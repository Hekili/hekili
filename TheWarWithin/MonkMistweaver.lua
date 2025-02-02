-- MonkMistweaver.lua
-- January 2025

if UnitClassBase( "player" ) ~= "MONK" then return end

local addon, ns = ...
local Hekili = _G[ addon ]
local class, state = Hekili.Class, Hekili.State

local strformat = string.format

local spec = Hekili:NewSpecialization( 270 )
local GetSpellCount = C_Spell.GetSpellCastCount

spec:RegisterResource( Enum.PowerType.Mana )

-- Talents
spec:RegisterTalents( {
    -- Monk
    against_all_odds              = { 101253, 450986, 1 }, -- Flurry Strikes increase your Agility by 1% for 5 sec, stacking up to 20 times.
    ancient_arts                  = { 101184, 344359, 2 }, -- Reduces the cooldown of Paralysis by 15 sec and the cooldown of Leg Sweep by 10 sec.
    bounce_back                   = { 101177, 389577, 1 }, -- When a hit deals more than 12% of your maximum health, reduce all damage you take by 40% for 6 sec. This effect cannot occur more than once every 30 seconds.
    bounding_agility              = { 101161, 450520, 1 }, -- Roll and Chi Torpedo travel a small distance further.
    calming_presence              = { 101153, 388664, 1 }, -- Reduces all damage taken by 6%.
    celerity                      = { 101183, 115173, 1 }, -- Reduces the cooldown of Roll by 5 sec and increases its maximum number of charges by 1.
    celestial_determination       = { 101180, 450638, 1 }, -- While your Celestial is active, you cannot be slowed below 90% normal movement speed.
    chi_burst                     = { 102432, 123986, 1 }, -- Hurls a torrent of Chi energy up to 40 yds forward, dealing 29,046 Nature damage to all enemies, and 20,243 healing to the Monk and all allies in its path. Healing and damage reduced beyond 5 targets. 
    chi_proficiency               = { 101169, 450426, 2 }, -- Magical damage done increased by 5% and healing done increased by 5%.
    chi_torpedo                   = { 101183, 115008, 1 }, -- Torpedoes you forward a long distance and increases your movement speed by 30% for 10 sec, stacking up to 2 times.
    chi_wave                      = { 102432, 450391, 1 }, -- Every 15 sec, your next Rising Sun Kick or Vivify releases a wave of Chi energy that flows through friends and foes, dealing 2,074 Nature damage or 5,520 healing. Bounces up to 7 times to targets within 25 yards.
    clash                         = { 101154, 324312, 1 }, -- You and the target charge each other, meeting halfway then rooting all targets within 6 yards for 4 sec.
    crashing_momentum             = { 101149, 450335, 1 }, -- Targets you Roll through are snared by 40% for 5 sec.
    dance_of_the_wind             = { 101139, 432181, 1 }, -- Your physical damage taken is reduced by 10% and an additional 10% every 4 sec until you receive a physical attack.
    diffuse_magic                 = { 101165, 122783, 1 }, -- Reduces magic damage you take by 60% for 6 sec, and transfers all currently active harmful magical effects on you back to their original caster if possible.
    disable                       = { 101149, 116095, 1 }, -- Reduces the target's movement speed by 50% for 15 sec, duration refreshed by your melee attacks.
    efficient_training            = { 101251, 450989, 1 }, -- Energy spenders deal an additional 20% damage. Every 50 Energy spent reduces the cooldown of Storm, Earth, and Fire by 1 sec.
    elusive_mists                 = { 101144, 388681, 1 }, -- Reduces all damage taken by you and your target while channeling Soothing Mists by 6%.
    energy_transfer               = { 101151, 450631, 1 }, -- Successfully interrupting an enemy reduces the cooldown of Paralysis and Roll by 5 sec.
    escape_from_reality           = { 101176, 394110, 1 }, -- After you use Transcendence: Transfer, you can use Transcendence: Transfer again within 10 sec, ignoring its cooldown.
    expeditious_fortification     = { 101174, 388813, 1 }, -- Fortifying Brew cooldown reduced by 30 sec.
    fast_feet                     = { 101185, 388809, 1 }, -- Rising Sun Kick deals 70% increased damage. Spinning Crane Kick deals 10% additional damage. 
    fatal_touch                   = { 101178, 394123, 1 }, -- Touch of Death increases your damage by 5% for 30 sec after being cast and its cooldown is reduced by 90 sec.
    ferocity_of_xuen              = { 101166, 388674, 1 }, -- Increases all damage dealt by 2%.
    flow_of_chi                   = { 101170, 450569, 1 }, -- You gain a bonus effect based on your current health. Above 90% health: Movement speed increased by 5%. This bonus stacks with similar effects. Between 90% and 35% health: Damage taken reduced by 5%. Below 35% health: Healing received increased by 10%. 
    flurry_strikes                = { 101248, 450615, 1 }, -- Every 61,118 damage you deal generates a Flurry Charge. For each 240 energy you spend, unleash all Flurry Charges, dealing 6,224 Physical damage per charge. 
    fortifying_brew               = { 101173, 115203, 1 }, -- Turns your skin to stone for 15 sec, increasing your current and maximum health by 20%, reducing all damage you take by 20%.
    grace_of_the_crane            = { 101146, 388811, 1 }, -- Increases all healing taken by 6%.
    hasty_provocation             = { 101158, 328670, 1 }, -- Provoked targets move towards you at 50% increased speed.
    healing_winds                 = { 101171, 450560, 1 }, -- Transcendence: Transfer immediately heals you for 10% of your maximum health.
    high_impact                   = { 101247, 450982, 1 }, -- Enemies who die within 10 sec of being damaged by a Flurry Strike explode, dealing 10,373 physical damage to uncontrolled enemies within 8 yds.
    improved_detox                = { 101089, 388874, 1 }, -- Detox additionally removes all Poison and Disease effects.
    improved_touch_of_death       = { 101140, 322113, 1 }, -- Touch of Death can now be used on targets with less than 15% health remaining, dealing 35% of your maximum health in damage.
    ironshell_brew                = { 101174, 388814, 1 }, -- Increases your maximum health by an additional 10% and your damage taken is reduced by an additional 10% while Fortifying Brew is active.
    jade_walk                     = { 101160, 450553, 1 }, -- While out of combat, your movement speed is increased by 15%.
    lead_from_the_front           = { 101254, 450985, 1 }, -- Chi Burst, Chi Wave, and Expel Harm now heal you for 20% of damage dealt.
    lighter_than_air              = { 101168, 449582, 1 }, -- Roll causes you to become lighter than air, allowing you to double jump to dash forward a short distance once within 5 sec, but the cooldown of Roll is increased by 2 sec.
    martial_instincts             = { 101179, 450427, 2 }, -- Increases your Physical damage done by 5% and Avoidance increased by 4%.
    martial_precision             = { 101246, 450990, 1 }, -- Your attacks penetrate 12% armor.
    one_versus_many               = { 101250, 450988, 1 }, -- Damage dealt by Fists of Fury and Keg Smash counts as double towards Flurry Charge generation. Fists of Fury damage increased by 15%. Keg Smash damage increased by 35%.
    paralysis                     = { 101142, 115078, 1 }, -- Incapacitates the target for 1 min. Limit 1. Damage may cancel the effect.
    peace_and_prosperity          = { 101163, 450448, 1 }, -- Reduces the cooldown of Ring of Peace by 5 sec and Song of Chi-Ji's cast time is reduced by 0.5 sec.
    predictive_training           = { 101245, 450992, 1 }, -- When you dodge or parry an attack, reduce all damage taken by 10% for the next 6 sec.
    pressure_points               = { 101141, 450432, 1 }, -- Paralysis now removes all Enrage effects from its target.
    pride_of_pandaria             = { 101247, 450979, 1 }, -- Flurry Strikes have 15% additional chance to critically strike.
    profound_rebuttal             = { 101135, 392910, 1 }, -- Expel Harm's critical healing is increased by 15%.
    protect_and_serve             = { 101254, 450984, 1 }, -- Your Vivify always heals you for an additional 30% of its total value.
    quick_footed                  = { 101158, 450503, 1 }, -- The duration of snare effects on you is reduced by 20%.
    ring_of_peace                 = { 101136, 116844, 1 }, -- Form a Ring of Peace at the target location for 5 sec. Enemies that enter will be ejected from the Ring.
    rising_sun_kick               = { 101186, 107428, 1 }, -- Kick upwards, dealing 52,240 Physical damage. Applies Renewing Mist for 6 seconds to an ally within 40 yds
    rushing_reflexes              = { 101154, 450154, 1 }, -- Your heightened reflexes allow you to react swiftly to the presence of enemies, causing you to quickly lunge to the nearest enemy in front of you within 10 yards after you Roll.
    save_them_all                 = { 101157, 389579, 1 }, -- When your healing spells heal an ally whose health is below 35% maximum health, you gain an additional 10% healing for the next 4 sec.
    song_of_chiji                 = { 101136, 198898, 1 }, -- Conjures a cloud of hypnotic mist that slowly travels forward. Enemies touched by the mist fall asleep, Disoriented for 20 sec.
    soothing_mist                 = { 101143, 115175, 1 }, -- Heals the target for 133,673 over 7.4 sec. While channeling, Enveloping Mist and Vivify may be cast instantly on the target. Each heal has a chance to cause a Gust of Mists on the target.
    spear_hand_strike             = { 101152, 116705, 1 }, -- Jabs the target in the throat, interrupting spellcasting and preventing any spell from that school of magic from being cast for 3 sec.
    spirits_essence               = { 101138, 450595, 1 }, -- Transcendence: Transfer snares targets within 10 yds by 70% for 4 sec when cast.
    strength_of_spirit            = { 101135, 387276, 1 }, -- Expel Harm's healing is increased by up to 30%, based on your missing health.
    summon_jade_serpent_statue    = { 101164, 115313, 1 }, -- Summons a Jade Serpent Statue at the target location. When you channel Soothing Mist, the statue will also begin to channel Soothing Mist on your target, healing for 59,675 over 7.4 sec.
    swift_art                     = { 101155, 450622, 1 }, -- Roll removes a snare effect once every 30 sec.
    tiger_tail_sweep              = { 101182, 264348, 1 }, -- Increases the range of Leg Sweep by 4 yds.
    tigers_lust                   = { 101147, 116841, 1 }, -- Increases a friendly target's movement speed by 70% for 6 sec and removes all roots and snares.
    transcendence                 = { 101167, 101643, 1 }, -- Split your body and spirit, leaving your spirit behind for 15 min. Use Transcendence: Transfer to swap locations with your spirit.
    transcendence_linked_spirits  = { 101176, 434774, 1 }, -- Transcendence now tethers your spirit onto an ally for 1 |4hour:hrs;. Use Transcendence: Transfer to teleport to your ally's location.
    veterans_eye                  = { 101249, 450987, 1 }, -- Striking the same target 5 times within 2 sec grants 1% Haste, stacking up to 10 times.
    vigilant_watch                = { 101244, 450993, 1 }, -- Blackout Kick deals an additional 20% critical damage and increases the damage of your next set of Flurry Strikes by 10%.
    vigorous_expulsion            = { 101156, 392900, 1 }, -- Expel Harm's healing increased by 5% and critical strike chance increased by 15%. 
    vivacious_vivification        = { 101145, 388812, 1 }, -- Every 10 sec, your next Vivify becomes instant and its healing is increased by 20%. 
    whirling_steel                = { 101245, 450991, 1 }, -- When your health drops below 50%, summon Whirling Steel, increasing your parry chance and avoidance by 15% for 6 sec. This effect can not occur more than once every 180 sec.
    winds_reach                   = { 101148, 450514, 1 }, -- The range of Disable is increased by 5 yds. The duration of Crashing Momentum is increased by 3 sec and its snare now reduces movement speed by an additional 20%.
    windwalking                   = { 101175, 157411, 1 }, -- You and your allies within 10 yards have 10% increased movement speed. Stacks with other similar effects.
    wisdom_of_the_wall            = { 101252, 450994, 1 }, -- Every 10 Flurry Strikes, become infused with the Wisdom of the Wall, gaining one of the following effects for 16 sec. Critical strike damage increased by 30%. Dodge and Critical Strike chance increased by 25% of your Versatility bonus. Flurry Strikes deal 16,597 Shadow damage to all uncontrolled enemies within 6 yds. Effect of your Mastery increased by 25%. 
    yulons_grace                  = { 101165, 414131, 1 }, -- Find resilience in the flow of chi in battle, gaining a magic absorb shield for 1.0% of your max health every 3 sec in combat, stacking up to 10%.

    -- Mistweaver
    awakened_jadefire             = { 101104, 388779, 1 }, -- Your abilities reset Jadefire Stomp 100% more often. While within Jadefire Stomp, your Tiger Palms strike twice, your Blackout Kicks strike an additional 2 targets at 20% effectiveness, and your Spinning Crane Kick heals 3 nearby allies for 110% of the damage done.
    burst_of_life                 = { 101098, 399226, 1 }, -- When Life Cocoon expires, it releases a burst of mist that restores 85,913 health to 3 nearby allies.
    calming_coalescence           = { 101095, 388218, 1 }, -- The absorb amount of Life Cocoon is increased by 80%.
    celestial_harmony             = { 101128, 343655, 1 }, -- While active, Yu'lon and Chi'Ji heal up to 5 nearby targets with Enveloping Breath when you cast Enveloping Mist, healing for 15,448 over 7 sec, and increasing the healing they receive from you by 10%. When activated, Yu'lon and Chi'Ji apply Chi Cocoons to 5 targets within 40 yds, absorbing 84,432 damage for 10 sec.
    chi_harmony                   = { 101121, 448392, 1 }, -- Renewing Mist increases its target's healing received from you by 50% for the first 8 sec of its duration, but cannot jump to a new target during this time.
    chrysalis                     = { 101098, 202424, 1 }, -- Reduces the cooldown of Life Cocoon by 45 sec.
    crane_style                   = { 101097, 446260, 1 }, -- Rising Sun Kick now kicks up a Gust of Mist to heal 2 allies within 40 yds for 18,333. Spinning Crane Kick and Blackout Kick have a chance to kick up a Gust of Mist to heal 1 ally within 40 yds for 18,333. 
    dance_of_chiji                = { 101106, 438439, 1 }, -- Your spells and abilities have a chance to make your next Spinning Crane Kick deal an additional 400% damage.
    dancing_mists                 = { 101112, 388701, 1 }, -- Renewing Mist has a 8% chance to immediately spread to an additional target when initially cast or when traveling to a new target.
    deep_clarity                  = { 101122, 446345, 1 }, -- After you fully consume Thunder Focus Tea, your next Vivify triggers Zen Pulse.
    emperors_favor                = { 101118, 471761, 1 }, -- Sheilun's Gift's healing is increased by 150% and its cast time is reduced by 100%, but it now only heals a single ally.
    energizing_brew               = { 101130, 422031, 1 }, -- Mana Tea now channels 50% faster and generates 20% more Mana.
    enveloping_mist               = { 101134, 124682, 1 }, -- Wraps the target in healing mists, healing for 46,979 over 7 sec, and increasing healing received from your other spells by 40%. Applies Renewing Mist for 6 seconds to an ally within 40 yds.
    focused_thunder               = { 101115, 197895, 1 }, -- Thunder Focus Tea now empowers your next 2 spells.
    gift_of_the_celestials        = { 101113, 388212, 1 }, -- Reduces the cooldown of Invoke Chi-Ji, the Red Crane by 1 min, but decreases its duration to 12 sec. 
    healing_elixir                = { 101109, 122280, 1 }, -- You consume a healing elixir when you drop below 40% health or generate excess healing elixirs, instantly healing you for 15% of your maximum health. You generate 1 healing elixir every 30 sec, stacking up to 2 times.
    invigorating_mists            = { 101110, 274586, 1 }, -- Vivify heals all allies with your Renewing Mist active for 13,248, reduced beyond 5 allies. 
    invoke_chiji_the_red_crane    = { 101129, 325197, 1 }, -- Summon an effigy of Chi-Ji for 12 sec that kicks up 3 Gust of Mists when you Blackout Kick, Rising Sun Kick, or Spinning Crane Kick, healing up to 2 allies for 18,333, and reducing the cost and cast time of your next Enveloping Mist by 33%, stacking. Chi-Ji's presence makes you immune to movement impairing effects.
    invoke_yulon_the_jade_serpent = { 101129, 322118, 1 }, -- Summons an effigy of Yu'lon, the Jade Serpent for 12 sec. Yu'lon will heal injured allies with Soothing Breath, healing the target and up to 2 allies for 11,192 over 4.2 sec. Enveloping Mist costs 50% less mana while Yu'lon is active.
    invokers_delight              = { 101123, 388661, 1 }, -- You gain 20% haste for 8 sec after summoning your Celestial. 
    jade_bond                     = { 101113, 388031, 1 }, -- Chi Cocoons now apply Enveloping Mist for 4 sec when they expire or are consumed, and Chi-Ji's Gusts of Mists healing is increased by 40% and Yu'lon's Soothing Breath healing is increased by 500%.
    jade_empowerment              = { 101106, 467316, 1 }, -- Casting Thunder Focus Tea increases your next Crackling Jade Lightning's damage by 3,000% and causes it to chain to 4 additional enemies at 10% effectiveness.
    jadefire_stomp                = { 101101, 388193, 1 }, -- Strike the ground fiercely to expose a path of jade for 30 sec, dealing 11,759 Nature damage to up to 5 enemies, and restoring 24,250 health to up to 5 allies within 30 yds caught in the path. Your abilities have a 6% chance of resetting the cooldown of Jadefire Stomp while fighting within the path.
    jadefire_teachings            = { 101102, 467293, 1 }, -- After casting Jadefire Stomp or Thunder Focus Tea, Ancient Teachings transfers an additional 160% damage to healing for 15 sec. While Jadefire Teachings is active, your Stamina is increased by 5%.
    legacy_of_wisdom              = { 101118, 404408, 1 }, -- Sheilun's Gift heals 2 additional allies and its cast time is reduced by 0.5 sec.
    life_cocoon                   = { 101096, 116849, 1 }, -- Encases the target in a cocoon of Chi energy for 12 sec, absorbing 337,729 damage and increasing all healing over time received by 50%. Applies Renewing Mist and Enveloping Mist to the target.
    lifecycles                    = { 101130, 197915, 1 }, -- Vivify has a 20% chance to cause your next Rising Sun Kick or Enveloping Mist to generate 1 stack of Mana Tea. Enveloping Mist and Rising Sun Kick have a 20% chance to cause your next Vivify to generate 1 stack of Mana Tea.
    lotus_infusion                = { 101121, 458431, 1 }, -- Allies with Renewing Mist receive 10% more healing from you and Renewing Mist's duration is increased by 2 sec.
    mana_tea                      = { 101132, 115869, 1 }, -- For every 29,360 Mana you spend, you gain 1 stack of Mana Tea, with a chance equal to your critical strike chance to generate 1 extra stack. Mana Tea: Consumes 1 stack of Mana Tea per 0.2 sec to restore 3,600 Mana and reduces the Mana cost of your spells by 30% for 1.00 sec per stack of Mana Tea consumed after drinking. Can be cast while moving, but movement speed is reduced by 40% while channeling.
    mending_proliferation         = { 101125, 388509, 1 }, -- Each time Enveloping Mist heals, its healing bonus has a 50% chance to spread to an injured ally within 30 yds.
    mist_wrap                     = { 101093, 197900, 1 }, -- Increases Enveloping Mist's duration by 1 sec and its healing bonus by 10%.
    mists_of_life                 = { 101099, 388548, 1 }, -- Life Cocoon applies Renewing Mist and Enveloping Mist to the target. 
    misty_peaks                   = { 101114, 388682, 2 }, -- Renewing Mist's heal over time effect has a 5.0% chance to apply Enveloping Mist for 2 sec.
    overflowing_mists             = { 101094, 388511, 2 }, -- Your Enveloping Mists heal the target for 2.0% of their maximum health each time they take direct damage.
    peaceful_mending              = { 101116, 388593, 1 }, -- Allies targeted by Soothing Mist receive 40% more healing from your Enveloping Mist and Renewing Mist effects.
    peer_into_peace               = { 101127, 440008, 1 }, -- 5% of your overhealing done onto targets with Soothing Mist is spread to 3 nearby injured allies. Soothing Mist now follows the target of your Enveloping Mist or Vivify and its channel time is increased by 4 sec.
    pool_of_mists                 = { 101127, 173841, 1 }, -- Renewing Mist now has 3 charges and reduces the remaining cooldown of Rising Sun Kick by 1.0 sec. Rising Sun Kick now reduces the remaining cooldown of Renewing Mist by 1.0 sec.
    rapid_diffusion               = { 101111, 388847, 2 }, -- Rising Sun Kick and Enveloping Mist apply Renewing Mist for 6 seconds to an ally within 40 yds.
    refreshing_jade_wind          = { 101093, 457397, 1 }, -- Thunder Focus Tea summons a whirling tornado around you, causing 1,545 healing every 0.69 sec for 6 sec on to up to 5 allies within 10 yards. 
    refreshment                   = { 101095, 467270, 1 }, -- Life Cocoon grants up to 5 stacks of Mana Tea and applies 2 stacks of Healing Elixir to its target.
    renewing_mist                 = { 101107, 115151, 1 }, -- Surrounds the target with healing mists, restoring 27,933 health over 22 sec. If Renewing Mist heals a target past maximum health, it will travel to another injured ally within 20 yds.
    resplendent_mist              = { 101126, 388020, 2 }, -- Gust of Mists has a 30% chance to do 100% more healing.
    restoral                      = { 101131, 388615, 1 }, -- Heals all party and raid members within 40 yds for 159,576 and clears them of all harmful Poison and Disease effects. Castable while stunned. Healing reduced beyond 5 targets.
    revival                       = { 101131, 115310, 1 }, -- Heals all party and raid members within 40 yds for 159,576 and clears them of 3 harmful Magic, all Poison, and all Disease effects. Healing reduced beyond 5 targets.
    rising_mist                   = { 101117, 274909, 1 }, -- Rising Sun Kick heals all allies with your Renewing Mist and Enveloping Mist for 2,552, and extends those effects by 4 sec, up to 100% of their original duration.
    rushing_wind_kick             = { 101102, 467307, 1 }, -- Kick up a powerful gust of wind, dealing 130,600 Nature damage in a 25 yd cone to enemies in front of you, split evenly among them. Damage is increased by 6% for each target hit, up to 30%. Grants Rushing Winds for 4 sec, increasing Renewing Mist's healing by 100%.
    secret_infusion               = { 101124, 388491, 2 }, -- After using Thunder Focus Tea, your next spell gives 5% of a stat for 10 sec: Enveloping Mist: Critical strike Renewing Mist: Haste Vivify: Mastery Rising Sun Kick: Versatility Expel Harm: Versatility
    shaohaos_lessons              = { 101119, 400089, 1 }, -- Each time you cast Sheilun's Gift, you learn one of Shaohao's Lessons for up to 30 sec, with the duration based on how many clouds of mist are consumed. Lesson of Doubt: Your spells and abilities deal up to 40% more healing and damage to targets, based on their current health. Lesson of Despair: Your Critical Strike is increased by 30% while above 50% health. Lesson of Fear: Decreases your damage taken by 15% and increases your Haste by 20%. Lesson of Anger: 25% of the damage or healing you deal is duplicated every 4 sec.
    sheiluns_gift                 = { 101120, 399491, 1 }, -- Draws in all nearby clouds of mist, healing the friendly target and up to 2 nearby allies for 12,880 per cloud absorbed. A cloud of mist is generated every 8 sec while in combat.
    tea_of_plenty                 = { 101103, 388517, 1 }, -- Thunder Focus Tea also empowers 2 additional Enveloping Mist, Expel Harm, or Rising Sun Kick at random.
    tea_of_serenity               = { 101103, 393460, 1 }, -- Thunder Focus Tea also empowers 2 additional Renewing Mist, Enveloping Mist, or Vivify at random.
    tear_of_morning               = { 101117, 387991, 1 }, -- Casting Vivify or Enveloping Mist on a target with Renewing Mist has a 10% chance to spread the Renewing Mist to another target. Your Vivify healing through Renewing Mist is increased by 10% and your Enveloping Mist also heals allies with Renewing Mist for 12% of its healing.
    thunder_focus_tea             = { 101133, 116680, 1 }, -- Receive a jolt of energy, empowering your next spell cast: Enveloping Mist: Immediately heals for 33,257 and is instant cast. Renewing Mist: Duration increased by 10 sec. Vivify: No mana cost. Rising Sun Kick: Cooldown reduced by 9 sec. Expel Harm: Transfers 25% additional healing into damage and creates a Chi Cocoon absorbing 112,576 damage. 
    unison                        = { 101125, 388477, 1 }, -- Soothing Mist heals a second injured ally within 40 yds for 25% of the amount healed.
    uplifted_spirits              = { 101092, 388551, 1 }, -- Vivify critical strikes and Rising Sun Kicks reduce the remaining cooldown on Revival by 1 sec, and Revival heals targets for 15% of Revival's heal over 10 sec.
    veil_of_pride                 = { 101119, 400053, 1 }, -- Increases Sheilun's Gift cloud of mist generation to every 4 sec. 
    yulons_whisper                = { 101100, 388038, 1 }, -- While channeling Mana Tea you exhale the breath of Yu'lon, healing up to 5 allies within 15 yards for 4,850 every 0.2 sec.
    zen_pulse                     = { 101108, 446326, 1 }, -- Renewing Mist's heal over time has a chance to cause your next Vivify to also trigger a Zen Pulse on its target and all allies with Renewing Mist, healing them for 17,055 increased by 6% per Renewing Mist active, up to 30%.

    -- Master of Harmony
    aspect_of_harmony             = { 101223, 450508, 1, "master_of_harmony" }, -- Store vitality from 10% of your damage dealt and 30% of your healing. Vitality stored from overhealing is reduced. For 10 sec after casting Thunder Focus Tea your spells and abilities draw upon the stored vitality to deal 40% additional healing over 8 sec.
    balanced_stratagem            = { 101230, 450889, 1 }, -- Casting a Physical spell or ability increases the damage and healing of your next Fire or Nature spell or ability by 3%, and vice versa. Stacks up to 5.
    clarity_of_purpose            = { 101228, 451017, 1 }, -- Casting Vivify stores 9,403 vitality, increased based on your recent Gusts of Mist.
    coalescence                   = { 101227, 450529, 1 }, -- When Aspect of Harmony deals damage or heals, it has a chance to spread to a nearby target. When you directly attack or heal an affected target, it has a chance to intensify. Targets damaged or healed by your Aspect of Harmony take 20% increased damage or healing from you.
    endless_draught               = { 101225, 450892, 1 }, -- Thunder Focus Tea has 1 additional charge.
    harmonic_gambit               = { 101224, 450870, 1 }, -- During Aspect of Harmony, Rising Sun Kick, Blackout Kick, and Tiger Palm also withdraw vitality to damage enemies.
    manifestation                 = { 101222, 450875, 1 }, -- Chi Burst and Chi Wave deal 50% increased damage and healing.
    mantra_of_purity              = { 101229, 451036, 1 }, -- When cast on yourself, your single-target healing spells heal for 10% more and restore an additional 15,988 health over 6 sec.
    mantra_of_tenacity            = { 101229, 451029, 1 }, -- Fortifying Brew grants 20% Stagger.
    overwhelming_force            = { 101220, 451024, 1 }, -- Rising Sun Kick, Blackout Kick, and Tiger Palm deal 15% additional damage to enemies in a line in front of you. Damage reduced above 5 targets.
    path_of_resurgence            = { 101226, 450912, 1 }, -- Chi Wave increases vitality stored by 25% for 5 sec.
    purified_spirit               = { 101224, 450867, 1 }, -- When Aspect of Harmony ends, any remaining vitality is expelled as healing over 8 sec, split among nearby targets.
    roar_from_the_heavens         = { 101221, 451043, 1 }, -- Tiger's Lust grants 20% movement speed to up to 2 allies near its target.
    tigers_vigor                  = { 101221, 451041, 1 }, -- Casting Tiger's Lust reduces the remaining cooldown on Roll by 5 sec.
    way_of_a_thousand_strikes     = { 101226, 450965, 1 }, -- Rising Sun Kick, Blackout Kick, and Tiger Palm contribute 30% additional vitality.

    -- Conduit of the Celestials
    august_dynasty                = { 101235, 442818, 1 }, -- Casting Jadefire Stomp increases the damage or healing of your next Rising Sun Kick by 30% or Vivify by 50%. This effect can only activate once every 8 sec.
    celestial_conduit             = { 101243, 443028, 1, "conduit_of_the_celestials" }, -- The August Celestials empower you, causing you to radiate 465,318 healing onto up to 5 injured allies and 93,969 Nature damage onto enemies within 20 yds over 3.5 sec, split evenly among them. Healing and damage increased by 6% per target, up to 30%. You may move while channeling, but casting other healing or damaging spells cancels this effect.
    chijis_swiftness              = { 101240, 443566, 1 }, -- Your movement speed is increased by 75% during Celestial Conduit and by 15% for 3 sec after being assisted by any Celestial. 
    courage_of_the_white_tiger    = { 101242, 443087, 1 }, -- Tiger Palm and Vivify have a chance to cause Xuen to claw a nearby enemy for 38,511 Physical damage, healing a nearby ally for 200% of the damage done. Invoke Yu'lon, the Jade Serpent or Invoke Chi-Ji, the Red Crane guarantees your next cast activates this effect.
    flight_of_the_red_crane       = { 101234, 443255, 1 }, -- Refreshing Jade Wind and Spinning Crane Kick have a chance to cause Chi-Ji to grant you a stack of Mana Tea and quickly rush to 5 allies, healing each target for 13,324.
    heart_of_the_jade_serpent     = { 101237, 443294, 1 }, -- Sheilun's Gift calls upon Yu'lon to decrease the cooldown time of Renewing Mist, Rising Sun Kick, Life Cocoon, and Thunder Focus Tea by 75% for up to 8 sec, based on the clouds of mist consumed.
    inner_compass                 = { 101235, 443571, 1 }, -- You switch between alignments after an August Celestial assists you, increasing a corresponding secondary stat by 2%. Crane Stance: Haste Tiger Stance: Critical Strike Ox Stance: Versatility Serpent Stance: Mastery
    jade_sanctuary                = { 101238, 443059, 1 }, -- You heal for 10% of your maximum health instantly when you activate Celestial Conduit and receive 15% less damage for its duration. This effect lingers for an additional 8 sec after Celestial Conduit ends.
    niuzaos_protection            = { 101238, 442747, 1 }, -- Fortifying Brew grants you an absorb shield for 25% of your maximum health.
    restore_balance               = { 101233, 442719, 1 }, -- Gain Refreshing Jade Wind while Chi-Ji, the Red Crane or Yu'lon, the Jade Serpent is active.
    strength_of_the_black_ox      = { 101241, 443110, 1 }, -- After Xuen assists you, your next Enveloping Mist's cast time is reduced by 50% and causes Niuzao to grant an absorb shield to 5 nearby allies for 3% of your maximum health.
    temple_training               = { 101236, 442743, 1 }, -- The healing of Enveloping Mist and Vivify is increased by 6%.
    unity_within                  = { 101239, 443589, 1 }, -- Celestial Conduit can be recast once during its duration to call upon all of the August Celestials to assist you at 200% effectiveness. Unity Within is automatically cast when Celestial Conduit ends if not used before expiration.
    xuens_guidance                = { 101236, 442687, 1 }, -- Teachings of the Monastery has a 15% chance to refund a charge when consumed. The damage of Tiger Palm is increased by 10%.
    yulons_knowledge              = { 101233, 443625, 1 }, -- Refreshing Jade Wind's duration is increased by 6 sec.
} )

-- PvP Talents
spec:RegisterPvpTalents( { 
    absolute_serenity = 5642, -- (455945) 
    counteract_magic  =  679, -- (353502) 
    dematerialize     = 5398, -- (353361) 
    eminence          =   70, -- (353584) 
    feather_feet      = 5669, -- (474441) 
    grapple_weapon    = 3732, -- (233759) You fire off a rope spear, grappling the target's weapons and shield, returning them to you for 5 sec.
    healing_sphere    =  683, -- (205234) Coalesces a Healing Sphere out of the mists at the target location after 1.5 sec. If allies walk through it, they consume the sphere, healing themselves for 47,966 and dispelling all harmful periodic magic effects. Maximum of 3 Healing Spheres can be active by the Monk at any given time.
    jadefire_accord   = 5565, -- (406888) 
    mighty_ox_kick    = 5539, -- (202370) You perform a Mighty Ox Kick, hurling your enemy a distance behind you.
    peaceweaver       = 5395, -- (353313) 
    rodeo             = 5645, -- (355917) 
    zen_focus_tea     = 1928, -- (468430) 
    zen_spheres       = 5603, -- (410777) Forms a sphere of Hope or Despair above the target. Only one of each sphere can be active at a time.  Sphere of Hope: Heals for 26,648 and increases your healing done to the target by 15%.  Sphere of Despair: Deals 27,430 Nature damage, Target deals 3% less damage, and takes 10% increased damage from all sources. 
} )

-- Auras
spec:RegisterAuras( {
    accumulating_mist = {
        id = 388566,
        duration = 30,
        max_stack = 6,
        dot = "buff"
    },
    ancient_concordance = {
        id = 389391,
        duration = 3600,
        max_stack = 1
    },
    ancient_teachings = {
        id = 388026,
        duration = 15,
        max_stack = 1
    },
    awakened_faeline = {
        id = 389387,
        duration = 3600,
        max_stack = 1,
        copy = "awakened_jadefire"
    },
    bonedust_brew = {
        id = 386276,
        duration = 10,
        max_stack = 1
    },
    bounce_back = {
        id = 390239,
        duration = 4,
        max_stack = 1
    },
    chi_torpedo = { -- Movement buff.
        id = 119085,
        duration = 10,
        max_stack = 2
    },
    close_to_heart = {
        id = 389684,
        duration = 3600,
        max_stack = 1,
        copy = 389574
    },
    crackling_jade_lightning = {
        id = 117952,
        duration = 4,
        tick_time = 1,
        max_stack = 1
    },
    dampen_harm = {
        id = 122278,
        duration = 10,
        max_stack = 1
    },
    dance_of_chiji = {
        id = 438443,
        duration = 15,
        max_stack = 1
    },
    -- Your dodge chance is increased by $w1% until you dodge an attack.
    dance_of_the_wind = {
        id = 432180,
        duration = 3600,
        max_stack = 9
    },
    diffuse_magic = {
        id = 122783,
        duration = 6,
        max_stack = 1
    },
    disable = {
        id = 116095,
        duration = 15,
        tick_time = 1,
        max_stack = 1
    },
    dome_of_mist = {
        id = 205655,
        duration = 8,
        max_stack = 1,
        dot = "buff"
    },
    enveloping_mist = {
        id = 124682,
        duration = 6,
        tick_time = 1,
        max_stack = 1,
        dot = "buff"
    },
    eye_of_the_tiger = {
        id = 196608,
        duration = 8,
        tick_time = 2,
        max_stack = 1
    },
    fae_exposure_buff = {
        id = 356774,
        duration = 10,
        max_stack = 1,
        friendly = true
    },
    fae_exposure_debuff = {
        id = 356773,
        duration = 10,
        max_stack = 1
    },
    faeline_stomp = {
        id = 388193,
        duration = 30,
        max_stack = 1,
        copy = "jadefire_stomp",
    },
    fatal_touch = {
        id = 337296,
        duration = 3600,
        max_stack = 1
    },
    generous_pour = {
        id = 389685,
        duration = 3600,
        max_stack = 1
    },
    grapple_weapon = {
        id = 233759,
        duration = 6,
        max_stack = 1
    },
    healing_elixir = {
        id = 427296,
        duration = 3600,
        max_stack = 2
    },
    invoke_chiji_the_red_crane = { -- This is not the presence of the totem, but the buff stacks gained while totem is up.
        id = 343820,
        duration = 20,
        max_stack = 3,
        copy = { "invoke_chiji", "chiji_the_red_crane", "chiji" }
    },
    invoke_yulon_the_jade_serpent = { -- Misleading; use pet.yulon.up or totem.yulon.up instead.
        id = 322118,
        duration = 25,
        tick_time = 1,
        max_stack = 1,
        copy = { "invoke_yulon", "yulon_the_jade_serpent", "yulon" }
    },
    invokers_delight = {
        id = 388663,
        duration = 20,
        max_stack = 1
    },
    jadefire_teachings = {
        id = 388026,
        duration = 15,
        max_stack = 1
    },
    leg_sweep = {
        id = 119381,
        duration = 3,
        max_stack = 1
    },
    lifecycles_em_rsk = {
        id = 197919,
        duration = 15,
        max_stack = 1,
    },
    lifecycles_vivify = {
        id = 197916,
        duration = 15,
        max_stack = 1,
    },
    life_cocoon = {
        id = 116849,
        duration = 12,
        max_stack = 1,
        dot = "buff"
    },
    mana_tea = {
        id = 197908,
        duration = 10,
        max_stack = 1
    },
    mana_tea_channel = {
        id = 115869,
        duration = function() return buff.mana_tea_stack.stack * ( talent.energizing_brew.enabled and 0.25 or 0.5 ) end,
        tick_time = function() return talent.energizing_brew.enabled and 0.25 or 0.5 end,
    },
    mana_tea_stack = {
        id = 115867,
        duration = 120,
        max_stack = 20
    },
    mastery_gust_of_mists = {
        id = 117907,
    },
    mystic_touch = {
        id = 8647,
    },
    overflowing_mists = {
        id = 388513,
        duration = 6,
        max_stack = 1
    },
    paralysis = {
        id = 115078,
        duration = 60,
        max_stack = 1
    },
    profound_rebuttal = {
        id = 392910,
    },
    refreshing_jade_wind = {
        id = 196725,
        duration = 9,
        tick_time = 0.75,
        max_stack = 1
    },
    ring_of_peace = {
        id = 116844,
        duration = 5,
        max_stack = 1
    },
    save_them_all = {
        id = 389579,
    },
    secret_infusion = {
        alias = { "secret_infusion_critical_strike", "secret_infusion_haste", "secret_infusion_mastery", "secret_infusion_versatility" },
        aliasMode = "longest",
        aliasType = "buff",
        duration = 10,
    },
    secret_infusion_critical_strike = {
        id = 388498,
        duration = 10,
        max_stack = 1,
        copy = "secret_infusion_crit"
    },
    secret_infusion_haste = {
        id = 388497,
        duration = 10,
        max_stack = 1
    },
    secret_infusion_mastery = {
        id = 388499,
        duration = 10,
        max_stack = 1
    },
    secret_infusion_versatility = {
        id = 388500,
        duration = 10,
        max_stack = 1
    },
    shaohaos_lesson_anger = {
        id = 405807,
        duration = 3600,
        max_stack = 1
    },
    shaohaos_lesson_despair = {
        id = 405810,
        duration = 3600,
        max_stack = 1
    },
    shaohaos_lesson_doubt = {
        id = 405808,
        duration = 3600,
        max_stack = 1
    },
    shaohaos_lesson_fear = {
        id = 405809,
        duration = 3600,
        max_stack = 1
    },
    lesson_of_anger = {
        id = 400106,
        duration = function() return 3 * gust_of_mist.count end,
        max_stack = 1
    },
    lesson_of_despair = {
        id = 400100,
        duration = function() return 3 * gust_of_mist.count end,
        max_stack = 1
    },
    lesson_of_doubt = {
        id = 400097,
        duration = function() return 3 * gust_of_mist.count end,
        max_stack = 1
    },
    lesson_of_fear = {
        id = 400103,
        duration = function() return 3 * gust_of_mist.count end,
        max_stack = 1
    },
    renewing_mist = {
        id = 119611,
        duration = function() return 20 + ( buff.tea_of_serenity_rm.up and 10 or 0 ) + ( buff.tea_of_plenty_rm.up and 10 or 0 ) end,
        max_stack = 1,
        dot = "buff"
    },
    rushing_winds = {
        id = 467341,
        duration = 4,
        max_stack = 1
    },
    song_of_chiji = {
        id = 198909,
        duration = 20,
        max_stack = 1
    },
    soothing_breath = { -- Applied by Yu'lon while active.
        id = 343737,
        duration = 25,
        max_stack = 1,
    },
    soothing_mist = {
        id = 115175,
        duration = 8,
        tick_time = 1,
        max_stack = 1
    },
    spinning_crane_kick = {
        id = 101546,
        duration = 1.5,
        tick_time = 0.5,
        max_stack = 1
    },
    strength_of_spirit = {
        id = 387276,
    },
    strength_of_the_black_ox = {
        id = 443112,
        duration = 30,
        max_stack = 1
    },
    summon_black_ox_statue = { -- TODO: Is a totem.
        id = 115315,
        duration = 900,
        max_stack = 1
    },
    summon_jade_serpent_statue = { -- TODO: Is a totem.
        id = 115313,
        duration = 900,
        max_stack = 1
    },
    summon_white_tiger_statue = { -- TODO: Is a totem.
        id = 388686,
        duration = 30,
        max_stack = 1
    },
    tea_of_plenty_eh = {
        id = 388524,
        duration = 30,
        max_stack = 3,
    },
    tea_of_plenty_em = {
        id = 393988,
        duration = 30,
        max_stack = 3,
    },
    tea_of_plenty_rsk = {
        id = 388525,
        duration = 30,
        max_stack = 3,
    },
    tea_of_serenity_em = {
        id = 388519,
        duration = 30,
        max_stack = 3
    },
    tea_of_serenity_rm = {
        id = 388520,
        duration = 30,
        max_stack = 3
    },
    tea_of_serenity_v = {
        id = 388518,
        duration = 30,
        max_stack = 3,
    },
    teachings_of_the_monastery = {
        id = 202090,
        duration = 10,
        max_stack = 4
    },
    thunder_focus_tea = {
        id = 116680,
        duration = 30,
        max_stack = function() return talent.focused_thunder.enabled and 2 or 1 end,
        onRemove = function()
            setCooldown( "thunder_focus_tea", 30 )
        end,
    },
    tigers_lust = {
        id = 116841,
        duration = 6,
        max_stack = 1
    },
    transcendence = {
        id = 101643,
        duration = 900,
        max_stack = 1
    },
    transcendence_transfer = {
        id = 119996,
    },
    vigorous_expulsion = {
        id = 392900,
    },
    vivacious_vivification = {
        id = 392883,
        duration = 3600,
        max_stack = 1
    },
    yulons_whisper = { -- TODO: If needed, this would be triggered by TFT cast.
        id = 388040,
        duration = 2,
        tick_time = 1,
        max_stack = 1
    },
    zen_flight = {
        id = 125883,
        duration = 3600,
        max_stack = 1
    },
    zen_pulse = {
        id = 446334,
        duration = 20,
        max_stack = 1
    },
    zen_focus_tea = {
        id = 209584,
        duration = 5,
        max_stack = 1
    },
    zen_pilgrimage = {
        id = 126892,
    },
} )

-- The War Within
spec:RegisterGear( "tww2", 229298, 212045, 229301, 229299, 229297 )

-- Dragonflight
spec:RegisterGear( "tier31", 207243, 207244, 207245, 207246, 207248, 217188, 217190, 217186, 217187, 217189 )
spec:RegisterAuras( {
    chi_harmony = {
        id = 423439,
        duration = 8,
        max_stack = 1
    }
} )
spec:RegisterGear( "tier30", 202509, 202507, 202506, 202505, 202504 )
spec:RegisterAuras( {
    soulfang_infusion = {
        id = 410007,
        duration = 3,
        max_stack = 1
    },
    soulfang_vitality = {
        id = 410082,
        duration = 6,
        max_stack = 1
    }
} )

-- Totems (which are sometimes pets)
spec:RegisterTotems({
    chiji = {
        id = 877514
    },
    yulon = {
        id = 574571
    },
})

spec:RegisterStateTable( "gust_of_mist", setmetatable( {}, {
    __index = function( t,  k)
        if k == "count" then
            t[ k ] = GetSpellCount( action.sheiluns_gift.id )
            return t[ k ]
        end
    end
} ) )

local manaTeaMulti = 1

spec:RegisterHook( "reset_precast", function()
    gust_of_mist.count = nil

    if buff.mana_tea.up then
        manaTeaMulti = 0.7
    else
        manaTeaMulti = 1
    end
end )

local sm_spells = {
    enveloping_mist = 1,
    zen_pulse = 1,
    vivify = 1
}

spec:RegisterHook( "runHandler", function( action )
    if buff.soothing_mist.up and not sm_spells[ action ] then
        removeBuff( "soothing_mist" )
    end
end )


-- Abilities
spec:RegisterAbilities( {
    -- Strike with a blast of Chi energy, dealing 1,429 Physical damage and granting Shuffle for 3 sec.
    blackout_kick = {
        id = 100784,
        cast = 0,
        cooldown = 3,
        hasteCD = true,
        gcd = "spell",
        school = "physical",

        startsCombat = true,

        handler = function ()
            removeBuff( "teachings_of_the_monastery" )
            if pet.chiji.up then
                addStack( "invoke_chiji" )
                gust_of_mist.count = min( 10, gust_of_mist.count + 1 )
                -- if talent.jade_bond.enabled then reduceCooldown( talent.invoke_chiji.enabled and "invoke_chiji" or "invoke_yulon", 0.5 ) end
            end
        end,
    },

        -- $?c2[The August Celestials empower you, causing you to radiate ${$443039s1*$s7} healing onto up to $s3 injured allies and ${$443038s1*$s7} Nature damage onto enemies within $s6 yds over $d, split evenly among them. Healing and damage increased by $s1% per target, up to ${$s1*$s3}%.]?c3[The August Celestials empower you, causing you to radiate ${$443038s1*$s7} Nature damage onto enemies and ${$443039s1*$s7} healing onto up to $s3 injured allies within $443038A2 yds over $d, split evenly among them. Healing and damage increased by $s1% per enemy struck, up to ${$s1*$s3}%.][]; You may move while channeling, but casting other healing or damaging spells cancels this effect.;
        celestial_conduit = {
            id = 443028,
            cast = function() return talent.unity_within.enabled and buff.celestial_conduit.up and 0 or 4.0 end,
            channeled = function() return not talent.unity_within.enabled or not buff.celestial_conduit.up end,
            dual_cast = function() return talent.unity_within.enabled and buff.celestial_conduit.up end,
            cooldown = 90.0,
            gcd = "spell",
    
            spend = 0.050,
            spendType = 'mana',
    
            talent = "celestial_conduit",
            startsCombat = false,
    
            start = function()
                applyBuff( "celestial_conduit" )
            end,
    
            handler = function()
                -- TODO: do whatever unity_within does.
            end,
        },

    enveloping_mist = {
        id = 124682,
        cast = function()
            if buff.invoke_chiji.stack == 3 or buff.thunder_focus_tea.up or buff.tea_of_plenty_em.up or buff.tea_of_serenity_em.up then return 0 end
            return 2 * ( 1 - 0.333 * buff.invoke_chiji.stack ) * haste
        end,
        cooldown = 0,
        gcd = "spell",

        spend = function()
            return 0.04 * manaTeaMulti * ( pet.yulon.up and 0.5 or 1 )
        end,
        spendType = "mana",

        startsCombat = false,
        texture = 775461,

        handler = function ()
            if buff.thunder_focus_tea.up then
                removeStack( "thunder_focus_tea" )
                if buff.thunder_focus_tea.down and talent.deep_clarity.enabled then applyBuff( "zen_pulse" ) end
            elseif buff.tea_of_plenty_em.up then removeStack( "tea_of_plenty_em" )
            elseif buff.tea_of_serenity_em.up then removeStack( "tea_of_serenity_em" )
            elseif buff.invoke_chiji.stack == 3 then removeBuff( "invoke_chiji" ) end

            gust_of_mist.count = 0

            if buff.lifecycles_em_rsk.up then
                addStack( "mana_tea_stack" )
                removeBuff( "lifecycles_em_rsk" )
            end

            applyBuff( "enveloping_mist" )
            if talent.secret_infusion.enabled and buff.thunder_focus_tea.stack == buff.thunder_focus_tea.max_stack then applyBuff( "secret_infusion_versatility" ) end
        end,
    },

    expel_harm = {
        id = 322101,
        cast = 0,
        cooldown = 15,
        gcd = "totem",

        spend = function() return 0.014 * manaTeaMulti end,
        spendType = "mana",

        startsCombat = false,
        texture = 627486,

        handler = function ()
            if buff.tea_of_plenty_eh.up then removeStack( "tea_of_plenty_eh" ) end
        end,
    },

    invoke_chiji_the_red_crane = {
        id = 325197,
        cast = 0,
        cooldown = 120,
        gcd = "spell",

        spend = function() return 0.05 * manaTeaMulti end,
        spendType = "mana",

        startsCombat = false,
        texture = 877514,

        toggle = "cooldowns",

        handler = function ()
            summonTotem( "chiji", nil, ( talent.gift_of_the_celestials.enabled and 12 or 25 ) )
        end,

        copy = "invoke_chiji"
    },

    invoke_yulon_the_jade_serpent = {
        id = 322118,
        cast = 0,
        cooldown = 120,
        gcd = "spell",

        spend = function() return 0.05 * manaTeaMulti end,
        spendType = "mana",

        startsCombat = false,
        texture = 574571,

        toggle = "cooldowns",

        handler = function ()
            summonTotem( "yulon", nil, ( talent.gift_of_the_celestials.enabled and 12 or 25 ) )
        end,

        copy = "invoke_yulon"
    },

        -- Talent: Strike the ground fiercely to expose a faeline for $d, dealing $388207s1 Nature damage to up to 5 enemies, and restores $388207s2 health to up to 5 allies within $388207a1 yds caught in the faeline. $?a137024[Up to 5 allies]?a137025[Up to 5 enemies][Stagger is $s3% more effective for $347480d against enemies] caught in the faeline$?a137023[]?a137024[ are healed with an Essence Font bolt][ suffer an additional $388201s1 damage].    Your abilities have a $s2% chance of resetting the cooldown of Faeline Stomp while fighting on a faeline.
        jadefire_stomp = {
            id = function() return talent.jadefire_stomp.enabled and 388193 or 327104 end,
            cast = 0,
            -- charges = 1,
            cooldown = 15,
            -- recharge = 30,
            gcd = "totem",
            school = "nature",

            spend = 0.04,
            spendType = "mana",

            startsCombat = true,
            talent = "jadefire_stomp",


            handler = function ()
                applyBuff( "jadefire_stomp" )
                if talent.jadefire_teachings.enabled then applyBuff( "jadefire_teachings" ) end
                if talent.awakened_jadefire.enabled then applyBuff( "awakened_jadefire" ) end
            end,

            copy = { 388193, 327104, "faeline_stomp" }
        },

    -- Encases the target in a cocoon of Chi energy for $d, absorbing $<newshield> damage and increasing all healing over time received by $m2%.$?a388548[; Applies Renewing Mist and Enveloping Mist to the target.][]
    life_cocoon = {
        id = 116849,
        cast = 0,
        cooldown = function() return 120 - ( 45 * talent.chrysalis.rank ) end,
        gcd = "off",
        icd = 0.75,

        spend = function() return 0.02 * manaTeaMulti end,
        spendType = "mana",

        startsCombat = false,
        texture = 627485,

        toggle = "cooldowns",

        handler = function ()
            applyBuff( "life_cocoon" )
            if talent.mists_of_life.enabled then
                applyBuff( "renewing_mist" )
                applyBuff( "enveloping_mist" )
            end
            if talent.refreshment.enabled then
                addStack( "mana_tea_stack", nil, 5 )
                addStack( "healing_elixir", nil, 2 )
            end
        end,
    },

    mana_tea = {
        id = 115294,
        cast = function() return buff.mana_tea_stack.stack * ( talent.energizing_brew.enabled and 0.25 or 0.5 ) * haste end,
        channeled = true,
        cooldown = 0,
        gcd = "spell",

        startsCombat = false,
        texture = 608949,

        toggle = "cooldowns",
        buff = "mana_tea_stack",

        start = function ()
            if set_bonus.tier30_4pc > 0 or set_bonus.tier31_4pc > 0 then applyBuff( "soulfang_vitality" ) end
        end,

        finish = function ()
            applyBuff( "mana_tea", 5 ) -- Faking it just to avoid caching the stacks at the start.
            removeBuff( "mana_tea_stack" )
        end,

        --[[ start = function ()
            if set_bonus.tier30_4pc > 0 then applyBuff( "soulfang_vitality" ) end
        end,

        tick = function ()
            applyBuff( "mana_tea", buff.mana_tea_stack.stack )
        end ]]
    },

    -- You perform a Mighty Ox Kick, hurling your enemy a distance behind you.
    mighty_ox_kick = {
        id = 202370,
        cast = 0,
        cooldown = 30,
        gcd = "totem",

        pvptalent = "mighty_ox_kick",
        startsCombat = false,
        texture = 1381297,

        handler = function ()
        end,
    },

    reawaken = {
        id = 212051,
        cast = 10,
        cooldown = 0,
        gcd = "spell",

        spend = function() return 0.04 * manaTeaMulti end,
        spendType = "mana",

        startsCombat = false,
        texture = 1056569,

        handler = function ()
        end,
    },

    refreshing_jade_wind = {
        id = 196725,
        cast = 0,
        cooldown = 45,
        gcd = "spell",

        spend = function() return 0.25 * manaTeaMulti end,
        spendType = "mana",

        startsCombat = false,
        texture = 606549,

        handler = function ()
        end,
    },

    renewing_mist = {
        id = 115151,
        cast = 0,
        charges = 2,
        cooldown = 9,
        recharge = 9,
        gcd = "spell",

        spend = function() return 0.02 * manaTeaMulti end,
        spendType = "mana",

        startsCombat = false,
        texture = 627487,

        handler = function ()
            applyBuff( "renewing_mist" )
            removeStack( "tea_of_serenity_rm" )
            if talent.secret_infusion.enabled and buff.thunder_focus_tea.stack == buff.thunder_focus_tea.max_stack then applyBuff( "secret_infusion_haste" ) end
        end,
    },

    restoral = {
        id = 388615,
        cast = 0,
        charges = 1,
        cooldown = 180,
        recharge = 180,
        gcd = "spell",

        spend = function() return 0.04 * manaTeaMulti end,
        spendType = "mana",

        startsCombat = false,
        texture = 1381300,

        toggle = "cooldowns",

        handler = function ()
        end,
    },

    resuscitate = {
        id = 115178,
        cast = 10,
        cooldown = 0,
        gcd = "spell",

        spend = function() return 0.04 * manaTeaMulti end,
        spendType = "mana",

        startsCombat = false,
        texture = 132132,

        handler = function ()
        end,
    },

    revival = {
        id = 115310,
        cast = 0,
        charges = 1,
        cooldown = 180,
        recharge = 180,
        gcd = "spell",

        spend = function() return 0.04 * manaTeaMulti end,
        spendType = "mana",

        startsCombat = false,
        texture = 1020466,

        toggle = "cooldowns",

        handler = function ()
        end,
    },

    -- Talent: Kick upwards, dealing 3,359 Physical damage.
    rising_sun_kick = {
        id = 107428,
        cast = 0,
        cooldown = function()
            return ( ( buff.thunder_focus_tea.up or buff.tea_of_plenty_rsk.up ) and 3 or 12 ) * haste
        end,
        gcd = "spell",
        school = "physical",

        talent = "rising_sun_kick",
        notalent = "rushing_wind_kick",
        startsCombat = true,

        spend = function() return 0.025 * manaTeaMulti end,
        spendType = "mana",

        handler = function ()
                if talent.rapid_diffusion.enabled then
                    if solo then applyBuff( "renewing_mist", 3 * talent.rapid_diffusion.rank )
                    else active_dot.renewing_mist = max( group_members, active_dot.renewing_mist + 1 ) end
                end
                if talent.secret_infusion.enabled and buff.thunder_focus_tea.stack == buff.thunder_focus_tea.max_stack then applyBuff( "secret_infusion_versatility" ) end
                if pet.chiji.up then
                    addStack( "invoke_chiji" )
                    gust_of_mist.count = min( 10, gust_of_mist.count + 1 )
                    -- if talent.jade_bond.enabled then reduceCooldown( talent.invoke_chiji.enabled and "invoke_chiji" or "invoke_yulon", 0.5 ) end
                end
                if buff.thunder_focus_tea.up then
                    removeStack( "thunder_focus_tea" )
                    if buff.thunder_focus_tea.down and talent.deep_clarity.enabled then applyBuff( "zen_pulse" ) end
                elseif buff.tea_of_plenty_rsk.up then removeStack( "tea_of_plenty_rsk" ) end
                if buff.lifecycles_em_rsk.up then
                    addStack( "mana_tea_stack" )
                    removeBuff( "lifecycles_em_rsk" )
                end
        end,

        copy = "rushing_wind_kick"
    },

    -- Kick up a powerful gust of wind, dealing $468179s1 Nature damage in a $468179a1 yd cone to enemies in front of you, split evenly among them. Damage is increased by $s1% for each target hit, up to ${$s1*$s2}%.; Grants Rushing Winds for $467341d, increasing Renewing Mist's healing by $467341s1%.
    rushing_wind_kick = {
        id = 467307,
        cast = 0.0,
        cooldown = function()
            return ( ( buff.thunder_focus_tea.up or buff.tea_of_plenty_rsk.up ) and 3 or 12 ) * haste
        end,
        gcd = "spell",

        spend = function() return 0.02 * manaTeaMulti end,
        spendType = 'mana',

        talent = "rushing_wind_kick",
        startsCombat = true,

        handler = function()
            if buff.thunder_focus_tea.up then
                removeStack( "thunder_focus_tea" )
                if buff.thunder_focus_tea.down and talent.deep_clarity.enabled then applyBuff( "zen_pulse" ) end
            elseif buff.tea_of_plenty_rsk.up then removeStack( "tea_of_plenty_rsk" ) end
            if buff.lifecycles_em_rsk.up then
                addStack( "mana_tea_stack" )
                removeBuff( "lifecycles_em_rsk" )
            end
            applyBuff( "rushing_winds" )
        end,

        bind = "rising_sun_kick"
    },

    -- Draws in all nearby clouds of mist, healing up to 3 nearby allies for 1,220 per cloud absorbed. A cloud of mist is generated every 8 sec while in combat.
    sheiluns_gift = {
        id = 399491,
        cast = function() return ( talent.legacy_of_wisdom.enabled and 1.5 or 2 ) * ( talent.emperors_favor.enabled and 0 or 1 ) * haste end,
        cooldown = 0,
        gcd = "spell",

        spend = function() return 0.02 * manaTeaMulti end,
        spendType = "mana",

        talent = "sheiluns_gift",
        startsCombat = false,
        texture = 1242282,

        usable = function()
            return gust_of_mist.count > 0, "requires mists"
        end,

        handler = function ()
            if buff.shaohaos_lesson_anger.up then
                applyBuff( "lesson_of_anger" )
                removeBuff( "shaohaos_lesson_anger" )
            elseif buff.shaohaos_lesson_despair.up then
                applyBuff( "lesson_of_despair" )
                removeBuff( "shaohaos_lesson_despair" )
            elseif buff.shaohaos_lesson_doubt.up then
                applyBuff( "lesson_of_doubt" )
                removeBuff( "shaohaos_lesson_doubt" )
            elseif buff.shaohaos_lesson_fear.up then
                applyBuff( "lesson_of_fear" )
                stat.haste = stat.haste + 0.2
                removeBuff( "shaohaos_lesson_fear" )
            end
            gust_of_mist.count = 0
        end,
    },

    song_of_chiji = {
        id = 198898,
        cast = 1.8,
        cooldown = 30,
        gcd = "spell",

        startsCombat = false,
        texture = 332402,

        handler = function ()
            applyDebuff( "target", "song_of_chiji" )
        end,
    },

    soothing_mist = {
        id = 115175,
        cast = 0,
        -- channeled = true,
        dontChannel = function()
            applyBuff( "soothing_mist", buff.casting.remains )
            return true
        end,
        cooldown = 0,
        gcd = "totem",

        spend = function() return 0.16 * manaTeaMulti end,
        spendType = "mana",
        nobuff = "soothing_mist",

        startsCombat = false,
        texture = 606550,

        handler = function ()
            applyBuff( "soothing_mist" )
        end,
    },

    spinning_crane_kick = {
        id = 101546,
        cast = 0,
        cooldown = 0,
        gcd = "spell",
        school = "physical",

        spend = function() return 0.01 * manaTeaMulti end,
        spendType = "mana",

        startsCombat = true,

        handler = function ()
            applyBuff( "spinning_crane_kick" )
            if buff.dance_of_chiji.up then removeBuff( "dance_of_chiji" ) end
            if pet.chiji.up then
                addStack( "invoke_chiji" )
                gust_of_mist.count = min( 10, gust_of_mist.count + 1 )
                -- if talent.jade_bond.enabled then reduceCooldown( talent.invoke_chiji.enabled and "invoke_chiji" or "invoke_yulon", 0.5 ) end
            end
        end,
    },

    thunder_focus_tea = {
        id = 116680,
        cast = 0,
        cooldown = 30,
        gcd = "off",

        startsCombat = false,
        texture = 611418,
        nobuff = "thunder_focus_tea",

        handler = function ()
            addStack( "thunder_focus_tea", nil, talent.focused_thunder.enabled and 2 or 1 )
            if talent.jade_empowerment.enabled then addStack( "jade_empowerment" ) end
            if talent.jadefire_teachings.enabled then applyBuff( "jadefire_teachings" ) end
            if talent.refreshing_jade_wind.enabled then applyBuff( "refreshing_jade_wind" ) end
            if set_bonus.tier30_4pc > 0 or set_bonus.tier31_4pc > 0 then applyBuff( "soulfang_vitality" ) end
        end,
    },

    -- Strike with the palm of your hand, dealing 568 Physical damage. Reduces the remaining cooldown on your Brews by 1 sec.
    tiger_palm = {
        id = 100780,
        cast = 0,
        cooldown = 0,
        gcd = "spell",
        school = "physical",

        startsCombat = true,

        handler = function ()
            if talent.eye_of_the_tiger.enabled then
                applyDebuff( "target", "eye_of_the_tiger" )
                applyBuff( "eye_of_the_tiger" )
            end
            addStack( "teachings_of_the_monastery", nil, talent.awakened_jadefire.enabled and buff.jadefire_stomp.up and 2 or 1 )
        end,
    },

    vivify = {
        id = 116670,
        cast = function() return buff.vivacious_vivification.up and 0 or 1.5 end,
        cooldown = 0,
        gcd = function()
            return buff.soothing_mist.up and "totem" or "spell"
        end,

        spend = function()
            if buff.tea_of_serenity_v.up then return 0 end
            return 0.03 * manaTeaMulti
        end,
        spendType = "mana",

        startsCombat = false,
        texture = 1360980,

        handler = function ()
            removeStack( "tea_of_serenity_v" )
            if talent.secret_infusion.enabled and buff.thunder_focus_tea.stack == buff.thunder_focus_tea.max_stack then applyBuff( "secret_infusion_mastery" ) end
            if buff.lifecycles_vivify.up then
                addStack( "mana_tea_stack" )
                removeBuff( "lifecycles_vivify" )
            end
            removeBuff( "zen_pulse" )
            removeBuff( "vivacious_vivification" )
        end,
    },

    zen_focus_tea = {
        id = 209584,
        cast = 0,
        cooldown = 30,
        gcd = "off",

        startsCombat = false,
        texture = 651940,

        handler = function ()
            applyBuff( "zen_focus_tea" )
            if set_bonus.tier30_4pc > 0 or set_bonus.tier31_4pc > 0 then applyBuff( "soulfang_vitality" ) end
        end,
    },
} )


spec:RegisterSetting( "experimental_msg", nil, {
    type = "description",
    name = "|cFFFF0000WARNING|r:  Healer support in this addon is focused on DPS output only.  This is more useful for solo content or downtime when your healing output "
        .. "is less critical in a group/encounter.  Use at your own risk.",
    width = "full",
} )

spec:RegisterSetting( "save_faeline", false, {
    type = "toggle",
    name = strformat( "%s: Prevent Overlap", Hekili:GetSpellLinkWithTexture( spec.talents.jadefire_stomp[2] ) ),
    desc = strformat( "If checked, %s will not be recommended when %s and/or %s are active.\n\n"
        .. "Disabling this option may impact your mana efficiency.", Hekili:GetSpellLinkWithTexture( spec.talents.jadefire_stomp[2] ),
        Hekili:GetSpellLinkWithTexture( spec.auras.awakened_jadefire.id ), Hekili:GetSpellLinkWithTexture( spec.auras.jadefire_teachings.id ) ),
    width = "full",
} )

--[[ spec:RegisterSetting( "roll_movement", 5, {
    type = "range",
    name = strformat( "%s: Check Distance", Hekili:GetSpellLinkWithTexture( 109132 ), Hekili:GetSpellLinkWithTexture( 115008 ) ),
    desc = strformat( "If set above zero, %s (and %s) may be recommended when your target is at least this far away.", Hekili:GetSpellLinkWithTexture( 109132 ),
        Hekili:GetSpellLinkWithTexture( 115008 ) ),
    min = 0,
    max = 100,
    step = 1,
    width = "full"
} ) ]]

    spec:RegisterStateExpr( "distance_check", function()
        return target.minR > 0
    end )

local brm = class.specs[ 268 ]

spec:RegisterSetting( "aoe_rsk", false, {
    type = "toggle",
    name = function ()
        return strformat( "%s: AOE", Hekili:GetSpellLinkWithTexture( state.talent.rushing_wind_kick.enabled and spec.abilities.rushing_wind_kick.id or spec.abilities.rising_sun_kick.id ) )
    end,
    desc = function ()
        return strformat( "If checked, %s may be recommended when there are more than 3 enemies detected.\n\n"
        .. "This can result in lower damage but maintains your %s and other rotational buffs for healing.",
        Hekili:GetSpellLinkWithTexture( state.talent.rushing_wind_kick.enabled and spec.abilities.rushing_wind_kick.id or spec.abilities.rising_sun_kick.id ), Hekili:GetSpellLinkWithTexture( spec.abilities.enveloping_mist.id ) )
    end,
    width = "full",
} )

spec:RegisterSetting( "single_zen_pulse", false, {
    type = "toggle",
    name = strformat( "%s (%s): Single Target", Hekili:GetSpellLinkWithTexture( spec.abilities.vivify.id ), Hekili:GetSpellLinkWithTexture( spec.auras.zen_pulse.id ) ),
    desc = strformat( "If checked, %s may be recommended with %s when there is only one enemy detected.\n\n",
        Hekili:GetSpellLinkWithTexture( spec.abilities.vivify.id ), spec.auras.zen_pulse.name ),
    width = "full",
} )

spec:RegisterRanges( "blackout_kick", "rising_sun_kick", "paralysis", "provoke", "crackling_jade_lightning" )

spec:RegisterOptions( {
    enabled = true,

    aoe = 3,
    cycle = false,

    nameplates = false,
    nameplateRange = 10,
    rangeFilter = false,

    damage = true,
    damageExpiration = 8,

    potion = "tempered_potion",

    package = "Mistweaver",

    strict = false
} )



spec:RegisterPack( "Mistweaver", 20241109, [[Hekili:TJ1wVTTnu4Fl5f3KUgpl7CZfjbyxEynDTyyQf9njrlrBZAjsnrQKMbd9BFhkzjrrrjR0fJvmuuGKuXdpx)ox4XXY5do2bib259tNm9mlRjZhpz(0Pwx4ylEmg7yhJ83Gwb)bffb)8DeU4bm6ECI8OhdzOajl4S0eF4yh7fPKqXBOolmWxR5NnfOng7dF(Yjo2Rjbb4cAXCFh7FdJcXjzEXjewcrqW8mpucoZ7x)d7tHVGPcCqMhJg(y2Dz3jz9PwwNoz(RZ8EhAdq4F(P3M55ZOCqpbQb68sWXHiF5z2VTXTUaU1hJLAzM3DOa8sIuu2cwuS8wHOCHjavIk413CYPtNb30YA8KXNx95jZpD6vkmCjdSJpGr(Rj0vGzWwcSAnCW7yueOBj1wWKlpD2e4QFqE8NqW9(eraxZXoeScEEicVeLgkG)895HmKVGWO5(suI7AenWLlsiBGqaMIweIdC(zhb4LvjoLJDjcCexJOzQeTiKXcCxMM8OgvN1GkCchNSbmnnQoxLQqYQ1cU7Ntdwfb(qnsVqLuPVpx0AeDPkriQpgmtuORpkmuJYRAOFOvUSLUGlXFJU5oxLWywXVBqH1ejj1FY2haJ4eccOhlgdH0ptgNgdUFPaKxOMHjPu3I)2vg9kIHUfjp(jikoxawDkGJY84yHqcAgZH8m3LiCiHciJTBlbJJrpaGDkoW9Z7GTJ3XRmVrzElsxU0ajbShOn4s5jUIsyAB2yGgjFQT3kc4Y8MCJBANgN8sGjb6vuEU9T3K5nZOBugG70pIyfEXzdwqx)vjh4)k)NDCc2NfTa1o)Zi8Prsh40CxKMW1q)IcROKFdZik8wLCwSoLgGtCxY8t5Y4tLSnYT8W5FJPUXPHCCo8TKt3tUNS8XQsbdxzkGtv4vWICt4BusgiC4axoKtSbYeRkJ8mkHuUev6(abkbwkJZ7ugdp)PjUgCx1hvLkKxIzn2nQSK(yUaAxMd3oRqZh(fuaLcYkiUgJcJQQtA0AooZ7OQS5wEIg2KpJfktChRfsgNGJqeQmxmZBAM3lZ8w5hmoc9Lc9V(ETyFp38KCzE8Gn)BZJ0NO2fc(olvufsVCa5unBbWJjuQuJZR6wWi9uqE7m62zv9KCRJV7PVABGQH2R)VbZ2Dg4X54IJgsRSkDrZUkAKDYGmoPp4jyt7aILW3VrZU6jpP7If1tva)me7w1kO2pUVUdp9KqfuHEUxXWq92auqIGbpyUGv76VgLSQSTWoxHs2faHEq6aJi5nT7PpyjUJ6lForFZ(0MKQGY1g0bJ9J7UH6btpWCoggug0dQyyvwE2vH2df2DbHC(tO3Z2GDlMSUoxuP(cMEpoKfRgJVy4LIV8Puk(QVx8AFLGomfVMp4zdVTA0qdNyLBwkrPDGxFg1NLeiFfzdhWaIN9pwr1tgnBznrxwwdRajuI8E4v2sQk3HY5o2pGsKshEtB(2cirXSeXUTn8IDBj4fYTx8xPG6d2hNfb0HsbWxX(mGcPuOq64S7(98NvAz96mVFHbPxj5N)IU8faBfSEoV0xb0DS1xozVcO9tl1Kq3VpTwez3zWpaVs4P5dUWSg2cyRPGDMxTh9J)edrNFGJqDW)dL5NN5808at7WdO3ws3d0vNnDpGCHEFKYtJL6Pucf5NaNu7M(Ig0Fi1NZoW8)QdmIQd()mGOk4)8(9pkv67WdzOxWqLX)EFu2DVjQeODEnwlFBVWXYfoXwscXLTj4JR2a1pCZpwSZPS7mDw1q5sHSJa4ZTwtS6HvRfw9J1RbUXxRw7R6x1wZR6rvR1v9JnxJBd(RU2w1d0Sz4lA7z9vYn2DtELLxvSMVBSEfz5nQ7Rv96nNkts5rgx762TDfwh1ZAwRUv7wyJ6BTQQAO(MjlSqO1wd7R54p3EZS9Zc43DZHRNPGCGblbU06DnANRn2O(P6P06CVAaiPYSVCOrM3ZXObnH81NTD7Wi0stjBmpNupp(4J6sv3jddJ9FYEvZ04bQH3o7KrvQqlx8O9ns)TtF5UbY3UD)JXxt9jA(LIvdiDiDUDHrT2SGgpukz1bWqfrc4FtqsdazLuHD3QwB7rNkivZVzK9B3QVw6wCr3J(vYNV1Zrk0Y2jj)haqhD8G0Ei)rx9nGdloWWl(urK5FvgSvxbvECQ92RU(MY3b366gH0Dnw3O(xkZ1Dkf1PzpicODF1NDrOTjOQ8527q6wldHPU6wvrq3nSkj57TdA1oO01yizXWykqnpTVyn6OUNqFuNE39eBmKMPSVf49MRzjo2)ezdII2GYx6IZ)8]] )