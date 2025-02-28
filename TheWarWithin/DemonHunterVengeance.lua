-- DemonHunterVengeance.lua
-- January 2025

-- TODO: Support soul_fragments.total, .inactive

if UnitClassBase( "player" ) ~= "DEMONHUNTER" then return end

local addon, ns = ...
local Hekili = _G[ addon ]
local class, state = Hekili.Class, Hekili.State

local floor = math.floor
local strformat = string.format
local CanTriggerDemonsurge = IsSpellOverlayed

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

local sigils = setmetatable( {}, {
    __index = function( t, k )
        t[ k ] = 0
        return t[ k ]
    end
} )

spec:RegisterStateFunction( "create_sigil", function( sigil )
    sigils[ sigil ] = query_time + activation_time

    if sigil ~= "spite" then
        local effect = "sigil_of_" .. sigil
        applyDebuff( "target", effect )
        debuff[ effect ].applied = debuff[ effect ].applied + 1
        debuff[ effect ].expires = debuff[ effect ].expires + 1
    end
end )

spec:RegisterStateExpr( "soul_fragments", function ()
    return buff.soul_fragments.stack
end )

--[[spec:RegisterStateExpr( "last_metamorphosis", function ()
    return action.metamorphosis.lastCast
end )--]]

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
    -- last_metamorphosis = nil
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

    if IsSpellKnownOrOverridesKnown( 442294 ) then applyBuff( "reavers_glaive" ) end

    -- SpellOverlay API call is 1:1 with "can trigger a demonsurge damage proc", this grounds these fake buffs in the gamestate
    -- demonsurge_hardcast differentiates whether only the basic 2 abilities are transformed, or all 5
    if talent.demonsurge.enabled and buff.metamorphosis.up then

        local metaRemains = buff.metamorphosis.remains

        if CanTriggerDemonsurge( 452436 ) then applyBuff( "demonsurge_soul_sunder", metaRemains ) end
        if CanTriggerDemonsurge( 452437 ) then applyBuff( "demonsurge_spirit_burst", metaRemains ) end

        if talent.demonic_intensity.enabled then

            local metaApplied = ( buff.metamorphosis.applied - 0.005 ) -- fudge-factor because GetTime has ms precision
            if action.metamorphosis.lastCast >= metaApplied or action.fel_desolation.lastCast >= metaApplied then
                applyBuff( "demonsurge_hardcast", metaRemains )
            end


            if CanTriggerDemonsurge( 452486 ) then applyBuff( "demonsurge_fel_desolation", metaRemains ) end
            if CanTriggerDemonsurge( 452487 ) then applyBuff( "demonsurge_consuming_fire", metaRemains ) end
            if CanTriggerDemonsurge( 452490 ) then applyBuff( "demonsurge_sigil_of_doom", metaRemains ) end
            -- setCooldown( "fel_devastation", max( cooldown.fel_devastation.remains, cooldown.fel_desolation.remains, buff.metamorphosis.remains ) ) -- To support cooldown.eye_beam.up checks in SimC priority.

        end
        if Hekili.ActiveDebug then
            Hekili:Debug( "Demon Surge status:\n" ..
                " - Hardcast " .. ( buff.demonsurge_hardcast.up and "ACTIVE" or "INACTIVE" ) .. "\n" ..
                " - Demonic " .. ( buff.demonsurge_demonic.up and "ACTIVE" or "INACTIVE" ) .. "\n" ..
                " - Consuming Fire " .. ( buff.demonsurge_consuming_fire.up and "ACTIVE" or "INACTIVE" ) .. "\n" ..
                " - Fel Desolation " .. ( buff.demonsurge_fel_desolation.up and "ACTIVE" or "INACTIVE" ) .. "\n" ..
                " - Sigil of Doom " .. ( buff.demonsurge_sigil_of_doom.up and "ACTIVE" or "INACTIVE" ) .. "\n" ..
                " - Soul Sunder " .. ( buff.demonsurge_soul_sunder.up and "ACTIVE" or "INACTIVE" ) .. "\n" ..
                " - Spirit Burst " .. ( buff.demonsurge_spirit_burst.up and "ACTIVE" or "INACTIVE" )
            )
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

local sigilList = { "sigil_of_Flame", "sigil_of_misery", "sigil_of_spite", "sigil_of_silence", "sigil_of_chains", "sigil_of_doom" }

local TriggerDemonic = setfenv( function()

    local demonicExtension = 7

    if buff.metamorphosis.up then
        buff.metamorphosis.expires = buff.metamorphosis.expires + demonicExtension
        -- Fel-Scarred Demonsurge stuff
        if talent.demonsurge.enabled then
            local metaExpires = buff.metamorphosis.expires
            if buff.demonsurge_spirit_burst.up then buff.demonsurge_spirit_burst.expires = metaExpires end
            if buff.demonsurge_soul_sunder.up then buff.demonsurge_soul_sunder.expires = metaExpires end
            if talent.demonic_intensity.enabled and buff.demonsurge_hardcast.up then
                buff.demonsurge_hardcast.expires = metaExpires
                if buff.demonsurge_fel_desolation.up then buff.demonsurge_fel_desolation.expires = metaExpires end
                if buff.demonsurge_consuming_fire.up then buff.demonsurge_consuming_fire.expires = metaExpires end
                if buff.demonsurge_sigil_of_doom.up then buff.demonsurge_sigil_of_doom.expires = metaExpires end
            end
        end
    else
        applyBuff( "metamorphosis", demonicExtension )
        if talent.inner_demon.enabled then applyBuff( "inner_demon" ) end
        stat.haste = stat.haste + 10
        -- Fel-Scarred
        if talent.demonsurge.enabled then
            local metaRemains = buff.metamorphosis.remains
            applyBuff( "demonsurge_spirit_burst", metaRemains )
            applyBuff( "demonsurge_soul_sunder", metaRemains )
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

        -- sigil_placed = function() return sigil_placed end,

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

                applyBuff( "demonsurge_soul_sunder", metaRemains )
                applyBuff( "demonsurge_spirit_burst", metaRemains )

                if talent.violent_transformation.enabled then
                    setCooldown( "sigil_of_flame", 0 )
                    setCooldown( "fel_devastation", 0 )
                    if talent.demonic_intensity.enabled then
                        setCooldown( "sigil_of_doom", 0 )
                        setCooldown( "fel_desolation", 0 )
                    end
                end

                if talent.demonic_intensity.enabled then
                    applyBuff( "demonsurge_hardcast", metaRemains )
                    applyBuff( "demonsurge_consuming_fire", metaRemains )
                    applyBuff( "demonsurge_fel_desolation", metaRemains )
                    applyBuff( "demonsurge_sigil_of_doom", metaRemains )
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
                if talent.thrill_of_the_fight.enabled and buff.glaive_flurry.down then applyBuff( "thrill_of_the_fight" ) end
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
        cooldown = function() return talent.illuminated_sigils.enabled and 25 or 30 end,
        charges = function () return talent.illuminated_sigils.enabled and 2 or 1 end,
        recharge = function() return talent.illuminated_sigils.enabled and 25 or 30 end,
        gcd = "spell",
        icd = function() return 0.25 + ( talent.quickened_sigils.enabled and 1 or 2 ) end,
        school = "physical",

        spend = -30,
        spendType = "fury",

        startsCombat = false,
        texture = 1344652,
        nobuff = "demonsurge_hardcast",

        readyTime = function ()
            return sigils.flame - query_time
        end,

        sigil_placed = function() return sigil_placed end,

        handler = function ()
            create_sigil( "flame" )
            if talent.flames_of_fury.enabled then gain( talent.flames_of_fury.rank * active_enemies, "fury" ) end
            if talent.student_of_suffering.enabled then applyBuff( "student_of_suffering" ) end
            if talent.frailty.enabled then
                applyDebuff( "target", "frailty" )
                active_dot.frailty = active_enemies
                if talent.cycle_of_binding.enabled then
                    for _, sigil in ipairs( sigilList ) do
                        reduceCooldown( sigil, 5 )
                    end
                end

            end
        end,

        bind = "sigil_of_doom",
        copy = { 204596, 389810 }
    },

    sigil_of_doom = {
        id = 452490,
        known = 204596,
        cast = 0,
        cooldown = function() return talent.illuminated_sigils.enabled and 25 or 30 end,
        charges = function () return talent.illuminated_sigils.enabled and 2 or 1 end,
        recharge = function() return talent.illuminated_sigils.enabled and 25 or 30 end,
        gcd = "spell",
        icd = function() return 0.25 + ( talent.quickened_sigils.enabled and 1 or 2 ) end,
        school = "physical",

        spend = -30,
        spendType = "fury",

        startsCombat = false,
        texture = 1121022,
        talent = "demonic_intensity",
        buff = "demonsurge_hardcast",

        readyTime = function ()
            return sigils.flame - query_time
        end,

        sigil_placed = function() return sigil_placed end,

        handler = function ()
            if buff.demonsurge_sigil_of_doom.up then
                removeBuff( "demonsurge_sigil_of_doom" )
                if talent.demonic_intensity.enabled then addStack( "demonsurge" ) end
            end
            spec.abilities.sigil_of_flame.handler()
        end,

        bind = "sigil_of_flame"
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

    -- Place a demonic sigil at the target location that activates after $d.; Detonates to deal $389860s1 Chaos damage and shatter up to $s3 Lesser Soul Fragments from enemies affected by the sigil. Deals reduced damage beyond $s1 targets.
    sigil_of_spite = {
        id = 390163,
        cast = 0.0,
        cooldown = 60,
        gcd = "spell",

        talent = "sigil_of_spite",
        startsCombat = false,

        handler = function()
            create_sigil( "spite" )
            addStack( "soul_fragments", nil, 3 )
        end,
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
                if talent.thrill_of_the_fight.enabled and buff.rending_strike.down then applyBuff( "thrill_of_the_fight" ) end
            end

            if talent.feast_of_souls.enabled then applyBuff( "feast_of_souls" ) end
            if talent.soulcrush.enabled then applyDebuff( "target", "frailty" ) end
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

            applyDebuff( "target", "frailty" )
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



spec:RegisterPack( "Vengeance", 20250122, [[Hekili:S3ZAVnoos(BjyW5XoPJBBL4UZmxCwC3E4aUbhMpSzXTFZ2k2YjcX2kRKC)aiW)2psksk(Okskl5oz3zbwSthtQIvvSy9IfjNnE2FD29RIltM97rJIMmACu0WXrJU56pn7(YV)sYS7FjE5ZXps(h7I3s()))s29ys8ULSw((MS4vuiuKTpN(tpvw(sXV(Xp(yA5t7Fy4YSTFSiD7(nXLPz7wMhVUK(3l)4S7FyF6MY)NDZEqz4VE8OOFHaSxswo73NCZyc8sxTkPQtjflNDpTtxoE0Lr)YVEyX4XdhnCYHF7WVj)5XKF((0T)5dl2)cfSF4WIuY4MexKCyXQK1j7ks)sYUKIIdlIpS4H0s5Np6xUmkY4ZvBCmTX)ss62x2KSnzx5Hf)xjBZ2vSp)r9(nYbqgrX7)6xtIF(WIVeNNg)WgcIr5SeeQmJGrK)CjbQPfLSXyDw(Hf)33t6DXWdl(p(l)7KFk9Bhw81ycQVytw2lAGFmHGP)3BqXHpFz0vuC4jYa93Ija)VrMQs3rMnZZwNUHmhgVKozvm8L8eY83dXLxm9JcC9duuDAr6Uh3KmVmMq6LF4lXB2t(Txs2SH)tfdlEjnpTC(dKVF64d)waGCBm5ZJZs8bU7Mg1dTXBNojKb7H0hdBO(uiqRmpD3ZjLZhp)H9RxxWHk)xhoE4tXfZ3xKWA91x7R3a9hhg)y6M0YV)6RaTTnMijKd32xsYliRSq)2NOFlyllj04GMqCrGexegXf5G4ICqCrEiUiuIlkiIloFz8oIKBwEoD5fyFksjy88S1ZxVHWb(q66PpLKNnVmpjzy8Mv5XlFkDorLcbbjuCDBRt2uSmMa4v9kJ3qa)WIY9eTxLuyvqqSecQ(icILUDBwLwY5X7ZJPRx5DJ04Q0I89VuQ9tuDpZjcRpNu8b6eq261ZFC5QPJPi8zm(GAFgU)LE9lJ39mbfimT0Tj3ozGka1N23TFl5dJ)6o6pnNODFtXhYEzAEsbzbprpA8(nLth14VFB834sqm0uWMinpNX1l6TmlBZQSVUBO(Sab9BXGfPmyRjZFL7ZtQhjXVmC5tuDafZz)azKI3C30X9Q4LBtkJ3ML)YtzevZTdBUQnyt3GmXRwHnpqKGjc296xpru)RdZt2gNUR4o4wxreCPOXLxnqt0kDhr0NG)ZlilwForxCvTJ57js)S)A(gIbWksio)d0VBzjx0gAbNxGq0CPceyyuVYmo32a1lpmV8jYcGNiuoLhswjKU(deB1RsPFKCgnLOqBozPxArsVvzIF4H84DRgwMUKUaKZ77lgHHAgupFYGluAsyyu)N5MWo)6bvaBoHo6ki6Kpq0FsKOEWbhqXcQWclviHih)i1VPI7MwJkAmvfczui4arEoB37cejJytHin3iCPVoYCHexawZoO9O6QS9uWLVDoFrmeYwlnu39KVrq9KIlP2mgC3io27PJHJxKvLp(ys(8mIgK1BY(khT4dZOARzpUjM46oXCW(88VtnNv9Ze74RiY6CDlSFNyx9l0PdIdpvMPlMx9XorK8hNNS7jAKnZxUH(zqmijzBI2epbC4h51diTVo9XNkfC)BhpIygM13HuggXLK5Rsti)8aPM5G5HmzK5pKqcwiz(UKVrgfcdj5VVpHqnGI(xu5AwoZ3KYNs4miIhlKO9AXyPzBP)4HJpV)4liaTSYDTbdohseJZtUSF14AmRnm5Bjl3xsyre(0f8Uintc1yLrj2KOE7uHc(GDrFsSJNt)bIL5bdCR0Rbe9vxy7vdvi22XgIeszIaDU1fFHJLx2p6sBG3HOUoEAB3peK89f2qCfXaFOoFq47B)qXMSsrGmvEwOU4wnIoYAxSM61VpIwiqDwu1aOANOnY(kI290nBeRmRuBSkEB8JsPL7Ur2zJ1kKrwYZOF9t7jslcg2eB5Cq2rem7icNDe9pjSJxYO)HDavnLSCyc6N(jTrCjZzmt)vjRmyUmx0XdU2qd6PS66rvxMbhSxFfg1chh0cLXMVxfO6RVwhEuYgIZ1FjMAtPYurLeW0ittKIP7ApiSLn67Ym4f6MmhCR1qO6uhzuKRk4Uf2ZWfV7I04l6gc0BQwBNhhlePAynrmkBFzT0UrcfKc9slEg0Ir)zYD(8ObHTQQGWsZ8D9FdTYFbQ9E7K(0NZzJlwYfVznrjBOjrwJSa(mYCH0A11cJ3)99KWat2LSsAbFqV)zIxIPxr6IVqDI9cs8m7EDVvjAF0248NzRHDXFE7ypYPuhMVytV(6Ku(5nKwieZ7v)2FJNJvsRIlxBP2Ng8oETmQtscGk)DviAV0h2BM4858pJPyn0aHnvrxtxoTPJZJVDAFngYBihNk7O7DWTxj8Eoq)ryYuwmjDxs(hFMuZzjgCKh2V5zI4xjpn6)rGRO742D)jsGoqCgDCVAP5(8VRKtyRCIDEenNXC)yEojzhP9hjwPOS)ZPIJ3n9Qre0d30xCjffj(8MKSYN)neM(BjB2xo9g07mKqZ4XfzfBwqAljmDIdMV0nZh3(hOPddURYgVW4LNbTdn0VGmfzSrntzgR59NAxCE6Uk35l6rMti4qEs1(ZXq76GQQ)QGgLEijTqjGx7SwWfUqw8F30XIE43PY7MGhielQuPR6(8ILkOE30BgPOdLhf8RVA(lS9THXRm3de3A1e5top(RZzPtE(lllFhNs5b0ug4XaTjVXugozZdBIxvPCouoBp6KXTxBTNb0k3Ii8s4nLe2rjqwUA6i07m1eZWWuQDu(sG97EkD3QKCsGUXff0sgWK64C8Mm2a)mF33WOBLKPeS48FafmnYSwTFsMvBGZybFBdJjkaRe9KyOC4b0O3p6cvL61jdxBJ175xyY2SKYsAFP1uyyPsYEsZxr30bOdxq30H2LUbhMC526mfsTvtGQpH99FnoNrTfuJTpMKlmMoXDqOgj4vTwhXc(q338PxHq34JRzlpLeNJiJzLs88SVkZdVAJI4ZDNrEKV4KfhrBCVwb)86Mnw4GTMkiEFJGtbS7eiFzaIu9C7GyegsPN5AKoP4aRpWWCHeRt1wLXgiD9gub2F6NoSq0x5wKDbTcZ(s2ZjZf)eBZi5B4833(qgdzEk7LKJbcVK91KCI))R3xWXcX3ZrqfN62NxukfOwjlp85QTRNObUQiAdV(QP2KRfPhwx7MmJWCDGNhPLiof0IcVI9uv2GyvDZmK6mpODBXgRilKHKT87Kfu0MEiLTuNmsy1lHOidVTUhG4ZfJVbkjBtJ65HkX5K1(qAduW9eIHX(gpOHt14xJjaqaQ40H3zz3Yj(W3wdERbGPN(c8nNxH1dQCYam2B1xT3D0AQJGqK2YYNlRp7EiDGxF3yntc3hfjmsobusd6xz)rcBjei(EXS7rAD(Jj7i2khtm2GPub6x5E(yPVzGJmv4z92T9b9W3W3p9COQQXqbrvg45pqZofFtvOJR9Qtjh1o(L3coOFXU3u1FJPbZ0f0zpXmmE9QF7yadbs2HUgvh8c3e6DSjU3AY0L()6MIgI5AKTSCDAFcug(wIi8PvcwvlFNWC55nmqIZl3YlIR7(NrNONOUpuKSC6OHvjdRJiXZAOwOqe5UJGKFounHEwckJLTj45Kr4IjyrzU2(4PqpPw0CLPx03I8ZyuinIolJ4IwNs0MFHOh48pnyW)24rS6fxXgMoiUBKitgFHvRtBsQ(9h2KLTYjIkirX(5ZmGPJ1rx0psMkQJdy1f)khoyUguNBfLdxIMRzTDuXphwkkKrQ0jljiTH8uGKMf7MgwIvjCDaAAU0W4WlC0WOMAJgo581eXZC(w(cDKcLMc)tUjPbduKNabuc7mNSQxaJ1y4AzKjjeM4VBc)Qr01tcHF2wVXGpPZNBKGx9XMPkRDIODb(FJtb0WWJoanI0KEqqJWeCCcHXDaU(zISETXvU2(Ud)Xv937KtArQhb1vX5ptmpsIO5HmAmrvl6Coke3mirI(hVdGiKpdvEDr3)0MCC7mDnRgBmzTWh7kNys3EseBp68d(8iEKiSW35)LuTCYJLa5MmR5soYG5g88IzCnVRqOFWI2hlktZvblGiGifA6xwBgrezOISVAg16YWfcanm8TsftohjeUQizDoWRY2voxn0uGzA46sWmXYKbB1YywwN5iU3Cth4gCeEUzPjUGMdazpp(ujmqxNK39xxIVx1q8DqNHWU9CYrAEDS8wVC84tSCbR7OxZgZ5)bnlQG3HgGlhakXGPQvAIQ09auq3V)4lbA6YXdgCo4WkYN7GBN6opNyt(aWYlOCoTOTfgEMls3Sz)20DXLYZYKqJBlypg6mKCO7AadYhW8aRWzq8fsV)4riAfosUec0cNpXZLGlZ2azBGZPqt0GqHTZmv46G3fUbDZD2ZbLyCIbfw9vhlxue(zi0jPeo2l3xtHGiQKApETWf8OEAoD9nXs)ayJ4Y7le4VQNNn3CmRGW9Stu13ZAYokxycrLIdnF9vyM87eJRhvEHX)B9X5)FW4)rbY)hBW)h3E(pWPOMTe6A)97mmYJWDWZ0AVZKh4a(ja3oki8tvlTwXWMJBQhGdQpr4(HfzSTbLirkSJ40zhHONbtgOqpCyRXrvCG1KurQ)b2da6jS4B4a7rx4jynr5NyTXnYBjuBuRk02GlreOtydTy6b9CVhKp7bxgiM4iCnEUUq9GNQFUtJmT3dFXXX9VtK)7MPvRV7ADcOwOWRfnuuudLSVZoAYkOqgo1D7LjA7KbG6bjlABF(xE7uLGyTMZr5g1NFopMvQt1JE6ogOxh8giUJgRTxzlyyuUL(Q2sdIvuWWMRnvRue0QgsGwQbXQUpU11Idyxh0Zlb336iAq3gCrT9BPzgP4F0vC0Gu)sZWXz2w(u0MOL5wLZPNQDshfXJ1jc6QBNoHrE3n9AMZj6Ttuhw14y6TmeQLPFO1cgidYXj3ZJrAlAMSAf6ckBizI6zaEGrntd5yrVgic4vg9ovLjiidYPYJkC8ddvQvtOHk6h8OAt4M5lfCPMSiFAn4czwRvKV)zI2aED9Lm1txp6DQpWw4U6rI6DoUJgfi44lobN4ya0yj(kxZXuUeXi760LPLun1UxSf(Ya9vvb)DRToDxCJ7yLmxtpywAFbKpdbCCF06eCf1dcgZAATW3X9rFG0xmRYgKoN5MlOvXnW780TJHHAqLJFJcJHokGxSaWia0zBaUNMZA6f1Qg75cVxVG6dH6hwnDuWZsbs0eaB1KtiQTSKECtdA)2iU(BQZxGxA(jBnGk6lfdi85B9KIgYjSvzzBvKUGs3kSpG9asoa(4z9ucemI5m9ioUp8GBb2DA6y1tph30FQMD76AYZH0fgxgovpOjuZfsZesCTvdor(gG6UKgDKm(lejrQ(eX3K13MoZFL19x5uxxGLbUY)hxqQYfNnogvRjiKWv1dKcZ1AF54HDrOyfE5GBN(PbYamDeAAicwYWmBAiGH4Zytcc0bUgsGfbNYe3s749Z2JjqzHGptT(M8vc8cWF4wYTaVkIqczvzsMxXAdGERrKBezDTWe2YEz0knvcdihQMfTt7iZg4)WrG)injVYAEFqDUWXaqrBrhv1v2X84znvlYrXrToPRLZHJ30drJtD9oZQAsBSyOhpbmo(CUevGNzR)wL753lmRcb3V1hJddiyVth(GYP7wkHj)a8oKW(DZlPem0Z7Lus7Xw2TrI24JEakRBZ)Dm0rFLbvpiyzIOUhOb1OqfWsJItcILGK1lxdxcs78RlodMAUog56zPbwAadLqN2LhGL1K4e5(DYmcvDHoIlga)SaGGwA1fHnOqeTRYVNjlc6KrRExHHGPH)Ug4KQHNn0czuNZRNn13ySedjzxUtVVXq9mH(2lAIS8NVoctBhq3un6HTOwn1BGqX8uL7Frd9SDFZB)6gpChhASD0zJmed3zOmfJnrQNXyN9wnh7ZUN6kaPVQp7WFnoFhHHwm7E2JJB62xYYfVaV)m3mZpFyrobYP03lWffzekFr8(YST0K4DybzYKySSy4HF7)nDhPj6lg8FoBhzSyn)ZO2e)5Qh)x8oioKGKo2F83gmKkKdGLRlAgcoggbvpy9gOMAt2ifiuZEjPAFQlOpgZeqDmNVFXyjoN)c0QTW6Juy5JFaCKrnyla9aJ7Cf8yOgFNbWvBcdQ3GavTdoTjC1AeD28hbtz8PHRm(AyWQK(ldOQ0ckqNCka6Nofa9ZNgUkIWw7W1F5ea0OrNcGIOwVLC1ieXk9TB0aW6nIcAeHl7DGYa82DaDiqe16YHatSdyhzmNvDCzxe6WyUDlgdHzZOGhro3yZZmGUrRnf4DeUFfYYPoCsgBi6kkWYyg(z2qoe8Uuc3Ntl89dz7tnIfGb7sy49Xb9A4APRe)mA4cWO87Ug((HS9PeX1ejg)UBHEnCrC4HF4qmnlv9ROlwofEpDfM3tDRw8RonU(Gb2oWi91imMwIX)GbBRKnonafX5hZISXaYMn3uW3oC(0i9EnwuIhlyHtcrvAz(5gLjcK4)A9KeigMxVZlDcwASzlgiPrROtoNeyds)A7VxZ4aiyzh6biYi0AjHkOJTATBT(GmkDIp(VbWUJC(grPwhZ7rgLoIgoTbhILRTwzmzms(kAhqpnwOWsTuBblsCXhnybvRUkznpz(TxHQsPZzo5OuuDiKlMlF8nDYKsL7XDJukCKqdtjq9U(arV86(mS5b5PQULZeYqYEkUyoTShOBvMe7QdhZOz3wZ0akBV3IjtLPLFhbWgDPBbElW6T035SCNyDDx6wG3cSM0wbDpj8WV17w3piTGcyVVCUWDrh6sa3c8LUtCUqxE7DiyXqwlTI5Iuf5C9TvZnaOoxcc2LUf4TaRXwcc2LUf4TaRDT0dTBD)G0ckaEziqh6sa3c8fCHOD7DiyXq2tD4fmpnwNTzt2xjTtDLipU4WIVMKt(DcsTQQ8gkPDRQQeoSGwsFhw8W(sr)2LXCtz)oTEVAfTZRIlJFiUi5xj(1S4sIdkeEGJi47Ucs5ODd2juBvorbP648MrUirtDAi3wfofsILAfmpfzVFm2gQ3MWvonaflKVJzNqIWkuQUiPlyaVJYPa2oZ3YelYbos86DdW76O2Dd2wPV6KIXxHOEOtkKq(qGmr2jdHRTj4iSIDAQvmKKMCAZ7CRHoIDsX9QqZySiw26KfZNMTo5WV9)WOCkihFTUFxu6A29eY9PS8z3FF62)8S7z)(S)6S751Zl5F(7JP)D1ho7ErXHp7E(yn7)Cw5SFpI2hLt(c9RKFJ5rKz29up3iErgp7(ZiCzGJhZHf9iuQVvqgiXvQiQEbVA0ZRv7PXrNXORt0OEEY707dHGwxi5u1TCF2le8iPuHtWRZC6)AZEY)PVykbRaDpS4cYKPKxavMUhwCoz9ZHfdy)Vps9xyKklMoaGp3xhwC3HfJuz1oQivgYpFhJxkqo5mFJO5ibnfXWC(jiKG8QdXAO3Pg5KSX4rIpWX4XhavwId1Em2rTijRhIheGGqWR7cee7AAHUY41xvqqJ25f8YHf3EyH8qnaJQHqlt6uAX(viZGyqEHH6kQ5tnwuDeeCnFtaOG(ZnMrfnCct8N98nXwo0Ngi8A33GgKLS)jF8IknbaI7UcJNj2higq0WunXHElHGSygIZDtJ5CxnsxbIyXmy16Z6HR3dndwv)UyTvdi)FPXK)nbT2kCKnumD8OgJQris4Oi7XiC7bIeH1GPqi73UPWpZxflr6A72NEk3VrB2Q6oKbbzS3Jiqeagd)aVfmwa5ca7PgagpeWSW4H4QjoeGCHsWjt2Bwat3HCku7QzGjmmHnbwP4QUBIhfl8UWVsdyD4AUMfHVJ)igokhhYNMa4413fHqwJSZMMo7CKKs1VbDiYStvPjZPvkcd54sJqy2TcXpASgXbLgG187KK2H49PHcRJ7xOG6apkymbj)0hKxsbqFfMpZy)RvUbnCuwoK7vbWYvUFuANSKVfbgtSuugYLOMHY)aw8AJ3rq(h1q8(90YxakS553qlak5MYjJilQ5ouWtxI6sA17EKMOAiGO8bq5MNac4m8OI1S1SijcQ6cqWdsDKgOnVkLS8Rw)wFINxowlRaFqdSuRACNdA)czrdqPVswGimIRyYJ9eoot99txegZ7q23DlTIohX(NNPRGuzLwv8RqTW0Du1mKoGRf5zRwBUj7qSuvCP7XGLiaaWRrliMquNWeOd9PLlqL(osVTuw2z9aMaf1a4wm5qItzvT48Rr4mtv6cYSr9CR4YKLr1Q3USIjv77NKQ(ogxdJ9lPyfw9y9RPiBMwxbXGahYkXLXScKaPZxYAVAc8CVmSbHYZOschPhSwpbpat)4NqcDraS03utr35JAunLEY42OO3GaWqb)(i9Og6zn6hglhXsW7kMoQ1Qk2(r6vn0BuvdZtlMtFosfRQ5hVz2Tpt5(LYSQIvffkA)ps)1nFrUayeifiIopWpLJ)GrEmKCTRT0DJcXPFhEd2xoq4lVQ2tUkldmemQziiipww2)me30xEb(YlMWXZ03KwPtc82fpoGsMmEhKRypkpkvT8HdGZ8aJE(vOsDzAKMDwpFar0rPYQToQ8QGYI5ePWCukFtZdUodR8Hhs)rPVPLktG0zzZ4RmMLJ8nlh5Bwo6psZYaxicoNLhdnlBF9e0Iz5i2SSziPkksf6qUUEU3SEhOqWm(rnPcCUeNP7AFaftC1Q9mQLq16pailhSMrFGoRCl4QGe)6FKbbnqDo(SgocmCeAae5ywoZQZRo2vrUNMndutBAoaVpeiOKymnI7Ud1wGKyPrz6qrsZyiG1qH8qJYNgKHPHe2gkK4uFlju6eN7EWDWuSO2b7W0f)A2b9JSFcDy08ibJOEEfonyC(r9Qt4OSR0TIgm8adzCxr2BsYk9LrVM(wxtVAVpPmTArJQHJ5nfCvXSjs1G8LuIngMUSgswVcW4tF7UO)EhuXM8MWifUJXB4PorXdCJqrxB6hAiuKZ84v9oPQvhFUWfTbGHrMoyQTmoaojASykPuZF8A0ux0hk9IdAkBUQEiPuMPtvWvpcMdiQPzxptUkwaCs8E6IPVoWYUMcMi9sx0mmgMKQyClTQYu8(HOY)ODc3)J(6t0sfKfQVjomAvpFz6vjNYzKg)tgO7bPNmwR)TxOwiJm4uLXwsFNmsxFNOcAP0nUb5a1D7Bpoq2(tbs23WibOdyAQ2n2VYApJ84c3zWUjYMgvqfGDU6QQfntu4QSCqR5gV53jTbw)bJNO6RLIn3AHd2CcU)hASkSAp3w5KHmRsUOdkcKlOx7d6(ig2CwFvQ)MrT2fvewnxfRwkkupas0x2ii2UgxHX5XD1b2X9ETq(pOv63bB9qHiu0pYibCVxaz7VFOaAr6qjaCxJWuby4MR9EkQTqRYKdDOMG7Zs3mu8FKou4oJGkz1H8wH0XeCphWKo6qSGpdpbpBb9v0zCBLgwPI5gf177U4QrS)oXNFh)ZiVWBA2aXtXtUwO4jeUOcd1zeXPQHoJG7rK6thLWfaKP1WsHq4AQWnm1a4POo6gvFIHpur)(KFr3Xz1xNb1owYoSwI7RVzh1XqsRcGlnEfQOitZpLpAG06z1GffUR1EY6DqvE3cmvvkHA1WXTMICW4Q6)iXkbwUd1JqY(nmrTvZNbeL4H0E9SywsFZjVBPuxGjirCE)QonB8elailzKxbxzXWN6qKclbx9K3QLzGtRV4gFdi24(HeECxI86AGCUw5DtmjqrgeXA0lJZDGbOup(i6nEZGt1Hr8H4gOoAYh2uiUrmVCtWSmQjudB4e3ox3oK1uzPA6Ie6BWoiX6jzub7WQVdzcQVLDkx0SVIRoWxez9vvf3M8LtPl8e47ih5UysvVu(Mjyt1xcJnzW0BcLCL3WjeB(BT7lG597ipX2QSddNMabyLIe9E(jTEQSexVBFwBC1JbdYpmXr2648dtMlXQEa)8kY6q0iOmQB9yAkv(y5xJQ7zwV0JUxFOgx0vQXfDMBNz61CSunCdpG2HhCMH(yYDHQGSB1R2SqOlyFhri5bG7fPBsdek6(n4ZjpJ39nV(w8(M0HnC6lO()HGGyVSLU9349)IoSiGlnnD4psJG9Mwp5xvQSfpS9U1RPTJn9och5VsXDyJe3jWauxVWxfAIwg79N2vMYPhLdADwGf4OVGw6Hwihag5xLLT1Yfa33TlottuOLdtTRGiLRQQYbF9epWfk5jgpTcAL2G5mCdQNvRfQM8t8yccLdHqr8kelmsMjv7U6LBmP7GOX3gh)lV63KY1TkTosP8Z13gzxOi(g1afhQSe5GY6suLiQJ4LDQr16MHW0e1B3U3l1HDc28ERRlcKKY4A)z)IZn6YBq3AE12hC(9cHoEQuWN0PpX2OJVe0E63iBiwxjeG6qB5ou38Tq543JAx5HY6MNOMyHr5EENdvgoJ0vo(A7qpLR60TJnEsaXABD7c0O8FgI0ypDNrbpyZAIr15306QbiaoB)wS35AYsYdo)G6zm8QbVVDYBDmj6OAgT3AXJvUxXePVu011CmevJ4gN6kYgTz1nz89bJrXLzRlja3Y51etdOem5ADv8176iiEgqbt0QAZOEPV1Daqal97YLOwhOFDz1W2XzRdGVMzquMIGR1hAwRfloaI9wHHpXWWc4f6PZyJcvoIydI)O)mZ8IeDvAr((xmns58EeLj4tL5FoPak7NQTReqCjX2UCLQ8aXmHXI0gCOB2H8e0m2kYEkWfQrnzxDmbHUEgy3sIqWvS952bAP4WIQQjSD)qpjVqOjq6L8JAq3OxRnEvJm8f3vIwRpxVNbUWoiQa6CN7MkU6urfhlj08Rqsuze9xdkX6a3XtDhEFQ3C4lLjmkac6gxRLt3rcFNW54zm0yLiU7dezKNsYZMxMNWUcmki4yoPtn98kuLBvhrU2jJY6IkLG1h8PJABHCC83MAC99PzuwQrTRgT7K7OTJoXkwBnCsC3vHPKTv4ZNuhkUXtmDUE29T6JOj)Du5)V9UA7TTXHb)BPFjW9kUIlDD3TbK1FkxG3IV2GM2EW17Lp1F7twVskrsj50K5IfS9PAfBjksk(YdP01VP3PsXNFSFiscmQGt50Rx4Y)QmlFQNFSFi5Y)QWYhLE32ELjskHINucXj(fZ75zqfq7UnkD93TDTbMxEscLscT4rrHgLkwd(6(dbrqXWypqMyVAAC7CAAPtTdThdtmv(I5OhNnF2C0)3rRt(C0JtNViMkrv9voCq4WCrG6bTqMfTcIeFV59cv6k7WkTmwL4afQQ8IaitLTSkTfuwWlUhU(m(yQyCFT7fpUGZv1Sn5rahtCKnKZe06NmocxuHHWmqYKRKwaFpgIq5Yb(8BZHxeM40mMqTpdX)4s)3(SddDZZuxgIwYfJ7xLQFlh57gpmLFBr4iIJgbYsHd4QlJpHJ68mrZqQxADLvy9yiP6dbgFKUpy7Fw(JjrDOTI5JfyYKXPXKFD0GIn(sWOeHCOnDL1rjUegj2bxMSkYqO2EbNwZ1KVu7MNABZv(54DAph12k)qfwO0mWIjLL35JX9e4j2l(TZ01h(g1mE6oX(KRB6oN6pZ4f2eBbRbK)ApBos5J)dMarytM0DiVy8IKIB9wW7GYWJ8bSOCiqZ6llXb6rvYfomdjfg3eBaNPfehvAVI)G(t8Yesm8PJjDnNL2gdS53F54gW6HNwVzBN)XNZTzUK6O(8Bvem86nK2EDWrgHSGHEFP6iYVCp6iKrjaNBpp29d1AbaZ(HPCf6OOklVCPwJBJ22o10z8OzZDaTZuV)aRNoruX1)rTMqI5Bs94l2stUbaoPoDmJSOqNquF()YEf0GWn2l4aKLLgoHl3N3PNa8PMcYrxcaWYtR9RqdDNfmpE7iQNmu)na07OxNuPyPUfzLZ867K(hSz(F6aHDnZ)ydj82M2Fy7hPteO)ShyahK(TOoME7UDoTCgTXBAFO9wCxO9dj)Wifk2zMFJYbZl0U07bI)PTd0K7XNiI8bRDG(Bcrw3nonGXR8ifVp0ibZwWEyMb7FPFGX3o30kZxUYCKgRi4FKiFSvakexhOiqfhj2a7WNmvrhMqjgfdboMgzdAmMyezeKjweWqr4HU5Gig68IDw)s4cJ2nLaT74hh0)xH5MHuEr1Dx9Bgs3sH3YG7DC3RraaDfnrphgvrU9ZyTBeN3DJt)2806VlOSh0rsj6mSc49RjFvReOOY15HuJyV6Q3q))f)MVvMM1ob4ukO(scohob8nDOxWdT93d0(LNcppjVjmrcMsayOYn0i(6z7A)CGPAVzD19nchgKel6qKZ4e4Xv5LVMTeGlenOo858plPWUWk9YynjQVvj3KPMyOXCteXITx57RRnAmKdG4YgwkT1BlSjk8fmpzgGceX2RUIOv(xPb1abh(SFLCHLDAZy)j48MSlwkbNO2Su7Mi7YErFlH7J(abL)ZFD39kTodwWlOP(LbSaiT(1Up0bAZEMvUKPwTdJRFLZPDDBk1cElNWCExVypP9mjNfysyIbdxSHaNuIifA2b(aCCSyhwDIBOkUHcT3i0bhtVs2yaXfl6lg)gcnMm)cW(Ee6bAAMkI77Yecd(noXz2cOmdzSaYgzxVGfRMzd8AaJSe3aVXR4oSDg3v3YChEuMJPLup9Mbh)xPQJ(gsSkuYjxne5yTV97R1PyD9))Lb3x6nEAwbA1IndkbBLjx6E8H0L1AQKR0nA8Au4o9culUgWAc7mrITBWVP033PeXvBxdQ9MHx1jK7Gq2(DKvDXxF8UTJL3A3M1Tp)8yHxgYcnk((cx0z1ozjFuuXNttBHvnbVNiviZFskDpKsd57qVHK3zfU2YEg6Z8pinxnjZtal)4PmZj)n6p1fCMaat8CApgOeXIOJztlNaHlvT8joeA7YcuRcIr)PyHWkP)CFMlV(Qo5nQCFMN06ffUpZAkYIsVXzPsRukUZQPx)U(EBVMe(8OLJ321dTi89mle(J8tYw7N01YlwXKpMvc36yXbjy0DBXycGVtU(pAeSFnUo9aZMOXHRspDBRmAeXfOhfQ6VU8sZdez1CfMx2gu8VupHbbg5W4TpF0VLd72rz1VAsxpbcv2gB0eH8vbawi0i3jeOch(i6yienhesE4UoTuvYIB80SLq6hiFHuft7htfNPkM2OQBrUJxB(3)(Zp]] )
