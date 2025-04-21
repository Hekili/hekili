-- DemonHunterVengeance.lua
-- January 2025

-- TODO: Support soul_fragments.total, .inactive

if UnitClassBase( "player" ) ~= "DEMONHUNTER" then return end

local addon, ns = ...
local Hekili = _G[ addon ]
local class, state = Hekili.Class, Hekili.State

local floor = math.floor
local strformat = string.format
local IsSpellOverlayed = IsSpellOverlayed

local spec = Hekili:NewSpecialization( 581 )

spec:RegisterResource( Enum.PowerType.Fury, {
    -- Immolation Aura now grants 8 up front, then 2 per second
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
    -- 5 fury every 2 seconds for 8 seconds
    student_of_suffering = {
        aura    = "student_of_suffering",

        last = function ()
            local app = state.buff.student_of_suffering.applied
            local t = state.query_time

            return app + floor( t - app )
        end,

        interval = 2,
        value = 5
    },
} )

-- Talents
spec:RegisterTalents( {
    -- DemonHunter
    aldrachi_design           = {  90999, 391409, 1 }, -- Increases your chance to parry by 3%.
    aura_of_pain              = {  90933, 207347, 1 }, -- Increases the critical strike chance of Immolation Aura by 6%.
    blazing_path              = {  91008, 320416, 1 }, -- Infernal Strike gains an additional charge.
    bouncing_glaives          = {  90931, 320386, 1 }, -- Throw Glaive ricochets to 1 additional target.
    champion_of_the_glaive    = {  90994, 429211, 1 }, -- Throw Glaive has 2 charges and 10 yard increased range.
    chaos_fragments           = {  95154, 320412, 1 }, -- Each enemy stunned by Chaos Nova has a 30% chance to generate a Lesser Soul Fragment.
    chaos_nova                = {  90993, 179057, 1 }, -- Unleash an eruption of fel energy, dealing 6,678 Chaos damage and stunning all nearby enemies for 2 sec. Each enemy stunned by Chaos Nova has a 30% chance to generate a Lesser Soul Fragment.
    charred_warblades         = {  90948, 213010, 1 }, -- You heal for 4% of all Fire damage you deal.
    collective_anguish        = {  95152, 390152, 1 }, -- Fel Devastation summons an allied Havoc Demon Hunter who casts Eye Beam, dealing 56,864 Chaos damage over 1.7 sec. Deals reduced damage beyond 5 targets.
    consume_magic             = {  91006, 278326, 1 }, -- Consume 1 beneficial Magic effect removing it from the target.
    darkness                  = {  91002, 196718, 1 }, -- Summons darkness around you in an 8 yd radius, granting friendly targets a 15% chance to avoid all damage from an attack. Lasts 8 sec. Chance to avoid damage increased by 100% when not in a raid.
    demon_muzzle              = {  90928, 388111, 1 }, -- Enemies deal 8% reduced magic damage to you for 8 sec after being afflicted by one of your Sigils.
    demonic                   = {  91003, 213410, 1 }, -- Fel Devastation causes you to enter demon form for 5 sec after it finishes dealing damage.
    disrupting_fury           = {  90937, 183782, 1 }, -- Disrupt generates 30 Fury on a successful interrupt.
    erratic_felheart          = {  90996, 391397, 2 }, -- The cooldown of Infernal Strike is reduced by 10%.
    felblade                  = {  95150, 232893, 1 }, -- Charge to your target and deal 19,419 Fire damage. Fracture has a chance to reset the cooldown of Felblade. Generates 40 Fury.
    felfire_haste             = {  90939, 389846, 1 }, -- Infernal Strike increases your movement speed by 10% for 8 sec.
    flames_of_fury            = {  90949, 389694, 2 }, -- Sigil of Flame deals 35% increased damage and generates 1 additional Fury per target hit.
    illidari_knowledge        = {  90935, 389696, 1 }, -- Reduces magic damage taken by 5%.
    imprison                  = {  91007, 217832, 1 }, -- Imprisons a demon, beast, or humanoid, incapacitating them for 1 min. Damage may cancel the effect. Limit 1.
    improved_disrupt          = {  90938, 320361, 1 }, -- Increases the range of Disrupt to 10 yds.
    improved_sigil_of_misery  = {  90945, 320418, 1 }, -- Reduces the cooldown of Sigil of Misery by 30 sec.
    infernal_armor            = {  91004, 320331, 2 }, -- Immolation Aura increases your armor by 20% and causes melee attackers to suffer 2,916 Fire damage.
    internal_struggle         = {  90934, 393822, 1 }, -- Increases your mastery by 3.6%.
    live_by_the_glaive        = {  95151, 428607, 1 }, -- When you parry an attack or have one of your attacks parried, restore 2% of max health and 10 Fury. This effect may only occur once every 5 sec.
    long_night                = {  91001, 389781, 1 }, -- Increases the duration of Darkness by 3 sec.
    lost_in_darkness          = {  90947, 389849, 1 }, -- Spectral Sight has 5 sec reduced cooldown and no longer reduces movement speed.
    master_of_the_glaive      = {  90994, 389763, 1 }, -- Throw Glaive has 2 charges and snares all enemies hit by 50% for 6 sec.
    pitch_black               = {  91001, 389783, 1 }, -- Reduces the cooldown of Darkness by 120 sec.
    precise_sigils            = {  95155, 389799, 1 }, -- All Sigils are now placed at your target's location.
    pursuit                   = {  90940, 320654, 1 }, -- Mastery increases your movement speed.
    quickened_sigils          = {  95149, 209281, 1 }, -- All Sigils activate 1 second faster.
    rush_of_chaos             = {  95148, 320421, 2 }, -- Reduces the cooldown of Metamorphosis by 30 sec.
    shattered_restoration     = {  90950, 389824, 1 }, -- The healing of Shattered Souls is increased by 10%.
    sigil_of_misery           = {  90946, 207684, 1 }, -- Place a Sigil of Misery at the target location that activates after 1 sec. Causes all enemies affected by the sigil to cower in fear, disorienting them for 17 sec.
    sigil_of_spite            = {  90997, 390163, 1 }, -- Place a demonic sigil at the target location that activates after 1 sec. Detonates to deal 103,800 Chaos damage and shatter up to 3 Lesser Soul Fragments from enemies affected by the sigil. Deals reduced damage beyond 5 targets.
    soul_rending              = {  90936, 204909, 2 }, -- Leech increased by 6%. Gain an additional 6% leech while Metamorphosis is active.
    soul_sigils               = {  90929, 395446, 1 }, -- Afflicting an enemy with a Sigil generates 1 Lesser Soul Fragment.
    swallowed_anger           = {  91005, 320313, 1 }, -- Consume Magic generates 20 Fury when a beneficial Magic effect is successfully removed from the target.
    the_hunt                  = {  90927, 370965, 1 }, -- Charge to your target, striking them for 135,929 Chaos damage, rooting them in place for 1.5 sec and inflicting 105,579 Chaos damage over 6 sec to up to 5 enemies in your path. The pursuit invigorates your soul, healing you for 25% of the damage you deal to your Hunt target for 20 sec.
    unrestrained_fury         = {  90941, 320770, 1 }, -- Increases maximum Fury by 20.
    vengeful_bonds            = {  90930, 320635, 1 }, -- Vengeful Retreat reduces the movement speed of all nearby enemies by 70% for 3 sec.
    vengeful_retreat          = {  90942, 198793, 1 }, -- Remove all snares and vault away. Nearby enemies take 3,600 Physical damage.
    will_of_the_illidari      = {  91000, 389695, 1 }, -- Increases maximum health by 5%.

    -- Vengeance
    agonizing_flames          = {  90971, 207548, 1 }, -- Immolation Aura increases your movement speed by 10% and its duration is increased by 50%.
    ascending_flame           = {  90960, 428603, 1 }, -- Sigil of Flame's initial damage is increased by 50%. Multiple applications of Sigil of Flame may overlap.
    bulk_extraction           = {  90956, 320341, 1 }, -- Demolish the spirit of all those around you, dealing 7,825 Fire damage to nearby enemies and extracting up to 5 Lesser Soul Fragments, drawing them to you for immediate consumption.
    burning_alive             = {  90959, 207739, 1 }, -- Every 1 sec, Fiery Brand spreads to one nearby enemy.
    burning_blood             = {  90987, 390213, 1 }, -- Fire damage increased by 8%.
    calcified_spikes          = {  90967, 389720, 1 }, -- You take 12% reduced damage after Demon Spikes ends, fading by 1% per second.
    chains_of_anger           = {  90964, 389715, 1 }, -- Increases the duration of your Sigils by 2 sec and radius by 2 yds.
    charred_flesh             = {  90962, 336639, 2 }, -- Immolation Aura damage increases the duration of your Fiery Brand and Sigil of Flame by 0.25 sec.
    cycle_of_binding          = {  90963, 389718, 1 }, -- Sigil of Flame reduces the cooldown of your Sigils by 5 sec.
    darkglare_boon            = {  90985, 389708, 1 }, -- When Fel Devastation finishes fully channeling, it refreshes 15-30% of its cooldown and refunds 15-30 Fury.
    deflecting_spikes         = {  90989, 321028, 1 }, -- Demon Spikes also increases your Parry chance by 15% for 10 sec.
    down_in_flames            = {  90961, 389732, 1 }, -- Fiery Brand has 12 sec reduced cooldown and 1 additional charge.
    extended_spikes           = {  90966, 389721, 1 }, -- Increases the duration of Demon Spikes by 2 sec.
    fallout                   = {  90972, 227174, 1 }, -- Immolation Aura's initial burst has a chance to shatter Lesser Soul Fragments from enemies.
    feast_of_souls            = {  90969, 207697, 1 }, -- Soul Cleave heals you for an additional 33,553 over 6 sec.
    feed_the_demon            = {  90983, 218612, 1 }, -- Consuming a Soul Fragment reduces the remaining cooldown of Demon Spikes by 0.35 sec.
    fel_devastation           = {  90991, 212084, 1 }, -- Unleash the fel within you, damaging enemies directly in front of you for 69,683 Fire damage over 2 sec. Causing damage also heals you for up to 114,962 health.
    fel_flame_fortification   = {  90955, 389705, 1 }, -- You take 10% reduced magic damage while Immolation Aura is active.
    fiery_brand               = {  90951, 204021, 1 }, -- Brand an enemy with a demonic symbol, instantly dealing 50,546 Fire damage and 46,950 Fire damage over 12 sec. The enemy's damage done to you is reduced by 40% for 12 sec.
    fiery_demise              = {  90958, 389220, 2 }, -- Fiery Brand also increases Fire damage you deal to the target by 15%.
    focused_cleave            = {  90975, 343207, 1 }, -- Soul Cleave deals 50% increased damage to your primary target.
    fracture                  = {  90970, 263642, 1 }, -- Rapidly slash your target for 33,941 Physical damage, and shatter 2 Lesser Soul Fragments from them. Generates 25 Fury.
    frailty                   = {  90990, 389958, 1 }, -- Enemies struck by Sigil of Flame are afflicted with Frailty for 6 sec. You heal for 8% of all damage you deal to targets with Frailty.
    illuminated_sigils        = {  90961, 428557, 1 }, -- Sigil of Flame has 5 sec reduced cooldown and 1 additional charge. You have 12% increased chance to parry attacks from enemies afflicted by your Sigil of Flame.
    last_resort               = {  90979, 209258, 1 }, -- Sustaining fatal damage instead transforms you to Metamorphosis form. This may occur once every 8 min.
    meteoric_strikes          = {  90953, 389724, 1 }, -- Reduce the cooldown of Infernal Strike by 10 sec.
    painbringer               = {  90976, 207387, 2 }, -- Consuming a Soul Fragment reduces all damage you take by 1% for 6 sec. Multiple applications may overlap.
    perfectly_balanced_glaive = {  90968, 320387, 1 }, -- Reduces the cooldown of Throw Glaive by 6 sec.
    retaliation               = {  90952, 389729, 1 }, -- While Demon Spikes is active, melee attacks against you cause the attacker to take 3,510 Physical damage. Generates high threat.
    revel_in_pain             = {  90957, 343014, 1 }, -- When Fiery Brand expires on your primary target, you gain a shield that absorbs up 160,940 damage for 15 sec, based on your damage dealt to them while Fiery Brand was active.
    roaring_fire              = {  90988, 391178, 1 }, -- Fel Devastation heals you for up to 50% more, based on your missing health.
    ruinous_bulwark           = {  90965, 326853, 1 }, -- Fel Devastation heals for an additional 10%, and 100% of its healing is converted into an absorb shield for 10 sec.
    shear_fury                = {  90970, 389997, 1 }, -- Shear generates 10 additional Fury.
    sigil_of_chains           = {  90954, 202138, 1 }, -- Place a Sigil of Chains at the target location that activates after 1 sec. All enemies affected by the sigil are pulled to its center and are snared, reducing movement speed by 70% for 8 sec.
    sigil_of_silence          = {  90988, 202137, 1 }, -- Place a Sigil of Silence at the target location that activates after 1 sec. Silences all enemies affected by the sigil for 6 sec.
    soul_barrier              = {  90956, 263648, 1 }, -- Shield yourself for 15 sec, absorbing 279,615 damage. Consumes all available Soul Fragments to add 74,564 to the shield per fragment.
    soul_carver               = {  90982, 207407, 1 }, -- Carve into the soul of your target, dealing 75,092 Fire damage and an additional 32,588 Fire damage over 3 sec. Immediately shatters 3 Lesser Soul Fragments from the target and 1 additional Lesser Soul Fragment every 1 sec.
    soul_furnace              = {  90974, 391165, 1 }, -- Every 10 Soul Fragments you consume increases the damage of your next Soul Cleave or Spirit Bomb by 40%.
    soulcrush                 = {  90980, 389985, 1 }, -- Multiple applications of Frailty may overlap. Soul Cleave applies Frailty to your primary target for 8 sec.
    soulmonger                = {  90973, 389711, 1 }, -- When consuming a Soul Fragment would heal you above full health it shields you instead, up to a maximum of 184,766.
    spirit_bomb               = {  90978, 247454, 1 }, -- Consume up to 5 available Soul Fragments then explode, damaging nearby enemies for 8,870 Fire damage per fragment consumed, and afflicting them with Frailty for 6 sec, causing you to heal for 8% of damage you deal to them. Deals reduced damage beyond 8 targets.
    stoke_the_flames          = {  90984, 393827, 1 }, -- Fel Devastation damage increased by 35%.
    void_reaver               = {  90977, 268175, 1 }, -- Frailty now also reduces all damage you take from afflicted targets by 3%. Enemies struck by Soul Cleave are afflicted with Frailty for 6 sec.
    volatile_flameblood       = {  90986, 390808, 1 }, -- Immolation Aura generates 5-10 Fury when it deals critical damage. This effect may only occur once per 1 sec.
    vulnerability             = {  90981, 389976, 2 }, -- Frailty now also increases all damage you deal to afflicted targets by 2%.

    -- Aldrachi Reaver
    aldrachi_tactics          = {  94914, 442683, 1 }, -- The second enhanced ability in a pattern shatters an additional Soul Fragment.
    army_unto_oneself         = {  94896, 442714, 1 }, -- Felblade surrounds you with a Blade Ward, reducing damage taken by 10% for 5 sec.
    art_of_the_glaive         = {  94915, 442290, 1, "aldrachi_reaver" }, -- Consuming 20 Soul Fragments or casting The Hunt converts your next Throw Glaive into Reaver's Glaive.  Reaver's Glaive: Throw a glaive enhanced with the essence of consumed souls at your target, dealing 61,066 Physical damage and ricocheting to 3 additional enemies. Begins a well-practiced pattern of glaivework, enhancing your next Fracture and Soul Cleave. The enhanced ability you cast first deals 10% increased damage, and the second deals 20% increased damage.
    evasive_action            = {  94911, 444926, 1 }, -- Vengeful Retreat can be cast a second time within 3 sec.
    fury_of_the_aldrachi      = {  94898, 442718, 1 }, -- When enhanced by Reaver's Glaive, Soul Cleave casts 3 additional glaive slashes to nearby targets. If cast after Fracture, cast 6 slashes instead.
    incisive_blade            = {  94895, 442492, 1 }, -- Soul Cleave deals 10% increased damage.
    incorruptible_spirit      = {  94896, 442736, 1 }, -- Each Soul Fragment you consume shields you for an additional 15% of the amount healed.
    keen_engagement           = {  94910, 442497, 1 }, -- Reaver's Glaive generates 20 Fury.
    preemptive_strike         = {  94910, 444997, 1 }, -- Throw Glaive deals 3,813 Physical damage to enemies near its initial target.
    reavers_mark              = {  94903, 442679, 1 }, -- When enhanced by Reaver's Glaive, Fracture applies Reaver's Mark, which causes the target to take 7% increased damage for 20 sec. If cast after Soul Cleave, Reaver's Mark is increased to 14%.
    thrill_of_the_fight       = {  94919, 442686, 1 }, -- After consuming both enhancements, gain Thrill of the Fight, increasing your attack speed by 15% for 20 sec and your damage and healing by 20% for 10 sec.
    unhindered_assault        = {  94911, 444931, 1 }, -- Vengeful Retreat resets the cooldown of Felblade.
    warblades_hunger          = {  94906, 442502, 1 }, -- Consuming a Soul Fragment causes your next Fracture to deal 7,627 additional Physical damage.
    wounded_quarry            = {  94897, 442806, 1 }, -- Expose weaknesses in the target of your Reaver's Mark, causing your Physical damage to any enemy to also deal 20% of the damage dealt to your marked target as Chaos.

    -- Fel-Scarred
    burning_blades            = {  94905, 452408, 1 }, -- Your blades burn with Fel energy, causing your Soul Cleave, Throw Glaive, and auto-attacks to deal an additional 40% damage as Fire over 6 sec.
    demonic_intensity         = {  94901, 452415, 1 }, -- Activating Metamorphosis greatly empowers Fel Devastation, Immolation Aura, and Sigil of Flame. Demonsurge damage is increased by 10% for each time it previously triggered while your demon form is active.
    demonsurge                = {  94917, 452402, 1, "felscarred" }, -- Metamorphosis now also greatly empowers Soul Cleave and Spirit Bomb. While demon form is active, the first cast of each empowered ability induces a Demonsurge, causing you to explode with Fel energy, dealing 38,941 Fire damage to nearby enemies.
    enduring_torment          = {  94916, 452410, 1 }, -- The effects of your demon form persist outside of it in a weakened state, increasing maximum health by 5% and Armor by 20%.
    flamebound                = {  94902, 452413, 1 }, -- Immolation Aura has 2 yd increased radius and 30% increased critical strike damage bonus.
    focused_hatred            = {  94918, 452405, 1 }, -- Demonsurge deals 50% increased damage when it strikes a single target. Each additional target reduces this bonus by 10%.
    improved_soul_rending     = {  94899, 452407, 1 }, -- Leech granted by Soul Rending increased by 2% and an additional 2% while Metamorphosis is active.
    monster_rising            = {  94909, 452414, 1 }, -- Agility increased by 8% while not in demon form.
    pursuit_of_angriness      = {  94913, 452404, 1 }, -- Movement speed increased by 1% per 10 Fury.
    set_fire_to_the_pain      = {  94899, 452406, 1 }, -- 5% of all non-Fire damage taken is instead taken as Fire damage over 6 sec. Fire damage taken reduced by 10%.
    student_of_suffering      = {  94902, 452412, 1 }, -- Sigil of Flame applies Student of Suffering to you, increasing Mastery by 14.4% and granting 5 Fury every 2 sec, for 6 sec.
    untethered_fury           = {  94904, 452411, 1 }, -- Maximum Fury increased by 50.
    violent_transformation    = {  94912, 452409, 1 }, -- When you activate Metamorphosis, the cooldowns of your Sigil of Flame and Fel Devastation are immediately reset.
    wave_of_debilitation      = {  94913, 452403, 1 }, -- Chaos Nova slows enemies by 60% and reduces attack and cast speed 15% for 5 sec after its stun fades.
} )

-- PvP Talents
spec:RegisterPvpTalents( {
    blood_moon        = 5434, -- (355995)
    cleansed_by_flame =  814, -- (205625)
    cover_of_darkness = 5520, -- (357419)
    demonic_trample   = 3423, -- (205629) Transform to demon form, moving at 175% increased speed for 3 sec, knocking down all enemies in your path and dealing 2347.4 Physical damage. During Demonic Trample you are unaffected by snares but cannot cast spells or use your normal attacks. Shares charges with Infernal Strike.
    detainment        = 3430, -- (205596)
    everlasting_hunt  =  815, -- (205626)
    glimpse           = 5522, -- (354489)
    illidans_grasp    =  819, -- (205630) You strangle the target with demonic magic, stunning them in place and dealing 133,481 Shadow damage over 5 sec while the target is grasped. Can move while channeling. Use Illidan's Grasp again to toss the target to a location within 20 yards.
    jagged_spikes     =  816, -- (205627)
    rain_from_above   = 5521, -- (206803) You fly into the air out of harm's way. While floating, you gain access to Fel Lance allowing you to deal damage to enemies below.
    reverse_magic     = 3429, -- (205604) Removes all harmful magical effects from yourself and all nearby allies within 10 yards, and sends them back to their original caster if possible.
    sigil_mastery     = 1948, -- (211489)
    tormentor         = 1220, -- (207029) You focus the assault on this target, increasing their damage taken by 3% for 6 sec. Each unique player that attacks the target increases the damage taken by an additional 3%, stacking up to 5 times. Your melee attacks refresh the duration of Focused Assault.
    unending_hatred   = 3727, -- (213480)
} )

-- Auras
spec:RegisterAuras( {
    -- $w1 Soul Fragments consumed. At $?a212612[$442290s1~][$442290s2~], Reaver's Glaive is available to cast.
    art_of_the_glaive = {
        id = 444661,
        duration = 30.0,
        max_stack = 30,
    },
    -- Damage taken reduced by $s1%.
    blade_ward = {
        id = 442715,
        duration = 5.0,
        max_stack = 1,
    },
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
    calcified_spikes = {
        id = 391171,
        duration = 12,
        max_stack = 1
    },
    -- https://www.wowhead.com/spell=1490
    chaos_brand = {
        id = 1490,
        duration = 3600,
        max_stack = 1,
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
        duration = function() return ( talent.long_night.enabled and 11 or 8 ) + ( talent.cover_of_darkness.enabled and 2 or 0 ) end,
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
        duration = function() return 8 + talent.extended_spikes.rank end,
        max_stack = 1
    },
    -- https://www.wowhead.com/spell=452416
    -- Demonsurge Damage of your next Demonsurge is increased by 10%.
    demonsurge = {
        id = 452416,
        duration = 12,
        max_stack = 6,
    },
    -- Fake buffs for demonsurge damage procs
    demonsurge_hardcast = {
        id = 452489
    },
    demonsurge_consuming_fire = {},
    demonsurge_fel_desolation = {},
    demonsurge_sigil_of_doom = {},
    demonsurge_soul_sunder = {},
    demonsurge_spirit_burst = {},
    -- Vengeful Retreat may be cast again.
    evasive_action = {
        id = 444929,
        duration = 3.0,
        max_stack = 1,
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
        id = 393009,
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
    glaive_flurry = {
        id = 442435,
        duration = 30,
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
        max_stack = 1,
        -- This copy is for SIMC compatability while avoiding managing a virtual buff
        copy = "demonsurge_demonic"
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
    -- Agility increased by $w1%.
    monster_rising = {
        id = 452550,
        duration = 3600,
        max_stack = 1
    },
    painbringer = {
        id = 212988,
        duration = 6,
        max_stack = 30
    },
    -- $w3
    pursuit_of_angriness = {
        id = 452404,
        duration = 0.0,
        tick_time = 1.0,
        max_stack = 1,
    },
    reavers_glaive = {
    },
    reavers_mark = {
        id = 442624,
        duration = 20,
        max_stack = 1
    },
    rending_strike = {
        id = 442442,
        duration = 30,
        max_stack = 1
    },
    ruinous_bulwark = {
        id = 326863,
        duration = 10,
        max_stack = 1
    },
    -- Taking $w1 Fire damage every $t1 sec.
    set_fire_to_the_pain = {
        id = 453286,
        duration = 6.0,
        tick_time = 1.0,
        max_stack = 1,
    },
    -- Talent: Movement slowed by $s1%.
    -- https://wowhead.com/beta/spell=204843
    sigil_of_chains = {
        id = 204843,
        duration = function () return 6 + ( 2 * talent.chains_of_anger.rank ) end,
        type = "Magic",
        max_stack = 1
    },
    sigil_of_doom = {
        id = 462030,
        duration = 8,
        max_stack = 1
    },
    sigil_of_doom_active = {
        id = 452490,
        duration = 2,
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
        duration = function () return 15 + ( 2 * talent.chains_of_anger.rank ) end,
        mechanic = "flee",
        type = "Magic",
        max_stack = 1
    },
    -- Talent: Silenced.
    -- https://wowhead.com/beta/spell=204490
    sigil_of_silence = {
        id = 204490,
        duration = function () return 4 + ( 2 * talent.chains_of_anger.rank ) end,
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
        max_stack = 9,
        copy = 339424
    },
    soul_furnace = {
        id = 391172,
        duration = 30,
        max_stack = 1,
        copy = "soul_furnace_damage_amp"
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
    -- Mastery increased by ${$w1*$mas}.1%. ; Generating $453236s1 Fury every $t2 sec.
    student_of_suffering = {
        id = 453239,
        duration = 6,
        max_stack = 1
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
    -- Attack Speed increased by $w1%
    thrill_of_the_fight = {
        id = 442695,
        duration = 20.0,
        max_stack = 1,
        copy = "thrill_of_the_fight_attack_speed"
    },
    thrill_of_the_fight_damage = {
        id = 442688,
        duration = 10,
        max_stack = 1
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
    -- Your next $?a212612[Chaos Strike]?s263642[Fracture][Shear] will deal $442507s1 additional Physical damage.
    warblades_hunger = {
        id = 442503,
        duration = 30.0,
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

spec:RegisterStateExpr( "soul_fragments", function ()
    return buff.soul_fragments.stack
end )

spec:RegisterStateExpr( "last_infernal_strike", function ()
    return action.infernal_strike.lastCast
end )

spec:RegisterStateExpr( "activation_time", function()
    return talent.quickened_sigils.enabled and 1 or 2
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

-- Abilities that may trigger Demonsurge.
local demonsurge = {
    demonic = { "soul_sunder", "spirit_burst" },
    hardcast = { "consuming_fire", "fel_desolation", "sigil_of_doom" },
}

spec:RegisterHook( "reset_precast", function ()
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

    if IsSpellKnownOrOverridesKnown( 442294 ) or IsSpellOverlayed( 442294 ) then
        applyBuff( "reavers_glaive" )
        if Hekili.ActiveDebug then Hekili:Debug( "Applied Reaver's Glaive." ) end
    end

    if talent.demonsurge.enabled and buff.metamorphosis.up then
        local metaRemains = buff.metamorphosis.remains

        for _, name in ipairs( demonsurge.demonic ) do
            if IsSpellOverlayed( class.abilities[ name ].id ) then
                applyBuff( "demonsurge_" .. name, metaRemains )
            end
        end
        if talent.demonic_intensity.enabled then
            local metaApplied = ( buff.metamorphosis.applied - 0.005 ) -- fudge-factor because GetTime has ms precision
            if action.metamorphosis.lastCast >= metaApplied or action.fel_desolation.lastCast >= metaApplied then
                applyBuff( "demonsurge_hardcast", metaRemains )
            end
            for _, name in ipairs( demonsurge.hardcast ) do
                if IsSpellOverlayed( class.abilities[ name ].id ) then
                    applyBuff( "demonsurge_" .. name, metaRemains )
                end
            end
        end

        if Hekili.ActiveDebug then
            Hekili:Debug( "Demonsurge status:\n" ..
                " - Hardcast " .. ( buff.demonsurge_hardcast.up and "ACTIVE" or "INACTIVE" ) .. "\n" ..
                " - Demonic " .. ( buff.demonsurge_demonic.up and "ACTIVE" or "INACTIVE" ) .. "\n" ..
                " - Consuming Fire " .. ( buff.demonsurge_consuming_fire.up and "ACTIVE" or "INACTIVE" ) .. "\n" ..
                " - Fel Desolation " .. ( buff.demonsurge_fel_desolation.up and "ACTIVE" or "INACTIVE" ) .. "\n" ..
                " - Sigil of Doom " .. ( buff.demonsurge_sigil_of_doom.up and "ACTIVE" or "INACTIVE" ) .. "\n" ..
                " - Soul Sunder " .. ( buff.demonsurge_soul_sunder.up and "ACTIVE" or "INACTIVE" ) .. "\n" ..
                " - Spirit Burst " .. ( buff.demonsurge_spirit_burst.up and "ACTIVE" or "INACTIVE" ) )
        end
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

--[[
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
end )--]]

-- The War Within
spec:RegisterGear( "tww2", 229316, 229314, 229319, 229317, 229315 )

-- Dragonflight
spec:RegisterGear( "tier29", 200345, 200347, 200342, 200344, 200346 )
spec:RegisterAura( "decrepit_souls", {
    id = 394958,
    duration = 8,
    max_stack = 1
} )
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

-- Legacy
spec:RegisterGear( "tier19", 138375, 138376, 138377, 138378, 138379, 138380 )
spec:RegisterGear( "tier20", 147130, 147132, 147128, 147127, 147129, 147131 )
spec:RegisterGear( "tier21", 152121, 152123, 152119, 152118, 152120, 152122 )
spec:RegisterGear( "class", 139715, 139716, 139717, 139718, 139719, 139720, 139721, 139722 )
spec:RegisterGear( "convergence_of_fates", 140806 )

local ConsumeSoulFragments = setfenv( function( amt )
    if talent.soul_furnace.enabled then
        local overflow = buff.soul_furnace_stack.stack + amt
        if overflow >= 10 then
            applyBuff( "soul_furnace" )
            overflow = overflow - 10
            if overflow > 0 then -- stacks carry over past 10 to start a new stack
                applyBuff( "soul_furnace_stack", nil, overflow )
            end
        else
            addStack( "soul_furnace_stack", nil, amt )
        end
    end
    -- Reaver Tree
    if talent.art_of_the_glaive.enabled then
        addStack( "art_of_the_glaive", nil, amt )
        if  buff.art_of_the_glaive.stack == 20 then
            removeBuff( "art_of_the_glaive" )
            applyBuff( "reavers_glaive" )
        end
    end
    if talent.warblades_hunger.enabled then
        addStack( "warblades_hunger", nil, amt )
    end

    gainChargeTime( "demon_spikes", ( 0.35 * talent.feed_the_demon.rank * amt ) )
    buff.soul_fragments.count = max( 0, buff.soul_fragments.stack - amt )
end, state )

local sigilList = { "sigil_of_flame", "sigil_of_misery", "sigil_of_spite", "sigil_of_silence", "sigil_of_chains", "sigil_of_doom" }

local TriggerDemonic = setfenv( function()
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
    -- Talent: Demolish the spirit of all those around you, dealing $s1 Fire damage to nearby enemies and extracting up to $s2 Lesser Soul Fragments, drawing them to you for immediate consumption.
    bulk_extraction = {
        id = 320341,
        cast = 0,
        cooldown = 60,
        gcd = "spell",
        school = "fire",

        talent = "bulk_extraction",
        startsCombat = true,
        texture = 136194,

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
        texture = 135795,

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
        texture = 1305154,

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
        hasteCD = true,

        icd = 1.5,
        gcd = "off",
        school = "physical",

        startsCombat = false,

        toggle = "defensives",
        defensive = true,

        handler = function ()
            if talent.calcified_spikes.enabled and buff.demon_spikes.up then applyBuff( "calcified_spikes" ) end
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
        cast = 2,
        channeled = true,
        cooldown = 40,
        fixedCast = true,
        gcd = "spell",
        school = "fire",

        spend = 50,
        spendType = "fury",

        talent = "fel_devastation",
        startsCombat = true,
        texture = 1450143,
        nobuff = function () return talent.demonic_intensity.enabled and "metamorphosis" or nil end,

        start = function ()
            applyBuff( "fel_devastation" )
            if talent.demonic.enabled then TriggerDemonic() end
        end,

        finish = function ()
            if talent.darkglare_boon.enabled then
                gain( 15, "fury" )
                reduceCooldown( "fel_devastation", 6 )
            end
            if talent.ruinous_bulwark.enabled then applyBuff( "ruinous_bulwark" ) end
        end,

        bind = "fel_desolation"
    },

    fel_desolation = {
		id = 452486,
        known = 212084,
        cast = 2,
        channeled = true,
        cooldown = 40,
        fixedCast = true,
        gcd = "spell",
        school = "fire",

        spend = 50,
        spendType = "fury",

        talent = "demonic_intensity",
        startsCombat = true,
        texture = 135798,
        buff = "demonsurge_hardcast",

        start = function ()
            if buff.demonsurge_fel_desolation.up then
                removeBuff( "demonsurge_fel_desolation" )
                if talent.demonic_intensity.enabled then addStack( "demonsurge" ) end
            end
            spec.abilities.fel_devastation.start()
        end,

        finish = function ()
            spec.abilities.fel_devastation.finish()
        end,

        bind = "fel_devastation"
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

    -- Talent: Brand an enemy with a demonic symbol, instantly dealing $sw2 Fire damage$?s320962[ and ${$207771s3*$207744d} Fire damage over $207744d][]. The enemy's damage done to you is reduced by $s1% for $207744d.
    fiery_brand = {
        id = 204021,
        cast = 0,
        charges = function() return talent.down_in_flames.enabled and 2 or nil end,
        cooldown = function() return ( talent.down_in_flames.enabled and 48 or 60 ) + ( conduit.fel_defender.mod * 0.001 ) end,
        recharge = function() return talent.down_in_flames.enabled and ( 48 + ( conduit.fel_defender.mod * 0.001 ) ) or nil end,
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

        spend = function() return ( buff.metamorphosis.up and -45 or -25 ) end,
        spendType = "fury",

        talent = "fracture",
        bind = "shear",
        startsCombat = true,

        handler = function ()

            spec.abilities.shear.handler()
            addStack( "soul_fragments", nil, 1 )

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
        id = function() return buff.demonsurge_hardcast.up and 452487 or 258920 end,
        cast = 0,
        cooldown = 15,
        hasteCD = true,

        gcd = "spell",
        school = "fire",
        texture = function() return buff.demonsurge_hardcast.up and 135794 or 1344649 end,
        -- nobuff = "demonsurge_hardcast",

        spend = -8,
        spendType = "fury",
        startsCombat = true,

        handler = function ()
            applyBuff( "immolation_aura" )
            if legendary.fel_flame_fortification.enabled then applyBuff( "fel_flame_fortification" ) end
            if pvptalent.cleansed_by_flame.enabled then
                removeDebuff( "player", "reversible_magic" )
            end

            if talent.fallout.enabled then
                addStack( "soul_fragments", nil, active_enemies < 3 and 1 or 2 )
            end

            -- Fel-Scarred
            if buff.demonsurge_consuming_fire.up then
                removeBuff( "demonsurge_consuming_fire" )
                if talent.demonic_intensity.enabled then addStack( "demonsurge" ) end
            end

        end,

        tick = function ()
            if talent.charred_flesh.enabled then
                if debuff.fiery_brand.up then applyDebuff( "target", debuff.fiery_brand.remains + 0.25 * talent.charred_flesh.rank ) end
                if debuff.sigil_of_flame.up then applyDebuff( "target", debuff.sigil_of_flame.remains + 0.25 * talent.charred_flesh.rank ) end
            end
        end,

        bind = "consuming_fire",
        copy = "consuming_fire"
    },

    --[[consuming_fire = {
        id = 452487,
        known = 258920,
        cast = 0,
        cooldown = 15,
        hasteCD = true,
        gcd = "spell",
        school = "fire",
        texture = 135794,

        spend = -8,
        spendType = "fury",
        startsCombat = true,
        talent = "demonic_intensity",
        buff = "demonsurge_hardcast",

        handler = function ()
            applyBuff( "immolation_aura" )
            if legendary.fel_flame_fortification.enabled then applyBuff( "fel_flame_fortification" ) end
            if pvptalent.cleansed_by_flame.enabled then
                removeDebuff( "player", "reversible_magic" )
            end

            if talent.fallout.enabled then
                addStack( "soul_fragments", nil, active_enemies < 3 and 1 or 2 )
            end
            if buff.demonsurge_consuming_fire.up then
                removeBuff( "demonsurge_consuming_fire" )
                if talent.demonic_intensity.enabled then addStack( "demonsurge" ) end
            end
        end,

        bind = "immolation_aura",
    },--]]

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
        cooldown = function() return ( 20 - ( 10 * talent.meteoric_strikes.rank ) ) * ( 1 - 0.1 * talent.erratic_felheart.rank ) end,
        recharge = function() return talent.blazing_path.enabled and ( 20 - ( 10 * talent.meteoric_strikes.rank ) ) * ( 1 - 0.1 * talent.erratic_felheart.rank ) or nil end,

        gcd = "off",
        school = "physical",
        icd = function () return gcd.max + 0.1 end,

        startsCombat = false,
        nodebuff = "rooted",

        readyTime = function ()
            if ( settings.infernal_charges or 1 ) == 0 then return end
            return ( ( 1 + ( settings.infernal_charges or 1 ) ) - cooldown.infernal_strike.charges_fractional ) * cooldown.infernal_strike.recharge
        end,

        handler = function ()
            setDistance( 5 )
            spendCharges( "demonic_trample", 1 )

            if talent.felfire_haste.enabled or conduit.felfire_haste.enabled then applyBuff( "felfire_haste" ) end
        end,
    },

    -- Transform to demon form for $d, increasing current and maximum health by $s2% and Armor by $s8%$?s235893[. Versatility increased by $s5%][]$?s321067[. While transformed, Shear and Fracture generate one additional Lesser Soul Fragment][]$?s321068[ and $s4 additional Fury][].
    metamorphosis = {
        id = 187827,
        cast = 0,
        cooldown = function() return ( 180 - ( 30 * talent.rush_of_chaos.rank) ) end,
        gcd = "off",
        school = "chaos",

        startsCombat = false,

        toggle = "cooldowns",

        handler = function ()
            applyBuff( "metamorphosis", buff.metamorphosis.remains + 15 )
            gain( health.max * 0.4, "health" )

            if talent.demonsurge.enabled then
                local metaRemains = buff.metamorphosis.remains

                for _, name in ipairs( demonsurge.demonic ) do
                    applyBuff( "demonsurge_ " .. name, metaRemains )
                end

                if talent.violent_transformation.enabled then
                    setCooldown( "sigil_of_flame", 0 )
                    setCooldown( "fel_devastation", 0 )
                    if talent.demonic_intensity.enabled then
                        setCooldown( "sigil_of_doom", 0 )
                        setCooldown( "fel_desolation", 0 )
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

        spend = function () return -1 * ( 10 + 10 * talent.shear_fury.rank + ( buff.metamorphosis.up and 20 or 0 ) ) end,

        notalent = "fracture",
        bind = "fracture",
        startsCombat = true,

        handler = function ()
            if buff.rending_strike.up then -- Reaver stuff
                applyDebuff( "target", "reavers_mark" )
                removeBuff( "rending_strike" )
                if talent.thrill_of_the_fight.enabled and buff.glaive_flurry.down then
                    applyBuff( "thrill_of_the_fight" )
                    applyBuff( "thrill_of_the_fight_damage" )
                end
            end

            -- Legacy
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
        gcd = "spell",
        school = "physical",

        talent = "sigil_of_chains",
        startsCombat = false,

        flightTime = function() return activation_time end,
        delay = function() return activation_time end,
        placed = function() return query_time < action.sigil_of_chains.lastCast + activation_time end,
        impact = function ()
            applyDebuff( "target", "sigil_of_chains" )
        end,

        copy = { 202138, 389807 }
    },

    -- Talent: Place a Sigil of Flame at your location that activates after $d.    Deals $204598s1 Fire damage, and an additional $204598o3 Fire damage over $204598d, to all enemies affected by the sigil.    |CFFffffffGenerates $389787s1 Fury.|R
    sigil_of_flame = {
        id = function () return talent.precise_sigils.enabled and 389810 or 204596 end,
        known = 204596,
        cast = 0,
        cooldown = function() return ( pvptalent.sigil_of_mastery.enabled and 0.75 or 1 ) * 30 - ( talent.illuminated_sigils.enabled and 5 or 0 ) end,
        charges = function () return talent.illuminated_sigils.enabled and 2 or 1 end,
        recharge = function() return ( pvptalent.sigil_of_mastery.enabled and 0.75 or 1 ) * 30 - ( talent.illuminated_sigils.enabled and 5 or 0 ) end,
        gcd = "spell",
        icd = function() return 0.25 + activation_time end,
        school = "physical",

        spend = -30,
        spendType = "fury",

        startsCombat = false,
        texture = 1344652,
        nobuff = "demonsurge_hardcast",

        flightTime = function() return activation_time end,
        delay = function() return activation_time end,
        placed = function() return query_time < action.sigil_of_flame.lastCast + activation_time end,

        handler = function ()
            if talent.cycle_of_binding.enabled then
                for _, sigil in ipairs( sigilList ) do
                    reduceCooldown( sigil, 5 )
                end
            end
        end,

        impact = function()
            applyDebuff( "target", "sigil_of_flame" )
            active_dot.sigil_of_flame = active_enemies
            if talent.soul_sigils.enabled then addStack( "soul_fragments", nil, 1 ) end
            if talent.student_of_suffering.enabled then applyBuff( "student_of_suffering" ) end
            if talent.flames_of_fury.enabled then gain( talent.flames_of_fury.rank * active_enemies, "fury" ) end
            if talent.frailty.enabled then
                if talent.soulcrush.enabled and debuff.frailty.up then
                    -- Soulcrush allows for multiple applications of Frailty.
                    applyDebuff( "target", "frailty", nil, debuff.frailty.stack + 1 )
                else
                    applyDebuff( "target", "frailty" )
                end
                active_dot.frailty = active_enemies
            end
        end,

        bind = "sigil_of_doom",
        copy = { 204596, 389810 }
    },

    sigil_of_doom = {
        id = function () return talent.precise_sigils.enabled and 469991 or 452490 end,
        known = 204596,
        cast = 0,
        cooldown = function() return ( pvptalent.sigil_of_mastery.enabled and 0.75 or 1 ) * 30 - ( talent.illuminated_sigils.enabled and 5 or 0 ) end,
        charges = function () return talent.illuminated_sigils.enabled and 2 or 1 end,
        recharge = function() return ( pvptalent.sigil_of_mastery.enabled and 0.75 or 1 ) * 30 - ( talent.illuminated_sigils.enabled and 5 or 0 ) end,
        gcd = "spell",
        icd = function() return 0.25 + activation_time end,
        school = "physical",

        spend = -30,
        spendType = "fury",

        startsCombat = false,
        texture = 1121022,
        talent = "demonic_intensity",
        buff = "demonsurge_hardcast",

        flightTime = function() return activation_time end,
        delay = function() return activation_time end,
        placed = function() return query_time < action.sigil_of_doom.lastCast + activation_time end,

        handler = function ()
            if buff.demonsurge_sigil_of_doom.up then
                removeBuff( "demonsurge_sigil_of_doom" )
                if talent.demonic_intensity.enabled then addStack( "demonsurge" ) end
            end
            spec.abilities.sigil_of_flame.handler()
            -- Sigil of Doom and Sigil of Flame share a cooldown.
            setCooldown( "sigil_of_flame", action.sigil_of_doom.cooldown )
        end,

        impact = function()
            applyDebuff( "target", "sigil_of_doom" )
            active_dot.sigil_of_doom = active_enemies
            if talent.soul_sigils.enabled then addStack( "soul_fragments", nil, 1 ) end
            if talent.student_of_suffering.enabled then applyBuff( "student_of_suffering" ) end
            if talent.flames_of_fury.enabled then gain( talent.flames_of_fury.rank * active_enemies, "fury" ) end
            if talent.frailty.enabled then
                if talent.soulcrush.enabled and debuff.frailty.up then
                    -- Soulcrush allows for multiple applications of Frailty.
                    applyDebuff( "target", "frailty", nil, debuff.frailty.stack + 1 )
                else
                    applyDebuff( "target", "frailty" )
                end
                active_dot.frailty = active_enemies
            end
        end,

        bind = "sigil_of_flame",
        copy = { 452490, 469991 }
    },

    -- Talent: Place a Sigil of Misery at your location that activates after $d.    Causes all enemies affected by the sigil to cower in fear. Targets are disoriented for $207685d.
    sigil_of_misery = {
        id = function () return talent.precise_sigils.enabled and 389813 or 207684 end,
        known = 207684,
        cast = 0,
        cooldown = function () return ( pvptalent.sigil_mastery.enabled and 0.75 or 1 ) * 120 - ( talent.improved_sigil_of_misery.enabled and 30 or 0 ) end,
        gcd = "spell",
        school = "physical",

        talent = "sigil_of_misery",
        startsCombat = false,

        toggle = "interrupts",

        flightTime = function() return activation_time end,
        delay = function() return activation_time end,
        placed = function() return query_time < action.sigil_of_misery.lastCast + activation_time end,

        impact = function ()
            applyDebuff( "target", "sigil_of_misery_debuff" )
        end,

        copy = { 207684, 389813 }
    },

    sigil_of_silence = {
        id = function () return talent.precise_sigils.enabled and 389809 or 202137 end,
        known = 202137,
        cast = 0,
        cooldown = function () return ( pvptalent.sigil_mastery.enabled and 0.75 or 1 ) * 60 end,
        gcd = "spell",

        startsCombat = true,
        texture = 1418288,

        toggle = "interrupts",

        flightTime = function() return activation_time end,
        delay = function() return activation_time end,
        placed = function() return query_time < action.sigil_of_silence.lastCast + activation_time end,

        usable = function () return debuff.casting.remains > activation_time end,

        impact = function()
            interrupt()
            applyDebuff( "target", "sigil_of_silence" )
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

    -- Place a demonic sigil at the target location that activates after $d.; Detonates to deal $389860s1 Chaos damage and shatter up to $s3 Lesser Soul Fragments from enemies affected by the sigil. Deals reduced damage beyond $s1 targets.
    sigil_of_spite = {
        id = function () return talent.precise_sigils.enabled and 389815 or 390163 end,
        known = 390163,
        cast = 0.0,
        cooldown = function () return ( pvptalent.sigil_mastery.enabled and 0.75 or 1 ) * 60 end,
        gcd = "spell",

        talent = "sigil_of_spite",
        startsCombat = false,

        flightTime = function() return activation_time end,
        delay = function() return activation_time end,
        placed = function() return query_time < action.sigil_of_spite.lastCast + activation_time end,

        impact = function()
            addStack( "soul_fragments", nil, talent.soul_sigils.enabled and 4 or 3 )
        end,

        copy = { 390163, 389815 }
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

            ConsumeSoulFragments( buff.soul_fragments.stack )
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
        texture = 1344653,
        nobuff = function() if talent.demonsurge.enabled then return "demonsurge_demonic" end end,

        handler = function ()
            removeBuff( "soul_furnace" )

            --
            if buff.glaive_flurry.up then -- Reaver stuff
                removeBuff( "glaive_flurry" )
                if talent.thrill_of_the_fight.enabled and buff.rending_strike.down then
                    applyBuff( "thrill_of_the_fight" )
                    applyBuff( "thrill_of_the_fight_damage" )
                end
            end

            if talent.feast_of_souls.enabled then applyBuff( "feast_of_souls" ) end
            if talent.soulcrush.enabled then
                if debuff.frailty.up then
                    -- Soulcrush allows for multiple applications of Frailty.
                    applyDebuff( "target", "frailty", 8, debuff.frailty.stack + 1 )
                else
                    applyDebuff( "target", "frailty", 8 )
                end
            end
            if talent.void_reaver.enabled then active_dot.frailty = true_active_enemies end

            ConsumeSoulFragments( min( 2, buff.soul_fragments.stack ) )

            if legendary.fiery_soul.enabled then reduceCooldown( "fiery_brand", 2 * min( 2, buff.soul_fragments.stack ) ) end
        end,

        bind = "soul_sunder"
    },

    -- Viciously strike up to $228478s2 enemies in front of you for $228478s1 Physical damage and heal yourself for $s4.    Consumes up to $s3 available Soul Fragments$?s321021[ and heals you for an additional $s5 for each Soul Fragment consumed][].
    soul_sunder = {
		id = 452436,
        known = 228477,
        cast = 0,
        cooldown = 0,
        gcd = "spell",
        school = "physical",

        spend = 30,
        spendType = "fury",

        startsCombat = true,
        texture = 1355117,
        talent = "demonsurge",
        buff = "demonsurge_demonic",

        handler = function ()

            if buff.demonsurge_soul_sunder.up then
                removeBuff( "demonsurge_soul_sunder" )
                if talent.demonic_intensity.enabled then addStack( "demonsurge" ) end
            end
            spec.abilities.soul_cleave.handler()
        end,

        bind = "soul_cleave"
    },

    -- Allows you to see enemies and treasures through physical barriers, as well as enemies that are stealthed and invisible. Lasts $d.    Attacking or taking damage disrupts the sight.
    spectral_sight = {
        id = 188501,
        cast = 0,
        cooldown = function() return 30 - ( 5 * talent.lost_in_darkness.rank ) end,
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
        nobuff = function() if talent.demonsurge.enabled then return "demonsurge_demonic" end end,

        handler = function ()
            if talent.soulcrush.enabled and debuff.frailty.up then
                -- Soulcrush allows for multiple applications of Frailty.
                applyDebuff( "target", "frailty", nil, debuff.frailty.stack + 1 )
            else
                applyDebuff( "target", "frailty" )
            end
            active_dot.frailty = active_enemies
            removeBuff( "soul_furnace" )
            ConsumeSoulFragments( min( 5, buff.soul_fragments.stack ) )
        end,


        bind = "spirit_burst"
    },

    spirit_burst = {
        id = 452437,
        known = 247454,
        cast = 0,
        cooldown = 0,
        gcd = "spell",
        school = "fire",

        spend = 40,
        spendType = "fury",

        talent = "demonsurge",
        startsCombat = false,
        buff = function () return buff.metamorphosis.down and "metamorphosis" or "soul_fragments" end,

        handler = function ()
            if buff.demonsurge_spirit_burst.up then
                removeBuff( "demonsurge_spirit_burst" )
                if talent.demonic_intensity.enabled then addStack( "demonsurge" ) end
            end
            spec.abilities.spirit_bomb.handler()
        end,

        bind = "spirit_bomb"
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

            if legendary.blazing_slaughter.enabled then
                applyBuff( "immolation_aura" )
                applyBuff( "blazing_slaughter" )
            end
            -- Hero Talents
            if talent.art_of_the_glaive.enabled then applyBuff( "reavers_glaive" ) end

        end,

        copy = { 370965, 323639 }
    },

    reavers_glaive = {
        id = 442294,
        cast = 0,
        charges = function() return 1 + talent.champion_of_the_glaive.rank + talent.master_of_the_glaive.rank end,
        cooldown = function() return talent.perfectly_balanced_glaive.enabled and 3 or 9 end,
        recharge = function() if ( talent.champion_of_the_glaive.rank + talent.master_of_the_glaive.rank ) > 0 then
            return ( talent.perfectly_balanced_glaive.enabled and 3 or 9 ) end
            end,
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

    -- Throw a demonic glaive at the target, dealing $337819s1 Physical damage. The glaive can ricochet to $?$s320386[${$337819x1-1} additional enemies][an additional enemy] within 10 yards.
    throw_glaive = {
        id = 204157,
        cast = 0,
        charges = function() return 1 + talent.champion_of_the_glaive.rank + talent.master_of_the_glaive.rank end,
        cooldown = function() return talent.perfectly_balanced_glaive.enabled and 3 or 9 end,
        recharge = function() if ( talent.champion_of_the_glaive.rank + talent.master_of_the_glaive.rank ) > 0 then
            return ( talent.perfectly_balanced_glaive.enabled and 3 or 9 ) end
            end,
        gcd = "spell",
        school = "physical",

        -- spend = function() return talent.furious_throws.enabled and 25 or nil end,
        -- spendType = function() return talent.furious_throws.enabled and "fury" or nil end,

        startsCombat = true,
        nobuff = "reavers_glaive",

        handler = function ()
            if talent.master_of_the_glaive.enabled then applyDebuff( "target", "master_of_the_glaive" ) end
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
        cooldown = 25,
        gcd = "spell",

        startsCombat = true,
        nodebuff = "rooted",
        talent = "vengeful_retreat",

        readyTime = function ()
            if settings.recommend_movement then return 0 end
            return 3600
        end,

        handler = function ()
            if talent.evasive_action.enabled and buff.evasive_action.down then
                applyBuff( "evasive_action" )
                setCooldown( "vengeful_retreat", 0 )
            end
            if talent.vengeful_bonds.enabled and action.chaos_strike.in_range then -- 20231116: and target.within8 then
                applyDebuff( "target", "vengeful_retreat" )
            end

            if talent.unhindered_assault.enabled then setCooldown( "felblade", 0 ) end
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

    potion = "tempered_potion",

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


spec:RegisterPack( "Vengeance", 20250303, [[Hekili:S3ZAVnsoY9BX3IOvYESgP2wZm7flFi5coKBrYgGZls(qqSuBRw2cwsTVUBnpam0V9uKnjB(Ok2Sv3ASVBpGf3nwKDXQkwSEXIK3o(2F92BwexKC7VenkAYOlgDXWXFAYLt(PBVP4BpNC7nphF)tXpa)JTXBG)3)7KTpKeV9EElFBDA8cgeYt3LX(PhlkEo)3)(3)WQIh3D3W7t38(8vB2ToUyv627ZIxwW(77F)T3C3UvRl(ZBV9oSH)IjFaG5Zj3F7Vm5tJbWUAXIKY(MKF)T3W675JUa(VF)(5)PvFnjF)8LPz7N)VSErw89pUA)8)ss8NtYgU)N3)ZqVV88XJop6NGEpE8WrdNy8ZJHF(MvB(J7NV7zgU8U9ZxbiBsCEY(5lswMSnF1Nt2MKdJs8(53TQq95J(PZJIS(C9ghZA8VKSAZZRt2KSTy)8)TKnPBZ3L9Gz)g5biJy49V(LK4N2p)ZXzRIVBnGySPdaHksbmc(Z7bOUkVGpgCwXF6gO35dbEYF5Fg(PvFD)8VedO(81PPpBa(XabZ())ejo8XZJyC6F9ryG(FIbG))aZVR2cIazPlxTgM4JVNndNp85Seys)U4IZM(EjU(ogQonF12hwNmRigi9I395417GF75K1Rf)u(W8NxLTQy2DW3pD8(FoaqUjg(840K6a31tJ6r24vtNeYGD3QhcBO(qiqRiB12NskMnE2D7wUmxavXVoC8WhJZNTlpH36lV03Sb2pom(HvRxv8TxEbPTnXGKqgEBWQICy5i53(i7BrB5EGgh0eIlcL4IOiUipexKhIlQgIlIK4IcI4IZUpEli5MMLXwEH2N8vagplD5SLRboW7wTC6JjzPZkYssggluknlJRtcO4Q2wMSo)(yaWl6veVga)W8IDGUUcgSYbelbq1hiqSvB2KwQADw8USy26vr3GgxSkpB3Zfg)et3Zmqy9PK83XMasxUC2d3Vy6ygcFcNpO3NH7EUx)I4TpbOaW0wTj5Qjd0bO50(2DBGpm(lBz)0mWKW683L(80SKCybpOhnE36IPJA83Vj(RcjioAkztqZZ4C98E3NMUEr6x2o0Cwaq)wmyrAd2sy(Ryxws1ij)LH3)ithq(m(paJu86RNoUxjVCtsr8M0SNFmfun3oS5I2GnDdYeVyb18aibdc296xnru9RdZs2eVAB(14TUaeCzOX5xmWq0A1wq0hW)z5WI1Nsmfx17y2oq6N)xZwdgaljH4S3X(U7leI2yl4QfiGMlDGGdJQvMXzUgOE(UzfpclaEeOCgpewjSA57aB1lwX(i1m6kqH2myP3Q8KElsL)WDzXBxmSy19SfGcEFF5im0WG6PtgCMwtsdJM)SWe2PxoOeyZa6ORGOx(aO)eKOUZdhqZcQ0cltibKJFG53u(1tRqfdMQgHmkeCaKNt3(MarsbBkG0CJWL(MiZzkCbzn7Gar1F4h2p))9Fp5jWQ5)3(5)NPFgCYB(I0DmaLTzwYxbSijFUUVNlZs3aDk7Hz5j)1Djq0aZl9efwJKu(Va7uFM7mA8wWFYTWY3f6q4lXzBbPTHE5uoiH0tcWs0zLFxLQVKVMC)Ucq6L1y0OklApSogCFhmjSll7BmtA8FfmLVaqaH6fD9H(XeH2mSzTQLfoi(5mSAW1JeeqnDmCzja5F4HKSzWKw2Y1PFrGwIHXht4eCUqVtytCm5sWZVs)vYNv(XErequiz7JS4cND)A2NHXGuKTnAdUe5XH6lhaTVC1dpwi5(xnEe4pcVVdzmmW3SzlwLa)8aLjQG5H8flZUlbIAkz22KVcJsLCnQoGZk9rnJ7KwXJjcge46geRClgldJS9hpC8P9hFga0Is)whm4umrmbp58(IveMZAMRl8UOr0yP1z(KOz7mHcXGDwFii6tz)a4IYGb(1(3aI(IZCDVJje76HhiHuKirNR8Xxey559Jo3f4DiQBINUoafcs(2cBaFYSWhMxyaFFZ7YxNwiJOR0fl9f36H2cRDPAQx)(eAHq1zXudqQDI1i)RaZCRwVwUYSuTXI4nXpOKwU(tQoBTwbgzfpJ91pUdKwKmSjUY5OSJiC2ren7i6VtyhpNY(d3ilBkz5Xe0p8dgJ49CVsTDChwzWJDiVJhCJHgnKb91J6XoGoyV8coQfooyetNlFVmI9xEPkoXK1qugFoMztP0urPeW0iBtKYP7kpiCLn67Zm4zMMmhCLZqO7DlmkQvfc)J7z5R71rg8ftdbMnvPTRghlK5CzjigLUROsA3kZkkHELfplAXQ)C5U68OHGTQRGWrZ819FfTYFgP9E3SF1xWzJZVxiEZBIr2ytI8g5r(ALchL1QlLgV)R7G4Ht2MSqzbFqV)EIxsPxr5IVuDI7cs6uCFzVfjgF0M4SN4RH9XFE9ypQPupMV4tV11jL8ZRiTaeZBv)2FLNJ1YVKpxBz2Ng8gETmPtssGQ(DDiYx6BM8L)RTR)2(5mNA2pFEC2mr3NVFE629ZVlLTdKCX7C7eNG7iufi4AnGVVxWbsBRIVIV41Na65ORM23GH(koJXK9m9U4QlKEFhO)mCzshMKPln)TptQ5SeloYD7w)eidwi2pIFlWvmD876)aeOegNXe35(mTCx230sUUto1onIL8DHFqpLKSfA)bWkhJ9FktC86PxmcqpAtNXfmue8zojzrD(hbm9xt2CD5eCqVticTtexLtSDbPYey6GdQp3nZhx9BOPdlUR2oyX5LNGTvxSVaMIS2XRPCJ9I(ZSRoB12YWbyMV2b4qws5gDYr7QGYQ(QGgLEej9qlGz3SEieUiw8F90XYEuVtPxpHoqkEuTkx9RZlyMG61t)0inDOIOOF5f7FHVbyCEL9Mj5xRMmF0zXFzgpD0ZE((I3WPKEalLd1yG2M3yldNS(U1XlkvohkNThBY4QlD2ZbwDZbcVaVPayhfizjRPJqVt0tSdhtz2rflb2T9XvBxKKbbkhNNZQ9cBQtWXBYyJ8ZITXKIU1sgtWIZ)guW0kZCv(jzx2gEJL81nmOOaSs0tHHQHhrJE)OZ0vQxLmDJkuOx9ctUML0wsxxArLgwkLSN08v0nDa6Wf0nDO9PBWJjxHToBHux1eK6t4F)xIZ4uBoZy7djzsJPt8heQvcI1lAuQGpm9nF6fe0n94A3YJjXzeYyoPupl9lQ84R3OmiD)z0N4loAXr0g3R1WVADZMkCWwtfG33e4ua7UbXxgGivp)oigrHuMz(MOtAoWwhy4Uqs1PkRYudKPEdMallxvY(Q2ITZyLQ3NtFkzM8N4BMPydR)2M7s5iZJPpNCiq450VKKb()VCxUalKFVab1CQBxwEHsGAHQo7NP3UzIgeQIyn8Yl2AtUuMEztTBQmkl0bEAKro81qlg8Y3XuzJIvvnZrQtQbTBl24ezHkKS7)gSGI10DR4l1HrIQElKvR5vv9afFoB8NWsY20OE1qL0CYkFiDbk6EkXX46gpSHt34xJjauaQ50rTZY(LtQdFBn4DgaUE6ZO3CFnwpQYjlW4UvHvE3XkoraHG2sZMPk09EeDquO8undH7tIewjNalPb9lT)OGTccGVxC7EqRZEizlyRCmySHsPc2Vk88XrFZapzQOM1Bx1h1dFlF)mZHQUgdnevBGNDhl7uInLHnUURovCu34xEn4G1l29QQ(BmlyMUGo7jNHPl8)RgJyiqXom1O6Hx4NqVMpX9AtM(0)x1u0qkxJCLLRs7tGYWxbIWhxjyDT8DcZvK3WajUA5w1I4MU)z1j2rt8D5j3pD0WYKH1rK4jnuluiICxdi5hdvtynlbvXY2e8CYiAXeQOmx6EoFyh5nwUYmlACz(zSkehzNvrCXQZjwZpd6bo9ddg8pnEeVEZ1SHzcIRhjZKXN51k16KYF)U1PPl8IOssuwpaCdyMyD0z9JuPI6WawvXZkGdLRbv5wr7u6y4AwBhv6d0MMczIkLYrcYyipgiPDXYzGLuvsxhGM2lnSo8dhmmQO2OHtoDjiEMj2YxSZMPYu4FWpjnyGM8ekGs4hENf9cySgJxlKCjHWe)9t4xmITEsk8Z36no8HoFQvcEnhBUQS2jI2f4)N8kGggE0bOrKH0dbAeMGJximUdW1pcY6vgxfA77o8Nw1FVJoPfPFwExeN9eyEeIO5UuwmrLl68okGBgqKO)27KCI5ZqPxxS9pTjNBrBxZQWgBwl(X2YlM0ThPZ2JoFNpyNhicl9D(FivRM84jqUjZA(KJSyUbpVyhxZBke67SO9HIYSCvWdicjsHM(LvMrKrgQj7RNrTUmCHaqdlFR0XKtjcHRmswVd8I0TfZ0dnfzMgVUeStSmmylUpMN1zbIxBUPdCdocp3SSexWYbGQNhEQegyQtQ29xxHVx0q8DqNHW(9CYtAE9S82SC8etScbRRz3xjZe)bllQOxgjOlhqkXGP6vAIU09asq3V)4ZrA68XdgCk6WkZN7GRM6ppNut(iWQwq5DAXylmQzUy16172SABCH6Sqj142c2JLodfh66gWGQdy1aRWzqIfsV94reAfoqUeb0cNpjYLGpZ2izBqWPit0GuHT3mv47G7fUbD7D2ZdLyDIdLw91hlFue9zq0lPeo2R2xtPGiPKAprTWf8OECoD(nXs)aCJ4Q7Be8VQxnBU5yEbHxZorvDH1P6OAHjgvkp09v3fCQVtoU1OYlm(FRVoa(Bm(FuG8)Xw8)XTN)JCkS5lHUS((Dcf5bCh6mT27e1boqCcYDJcI(u5YQvmQ54M6b4GQtuE9WcgBxqjtKc)ioDYbi6zXKrk0dp2A8ufhunPuKw)axda6jT4B5a7bx4junX4NuTjmY7iuBvRkS2WlreStydRy6r9CVhMp7bxgi24iEnEUmx)0NAEUtJST3JFd8j8VtM)7MPvRV)ADcPwOORfnsu0aLCVZpAYkOqgo9D7LlA7Lbq6bjpA768V8QPAbX6mNtYnQo)C1ywPkvpMP7yGzDWBH4EASYELRGHv5wwx1wArSYcg2ETPELIqw1qs0spiw99XTQwCq76GE1sW9DoIgSTbxwB)oAMjk(htfhni1VSmCCIRLpnTjgzUv7C6PBN0tr84CIGU4QPt4K31tVK7CIz7G6WYghZULIiTm9DTwWqzqEo5E1yK2HMHvRyxWzdHjQNq4bw1mnMJf9AGiqTYOxRRmHaziovEmHJVBOsLAcduX8Ghvzc3oFPOl1uf5tRbxiZATI8RFMOnG3uFjx90LJEJ6dSdURFKOEJJ7KrbIo(YtWjngGnwYVY3CmJlbgzxU6(vfmn1(xSf(YaZvvb)DlDoDxcJ7uLmxtpywgFbMpdbCCFm6eEf1Jcg7AAnVUJ7J5azUywNnOCoZpxWOIBW35PRgJd1Gkh)gfgdBuqVybWraSZ2aEpTN1mlQvd2Zz1E9eAoe6Fy50rUilfertGSvtEHOXYs2XnnO9BdC93wNVeVm8t2za10xkhq8Z36rfnutylst3OjDHLUvCFa7HKCa6XZ5nziyeZB6r8CF6H3cU70SXQNzoUz)uf7231SNhPlkUmEQEitOMpKMlK4BRg8I8na19jn6jz8NjtIu1jIVjRVTDM)cN7)YP(UamdCL)3VGuvloBCmQotqeHRAgifLR11LJh(fHIt4LdUA6hgOcW0tOPHiyPcZSPHagIpJnjiqp4AibweCkt8lTt3pxpMqLfc(m1w3KVwGxi(d3sUf6vreriRAtYIkwBa2J2IAJiRQfMWw2RIwPPsyi5q1UODAhz2a)hoa8NOj1vwZBdQZhogak6k6ORUYnMNAwt1ICuCqRt6A5C84nRHOPPUEN4unPnwmSgpbSo(C(evWNzR(wT7j4ZSRcb)VviJddiuVZh1bLJ3Tucx(b5DmH)72xsjuOxTxsjThB53gjgJp5bOSQT6VJHo4RmOQbHktev9GmOgnQaxAuEsq8XJvNwKLqqzcN84A8lV9eP5543H)eVVpgfHGlOiKJktMwjw7)yiRFXCrGPH)ie4LQXfTnIpZKZBM6YxzSKcj53KsVTXqZ0o(6lAAF9r)NGvyNZYM5UhEuLuk2Jzl7oLM9y2wWEax)DFjlD7d)U9ZLK2(5Pl3ppzd)U2H9mDXRyLC2J0vo)llggIK1HRigtkOBGMvIIBI0dHImHskk92iDt38nocyMeruOyF(4RxJe7uQ)PxFLs1WD8y7XtNTY1nENXY5n1ePzUV92B9Dl42Byo1a9v88vpok62BepTD53Ed)9sEfSUkt(Om)JcdM)4(5zaKxvUClfO85X7ks3WshjSKd4SWKjSQ7)y1wOj2Ji9FmDlmw8M)rsR7)y5BVhDhKh3rOJ9h)1b8NhBeSCzEZqWX4iO(veGfQP3KlsHc10Ntk3XDHkTF8qUPcKJL8glqIwTfwVNbR64hih(vl2cspO4oxGpg6rQAbC9MOG6NiGQXra3gUgnsoB(9GPm(4WvgFjoy1sKNfu1AHeOtoga9dhdG(XJdxLqyRD46pDeaA0OJbqjuR3sUAeHyL5gNAbyZgjbnHWL7EPzbE3oqoeeIAD5qqj2HS3s2ZQEU2ocDyS34iRHWUzsWtiNBTnGwq3Q1Mc8oc3VGy5uhojtneDff4ymJ(0NOgcrxkW7ZXf(1dz3Z)IdGr7sy49Hb9k46ORK(0M4dWK87Ug(1dz3Z7IVjsk(D3c9k4s4WJ4yUyBwQ8xjxSCm8E6ckVN6wT4xCCC9HcSDGr6ljymTeJ)od2wjBCCakHZp2LlKfKTBUPGVD48Xr69sQOepuWINeIY0Y8JnkteeX)16jjummRApK6eS0ABJSqsRwjNCokWgL(n2PYMXbiWYo0dqIrO1scLqNA1A3A9Hyu6eF8FfGDh58nHsToM3tmkDenCCdoKkxBTYyYyI8v0oGECSqrLAP2cwI4IpyWIQwDrYsrY8BVcvTIa0EYrR8ajixkx(eB6KnLk3lQMPu4aHgLsGQD9bJEfvWAyZdQZhElNjuHK9yC(mwbCW2Qmf2vfoMvZ(TMzau(EVfdtLRk(gbGT6s3c8wG1BIZlsY8I1vDPBbElWAOTC2Esud)2SBD)G0ckG)s55d3LDOlbClWx2oX5dDfT3HGLczD0kMjtvK313on3aG6DjiAx6wG3cSMAjiAx6wG3cS23spYU19dslOa8LHiDOlbClWx0fIUT3HGLczp2HxW90yz661PFbAN5krgRoRy1E1(5asTOS8g41QvzvjSFoREj3p)UDfY(TnL7MYUTg9EXcwNxexeFxCEYVh8Rz(5GdkapWte8DxbPCWUb7fQTkNOOuDCwZixIOPooKBRcNIiXsTcMhJS3tgGABcx5OauQT()G2jeQT8Vts6cfW7OCkqTF2TmXIcGteyDNaCQ9cULRFPaBR0xDCXyILYDsHekgcIjYozi8TnbhGvSJtTIrK0KJBENBn0jStkVHiAgJLqru3Sy(Oa79)8FMt5mqo(st)Uy01T3aK7JPz3EZnR28hV9g(VF7VE7nI65f(N)Yy2Fx(H3EJS4WV9gXyD7)6Tf3(lrS(ODgEyFLwpUH5Qg42y8T3CcWwrozp7N3diT6wYuHh2hGigsCHoIAwWRwO7L6906qaz11jguVi5DM9PaAixXP0O60Nb8iPqdRf1zo7FTEh8)1xoLqvGU7NFgmzQynyLP7(5NcRF2pFa))EpmrpAeFOMTLt5sqPplWgu0hZS9ZVE)8r6ZgEQsv1mFJO5ijnfXXCXzHeqEDKEj2lUJAs2A8G4d8mEIbOEORXF8OxKZBQeH59q(2hOKTo6ii1nsdBL0lVOHGwTlQiM9ZVA)C1PEGKzp57lT4(GRzrmepMsbsnFOXIQJWOd7x3agO)yJzurdNWf)5pev8Ld9zbcV0)DbcS88puhPwQjiim3vI3xO(Cj)aXsqlu5Ch5DIcdhbo3NAmN7IrMkqKRvrRwFEp89YUDaSQ(DXYlb5)tnM8)utr3oA1Z4rngvJiKWjrKJLWDnJkiSYPqm73(PWpkwfRq6k72VnO86nIZxvhidcZyFnIarhigJ)C2XXcmxa4pAc44HCWZTEsXu4yFnwVXLdbFsCcNXxQWPQBYNLl6UiUuf4D4sXmN8LA473ygUlne3(hCooMpnbWXRUvfv8AZR1hq0AQofIpdjyzJWmx5MsoocJ54sJqy(9BX3BSMWbLgG1IBxfDrBBC)mnuh5LkJlwDKOpmVKcG(YTFW0(hRCdELlM7vbWY1UPxcEra6C0biLG5suZq5MT4TJW7im)JAiEFKw(2vuyZZVHrauQnLt5tzuZDOqKUeD5D9lGppJxdwr5j8(OMNac8m8OJ18L9ejcQ8cqOg(4bAG2(sHsHYC)bxqFL4XdTt6ul6LCfpQI(AP35uE8AdKbrc)hZ7ptbAk)d5F3vSs1Cu5qFIP2tT1qLTJ1cxRqzZyQeUuMbnx99wxbKUpyzi06fDcTo47c5AfOK58Pi3S2seAVhhCjWd0JlTfyophlkPr5LtlhX1VTALIHU3siL9Dm9Qz3xMrGRpTCounTcZxMlthe4qwoPpMxMceD(CE7LZbNsGKYJDxPmXuTErSMZNSlkCdeOUHNHUFFCjHd0lwNhuiDRGhnUTL2wdg(1bXA0531d2AHjcVM(SHW53hOx1ypstVPy5KkBBftNaQnNTFGEwJ9IBPy7EswQUb3AZ9AFU(9Zv5gLQwiWS3H6qONScZzghOp72VVyM(nwHt1ZxOFElpigIdhGOwv47ifHJ)E8iSVcrOfYk3dUs7sCciQjeabpwv6)Ce32FEJDPv5tHO8cLpSHkwoDhu6hoi3j0TYsdGtQbg9QtrBPtwJmSPxZhacsA1sTZHJxhuomNinMJwbBAFu15yvD4HYXnPaMaGJb5U1SvrQ)MnlBhJL)z5O6MLJ(T0SmYvGG3z5XyZYUxibTAwoYAwoIplBhwQMgmPoKlRaLDnpWGGDmKgYj08nX0GV95tovwP2ZQEc1R3aKKpWBM85gT0TKlcsGS)bgf1a9z9tA4iWXrSbqMNz1CTjV6qxx5FA2oqnJP5aS3lrqfXyBe3FhQSaPWsRs1HHK2XqGRZI4ztvmnOcsKiOrsijO(wsOSjo)9q4kQ9YCe2HTl(OfYJwaECAEKKrunVINWlb)OA1jEWDLABjdfFGLmUVi7TjzT(YPxBFRL9Z(QwwNty8oSY13fnQSG2KPAq9UqXhdBxwLJH17)zyzhja7u9D7I5Z6qj)R2mVnWKOebUbu0L2(HgcI7lTo3u(QVYRLpsUJgUymaCmY2bZa4XHXjjdNtl3K1fYxzYp6JL2UbeS5YAIKrz2ovfaLfGRhxPN4EZ08QzAWlXxtxSDlcx21wWKOxMIMoYcvClJkZu(AOOZ)yDI2)J(MZNkfK56VWpCsYmBDMfcN25KM(tgy6tznj818BptVyg5WPmRVqFNmYuFNSkAz0nTb5a1Dx3UzqS)GsKSVLrcuhWmuTBTTNvEgvJlCNG7MiFAudvq2YRlkxBmrJRYtITHJ92FNYgy1hmEIUVwA2CReo4Zj0(FyWQOQ)CxDqwYSAjGnOysoJD1py6JyyZz91P(pnQ1UOsWQfAsnsrH(HqI9onHX2n4kCopTRo4oU3RfY)bTs)ACJeAeHMAqojy79cnjWz7VDOawH6WiaBxJqialvawU56UVIgl0kTSWgQj0(S0ndL4hzdfD2UiLS6qERu6ycD6yOKo6qSqmdpHoBb910zCvPgwLI5gf17BU4QjS)oPo)o(7rErTjEdfpLpGCHINy4Iom0NrKNSg2mcThr6pewsxaiMwdlfcHRPI2WudGNM6OpP7tm(bl6xM8tMooR)cnO3Xc(b2sEN9D7bDuKgRVPbfwVPwmKP5N0hdq680AWJc33ApvntOlV7aMYklrVO6ewtjoCCL9FKCLap3HMbc5(oMO3Q9tbIwSFgVfyClPhqEm(Er4xXOBJy2KN5VYt0MiXciYsw5vWxYkQtDirLPqREQ2QlAGxRV0gFdie4(HefCxI8MAG8Uw5ntmjyrgeXBSwgN)adiPE6rS24nRnJgeXhsBG6GjFCtH0gXQLBIMmrdHACdN02562HSIklmYnRuHJ9Pjw(HMzz00Ezua5z6apLW6PO2YinkalfCn75hm6PMiLz3(OX4A6ZVJD)QeTrX4qNlPkAgv68z5hKIP7vrADXY2x3uvB2PbgUrV1hE2DbFsxpN6YLnfe8jYu6hM8yBHz7SrEaCLY1K(sRp(ChOhHhkvTG4ztLR81aApEhzhwrjD57rCRu(sJ0cHUW9lJGKhGUpF(jnuOuAt20njRxpn)liEZtG4MEQlfb)nbbXF2f97(WB)Lw0Xq63u9HghtdCa5qhc18I3OQBQmefJQW2aw9b1eSJ7M5zR0ADUOOl8RxWyZH6DaXmCHMN3w5iuIbKE5rV62gToXe4gxylhFuwtuKEjCG1szDXh1JSMrqS(VinDJJ3F(Vkz8MrQqR8MkFNikjvDTO11ZEKXiXip54zuBTSgSNHBqP16OrZMFsRqiuoebfjkgTWizUuT)YSUXKUhIMEhJQF5v)MuzWL5jsjLFQ5ow7dfP3tiSqEvvJhwcEIkfr9eAUxnQoxef22YF9kuaLoSJqDc4C7uqK)hFBf8N9UNA1gFVHt(9rNFptQJNjf8bt6tUJ90lbDN(Ts8IZnqbQo0wUz4nF3Ao8TdNmZbfix0fvelok3R25qTHZkZOJV0nRdQvDM2XgByZJinloxMbnkvRHin2Z0RD0ZrTHyuvQuDUjccGZ2VfBtVHSK6O(pOAgJUu077MNyptI0gsq2fZdvUxZezDzdSR5yeQgPno1vKnzZ67N5BdgJMlZo3jb(LZRiMgqjuY1MQ4R2Gtu8mGAZOvLbs1sFNRCGaw63LlrDU)amLvdBZTDoV)gMbjzksUwFSzTwS4ajjfAm8jwgwqV)q9gBuOYrGniXBm0T23BPlwLNT7zBJun6AlTA1aBHWtj6LJrbyqxT8uDGBMyWx0)uSqWz7NEwc5oQl3hDKl9JkY(MryrkZGm)szedUU7up6i4ghMM)m6AUO2zHY7jaSRja)OwuZrTLwVXswUQ7lT0vNW5tqx3xsfyhXD)uXfVsubjj08BSYdvgX8TPsUIXF4wxt3NQTP(Cv(KuXqlwl))3Exz9eh5aH)TWlOMGweZWquqIWFI99D2o70CicGupnj5P8BFD7ZYLRQSDphzqGsEkJt7YLlxUo)CsADE4zL77kwJnkIi1a8MpOecUVR)LLd9DAe7yTIi6vdQ2wJWeStbpx3kZYTRnkbd9y1KQeiHoT7R6ScgedIUu2RrDBnB34tEUWG01fEen5qBloLSBe98z4uzV8KtNR8eb6pu4Z2I3PsXFFF)JNax2OUDLtVEHl)5zw(u)(((hjx(Zdl)Om732RmrsDO4f1H4e)I598mOcO97RukZV)HLMkkZZsOusOpEuuOrPI1GVfdJQgrXWypqMb0AWjErdSss3dThdtSkoelpJ4c5GT8m(mADYxEgXvYHy5B22lORohmAOSg)dWrSohPfURkh326)t4cdIqChwDeBn1J8EteXBTu6YQGdXTa5or0OZrU7iuqClSWMWTCUi(BgbWOECkbMhHvIRE51Xvt)tl7(LIw6wtPRSIQrGZRLc2wcKI18C)I7hHanGOwtGVT4XidRUjksfCFaZw5V)3Z5CAPcaOmPQ2lLNkxlcXrOiTkWNisrLwW8)n0tmgUQNLIxSHKviBG7cyInsBQ(zN7cG54))Zg3Iuw6SC1dD(FMfy7Zy4D6zCntVTxBrZyEgm8uLDoT)3JqwL(qVdGbEU7xksgugEuEEL3Dx1QF2zZ0350O9MwrpJ3YBEOiDja6tX3uLCwXbqA2J)XchPkbYQLWoaqq9shZDiimun9NBXP(OS9ImRnptSE8X)cnbWhXOYNFGiEj53n)MINv8xY5Qly)SvYEcOG)fB46Kkej1TinuE9yx7FEk3gLhn9xwyVhWGXeo73jdWesQM6R4mOUs27aGds)vugIO8AYPuZOJDv7tT3fdADFj5)is9HLY8CBxQyJy1xcoS7DfraVWsWoFzM8uXlS3nmzs46YKD8IY8WMWW4nlXtL2cEFqmP4mZY4uWrBzM(kJSj(MiYG9ss6WKXmstL1m1ZbjElP3hes38rIYqnYw0ymXazf0jAIhsp(cUyOQe86OGe))kPGSW)CqTEfMvgcuff8V53yKEMI4QwT42BxiDYfrObfcc7Ny9DexJDJtJ3HP1FNszpOJLsaDCcPoVjFTMg4OYvNPesUwDnxQ)7XVZ3ktJ2BsriWQdgDhaTEnPSZ4o5VQl6d8uB)Ja1I5z9hM89ePlbRoasA5gksG)GDTFcWQU3S(a)grcdYIfDeZzbd8ES8NVoyzaNkA7Dy68)wsDAB0ggBnzeWwmfyA4BVS27tZeJswCbcabNYKxtJkSWuAR2wxYj7ghSB(WdaydxVMa0FR0YAWbf(UStU20ENUzSPmCEB3lPJa)GBNYTBq2H9B9BkQpWeeC(V963FuP1zWw4yAUpFbK3SNWLgaG8yw5sMw1omU(vEP21TQut5TschY76f7sTxi5OGqctWy4IueW4)iwHwCGdKKlc(c2Xckx)HCsvYjmy9u67xs0w5r57vHXvMaqC4jt73raZp0IoeVlxjl)4V4ePSJHNzidkq2G(6pyXQz2H6S(rwIBF34vChoYHrXKmnWEzoIws7Wzgm(FLQn4AiluJsU5QHizR9T)CPoxRM3tBZm9gpFRaDxyZGsA)pHhUf8MbR1ucplityN(4iWWeiAcbwGffhA(nMcC38XIpbw9dV(89pm2okDRw2UE9yJseY)SBn8d19nDkLpkbPbLuJ5bsseAURI2j)juVJrZBHf9yMEQSSZ8FCkDdoLgs8HEdjVZkCa4Ag(ZHFqzMpjJqalFmjZCZFJEQoLZeayoPtBrWsowGUMfvqVdephjef6G0dfGNWpoQt)z0FEvX6p3KjFxR6u4XiztiBA9IjVZiiNrYArP34S0tRukUZQPx)T(zBVMJUE0YX766HweEjZcH)k)K02(1ia6dfZQf837JdsWO72IXeyrmYa4ixWxFW9kwqrnOXfJbIAyGcncm8hs1hblI6xbXkR)w4t3svyKiSTtHO)OBAdLorzpXEcpxvSdR03IkPS9j80WLX)PgGtcNcM9BLE7Q1sMw30P9OOOMkE8NPe6x4(WJl4Co31KhgBnxXWEHkshfv8d9As(eehFrlWmphwS(5Ld46o82CeVlTWh7MdqqmEg0KJDbFZlu)srqNzSzlPUpUvEcBYX(UXhqU3wmoN(uz4HgoG5NH7DSwAFc4DjO(tRxBpSUpoP6TaL3A3D2(xu0OQK7qBj1vfyeHPPaYyyZmCBnk0UFcOt10vwFjLhOEd9MDrXgcbsX8gJX2zLVHYjB7a)dYq0UjThCvhLy9aiMzY9cF5AHx0bb7iytRkuUkuYPcyFpHNfbVWfJqo8ymHliXoni1TVXopWIz7FH8ds1uWxL6xdvtbJ0LidA7M)8p)p]] )
