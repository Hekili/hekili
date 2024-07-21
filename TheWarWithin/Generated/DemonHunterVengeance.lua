-- DemonHunterVengeance.lua
-- July 2024

local addon, ns = ...
local Hekili = _G[ addon ]
local class, state = Hekili.Class, Hekili.State

local spec = Hekili:NewSpecialization( 581 )

-- Resources
spec:RegisterResource( Enum.PowerType.Fury )
spec:RegisterResource( Enum.PowerType.Pain )

spec:RegisterTalents( {
    -- Demon Hunter Talents
    aldrachi_design           = { 90999, 391409, 1 }, -- Increases your chance to parry by $s1%.
    aura_of_pain              = { 90933, 207347, 1 }, -- Increases the critical strike chance of Immolation Aura by $s1%.
    blazing_path              = { 91008, 320416, 1 }, -- $?a212613[Infernal Strike][Fel Rush] gains an additional charge.
    bouncing_glaives          = { 90931, 320386, 1 }, -- Throw Glaive ricochets to $s1 additional $ltarget:targets;.
    champion_of_the_glaive    = { 90994, 429211, 1 }, -- Throw Glaive has ${$s2+1} charges and $s1 yard increased range.
    chaos_fragments           = { 95154, 320412, 1 }, -- Each enemy stunned by Chaos Nova has a $179057s3% chance to generate a Lesser Soul Fragment.
    chaos_nova                = { 90993, 179057, 1 }, -- Unleash an eruption of fel energy, dealing $s2 Chaos damage and stunning all nearby enemies for $d.$?s320412[; Each enemy stunned by Chaos Nova has a $s3% chance to generate a Lesser Soul Fragment.][]
    charred_warblades         = { 90948, 213010, 1 }, -- You heal for $s1% of all Fire damage you deal.
    collective_anguish        = { 95152, 390152, 1 }, -- $?a212613[Fel Devastation][Eye Beam] summons an allied $?a212613[Havoc][Vengeance] Demon Hunter who casts $?a212613[Eye Beam][Fel Devastation], dealing $?a212613[${$391058s1*10*2} Chaos][${$393834s1*(2/$393831t1)} Fire] damage over $?a212613[$391057d][$393831d]. $?a212613[Deals reduced damage beyond $198013s5 targets.][Dealing damage heals you for up to ${$212106s1*(2/$t1)} health.]
    consume_magic             = { 91006, 278326, 1 }, -- Consume $m1 beneficial Magic effect removing it from the target$?s320313[ and granting you $s2 Fury][].
    darkness                  = { 91002, 196718, 1 }, -- Summons darkness around you in a$?a357419[ 12 yd][n 8 yd] radius, granting friendly targets a $209426s2% chance to avoid all damage from an attack. Lasts $d.; Chance to avoid damage increased by $s3% when not in a raid.
    demon_muzzle              = { 90928, 388111, 1 }, -- Enemies deal $s1% reduced magic damage to you for $394933d after being afflicted by one of your Sigils.
    demonic                   = { 91003, 213410, 1 }, -- $?a212613[Fel Devastation][Eye Beam] causes you to enter demon form for ${$s1/1000} sec after it finishes dealing damage.
    disrupting_fury           = { 90937, 183782, 1 }, -- Disrupt generates $218903s1 Fury on a successful interrupt.
    erratic_felheart          = { 90996, 391397, 2 }, -- The cooldown of $?a212613[Infernal Strike ][Fel Rush ]is reduced by ${-1*$s1}%.
    felblade                  = { 95150, 232893, 1 }, -- [395020] $?a388114[Chaos][Fire]
    felfire_haste             = { 90939, 389846, 1 }, -- $?c1[Fel Rush][Infernal Strike] increases your movement speed by $389847s1% for $389847d.
    flames_of_fury            = { 90949, 389694, 2 }, -- Sigil of Flame deals $s2% increased damage and generates $s1 additional Fury per target hit.
    illidari_knowledge        = { 90935, 389696, 1 }, -- Reduces magic damage taken by $s1%.
    imprison                  = { 91007, 217832, 1 }, -- Imprisons a demon, beast, or humanoid, incapacitating them for $d. Damage will cancel the effect. Limit 1.
    improved_disrupt          = { 90938, 320361, 1 }, -- Increases the range of Disrupt to ${$s2+$s1} yds.
    improved_sigil_of_misery  = { 90945, 320418, 1 }, -- Reduces the cooldown of Sigil of Misery by ${$s1/-1000} sec.
    infernal_armor            = { 91004, 320331, 2 }, -- [395020] $?a388114[Chaos][Fire]
    internal_struggle         = { 90934, 393822, 1 }, -- Increases your mastery by ${$s1*$mas}.1%.
    live_by_the_glaive        = { 95151, 428607, 1 }, -- When you parry an attack or have one of your attacks parried, restore $428608s2% of max health and $428608s1 Fury. ; This effect may only occur once every $s1 sec.
    long_night                = { 91001, 389781, 1 }, -- Increases the duration of Darkness by ${$s1/1000} sec.
    lost_in_darkness          = { 90947, 389849, 1 }, -- Spectral Sight lasts an additional ${$s1/1000} sec if disrupted by attacking or taking damage.
    master_of_the_glaive      = { 90994, 389763, 1 }, -- Throw Glaive has ${$s2+1} charges and snares all enemies hit by $213405s1% for $213405d.
    pitch_black               = { 91001, 389783, 1 }, -- Reduces the cooldown of Darkness by ${$s1/-1000} sec.
    precise_sigils            = { 95155, 389799, 1 }, -- All Sigils are now placed at your target's location.
    pursuit                   = { 90940, 320654, 1 }, -- Mastery increases your movement speed.
    quickened_sigils          = { 95149, 209281, 1 }, -- All Sigils activate ${$s1/-1000} second faster.
    rush_of_chaos             = { 95148, 320421, 2 }, -- Reduces the cooldown of Metamorphosis by ${$m1/-1000} sec.
    shattered_restoration     = { 90950, 389824, 1 }, -- The healing of Shattered Souls is increased by $s1%.
    sigil_of_misery           = { 90946, 207684, 1 }, -- Place a Sigil of Misery at the target location that activates after $d.; Causes all enemies affected by the sigil to cower in fear, disorienting them for $207685d.
    sigil_of_spite            = { 90997, 390163, 1 }, -- Place a demonic sigil at the target location that activates after $d.; Detonates to deal $389860s1 Chaos damage and shatter up to $s3 Lesser Soul Fragments from enemies affected by the sigil. Deals reduced damage beyond $s1 targets.
    soul_rending              = { 90936, 204909, 2 }, -- Leech increased by $s1%.; Gain an additional $s2% leech while Metamorphosis is active.
    soul_sigils               = { 90929, 395446, 1 }, -- Afflicting an enemy with a Sigil generates $m1 Lesser Soul $LFragment:Fragments;. 
    swallowed_anger           = { 91005, 320313, 1 }, -- Consume Magic generates $278326s2 Fury when a beneficial Magic effect is successfully removed from the target.
    the_hunt                  = { 90927, 370965, 1 }, -- Charge to your target, striking them for $370966s1 Chaos damage, rooting them in place for $370970d and inflicting $370969o1 Chaos damage over $370969d to up to $370967s2 enemies in your path. ; The pursuit invigorates your soul, healing you for $?c1[$370968s1%][$370968s2%] of the damage you deal to your Hunt target for $370966d.
    unrestrained_fury         = { 90941, 320770, 1 }, -- Increases maximum Fury by $s1.
    vengeful_bonds            = { 90930, 320635, 1 }, -- Vengeful Retreat reduces the movement speed of all nearby enemies by $198813s1% for $198813d.
    vengeful_retreat          = { 90942, 198793, 1 }, -- Remove all snares and vault away. Nearby enemies take $198813s2 Physical damage$?s320635[ and have their movement speed reduced by $198813s1% for $198813d][].$?a203551[; Generates ${($203650s1/5)*$203650d} Fury over $203650d if you damage an enemy.][]
    will_of_the_illidari      = { 91000, 389695, 1 }, -- Increases maximum health by $s1%.

    -- Vengeance Talents
    agonizing_flames          = { 90971, 207548, 1 }, -- Immolation Aura increases your movement speed by $s1% and its duration is increased by $s2%.
    aldrachi_tactics          = { 94914, 442683, 1 }, -- The second enhanced ability in a pattern shatters an additional Soul Fragment.
    army_unto_oneself         = { 94896, 442714, 1 }, -- Felblade surrounds you with a Blade Ward, reducing damage taken by $442715s1% for $442715d.
    art_of_the_glaive         = { 94915, 442290, 1 }, -- [442294] Throw a glaive enhanced with the essence of consumed souls at your target, dealing $s1 Physical damage and ricocheting to ${$x1-1} additional $Lenemy:enemies;.;  ; Begins a well-practiced pattern of glaivework, enhancing your next $?a212612[Chaos Strike]?s263642[Fracture][Shear] and $?a212612[Blade Dance][Soul Cleave].; The enhanced ability you cast first deals $442290s3% increased damage, and the second deals $442290s4% increased damage.$?a442497[; Generates $s2 Fury.][]
    ascending_flame           = { 90960, 428603, 1 }, -- Sigil of Flame's initial damage is increased by $s2%.; Multiple applications of Sigil of Flame may overlap.
    bulk_extraction           = { 90956, 320341, 1 }, -- Demolish the spirit of all those around you, dealing $s1 Fire damage to nearby enemies and extracting up to $s2 Lesser Soul Fragments, drawing them to you for immediate consumption.
    burning_alive             = { 90959, 207739, 1 }, -- Every $207771t3 sec, Fiery Brand spreads to one nearby enemy.
    burning_blades            = { 94905, 452408, 1 }, -- Your blades burn with Fel energy, causing your $?a212612[Chaos Strike][Soul Cleave], Throw Glaive, and auto-attacks to deal an additional $s1% damage as Fire over $453177d.
    burning_blood             = { 90987, 390213, 1 }, -- Fire damage increased by $s1%.
    calcified_spikes          = { 90967, 389720, 1 }, -- You take $391171s2% reduced damage after Demon Spikes ends, fading by 1% per second.
    chains_of_anger           = { 90964, 389715, 1 }, -- Increases the duration of your Sigils by ${$s2/1000} sec and radius by $s1 yds.
    charred_flesh             = { 90962, 336639, 2 }, -- Immolation Aura damage increases the duration of your Fiery Brand and Sigil of Flame by ${$s1/1000}.2 sec.
    cycle_of_binding          = { 90963, 389718, 1 }, -- Afflicting an enemy with a Sigil reduces the cooldown of your Sigils by $s1 sec. 
    darkglare_boon            = { 90985, 389708, 1 }, -- When Fel Devastation finishes fully channeling, it refreshes $s1-$s2% of its cooldown and refunds $s3-$s4 Fury.
    deflecting_spikes         = { 90989, 321028, 1 }, -- Demon Spikes also increases your Parry chance by $203819s1% for $203819d.
    demonic_intensity         = { 94901, 452415, 1 }, -- Activating Metamorphosis greatly empowers $?a212612[Eye Beam][Fel Devastation], Immolation Aura, and Sigil of Flame.; Demonsurge damage is increased by $?a452416[${$452416s2/$452416u}][$452416s2]% for each time it previously triggered while your demon form is active.
    demonsurge                = { 94917, 452402, 1 }, -- Metamorphosis now also $?a203555[causes Demon Blades to generate $162264s10 additional Fury]?a212612[causes Demon's Bite to generate $162264s11 additional Fury][greatly empowers Soul Cleave and Spirit Bomb].; While demon form is active, the first cast of each empowered ability induces a Demonsurge, causing you to explode with Fel energy, dealing $452416s1 Fire damage to nearby enemies.
    down_in_flames            = { 90961, 389732, 1 }, -- Fiery Brand has ${$s1/-1000} sec reduced cooldown and $s2 additional $lcharge:charges;.
    enduring_torment          = { 94916, 452410, 1 }, -- The effects of your demon form persist outside of it in a weakened state, increasing $?a212612[Chaos Strike and Blade Dance damage by 5%, and Haste by 3%][maximum health by 5% and Armor by 20%].
    evasive_action            = { 94911, 444926, 1 }, -- Vengeful Retreat can be cast a second time within $444929d.
    extended_spikes           = { 90966, 389721, 1 }, -- Increases the duration of Demon Spikes by ${$s1/1000} sec.
    fallout                   = { 90972, 227174, 1 }, -- Immolation Aura's initial burst has a chance to shatter Lesser Soul Fragments from enemies.
    feast_of_souls            = { 90969, 207697, 1 }, -- Soul Cleave heals you for an additional $207693o1 over $207693d.
    feed_the_demon            = { 90983, 218612, 2 }, -- Consuming a Soul Fragment reduces the remaining cooldown of Demon Spikes by ${$s1/100}.2 sec.
    fel_devastation           = { 90991, 212084, 1 }, -- Unleash the fel within you, damaging enemies directly in front of you for ${$212105s1*(2/$t1)} Fire damage over $d.$?s320639[ Causing damage also heals you for up to ${$212106s1*(2/$t1)} health.][]
    fel_flame_fortification   = { 90955, 389705, 1 }, -- You take $393009s1% reduced magic damage while Immolation Aura is active.
    fiery_brand               = { 90951, 204021, 1 }, -- Brand an enemy with a demonic symbol, instantly dealing $s2 Fire damage$?s320962[ and ${$207771s5*$207771d} Fire damage over $207771d][]. The enemy's damage done to you is reduced by $s1% for $207744d.
    fiery_demise              = { 90958, 389220, 2 }, -- Fiery Brand also increases Fire damage you deal to the target by $s1%.
    flamebound                = { 94902, 452413, 1 }, -- Immolation Aura has 2 yd increased radius and 30% increased critical strike damage bonus.
    focused_cleave            = { 90975, 343207, 1 }, -- Soul Cleave deals $s1% increased damage to your primary target.
    focused_hatred            = { 94918, 452405, 1 }, -- Demonsurge deals $s1% increased damage when it strikes a single target.
    fracture                  = { 90970, 263642, 1 }, -- Rapidly slash your target for ${$225919sw1+$225921sw1} Physical damage, and shatter $s1 Lesser Soul Fragments from them.; Generates $s4 Fury.
    frailty                   = { 90990, 389958, 1 }, -- Enemies struck by Sigil of Flame are afflicted with Frailty for $247456d.; You heal for $247456s1% of all damage you deal to targets with Frailty.
    fury_of_the_aldrachi      = { 94898, 442718, 1 }, -- When enhanced by Reaver's Glaive, $?a212612[Blade Dance][Soul Cleave] casts $s2 additional glaive slashes to nearby targets. ; If cast after $?a212612[Chaos Strike]?s263642[Fracture][Shear], cast ${$s2*($s1/100+1)} slashes instead.
    illuminated_sigils        = { 90961, 428557, 1 }, -- Sigil of Flame has ${$s3/-1000} sec reduced cooldown and $s1 additional $lcharge:charges;.; You have $s2% increased chance to parry attacks from enemies afflicted by your Sigil of Flame.
    improved_soul_rending     = { 94899, 452407, 1 }, -- Leech granted by Soul Rending increased by $s1% and an additional $s2% while Metamorphosis is active.
    incisive_blade            = { 94895, 442492, 1 }, -- $?a212612[Chaos Strike][Soul Cleave] deals $s1% increased damage.
    incorruptible_spirit      = { 94896, 442736, 1 }, -- Consuming a Soul Fragment also heals you for an additional $s1% over time.
    keen_engagement           = { 94910, 442497, 1 }, -- Reaver's Glaive generates $s1 Fury.
    last_resort               = { 90979, 209258, 1 }, -- Sustaining fatal damage instead transforms you to Metamorphosis form.; This may occur once every $209261d.
    meteoric_strikes          = { 90953, 389724, 1 }, -- Reduce the cooldown of Infernal Strike by ${$s1/-1000} sec.
    monster_rising            = { 94909, 452414, 1 }, -- Agility increased by $452550s1% while not in demon form.
    painbringer               = { 90976, 207387, 2 }, -- Consuming a Soul Fragment reduces all damage you take by $s1% for $212988d.; Multiple applications may overlap.
    perfectly_balanced_glaive = { 90968, 320387, 1 }, -- Reduces the cooldown of Throw Glaive by ${$abs($s0/1000)} sec.
    preemptive_strike         = { 94910, 444997, 1 }, -- Throw Glaive deals $444979s1 damage to enemies near its initial target.
    pursuit_of_angriness      = { 94913, 452404, 1 }, -- Movement speed increased by $s1% per $s2 Fury.
    reavers_mark              = { 94903, 442679, 1 }, -- When enhanced by Reaver's Glaive, $?a212612[Chaos Strike]?s263642[Fracture][Shear] applies Reaver's Mark, which causes the target to take $442624s1% increased damage for $442624d. ; If cast after $?a212612[Blade Dance][Soul Cleave], Reaver's Mark is increased to ${$442624s1*($s1/100+1)}%.
    retaliation               = { 90952, 389729, 1 }, -- While Demon Spikes is active, melee attacks against you cause the attacker to take $391159s1 Physical damage. Generates high threat.
    revel_in_pain             = { 90957, 343014, 1 }, -- When Fiery Brand expires on your primary target, you gain a shield that absorbs up ${$AP*($s2/100)*(1+$@versadmg)} damage for $343013d, based on your damage dealt to them while Fiery Brand was active. 
    roaring_fire              = { 90988, 391178, 1 }, -- Fel Devastation heals you for up to $s1% more, based on your missing health.
    ruinous_bulwark           = { 90965, 326853, 1 }, -- Fel Devastation heals for an additional $s1%, and $s2% of its healing is converted into an absorb shield for $326863d.
    set_fire_to_the_pain      = { 94899, 452406, 1 }, -- $s2% of all non-Fire damage taken is instead taken as Fire damage over $453286d.; Fire damage taken reduced by $S3%.
    shear_fury                = { 90970, 389997, 1 }, -- Shear generates $s1 additional Fury.
    sigil_of_chains           = { 90954, 202138, 1 }, -- Place a Sigil of Chains at the target location that activates after $d.; All enemies affected by the sigil are pulled to its center and are snared, reducing movement speed by $204843s1% for $204843d.
    sigil_of_silence          = { 90988, 202137, 1 }, -- Place a Sigil of Silence at the target location that activates after $d.; Silences all enemies affected by the sigil for $204490d.
    soul_barrier              = { 90956, 263648, 1 }, -- Shield yourself for $d, absorbing $<baseAbsorb> damage.; Consumes all available Soul Fragments to add $<fragmentAbsorb> to the shield per fragment.
    soul_carver               = { 90982, 207407, 1 }, -- Carve into the soul of your target, dealing ${$s2+$214743s1} Fire damage and an additional $o1 Fire damage over $d.  Immediately shatters $s3 Lesser Soul Fragments from the target and $s4 additional Lesser Soul Fragment every $t1 sec.
    soul_furnace              = { 90974, 391165, 1 }, -- Every $391166u Soul Fragments you consume increases the damage of your next Soul Cleave or Spirit Bomb by $391172s1%.
    soulcrush                 = { 90980, 389985, 1 }, -- Multiple applications of Frailty may overlap.; Soul Cleave applies Frailty to your primary target for $s2 sec.
    soulmonger                = { 90973, 389711, 1 }, -- When consuming a Soul Fragment would heal you above full health it shields you instead, up to a maximum of ${$MHP*$s1/100}.
    spirit_bomb               = { 90978, 247454, 1 }, -- Consume up to $s2 available Soul Fragments then explode, damaging nearby enemies for $247455s1 Fire damage per fragment consumed, and afflicting them with Frailty for $247456d, causing you to heal for $247456s1% of damage you deal to them. Deals reduced damage beyond $s3 targets.
    stoke_the_flames          = { 90984, 393827, 1 }, -- Fel Devastation damage increased by $s1%.
    student_of_suffering      = { 94902, 452412, 1 }, -- Sigil of Flame applies Student of Suffering to you, increasing Mastery by ${$453239s1*$mas}.1% and granting $453236s1 Fury every $453239t2 sec, for $453239d.
    thrill_of_the_fight       = { 94919, 442686, 1 }, -- After consuming both enhancements, gain Thrill of the Fight, increasing your attack speed by $442695s1% for $442695d and your damage and healing by $442688s1% for $442688d.
    unhindered_assault        = { 94911, 444931, 1 }, -- Vengeful Retreat resets the cooldown of Felblade.
    untethered_fury           = { 94904, 452411, 1 }, -- Maximum Fury increased by $s1.
    violent_transformation    = { 94912, 452409, 1 }, -- When you activate Metamorphosis, the cooldowns of your Sigil of Flame and $?a212612[Immolation Aura][Fel Devastation] are immediately reset.
    void_reaver               = { 90977, 268175, 1 }, -- Frailty now also reduces all damage you take from afflicted targets by $s2%.; Enemies struck by Soul Cleave are afflicted with Frailty for $247456d.
    volatile_flameblood       = { 90986, 390808, 1 }, -- Immolation Aura generates $m-$M Fury when it deals critical damage.; This effect may only occur once per ${$proccooldown+0.1} sec.
    vulnerability             = { 90981, 389976, 2 }, -- Frailty now also increases all damage you deal to afflicted targets by $s1%.
    warblades_hunger          = { 94906, 442502, 1 }, -- Consuming a Soul Fragment causes your next $?a212612[Chaos Strike]?s263642[Fracture][Shear] to deal $442507s1 additional damage.$?a212612[; Felblade consumes up to $s2 nearby Soul Fragments.][]
    wave_of_debilitation      = { 94913, 452403, 1 }, -- Chaos Nova slows enemies by 60% and reduces attack and cast speed 15% for 5 sec after its stun fades. 
    wounded_quarry            = { 94897, 442806, 1 }, -- While $@spellname442624 is on your target, melee attacks strike with an additional glaive slash for $442808s1 Physical damage and have a chance to shatter a soul.
} )

-- PvP Talents
spec:RegisterPvpTalents( {
    blood_moon        = 5434, -- (355995) Consume Magic now affects all enemies within 8 yards of the target and generates a Lesser Soul Fragment. Each effect consumed has a $s1% chance to upgrade to a Greater Soul.
    chaotic_imprint   = 5439, -- (356510) Throw Glaive now deals damage from a random school of magic, and increases the target's damage taken from the school by $s1% for $356632d.
    cleansed_by_flame = 814 , -- (205625) Immolation Aura dispels a magical effect on you when cast.
    cover_of_darkness = 5520, -- (357419) The radius of Darkness is increased by $s1 yds, and its duration by ${$s2/1000} sec.
    demonic_trample   = 3423, -- (205629) Transform to demon form, moving at $m3% increased speed for $d, knocking down all enemies in your path and dealing $208645m1 Physical damage.; During Demonic Trample you are unaffected by snares but cannot cast spells or use your normal attacks. Shares charges with Infernal Strike.
    detainment        = 3430, -- (205596) Imprison's PvP duration is increased by $m2 sec, and targets become immune to damage and healing while imprisoned.
    everlasting_hunt  = 815 , -- (205626) Dealing damage increases your movement speed by $208769m1% for $208769d.
    glimpse           = 5522, -- (354489) Vengeful Retreat provides immunity to loss of control effects, and reduces damage taken by $s1% until you land.
    illidans_grasp    = 819 , -- (205630) You strangle the target with demonic magic, stunning them in place and dealing $o4 Shadow damage over $d while the target is grasped. Can move while channeling.; Use Illidan's Grasp again to toss the target to a location within $208173R yards, stunning them and all nearby enemies for $208618d and dealing $208618s1 Shadow damage.
    jagged_spikes     = 816 , -- (205627) While Demon Spikes is active, melee attacks against you cause Physical damage equal to $m1% of the damage taken back to the attacker.
    rain_from_above   = 5521, -- (206803) You fly into the air out of harm's way. While floating, you gain access to Fel Lance allowing you to deal damage to enemies below. 
    reverse_magic     = 3429, -- (205604) Removes all harmful magical effects from yourself and all nearby allies within $m1 yards, and sends them back to their original caster if possible.
    sigil_mastery     = 1948, -- (211489) Reduces the cooldown of your Sigils by an additional $m1%.
    tormentor         = 1220, -- (207029) [206891] You focus the assault on this target, increasing their damage taken by $s1% for $d. Each unique player that attacks the target increases the damage taken by an additional $s1%, stacking up to $u times.; Your melee attacks refresh the duration of Focused Assault.
    unending_hatred   = 3727, -- (213480) Taking damage causes you to gain Fury based on the damage dealt.
} )

-- Auras
spec:RegisterAuras( {
    -- $w1 Soul Fragments consumed. At $?a212612[$442290s1~][$442290s2~], Reaver's Glaive is available to cast.
    art_of_the_glaive = {
        id = 444661,
        duration = 30.0,
        max_stack = 1,
    },
    -- Damage taken reduced by $s1%.
    blade_ward = {
        id = 442715,
        duration = 5.0,
        max_stack = 1,
    },
    -- Damage taken reduced by $w1%, fading over $d.
    calcified_spikes = {
        id = 391171,
        duration = 12.0,
        max_stack = 1,
    },
    -- Magic damage taken increased by $s1%.
    chaos_brand = {
        id = 1490,
        duration = 3600,
        max_stack = 1,
    },
    -- Arcane damage taken increased by $s1%.
    chaos_brand_arcane = {
        id = 356632,
        duration = 20.0,
        max_stack = 1,
    },
    -- Stunned.
    chaos_nova = {
        id = 179057,
        duration = 2.0,
        max_stack = 1,

        -- Affected by:
        -- vengeance_demon_hunter[212613] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- vengeance_demon_hunter[212613] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- vengeance_demon_hunter[212613] #2: { 'type': APPLY_AURA, 'subtype': MOD_GLOBAL_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'target': TARGET_UNIT_CASTER, }
        -- burning_blood[390213] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- burning_blood[390213] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- frailty[247456] #3: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'points': 2.0, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- fiery_brand[207771] #1: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- havoc_demon_hunter[212612] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- havoc_demon_hunter[212612] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- havoc_demon_hunter[212612] #2: { 'type': APPLY_AURA, 'subtype': MOD_GLOBAL_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'target': TARGET_UNIT_CASTER, }
        -- havoc_demon_hunter[212612] #11: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- havoc_demon_hunter[212612] #12: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
    },
    -- Magic damage dealt to $@auracaster is reduced by $w1%.
    demon_muzzle = {
        id = 394933,
        duration = 8.0,
        max_stack = 1,
    },
    -- Deals $w1 Physical damage back to attackers.
    demon_spikes = {
        id = 391159,
        duration = 0.0,
        max_stack = 1,
    },
    -- Stunned.
    demonic_trample = {
        id = 208645,
        duration = 0.0,
        max_stack = 1,

        -- Affected by:
        -- vengeance_demon_hunter[212613] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- vengeance_demon_hunter[212613] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- frailty[247456] #3: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'points': 2.0, 'target': TARGET_UNIT_TARGET_ENEMY, }
    },
    -- Vengeful Retreat may be cast again.
    evasive_action = {
        id = 444929,
        duration = 3.0,
        max_stack = 1,
    },
    -- Increases movement speed by $w1%.
    everlasting_hunt = {
        id = 208769,
        duration = 3.0,
        max_stack = 1,
    },
    -- Healing $w1 health every $t1 sec.
    feast_of_souls = {
        id = 207693,
        duration = 6.0,
        max_stack = 1,
    },
    -- Magic damage taken reduced by $s1%.
    fel_flame_fortification = {
        id = 393009,
        duration = 3600,
        max_stack = 1,
    },
    -- Movement speed increased by $w1%.
    felfire_haste = {
        id = 389847,
        duration = 8.0,
        max_stack = 1,
    },
    -- Branded, taking $w5 Fire damage every $t5 sec, and dealing $204021s1% less damage to $@auracaster$?s389220[ and taking $w2% more Fire damage from them][].
    fiery_brand = {
        id = 207771,
        duration = 12.0,
        tick_time = 1.0,
        max_stack = 1,

        -- Affected by:
        -- vengeance_demon_hunter[212613] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- vengeance_demon_hunter[212613] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- burning_blood[390213] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- burning_blood[390213] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- fiery_demise[389220] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER_BY_LABEL, 'points': 25.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_2_VALUE, }
        -- frailty[247456] #3: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'points': 2.0, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- fiery_brand[207771] #1: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'target': TARGET_UNIT_TARGET_ENEMY, }
    },
    -- Damage taken increased by $m1%.
    focused_assault = {
        id = 206891,
        duration = 6.0,
        max_stack = 1,
    },
    -- Battling a demon from the Theater of Pain...
    fodder_to_the_flame = {
        id = 329554,
        duration = 25.0,
        max_stack = 1,
    },
    -- $@auracaster is healed for $w1% of all damage they deal to you.$?$w3!=0[; Dealing $w3% reduced damage to $@auracaster.][]$?$w4!=0[; Suffering $w4% increased damage from $@auracaster.][]
    frailty = {
        id = 247456,
        duration = 6.0,
        tick_time = 1.0,
        pandemic = true,
        max_stack = 1,

        -- Affected by:
        -- soulcrush[389985] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 19.0, 'target': TARGET_UNIT_CASTER, 'modifies': MAX_STACKS, }
    },
    -- Falling speed reduced.
    glide = {
        id = 131347,
        duration = 3600,
        max_stack = 1,
    },
    -- Stunned.
    illidans_grasp = {
        id = 208618,
        duration = 3.0,
        max_stack = 1,

        -- Affected by:
        -- vengeance_demon_hunter[212613] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- vengeance_demon_hunter[212613] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- frailty[247456] #3: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'points': 2.0, 'target': TARGET_UNIT_TARGET_ENEMY, }
    },
    -- [395020] $?a388114[Chaos][Fire]
    immolation_aura = {
        id = 258920,
        duration = 6.0,
        max_stack = 1,

        -- Affected by:
        -- vengeance_demon_hunter[212613] #3: { 'type': APPLY_AURA, 'subtype': MOD_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'target': TARGET_UNIT_CASTER, }
        -- infernal_armor[320331] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_5_VALUE, }
        -- agonizing_flames[207548] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_4_VALUE, }
        -- agonizing_flames[207548] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 50.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
        -- havoc_demon_hunter[212612] #3: { 'type': APPLY_AURA, 'subtype': MOD_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'target': TARGET_UNIT_CASTER, }
    },
    -- Incapacitated.
    imprison = {
        id = 217832,
        duration = 60.0,
        max_stack = 1,

        -- Affected by:
        -- detainment[205596] #0: { 'type': APPLY_AURA, 'subtype': OVERRIDE_ACTIONBAR_SPELLS, 'spell': 221527, 'target': TARGET_UNIT_CASTER, }
        -- detainment[205596] #3: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
    },
    -- Movement speed reduced by $s1%.
    master_of_the_glaive = {
        id = 213405,
        duration = 6.0,
        max_stack = 1,
    },
    -- Stunned.
    metamorphosis = {
        id = 200166,
        duration = 3.0,
        max_stack = 1,

        -- Affected by:
        -- burning_blood[390213] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- burning_blood[390213] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- fiery_brand[207771] #1: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- havoc_demon_hunter[212612] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- havoc_demon_hunter[212612] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- havoc_demon_hunter[212612] #11: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- havoc_demon_hunter[212612] #12: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
    },
    -- Agility increased by $w1%.
    monster_rising = {
        id = 452550,
        duration = 3600,
        max_stack = 1,
    },
    -- Damage taken reduced by $w1%.
    painbringer = {
        id = 212988,
        duration = 6.0,
        max_stack = 1,

        -- Affected by:
        -- painbringer[207387] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER_BY_LABEL, 'points': -1.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_1_VALUE, }
    },
    -- $w3
    pursuit_of_angriness = {
        id = 452404,
        duration = 0.0,
        tick_time = 1.0,
        max_stack = 1,
    },
    -- Gliding.
    rain_from_above = {
        id = 206804,
        duration = 10.0,
        max_stack = 1,
    },
    -- Absorbs $w1 damage.
    revel_in_pain = {
        id = 343013,
        duration = 15.0,
        max_stack = 1,
    },
    -- Absorbs $w1 damage.
    ruinous_bulwark = {
        id = 326863,
        duration = 10.0,
        max_stack = 1,
    },
    -- Taking $w1 Fire damage every $t1 sec.
    set_fire_to_the_pain = {
        id = 453286,
        duration = 6.0,
        tick_time = 1.0,
        max_stack = 1,
    },
    -- Movement slowed by $s1%.
    sigil_of_chains = {
        id = 204843,
        duration = 6.0,
        max_stack = 1,

        -- Affected by:
        -- precise_sigils[389799] #4: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
        -- chains_of_anger[389715] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': RADIUS, }
        -- chains_of_anger[389715] #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'pvp_multiplier': 0.5, 'points': 2000.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
        -- any_means_necessary[388114] #0: { 'type': APPLY_AURA, 'subtype': MOD_ABILITY_SCHOOL_MASK, 'value': 127, 'schools': ['physical', 'holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], 'target': TARGET_UNIT_CASTER, }
        -- any_means_necessary[388114] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 1.8, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- any_means_necessary[388114] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 1.8, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
    },
    -- Sigil of Flame is active.
    sigil_of_flame = {
        id = 204596,
        duration = 2.0,
        max_stack = 1,

        -- Affected by:
        -- vengeance_demon_hunter[212613] #2: { 'type': APPLY_AURA, 'subtype': MOD_GLOBAL_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'target': TARGET_UNIT_CASTER, }
        -- quickened_sigils[209281] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -1000.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
        -- chains_of_anger[389715] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': RADIUS, }
        -- illuminated_sigils[428557] #0: { 'type': APPLY_AURA, 'subtype': MOD_MAX_CHARGES, 'points': 1.0, 'target': TARGET_UNIT_CASTER, }
        -- sigil_mastery[211489] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -25.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
        -- any_means_necessary[388114] #0: { 'type': APPLY_AURA, 'subtype': MOD_ABILITY_SCHOOL_MASK, 'value': 127, 'schools': ['physical', 'holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], 'target': TARGET_UNIT_CASTER, }
        -- havoc_demon_hunter[212612] #2: { 'type': APPLY_AURA, 'subtype': MOD_GLOBAL_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'target': TARGET_UNIT_CASTER, }
    },
    -- Disoriented.
    sigil_of_misery = {
        id = 207685,
        duration = 15.0,
        max_stack = 1,

        -- Affected by:
        -- precise_sigils[389799] #4: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
        -- chains_of_anger[389715] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': RADIUS, }
        -- chains_of_anger[389715] #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'pvp_multiplier': 0.5, 'points': 2000.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
        -- any_means_necessary[388114] #0: { 'type': APPLY_AURA, 'subtype': MOD_ABILITY_SCHOOL_MASK, 'value': 127, 'schools': ['physical', 'holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], 'target': TARGET_UNIT_CASTER, }
        -- any_means_necessary[388114] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 1.8, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- any_means_necessary[388114] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 1.8, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
    },
    -- Silenced.
    sigil_of_silence = {
        id = 204490,
        duration = 4.0,
        max_stack = 1,

        -- Affected by:
        -- precise_sigils[389799] #4: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
        -- chains_of_anger[389715] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': RADIUS, }
        -- chains_of_anger[389715] #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'pvp_multiplier': 0.5, 'points': 2000.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
        -- any_means_necessary[388114] #0: { 'type': APPLY_AURA, 'subtype': MOD_ABILITY_SCHOOL_MASK, 'value': 127, 'schools': ['physical', 'holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], 'target': TARGET_UNIT_CASTER, }
        -- any_means_necessary[388114] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 1.8, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- any_means_necessary[388114] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 1.8, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
    },
    -- Absorbs $w1 damage.
    soul_barrier = {
        id = 263648,
        duration = 15.0,
        max_stack = 1,
    },
    -- Suffering $s1 Fire damage every $t1 sec.
    soul_carver = {
        id = 207407,
        duration = 3.0,
        tick_time = 1.0,
        max_stack = 1,

        -- Affected by:
        -- vengeance_demon_hunter[212613] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- vengeance_demon_hunter[212613] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- burning_blood[390213] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- burning_blood[390213] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- frailty[247456] #3: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'points': 2.0, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- any_means_necessary[388114] #0: { 'type': APPLY_AURA, 'subtype': MOD_ABILITY_SCHOOL_MASK, 'value': 127, 'schools': ['physical', 'holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], 'target': TARGET_UNIT_CASTER, }
        -- fiery_brand[207771] #1: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'target': TARGET_UNIT_TARGET_ENEMY, }
    },
    -- Consume to heal for $203794s2% of your maximum health.
    soul_fragment = {
        id = 204255,
        duration = 20.0,
        max_stack = 1,
    },
    -- The damage of your next Soul Cleave or Spirit Bomb is increased by $w1%.
    soul_furnace = {
        id = 391172,
        duration = 30.0,
        max_stack = 1,
    },
    -- Can see invisible and stealthed enemies.; Can see enemies and treasures through physical barriers.
    spectral_sight = {
        id = 188501,
        duration = 10.0,
        max_stack = 1,

        -- Affected by:
        -- vengeance_demon_hunter[212613] #2: { 'type': APPLY_AURA, 'subtype': MOD_GLOBAL_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'target': TARGET_UNIT_CASTER, }
        -- spectral_sight[320379] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -30000.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
        -- havoc_demon_hunter[212612] #2: { 'type': APPLY_AURA, 'subtype': MOD_GLOBAL_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'target': TARGET_UNIT_CASTER, }
    },
    -- Mastery increased by ${$w1*$mas}.1%. ; Generating $453236s1 Fury every $t2 sec.
    student_of_suffering = {
        id = 453239,
        duration = 8.0,
        max_stack = 1,
    },
    -- Stunned.
    the_hunt = {
        id = 333762,
        duration = 3.0,
        max_stack = 1,
    },
    -- Attack Speed increased by $w1%
    thrill_of_the_fight = {
        id = 442695,
        duration = 20.0,
        max_stack = 1,
    },
    -- Taunted.
    torment = {
        id = 185245,
        duration = 3.0,
        max_stack = 1,
    },
    -- You have recently benefited from Last Resort and cannot benefit from it again.
    uncontained_fel = {
        id = 209261,
        duration = 480.0,
        max_stack = 1,
    },
    -- Movement speed reduced by $s1%.
    vengeful_retreat = {
        id = 198813,
        duration = 3.0,
        max_stack = 1,

        -- Affected by:
        -- vengeance_demon_hunter[212613] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- vengeance_demon_hunter[212613] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- evasive_action[444929] #0: { 'type': APPLY_AURA, 'subtype': IGNORE_SPELL_COOLDOWN, 'target': TARGET_UNIT_CASTER, }
        -- frailty[247456] #3: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'points': 2.0, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- havoc_demon_hunter[212612] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- havoc_demon_hunter[212612] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- havoc_demon_hunter[212612] #11: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- havoc_demon_hunter[212612] #12: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
    },
    -- Your next $?a212612[Chaos Strike]?s263642[Fracture][Shear] will deal $442507s1 additional Physical damage.
    warblades_hunger = {
        id = 442503,
        duration = 30.0,
        max_stack = 1,
    },
} )

-- Abilities
spec:RegisterAbilities( {
    -- Demolish the spirit of all those around you, dealing $s1 Fire damage to nearby enemies and extracting up to $s2 Lesser Soul Fragments, drawing them to you for immediate consumption.
    bulk_extraction = {
        id = 320341,
        cast = 0.0,
        cooldown = 60.0,
        gcd = "global",

        talent = "bulk_extraction",
        startsCombat = true,

        -- Effects:
        -- #0: { 'type': SCHOOL_DAMAGE, 'subtype': NONE, 'ap_bonus': 0.322, 'variance': 0.05, 'radius': 8.0, 'target': TARGET_DEST_CASTER, 'target2': TARGET_UNIT_DEST_AREA_ENEMY, }
        -- #1: { 'type': DUMMY, 'subtype': NONE, 'target': TARGET_UNIT_CASTER, }
    },

    -- Unleash an eruption of fel energy, dealing $s2 Chaos damage and stunning all nearby enemies for $d.$?s320412[; Each enemy stunned by Chaos Nova has a $s3% chance to generate a Lesser Soul Fragment.][]
    chaos_nova = {
        id = 179057,
        cast = 0.0,
        cooldown = 45.0,
        gcd = "global",

        spend = 25,
        spendType = 'fury',

        talent = "chaos_nova",
        startsCombat = true,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': MOD_STUN, 'mechanic': stunned, 'radius': 8.0, 'target': TARGET_DEST_CASTER, 'target2': TARGET_UNIT_DEST_AREA_ENEMY, }
        -- #1: { 'type': SCHOOL_DAMAGE, 'subtype': NONE, 'ap_bonus': 0.2432, 'variance': 0.05, 'radius': 8.0, 'target': TARGET_DEST_CASTER, 'target2': TARGET_UNIT_DEST_AREA_ENEMY, }
        -- #2: { 'type': DUMMY, 'subtype': NONE, 'radius': 8.0, 'target': TARGET_DEST_CASTER, 'target2': TARGET_UNIT_DEST_AREA_ENEMY, }

        -- Affected by:
        -- vengeance_demon_hunter[212613] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- vengeance_demon_hunter[212613] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- vengeance_demon_hunter[212613] #2: { 'type': APPLY_AURA, 'subtype': MOD_GLOBAL_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'target': TARGET_UNIT_CASTER, }
        -- burning_blood[390213] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- burning_blood[390213] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- frailty[247456] #3: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'points': 2.0, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- fiery_brand[207771] #1: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- havoc_demon_hunter[212612] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- havoc_demon_hunter[212612] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- havoc_demon_hunter[212612] #2: { 'type': APPLY_AURA, 'subtype': MOD_GLOBAL_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'target': TARGET_UNIT_CASTER, }
        -- havoc_demon_hunter[212612] #11: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- havoc_demon_hunter[212612] #12: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
    },

    -- [162794] Slice your target for ${$222031s1+$199547s1} Chaos damage. Chaos Strike has a ${$min($197125h,100)}% chance to refund $193840s1 Fury.
    chaos_strike = {
        id = 344862,
        cast = 0.0,
        cooldown = 0.0,
        gcd = "global",

        spend = 40,
        spendType = 'fury',

        startsCombat = true,

        -- Effects:
        -- #0: { 'type': DUMMY, 'subtype': NONE, 'chain_targets': 1, 'target': TARGET_UNIT_TARGET_ENEMY, }
    },

    -- Consume $m1 beneficial Magic effect removing it from the target$?s320313[ and granting you $s2 Fury][].
    consume_magic = {
        id = 278326,
        cast = 0.0,
        cooldown = 10.0,
        gcd = "global",

        talent = "consume_magic",
        startsCombat = true,

        -- Effects:
        -- #0: { 'type': DISPEL, 'subtype': NONE, 'points': 1.0, 'value': 1, 'schools': ['physical'], 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #1: { 'type': ENERGIZE, 'subtype': NONE, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'resource': fury, }
        -- #2: { 'type': DISPEL, 'subtype': NONE, 'points': 1.0, 'value': 1, 'schools': ['physical'], 'radius': 8.0, 'target': TARGET_DEST_TARGET_ENEMY, 'target2': TARGET_UNIT_DEST_AREA_ENEMY, }
    },

    -- Summons darkness around you in a$?a357419[ 12 yd][n 8 yd] radius, granting friendly targets a $209426s2% chance to avoid all damage from an attack. Lasts $d.; Chance to avoid damage increased by $s3% when not in a raid.
    darkness = {
        id = 196718,
        cast = 0.0,
        cooldown = 300.0,
        gcd = "global",

        talent = "darkness",
        startsCombat = false,

        -- Effects:
        -- #0: { 'type': CREATE_AREATRIGGER, 'subtype': NONE, 'value': 6615, 'schools': ['physical', 'holy', 'fire', 'frost', 'arcane'], 'target': TARGET_DEST_CASTER_GROUND, }
        -- #1: { 'type': APPLY_AURA, 'subtype': DUMMY, 'target': TARGET_UNIT_CASTER, }
        -- #2: { 'type': APPLY_AURA, 'subtype': DUMMY, 'points': 100.0, 'target': TARGET_UNIT_CASTER, }

        -- Affected by:
        -- vengeance_demon_hunter[212613] #2: { 'type': APPLY_AURA, 'subtype': MOD_GLOBAL_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'target': TARGET_UNIT_CASTER, }
        -- long_night[389781] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 3000.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
        -- pitch_black[389783] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -120000.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
        -- cover_of_darkness[357419] #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 2000.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
        -- havoc_demon_hunter[212612] #2: { 'type': APPLY_AURA, 'subtype': MOD_GLOBAL_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'target': TARGET_UNIT_CASTER, }
    },

    -- [203555] Your auto attacks deal an additional $203796s1 $@spelldesc395041 damage and generate $203796m2-$203796M2 Fury.
    demon_blades = {
        id = 203796,
        cast = 0.0,
        cooldown = 0.0,
        gcd = "global",

        startsCombat = true,

        -- Effects:
        -- #0: { 'type': SCHOOL_DAMAGE, 'subtype': NONE, 'ap_bonus': 0.149325, 'variance': 0.05, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #1: { 'type': ENERGIZE, 'subtype': NONE, 'variance': 0.5263158, 'points': 9.5, 'target': TARGET_UNIT_CASTER, 'resource': fury, }

        -- Affected by:
        -- vengeance_demon_hunter[212613] #2: { 'type': APPLY_AURA, 'subtype': MOD_GLOBAL_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'target': TARGET_UNIT_CASTER, }
        -- metamorphosis[162264] #9: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_2_VALUE, }
        -- any_means_necessary[388114] #0: { 'type': APPLY_AURA, 'subtype': MOD_ABILITY_SCHOOL_MASK, 'value': 127, 'schools': ['physical', 'holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], 'target': TARGET_UNIT_CASTER, }
        -- any_means_necessary[388114] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 1.8, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- any_means_necessary[388114] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 1.8, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- havoc_demon_hunter[212612] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- havoc_demon_hunter[212612] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- havoc_demon_hunter[212612] #2: { 'type': APPLY_AURA, 'subtype': MOD_GLOBAL_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'target': TARGET_UNIT_CASTER, }
        -- havoc_demon_hunter[212612] #11: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- havoc_demon_hunter[212612] #12: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
    },

    -- Surge with fel power, increasing your Armor by ${$203819s2*$AGI/100}$?s321028[, and your Parry chance by $203819s1%, for $203819d][].
    demon_spikes = {
        id = 203720,
        cast = 0.0,
        cooldown = 1.5,
        gcd = "none",

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': DUMMY, 'subtype': NONE, 'target': TARGET_UNIT_CASTER, }
    },

    -- Transform to demon form, moving at $m3% increased speed for $d, knocking down all enemies in your path and dealing $208645m1 Physical damage.; During Demonic Trample you are unaffected by snares but cannot cast spells or use your normal attacks. Shares charges with Infernal Strike.
    demonic_trample = {
        id = 205629,
        color = 'pvp_talent',
        cast = 0.0,
        cooldown = 0.8,
        gcd = "global",

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': FORCE_MOVE_FORWARD, 'points': 1.0, 'target': TARGET_UNIT_CASTER, }
        -- #1: { 'type': APPLY_AURA, 'subtype': AREA_TRIGGER, 'value': 6482, 'schools': ['holy', 'frost', 'arcane'], 'target': TARGET_UNIT_CASTER, }
        -- #2: { 'type': APPLY_AURA, 'subtype': MOD_SPEED_NOT_STACK, 'points': 175.0, 'target': TARGET_UNIT_CASTER, }
        -- #3: { 'type': APPLY_AURA, 'subtype': MOD_MINIMUM_SPEED, 'points': 275.0, 'target': TARGET_UNIT_CASTER, }
        -- #4: { 'type': APPLY_AURA, 'subtype': ALLOW_ONLY_ABILITY, 'points': 1.0, 'target': TARGET_UNIT_CASTER, }
        -- #5: { 'type': APPLY_AURA, 'subtype': UNKNOWN, 'points': 1.0, 'target': TARGET_UNIT_CASTER, }
        -- #6: { 'type': APPLY_AURA, 'subtype': TRANSFORM, 'value': 104712, 'schools': ['nature'], 'value1': 6, 'target': TARGET_UNIT_CASTER, }

        -- Affected by:
        -- blazing_path[320416] #1: { 'type': APPLY_AURA, 'subtype': MOD_MAX_CHARGES, 'points': 1.0, 'target': TARGET_UNIT_CASTER, }
    },

    -- [162243] Quickly attack for $s2 Physical damage.; Generates $?a258876[${$m3+$258876s3} to ${$M3+$258876s4}][$m3 to $M3] Fury.
    demons_bite = {
        id = 344859,
        cast = 0.0,
        cooldown = 0.0,
        gcd = "global",

        startsCombat = true,

        -- Effects:
        -- #0: { 'type': TRIGGER_SPELL, 'subtype': NONE, 'trigger_spell': 162243, 'target': TARGET_UNIT_TARGET_ENEMY, }

        -- Affected by:
        -- metamorphosis[162264] #10: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_3_VALUE, }
        -- insatiable_hunger[258876] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'ap_bonus': 0.1, 'points': 50.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
    },

    -- Quickly attack for $s2 Physical damage.; Generates $?a258876[${$m3+$258876s3} to ${$M3+$258876s4}][$m3 to $M3] Fury.
    demons_bite_162243 = {
        id = 162243,
        cast = 0.0,
        cooldown = 0.0,
        gcd = "global",

        startsCombat = true,

        -- Effects:
        -- #0: { 'type': DUMMY, 'subtype': NONE, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #1: { 'type': SCHOOL_DAMAGE, 'subtype': NONE, 'ap_bonus': 0.845132, 'variance': 0.05, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #2: { 'type': ENERGIZE, 'subtype': NONE, 'variance': 0.4, 'points': 25.0, 'target': TARGET_UNIT_CASTER, 'resource': fury, }

        -- Affected by:
        -- vengeance_demon_hunter[212613] #2: { 'type': APPLY_AURA, 'subtype': MOD_GLOBAL_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'target': TARGET_UNIT_CASTER, }
        -- metamorphosis[162264] #10: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_3_VALUE, }
        -- insatiable_hunger[258876] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'ap_bonus': 0.1, 'points': 50.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- havoc_demon_hunter[212612] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- havoc_demon_hunter[212612] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- havoc_demon_hunter[212612] #2: { 'type': APPLY_AURA, 'subtype': MOD_GLOBAL_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'target': TARGET_UNIT_CASTER, }
        -- havoc_demon_hunter[212612] #11: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- havoc_demon_hunter[212612] #12: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        from = "triggered_spell",
    },

    -- Interrupts the enemy's spellcasting and locks them from that school of magic for $d.$?s183782[; Generates $218903s1 Fury on a successful interrupt.][]
    disrupt = {
        id = 183752,
        cast = 0.0,
        cooldown = 15.0,
        gcd = "none",

        startsCombat = true,
        interrupt = true,

        -- Effects:
        -- #0: { 'type': INTERRUPT_CAST, 'subtype': NONE, 'mechanic': interrupted, 'target': TARGET_UNIT_TARGET_ENEMY, }

        -- Affected by:
        -- improved_disrupt[320361] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': RANGE, }
        -- burning_blood[390213] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- burning_blood[390213] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- any_means_necessary[388114] #0: { 'type': APPLY_AURA, 'subtype': MOD_ABILITY_SCHOOL_MASK, 'value': 127, 'schools': ['physical', 'holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], 'target': TARGET_UNIT_CASTER, }
        -- fiery_brand[207771] #1: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'target': TARGET_UNIT_TARGET_ENEMY, }
    },

    -- Unleash the fel within you, damaging enemies directly in front of you for ${$212105s1*(2/$t1)} Fire damage over $d.$?s320639[ Causing damage also heals you for up to ${$212106s1*(2/$t1)} health.][]
    fel_devastation = {
        id = 212084,
        cast = 2.0,
        channeled = true,
        cooldown = 40.0,
        gcd = "global",

        spend = 50,
        spendType = 'fury',

        talent = "fel_devastation",
        startsCombat = false,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': PERIODIC_TRIGGER_SPELL, 'tick_time': 0.2, 'trigger_spell': 212105, 'target': TARGET_UNIT_CASTER, }
        -- #1: { 'type': APPLY_AURA, 'subtype': MOD_DECREASE_SPEED, 'points': -200.0, 'target': TARGET_UNIT_CASTER, }
        -- #2: { 'type': APPLY_AURA, 'subtype': DUMMY, 'target': TARGET_UNIT_CASTER, }
        -- #3: { 'type': APPLY_AURA, 'subtype': MECHANIC_IMMUNITY, 'target': TARGET_UNIT_CASTER, 'mechanic': 26, }
    },

    -- [195072] Rush forward, incinerating anything in your path for $192611s1 Chaos damage.
    fel_rush = {
        id = 344865,
        cast = 0.0,
        cooldown = 1.0,
        gcd = "global",

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': TRIGGER_SPELL, 'subtype': NONE, 'trigger_spell': 195072, 'target': TARGET_UNIT_CASTER, }

        -- Affected by:
        -- blazing_path[320416] #0: { 'type': APPLY_AURA, 'subtype': MOD_MAX_CHARGES, 'points': 1.0, 'target': TARGET_UNIT_CASTER, }
    },

    -- Rush forward, incinerating anything in your path for $192611s1 Chaos damage.
    fel_rush_195072 = {
        id = 195072,
        cast = 0.0,
        cooldown = 0.5,
        gcd = "global",

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': DUMMY, 'subtype': NONE, 'target': TARGET_UNIT_CASTER, }
        -- #1: { 'type': DUMMY, 'subtype': NONE, 'target': TARGET_UNIT_CASTER, }

        -- Affected by:
        -- blazing_path[320416] #0: { 'type': APPLY_AURA, 'subtype': MOD_MAX_CHARGES, 'points': 1.0, 'target': TARGET_UNIT_CASTER, }
        from = "triggered_spell",
    },

    -- [395020] $?a388114[Chaos][Fire]
    felblade = {
        id = 232893,
        cast = 0.0,
        cooldown = 15.0,
        gcd = "global",

        talent = "felblade",
        startsCombat = true,

        -- Effects:
        -- #0: { 'type': DUMMY, 'subtype': NONE, 'target': TARGET_UNIT_TARGET_ENEMY, }

        -- Affected by:
        -- vengeance_demon_hunter[212613] #3: { 'type': APPLY_AURA, 'subtype': MOD_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'target': TARGET_UNIT_CASTER, }
        -- vengeance_demon_hunter[212613] #6: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -35.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- any_means_necessary[388114] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 1.8, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- any_means_necessary[388114] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 1.8, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- havoc_demon_hunter[212612] #3: { 'type': APPLY_AURA, 'subtype': MOD_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'target': TARGET_UNIT_CASTER, }
    },

    -- Brand an enemy with a demonic symbol, instantly dealing $s2 Fire damage$?s320962[ and ${$207771s5*$207771d} Fire damage over $207771d][]. The enemy's damage done to you is reduced by $s1% for $207744d.
    fiery_brand = {
        id = 204021,
        cast = 0.0,
        cooldown = 0.0,
        gcd = "global",

        talent = "fiery_brand",
        startsCombat = true,

        -- Effects:
        -- #0: { 'type': DUMMY, 'subtype': NONE, 'target': TARGET_UNIT_CASTER, }
        -- #1: { 'type': SCHOOL_DAMAGE, 'subtype': NONE, 'ap_bonus': 2.08, 'variance': 0.05, 'target': TARGET_UNIT_TARGET_ENEMY, }

        -- Affected by:
        -- vengeance_demon_hunter[212613] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- vengeance_demon_hunter[212613] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- vengeance_demon_hunter[212613] #2: { 'type': APPLY_AURA, 'subtype': MOD_GLOBAL_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'target': TARGET_UNIT_CASTER, }
        -- burning_blood[390213] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- burning_blood[390213] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- down_in_flames[389732] #1: { 'type': APPLY_AURA, 'subtype': MOD_MAX_CHARGES, 'points': 1.0, 'target': TARGET_UNIT_CASTER, }
        -- frailty[247456] #3: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'points': 2.0, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- any_means_necessary[388114] #0: { 'type': APPLY_AURA, 'subtype': MOD_ABILITY_SCHOOL_MASK, 'value': 127, 'schools': ['physical', 'holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], 'target': TARGET_UNIT_CASTER, }
        -- fiery_brand[207771] #1: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- havoc_demon_hunter[212612] #2: { 'type': APPLY_AURA, 'subtype': MOD_GLOBAL_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'target': TARGET_UNIT_CASTER, }
    },

    -- [350570] Your damaging abilities have a chance to call forth a demon from the Theater of Pain for $329554d. Throw Glaive deals lethal damage to the demon, which explodes on death, dealing $350631s1 $@spelldesc395041 damage to nearby enemies and healing you for $350631s2% of your maximum health. The explosion deals reduced damage beyond 5 targets.
    fodder_to_the_flame = {
        id = 329554,
        color = 'necrolord',
        cast = 0.0,
        cooldown = 120.0,
        gcd = "global",

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': DUMMY, 'target': TARGET_UNIT_CASTER, }
        -- #1: { 'type': TRIGGER_SPELL, 'subtype': NONE, 'trigger_spell': 342357, 'points': 1.0, 'target': TARGET_UNIT_CASTER, }
    },

    -- Rapidly slash your target for ${$225919sw1+$225921sw1} Physical damage, and shatter $s1 Lesser Soul Fragments from them.; Generates $s4 Fury.
    fracture = {
        id = 263642,
        cast = 0.0,
        cooldown = 0.0,
        gcd = "global",

        talent = "fracture",
        startsCombat = true,

        -- Effects:
        -- #0: { 'type': DUMMY, 'subtype': NONE, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #1: { 'type': TRIGGER_SPELL, 'subtype': NONE, 'trigger_spell': 225919, }
        -- #2: { 'type': TRIGGER_SPELL, 'subtype': NONE, 'trigger_spell': 225921, 'value': 150, 'schools': ['holy', 'fire', 'frost'], }
        -- #3: { 'type': ENERGIZE, 'subtype': NONE, 'points': 25.0, 'target': TARGET_UNIT_CASTER, 'resource': fury, }

        -- Affected by:
        -- metamorphosis[187827] #8: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 1.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_1_VALUE, }
        -- metamorphosis[187827] #9: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_4_VALUE, }
    },

    -- Throws two demonic glaives in a whirlwind of energy, causing ${7*($201628sw1+$201789sw1)} Chaos damage over $d to all nearby enemies.
    fury_of_the_illidari = {
        id = 201467,
        color = 'artifact',
        cast = 0.0,
        cooldown = 60.0,
        gcd = "global",

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': CREATE_AREATRIGGER, 'subtype': NONE, 'value': 5758, 'schools': ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], 'target': TARGET_DEST_CASTER, }
    },

    -- Reduces your falling speed.; You can activate this ability with the jump key while falling.
    glide = {
        id = 131347,
        cast = 0.0,
        cooldown = 1.0,
        gcd = "none",

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': FEATHER_FALL, 'target': TARGET_UNIT_CASTER, }
        -- #1: { 'type': APPLY_AURA, 'subtype': CAN_TURN_WHILE_FALLING, 'target': TARGET_UNIT_CASTER, }
        -- #2: { 'type': APPLY_AURA, 'subtype': OBS_MOD_HEALTH, 'tick_time': 0.333, 'target': TARGET_UNIT_CASTER, }
    },

    -- You strangle the target with demonic magic, stunning them in place and dealing $o4 Shadow damage over $d while the target is grasped. Can move while channeling.; Use Illidan's Grasp again to toss the target to a location within $208173R yards, stunning them and all nearby enemies for $208618d and dealing $208618s1 Shadow damage.
    illidans_grasp = {
        id = 205630,
        color = 'pvp_talent',
        cast = 5.0,
        channeled = true,
        cooldown = 60.0,
        gcd = "global",

        startsCombat = true,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': MOD_STUN, 'mechanic': stunned, 'points': 100.0, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #1: { 'type': APPLY_AURA, 'subtype': OVERRIDE_ACTIONBAR_SPELLS, 'spell': 208173, 'value': 205630, 'schools': ['holy', 'fire', 'nature', 'frost', 'shadow'], 'target': TARGET_UNIT_CASTER, }
        -- #2: { 'type': APPLY_AURA, 'subtype': TRANSFORM, 'value': 104712, 'schools': ['nature'], 'value1': 6, 'target': TARGET_UNIT_CASTER, }
        -- #3: { 'type': APPLY_AURA, 'subtype': PERIODIC_DAMAGE, 'tick_time': 1.0, 'ap_bonus': 1.4, 'target': TARGET_UNIT_TARGET_ENEMY, }
    },

    -- Throw the target to a location within $R yards, stunning them and all nearby enemies for $208618d and dealing $208618m1 Shadow damage.
    illidans_grasp_throw = {
        id = 208173,
        color = 'pvp_talent',
        cast = 0.0,
        cooldown = 0.0,
        gcd = "global",

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': DUMMY, 'subtype': NONE, 'radius': 2.0, 'target': TARGET_DEST_DEST_GROUND, }
    },

    -- [395020] $?a388114[Chaos][Fire]
    immolation_aura = {
        id = 258920,
        cast = 0.0,
        cooldown = 1.5,
        gcd = "global",

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': PERIODIC_TRIGGER_SPELL, 'tick_time': 1.0, 'trigger_spell': 258922, 'target': TARGET_UNIT_CASTER, }
        -- #1: { 'type': ENERGIZE, 'subtype': NONE, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'resource': fury, }
        -- #2: { 'type': ENERGIZE, 'subtype': NONE, 'points': 8.0, 'target': TARGET_UNIT_CASTER, 'resource': fury, }
        -- #3: { 'type': APPLY_AURA, 'subtype': MOD_SPEED_ALWAYS, 'target': TARGET_UNIT_CASTER, }
        -- #4: { 'type': APPLY_AURA, 'subtype': MOD_RESISTANCE_PCT, 'value': 1, 'schools': ['physical'], 'target': TARGET_UNIT_CASTER, }
        -- #5: { 'type': APPLY_AURA, 'subtype': MOD_ABILITY_SCHOOL_MASK, 'value': 4, 'schools': ['fire'], 'target': TARGET_UNIT_CASTER, }

        -- Affected by:
        -- vengeance_demon_hunter[212613] #3: { 'type': APPLY_AURA, 'subtype': MOD_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'target': TARGET_UNIT_CASTER, }
        -- infernal_armor[320331] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_5_VALUE, }
        -- agonizing_flames[207548] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_4_VALUE, }
        -- agonizing_flames[207548] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 50.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
        -- havoc_demon_hunter[212612] #3: { 'type': APPLY_AURA, 'subtype': MOD_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'target': TARGET_UNIT_CASTER, }
    },

    -- Imprisons a demon, beast, or humanoid, incapacitating them for $d. Damage will cancel the effect. Limit 1.
    imprison = {
        id = 217832,
        cast = 0.0,
        cooldown = 45.0,
        gcd = "global",

        talent = "imprison",
        startsCombat = true,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': MOD_STUN, 'points': 1.0, 'target': TARGET_UNIT_TARGET_ENEMY, }

        -- Affected by:
        -- detainment[205596] #0: { 'type': APPLY_AURA, 'subtype': OVERRIDE_ACTIONBAR_SPELLS, 'spell': 221527, 'target': TARGET_UNIT_CASTER, }
        -- detainment[205596] #3: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
    },

    -- Leap through the air toward a targeted location, dealing $189112s1 Fire damage to all enemies within $189112a1 yards.
    infernal_strike = {
        id = 189110,
        cast = 0.0,
        cooldown = 0.8,
        gcd = "none",

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': DUMMY, 'subtype': NONE, 'variance': 1.0, 'radius': 3.0, 'target': TARGET_DEST_DEST, }
        -- #1: { 'type': UNKNOWN, 'subtype': NONE, 'points': 5.0, 'value': 2, 'schools': ['holy'], 'target': TARGET_DEST_DEST, }

        -- Affected by:
        -- blazing_path[320416] #1: { 'type': APPLY_AURA, 'subtype': MOD_MAX_CHARGES, 'points': 1.0, 'target': TARGET_UNIT_CASTER, }
    },

    -- Transform to demon form for $d, increasing current and maximum health by $s2% and Armor by $s8%$?s235893[. Versatility increased by $s5%][]$?s321067[. While transformed, Shear and Fracture generate one additional Lesser Soul Fragment][]$?s321068[ and $s4 additional Fury][].
    metamorphosis = {
        id = 187827,
        cast = 0.0,
        cooldown = 20.0,
        gcd = "none",

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': TRANSFORM, 'sp_bonus': 0.25, 'value': 104712, 'schools': ['nature'], 'value1': 6, 'target': TARGET_UNIT_CASTER, }
        -- #1: { 'type': APPLY_AURA, 'subtype': MOD_INCREASE_HEALTH_PERCENT, 'points': 40.0, 'target': TARGET_UNIT_CASTER, }
        -- #2: { 'type': APPLY_AURA, 'subtype': MOD_LEECH, 'target': TARGET_UNIT_CASTER, }
        -- #3: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_2_VALUE, }
        -- #4: { 'type': APPLY_AURA, 'subtype': MOD_VERSATILITY, 'target': TARGET_UNIT_CASTER, }
        -- #5: { 'type': APPLY_AURA, 'subtype': ANIM_REPLACEMENT_SET, 'value': 536, 'schools': ['nature', 'frost'], 'target': TARGET_UNIT_CASTER, }
        -- #6: { 'type': APPLY_AURA, 'subtype': PERIODIC_DUMMY, 'tick_time': 2.0, }
        -- #7: { 'type': APPLY_AURA, 'subtype': MOD_BASE_RESISTANCE_PCT, 'points': 200.0, 'value': 1, 'schools': ['physical'], 'target': TARGET_UNIT_CASTER, }
        -- #8: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 1.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_1_VALUE, }
        -- #9: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_4_VALUE, }
        -- #10: { 'type': APPLY_AURA, 'subtype': TRANSFORM, 'sp_bonus': 0.25, 'value': 104712, 'schools': ['nature'], 'value1': 6, 'target': TARGET_UNIT_CASTER, }

        -- Affected by:
        -- metamorphosis[321068] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
        -- rush_of_chaos[320421] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -30000.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
        -- soul_rending[204909] #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 6.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_3_VALUE, }
    },

    -- Leap into the air and land with explosive force, dealing $200166s2 Chaos damage to enemies within 8 yds, and stunning them for $200166d. Players are Dazed for $247121d instead.; Upon landing, you are transformed into a hellish demon for $162264d, $?s320645[immediately resetting the cooldown of your Eye Beam and Blade Dance abilities, ][]greatly empowering your Chaos Strike and Blade Dance abilities and gaining $162264s4% Haste$?(s235893&s204909)[, $162264s5% Versatility, and $162264s3% Leech]?(s235893&!s204909[ and $162264s5% Versatility]?(s204909&!s235893)[ and $162264s3% Leech][].
    metamorphosis_191427 = {
        id = 191427,
        cast = 0.0,
        cooldown = 180.0,
        gcd = "global",

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': DUMMY, 'subtype': NONE, 'variance': 1.0, 'radius': 5.0, 'target': TARGET_DEST_DEST, }
        -- #1: { 'type': TRIGGER_SPELL, 'subtype': NONE, 'trigger_spell': 162264, 'target': TARGET_UNIT_CASTER, }
        -- #2: { 'type': UNKNOWN, 'subtype': NONE, 'points': 5.0, 'value': 9, 'schools': ['physical', 'nature'], 'target': TARGET_DEST_DEST, }
        -- #3: { 'type': TRIGGER_SPELL, 'subtype': NONE, 'trigger_spell': 201453, 'target': TARGET_UNIT_CASTER, }

        -- Affected by:
        -- vengeance_demon_hunter[212613] #2: { 'type': APPLY_AURA, 'subtype': MOD_GLOBAL_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'target': TARGET_UNIT_CASTER, }
        -- rush_of_chaos[320421] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -30000.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
        -- soul_rending[204909] #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 6.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_3_VALUE, }
        -- havoc_demon_hunter[212612] #2: { 'type': APPLY_AURA, 'subtype': MOD_GLOBAL_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'target': TARGET_UNIT_CASTER, }
        from = "class",
    },

    -- You fly into the air out of harm's way. While floating, you gain access to Fel Lance allowing you to deal damage to enemies below. 
    rain_from_above = {
        id = 206803,
        color = 'pvp_talent',
        cast = 0.0,
        cooldown = 60.0,
        gcd = "global",

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': KNOCK_BACK, 'subtype': NONE, 'points': 400.0, 'value': 5, 'schools': ['physical', 'fire'], 'target': TARGET_UNIT_CASTER, }
        -- #1: { 'type': APPLY_AURA, 'subtype': PERIODIC_TRIGGER_SPELL, 'tick_time': 1.0, 'trigger_spell': 206804, 'target': TARGET_UNIT_CASTER, }
        -- #2: { 'type': APPLY_AURA, 'subtype': TRANSFORM, 'value': 93467, 'schools': ['physical', 'holy', 'nature', 'frost'], 'value1': 9, 'target': TARGET_UNIT_CASTER, }
        -- #3: { 'type': TRIGGER_SPELL, 'subtype': NONE, 'attributes': ['No Immunity'], 'trigger_spell': 206959, 'value': 500, 'schools': ['fire', 'frost', 'shadow', 'arcane'], 'target': TARGET_UNIT_CASTER, }
        -- #4: { 'type': APPLY_AURA, 'subtype': MECHANIC_IMMUNITY, 'target': TARGET_UNIT_CASTER, 'mechanic': 7, }
        -- #5: { 'type': APPLY_AURA, 'subtype': MECHANIC_IMMUNITY, 'target': TARGET_UNIT_CASTER, 'mechanic': 12, }
        -- #6: { 'type': APPLY_AURA, 'subtype': DAMAGE_IMMUNITY, 'value': 127, 'schools': ['physical', 'holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], 'target': TARGET_UNIT_CASTER, }
        -- #7: { 'type': APPLY_AURA, 'subtype': MOD_PACIFY_SILENCE, 'value': 127, 'schools': ['physical', 'holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], 'target': TARGET_UNIT_CASTER, }
        -- #8: { 'type': APPLY_AURA, 'subtype': MECHANIC_IMMUNITY, 'target': TARGET_UNIT_CASTER, 'mechanic': 18, }
    },

    -- Removes all harmful magical effects from yourself and all nearby allies within $m1 yards, and sends them back to their original caster if possible.
    reverse_magic = {
        id = 205604,
        color = 'pvp_talent',
        cast = 0.0,
        cooldown = 60.0,
        gcd = "global",

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': SCRIPT_EFFECT, 'subtype': NONE, 'points': 10.0, 'radius': 10.0, 'target': TARGET_SRC_CASTER, 'target2': TARGET_UNIT_SRC_AREA_ALLY, }
    },

    -- Shears an enemy for $s1 Physical damage, and shatters $?a187827[two Lesser Soul Fragments][a Lesser Soul Fragment] from your target.; Generates $m2 Fury.
    shear = {
        id = 203782,
        cast = 0.0,
        cooldown = 0.0,
        gcd = "global",

        startsCombat = true,

        -- Effects:
        -- #0: { 'type': SCHOOL_DAMAGE, 'subtype': NONE, 'ap_bonus': 0.633, 'variance': 0.05, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #1: { 'type': ENERGIZE, 'subtype': NONE, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'resource': fury, }

        -- Affected by:
        -- metamorphosis[187827] #3: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_2_VALUE, }
        -- vengeance_demon_hunter[212613] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- vengeance_demon_hunter[212613] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- vengeance_demon_hunter[212613] #2: { 'type': APPLY_AURA, 'subtype': MOD_GLOBAL_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'target': TARGET_UNIT_CASTER, }
        -- vengeance_demon_hunter[212613] #3: { 'type': APPLY_AURA, 'subtype': MOD_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'target': TARGET_UNIT_CASTER, }
        -- vengeance_demon_hunter[212613] #8: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- shear_fury[389997] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_2_VALUE, }
        -- frailty[247456] #3: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'points': 2.0, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- havoc_demon_hunter[212612] #2: { 'type': APPLY_AURA, 'subtype': MOD_GLOBAL_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'target': TARGET_UNIT_CASTER, }
        -- havoc_demon_hunter[212612] #3: { 'type': APPLY_AURA, 'subtype': MOD_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'target': TARGET_UNIT_CASTER, }
    },

    -- Place a Sigil of Chains at the target location that activates after $d.; All enemies affected by the sigil are pulled to its center and are snared, reducing movement speed by $204843s1% for $204843d.
    sigil_of_chains = {
        id = 202138,
        cast = 0.0,
        cooldown = 0.0,
        gcd = "global",

        talent = "sigil_of_chains",
        startsCombat = false,

        -- Effects:
        -- #0: { 'type': DUMMY, 'subtype': NONE, 'radius': 8.0, 'target': TARGET_DEST_DEST, }
        -- #1: { 'type': CREATE_AREATRIGGER, 'subtype': NONE, 'value': 6031, 'schools': ['physical', 'holy', 'fire', 'nature'], 'target': TARGET_DEST_DEST, }

        -- Affected by:
        -- vengeance_demon_hunter[212613] #2: { 'type': APPLY_AURA, 'subtype': MOD_GLOBAL_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'target': TARGET_UNIT_CASTER, }
        -- quickened_sigils[209281] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -1000.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
        -- chains_of_anger[389715] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': RADIUS, }
        -- sigil_mastery[211489] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -25.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
        -- any_means_necessary[388114] #0: { 'type': APPLY_AURA, 'subtype': MOD_ABILITY_SCHOOL_MASK, 'value': 127, 'schools': ['physical', 'holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], 'target': TARGET_UNIT_CASTER, }
        -- havoc_demon_hunter[212612] #2: { 'type': APPLY_AURA, 'subtype': MOD_GLOBAL_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'target': TARGET_UNIT_CASTER, }
    },

    -- [395020] $?a388114[Chaos][Fire]
    sigil_of_flame = {
        id = 204596,
        cast = 0.0,
        cooldown = 0.0,
        gcd = "global",

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': DUMMY, 'subtype': NONE, 'radius': 8.0, 'target': TARGET_DEST_DEST, }
        -- #1: { 'type': CREATE_AREATRIGGER, 'subtype': NONE, 'value': 6039, 'schools': ['physical', 'holy', 'fire', 'frost'], 'target': TARGET_DEST_DEST, }

        -- Affected by:
        -- vengeance_demon_hunter[212613] #2: { 'type': APPLY_AURA, 'subtype': MOD_GLOBAL_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'target': TARGET_UNIT_CASTER, }
        -- quickened_sigils[209281] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -1000.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
        -- chains_of_anger[389715] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': RADIUS, }
        -- illuminated_sigils[428557] #0: { 'type': APPLY_AURA, 'subtype': MOD_MAX_CHARGES, 'points': 1.0, 'target': TARGET_UNIT_CASTER, }
        -- sigil_mastery[211489] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -25.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
        -- any_means_necessary[388114] #0: { 'type': APPLY_AURA, 'subtype': MOD_ABILITY_SCHOOL_MASK, 'value': 127, 'schools': ['physical', 'holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], 'target': TARGET_UNIT_CASTER, }
        -- havoc_demon_hunter[212612] #2: { 'type': APPLY_AURA, 'subtype': MOD_GLOBAL_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'target': TARGET_UNIT_CASTER, }
    },

    -- Place a Sigil of Misery at the target location that activates after $d.; Causes all enemies affected by the sigil to cower in fear, disorienting them for $207685d.
    sigil_of_misery = {
        id = 207684,
        cast = 0.0,
        cooldown = 0.0,
        gcd = "global",

        talent = "sigil_of_misery",
        startsCombat = false,

        -- Effects:
        -- #0: { 'type': DUMMY, 'subtype': NONE, 'radius': 8.0, 'target': TARGET_DEST_DEST, }
        -- #1: { 'type': CREATE_AREATRIGGER, 'subtype': NONE, 'value': 6351, 'schools': ['physical', 'holy', 'fire', 'nature', 'arcane'], 'target': TARGET_DEST_DEST, }

        -- Affected by:
        -- quickened_sigils[209281] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -1000.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
        -- chains_of_anger[389715] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': RADIUS, }
        -- sigil_mastery[211489] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -25.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
        -- any_means_necessary[388114] #0: { 'type': APPLY_AURA, 'subtype': MOD_ABILITY_SCHOOL_MASK, 'value': 127, 'schools': ['physical', 'holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], 'target': TARGET_UNIT_CASTER, }
    },

    -- Place a Sigil of Silence at the target location that activates after $d.; Silences all enemies affected by the sigil for $204490d.
    sigil_of_silence = {
        id = 202137,
        cast = 0.0,
        cooldown = 0.0,
        gcd = "global",

        talent = "sigil_of_silence",
        startsCombat = false,

        -- Effects:
        -- #0: { 'type': DUMMY, 'subtype': NONE, 'radius': 8.0, 'target': TARGET_DEST_DEST, }
        -- #1: { 'type': CREATE_AREATRIGGER, 'subtype': NONE, 'value': 6027, 'schools': ['physical', 'holy', 'nature'], 'target': TARGET_DEST_DEST, }

        -- Affected by:
        -- vengeance_demon_hunter[212613] #2: { 'type': APPLY_AURA, 'subtype': MOD_GLOBAL_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'target': TARGET_UNIT_CASTER, }
        -- quickened_sigils[209281] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -1000.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
        -- chains_of_anger[389715] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': RADIUS, }
        -- sigil_mastery[211489] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -25.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
        -- any_means_necessary[388114] #0: { 'type': APPLY_AURA, 'subtype': MOD_ABILITY_SCHOOL_MASK, 'value': 127, 'schools': ['physical', 'holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], 'target': TARGET_UNIT_CASTER, }
        -- havoc_demon_hunter[212612] #2: { 'type': APPLY_AURA, 'subtype': MOD_GLOBAL_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'target': TARGET_UNIT_CASTER, }
    },

    -- Place a demonic sigil at the target location that activates after $d.; Detonates to deal $389860s1 Chaos damage and shatter up to $s3 Lesser Soul Fragments from enemies affected by the sigil. Deals reduced damage beyond $s1 targets.
    sigil_of_spite = {
        id = 390163,
        cast = 0.0,
        cooldown = 0.0,
        gcd = "global",

        talent = "sigil_of_spite",
        startsCombat = false,

        -- Effects:
        -- #0: { 'type': DUMMY, 'subtype': NONE, 'radius': 8.0, 'target': TARGET_DEST_DEST, }
        -- #1: { 'type': CREATE_AREATRIGGER, 'subtype': NONE, 'points': 50.0, 'value': 26752, 'target': TARGET_DEST_DEST, }
        -- #2: { 'type': DUMMY, 'subtype': NONE, 'target': TARGET_DEST_DEST, }

        -- Affected by:
        -- quickened_sigils[209281] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -1000.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
        -- chains_of_anger[389715] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': RADIUS, }
        -- sigil_mastery[211489] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -25.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
    },

    -- Shield yourself for $d, absorbing $<baseAbsorb> damage.; Consumes all available Soul Fragments to add $<fragmentAbsorb> to the shield per fragment.
    soul_barrier = {
        id = 263648,
        cast = 0.0,
        cooldown = 30.0,
        gcd = "global",

        talent = "soul_barrier",
        startsCombat = false,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': SCHOOL_ABSORB, 'attributes': ['Aura Points Stack'], 'value': 127, 'schools': ['physical', 'holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], 'target': TARGET_UNIT_CASTER, }
        -- #1: { 'type': APPLY_AURA, 'subtype': DUMMY, 'points': 200.0, 'target': TARGET_UNIT_CASTER, }
    },

    -- Carve into the soul of your target, dealing ${$s2+$214743s1} Fire damage and an additional $o1 Fire damage over $d.  Immediately shatters $s3 Lesser Soul Fragments from the target and $s4 additional Lesser Soul Fragment every $t1 sec.
    soul_carver = {
        id = 207407,
        cast = 0.0,
        cooldown = 60.0,
        gcd = "global",

        talent = "soul_carver",
        startsCombat = true,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': PERIODIC_DAMAGE, 'tick_time': 1.0, 'ap_bonus': 0.447, 'variance': 0.05, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #1: { 'type': SCHOOL_DAMAGE, 'subtype': NONE, 'ap_bonus': 2.06, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #2: { 'type': TRIGGER_SPELL, 'subtype': NONE, 'trigger_spell': 214743, 'points': 3.0, }
        -- #3: { 'type': DUMMY, 'subtype': NONE, 'target': TARGET_UNIT_CASTER, }

        -- Affected by:
        -- vengeance_demon_hunter[212613] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- vengeance_demon_hunter[212613] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- burning_blood[390213] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- burning_blood[390213] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- frailty[247456] #3: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'points': 2.0, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- any_means_necessary[388114] #0: { 'type': APPLY_AURA, 'subtype': MOD_ABILITY_SCHOOL_MASK, 'value': 127, 'schools': ['physical', 'holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], 'target': TARGET_UNIT_CASTER, }
        -- fiery_brand[207771] #1: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'target': TARGET_UNIT_TARGET_ENEMY, }
    },

    -- [207407] Carve into the soul of your target, dealing ${$s2+$214743s1} Fire damage and an additional $o1 Fire damage over $d.  Immediately shatters $s3 Lesser Soul Fragments from the target and $s4 additional Lesser Soul Fragment every $t1 sec.
    soul_carver_214743 = {
        id = 214743,
        cast = 0.0,
        cooldown = 60.0,
        gcd = "global",

        startsCombat = true,

        -- Effects:
        -- #0: { 'type': SCHOOL_DAMAGE, 'subtype': NONE, 'ap_bonus': 2.06, 'target': TARGET_UNIT_TARGET_ENEMY, }

        -- Affected by:
        -- vengeance_demon_hunter[212613] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- vengeance_demon_hunter[212613] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- frailty[247456] #3: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'points': 2.0, 'target': TARGET_UNIT_TARGET_ENEMY, }
        from = "class",
    },

    -- Viciously strike up to $228478s2 enemies in front of you for $228478s1 Physical damage and heal yourself for $s4.; Consumes up to $s3 available Soul Fragments$?s321021[ and heals you for an additional $s5 for each Soul Fragment consumed][].
    soul_cleave = {
        id = 228477,
        cast = 0.0,
        cooldown = 0.0,
        gcd = "global",

        spend = 30,
        spendType = 'fury',

        startsCombat = true,

        -- Effects:
        -- #0: { 'type': DUMMY, 'subtype': NONE, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #1: { 'type': TRIGGER_SPELL, 'subtype': NONE, 'trigger_spell': 228478, 'value': 300, 'schools': ['fire', 'nature', 'shadow'], 'target': TARGET_UNIT_CASTER, }
        -- #2: { 'type': DUMMY, 'subtype': NONE, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #3: { 'type': HEAL, 'subtype': NONE, 'ap_bonus': 0.4, 'variance': 0.05, 'target': TARGET_UNIT_CASTER, }
        -- #4: { 'type': HEAL, 'subtype': NONE, 'ap_bonus': 0.4, 'variance': 0.05, 'target': TARGET_UNIT_CASTER, }

        -- Affected by:
        -- immolation_aura[258920] #5: { 'type': APPLY_AURA, 'subtype': MOD_ABILITY_SCHOOL_MASK, 'value': 4, 'schools': ['fire'], 'target': TARGET_UNIT_CASTER, }
    },

    -- Allows you to see enemies and treasures through physical barriers, as well as enemies that are stealthed and invisible. Lasts $d.; Attacking or taking damage disrupts the sight.
    spectral_sight = {
        id = 188501,
        cast = 0.0,
        cooldown = 30.0,
        gcd = "global",

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': TRIGGER_SPELL, 'subtype': NONE, 'trigger_spell': 202688, 'target': TARGET_UNIT_CASTER, }
        -- #1: { 'type': TRIGGER_SPELL, 'subtype': NONE, 'trigger_spell': 215725, 'target': TARGET_UNIT_CASTER, }
        -- #2: { 'type': APPLY_AURA, 'subtype': SCREEN_EFFECT, 'value': 1173, 'schools': ['physical', 'fire', 'frost'], 'value1': 7, 'target': TARGET_UNIT_CASTER, }
        -- #3: { 'type': APPLY_AURA, 'subtype': MOD_DECREASE_SPEED, 'points': -30.0, 'target': TARGET_UNIT_CASTER, }
        -- #4: { 'type': APPLY_AURA, 'subtype': ANIM_REPLACEMENT_SET, 'value': 499, 'schools': ['physical', 'holy', 'frost', 'shadow', 'arcane'], 'target': TARGET_UNIT_CASTER, }
        -- #5: { 'type': UPDATE_PLAYER_PHASE, 'subtype': NONE, 'target': TARGET_UNIT_CASTER, }

        -- Affected by:
        -- vengeance_demon_hunter[212613] #2: { 'type': APPLY_AURA, 'subtype': MOD_GLOBAL_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'target': TARGET_UNIT_CASTER, }
        -- spectral_sight[320379] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -30000.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
        -- havoc_demon_hunter[212612] #2: { 'type': APPLY_AURA, 'subtype': MOD_GLOBAL_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'target': TARGET_UNIT_CASTER, }
    },

    -- Consume up to $s2 available Soul Fragments then explode, damaging nearby enemies for $247455s1 Fire damage per fragment consumed, and afflicting them with Frailty for $247456d, causing you to heal for $247456s1% of damage you deal to them. Deals reduced damage beyond $s3 targets.
    spirit_bomb = {
        id = 247454,
        cast = 0.0,
        cooldown = 0.0,
        gcd = "global",

        spend = 40,
        spendType = 'fury',

        talent = "spirit_bomb",
        startsCombat = false,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': DUMMY, 'points': 25.0, 'target': TARGET_UNIT_CASTER, }
        -- #1: { 'type': APPLY_AURA, 'subtype': DUMMY, 'points': 5.0, 'target': TARGET_UNIT_CASTER, }
        -- #2: { 'type': APPLY_AURA, 'subtype': DUMMY, 'points': 8.0, 'target': TARGET_UNIT_CASTER, }
    },

    -- Charge to your target, striking them for $370966s1 Chaos damage, rooting them in place for $370970d and inflicting $370969o1 Chaos damage over $370969d to up to $370967s2 enemies in your path. ; The pursuit invigorates your soul, healing you for $?c1[$370968s1%][$370968s2%] of the damage you deal to your Hunt target for $370966d.
    the_hunt = {
        id = 370965,
        cast = 1.0,
        cooldown = 90.0,
        gcd = "global",

        talent = "the_hunt",
        startsCombat = true,

        -- Effects:
        -- #0: { 'type': CHARGE, 'subtype': NONE, 'amplitude': 2.0, 'trigger_spell': 370966, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #1: { 'type': TRIGGER_SPELL, 'subtype': NONE, 'trigger_spell': 370967, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #2: { 'type': TRIGGER_SPELL, 'subtype': NONE, 'trigger_spell': 370968, 'target': TARGET_UNIT_CASTER, }
        -- #3: { 'type': APPLY_AURA, 'subtype': DUMMY, 'target': TARGET_UNIT_CASTER, }
    },

    -- Throw a demonic glaive at the target, dealing $346665s1 Physical damage. The glaive can ricochet to $?$s320386[${$346665x1-1} additional enemies][an additional enemy] within 10 yards. Generates high threat.
    throw_glaive = {
        id = 204157,
        cast = 0.0,
        cooldown = 0.0,
        gcd = "global",

        startsCombat = true,
        interrupt = true,

        -- Effects:
        -- #0: { 'type': TRIGGER_SPELL, 'subtype': NONE, 'trigger_spell': 346665, 'target': TARGET_UNIT_TARGET_ENEMY, }

        -- Affected by:
        -- vengeance_demon_hunter[212613] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- vengeance_demon_hunter[212613] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- vengeance_demon_hunter[212613] #2: { 'type': APPLY_AURA, 'subtype': MOD_GLOBAL_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'target': TARGET_UNIT_CASTER, }
        -- vengeance_demon_hunter[212613] #3: { 'type': APPLY_AURA, 'subtype': MOD_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'target': TARGET_UNIT_CASTER, }
        -- bouncing_glaives[320386] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 1.0, 'target': TARGET_UNIT_CASTER, 'modifies': CHAINED_TARGETS, }
        -- champion_of_the_glaive[429211] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': RANGE, }
        -- champion_of_the_glaive[429211] #1: { 'type': APPLY_AURA, 'subtype': MOD_MAX_CHARGES, 'points': 1.0, 'target': TARGET_UNIT_CASTER, }
        -- master_of_the_glaive[389763] #1: { 'type': APPLY_AURA, 'subtype': MOD_MAX_CHARGES, 'points': 1.0, 'target': TARGET_UNIT_CASTER, }
        -- frailty[247456] #3: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'points': 2.0, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- havoc_demon_hunter[212612] #2: { 'type': APPLY_AURA, 'subtype': MOD_GLOBAL_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'target': TARGET_UNIT_CASTER, }
        -- havoc_demon_hunter[212612] #3: { 'type': APPLY_AURA, 'subtype': MOD_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'target': TARGET_UNIT_CASTER, }
    },

    -- Throw a demonic glaive at the target, dealing $337819s1 Physical damage. The glaive can ricochet to $?$s320386[${$337819x1-1} additional enemies][an additional enemy] within 10 yards.; 
    throw_glaive_185123 = {
        id = 185123,
        cast = 0.0,
        cooldown = 0.0,
        gcd = "global",

        spend = 25,
        spendType = 'fury',

        startsCombat = true,
        interrupt = true,

        -- Effects:
        -- #0: { 'type': TRIGGER_SPELL, 'subtype': NONE, 'trigger_spell': 337819, 'target': TARGET_UNIT_TARGET_ENEMY, }

        -- Affected by:
        -- vengeance_demon_hunter[212613] #2: { 'type': APPLY_AURA, 'subtype': MOD_GLOBAL_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'target': TARGET_UNIT_CASTER, }
        -- vengeance_demon_hunter[212613] #3: { 'type': APPLY_AURA, 'subtype': MOD_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'target': TARGET_UNIT_CASTER, }
        -- bouncing_glaives[320386] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 1.0, 'target': TARGET_UNIT_CASTER, 'modifies': CHAINED_TARGETS, }
        -- champion_of_the_glaive[429211] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': RANGE, }
        -- champion_of_the_glaive[429211] #1: { 'type': APPLY_AURA, 'subtype': MOD_MAX_CHARGES, 'points': 1.0, 'target': TARGET_UNIT_CASTER, }
        -- master_of_the_glaive[389763] #1: { 'type': APPLY_AURA, 'subtype': MOD_MAX_CHARGES, 'points': 1.0, 'target': TARGET_UNIT_CASTER, }
        -- havoc_demon_hunter[212612] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- havoc_demon_hunter[212612] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- havoc_demon_hunter[212612] #2: { 'type': APPLY_AURA, 'subtype': MOD_GLOBAL_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'target': TARGET_UNIT_CASTER, }
        -- havoc_demon_hunter[212612] #3: { 'type': APPLY_AURA, 'subtype': MOD_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'target': TARGET_UNIT_CASTER, }
        -- havoc_demon_hunter[212612] #11: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- havoc_demon_hunter[212612] #12: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        from = "class",
    },

    -- Taunts the target to attack you.
    torment = {
        id = 185245,
        cast = 0.0,
        cooldown = 8.0,
        gcd = "none",

        startsCombat = true,

        -- Effects:
        -- #0: { 'type': ATTACK_ME, 'subtype': NONE, 'sp_bonus': 0.25, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #1: { 'type': APPLY_AURA, 'subtype': MOD_TAUNT, 'points': 400.0, 'target': TARGET_UNIT_TARGET_ENEMY, }
    },

    -- [206891] You focus the assault on this target, increasing their damage taken by $s1% for $d. Each unique player that attacks the target increases the damage taken by an additional $s1%, stacking up to $u times.; Your melee attacks refresh the duration of Focused Assault.
    tormentor = {
        id = 207029,
        color = 'pvp_talent',
        cast = 0.0,
        cooldown = 20.0,
        gcd = "global",

        startsCombat = true,

        -- Effects:
        -- #0: { 'type': TRIGGER_SPELL, 'subtype': NONE, 'trigger_spell': 206891, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #1: { 'type': APPLY_AURA, 'subtype': DUMMY, 'target': TARGET_UNIT_CASTER, }
    },

    -- Remove all snares and vault away. Nearby enemies take $198813s2 Physical damage$?s320635[ and have their movement speed reduced by $198813s1% for $198813d][].$?a203551[; Generates ${($203650s1/5)*$203650d} Fury over $203650d if you damage an enemy.][]
    vengeful_retreat = {
        id = 198793,
        cast = 0.0,
        cooldown = 25.0,
        gcd = "none",

        talent = "vengeful_retreat",
        startsCombat = false,

        -- Effects:
        -- #0: { 'type': TRIGGER_SPELL, 'subtype': NONE, 'trigger_spell': 198813, 'target': TARGET_UNIT_CASTER, }
        -- #1: { 'type': KNOCK_BACK_DEST, 'subtype': NONE, 'points': 100.0, 'value': 175, 'schools': ['physical', 'holy', 'fire', 'nature', 'shadow'], 'target': TARGET_UNIT_CASTER, 'target2': TARGET_DEST_CASTER_FRONT, }
        -- #2: { 'type': APPLY_AURA, 'subtype': DUMMY, 'target': TARGET_UNIT_CASTER, }
        -- #3: { 'type': TRIGGER_SPELL, 'subtype': NONE, 'trigger_spell': 232709, 'target': TARGET_UNIT_CASTER, }

        -- Affected by:
        -- evasive_action[444929] #0: { 'type': APPLY_AURA, 'subtype': IGNORE_SPELL_COOLDOWN, 'target': TARGET_UNIT_CASTER, }
    },

} )