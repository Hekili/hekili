-- DemonHunterHavoc.lua
-- July 2024

local addon, ns = ...
local Hekili = _G[ addon ]
local class, state = Hekili.Class, Hekili.State

local spec = Hekili:NewSpecialization( 577 )

-- Resources
spec:RegisterResource( Enum.PowerType.Fury )
spec:RegisterResource( Enum.PowerType.Pain )

spec:RegisterTalents( {
    -- Demon Hunter Talents
    aldrachi_design          = { 90999, 391409, 1 }, -- Increases your chance to parry by $s1%.
    aura_of_pain             = { 90933, 207347, 1 }, -- Increases the critical strike chance of Immolation Aura by $s1%.
    blazing_path             = { 91008, 320416, 1 }, -- $?a212613[Infernal Strike][Fel Rush] gains an additional charge.
    bouncing_glaives         = { 90931, 320386, 1 }, -- Throw Glaive ricochets to $s1 additional $ltarget:targets;.
    champion_of_the_glaive   = { 90994, 429211, 1 }, -- Throw Glaive has ${$s2+1} charges and $s1 yard increased range.
    chaos_fragments          = { 95154, 320412, 1 }, -- Each enemy stunned by Chaos Nova has a $179057s3% chance to generate a Lesser Soul Fragment.
    chaos_nova               = { 90993, 179057, 1 }, -- Unleash an eruption of fel energy, dealing $s2 Chaos damage and stunning all nearby enemies for $d.$?s320412[; Each enemy stunned by Chaos Nova has a $s3% chance to generate a Lesser Soul Fragment.][]
    charred_warblades        = { 90948, 213010, 1 }, -- You heal for $s1% of all Fire damage you deal.
    collective_anguish       = { 95152, 390152, 1 }, -- $?a212613[Fel Devastation][Eye Beam] summons an allied $?a212613[Havoc][Vengeance] Demon Hunter who casts $?a212613[Eye Beam][Fel Devastation], dealing $?a212613[${$391058s1*10*2} Chaos][${$393834s1*(2/$393831t1)} Fire] damage over $?a212613[$391057d][$393831d]. $?a212613[Deals reduced damage beyond $198013s5 targets.][Dealing damage heals you for up to ${$212106s1*(2/$t1)} health.]
    consume_magic            = { 91006, 278326, 1 }, -- Consume $m1 beneficial Magic effect removing it from the target$?s320313[ and granting you $s2 Fury][].
    darkness                 = { 91002, 196718, 1 }, -- Summons darkness around you in a$?a357419[ 12 yd][n 8 yd] radius, granting friendly targets a $209426s2% chance to avoid all damage from an attack. Lasts $d.; Chance to avoid damage increased by $s3% when not in a raid.
    demon_muzzle             = { 90928, 388111, 1 }, -- Enemies deal $s1% reduced magic damage to you for $394933d after being afflicted by one of your Sigils.
    demonic                  = { 91003, 213410, 1 }, -- $?a212613[Fel Devastation][Eye Beam] causes you to enter demon form for ${$s1/1000} sec after it finishes dealing damage.
    disrupting_fury          = { 90937, 183782, 1 }, -- Disrupt generates $218903s1 Fury on a successful interrupt.
    erratic_felheart         = { 90996, 391397, 2 }, -- The cooldown of $?a212613[Infernal Strike ][Fel Rush ]is reduced by ${-1*$s1}%.
    felblade                 = { 95150, 232893, 1 }, -- [395020] $?a388114[Chaos][Fire]
    felfire_haste            = { 90939, 389846, 1 }, -- $?c1[Fel Rush][Infernal Strike] increases your movement speed by $389847s1% for $389847d.
    flames_of_fury           = { 90949, 389694, 2 }, -- Sigil of Flame deals $s2% increased damage and generates $s1 additional Fury per target hit.
    illidari_knowledge       = { 90935, 389696, 1 }, -- Reduces magic damage taken by $s1%.
    imprison                 = { 91007, 217832, 1 }, -- Imprisons a demon, beast, or humanoid, incapacitating them for $d. Damage will cancel the effect. Limit 1.
    improved_disrupt         = { 90938, 320361, 1 }, -- Increases the range of Disrupt to ${$s2+$s1} yds.
    improved_sigil_of_misery = { 90945, 320418, 1 }, -- Reduces the cooldown of Sigil of Misery by ${$s1/-1000} sec.
    infernal_armor           = { 91004, 320331, 2 }, -- [395020] $?a388114[Chaos][Fire]
    internal_struggle        = { 90934, 393822, 1 }, -- Increases your mastery by ${$s1*$mas}.1%.
    live_by_the_glaive       = { 95151, 428607, 1 }, -- When you parry an attack or have one of your attacks parried, restore $428608s2% of max health and $428608s1 Fury. ; This effect may only occur once every $s1 sec.
    long_night               = { 91001, 389781, 1 }, -- Increases the duration of Darkness by ${$s1/1000} sec.
    lost_in_darkness         = { 90947, 389849, 1 }, -- Spectral Sight lasts an additional ${$s1/1000} sec if disrupted by attacking or taking damage.
    master_of_the_glaive     = { 90994, 389763, 1 }, -- Throw Glaive has ${$s2+1} charges and snares all enemies hit by $213405s1% for $213405d.
    pitch_black              = { 91001, 389783, 1 }, -- Reduces the cooldown of Darkness by ${$s1/-1000} sec.
    precise_sigils           = { 95155, 389799, 1 }, -- All Sigils are now placed at your target's location.
    pursuit                  = { 90940, 320654, 1 }, -- Mastery increases your movement speed.
    quickened_sigils         = { 95149, 209281, 1 }, -- All Sigils activate ${$s1/-1000} second faster.
    rush_of_chaos            = { 95148, 320421, 2 }, -- Reduces the cooldown of Metamorphosis by ${$m1/-1000} sec.
    shattered_restoration    = { 90950, 389824, 1 }, -- The healing of Shattered Souls is increased by $s1%.
    sigil_of_misery          = { 90946, 207684, 1 }, -- Place a Sigil of Misery at the target location that activates after $d.; Causes all enemies affected by the sigil to cower in fear, disorienting them for $207685d.
    sigil_of_spite           = { 90997, 390163, 1 }, -- Place a demonic sigil at the target location that activates after $d.; Detonates to deal $389860s1 Chaos damage and shatter up to $s3 Lesser Soul Fragments from enemies affected by the sigil. Deals reduced damage beyond $s1 targets.
    soul_rending             = { 90936, 204909, 2 }, -- Leech increased by $s1%.; Gain an additional $s2% leech while Metamorphosis is active.
    soul_sigils              = { 90929, 395446, 1 }, -- Afflicting an enemy with a Sigil generates $m1 Lesser Soul $LFragment:Fragments;. 
    swallowed_anger          = { 91005, 320313, 1 }, -- Consume Magic generates $278326s2 Fury when a beneficial Magic effect is successfully removed from the target.
    the_hunt                 = { 90927, 370965, 1 }, -- Charge to your target, striking them for $370966s1 Chaos damage, rooting them in place for $370970d and inflicting $370969o1 Chaos damage over $370969d to up to $370967s2 enemies in your path. ; The pursuit invigorates your soul, healing you for $?c1[$370968s1%][$370968s2%] of the damage you deal to your Hunt target for $370966d.
    unrestrained_fury        = { 90941, 320770, 1 }, -- Increases maximum Fury by $s1.
    vengeful_bonds           = { 90930, 320635, 1 }, -- Vengeful Retreat reduces the movement speed of all nearby enemies by $198813s1% for $198813d.
    vengeful_retreat         = { 90942, 198793, 1 }, -- Remove all snares and vault away. Nearby enemies take $198813s2 Physical damage$?s320635[ and have their movement speed reduced by $198813s1% for $198813d][].$?a203551[; Generates ${($203650s1/5)*$203650d} Fury over $203650d if you damage an enemy.][]
    will_of_the_illidari     = { 91000, 389695, 1 }, -- Increases maximum health by $s1%.

    -- Havoc Talents
    a_fire_inside            = { 95143, 427775, 1 }, -- Immolation Aura has $m1 additional $Lcharge:charges; and $s3% chance to refund a charge when used.; You can have multiple Immolation Auras active at a time.
    accelerated_blade        = { 91011, 391275, 1 }, -- Throw Glaive deals $s2% increased damage, reduced by ${$s2/2}% for each previous enemy hit.
    aldrachi_tactics         = { 94914, 442683, 1 }, -- The second enhanced ability in a pattern shatters an additional Soul Fragment.
    any_means_necessary      = { 90919, 388114, 1 }, -- Mastery: Demonic Presence now also causes your Arcane, Fire, Frost, Nature, and Shadow damage to be dealt as Chaos instead, and increases that damage by ${$s2*((100+$394486s1)/100)}.1%.
    army_unto_oneself        = { 94896, 442714, 1 }, -- Felblade surrounds you with a Blade Ward, reducing damage taken by $442715s1% for $442715d.
    art_of_the_glaive        = { 94915, 442290, 1 }, -- [442294] Throw a glaive enhanced with the essence of consumed souls at your target, dealing $s1 Physical damage and ricocheting to ${$x1-1} additional $Lenemy:enemies;.;  ; Begins a well-practiced pattern of glaivework, enhancing your next $?a212612[Chaos Strike]?s263642[Fracture][Shear] and $?a212612[Blade Dance][Soul Cleave].; The enhanced ability you cast first deals $442290s3% increased damage, and the second deals $442290s4% increased damage.$?a442497[; Generates $s2 Fury.][]
    blind_fury               = { 91026, 203550, 2 }, -- Eye Beam generates ${$s3/5} Fury every second, and its damage and duration are increased by $s1%.
    burning_blades           = { 94905, 452408, 1 }, -- Your blades burn with Fel energy, causing your $?a212612[Chaos Strike][Soul Cleave], Throw Glaive, and auto-attacks to deal an additional $s1% damage as Fire over $453177d.
    burning_hatred           = { 90923, 320374, 1 }, -- Immolation Aura generates an additional ${$258922s2*$258920d} Fury over $258920d.
    burning_wound            = { 90917, 391189, 1 }, -- $?s203555[Demon Blades][Demon's Bite] and Throw Glaive leave open wounds on your enemies, dealing $391191o1 Chaos damage over $391191d and increasing damage taken from your Immolation Aura by $391191s2%.; May be applied to up to $s2 targets.
    chaos_theory             = { 91035, 389687, 1 }, -- Blade Dance causes your next Chaos Strike within $337567d to have a $s1-$s2% increased critical strike chance and will always refund Fury.
    chaotic_disposition      = { 95147, 428492, 2 }, -- Your Chaos damage has a ${$s2/100}.2% chance to be increased by $s3%, occurring up to $m1 total $Ltime:times;.
    chaotic_transformation   = { 90922, 388112, 1 }, -- When you activate Metamorphosis, the cooldowns of Blade Dance and Eye Beam are immediately reset.
    critical_chaos           = { 91028, 320413, 1 }, -- The chance that Chaos Strike will refund $193840s1 Fury is increased by $s2% of your critical strike chance.
    cycle_of_hatred          = { 91032, 258887, 2 }, -- Blade Dance, Chaos Strike, $?a393029[Throw Glaive, ][]and Glaive Tempest reduce the cooldown of Eye Beam by ${$s1/1000}.1 sec.
    dancing_with_fate        = { 91015, 389978, 2 }, -- The final slash of Blade Dance deals an additional $s1% damage.
    dash_of_chaos            = { 93014, 427794, 1 }, -- For ${$427793D-($428160s1/10)} sec after using Fel Rush, activating it again will dash back towards your initial location.
    deflecting_dance         = { 93015, 427776, 1 }, -- You deflect incoming attacks while Blade Dancing, absorbing damage up to $s1% of your maximum health.
    demon_blades             = { 91019, 203555, 1 }, -- [395041] $?a388114[Chaos][Shadow]
    demon_hide               = { 91017, 428241, 1 }, -- Magical damage increased by $s1%, and Physical damage taken reduced by $s2%.
    demonic_intensity        = { 94901, 452415, 1 }, -- Activating Metamorphosis greatly empowers $?a212612[Eye Beam][Fel Devastation], Immolation Aura, and Sigil of Flame.; Demonsurge damage is increased by $?a452416[${$452416s2/$452416u}][$452416s2]% for each time it previously triggered while your demon form is active.
    demonsurge               = { 94917, 452402, 1 }, -- Metamorphosis now also $?a212612[increases current and maximum health by $162264s10% and Armor by $162264s11%][greatly empowers Soul Cleave and Spirit Bomb].; While demon form is active, the first cast of each empowered ability induces a Demonsurge, causing you to explode with Fel energy, dealing $452416s1 Fire damage to nearby enemies.
    desperate_instincts      = { 93016, 205411, 1 }, -- Blur now reduces damage taken by an additional ${$abs($m3)}%.; Additionally, you automatically trigger Blur with $s4% reduced cooldown and duration when you fall below $s1% health. This effect can only occur when Blur is not on cooldown.
    enduring_torment         = { 94916, 452410, 1 }, -- The effects of your demon form persist outside of it in a weakened state, increasing $?a212612[Chaos Strike and Blade Dance damage by 5%, and Haste by 3%][maximum health by 5% and Armor by 20%].
    essence_break            = { 91033, 258860, 1 }, -- Slash all enemies in front of you for $s1 Chaos damage, and increase the damage your Chaos Strike and Blade Dance deal to them by $320338s1% for $320338d. Deals reduced damage beyond $s2 targets.
    evasive_action           = { 94911, 444926, 1 }, -- Vengeful Retreat can be cast a second time within $444929d.
    eye_beam                 = { 91018, 198013, 1 }, -- Blasts all enemies in front of you,$?s320415[ dealing guaranteed critical strikes][] for up to $<dmg> Chaos damage over $d. Deals reduced damage beyond $s5 targets.$?s343311[; When Eye Beam finishes fully channeling, your Haste is increased by an additional $343312s1% for $343312d.][]
    fel_barrage              = { 95144, 258925, 1 }, -- Unleash a torrent of Fel energy, rapidly consuming Fury to inflict $258926s1 Chaos damage to all enemies within $258926A1 yds, lasting $d or until Fury is depleted. Deals reduced damage beyond $258926s2 targets.
    first_blood              = { 90925, 206416, 1 }, -- Blade Dance deals $<firstbloodDmg> Chaos damage to the first target struck.
    flamebound               = { 94902, 452413, 1 }, -- Immolation Aura has 2 yd increased radius and 30% increased critical strike damage bonus.
    focused_hatred           = { 94918, 452405, 1 }, -- Demonsurge deals $s1% increased damage when it strikes a single target.
    furious_gaze             = { 91025, 343311, 1 }, -- When Eye Beam finishes fully channeling, your Haste is increased by an additional $343312s1% for $343312d.
    furious_throws           = { 93013, 393029, 1 }, -- Throw Glaive now costs $s1 Fury and throws a second glaive at the target.
    fury_of_the_aldrachi     = { 94898, 442718, 1 }, -- When enhanced by Reaver's Glaive, $?a212612[Blade Dance][Soul Cleave] casts $s2 additional glaive slashes to nearby targets. ; If cast after $?a212612[Chaos Strike]?s263642[Fracture][Shear], cast ${$s2*($s1/100+1)} slashes instead.
    glaive_tempest           = { 91035, 342817, 1 }, -- Launch two demonic glaives in a whirlwind of energy, causing ${14*$342857s1} Chaos damage over $d to all nearby enemies. Deals reduced damage beyond $s2 targets.
    growing_inferno          = { 90916, 390158, 1 }, -- Immolation Aura's damage increases by $s1% each time it deals damage.
    improved_chaos_strike    = { 91030, 343206, 1 }, -- Chaos Strike damage increased by $s1%.
    improved_fel_rush        = { 93014, 343017, 1 }, -- Fel Rush damage increased by $s1%.
    improved_soul_rending    = { 94899, 452407, 1 }, -- Leech granted by Soul Rending increased by $s1% and an additional $s2% while Metamorphosis is active.
    incisive_blade           = { 94895, 442492, 1 }, -- $?a212612[Chaos Strike][Soul Cleave] deals $s1% increased damage.
    incorruptible_spirit     = { 94896, 442736, 1 }, -- Consuming a Soul Fragment also heals you for an additional $s1% over time.
    inertia                  = { 91021, 427640, 1 }, -- When empowered by Unbound Chaos, Fel Rush increases your damage done by $427641s1% for $427641d.
    initiative               = { 91027, 388108, 1 }, -- Damaging an enemy before they damage you increases your critical strike chance by $391215s1% for $391215d.; Vengeful Retreat refreshes your potential to trigger this effect on any enemies you are in combat with.
    inner_demon              = { 91024, 389693, 1 }, -- Entering demon form causes your next Chaos Strike to unleash your inner demon, causing it to crash into your target and deal $390137s1 Chaos damage to all nearby enemies. Deals reduced damage beyond $s2 targets.
    insatiable_hunger        = { 91019, 258876, 1 }, -- Demon's Bite deals $s2% more damage and generates $s3 to $s4 additional Fury.
    isolated_prey            = { 91036, 388113, 1 }, -- Chaos Nova, Eye Beam, and Immolation Aura gain bonuses when striking 1 target.; $@spellicon179057 $@spellname179057:; Stun duration increased by ${$s1/1000} sec.; $@spellicon198013 $@spellname198013:; Deals $s2% increased damage.; $@spellicon258920 $@spellname258920:; Always critically strikes.
    keen_engagement          = { 94910, 442497, 1 }, -- Reaver's Glaive generates $s1 Fury.
    know_your_enemy          = { 91034, 388118, 2 }, -- Gain critical strike damage equal to $s2% of your critical strike chance.
    looks_can_kill           = { 90921, 320415, 1 }, -- Eye Beam deals guaranteed critical strikes.
    momentum                 = { 91021, 206476, 1 }, -- Fel Rush, The Hunt, and Vengeful Retreat increase your damage done by $208628s1% for $208628d, up to a maximum of ${$s2/1000} sec.
    monster_rising           = { 94909, 452414, 1 }, -- Agility increased by $452550s1% while not in demon form.
    mortal_dance             = { 93015, 328725, 1 }, -- Blade Dance now reduces targets' healing received by $356608s1% for $356608d.
    netherwalk               = { 93016, 196555, 1 }, -- Slip into the nether, increasing movement speed by $s3% and becoming immune to damage, but unable to attack. Lasts $d.
    preemptive_strike        = { 94910, 444997, 1 }, -- Throw Glaive deals $444979s1 damage to enemies near its initial target.
    pursuit_of_angriness     = { 94913, 452404, 1 }, -- Movement speed increased by $s1% per $s2 Fury.
    ragefire                 = { 90918, 388107, 1 }, -- Each time Immolation Aura deals damage, $s1% of the damage dealt by up to $s2 critical strikes is gathered as Ragefire.; When Immolation Aura expires you explode, dealing all stored Ragefire damage to nearby enemies.
    reavers_mark             = { 94903, 442679, 1 }, -- When enhanced by Reaver's Glaive, $?a212612[Chaos Strike]?s263642[Fracture][Shear] applies Reaver's Mark, which causes the target to take $442624s1% increased damage for $442624d. ; If cast after $?a212612[Blade Dance][Soul Cleave], Reaver's Mark is increased to ${$442624s1*($s1/100+1)}%.
    relentless_onslaught     = { 91012, 389977, 1 }, -- Chaos Strike has a $s1% chance to trigger a second Chaos Strike.
    restless_hunter          = { 91024, 390142, 1 }, -- Leaving demon form grants a charge of Fel Rush and increases the damage of your next Blade Dance by $390212s1%.
    scars_of_suffering       = { 90914, 428232, 1 }, -- Increases Versatility by $s1% and reduces threat generated by ${$s2*-1}%.
    serrated_glaive          = { 91013, 390154, 1 }, -- Enemies hit by Chaos Strike or Throw Glaive take $s1% increased damage from Chaos Strike and Throw Glaive for $390155d.
    set_fire_to_the_pain     = { 94899, 452406, 1 }, -- $s2% of all non-Fire damage taken is instead taken as Fire damage over $453286d.; Fire damage taken reduced by $S3%.
    shattered_destiny        = { 91031, 388116, 1 }, -- The duration of your active demon form is extended by ${$s1/1000}.1 sec per $s2 Fury spent.
    soulscar                 = { 91012, 388106, 1 }, -- Throw Glaive causes targets to take an additional $s1% of damage dealt as Chaos over $390181d.
    student_of_suffering     = { 94902, 452412, 1 }, -- Sigil of Flame applies Student of Suffering to you, increasing Mastery by ${$453239s1*$mas}.1% and granting $453236s1 Fury every $453239t2 sec, for $453239d.
    tactical_retreat         = { 91022, 389688, 1 }, -- Vengeful Retreat has a ${$s1/-1000} sec reduced cooldown and generates ${$389890m1/$389890t*$389890d} Fury over $389890d.
    thrill_of_the_fight      = { 94919, 442686, 1 }, -- After consuming both enhancements, gain Thrill of the Fight, increasing your attack speed by $442695s1% for $442695d and your damage and healing by $442688s1% for $442688d.
    trail_of_ruin            = { 90915, 258881, 1 }, -- The final slash of Blade Dance inflicts an additional $258883o1 Chaos damage over $258883d.
    unbound_chaos            = { 91020, 347461, 1 }, -- Activating Immolation Aura increases the damage of your next Fel Rush by $s2%. Lasts $347462d.
    unhindered_assault       = { 94911, 444931, 1 }, -- Vengeful Retreat resets the cooldown of Felblade.
    untethered_fury          = { 94904, 452411, 1 }, -- Maximum Fury increased by $s1.
    violent_transformation   = { 94912, 452409, 1 }, -- When you activate Metamorphosis, the cooldowns of your Sigil of Flame and $?a212612[Immolation Aura][Fel Devastation] are immediately reset.
    warblades_hunger         = { 94906, 442502, 1 }, -- Consuming a Soul Fragment causes your next $?a212612[Chaos Strike]?s263642[Fracture][Shear] to deal $442507s1 additional damage.$?a212612[; Felblade consumes up to $s2 nearby Soul Fragments.][]
    wave_of_debilitation     = { 94913, 452403, 1 }, -- Chaos Nova slows enemies by 60% and reduces attack and cast speed 15% for 5 sec after its stun fades. 
    wounded_quarry           = { 94897, 442806, 1 }, -- While $@spellname442624 is on your target, melee attacks strike with an additional glaive slash for $442808s1 Physical damage and have a chance to shatter a soul.
} )

-- PvP Talents
spec:RegisterPvpTalents( {
    blood_moon        = 5433, -- (355995) Consume Magic now affects all enemies within 8 yards of the target and generates a Lesser Soul Fragment. Each effect consumed has a $s1% chance to upgrade to a Greater Soul.
    chaotic_imprint   = 809 , -- (356510) Throw Glaive now deals damage from a random school of magic, and increases the target's damage taken from the school by $s1% for $356632d.
    cleansed_by_flame = 805 , -- (205625) Immolation Aura dispels a magical effect on you when cast.
    cover_of_darkness = 1206, -- (357419) The radius of Darkness is increased by $s1 yds, and its duration by ${$s2/1000} sec.
    detainment        = 812 , -- (205596) Imprison's PvP duration is increased by $m2 sec, and targets become immune to damage and healing while imprisoned.
    glimpse           = 813 , -- (354489) Vengeful Retreat provides immunity to loss of control effects, and reduces damage taken by $s1% until you land.
    rain_from_above   = 811 , -- (206803) You fly into the air out of harm's way. While floating, you gain access to Fel Lance allowing you to deal damage to enemies below. 
    reverse_magic     = 806 , -- (205604) Removes all harmful magical effects from yourself and all nearby allies within $m1 yards, and sends them back to their original caster if possible.
    sigil_mastery     = 5523, -- (211489) Reduces the cooldown of your Sigils by an additional $m1%.
    unending_hatred   = 1218, -- (213480) Taking damage causes you to gain Fury based on the damage dealt.
} )

-- Auras
spec:RegisterAuras( {
    -- $w1 Soul Fragments consumed. At $?a212612[$442290s1~][$442290s2~], Reaver's Glaive is available to cast.
    art_of_the_glaive = {
        id = 444661,
        duration = 30.0,
        max_stack = 1,
    },
    -- Dodge chance increased by $s2%.
    blade_dance = {
        id = 188499,
        duration = 1.0,
        max_stack = 1,

        -- Affected by:
        -- havoc_demon_hunter[212612] #2: { 'type': APPLY_AURA, 'subtype': MOD_GLOBAL_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'target': TARGET_UNIT_CASTER, }
        -- havoc_demon_hunter[212612] #3: { 'type': APPLY_AURA, 'subtype': MOD_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'target': TARGET_UNIT_CASTER, }
        -- blade_dance[320402] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -5000.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
        -- metamorphosis[162264] #6: { 'type': APPLY_AURA, 'subtype': OVERRIDE_ACTIONBAR_SPELLS, 'spell': 210152, 'target': TARGET_UNIT_CASTER, }
        -- vengeance_demon_hunter[212613] #2: { 'type': APPLY_AURA, 'subtype': MOD_GLOBAL_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'target': TARGET_UNIT_CASTER, }
        -- vengeance_demon_hunter[212613] #3: { 'type': APPLY_AURA, 'subtype': MOD_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'target': TARGET_UNIT_CASTER, }
        -- essence_break[320338] #0: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'pvp_multiplier': 0.5, 'points': 80.0, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- restless_hunter[390212] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.6, 'points': 50.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
    },
    -- Damage taken reduced by $s1%.
    blade_ward = {
        id = 442715,
        duration = 5.0,
        max_stack = 1,
    },
    -- Dodge increased by $s2%. Damage taken reduced by $s3%.
    blur = {
        id = 212800,
        duration = 10.0,
        max_stack = 1,

        -- Affected by:
        -- desperate_instincts[205411] #2: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -10.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_3_VALUE, }
    },
    -- Taking $w1 Chaos damage every $t1 seconds.; Damage taken from $@auracaster's Immolation Aura increased by $s2%.
    burning_wound = {
        id = 391191,
        duration = 15.0,
        tick_time = 3.0,
        pandemic = true,
        max_stack = 1,

        -- Affected by:
        -- mastery_demonic_presence[185164] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 1.8, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- mastery_demonic_presence[185164] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 1.8, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
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
    -- [179057] Stunned.
    chaos_nova = {
        id = 344867,
        duration = 0.0,
        max_stack = 1,

        -- Affected by:
        -- mastery_demonic_presence[185164] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 1.8, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- mastery_demonic_presence[185164] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 1.8, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
    },
    -- Chaos Strike damage increased by $w1%.; Chaos Strike has a $197125h% chance to refund $193840s1 Fury.
    chaotic_blades = {
        id = 337567,
        duration = 8.0,
        max_stack = 1,
    },
    -- Magic damage dealt to $@auracaster is reduced by $w1%.
    demon_muzzle = {
        id = 394933,
        duration = 8.0,
        max_stack = 1,
    },
    -- The Demon Hunter's Chaos Strike and Blade Dance inflict $s2% additional damage.
    essence_break = {
        id = 320338,
        duration = 4.0,
        max_stack = 1,
    },
    -- Vengeful Retreat may be cast again.
    evasive_action = {
        id = 444929,
        duration = 3.0,
        max_stack = 1,
    },
    -- Unleashing Fel.
    fel_barrage = {
        id = 258925,
        duration = 8.0,
        max_stack = 1,
    },
    -- Stunned.
    fel_eruption = {
        id = 211881,
        duration = 4.0,
        max_stack = 1,

        -- Affected by:
        -- mastery_demonic_presence[185164] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 1.8, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- mastery_demonic_presence[185164] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 1.8, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- havoc_demon_hunter[212612] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- havoc_demon_hunter[212612] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- havoc_demon_hunter[212612] #11: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- havoc_demon_hunter[212612] #12: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- vengeance_demon_hunter[212613] #7: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -60.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- inertia[427641] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.67, 'points': 18.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- inertia[427641] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.67, 'points': 18.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- momentum[208628] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 6.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- momentum[208628] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 6.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
    },
    -- Movement speed increased by $w1%.
    felfire_haste = {
        id = 389847,
        duration = 8.0,
        max_stack = 1,
    },
    -- Battling a demon from the Theater of Pain...
    fodder_to_the_flame = {
        id = 329554,
        duration = 25.0,
        max_stack = 1,
    },
    -- Haste increased by $w1.
    furious_gaze = {
        id = 273232,
        duration = 12.0,
        max_stack = 1,
    },
    -- Falling speed reduced.
    glide = {
        id = 131347,
        duration = 3600,
        max_stack = 1,
    },
    -- The caster's Demon's Bite generates maximum Fury and deals increased damage.
    hungering_glaive = {
        id = 244785,
        duration = 12.0,
        max_stack = 1,

        -- Affected by:
        -- mastery_demonic_presence[185164] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 1.8, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- mastery_demonic_presence[185164] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 1.8, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
    },
    -- [395020] $?a388114[Chaos][Fire]
    immolation_aura = {
        id = 258920,
        duration = 6.0,
        max_stack = 1,

        -- Affected by:
        -- havoc_demon_hunter[212612] #3: { 'type': APPLY_AURA, 'subtype': MOD_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'target': TARGET_UNIT_CASTER, }
        -- immolation_aura[320377] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 4000.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
        -- infernal_armor[320331] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_5_VALUE, }
        -- a_fire_inside[427775] #0: { 'type': APPLY_AURA, 'subtype': MOD_MAX_CHARGES, 'points': 1.0, 'target': TARGET_UNIT_CASTER, }
        -- vengeance_demon_hunter[212613] #3: { 'type': APPLY_AURA, 'subtype': MOD_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'target': TARGET_UNIT_CASTER, }
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
    -- Damage done increased by $w1%.
    inertia = {
        id = 427641,
        duration = 5.0,
        max_stack = 1,
    },
    -- Critical strike chance increased by $s1%.
    initiative = {
        id = 391215,
        duration = 5.0,
        max_stack = 1,
    },
    -- Mana costs increased by $w3%.
    mana_break = {
        id = 203704,
        duration = 10.0,
        max_stack = 1,

        -- Affected by:
        -- mastery_demonic_presence[185164] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 1.8, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- mastery_demonic_presence[185164] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 1.8, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- havoc_demon_hunter[212612] #2: { 'type': APPLY_AURA, 'subtype': MOD_GLOBAL_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'target': TARGET_UNIT_CASTER, }
        -- demon_hide[428241] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- demon_hide[428241] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- vengeance_demon_hunter[212613] #2: { 'type': APPLY_AURA, 'subtype': MOD_GLOBAL_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'target': TARGET_UNIT_CASTER, }
    },
    -- Movement speed reduced by $s1%.
    master_of_the_glaive = {
        id = 213405,
        duration = 6.0,
        max_stack = 1,
    },
    -- Dazed.
    metamorphosis = {
        id = 247121,
        duration = 3.0,
        max_stack = 1,

        -- Affected by:
        -- mastery_demonic_presence[185164] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 1.8, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- mastery_demonic_presence[185164] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 1.8, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
    },
    -- Stunned.
    metamorphosis_alex_s_copy = {
        id = 418583,
        duration = 3.0,
        max_stack = 1,

        -- Affected by:
        -- mastery_demonic_presence[185164] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 1.8, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- mastery_demonic_presence[185164] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 1.8, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
    },
    -- Damage done increased by $w1%.
    momentum = {
        id = 208628,
        duration = 6.0,
        pandemic = true,
        max_stack = 1,
    },
    -- Agility increased by $w1%.
    monster_rising = {
        id = 452550,
        duration = 3600,
        max_stack = 1,
    },
    -- Healing effects received reduced by $w1%.
    mortal_dance = {
        id = 356608,
        duration = 6.0,
        max_stack = 1,
    },
    -- Healing effects received reduced by $w1%.
    mortal_wounds = {
        id = 115804,
        duration = 10.0,
        max_stack = 1,
    },
    -- Immune to damage and unable to attack.; Movement speed increased by $s3%.
    netherwalk = {
        id = 196555,
        duration = 6.0,
        max_stack = 1,
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
    -- Damage of next Blade Dance increased by $s1%.
    restless_hunter = {
        id = 390212,
        duration = 12.0,
        max_stack = 1,
    },
    -- Damage taken from Chaos Strike and Throw Glaive increased by $w1%.
    serrated_glaive = {
        id = 390155,
        duration = 15.0,
        max_stack = 1,
    },
    -- Taking $w1 Fire damage every $t1 sec.
    set_fire_to_the_pain = {
        id = 453286,
        duration = 6.0,
        tick_time = 1.0,
        max_stack = 1,
    },
    -- Sigil of Flame is active.
    sigil_of_flame = {
        id = 204596,
        duration = 2.0,
        max_stack = 1,

        -- Affected by:
        -- havoc_demon_hunter[212612] #2: { 'type': APPLY_AURA, 'subtype': MOD_GLOBAL_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'target': TARGET_UNIT_CASTER, }
        -- quickened_sigils[209281] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -1000.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
        -- any_means_necessary[388114] #0: { 'type': APPLY_AURA, 'subtype': MOD_ABILITY_SCHOOL_MASK, 'value': 127, 'schools': ['physical', 'holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], 'target': TARGET_UNIT_CASTER, }
        -- sigil_mastery[211489] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -25.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
        -- vengeance_demon_hunter[212613] #2: { 'type': APPLY_AURA, 'subtype': MOD_GLOBAL_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'target': TARGET_UNIT_CASTER, }
    },
    -- Disoriented.
    sigil_of_misery = {
        id = 207685,
        duration = 15.0,
        max_stack = 1,

        -- Affected by:
        -- precise_sigils[389799] #4: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
        -- any_means_necessary[388114] #0: { 'type': APPLY_AURA, 'subtype': MOD_ABILITY_SCHOOL_MASK, 'value': 127, 'schools': ['physical', 'holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], 'target': TARGET_UNIT_CASTER, }
        -- any_means_necessary[388114] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 1.8, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- any_means_necessary[388114] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 1.8, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
    },
    -- Suffering $s1 Fire damage every $t1 sec.
    soul_carver = {
        id = 207407,
        duration = 3.0,
        tick_time = 1.0,
        max_stack = 1,

        -- Affected by:
        -- any_means_necessary[388114] #0: { 'type': APPLY_AURA, 'subtype': MOD_ABILITY_SCHOOL_MASK, 'value': 127, 'schools': ['physical', 'holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], 'target': TARGET_UNIT_CASTER, }
        -- vengeance_demon_hunter[212613] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- vengeance_demon_hunter[212613] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
    },
    -- Suffering $w1 Chaos damage every $t1 sec.
    soulscar = {
        id = 390181,
        duration = 6.0,
        tick_time = 2.0,
        max_stack = 1,

        -- Affected by:
        -- mastery_demonic_presence[185164] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 1.8, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- mastery_demonic_presence[185164] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 1.8, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
    },
    -- Can see invisible and stealthed enemies.; Can see enemies and treasures through physical barriers.
    spectral_sight = {
        id = 188501,
        duration = 10.0,
        max_stack = 1,

        -- Affected by:
        -- havoc_demon_hunter[212612] #2: { 'type': APPLY_AURA, 'subtype': MOD_GLOBAL_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'target': TARGET_UNIT_CASTER, }
        -- spectral_sight[320379] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -30000.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
        -- vengeance_demon_hunter[212613] #2: { 'type': APPLY_AURA, 'subtype': MOD_GLOBAL_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'target': TARGET_UNIT_CASTER, }
    },
    -- Mastery increased by ${$w1*$mas}.1%. ; Generating $453236s1 Fury every $t2 sec.
    student_of_suffering = {
        id = 453239,
        duration = 8.0,
        max_stack = 1,
    },
    -- Generating $s1 Fury every $t sec.
    tactical_retreat = {
        id = 389890,
        duration = 10.0,
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
    -- Suffering $w1 Chaos damage every $t1 sec.
    trail_of_ruin = {
        id = 258883,
        duration = 4.0,
        tick_time = 1.0,
        pandemic = true,
        max_stack = 1,

        -- Affected by:
        -- mastery_demonic_presence[185164] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 1.8, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- mastery_demonic_presence[185164] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 1.8, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
    },
    -- Damage of your next Fel Rush increased by $w1%.
    unbound_chaos = {
        id = 347462,
        duration = 12.0,
        max_stack = 1,
    },
    -- Movement speed reduced by $s1%.
    vengeful_retreat = {
        id = 198813,
        duration = 3.0,
        max_stack = 1,

        -- Affected by:
        -- havoc_demon_hunter[212612] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- havoc_demon_hunter[212612] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- havoc_demon_hunter[212612] #11: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- havoc_demon_hunter[212612] #12: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- tactical_retreat[389688] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -5000.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
        -- evasive_action[444929] #0: { 'type': APPLY_AURA, 'subtype': IGNORE_SPELL_COOLDOWN, 'target': TARGET_UNIT_CASTER, }
        -- vengeance_demon_hunter[212613] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- vengeance_demon_hunter[212613] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- inertia[427641] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.67, 'points': 18.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- inertia[427641] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.67, 'points': 18.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- momentum[208628] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 6.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- momentum[208628] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 6.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
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
    -- Slice your target for ${$227518s1+$201428s1} Chaos damage. Annihilation has a $197125h% chance to refund $193840s1 Fury.
    annihilation = {
        id = 201427,
        cast = 0.0,
        cooldown = 0.0,
        gcd = "global",

        spend = 40,
        spendType = 'fury',

        startsCombat = true,

        -- Effects:
        -- #0: { 'type': DUMMY, 'subtype': NONE, 'chain_targets': 1, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #1: { 'type': TRIGGER_SPELL, 'subtype': NONE, 'trigger_spell': 227518, 'target': TARGET_UNIT_CASTER, }
        -- #2: { 'type': TRIGGER_SPELL, 'subtype': NONE, 'trigger_spell': 201428, 'value': 300, 'schools': ['fire', 'nature', 'shadow'], 'target': TARGET_UNIT_CASTER, }

        -- Affected by:
        -- mastery_demonic_presence[185164] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 1.8, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- mastery_demonic_presence[185164] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 1.8, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- havoc_demon_hunter[212612] #2: { 'type': APPLY_AURA, 'subtype': MOD_GLOBAL_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'target': TARGET_UNIT_CASTER, }
        -- demon_hide[428241] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- demon_hide[428241] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- vengeance_demon_hunter[212613] #2: { 'type': APPLY_AURA, 'subtype': MOD_GLOBAL_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'target': TARGET_UNIT_CASTER, }
    },

    -- Strike $?a206416[your primary target for $<firstbloodDmg> Chaos damage and ][]nearby enemies for $<baseDmg> Physical damage$?s320398[, and increase your chance to dodge by $193311s1% for $193311d.][. Deals reduced damage beyond $199552s1 targets.]
    blade_dance = {
        id = 188499,
        cast = 0.0,
        cooldown = 15.0,
        gcd = "global",

        spend = 35,
        spendType = 'fury',

        startsCombat = true,

        -- Effects:
        -- #0: { 'type': DUMMY, 'subtype': NONE, 'radius': 8.0, 'target': TARGET_SRC_CASTER, 'target2': TARGET_UNIT_SRC_AREA_ENEMY, }
        -- #1: { 'type': TRIGGER_SPELL, 'subtype': NONE, 'trigger_spell': 199552, 'target': TARGET_UNIT_CASTER, }
        -- #2: { 'type': TRIGGER_SPELL, 'subtype': NONE, 'trigger_spell': 199552, 'value': 150, 'schools': ['holy', 'fire', 'frost'], 'target': TARGET_UNIT_CASTER, }
        -- #3: { 'type': TRIGGER_SPELL, 'subtype': NONE, 'trigger_spell': 199552, 'value': 450, 'schools': ['holy', 'arcane'], 'target': TARGET_UNIT_CASTER, }
        -- #4: { 'type': TRIGGER_SPELL, 'subtype': NONE, 'trigger_spell': 200685, 'value': 700, 'schools': ['fire', 'nature', 'frost', 'shadow'], 'target': TARGET_UNIT_CASTER, }
        -- #5: { 'type': APPLY_AURA, 'subtype': SUPPRESS_TRANSFORMS, 'value1': 8, 'target': TARGET_UNIT_CASTER, }

        -- Affected by:
        -- havoc_demon_hunter[212612] #2: { 'type': APPLY_AURA, 'subtype': MOD_GLOBAL_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'target': TARGET_UNIT_CASTER, }
        -- havoc_demon_hunter[212612] #3: { 'type': APPLY_AURA, 'subtype': MOD_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'target': TARGET_UNIT_CASTER, }
        -- blade_dance[320402] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -5000.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
        -- metamorphosis[162264] #6: { 'type': APPLY_AURA, 'subtype': OVERRIDE_ACTIONBAR_SPELLS, 'spell': 210152, 'target': TARGET_UNIT_CASTER, }
        -- vengeance_demon_hunter[212613] #2: { 'type': APPLY_AURA, 'subtype': MOD_GLOBAL_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'target': TARGET_UNIT_CASTER, }
        -- vengeance_demon_hunter[212613] #3: { 'type': APPLY_AURA, 'subtype': MOD_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'target': TARGET_UNIT_CASTER, }
        -- essence_break[320338] #0: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'pvp_multiplier': 0.5, 'points': 80.0, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- restless_hunter[390212] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.6, 'points': 50.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
    },

    -- Increases your chance to dodge by $212800s2% and reduces all damage taken by $212800s3% for $212800d.
    blur = {
        id = 198589,
        cast = 0.0,
        cooldown = 60.0,
        gcd = "none",

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': TRIGGER_SPELL, 'subtype': NONE, 'trigger_spell': 212800, 'target': TARGET_UNIT_CASTER, }

        -- Affected by:
        -- desperate_instincts[205411] #2: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -10.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_3_VALUE, }
    },

    -- [198589] Increases your chance to dodge by $212800s2% and reduces all damage taken by $212800s3% for $212800d.
    blur_212800 = {
        id = 212800,
        cast = 0.0,
        cooldown = 60.0,
        gcd = "none",

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': IGNORE_HIT_DIRECTION, 'points': 100.0, 'target': TARGET_UNIT_CASTER, }
        -- #1: { 'type': APPLY_AURA, 'subtype': MOD_DODGE_PERCENT, 'points': 50.0, 'target': TARGET_UNIT_CASTER, }
        -- #2: { 'type': APPLY_AURA, 'subtype': MOD_DAMAGE_PERCENT_TAKEN, 'points': -20.0, 'schools': ['physical', 'holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], 'target': TARGET_UNIT_CASTER, }
        -- #3: { 'type': APPLY_AURA, 'subtype': MOD_INCREASE_SPEED, 'target': TARGET_UNIT_CASTER, }

        -- Affected by:
        -- desperate_instincts[205411] #2: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -10.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_3_VALUE, }
        from = "triggered_spell",
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
        -- mastery_demonic_presence[185164] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 1.8, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- mastery_demonic_presence[185164] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 1.8, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- havoc_demon_hunter[212612] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- havoc_demon_hunter[212612] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- havoc_demon_hunter[212612] #2: { 'type': APPLY_AURA, 'subtype': MOD_GLOBAL_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'target': TARGET_UNIT_CASTER, }
        -- havoc_demon_hunter[212612] #11: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- havoc_demon_hunter[212612] #12: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- demon_hide[428241] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- demon_hide[428241] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- vengeance_demon_hunter[212613] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- vengeance_demon_hunter[212613] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- vengeance_demon_hunter[212613] #2: { 'type': APPLY_AURA, 'subtype': MOD_GLOBAL_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'target': TARGET_UNIT_CASTER, }
        -- inertia[427641] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.67, 'points': 18.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- inertia[427641] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.67, 'points': 18.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- momentum[208628] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 6.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- momentum[208628] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 6.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
    },

    -- [179057] Unleash an eruption of fel energy, dealing $s2 Chaos damage and stunning all nearby enemies for $d.$?s320412[; Each enemy stunned by Chaos Nova has a $s3% chance to generate a Lesser Soul Fragment.][]
    chaos_nova_344867 = {
        id = 344867,
        cast = 0.0,
        cooldown = 60.0,
        gcd = "global",

        spend = 30,
        spendType = 'fury',

        startsCombat = true,

        -- Effects:
        -- #0: { 'type': DUMMY, 'subtype': NONE, 'radius': 8.0, 'target': TARGET_DEST_CASTER, 'target2': TARGET_UNIT_DEST_AREA_ENEMY, }

        -- Affected by:
        -- mastery_demonic_presence[185164] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 1.8, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- mastery_demonic_presence[185164] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 1.8, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        from = "affected_by_mastery",
    },

    -- Slice your target for ${$222031s1+$199547s1} Chaos damage. Chaos Strike has a ${$min($197125h,100)}% chance to refund $193840s1 Fury.
    chaos_strike = {
        id = 162794,
        cast = 0.0,
        cooldown = 0.0,
        gcd = "global",

        spend = 40,
        spendType = 'fury',

        startsCombat = true,

        -- Effects:
        -- #0: { 'type': DUMMY, 'subtype': NONE, 'chain_targets': 1, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #1: { 'type': TRIGGER_SPELL, 'subtype': NONE, 'trigger_spell': 222031, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #2: { 'type': TRIGGER_SPELL, 'subtype': NONE, 'trigger_spell': 199547, 'value': 300, 'schools': ['fire', 'nature', 'shadow'], 'target': TARGET_UNIT_TARGET_ENEMY, }

        -- Affected by:
        -- mastery_demonic_presence[185164] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 1.8, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- mastery_demonic_presence[185164] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 1.8, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- havoc_demon_hunter[212612] #2: { 'type': APPLY_AURA, 'subtype': MOD_GLOBAL_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'target': TARGET_UNIT_CASTER, }
        -- critical_chaos[320413] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 30.0, 'target': TARGET_UNIT_CASTER, 'modifies': PROC_CHANCE, }
        -- demon_hide[428241] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- demon_hide[428241] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- metamorphosis[162264] #5: { 'type': APPLY_AURA, 'subtype': OVERRIDE_ACTIONBAR_SPELLS, 'spell': 201427, 'target': TARGET_UNIT_CASTER, }
        -- vengeance_demon_hunter[212613] #2: { 'type': APPLY_AURA, 'subtype': MOD_GLOBAL_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'target': TARGET_UNIT_CASTER, }
        -- chaotic_blades[337567] #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 60.0, 'target': TARGET_UNIT_CASTER, 'modifies': PROC_CHANCE, }
    },

    -- [162794] Slice your target for ${$222031s1+$199547s1} Chaos damage. Chaos Strike has a ${$min($197125h,100)}% chance to refund $193840s1 Fury.
    chaos_strike_344862 = {
        id = 344862,
        cast = 0.0,
        cooldown = 0.0,
        gcd = "global",

        spend = 40,
        spendType = 'fury',

        startsCombat = true,

        -- Effects:
        -- #0: { 'type': DUMMY, 'subtype': NONE, 'chain_targets': 1, 'target': TARGET_UNIT_TARGET_ENEMY, }
        from = "class",
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
        -- havoc_demon_hunter[212612] #2: { 'type': APPLY_AURA, 'subtype': MOD_GLOBAL_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'target': TARGET_UNIT_CASTER, }
        -- long_night[389781] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 3000.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
        -- pitch_black[389783] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -120000.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
        -- cover_of_darkness[357419] #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 2000.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
        -- vengeance_demon_hunter[212613] #2: { 'type': APPLY_AURA, 'subtype': MOD_GLOBAL_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'target': TARGET_UNIT_CASTER, }
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
        -- havoc_demon_hunter[212612] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- havoc_demon_hunter[212612] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- havoc_demon_hunter[212612] #2: { 'type': APPLY_AURA, 'subtype': MOD_GLOBAL_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'target': TARGET_UNIT_CASTER, }
        -- havoc_demon_hunter[212612] #11: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- havoc_demon_hunter[212612] #12: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- any_means_necessary[388114] #0: { 'type': APPLY_AURA, 'subtype': MOD_ABILITY_SCHOOL_MASK, 'value': 127, 'schools': ['physical', 'holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], 'target': TARGET_UNIT_CASTER, }
        -- any_means_necessary[388114] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 1.8, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- any_means_necessary[388114] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 1.8, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- demon_hide[428241] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- demon_hide[428241] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- hungering_glaive[244785] #2: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'points': 200.0, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- vengeance_demon_hunter[212613] #2: { 'type': APPLY_AURA, 'subtype': MOD_GLOBAL_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'target': TARGET_UNIT_CASTER, }
        -- inertia[427641] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.67, 'points': 18.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- inertia[427641] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.67, 'points': 18.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- momentum[208628] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 6.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- momentum[208628] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 6.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
    },

    -- Quickly attack for $s2 Physical damage.; Generates $?a258876[${$m3+$258876s3} to ${$M3+$258876s4}][$m3 to $M3] Fury.
    demons_bite = {
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
        -- havoc_demon_hunter[212612] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- havoc_demon_hunter[212612] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- havoc_demon_hunter[212612] #2: { 'type': APPLY_AURA, 'subtype': MOD_GLOBAL_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'target': TARGET_UNIT_CASTER, }
        -- havoc_demon_hunter[212612] #11: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- havoc_demon_hunter[212612] #12: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- insatiable_hunger[258876] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'ap_bonus': 0.1, 'points': 50.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- hungering_glaive[244785] #1: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'points': 200.0, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- vengeance_demon_hunter[212613] #2: { 'type': APPLY_AURA, 'subtype': MOD_GLOBAL_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'target': TARGET_UNIT_CASTER, }
        -- inertia[427641] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.67, 'points': 18.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- inertia[427641] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.67, 'points': 18.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- momentum[208628] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 6.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- momentum[208628] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 6.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
    },

    -- [162243] Quickly attack for $s2 Physical damage.; Generates $?a258876[${$m3+$258876s3} to ${$M3+$258876s4}][$m3 to $M3] Fury.
    demons_bite_344859 = {
        id = 344859,
        cast = 0.0,
        cooldown = 0.0,
        gcd = "global",

        startsCombat = true,

        -- Effects:
        -- #0: { 'type': TRIGGER_SPELL, 'subtype': NONE, 'trigger_spell': 162243, 'triggers': demons_bite, 'target': TARGET_UNIT_TARGET_ENEMY, }

        -- Affected by:
        -- insatiable_hunger[258876] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'ap_bonus': 0.1, 'points': 50.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- hungering_glaive[244785] #1: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'points': 200.0, 'target': TARGET_UNIT_TARGET_ENEMY, }
        from = "class",
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
        -- any_means_necessary[388114] #0: { 'type': APPLY_AURA, 'subtype': MOD_ABILITY_SCHOOL_MASK, 'value': 127, 'schools': ['physical', 'holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], 'target': TARGET_UNIT_CASTER, }
        -- demon_hide[428241] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- demon_hide[428241] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
    },

    -- Slash all enemies in front of you for $s1 Chaos damage, and increase the damage your Chaos Strike and Blade Dance deal to them by $320338s1% for $320338d. Deals reduced damage beyond $s2 targets.
    essence_break = {
        id = 258860,
        cast = 0.0,
        cooldown = 40.0,
        gcd = "global",

        talent = "essence_break",
        startsCombat = true,

        -- Effects:
        -- #0: { 'type': SCHOOL_DAMAGE, 'subtype': NONE, 'attributes': ['Area Effects Use Target Radius'], 'ap_bonus': 2.5, 'pvp_multiplier': 0.9, 'variance': 0.05, 'radius': 10.0, 'target': TARGET_UNIT_CONE_CASTER_TO_DEST_ENEMY, }
        -- #1: { 'type': DUMMY, 'subtype': NONE, }

        -- Affected by:
        -- mastery_demonic_presence[185164] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 1.8, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- mastery_demonic_presence[185164] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 1.8, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
    },

    -- Blasts all enemies in front of you,$?s320415[ dealing guaranteed critical strikes][] for up to $<dmg> Chaos damage over $d. Deals reduced damage beyond $s5 targets.$?s343311[; When Eye Beam finishes fully channeling, your Haste is increased by an additional $343312s1% for $343312d.][]
    eye_beam = {
        id = 198013,
        cast = 2.0,
        channeled = true,
        cooldown = 40.0,
        gcd = "global",

        spend = 30,
        spendType = 'fury',

        talent = "eye_beam",
        startsCombat = false,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': PERIODIC_TRIGGER_SPELL, 'tick_time': 0.2, 'target': TARGET_UNIT_CASTER, }
        -- #1: { 'type': APPLY_AURA, 'subtype': MOD_DECREASE_SPEED, 'points': -200.0, 'target': TARGET_UNIT_CASTER, }
        -- #2: { 'type': APPLY_AURA, 'subtype': DUMMY, 'points': 50.0, 'target': TARGET_UNIT_CASTER, }
        -- #3: { 'type': APPLY_AURA, 'subtype': MOD_POWER_REGEN, 'value': 17, 'schools': ['physical', 'frost'], 'target': TARGET_UNIT_CASTER, }
        -- #4: { 'type': APPLY_AURA, 'subtype': DUMMY, 'points': 5.0, 'target': TARGET_UNIT_CASTER, }
        -- #5: { 'type': APPLY_AURA, 'subtype': MECHANIC_IMMUNITY, 'target': TARGET_UNIT_CASTER, 'mechanic': 26, }

        -- Affected by:
        -- blind_fury[203550] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
        -- blind_fury[203550] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
    },

    -- Unleash a torrent of Fel energy, rapidly consuming Fury to inflict $258926s1 Chaos damage to all enemies within $258926A1 yds, lasting $d or until Fury is depleted. Deals reduced damage beyond $258926s2 targets.
    fel_barrage = {
        id = 258925,
        cast = 0.0,
        cooldown = 90.0,
        gcd = "global",

        spend = 10,
        spendType = 'fury',

        talent = "fel_barrage",
        startsCombat = false,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': PERIODIC_TRIGGER_SPELL, 'tick_time': 0.25, 'trigger_spell': 258926, 'target': TARGET_UNIT_CASTER, }
    },

    -- Impales the target for $s1 Chaos damage and stuns them for $d.
    fel_eruption = {
        id = 211881,
        cast = 0.0,
        cooldown = 30.0,
        gcd = "global",

        spend = 10,
        spendType = 'fury',

        startsCombat = true,

        -- Effects:
        -- #0: { 'type': SCHOOL_DAMAGE, 'subtype': NONE, 'ap_bonus': 0.3276, 'variance': 0.05, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #1: { 'type': APPLY_AURA, 'subtype': MOD_STUN, 'mechanic': stunned, 'target': TARGET_UNIT_TARGET_ENEMY, }

        -- Affected by:
        -- mastery_demonic_presence[185164] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 1.8, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- mastery_demonic_presence[185164] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 1.8, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- havoc_demon_hunter[212612] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- havoc_demon_hunter[212612] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- havoc_demon_hunter[212612] #11: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- havoc_demon_hunter[212612] #12: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- vengeance_demon_hunter[212613] #7: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -60.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- inertia[427641] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.67, 'points': 18.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- inertia[427641] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.67, 'points': 18.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- momentum[208628] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 6.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- momentum[208628] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 6.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
    },

    -- Deals up to $s2% of the target's total health in Chaos damage.
    fel_lance = {
        id = 206966,
        color = 'pvp_talent',
        cast = 0.0,
        cooldown = 0.0,
        gcd = "global",

        startsCombat = true,

        -- Effects:
        -- #0: { 'type': DAMAGE_FROM_MAX_HEALTH_PCT, 'subtype': NONE, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #1: { 'type': DUMMY, 'subtype': NONE, }

        -- Affected by:
        -- mastery_demonic_presence[185164] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 1.8, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- mastery_demonic_presence[185164] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 1.8, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- havoc_demon_hunter[212612] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- havoc_demon_hunter[212612] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- havoc_demon_hunter[212612] #11: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- havoc_demon_hunter[212612] #12: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- inertia[427641] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.67, 'points': 18.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- inertia[427641] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.67, 'points': 18.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- momentum[208628] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 6.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- momentum[208628] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 6.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
    },

    -- Rush forward, incinerating anything in your path for $192611s1 Chaos damage.
    fel_rush = {
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
    },

    -- [195072] Rush forward, incinerating anything in your path for $192611s1 Chaos damage.
    fel_rush_344865 = {
        id = 344865,
        cast = 0.0,
        cooldown = 1.0,
        gcd = "global",

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': TRIGGER_SPELL, 'subtype': NONE, 'trigger_spell': 195072, 'triggers': fel_rush, 'target': TARGET_UNIT_CASTER, }

        -- Affected by:
        -- blazing_path[320416] #0: { 'type': APPLY_AURA, 'subtype': MOD_MAX_CHARGES, 'points': 1.0, 'target': TARGET_UNIT_CASTER, }
        from = "class",
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
        -- havoc_demon_hunter[212612] #3: { 'type': APPLY_AURA, 'subtype': MOD_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'target': TARGET_UNIT_CASTER, }
        -- any_means_necessary[388114] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 1.8, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- any_means_necessary[388114] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 1.8, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- vengeance_demon_hunter[212613] #3: { 'type': APPLY_AURA, 'subtype': MOD_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'target': TARGET_UNIT_CASTER, }
        -- vengeance_demon_hunter[212613] #6: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -35.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
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

    -- Launch two demonic glaives in a whirlwind of energy, causing ${14*$342857s1} Chaos damage over $d to all nearby enemies. Deals reduced damage beyond $s2 targets.
    glaive_tempest = {
        id = 342817,
        cast = 0.0,
        cooldown = 25.0,
        gcd = "global",

        spend = 30,
        spendType = 'fury',

        talent = "glaive_tempest",
        startsCombat = false,

        -- Effects:
        -- #0: { 'type': CREATE_AREATRIGGER, 'subtype': NONE, 'value': 21832, 'schools': ['nature', 'arcane'], 'target': TARGET_DEST_CASTER_GROUND, }
        -- #1: { 'type': DUMMY, 'subtype': NONE, }

        -- Affected by:
        -- havoc_demon_hunter[212612] #3: { 'type': APPLY_AURA, 'subtype': MOD_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'target': TARGET_UNIT_CASTER, }
        -- vengeance_demon_hunter[212613] #3: { 'type': APPLY_AURA, 'subtype': MOD_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'target': TARGET_UNIT_CASTER, }
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

    -- Strike an enemy with a glaive of fel energy, dealing $s1 Chaos damage and weakening them to your $?a203555[Demon Blades][Demon's Bite].; For $d, $?a203555[Demon Blades][Demon's Bite] will generate the maximum amount of Fury and deal $?a203555[$s3%][$s2%] increased damage against them.
    hungering_glaive = {
        id = 244785,
        cast = 0.0,
        cooldown = 10.0,
        gcd = "global",

        spend = 40,
        spendType = 'fury',

        startsCombat = true,

        -- Effects:
        -- #0: { 'type': SCHOOL_DAMAGE, 'subtype': NONE, 'ap_bonus': 1.5921, 'variance': 0.05, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #1: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'points': 200.0, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #2: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'points': 200.0, 'target': TARGET_UNIT_TARGET_ENEMY, }

        -- Affected by:
        -- mastery_demonic_presence[185164] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 1.8, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- mastery_demonic_presence[185164] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 1.8, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
    },

    -- Strike an enemy with a glaive of fel energy, dealing $s1 Chaos damage
    hungering_glaive_257938 = {
        id = 257938,
        cast = 0.0,
        cooldown = 9.0,
        gcd = "global",

        spend = 30,
        spendType = 'fury',

        startsCombat = true,

        -- Effects:
        -- #0: { 'type': SCHOOL_DAMAGE, 'subtype': NONE, 'ap_bonus': 1.5921, 'variance': 0.05, 'target': TARGET_UNIT_TARGET_ENEMY, }

        -- Affected by:
        -- mastery_demonic_presence[185164] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 1.8, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- mastery_demonic_presence[185164] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 1.8, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- havoc_demon_hunter[212612] #3: { 'type': APPLY_AURA, 'subtype': MOD_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'target': TARGET_UNIT_CASTER, }
        -- vengeance_demon_hunter[212613] #3: { 'type': APPLY_AURA, 'subtype': MOD_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'target': TARGET_UNIT_CASTER, }
        from = "affected_by_mastery",
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
        -- havoc_demon_hunter[212612] #3: { 'type': APPLY_AURA, 'subtype': MOD_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'target': TARGET_UNIT_CASTER, }
        -- immolation_aura[320377] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 4000.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
        -- infernal_armor[320331] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_5_VALUE, }
        -- a_fire_inside[427775] #0: { 'type': APPLY_AURA, 'subtype': MOD_MAX_CHARGES, 'points': 1.0, 'target': TARGET_UNIT_CASTER, }
        -- vengeance_demon_hunter[212613] #3: { 'type': APPLY_AURA, 'subtype': MOD_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'target': TARGET_UNIT_CASTER, }
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

    -- Deals up to $m2% of the target's maximum health in Chaos damage, and increases the mana cost of their spells by $m3% for $d.
    mana_break = {
        id = 203704,
        color = 'pvp_talent',
        cast = 0.0,
        cooldown = 60.0,
        gcd = "global",

        spend = 50,
        spendType = 'fury',

        startsCombat = true,

        -- Effects:
        -- #0: { 'type': SCHOOL_DAMAGE, 'subtype': NONE, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #1: { 'type': DUMMY, 'subtype': NONE, }
        -- #2: { 'type': APPLY_AURA, 'subtype': UNKNOWN, 'points': 30.0, 'target': TARGET_UNIT_TARGET_ENEMY, }

        -- Affected by:
        -- mastery_demonic_presence[185164] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 1.8, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- mastery_demonic_presence[185164] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 1.8, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- havoc_demon_hunter[212612] #2: { 'type': APPLY_AURA, 'subtype': MOD_GLOBAL_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'target': TARGET_UNIT_CASTER, }
        -- demon_hide[428241] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- demon_hide[428241] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- vengeance_demon_hunter[212613] #2: { 'type': APPLY_AURA, 'subtype': MOD_GLOBAL_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'target': TARGET_UNIT_CASTER, }
    },

    -- Leap into the air and land with explosive force, dealing $200166s2 Chaos damage to enemies within 8 yds, and stunning them for $200166d. Players are Dazed for $247121d instead.; Upon landing, you are transformed into a hellish demon for $162264d, $?s320645[immediately resetting the cooldown of your Eye Beam and Blade Dance abilities, ][]greatly empowering your Chaos Strike and Blade Dance abilities and gaining $162264s4% Haste$?(s235893&s204909)[, $162264s5% Versatility, and $162264s3% Leech]?(s235893&!s204909[ and $162264s5% Versatility]?(s204909&!s235893)[ and $162264s3% Leech][].
    metamorphosis = {
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
        -- havoc_demon_hunter[212612] #2: { 'type': APPLY_AURA, 'subtype': MOD_GLOBAL_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'target': TARGET_UNIT_CASTER, }
        -- rush_of_chaos[320421] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -30000.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
        -- soul_rending[204909] #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 6.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_3_VALUE, }
        -- vengeance_demon_hunter[212613] #2: { 'type': APPLY_AURA, 'subtype': MOD_GLOBAL_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'target': TARGET_UNIT_CASTER, }
    },

    -- Slip into the nether, increasing movement speed by $s3% and becoming immune to damage, but unable to attack. Lasts $d.
    netherwalk = {
        id = 196555,
        cast = 0.0,
        cooldown = 180.0,
        gcd = "global",

        talent = "netherwalk",
        startsCombat = false,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': DAMAGE_IMMUNITY, 'value': 127, 'schools': ['physical', 'holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], 'target': TARGET_UNIT_CASTER, }
        -- #1: { 'type': APPLY_AURA, 'subtype': MOD_PACIFY, 'target': TARGET_UNIT_CASTER, }
        -- #2: { 'type': APPLY_AURA, 'subtype': MOD_SPEED_NOT_STACK, 'points': 100.0, 'target': TARGET_UNIT_CASTER, }
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
        -- havoc_demon_hunter[212612] #2: { 'type': APPLY_AURA, 'subtype': MOD_GLOBAL_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'target': TARGET_UNIT_CASTER, }
        -- quickened_sigils[209281] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -1000.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
        -- any_means_necessary[388114] #0: { 'type': APPLY_AURA, 'subtype': MOD_ABILITY_SCHOOL_MASK, 'value': 127, 'schools': ['physical', 'holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], 'target': TARGET_UNIT_CASTER, }
        -- sigil_mastery[211489] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -25.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
        -- vengeance_demon_hunter[212613] #2: { 'type': APPLY_AURA, 'subtype': MOD_GLOBAL_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'target': TARGET_UNIT_CASTER, }
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
        -- any_means_necessary[388114] #0: { 'type': APPLY_AURA, 'subtype': MOD_ABILITY_SCHOOL_MASK, 'value': 127, 'schools': ['physical', 'holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], 'target': TARGET_UNIT_CASTER, }
        -- sigil_mastery[211489] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -25.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
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
        -- sigil_mastery[211489] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -25.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
    },

    -- Carve into the soul of your target, dealing ${$s2+$214743s1} Fire damage and an additional $o1 Fire damage over $d.  Immediately shatters $s3 Lesser Soul Fragments from the target and $s4 additional Lesser Soul Fragment every $t1 sec.
    soul_carver = {
        id = 207407,
        cast = 0.0,
        cooldown = 60.0,
        gcd = "global",

        startsCombat = true,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': PERIODIC_DAMAGE, 'tick_time': 1.0, 'ap_bonus': 0.447, 'variance': 0.05, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #1: { 'type': SCHOOL_DAMAGE, 'subtype': NONE, 'ap_bonus': 2.06, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #2: { 'type': TRIGGER_SPELL, 'subtype': NONE, 'trigger_spell': 214743, 'points': 3.0, }
        -- #3: { 'type': DUMMY, 'subtype': NONE, 'target': TARGET_UNIT_CASTER, }

        -- Affected by:
        -- any_means_necessary[388114] #0: { 'type': APPLY_AURA, 'subtype': MOD_ABILITY_SCHOOL_MASK, 'value': 127, 'schools': ['physical', 'holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], 'target': TARGET_UNIT_CASTER, }
        -- vengeance_demon_hunter[212613] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- vengeance_demon_hunter[212613] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
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
        from = "class",
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
        -- havoc_demon_hunter[212612] #2: { 'type': APPLY_AURA, 'subtype': MOD_GLOBAL_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'target': TARGET_UNIT_CASTER, }
        -- spectral_sight[320379] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -30000.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
        -- vengeance_demon_hunter[212613] #2: { 'type': APPLY_AURA, 'subtype': MOD_GLOBAL_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'target': TARGET_UNIT_CASTER, }
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

    -- Throw a demonic glaive at the target, dealing $337819s1 Physical damage. The glaive can ricochet to $?$s320386[${$337819x1-1} additional enemies][an additional enemy] within 10 yards.; 
    throw_glaive = {
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
        -- havoc_demon_hunter[212612] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- havoc_demon_hunter[212612] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- havoc_demon_hunter[212612] #2: { 'type': APPLY_AURA, 'subtype': MOD_GLOBAL_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'target': TARGET_UNIT_CASTER, }
        -- havoc_demon_hunter[212612] #3: { 'type': APPLY_AURA, 'subtype': MOD_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'target': TARGET_UNIT_CASTER, }
        -- havoc_demon_hunter[212612] #11: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- havoc_demon_hunter[212612] #12: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- bouncing_glaives[320386] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 1.0, 'target': TARGET_UNIT_CASTER, 'modifies': CHAINED_TARGETS, }
        -- champion_of_the_glaive[429211] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': RANGE, }
        -- champion_of_the_glaive[429211] #1: { 'type': APPLY_AURA, 'subtype': MOD_MAX_CHARGES, 'points': 1.0, 'target': TARGET_UNIT_CASTER, }
        -- master_of_the_glaive[389763] #1: { 'type': APPLY_AURA, 'subtype': MOD_MAX_CHARGES, 'points': 1.0, 'target': TARGET_UNIT_CASTER, }
        -- accelerated_blade[391275] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -19.0, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_20, }
        -- accelerated_blade[391275] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 60.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- serrated_glaive[390155] #0: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- vengeance_demon_hunter[212613] #2: { 'type': APPLY_AURA, 'subtype': MOD_GLOBAL_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'target': TARGET_UNIT_CASTER, }
        -- vengeance_demon_hunter[212613] #3: { 'type': APPLY_AURA, 'subtype': MOD_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'target': TARGET_UNIT_CASTER, }
        -- inertia[427641] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.67, 'points': 18.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- inertia[427641] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.67, 'points': 18.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- momentum[208628] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 6.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- momentum[208628] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 6.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
    },

    -- Throw a demonic glaive at the target, dealing $s1 Physical damage. The glaive can ricochet to ${$x1-1} additional enemies within 10 yards.
    throw_glaive_211813 = {
        id = 211813,
        cast = 0.0,
        cooldown = 10.0,
        gcd = "global",

        startsCombat = true,
        interrupt = true,

        -- Effects:
        -- #0: { 'type': DUMMY, 'subtype': NONE, 'chain_targets': 3, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #1: { 'type': SCHOOL_DAMAGE, 'subtype': NONE, 'chain_targets': 3, 'ap_bonus': 0.41768998, 'variance': 0.05, 'target': TARGET_UNIT_TARGET_ENEMY, }

        -- Affected by:
        -- mastery_demonic_presence[185164] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 1.8, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- mastery_demonic_presence[185164] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 1.8, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- bouncing_glaives[320386] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 1.0, 'target': TARGET_UNIT_CASTER, 'modifies': CHAINED_TARGETS, }
        -- champion_of_the_glaive[429211] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': RANGE, }
        -- accelerated_blade[391275] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -19.0, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_20, }
        -- accelerated_blade[391275] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 60.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- serrated_glaive[390155] #0: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'target': TARGET_UNIT_TARGET_ENEMY, }
        from = "affected_by_mastery",
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
        -- tactical_retreat[389688] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -5000.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
        -- evasive_action[444929] #0: { 'type': APPLY_AURA, 'subtype': IGNORE_SPELL_COOLDOWN, 'target': TARGET_UNIT_CASTER, }
    },

} )