-- MonkBrewmaster.lua
-- July 2024

if UnitClassBase( "player" ) ~= "MONK" then return end

local addon, ns = ...
local Hekili = _G[ addon ]
local class, state = Hekili.Class, Hekili.State

local strformat = string.format

local spec = Hekili:NewSpecialization( 268 )
local GetSpellCount = C_Spell.GetSpellCastCount
local GetUnitBuffByAuraInstanceID = C_TooltipInfo.GetUnitBuffByAuraInstanceID

rawset( state, "ColorMixin", ColorMixin )

spec:RegisterResource( Enum.PowerType.Mana )
spec:RegisterResource( Enum.PowerType.Energy )
spec:RegisterResource( Enum.PowerType.Chi )

-- Talents
spec:RegisterTalents( {
    -- Monk
    ancient_arts                        = { 101184, 344359, 2 }, -- Reduces the cooldown of Paralysis by 15 sec and the cooldown of Leg Sweep by 10 sec.
    bounce_back                         = { 101177, 389577, 1 }, -- When a hit deals more than 12% of your maximum health, reduce all damage you take by 20% for 4 sec. This effect cannot occur more than once every 30 seconds.
    bounding_agility                    = { 101161, 450520, 1 }, -- Roll and Chi Torpedo travel a small distance further.
    calming_presence                    = { 101153, 388664, 1 }, -- Reduces all damage taken by 3%.
    celerity                            = { 101183, 115173, 1 }, -- Reduces the cooldown of Roll by 5 sec and increases its maximum number of charges by 1.
    celestial_determination             = { 101180, 450638, 1 }, -- While your Celestial is active, you cannot be slowed below 90% normal movement speed.
    chi_burst                           = { 102433, 123986, 1 }, -- Hurls a torrent of Chi energy up to 40 yds forward, dealing 47,570 Nature damage to all enemies, and 40,038 healing to the Monk and all allies in its path. Healing and damage reduced beyond 5 targets. Casting Chi Burst does not prevent avoiding attacks.
    chi_proficiency                     = { 101169, 450426, 2 }, -- Magical damage done increased by 5% and healing done increased by 5%.
    chi_torpedo                         = { 101183, 115008, 1 }, -- Torpedoes you forward a long distance and increases your movement speed by 30% for 10 sec, stacking up to 2 times.
    chi_wave                            = { 102433, 450391, 1 }, -- Every 15 sec, your next Rising Sun Kick or Vivify releases a wave of Chi energy that flows through friends and foes, dealing 2,413 Nature damage or 6,886 healing. Bounces up to 7 times to targets within 25 yards.
    clash                               = { 101154, 324312, 1 }, -- You and the target charge each other, meeting halfway then rooting all targets within 6 yards for 4 sec.
    crashing_momentum                   = { 101149, 450335, 1 }, -- Targets you Roll through are snared by 40% for 5 sec.
    dampen_harm                         = { 101181, 122278, 1 }, -- Reduces all damage you take by 20% to 50% for 10 sec, with larger attacks being reduced by more.
    dance_of_the_wind                   = { 101181, 414132, 1 }, -- Your dodge chance is increased by 10%.
    detox                               = { 101090, 218164, 1 }, -- Removes all Poison and Disease effects from the target.
    diffuse_magic                       = { 101165, 122783, 1 }, -- Reduces magic damage you take by 60% for 6 sec, and transfers all currently active harmful magical effects on you back to their original caster if possible.
    disable                             = { 101149, 116095, 1 }, -- Reduces the target's movement speed by 50% for 15 sec, duration refreshed by your melee attacks.
    elusive_mists                       = { 101144, 388681, 1 }, -- Reduces all damage taken by you and your target while channeling Soothing Mists by 6%.
    energy_transfer                     = { 101151, 450631, 1 }, -- Successfully interrupting an enemy reduces the cooldown of Paralysis and Roll by 5 sec.
    escape_from_reality                 = { 101176, 394110, 1 }, -- After you use Transcendence: Transfer, you can use Transcendence: Transfer again within 10 sec, ignoring its cooldown.
    expeditious_fortification           = { 101174, 388813, 1 }, -- Fortifying Brew cooldown reduced by 120 sec.
    fast_feet                           = { 101185, 388809, 1 }, -- Rising Sun Kick deals 70% increased damage. Spinning Crane Kick deals 10% additional damage.
    fatal_touch                         = { 101178, 394123, 1 }, -- Touch of Death increases your damage by 5% for 30 sec after being cast and its cooldown is reduced by 90 sec.
    ferocity_of_xuen                    = { 101166, 388674, 1 }, -- Increases all damage dealt by 2%.
    flow_of_chi                         = { 101170, 450569, 1 }, -- You gain a bonus effect based on your current health. Above 90% health: Movement speed increased by 5%. This bonus stacks with similar effects. Between 90% and 35% health: Damage taken reduced by 5%. Below 35% health: Healing received increased by 10%.
    fortifying_brew                     = { 101173, 115203, 1 }, -- Turns your skin to stone for 15 sec, increasing your current and maximum health by 30%, increasing the effectiveness of Stagger by 15%, reducing all damage you take by 30%.
    grace_of_the_crane                  = { 101146, 388811, 1 }, -- Increases all healing taken by 6%.
    hasty_provocation                   = { 101158, 328670, 1 }, -- Provoked targets move towards you at 50% increased speed.
    healing_winds                       = { 101171, 450560, 1 }, -- Transcendence: Transfer immediately heals you for 15% of your maximum health.
    improved_touch_of_death             = { 101140, 322113, 1 }, -- Touch of Death can now be used on targets with less than 15% health remaining, dealing 35% of your maximum health in damage.
    ironshell_brew                      = { 101174, 388814, 1 }, -- Increases your maximum health by an additional 10% and your damage taken is reduced by an additional 10% while Fortifying Brew is active.
    jade_walk                           = { 101160, 450553, 1 }, -- While out of combat, your movement speed is increased by 15%.
    lighter_than_air                    = { 101168, 449582, 1 }, -- Roll causes you to become lighter than air, allowing you to double jump to dash forward a short distance once within 5 sec, but the cooldown of Roll is increased by 2 sec.
    martial_instincts                   = { 101179, 450427, 2 }, -- Increases your Physical damage done by 5% and Avoidance increased by 4%.
    paralysis                           = { 101142, 115078, 1 }, -- Incapacitates the target for 1 min. Limit 1. Damage will cancel the effect.
    peace_and_prosperity                = { 101163, 450448, 1 }, -- Reduces the cooldown of Ring of Peace by 5 sec and Song of Chi-Ji's cast time is reduced by 0.5 sec.
    pressure_points                     = { 101141, 450432, 1 }, -- Paralysis now removes all Enrage effects from its target.
    profound_rebuttal                   = { 101135, 392910, 1 }, -- Expel Harm's critical healing is increased by 50%.
    quick_footed                        = { 101158, 450503, 1 }, -- The duration of snare effects on you is reduced by 20%.
    ring_of_peace                       = { 101136, 116844, 1 }, -- Form a Ring of Peace at the target location for 5 sec. Enemies that enter will be ejected from the Ring.
    rising_sun_kick                     = { 101186, 107428, 1 }, -- Kick upwards, dealing 55,002 Physical damage.
    rushing_reflexes                    = { 101154, 450154, 1 }, -- Your heightened reflexes allow you to react swiftly to the presence of enemies, causing you to quickly lunge to the nearest enemy in front of you within 10 yards after you Roll.
    save_them_all                       = { 101157, 389579, 1 }, -- When your healing spells heal an ally whose health is below 35% maximum health, you gain an additional 10% healing for the next 4 sec.
    song_of_chiji                       = { 101136, 198898, 1 }, -- Conjures a cloud of hypnotic mist that slowly travels forward. Enemies touched by the mist fall asleep, Disoriented for 20 sec.
    soothing_mist                       = { 101143, 115175, 1 }, -- Heals the target for 193,860 over 7.2 sec. While channeling, Enveloping Mist and Vivify may be cast instantly on the target.
    spear_hand_strike                   = { 101152, 116705, 1 }, -- Jabs the target in the throat, interrupting spellcasting and preventing any spell from that school of magic from being cast for 3 sec.
    spirits_essence                     = { 101138, 450595, 1 }, -- Transcendence: Transfer snares targets within 10 yds by 70% for 4 sec when cast.
    strength_of_spirit                  = { 101135, 387276, 1 }, -- Expel Harm's healing is increased by up to 100%, based on your missing health.
    summon_black_ox_statue              = { 101172, 115315, 1 }, -- Summons a Black Ox Statue at the target location for 15 min, pulsing threat to all enemies within 20 yards. You may cast Provoke on the statue to taunt all enemies near the statue.
    swift_art                           = { 101155, 450622, 1 }, -- Roll removes a snare effect once every 30 sec.
    tiger_tail_sweep                    = { 101182, 264348, 1 }, -- Increases the range of Leg Sweep by 4 yds.
    tigers_lust                         = { 101147, 116841, 1 }, -- Increases a friendly target's movement speed by 70% for 6 sec and removes all roots and snares.
    transcendence                       = { 101167, 101643, 1 }, -- Split your body and spirit, leaving your spirit behind for 15 min. Use Transcendence: Transfer to swap locations with your spirit.
    transcendence_linked_spirits        = { 101176, 434774, 1 }, -- Transcendence now tethers your spirit onto an ally for 1 |4hour:hrs;. Use Transcendence: Transfer to teleport to your ally's location.
    vigorous_expulsion                  = { 101156, 392900, 1 }, -- Expel Harm's healing increased by 5% and critical strike chance increased by 15%.
    vivacious_vivification              = { 101145, 388812, 1 }, -- Every 10 sec, your next Vivify becomes instant and its healing is increased by 20%. This effect also reduces the energy cost of Vivify by 75%.
    winds_reach                         = { 101148, 450514, 1 }, -- The range of Disable is increased by 5 yds. The duration of Crashing Momentum is increased by 3 sec and its snare now reduces movement speed by an additional 20%.
    windwalking                         = { 101175, 157411, 1 }, -- You and your allies within 10 yards have 10% increased movement speed. Stacks with other similar effects.
    yulons_grace                        = { 101165, 414131, 1 }, -- Find resilience in the flow of chi in battle, gaining a magic absorb shield for 2.0% of your max health every 2 sec in combat, stacking up to 10%.

    -- Brewmaster
    anvil_stave                         = { 101081, 386937, 2 }, -- Each time you dodge or an enemy misses you, the remaining cooldown on your Brews is reduced by 0.5 sec. Effect reduced for each recent melee attacker.
    august_blessing                     = { 101084, 454483, 1 }, -- When you would be healed above maximum health, you instead convert an amount equal to 40% of your critical strike chance to a heal over time effect.
    black_ox_adept                      = { 101198, 455079, 1 }, -- Rising Sun Kick grants a charge of Ox Stance.
    black_ox_brew                       = { 101190, 115399, 1 }, -- Chug some Black Ox Brew, which instantly refills your Energy, Purifying Brew charges, and resets the cooldown of Celestial Brew.
    blackout_combo                      = { 101195, 196736, 1 }, -- Blackout Kick also empowers your next ability: Tiger Palm: Damage increased by 100%. Breath of Fire: Damage increased by 50%, and damage reduction increased by 5%. Keg Smash: Reduces the remaining cooldown on your Brews by 2 additional sec. Celestial Brew: Gain up to 3 additional stacks of Purified Chi. Purifying Brew: Pauses Stagger damage for 3 sec.
    bob_and_weave                       = { 101190, 280515, 1 }, -- Increases the duration of Stagger by 3.0 sec.
    breath_of_fire                      = { 101069, 115181, 1 }, -- Breathe fire on targets in front of you, causing 8,155 Fire damage. Deals reduced damage to secondary targets. Targets affected by Keg Smash will also burn, taking 5,096 Fire damage and dealing 5% reduced damage to you for 12 sec.
    call_to_arms                        = { 101192, 397251, 1 }, -- Weapons of Order calls forth Niuzao, the Black Ox to assist you for 12 sec. Triggering a bonus attack with Press the Advantage has a chance to call forth Niuzao, the Black Ox.
    celestial_brew                      = { 101067, 322507, 1 }, -- A swig of strong brew that coalesces purified chi escaping your body into a celestial guard, absorbing 151,500 damage. Purifying Stagger damage increases absorption by up to 200%.
    celestial_flames                    = { 101070, 325177, 1 }, -- Drinking from Brews has a 30% chance to coat the Monk with Celestial Flames for 6 sec. While Celestial Flames is active, Spinning Crane Kick applies Breath of Fire and Breath of Fire reduces the damage affected enemies deal to you by an additional 5%.
    charred_passions                    = { 101187, 386965, 1 }, -- Your Breath of Fire ignites your right leg in flame for 8 sec, causing your Blackout Kick and Spinning Crane Kick to deal 50% additional damage as Fire damage and refresh the duration of your Breath of Fire on the target.
    chi_surge                           = { 101712, 393400, 1 }, -- Triggering a bonus attack from Press the Advantage or casting Weapons of Order releases a surge of chi at your target's location, dealing Nature damage split evenly between all targets over 8 sec.  Press the Advantage: Deals 32,464 Nature damage.  Weapons of Order: Deals 64,928 Nature damage and reduces the cooldown of Weapons of Order by 4 for each affected enemy, to a maximum of 20 sec.
    counterstrike                       = { 101080, 383785, 1 }, -- Each time you dodge or an enemy misses you, your next Tiger Palm or Spinning Crane Kick deals 100% increased damage.
    dragonfire_brew                     = { 101187, 383994, 1 }, -- After using Breath of Fire, you breathe fire 2 additional times, each dealing 3,061 Fire damage. Breath of Fire damage increased by up to 100% based on your level of Stagger.
    elixir_of_determination             = { 101085, 455139, 1 }, -- When you fall below 40% health, you gain an absorb for 50% of your recently Purified damage, or a minimum of 20% of your maximum health. Cannot occur more than once every 15 sec.
    elusive_footwork                    = { 101194, 387046, 1 }, -- Blackout Kick deals an additional 5% damage. Blackout Kick critical hits grant an additional 1 stack of Elusive Brawler.
    exploding_keg                       = { 101197, 325153, 1 }, -- Hurls a flaming keg at the target location, dealing 43,832 Fire damage to nearby enemies, causing your attacks against them to deal 3,397 additional Fire damage, and causing their melee attacks to deal 100% reduced damage for the next 3 sec.
    face_palm                           = { 101079, 389942, 1 }, -- Tiger Palm has a 50% chance to deal 200% of normal damage and reduce the remaining cooldown of your Brews by 1 additional sec.
    fluidity_of_motion                  = { 101078, 387230, 1 }, -- Blackout Kick's cooldown is reduced by 1 sec and its damage is reduced by 10%.
    fortifying_brew_determination       = { 101068, 322960, 1 }, -- Fortifying Brew increases Stagger effectiveness by 15% while active. Combines with other Fortifying Brew effects.
    gai_plins_imperial_brew             = { 102004, 383700, 1 }, -- Purifying Brew instantly heals you for 25% of the purified Stagger damage.
    gift_of_the_ox                      = { 101072, 124502, 1 }, -- When you take damage, you have a chance to summon a Healing Sphere. Healing Sphere: Summon a Healing Sphere visible only to you. Moving through this Healing Sphere heals you for 41,620.
    heightened_guard                    = { 101711, 455081, 1 }, -- Ox Stance will now trigger when an attack is larger than 40% of your current health.
    high_tolerance                      = { 101189, 196737, 2 }, -- Stagger is 5% more effective at delaying damage. You gain up to 10% Haste based on your current level of Stagger.
    hit_scheme                          = { 101071, 383695, 1 }, -- Dealing damage with Blackout Kick increases the damage of your next Keg Smash by 10%, stacking up to 4 times.
    improved_invoke_niuzao_the_black_ox = { 101073, 322740, 1 }, -- While Niuzao is active, Purifying Brew increases the damage of Niuzao's next Stomp, based on Stagger level.
    invoke_niuzao_the_black_ox          = { 101075, 132578, 1 }, -- Summons an effigy of Niuzao, the Black Ox for 25 sec. Niuzao attacks your primary target, and frequently Stomps, damaging all nearby enemies. While active, 25% of damage delayed by Stagger is instead Staggered by Niuzao.
    keg_smash                           = { 101088, 121253, 1 }, -- Smash a keg of brew on the target, dealing 18,348 Physical damage to all enemies within 8 yds and reducing their movement speed by 20% for 15 sec. Deals reduced damage beyond 5 targets. Grants Shuffle for 5 sec and reduces the remaining cooldown on your Brews by 3 sec.
    light_brewing                       = { 101082, 325093, 1 }, -- Reduces the cooldown of Purifying Brew and Celestial Brew by 20%.
    one_with_the_wind                   = { 101710, 454484, 1 }, -- You have a 10% chance to not reset your Elusive Brawler stacks after a successful dodge.
    ox_stance                           = { 101199, 455068, 1 }, -- Casting Purifying Brew grants a charge of Ox Stance, increased based on Stagger level. When you take damage that is greater than 60% of your current health, a charge is consumed to increase the amount you Stagger.
    press_the_advantage                 = { 101193, 418359, 1 }, -- Your main hand auto attacks reduce the cooldown on your brews by 0.5 sec and block your target's chi, dealing 3,397 additional Nature damage and increasing your damage dealt by 1% for 20 sec. Upon reaching 10 stacks, your next cast of Rising Sun Kick or Keg Smash consumes all stacks to strike again at 100% effectiveness. This bonus attack can trigger effects on behalf of Tiger Palm at reduced effectiveness.
    pretense_of_instability             = { 101077, 393516, 1 }, -- Activating Purifying Brew or Celestial Brew grants you 15% dodge for 5 sec.
    purifying_brew                      = { 101064, 119582, 1 }, -- Clears 50% of your damage delayed with Stagger. Instantly heals you for 25% of the damage cleared.
    quick_sip                           = { 101063, 388505, 1 }, -- Purify 5% of your Staggered damage each time you gain 3 sec of Shuffle duration.
    rushing_jade_wind                   = { 101202, 116847, 1 }, -- Summons a whirling tornado around you, causing 16,403 Physical damage over 8.1 sec to all enemies within 8 yards. Deals reduced damage beyond 5 targets.
    salsalabims_strength                = { 101188, 383697, 1 }, -- When you use Keg Smash, the remaining cooldown on Breath of Fire is reset.
    scalding_brew                       = { 101188, 383698, 1 }, -- Keg Smash deals an additional 20% damage to targets affected by Breath of Fire.
    shadowboxing_treads                 = { 101078, 387638, 1 }, -- Blackout Kick's damage increased by 20% and it strikes an additional 2 targets.
    shuffle                             = { 101087, 322120, 1 }, -- Niuzao's teachings allow you to shuffle during combat, increasing the effectiveness of your Stagger by 100%. Shuffle is granted by attacking enemies with your Keg Smash, Blackout Kick, and Spinning Crane Kick.
    special_delivery                    = { 101202, 196730, 1 }, -- Drinking from your Brews has a 100% chance to toss a keg high into the air that lands nearby after 3 sec, dealing 11,131 damage to all enemies within 8 yards and reducing their movement speed by 50% for 15 sec.
    spirit_of_the_ox                    = { 101086, 400629, 1 }, -- Rising Sun Kick and Blackout Kick have a chance to summon a Healing Sphere. Healing Sphere: Summon a Healing Sphere visible only to you. Moving through this Healing Sphere heals you for 41,620.
    staggering_strikes                  = { 101065, 387625, 1 }, -- When you Blackout Kick, your Stagger is reduced by 15,765.
    stormstouts_last_keg                = { 101196, 383707, 1 }, -- Keg Smash deals 20% additional damage, and has 1 additional charge.
    strike_at_dawn                      = { 101076, 455043, 1 }, -- Rising Sun Kick grants a stack of Elusive Brawler.
    training_of_niuzao                  = { 101082, 383714, 1 }, -- Gain up to 15% Mastery based on your current level of Stagger.
    tranquil_spirit                     = { 101083, 393357, 1 }, -- When you consume a Healing Sphere or cast Expel Harm, your current Stagger amount is lowered by 5%.
    walk_with_the_ox                    = { 101074, 387219, 2 }, -- Abilities that grant Shuffle reduce the cooldown on Invoke Niuzao, the Black Ox by 0.50 sec, and Niuzao's Stomp deals an additional 10% damage.
    weapons_of_order                    = { 101193, 387184, 1 }, -- For the next 30 sec, your Mastery is increased by 10%. Additionally, Keg Smash cooldown is reset instantly and enemies hit by Keg Smash or Rising Sun Kick take 8% increased damage from you for 10 sec, stacking up to 4 times.
    zen_meditation                      = { 101201, 115176, 1 }, -- Reduces all damage taken by 60% for 8 sec. Being hit by a melee attack, or taking another action will cancel this effect.

    -- Shado-Pan
    against_all_odds                    = { 101253, 450986, 1 }, -- Flurry Strikes increase your Agility by 1% for 6 sec, stacking up to 20 times.
    efficient_training                  = { 101251, 450989, 1 }, -- Energy spenders deal an additional 15% damage. Every 50 Energy spent reduces the cooldown of Weapons of Order by 1 sec.
    flurry_strikes                      = { 101248, 450615, 1, "shadopan" }, -- Every 61,321 damage you deal generates a Flurry Charge. For each 400 energy you spend, unleash all Flurry Charges, dealing 7,652 Physical damage per charge.
    high_impact                         = { 101247, 450982, 1 }, -- Enemies who die within 5 sec of being damaged by a Flurry Strike explode, dealing 15,305 physical damage to uncontrolled enemies within 8 yds.
    lead_from_the_front                 = { 101254, 450985, 1 }, -- Chi Burst, Chi Wave, and Expel Harm now heal you for 20% of damage dealt.
    martial_precision                   = { 101246, 450990, 1 }, -- Your attacks penetrate 10% armor.
    one_versus_many                     = { 101250, 450988, 1 }, -- Damage dealt by Fists of Fury and Keg Smash counts as double towards Flurry Charge generation. Fists of Fury damage increased by 10%. Keg Smash damage increased by 30%.
    predictive_training                 = { 101245, 450992, 1 }, -- When you dodge or parry an attack, reduce all damage taken by 10% for the next 6 sec.
    pride_of_pandaria                   = { 101247, 450979, 1 }, -- Flurry Strikes have 15% additional chance to critically strike.
    protect_and_serve                   = { 101254, 450984, 1 }, -- Your Vivify always heals you for an additional 30% of its total value.
    veterans_eye                        = { 101249, 450987, 1 }, -- Striking the same target 5 times within 2 sec grants 1% Haste. Multiple instances of this effect may overlap, stacking up to 10 times.
    vigilant_watch                      = { 101244, 450993, 1 }, -- Blackout Kick deals an additional 20% critical damage and increases the damage of your next set of Flurry Strikes by 10%.
    whirling_steel                      = { 101245, 450991, 1 }, -- When your health drops below 50%, summon Whirling Steel, increasing your parry chance and avoidance by 15% for 6 sec. This effect can not occur more than once every 180 sec.
    wisdom_of_the_wall                  = { 101252, 450994, 1 }, -- Every 10 Flurry Strikes, become infused with the Wisdom of the Wall, gaining one of the following effects for 20 sec. Critical strike damage increased by 30%. Dodge and Critical Strike chance increased by 25% of your Versatility bonus. Flurry Strikes deal 15,306 Shadow damage to all uncontrolled enemies within 6 yds. Effect of your Mastery increased by 25%.

    -- Master of Harmony
    aspect_of_harmony                   = { 101223, 450508, 1, "master_of_harmony" }, -- Store vitality from 20% of your damage dealt and 10% of your effective healing. For 10 sec after casting Celestial Brew your spells and abilities draw upon the stored vitality to deal 25% additional damage over 8 sec.
    balanced_stratagem                  = { 101230, 450889, 1 }, -- Casting a Physical spell or ability increases the damage and healing of your next Fire or Nature spell or ability by 5%, and vice versa. Stacks up to 5.
    clarity_of_purpose                  = { 101228, 451017, 1 }, -- Casting Purifying Brew stores 14,428 vitality, increased based on Stagger level.
    coalescence                         = { 101227, 450529, 1 }, -- When Aspect of Harmony deals damage, it has a chance to spread to a nearby enemy. When you directly attack an affected target, it has a chance to intensify. Targets damaged or healed by your Aspect of Harmony take 10% increased damage or healing from you.
    endless_draught                     = { 101225, 450892, 1 }, -- Celestial Brew has 1 additional charge.
    harmonic_gambit                     = { 101224, 450870, 1 }, -- During Aspect of Harmony, Expel Harm and Vivify withdraw vitality to heal.
    manifestation                       = { 101222, 450875, 1 }, -- Chi Burst and Chi Wave deal 100% increased damage and healing.
    mantra_of_purity                    = { 101229, 451036, 1 }, -- Purifying Brew removes 10% additional Stagger and causes you to absorb up to 25,971 incoming Stagger.
    mantra_of_tenacity                  = { 101229, 451029, 1 }, -- Fortifying Brew applies a Chi Cocoon.
    overwhelming_force                  = { 101220, 451024, 1 }, -- Rising Sun Kick, Blackout Kick, and Tiger Palm deal 15% additional damage to enemies in a line in front of you. Damage reduced above 5 targets.
    path_of_resurgence                  = { 101226, 450912, 1 }, -- Chi Wave increases vitality stored by 25% for 5 sec.
    purified_spirit                     = { 101224, 450867, 1 }, -- When Aspect of Harmony ends, any remaining vitality is expelled as damage over 8 sec, split among nearby targets.
    roar_from_the_heavens               = { 101221, 451043, 1 }, -- Tiger's Lust grants 20% movement speed to up to 2 allies near its target.
    tigers_vigor                        = { 101221, 451041, 1 }, -- Casting Tiger's Lust reduces the remaining cooldown on Roll by 5 sec.
    way_of_a_thousand_strikes           = { 101226, 450965, 1 }, -- Rising Sun Kick, Blackout Kick, and Tiger Palm contribute 50% additional vitality.
} )


-- PvP Talents
spec:RegisterPvpTalents( {
    admonishment       =  843, -- (207025) You focus the assault on this target, increasing their damage taken by 3% for 6 sec. Each unique player that attacks the target increases the damage taken by an additional 3%, stacking up to 5 times. Your melee attacks refresh the duration of Focused Assault.
    alpha_tiger        = 5552, -- (287503) Attacking new challengers with Tiger Palm fills you with the spirit of Xuen, granting you 20% haste for 8 sec. This effect cannot occur more than once every 30 sec per target.
    avert_harm         =  669, -- (202162) Guard the 4 closest players within 15 yards for 15 sec, allowing you to Stagger 20% of damage they take.
    dematerialize      = 5541, -- (353361)
    double_barrel      =  672, -- (202335) Your next Keg Smash deals 50% additional damage, and stuns all targets it hits for 3 sec.
    eerie_fermentation =  765, -- (205147) You gain up to 30% movement speed and 15% magical damage reduction based on your current level of Stagger.
    grapple_weapon     = 5538, -- (233759) You fire off a rope spear, grappling the target's weapons and shield, returning them to you for 5 sec.
    guided_meditation  =  668, -- (202200) The cooldown of Zen Meditation is reduced by 50%. While Zen Meditation is active, all harmful spells cast against your allies within 40 yards are redirected to you. Zen Meditation is no longer cancelled when being struck by a melee attack.
    hot_trub           =  667, -- (410346) Purifying Brew deals 20% of cleared damage split among nearby enemies. After clearing 100% of your maximum health in Stagger damage, your next Breath of Fire incapacitates targets for 4 sec.
    microbrew          =  666, -- (202107) Reduces the cooldown of Fortifying Brew by 50%.
    mighty_ox_kick     =  673, -- (202370) You perform a Mighty Ox Kick, hurling your enemy a distance behind you.
    nimble_brew        =  670, -- (354540) Douse allies in the targeted area with Nimble Brew, preventing the next full loss of control effect within 8 sec.
    niuzaos_essence    = 1958, -- (232876) Drinking a Purifying Brew will dispel all snares affecting you.
    rodeo              = 5417, -- (355917) Every 3 sec while Clash is off cooldown, your next Clash can be reactivated immediately to wildly Clash an additional enemy. This effect can stack up to 3 times.
} )


-- Auras
spec:RegisterAuras( {
    admonishment = {
        id = 207025,
    },
    aspect_of_harmony = {
        id = 450711,
        duration = 10,
        max_stack = 1,
    },
    aspect_of_harmony_accumulator = {
        id = 450521,
        duration = 3600,
        max_stack = 1,
        copy = { 450521, 450526, 450531 },

        generate = function( t )
            local aura = GetPlayerAuraBySpellID( 450521 ) or GetPlayerAuraBySpellID( 450526 ) or GetPlayerAuraBySpellID( 450531 )

            if aura then
                t.name = aura.name
                t.count = 1
                t.applied = query_time
                t.expires = t.applied + 3600
                t.duration = 3600
                t.caster = "player"

                local tooltip = GetUnitBuffByAuraInstanceID( "player", aura.auraInstanceID )
                if not tooltip then
                    t.v1 = 0
                    return
                end

                local value = tooltip.lines and tooltip.lines[2] and tooltip.lines[2].leftText
                value = value and value:match( "%d+" )

                if not value then
                    t.v1 = 0
                    return
                end

                t.v1 = tonumber( value ) or 0
                return
            end

            t.name = t.name or class.auras.aspect_of_harmony_accumulator.name or "Aspect of Harmony"
            t.count = 0
            t.expires = 0
            t.duration = 3600
            t.applied = 0
            t.v1 = 0
            t.caster = "nobody"
        end,
    },
    aspect_of_harmony_damage = {
        id = 450763,
        duration = 8,
        max_stack = 1,
    },
    august_blessing = {
        id = 454494,
        duration = 10,
        max_stack = 1
    },
    blackout_combo = {
        id = 228563,
        duration = 15,
        max_stack = 1,
    },
    bounce_back = {
        id = 390239,
        duration = 4,
        max_stack = 1
    },
    breath_of_fire_dot = {
        id = 123725,
        duration = 12,
        max_stack = 1,
        copy = "breath_of_fire"
    },
    brewmasters_balance = {
        id = 245013,
    },
    celestial_brew = {
        id = 322507,
        duration = 8,
        max_stack = 1,
    },
    celestial_flames = {
        id = 325190,
        duration = 6,
        max_stack = 1,
    },
    celestial_fortune = {
        id = 216519,
    },
    charred_passions = {
        id = 386963,
        duration = 8,
        max_stack = 1,
        copy = 338140 -- legendary
    },
    -- Increases the damage done by your next Chi Explosion by $s1%.    Chi Explosion is triggered whenever you use Spinning Crane Kick.
    -- https://wowhead.com/beta/spell=393057
    chi_energy = {
        id = 393057,
        duration = 45,
        max_stack = 30
    },
    -- Talent: Movement speed increased by $w1%.
    -- https://wowhead.com/beta/spell=119085
    chi_torpedo = {
        id = 119085,
        duration = 10,
        max_stack = 2
    },
    clash = {
        id = 128846,
        duration = 4,
        max_stack = 1,
    },
    -- Taking $w1 damage every $t1 sec.
    -- https://wowhead.com/beta/spell=117952
    crackling_jade_lightning = {
        id = 117952,
        duration = function() return 4 * haste end,
        tick_time = function() return haste end,
        type = "Magic",
        max_stack = 1
    },
    -- Movement slowed by $w1%.
    crashing_momentum = {
        id = 450342,
        duration = function() return 5.0 + ( 3 * talent.winds_reach.rank ) end,
        pandemic = true,
        max_stack = 1
    },
    -- Talent: Damage taken reduced by $m2% to $m3% for $d, with larger attacks being reduced by more.
    -- https://wowhead.com/beta/spell=122278
    dampen_harm = {
        id = 122278,
        duration = 10,
        type = "Magic",
        max_stack = 1
    },
    -- Your next Spinning Crane Kick is free and deals an additional $325201s1% damage.
    -- https://wowhead.com/beta/spell=325202
    dance_of_chiji = {
        id = 325202,
        duration = 15,
        max_stack = 1
    },
    -- Talent: Spell damage taken reduced by $m1%.
    -- https://wowhead.com/beta/spell=122783
    diffuse_magic = {
        id = 122783,
        duration = 6,
        type = "Magic",
        max_stack = 1
    },
    -- Talent: Movement slowed by $w1%. When struck again by Disable, you will be rooted for $116706d.
    -- https://wowhead.com/beta/spell=116095
    disable = {
        id = 116095,
        duration = 15,
        mechanic = "snare",
        max_stack = 1
    },
    double_barrel = {
        id = 202335,
    },
    elusive_brawler = {
        id = 195630,
        duration = 10,
        max_stack = 10,
    },
    -- Absorbing $w1 damage.
    elixir_of_determination = {
        id = 455179,
        duration = 15.0,
        max_stack = 1,
    },
    exploding_keg = {
        id = 325153,
        duration = 3,
        max_stack = 1,
    },
    -- Fighting on a faeline has a $s2% chance of resetting the cooldown of Faeline Stomp.
    -- https://wowhead.com/beta/spell=388193
    faeline_stomp = {
        id = 388193,
        duration = 30,
        max_stack = 1,
        copy = "jadefire_stomp"
    },
    flow_of_battle_damage = {
        id = 457257,
        duration = 15,
        max_stack = 3,
    },
    flow_of_battle_free_keg_smash= {
        id = 457271,
        duration = 15,
        max_stack = 1,
    },
    flow_of_chi_speed = {
        id = 450574,
        duration = 3600,
        max_stack = 1,
    },
    flow_of_chi_dr = {
        id = 450572,
        duration = 3600,
        max_stack = 1,
    },
    -- Increases all healing taken by $w1%.
    flow_of_chi_healing = {
        id = 450571,
        duration = 3600,
        max_stack = 1,
    },
    fortifying_brew = {
        id = 120954,
        duration = 15,
        max_stack = 1,
    },
    gift_of_the_ox = {
        id = 124502,
        duration = 3600,
        max_stack = 10,
    },
    guard = {
        id = 115295,
        duration = 8,
        max_stack = 1,
    },
    hit_scheme = {
        id = 383696,
        duration = 8,
        max_stack = 4
    },
    invoke_niuzao_the_black_ox = {
        id = 132578,
        duration = 25,
        max_stack = 1,
        copy = { "invoke_niuzao", "niuzao_the_black_ox" }
    },
    invokers_delight = {
        id = 338321,
        duration = 20,
        max_stack = 1
    },
    -- Movement speed increased by $w1%.
    jade_walk = {
        id = 450552,
        duration = 5.0,
        max_stack = 1,
    },
    -- Talent: $?$w3!=0[Movement speed reduced by $w3%.  ][]Drenched in brew, vulnerable to Breath of Fire.
    -- https://wowhead.com/beta/spell=121253
    keg_smash = {
        id = 121253,
        duration = 15,
        max_stack = 1
    },
    -- Talent: $?$w3!=0[Movement speed reduced by $w3%.  ][]
    -- https://wowhead.com/beta/spell=330911
    keg_smash_snare = {
        id = 330911,
        duration = 15,
        max_stack = 1
    },
    -- Stunned.
    -- https://wowhead.com/beta/spell=119381
    leg_sweep = {
        id = 119381,
        duration = 3,
        mechanic = "stun",
        max_stack = 1
    },
    -- You may jump twice to dash forward a short distance.
    lighter_than_air = {
        id = 449609,
        duration = 5.0,
        max_stack = 1,
    },
    ox_stance = {
        id = 455071,
        duration = 30,
        max_stack = 20 -- ???
    },
    -- Talent: Incapacitated.
    -- https://wowhead.com/beta/spell=115078
    paralysis = {
        id = 115078,
        duration = 60,
        mechanic = "incapacitate",
        max_stack = 1
    },
    press_the_advantage = {
        id = 418361,
        duration = 20,
        max_stack = 10,
    },
    pretense_of_instability = {
        id = 393515,
        duration = 3,
        max_stack = 1
    },
    -- Taunted. Movement speed increased by $s3%.
    -- https://wowhead.com/beta/spell=116189
    provoke = {
        id = 116189,
        duration = 3,
        mechanic = "taunt",
        max_stack = 1
    },
    purified_chi = {
        id = 325092,
        duration = 15,
        max_stack = 10,
    },
    -- Talent: Nearby enemies will be knocked out of the Ring of Peace.
    -- https://wowhead.com/beta/spell=116844
    ring_of_peace = {
        id = 116844,
        duration = 5,
        type = "Magic",
        max_stack = 1
    },
    -- Talent: Dealing physical damage to nearby enemies every $116847t1 sec.
    -- https://wowhead.com/beta/spell=116847
    rushing_jade_wind = {
        id = 116847,
        duration = 6,
        tick_time = 0.75,
        max_stack = 1
    },
    shuffle = {
        id = 322120,
        duration = 9,
        max_stack = 1,
        copy = 215479
    },
    -- Disoriented.
    song_of_chiji = {
        id = 198909,
        duration = 20.0,
        max_stack = 1,
    },
    -- Talent: Healing for $w1 every $t1 sec.
    -- https://wowhead.com/beta/spell=115175
    soothing_mist = {
        id = 115175,
        duration = 8,
        type = "Magic",
        max_stack = 1
    },
    -- Talent: $?$w2!=0[Movement speed reduced by $w2%.  ][]Drenched in brew, vulnerable to Breath of Fire.
    -- https://wowhead.com/beta/spell=196733
    special_delivery = {
        id = 196733,
        duration = 15,
        max_stack = 1
    },
    -- Attacking all nearby enemies for Physical damage every $101546t1 sec.
    -- https://wowhead.com/beta/spell=330901
    spinning_crane_kick = {
        id = 330901,
        duration = 1.5,
        tick_time = 0.5,
        max_stack = 1,
        copy = { 101546, 322729 }
    },
    -- Movement slowed by $w1%.
    spirits_essence = {
        id = 450596,
        duration = 4.0,
        max_stack = 1,
    },
    -- Damage of next Crackling Jade Lightning increased by $s1%.  Energy cost of next Crackling Jade Lightning reduced by $s2%.
    -- https://wowhead.com/beta/spell=393039
    the_emperors_capacitor = {
        id = 393039,
        duration = 3600,
        max_stack = 20
    },
    -- Talent: Moving $s1% faster.
    -- https://wowhead.com/beta/spell=116841
    tigers_lust = {
        id = 116841,
        duration = 6,
        type = "Magic",
        max_stack = 1
    },
	touch_of_death = {
        id = 115080,
        duration = 8,
        max_stack = 1
    },
    -- Damage dealt to the Monk is redirected to you as Nature damage over $124280d.
    -- https://wowhead.com/beta/spell=122470
    touch_of_karma = {
        id = 122470,
        duration = 10,
        max_stack = 1
    },
    -- Talent: You left your spirit behind, allowing you to use Transcendence: Transfer to swap with its location.
    -- https://wowhead.com/beta/spell=101643
    transcendence = {
        id = 101643,
        duration = 900,
        max_stack = 1
    },
    transendence_tether = {
        id = 434763,
        duration = 3600,
        max_stack = 1,
        dot = "buff",
        friendly = true,
        no_ticks = true
    },
    transendence_tethered = {
        id = 434767,
        duration = 3600,
        max_stack = 1,
        dot = "buff",
        friendly = true,
        no_ticks = true
    },
    -- Talent: Your next Vivify is instant.
    -- https://wowhead.com/beta/spell=392883
    vivacious_vivification = {
        id = 392883,
        duration = 3600,
        max_stack = 1
    },
    weapons_of_order = {
        id = 387184,
        duration = function () return conduit.strike_with_clarity.enabled and 35 or 30 end,
        max_stack = 1,
        copy = 310454
    },
    weapons_of_order_debuff = {
        id = 387179,
        duration = 8,
        max_stack = 4,
        copy = 312106
    },
    yulons_grace = {
        id = 414143,
        duration = 30,
        max_stack = 1
    },
    -- Flying.
    -- https://wowhead.com/beta/spell=125883
    zen_flight = {
        id = 125883,
        duration = 3600,
        type = "Magic",
        max_stack = 1
    },
    zen_meditation = {
        id = 115176,
        duration = 8,
        max_stack = 1,
    },

    light_stagger = {
        id = 124275,
        duration = function () return talent.bob_and_weave.enabled and 13 or 10 end,
        unit = "player",
    },
    moderate_stagger = {
        id = 124274,
        duration = function () return talent.bob_and_weave.enabled and 13 or 10 end,
        unit = "player",
    },
    heavy_stagger = {
        id = 124273,
        duration = function () return talent.bob_and_weave.enabled and 13 or 10 end,
        unit = "player",
    },

    recent_purifies = {
        duration = 6,
        max_stack = 1
    },

    -- Azerite Powers
    straight_no_chaser = {
        id = 285959,
        duration = 7,
        max_stack = 1,
    },

    -- Conduits
    dizzying_tumble = {
        id = 336891,
        duration = 5,
        max_stack = 1
    },
    fortifying_ingredients = {
        id = 336874,
        duration = 15,
        max_stack = 1
    },
    lingering_numbness = {
        id = 336884,
        duration = 5,
        max_stack = 1
    },

    -- Legendaries
    mighty_pour = {
        id = 337994,
        duration = 8,
        max_stack = 1
    }
} )


spec:RegisterHook( "reset_postcast", function( x )
    for k, v in pairs( stagger ) do
        stagger[ k ] = nil
    end
    return x
end )


spec:RegisterGear( "tier31", 207243, 207244, 207245, 207246, 207248, 217188, 217190, 217186, 217187, 217189 )

-- Tier 30
spec:RegisterGear( "tier30", 202509, 202507, 202506, 202505, 202504 )
spec:RegisterAura( "leverage", {
    id = 408503,
    duration = 30,
    max_stack = 5
} )


spec:RegisterGear( "tier29", 200363, 200365, 200360, 200362, 200364 )
spec:RegisterAura( "brewmasters_rhythm", {
    id = 394797,
    duration = 15,
    max_stack = 4
} )

spec:RegisterGear( "tier19", 138325, 138328, 138331, 138334, 138337, 138367 )
spec:RegisterGear( "tier20", 147154, 147156, 147152, 147151, 147153, 147155 )
spec:RegisterGear( "tier21", 152145, 152147, 152143, 152142, 152144, 152146 )
spec:RegisterGear( "class", 139731, 139732, 139733, 139734, 139735, 139736, 139737, 139738 )

spec:RegisterGear( "cenedril_reflector_of_hatred", 137019 )
spec:RegisterGear( "cinidaria_the_symbiote", 133976 )
spec:RegisterGear( "drinking_horn_cover", 137097 )
spec:RegisterGear( "firestone_walkers", 137027 )
spec:RegisterGear( "fundamental_observation", 137063 )
spec:RegisterGear( "gai_plins_soothing_sash", 137079 )
spec:RegisterGear( "hidden_masters_forbidden_touch", 137057 )
spec:RegisterGear( "jewel_of_the_lost_abbey", 137044 )
spec:RegisterGear( "katsuos_eclipse", 137029 )
spec:RegisterGear( "march_of_the_legion", 137220 )
spec:RegisterGear( "salsalabims_lost_tunic", 137016 )
spec:RegisterGear( "soul_of_the_grandmaster", 151643 )
spec:RegisterGear( "stormstouts_last_gasp", 151788 )
spec:RegisterGear( "the_emperors_capacitor", 144239 )
spec:RegisterGear( "the_wind_blows", 151811 )


spec:RegisterHook( "spend", function( amount, resource )
    if equipped.the_emperors_capacitor and resource == "chi" then
        addStack( "the_emperors_capacitor" )
    end
end )

spec:RegisterStateTable( "healing_sphere", setmetatable( {}, {
    __index = function( t,  k)
        if k == "count" then
            t[ k ] = GetSpellCount( action.expel_harm.id )
            return t[ k ]
        end
    end
} ) )


local staggered_damage = {}
local staggered_damage_pool = {}
local total_staggered = 0

local stagger_ticks = {}

local function trackBrewmasterDamage( _, subtype, _, sourceGUID, sourceName, _, _, destGUID, destName, destFlags, _, arg1, arg2, arg3, arg4, arg5, arg6, _, arg8, _, _, arg11 )
    if destGUID == state.GUID then
        if subtype == "SPELL_ABSORBED" then
            local now = GetTime()

            if arg1 == destGUID and arg5 == 115069 then
                local dmg = table.remove( staggered_damage_pool, 1 ) or {}

                dmg.t = now
                dmg.d = arg8
                dmg.s = 6603

                total_staggered = total_staggered + arg8

                table.insert( staggered_damage, 1, dmg )

            elseif arg8 == 115069 then
                local dmg = table.remove( staggered_damage_pool, 1 ) or {}

                dmg.t = now
                dmg.d = arg11
                dmg.s = arg1

                total_staggered = total_staggered + arg11

                table.insert( staggered_damage, 1, dmg )

            end
        elseif subtype == "SPELL_PERIODIC_DAMAGE" and sourceGUID == state.GUID and arg1 == 124255 then
            table.insert( stagger_ticks, 1, arg4 )
            stagger_ticks[ 31 ] = nil

        end
    end
end

-- Use register event so we can access local data.
spec:RegisterCombatLogEvent( trackBrewmasterDamage )

spec:RegisterEvent( "PLAYER_REGEN_ENABLED", function ()
    table.wipe( stagger_ticks )
end )


function stagger_in_last( t )
    local now = GetTime()

    for i = #staggered_damage, 1, -1 do
        if staggered_damage[ i ].t + 10 < now then
            total_staggered = max( 0, total_staggered - staggered_damage[ i ].d )
            staggered_damage_pool[ #staggered_damage_pool + 1 ] = table.remove( staggered_damage, i )
        end
    end

    t = min( 10, t )

    if t == 10 then return total_staggered end

    local sum = 0

    for i = 1, #staggered_damage do
        if staggered_damage[ i ].t > now + t then
            break
        end
        sum = sum + staggered_damage[ i ]
    end

    return sum
end

local function avg_stagger_ps_in_last( t )
    t = max( 1, min( 10, t ) )
    return stagger_in_last( t ) / t
end


state.UnitStagger = UnitStagger


spec:RegisterStateTable( "stagger", setmetatable( {}, {
    __index = function( t, k, v )
        local stagger = debuff.heavy_stagger.up and debuff.heavy_stagger or nil
        stagger = stagger or ( debuff.moderate_stagger.up and debuff.moderate_stagger ) or nil
        stagger = stagger or ( debuff.light_stagger.up and debuff.light_stagger ) or nil

        if not stagger then
            if k == "up" then return false
            elseif k == "down" then return true
            else return 0 end
        end

        -- SimC expressions.
        if k == "light" then
            return t.percent < 3.5

        elseif k == "moderate" then
            return t.percent >= 3.5 and t.percent <= 6.5

        elseif k == "heavy" then
            return t.percent > 6.5

        elseif k == "none" then
            return stagger.down

        elseif k == "percent" or k == "pct" then
            -- stagger tick dmg / current effective hp
            if health.current == 0 then return 100 end
            return ceil( 100 * t.tick / health.current )

        elseif k == "percent_max" or k == "pct_max" then
            if health.max == 0 then return 100 end
            return ceil( 100 * t.tick / health.max )

        elseif k == "tick" or k == "amount" then
            if t.ticks_remain == 0 then return 0 end
            return t.amount_remains / t.ticks_remain

        elseif k == "ticks_remain" then
            return floor( stagger.remains / 0.5 )

        elseif k == "amount_remains" then
            t.amount_remains = UnitStagger( "player" )
            return t.amount_remains

        elseif k == "amount_to_total_percent" or k == "amounttototalpct" then
            return ceil( 100 * t.tick / t.amount_remains )

        elseif k:sub( 1, 17 ) == "last_tick_damage_" then
            local ticks = k:match( "(%d+)$" )
            ticks = tonumber( ticks )

            if not ticks or ticks == 0 then return 0 end

            -- This isn't actually looking backwards, but we'll worry about it later.
            local total = 0

            for i = 1, ticks do
                total = total + ( stagger_ticks[ i ] or 0 )
            end

            return total


            -- Hekili-specific expressions.
        elseif k == "incoming_per_second" then
            return avg_stagger_ps_in_last( 10 )

        elseif k == "time_to_death" then
            return ceil( health.current / ( t.tick * 2 ) )

        elseif k == "percent_max_hp" then
            return ( 100 * t.amount / health.max )

        elseif k == "percent_remains" then
            return total_staggered > 0 and ( 100 * t.amount / stagger_in_last( 10 ) ) or 0

        elseif k == "total" then
            return total_staggered

        elseif k == "dump" then
            if DevTools_Dump then DevTools_Dump( staggered_damage ) end

        else
            return stagger[ k ]

        end

        return nil

    end
} ) )

spec:RegisterTotem( "black_ox_statue", 627607 )
spec:RegisterPet( "niuzao_the_black_ox", 73967, "invoke_niuzao", 25, "niuzao" )

--[[ Dragonflight:
New priority increments BOC variable when list requirements are met and the last ability used was Blackout Kick.

rotation_blackout_combo:
    talent.blackout_combo.enabled & talent.salsalabims_strength.enabled & talent.charred_passions.enabled & ! talent.fluidity_of_motion.enabled

rotation_fom_boc:
    talent.blackout_combo.enabled & talent.salsalabims_strength.enabled & talent.charred_passions.enabled & talent.fluidity_of_motion.enabled

We will count actual Blackout Kicks in combat, and reset to zero when out of combat and Blackout Combo falls off. ]]

local blackoutComboCount = 0

spec:RegisterCombatLogEvent( function( _, subtype, _,  sourceGUID, _, _, _, _, _, _, _, spellID )
    if sourceGUID == state.GUID and subtype == "SPELL_CAST_SUCCESS" and spellID == 205523 and state.talent.blackout_combo.enabled and state.talent.salsalabims_strength.enabled and state.talent.charred_passions.enabled then
        blackoutComboCount = blackoutComboCount + 1
    end
end )


-- I shouldn't need to do this, but trying to prevent unnecessary warnings when scripts are loaded.
state.boc_count = 0

spec:RegisterStateExpr( "boc_count", function()
    return blackoutComboCount
end )


spec:RegisterHook( "reset_precast", function ()
    rawset( healing_sphere, "count", nil )
    if healing_sphere.count > 0 then
        applyBuff( "gift_of_the_ox", nil, healing_sphere.count )
    end

    -- Reset blackoutComboCount if we are not in combat and Blackout Combo has fallen off.
    if state.combat == 0 and buff.blackout_combo.down then
        blackoutComboCount = 0
    end
    boc_count = nil

    stagger.amount = nil
    stagger.amount_remains = nil
end )


-- Abilities
spec:RegisterAbilities( {
    -- You focus the assault on this target, increasing their damage taken by 3% for 6 sec. Each unique player that attacks the target increases the damage taken by an additional 3%, stacking up to 5 times. Your melee attacks refresh the duration of Focused Assault.
    admonishment = {
        id = 207025,
        cast = 0,
        cooldown = 20,
        gcd = "totem",

        pvptalent = "admonishment",
        startsCombat = false,
        texture = 620830,

        handler = function ()
            applyDebuff( "target", "admonishment" )
        end,
    },

    -- Guard the 4 closest players within 15 yards for 15 sec, allowing you to Stagger 20% of damage they take.
    avert_harm = {
        id = 202162,
        cast = 0,
        cooldown = 45,
        gcd = "spell",

        pvptalent = "avert_harm",
        startsCombat = false,
        texture = 620829,

        usable = function() return group, "requires allies" end,

        handler = function ()
            active_dot.avert_harm = min( 4, group_members )
        end,
    },

    -- Talent: Chug some Black Ox Brew, which instantly refills your Energy, Purifying Brew charges, and resets the cooldown of Celestial Brew.
    black_ox_brew = {
        id = 115399,
        cast = 0,
        cooldown = 120,
        gcd = "off",
        school = "physical",

        talent = "black_ox_brew",
        startsCombat = false,

        toggle = "defensives",

        handler = function ()
            gain( energy.max, "energy" )
            setCooldown( "celestial_brew", 0 )
            gainCharges( "purifying_brew", class.abilities.purifying_brew.charges )
        end,
    },

    -- Strike with a blast of Chi energy, dealing 1,429 Physical damage and granting Shuffle for 3 sec.
    blackout_kick = {
        id = 205523,
        cast = 0,
        cooldown = function() return talent.fluidity_of_motion.enabled and 3 or 4 end,
        hasteCD = true,
        gcd = "spell",
        school = "physical",

        startsCombat = true,

        handler = function ()
            applyBuff( "shuffle" )
            if buff.charred_passions.up and debuff.breath_of_fire_dot.up then applyDebuff( "target", "breath_of_fire_dot" ) end

            if talent.blackout_combo.enabled then applyBuff( "blackout_combo" ) end
            if talent.hit_scheme.enabled then addStack( "hit_scheme" ) end
            if talent.staggering_strikes.enabled then stagger.amount_remains = max( 0, stagger.amount_remains - stat.attack_power ) end
            if talent.walk_with_the_ox.enabled then reduceCooldown( "invoke_niuzao", 0.25 * talent.walk_with_the_ox.rank ) end

            if conduit.walk_with_the_ox.enabled and cooldown.invoke_niuzao.remains > 0 then reduceCooldown( "invoke_niuzao", 0.5 ) end

            addStack( "elusive_brawler" )
        end,
    },

    -- Talent: Breathe fire on targets in front of you, causing 897 Fire damage. Deals reduced damage to secondary targets. Targets affected by Keg Smash will also burn, taking 622 Fire damage and dealing 5% reduced damage to you for 12 sec.
    breath_of_fire = {
        id = 115181,
        cast = 0,
        cooldown = function () return buff.blackout_combo.up and 12 or 15 end,
        gcd = "totem",
        school = "fire",

        talent = "breath_of_fire",
        startsCombat = true,

        usable = function ()
            if active_dot.keg_smash / true_active_enemies < settings.bof_percent / 100 then
                return false, "keg_smash applied to fewer than " .. settings.bof_percent .. " targets"
            end
            return true
        end,

        handler = function ()
            removeBuff( "blackout_combo" )
            addStack( "elusive_brawler", nil, active_enemies * ( 1 + set_bonus.tier21_2pc ) )
            if debuff.keg_smash.up then applyDebuff( "target", "breath_of_fire_dot" ) end
            if talent.charred_passions.enabled or legendary.charred_passions.enabled then applyBuff( "charred_passions" ) end
        end,
    },

    -- Talent: A swig of strong brew that coalesces purified chi escaping your body into a celestial guard, absorbing 13,480 damage.
    celestial_brew = {
        id = 322507,
        cast = 0,
        cooldown = function() return talent.light_brewing.enabled and 36 or 45 end,
        gcd = "totem",
        school = "physical",

        talent = "celestial_brew",
        startsCombat = false,
        toggle = "defensives",

        handler = function ()
            removeBuff( "purified_chi" )
            applyBuff( "celestial_brew" )

            if buff.aspect_of_harmony_accumulator.up then
                removeBuff( "aspect_of_harmony_accumulator" )
                applyBuff( "aspect_of_harmony" )
            end

            if talent.pretense_of_instability.enabled then applyBuff( "pretense_of_instability" ) end
        end,
    },

    -- Talent: Hurls a torrent of Chi energy up to 40 yds forward, dealing 967 Nature damage to all enemies, and 1,775 healing to the Monk and all allies in its path. Healing reduced beyond 6 targets. Casting Chi Burst does not prevent avoiding attacks.
    chi_burst = {
        id = 123986,
        cast = 1,
        cooldown = 30,
        gcd = "spell",
        school = "nature",

        talent = "chi_burst",
        startsCombat = true,

        handler = function ()
        end,
    },

    -- Talent: Torpedoes you forward a long distance and increases your movement speed by 30% for 10 sec, stacking up to 2 times.
    chi_torpedo = {
        id = 115008,
        cast = 0,
        charges = function() return level > 13 and 3 or 2 end,
        cooldown = 20,
        recharge = 20,
        gcd = "off",
        school = "physical",

        talent = "chi_torpedo",
        startsCombat = true,

        handler = function ()
            addStack( "chi_torpedo" )
            setDistance( 5 )
            if talent.crashing_momentum.enabled then applyDebuff( "target", "crashing_momentum" ) end
            if talent.lighter_than_air.enabled then applyBuff( "lighter_than_air" ) end
        end,
    },

    -- Talent: You and the target charge each other, meeting halfway then rooting all targets within 6 yards for 4 sec.
    clash = {
        id = 324312,
        cast = 0,
        cooldown = 60,
        gcd = "totem",
        school = "physical",

        talent = "clash",
        startsCombat = true,

        handler = function ()
            setDistance( 5 )
            applyDebuff( "target", "clash" )
        end,
    },

    -- Channel Jade lightning, causing 654 Nature damage over 3.5 sec to the target and sometimes knocking back melee attackers.
    crackling_jade_lightning = {
        id = 117952,
        cast = 0,
        channeled = true,
        breakable = true,
        cooldown = 0,
        gcd = "spell",
        school = "nature",

        spend = 20,
        spendType = "energy",

        startsCombat = true,

        start = function ()
            removeBuff( "the_emperors_capacitor" )
            applyDebuff( "target", "crackling_jade_lightning" )
        end,
    },

    -- Talent: Reduces all damage you take by 20% to 50% for 10 sec, with larger attacks being reduced by more.
    dampen_harm = {
        id = 122278,
        cast = 0,
        cooldown = 120,
        gcd = "off",
        school = "physical",

        talent = "dampen_harm",
        startsCombat = false,

        toggle = "defensives",

        handler = function ()
            applyBuff( "dampen_harm" )
        end,
    },

    -- Talent: Removes all Poison and Disease effects from the target.
    detox = {
        id = 218164,
        cast = 0,
        charges = 1,
        cooldown = 8,
        recharge = 8,
        gcd = "spell",
        school = "nature",

        spend = 10,
        spendType = "energy",

        talent = "detox",
        startsCombat = false,
        toggle = "interrupts",

        usable = function () return debuff.dispellable_poison.up or debuff.dispellable_disease.up, "requires dispellable effect" end,
        handler = function ()
            removeDebuff( "player", "dispellable_poison" )
            removeDebuff( "player", "dispellable_disease" )
        end,
    },

    -- Talent: Reduces magic damage you take by 60% for 6 sec, and transfers all currently active harmful magical effects on you back to their original caster if possible.
    diffuse_magic = {
        id = 122783,
        cast = 0,
        cooldown = 90,
        gcd = "off",
        school = "nature",

        talent = "diffuse_magic",
        startsCombat = false,

        toggle = "interrupts",
        buff = "dispellable_magic",

        handler = function ()
            applyBuff( "diffuse_magic" )
            removeBuff( "dispellable_magic" )
        end,
    },

    -- Talent: Reduces the target's movement speed by 50% for 15 sec, duration refreshed by your melee attacks.
    disable = {
        id = 116095,
        cast = 0,
        cooldown = 0,
        gcd = "spell",
        school = "physical",

        spend = function()
            if state.spec.mistweaver then return 0.007, "mana" end
            return 15, "energy"
        end,

        talent = "disable",
        startsCombat = true,

        handler = function ()
            applyDebuff( "target", "disable" )
        end,
    },

    -- Your next Keg Smash deals 50% additional damage, and stuns all targets it hits for 3 sec.
    double_barrel = {
        id = 202335,
        cast = 0,
        cooldown = 45,
        gcd = "off",

        pvptalent = "double_barrel",
        startsCombat = false,
        texture = 644378,

        handler = function ()
            applyBuff( "double_barrel" )
        end,
    },

    -- Expel negative chi from your body, healing for $s1 and dealing $s2% of the amount healed as Nature damage to an enemy within $115129A1 yards.$?s322102[; Draws in the positive chi of all your Healing Spheres to increase the healing of Expel Harm.][]$?s322106[; Generates $s3 Chi.]?s342928[; Generates ${$s3+$342928s2} Chi.][]
    expel_harm = {
        id = 322101,
        cast = 0,
        cooldown = function() return level > 42 and 5 or 15 end,
        gcd = "totem",
        school = "nature",

        spend = 15,
        spendType = "energy",

        startsCombat = true,

        usable = function ()
            if ( settings.eh_percent > 0 and health.pct > settings.eh_percent ) then return false, "health is above " .. settings.eh_percent .. "%" end
            return true
        end,
        handler = function ()
            gain( ( healing_sphere.count * stat.attack_power ) + stat.spell_power * ( 1 + stat.versatility_atk_mod ), "health" )
            if pvptalent.reverse_harm.enabled then gain( 1, "chi" ) end
            removeBuff( "gift_of_the_ox" )
            if talent.tranquil_spirit.enabled and healing_sphere.count > 0 then stagger.amount_remains = 0.95 * stagger.amount_remains end
            healing_sphere.count = 0
        end,
    },

    -- Talent: Hurls a flaming keg at the target location, dealing 6,028 Fire damage to nearby enemies, causing your attacks against them to deal 467 additional Fire damage, and causing their melee attacks to deal 100% reduced damage for the next 3 sec.
    exploding_keg = {
        id = 325153,
        cast = 0,
        cooldown = 60,
        gcd = "totem",
        school = "fire",

        talent = "exploding_keg",
        startsCombat = true,

        handler = function ()
            applyDebuff( "target", "exploding_keg" )
        end,
    },

    -- Talent: Turns your skin to stone for 15 sec, increasing your current and maximum health by 15%, reducing all damage you take by 20%, increasing your armor by 25% and dodge chance by 25%.
    fortifying_brew = {
        id = 115203,
        cast = 0,
        cooldown = function () return ( talent.expeditious_fortification.enabled and 300 or 420 ) * ( essence.vision_of_perfection.enabled and 0.87 or 1 ) end,
        gcd = "off",
        school = "physical",

        talent = "fortifying_brew",
        startsCombat = false,

        toggle = "defensives",

        handler = function ()
            applyBuff( "fortifying_brew" )
            health.max = health.max * 1.2
            health.actual = health.actual * 1.2
            if conduit.fortifying_ingredients.enabled then applyBuff( "fortifying_ingredients" ) end
        end,
    },

    -- You fire off a rope spear, grappling the target's weapons and shield, returning them to you for 6 sec.
    grapple_weapon = {
        id = 233759,
        cast = 0,
        cooldown = 45,
        gcd = "totem",

        pvptalent = "grapple_weapon",
        startsCombat = true,
        texture = 132343,

        handler = function ()
            applyBuff( "grapple_weapon" )
        end,
    },

    -- Talent: Summons an effigy of Niuzao, the Black Ox for 25 sec. Niuzao attacks your primary target, and frequently Stomps, damaging all nearby enemies. While active, 25% of damage delayed by Stagger is instead Staggered by Niuzao.
    invoke_niuzao_the_black_ox = {
        id = 132578,
        cast = 0,
        cooldown = 180,
        gcd = "totem",
        school = "nature",

        talent = "invoke_niuzao_the_black_ox",
        startsCombat = false,

        toggle = "cooldowns",

        handler = function ()
            summonPet( "niuzao_the_black_ox", 25 )

            if legendary.invokers_delight.enabled then
                if buff.invokers_delight.down then stat.haste = stat.haste + 0.33 end
                applyBuff( "invokers_delight" )
            end
        end,

        copy = "invoke_niuzao"
    },

    -- Talent: Smash a keg of brew on the target, dealing 2,009 Physical damage to all enemies within 8 yds and reducing their movement speed by 20% for 15 sec. Deals reduced damage beyond 5 targets. Grants Shuffle for 5 sec and reduces the remaining cooldown on your Brews by 3 sec.
    keg_smash = {
        id = 121253,
        cast = 0,
        cooldown = 8,
        charges = function () return ( talent.stormstouts_last_keg.enabled or legendary.stormstouts_last_keg.enabled ) and 2 or nil end,
        recharge = function () return ( talent.stormstouts_last_keg.enabled or legendary.stormstouts_last_keg.enabled ) and 8 or nil end,
        gcd = "totem",
        school = "physical",

        spend = function () return buff.flow_of_battle_free_keg_smash.up and 0 or 40 end,
        spendType = "energy",

        talent = "keg_smash",
        startsCombat = true,

        handler = function ()
            applyDebuff( "target", "keg_smash" )
            active_dot.keg_smash = active_enemies

            applyBuff( "shuffle" )

            reduceCooldown( "celestial_brew", 4 + ( buff.blackout_combo.up and 2 or 0 ))
            reduceCooldown( "fortifying_brew", 4 + ( buff.blackout_combo.up and 2 or 0 ))
            gainChargeTime( "purifying_brew", 4 + ( buff.blackout_combo.up and 2 or 0 ))

            if buff.press_the_advantage.stack == 10 then
                removeBuff( "press_the_advantage" )
            end

            if buff.weapons_of_order.up then
                applyDebuff( "target", "weapons_of_order_debuff", nil, min( 5, debuff.weapons_of_order_debuff.stack + 1 ) )
            end

            if talent.salsalabims_strength.enabled then setCooldown( "breath_of_fire", 0 ) end
            if talent.walk_with_the_ox.enabled then reduceCooldown( "invoke_niuzao", 0.25 * talent.walk_with_the_ox.rank ) end

            removeBuff( "flow_of_battle_free_keg_smash" )
            removeBuff( "blackout_combo" )
            addStack( "elusive_brawler" )
        end,
    },

    -- Knocks down all enemies within 6 yards, stunning them for 3 sec.
    leg_sweep = {
        id = 119381,
        cast = 0,
        cooldown = function () return 60 - ( 5 * talent.ancient_arts.rank ) end,
        gcd = "spell",
        school = "physical",

        startsCombat = true,

        handler = function ()
            applyDebuff( "target", "leg_sweep" )
            interrupt()
            if conduit.dizzying_tumble.enabled then applyDebuff( "target", "dizzying_tumble" ) end
        end,
    },

    -- You perform a Mighty Ox Kick, hurling your enemy a distance behind you.
    mighty_ox_kick = {
        id = 202370,
        cast = 0,
        cooldown = 30,
        gcd = "totem",

        pvptalent = "mighty_ox_kick",
        startsCombat = true,
        texture = 1381297,

        handler = function ()
        end,
    },

    -- Douse allies in the targeted area with Nimble Brew, preventing the next full loss of control effect within 8 sec.
    nimble_brew = {
        id = 354540,
        cast = 0,
        cooldown = 90,
        gcd = "totem",

        pvptalent = "nimble_brew",
        startsCombat = false,
        texture = 839394,

        toggle = "defensives",

        handler = function ()
            applyBuff( "nimble_brew" )
        end,
    },

    -- Talent: Incapacitates the target for 1 min. Limit 1. Damage will cancel the effect.
    paralysis = {
        id = 115078,
        cast = 0,
        cooldown = function() return 45 - ( 7.5 * talent.ancient_arts.rank ) end,
        gcd = "spell",
        school = "physical",

        spend = 20,
        spendType = "energy",

        talent = "paralysis",
        startsCombat = true,
        debuff = function() return talent.pressure_points.enabled and "dispellable_enrage" or nil end,

        handler = function ()
            applyDebuff( "target", "paralysis" )
            if talent.pressure_points.enabled then removeDebuff( "target", "dispellable_enrage" ) end
        end,
    },

    -- Taunts the target to attack you and causes them to move toward you at 50% increased speed. This ability can be targeted on your Statue of the Black Ox, causing the same effect on all enemies within 10 yards of the statue.
    provoke = {
        id = 115546,
        cast = 0,
        cooldown = 8,
        gcd = "off",
        school = "physical",

        startsCombat = true,

        handler = function ()
            applyDebuff( "target", "provoke" )
        end,
    },

    -- Talent: Clears 50% of your damage delayed with Stagger. Instantly heals you for 25% of the damage cleared.
    purifying_brew = {
        id = 119582,
        cast = 0,
        charges = function () return level > 46 and 2 or nil end,
        cooldown = function () return ( talent.light_brewing.enabled and 12 or 15 ) * haste end,
        recharge = function ()
            if level < 47 then return end
            return ( talent.light_brewing.enabled and 12 or 15 ) * haste
        end,
        gcd = "off",
        school = "physical",

        talent = "purifying_brew",
        startsCombat = false,
        toggle = "defensives",

        usable = function ()
            if stagger.amount == 0 then return false, "no damage is staggered" end
            if health.current == 0 then return false, "you are dead" end
            return true
        end,

        handler = function ()
            if buff.blackout_combo.up then
                addStack( "elusive_brawler" )
                removeBuff( "blackout_combo" )
            end

            applyBuff( "purified_chi" )

            if talent.pretense_of_instability.enabled then applyBuff( "pretense_of_instability" ) end

            local stacks = stagger.heavy and 3 or stagger.moderate and 2 or 1
            addStack( "purified_chi", nil, stacks )
            if talent.ox_stance.enabled then addStack( "ox_stance", nil, stacks ) end -- This is a guess.

            local reduction = stagger.amount_remains * ( 0.5 + 0.03 * buff.brewmasters_rhythm.stack )
            stagger.amount_remains = stagger.amount_remains - reduction
            gain( 0.25 * reduction, "health" )

            applyBuff( "recent_purifies", nil, 1, reduction )
        end,

        copy = "brews"
    },

    -- Talent: Form a Ring of Peace at the target location for 5 sec. Enemies that enter will be ejected from the Ring.
    ring_of_peace = {
        id = 116844,
        cast = 0,
        cooldown = function() return 45 - ( 5 * talent.peace_and_prosperity.rank ) end,
        gcd = "spell",
        school = "nature",

        talent = "ring_of_peace",
        startsCombat = false,

        handler = function ()
        end,
    },

    -- Talent: Kick upwards, dealing 3,359 Physical damage.
    rising_sun_kick = {
        id = 107428,
        cast = 0,
        cooldown = 10,
        gcd = "spell",
        school = "physical",

        talent = "rising_sun_kick",
        startsCombat = true,

        handler = function ()
            removeBuff( "leverage" )

            if talent.black_ox_adept.enabled then addStack( "ox_stance", nil, 1 ) end

            if buff.press_the_advantage.stack == 10 then
                removeBuff( "press_the_advantage" )
            end

            if talent.strike_at_dawn.enabled then addStack( "elusive_brawler" ) end

            if set_bonus.tier30_4pc > 0 then addStack( "elusive_brawler" ) end
        end,
    },

    -- Roll a short distance.
    roll = {
        id = 109132,
        cast = 0,
        charges = function() return level > 13 and 3 or 2 end,
        cooldown = function () return talent.celerity.enabled and 15 or 20 end,
        recharge = function () return talent.celerity.enabled and 15 or 20 end,
        gcd = "off",
        school = "physical",

        startsCombat = false,
        notalent = "chi_torpedo",

        handler = function ()
            setDistance( 5 )
            if talent.crashing_momentum.enabled then applyDebuff( "target", "crashing_momentum" ) end
            if talent.lighter_than_air.enabled then applyBuff( "lighter_than_air" ) end
        end,
    },

    -- Talent: Summons a whirling tornado around you, causing 2,261 Physical damage over 7.8 sec to all enemies within 8 yards. Deals reduced damage beyond 5 targets.
    rushing_jade_wind = {
        id = 116847,
        cast = 0,
        cooldown = 6,
        hasteCD = true,
        gcd = "spell",
        school = "nature",

        talent = "rushing_jade_wind",
        startsCombat = false,

        handler = function ()
            applyBuff( "rushing_jade_wind" )
        end,
    },

    -- Conjures a cloud of hypnotic mist that slowly travels forward. Enemies touched by the mist fall asleep, Disoriented for $198909d.
    song_of_chiji = {
        id = 198898,
        cast = function() return 1.8 - 0.5 * talent.peace_and_prosperity.rank end,
        cooldown = 30.0,
        gcd = "spell",

        talent = "song_of_chiji",
        startsCombat = false,
    },

    -- Talent: Heals the target for 9,492 over 6.9 sec. While channeling, Enveloping Mist and Vivify may be cast instantly on the target.
    soothing_mist = {
        id = 115175,
        cast = 8,
        channeled = true,
        cooldown = 0,
        gcd = "totem",
        school = "nature",

        spend = 15,
        spendType = "energy",

        talent = "soothing_mist",
        startsCombat = false,

        start = function ()
            applyBuff( "soothing_mist" )
        end,
    },

    -- Talent: Jabs the target in the throat, interrupting spellcasting and preventing any spell from that school of magic from being cast for 4 sec.
    spear_hand_strike = {
        id = 116705,
        cast = 0,
        cooldown = 15,
        gcd = "off",
        school = "physical",

        talent = "spear_hand_strike",
        startsCombat = true,

        toggle = "interrupts",

        debuff = "casting",
        readyTime = state.timeToInterrupt,

        handler = function ()
            interrupt()
            if talent.energy_transfer.enabled then
                reduceCooldown( "paralysis", 5 )
                reduceCooldown( talent.chi_torpedo.enabled and "chi_torpedo" or "roll", 5 )
            end
        end,
    },

    -- Spin while kicking in the air, dealing 935 Physical damage over 1.3 sec to enemies within 8 yds. Dealing damage with Spinning Crane Kick grants Shuffle for 1 sec, and your Healing Spheres travel towards you.
    spinning_crane_kick = {
        id = 322729,
        cast = 0,
        cooldown = 0,
        gcd = "spell",
        school = "physical",

        spend = 25,
        spendType = "energy",

        startsCombat = true,

        handler = function ()
            applyBuff( "shuffle" )
            applyBuff( "spinning_crane_kick" )
            removeBuff( "counterstrike" )
            removeBuff( "leverage" )

            if buff.celestial_flames.up then
                applyDebuff( "target", "breath_of_fire_dot" )
                active_dot.breath_of_fire_dot = active_enemies
            end

            if buff.charred_passions.up and debuff.breath_of_fire_dot.up then
                applyDebuff( "target", "breath_of_fire_dot" )
            end

            if talent.walk_with_the_ox.enabled then reduceCooldown( "invoke_niuzao", 0.25 * talent.walk_with_the_ox.rank ) end

            if set_bonus.tier29_2pc > 0 then addStack( "brewmasters_rhythm" ) end
        end,
    },

    -- Summons a Black Ox Statue at the target location for $d, pulsing threat to all enemies within $163178A1 yards.; You may cast Provoke on the statue to taunt all enemies near the statue.
    summon_black_ox_statue = {
        id = 115315,
        cast = 0.0,
        cooldown = 10.0,
        gcd = "spell",

        talent = "summon_black_ox_statue",
        startsCombat = false,

        handler = function ()
            summonPet( "black_ox_statue", 1800 )
        end,
    },

    -- Strike with the palm of your hand, dealing 568 Physical damage. Reduces the remaining cooldown on your Brews by 1 sec.
    tiger_palm = {
        id = 100780,
        cast = 0,
        cooldown = 0,
        gcd = "spell",
        school = "physical",

        spend = 50,
        spendType = "energy",

        startsCombat = true,
        notalent = "press_the_advantage",

        handler = function ()
            removeBuff( "blackout_combo" )
            removeBuff( "counterstrike" )

            reduceCooldown( "celestial_brew", 1 )
            reduceCooldown( "fortifying_brew", 1 )
            gainChargeTime( "purifying_brew", 1 )

            if set_bonus.tier29_2pc > 0 then addStack( "brewmasters_rhythm" ) end
        end,
    },

    -- Talent: Increases a friendly target's movement speed by 70% for 6 sec and removes all roots and snares.
    tigers_lust = {
        id = 116841,
        cast = 0,
        cooldown = 30,
        gcd = "spell",
        school = "physical",

        talent = "tigers_lust",
        startsCombat = false,

        handler = function ()
            applyBuff( "tigers_lust" )
        end,
    },

    -- Causes a surge of invigorating mists, healing the target for $<healing>$?s274586[ and all allies with your Renewing Mist active for $425804s1, reduced beyond $274586s1 allies][].
    vivify = {
        id = 116670,
        cast = function() return buff.vivacious_vivification.up and 0 or 1.5 end,
        cooldown = 0.0,
        gcd = "spell",

        spend = function() return buff.vivacious_vivification.up and 7.5 or 30 end,
        spendType = 'energy',

        startsCombat = false,

        handler = function ()
            removeBuff( "vivacious_vivification" )
        end,
    },

    -- For the next 30 sec, your Mastery is increased by 10%. Additionally, Keg Smash cooldown is reset instantly and enemies hit by Keg Smash take 8% increased damage from you for 10 sec, stacking up to 4 times.
    weapons_of_order = {
        id = function() return talent.weapons_of_order.enabled and 387184 or 310454 end,
        cast = 0,
        cooldown = 120,
        gcd = "spell",
        school = "arcane",


        spend = 0.05,
        spendType = "mana",

        startsCombat = false,
        toggle = "cooldowns",

        handler = function ()
            applyBuff( "weapons_of_order" )
            setCooldown( "keg_smash", 0 )
            if talent.call_to_arms.enabled or legendary.call_to_arms.enabled then summonPet( "niuzao", 12 ) end
            if talent.chi_surge.enabled then reduceCooldown( "weapons_of_order", min( active_enemies, 5 ) * 4 ) end
        end,

        copy = { 387184, 310454 }
    },

    -- Talent: Reduces all damage taken by 60% for 8 sec. Being hit by a melee attack, or taking another action will cancel this effect.
    zen_meditation = {
        id = 115176,
        cast = 8,
        channeled = true,
        cooldown = 300,
        gcd = "off",
        school = "nature",

        talent = "zen_meditation",
        startsCombat = false,

        toggle = "defensives",

        start = function ()
            applyBuff( "zen_meditation" )
        end,
    },
	
	-- You exploit the enemy target's weakest point, instantly killing $?s322113[creatures if they have less health than you.][them.    Only usable on creatures that have less health than you]$?s322113[ Deals damage equal to $s3% of your maximum health against players and stronger creatures under $s2% health.][.]$?s325095[    Reduces delayed Stagger damage by $325095s1% of damage dealt.]?s325215[    Spawns $325215s1 Chi Spheres, granting 1 Chi when you walk through them.]?s344360[    Increases the Monk's Physical damage by $344361s1% for $344361d.][]
    touch_of_death = {
        id = 322109,
        cast = 0,
        cooldown = function () return 180 - ( 90 * talent.fatal_touch.rank ) end,
        gcd = "spell",
        school = "physical",

        startsCombat = true,

        toggle = "cooldowns",
        cycle = "touch_of_death",

        -- Non-players can be executed as soon as their current health is below player's max health.
        -- All targets can be executed under 15%, however only at 35% damage.
        usable = function ()
            return ( talent.improved_touch_of_death.enabled and target.health.pct < 15 ) or ( target.class == "npc" and target.health_current < health.max ), "requires low health target"
        end,

        handler = function ()
            applyDebuff( "target", "touch_of_death" )
            if talent.fatal_touch.enabled then applyBuff( "fatal_touch" ) end
        end,
    },
} )


spec:RegisterRanges( "blackout_kick", "tiger_palm", "keg_smash", "paralysis", "provoke", "crackling_jade_lightning" )

spec:RegisterOptions( {
    enabled = true,

    aoe = 2,
    cycle = false,

    nameplates = true,
    nameplateRange = 10,
    rangeFilter = false,

    damage = true,
    damageDots = false,
    damageExpiration = 8,

    potion = "phantom_fire",

    package = "Brewmaster"
} )


--[[ spec:RegisterSetting( "ox_walker", true, {
    name = "Use |T606543:0|t Spinning Crane Kick in Single-Target with Walk with the Ox",
    desc = "If checked, the default priority will recommend |T606543:0|t Spinning Crane Kick when Walk with the Ox is active.  This tends to " ..
        "reduce mitigation slightly but increase damage based on using Invoke Niuzao more frequently.",
    type = "toggle",
    width = "full",
} ) ]]


spec:RegisterSetting( "purify_for_celestial", true, {
    name = strformat( "%s: Maximize Shield", Hekili:GetSpellLinkWithTexture( spec.abilities.celestial_brew.id ) ),
    desc = strformat( "If checked, %s may be recommended more frequently to build stacks of %s for your %s shield.\n\n" ..
        "This feature may work best with the %s talent, but risks leaving you without a charge of %s following a large spike in your %s.",
        Hekili:GetSpellLinkWithTexture( spec.abilities.purifying_brew.id ), Hekili:GetSpellLinkWithTexture( spec.auras.purified_chi.id ),
        Hekili:GetSpellLinkWithTexture( spec.abilities.celestial_brew.id ), Hekili:GetSpellLinkWithTexture( spec.talents.light_brewing[2] ),
        spec.abilities.purifying_brew.name, Hekili:GetSpellLinkWithTexture( 115069 ) ),
    type = "toggle",
    width = "full",
} )


spec:RegisterSetting( "purify_for_niuzao", true, {
    name = strformat( "%s: Maximize %s", Hekili:GetSpellLinkWithTexture( spec.abilities.purifying_brew.id ),
        Hekili:GetSpellLinkWithTexture( spec.talents.improved_invoke_niuzao_the_black_ox[2] ) ),
    desc = strformat( "If checked, %s may be recommended when %s is active if %s is talented.\n\n"
        .. "This feature is used to maximize %s damage from your guardian.", Hekili:GetSpellLinkWithTexture( spec.abilities.purifying_brew.id ),
        Hekili:GetSpellLinkWithTexture( spec.abilities.invoke_niuzao.id ), Hekili:GetSpellLinkWithTexture( spec.talents.improved_invoke_niuzao_the_black_ox[2] ),
        Hekili:GetSpellLinkWithTexture( 227291 ) ),
    type = "toggle",
    width = "full"
} )


spec:RegisterSetting( "purify_stagger_currhp", 12, {
    name = strformat( "%s: %s Tick %% Current Health", Hekili:GetSpellLinkWithTexture( spec.abilities.purifying_brew.id ), Hekili:GetSpellLinkWithTexture( 115069 ) ),
    desc = strformat( "If set above zero, %s may be recommended when your current %s ticks for this percentage of your |cFFFFD100current|r effective health (or more).  "
        .. "Custom priorities may ignore this setting.\n\n"
        .. "This value is halved when playing solo.", Hekili:GetSpellLinkWithTexture( spec.abilities.purifying_brew.id ), Hekili:GetSpellLinkWithTexture( 115069 ) ),
    type = "range",
    min = 0,
    max = 100,
    step = 0.1,
    width = "full"
} )


spec:RegisterSetting( "purify_stagger_maxhp", 6, {
    name = strformat( "%s: %s Tick %% Maximum Health", Hekili:GetSpellLinkWithTexture( spec.abilities.purifying_brew.id ), Hekili:GetSpellLinkWithTexture( 115069 ) ),
    desc = strformat( "If set above zero, %s may be recommended when your current %s ticks for this percentage of your |cFFFFD100maximum|r health (or more).  "
        .. "Custom priorities may ignore this setting.\n\n"
        .. "This value is halved when playing solo.", Hekili:GetSpellLinkWithTexture( spec.abilities.purifying_brew.id ), Hekili:GetSpellLinkWithTexture( 115069 ) ),
    type = "range",
    min = 0,
    max = 100,
    step = 0.1,
    width = "full"
} )


spec:RegisterSetting( "bof_percent", 50, {
    name = strformat( "%s: Require %s %%", Hekili:GetSpellLinkWithTexture( spec.abilities.breath_of_fire.id ),
        Hekili:GetSpellLinkWithTexture( spec.abilities.keg_smash.id ) ),
    desc = strformat( "If set above zero, %s may be recommended only if this percentage of your identified targets are afflicted with %s.\n\n" ..
        "Example:  If set to |cFFFFD10050|r, with 4 targets, |W%s|w will only be recommended when at least 2 targets have |W%s|w applied.",
        Hekili:GetSpellLinkWithTexture( spec.abilities.breath_of_fire.id ), Hekili:GetSpellLinkWithTexture( spec.abilities.keg_smash.id ),
        spec.abilities.breath_of_fire.name, spec.abilities.keg_smash.name ),
    type = "range",
    min = 0,
    max = 100,
    step = 0.1,
    width = "full"
} )


spec:RegisterSetting( "eh_percent", 65, {
    name = strformat( "%s: Health %%", Hekili:GetSpellLinkWithTexture( spec.abilities.expel_harm.id ) ),
    desc = strformat( "If set above zero, %s will not be recommended until your health falls below this percentage.",
        Hekili:GetSpellLinkWithTexture( spec.abilities.expel_harm.id ) ),
    type = "range",
    min = 0,
    max = 100,
    step = 1,
    width = "full"
} )

spec:RegisterSetting( "vivify_percent", 65, {
    name = strformat( "%s: Health %%", Hekili:GetSpellLinkWithTexture( spec.abilities.vivify.id ) ),
    desc = strformat( "If set above zero, %s will not be recommended until your health falls below this percentage.",
        Hekili:GetSpellLinkWithTexture( spec.abilities.vivify.id ) ),
    type = "range",
    min = 0,
    max = 100,
    step = 1,
    width = "full"
} )

spec:RegisterSetting( "max_damage", true, {
    name = strformat( "%s: Maximize Damage", Hekili:GetSpellLinkWithTexture( spec.auras.blackout_combo.id ) ),
    desc = strformat( "If checked, %s won't be recommended if %s is up to maximize damage.\n",
        Hekili:GetSpellLinkWithTexture( spec.abilities.purifying_brew.id ), Hekili:GetSpellLinkWithTexture( spec.auras.blackout_combo.id ) ),
    type = "toggle",
    width = "full",
} )


spec:RegisterPack( "Brewmaster", 20241021, [[Hekili:nJvBVTnos4FlblGAC6gfjz7MKIydCTF52IdloaxG9BwMwI2MBKe1rrL0CWq)23HuVrklkB3KDBrbkCehoZZ8cho8zP7YVUCriIJx(7EoEtCD8CTDDhF30jlxWFjfVCrkk4r0w4hjOy4))ed)CmkJJzILEjIIcfQiJMZcGL3X5PzF8MB2s47YxBhqJVjJeNhH4eAsadTHl(7GBwUyDojI)Bjlx3V9hVCbkNVJcMzbj(ZGMjHH4sXXzblxie)AxNR9C)yXQpHw)skJs3a)mcamnNxS6Z0410IVu8LArDfI(VYsXbWQcz)3iwmn5LIvOGGCjkPm4psclwjmAXQ8ub2A0HZ9x759rHMtYYJXhASvpd(DXQVs2Ibf9FrrXQ71zQW(prjG(dP5RJWx)5p1kWDLkVsGeWg4Kmsakc0uoJS5fsYwWKqciRDt3ET3hGn91DaA(dey0)aqajz5IisgptMDXBq5rC4N)UmBJtqGLdx(PLlcyeirsqqUgX2I52H415B2yhajyWy2mmkGdjIar2dsYPyeZFheF8Z4mYJ4LCiTj0zTeHKnBYZW(XOTKavtbco2OX3Hrr8D2PI0YdZkwLH5cZNz)e5jWT9tXqTvcSOvXkj(GVJci08mFPeqmsyE780wKuUvHDNmGtN8OmMAPyZuzO2FdL5hGJWqGqKaajUSyfNeJ95uW9(MFWorildqCXQTbH2W3kwTFFfcLAHGdbXiaUAHU2cmCmIKuQdx7PfRUsrxJkvxaLgfsFoXUbn(RHsaT96PVtWwvOZFdRmGi8H5sJ0gIsRlQKkueQMEsHQYseD0iqyDu6ciqHIGeMnjgou(KWz1LUYedfVgPOTMCJiUhIGIlSYwxxDg0pqCeScjJADtDBlCZpy0n3YOvjRVFl3B5ughTf6j4hKZy7sL5cNsblxOS4F(SJTZHYE3A0TYOr0FM9kz5RZW1M3DAjTE9nRVFxduZ3NNj34qo09)WsxVoF6uswUoNw26VdVRUKAwJ7nS3mR)Wa0v1zqx08LP)DN)EZ8q3H9qVt7g7Iv3ovQEsc4dcnu6K(JZKwPsy5vtxjdko2WnwVV9NIlVkllgv77YydCjmxbuYGJYWgO4uCcmpclwc3tCaJIvtDEZH7LviwbthEtuh3rc6jQJpXP5b78PB8dXi(UoZp5A(2zPP3s2Wf7LVd7t)MnKRdEu6qtKiStmOPKbVRE(QwCG)wkoQnW(bvmMsRKrdB3QkY6ikn0Fto7LUIDNMyywgMjgRORy3RkgIfGseJDXysqQjQNJQOrKT74z()zE424EK1vv2negwc0UsPnqlkjagEGbdpaZHh1v0XAUdARm8ZibpM1vYUdH2KXzKKhXCxOPreLR83In1nH3ztED2KNCtMhUbNGzBFrM9N4OMTGcfOIPPM0Z8GeVYgAY1rYhGjcv7kF(LVYRVSFcfLJlVBYES8OM65XAD8mgLcVpsOekle6OvDLYfIhwX7XeLO0Md5gz9M5Hd9mpOXpbEF7S1hecAgQ(nkoyE(KxzCyJ4uQV27xC6BbXfut(EICEDICd5MJnpPYR0nptq3B6U5XFhKTvJsvHV3GK(yx9(4vo3JWo7(AET2KWR28xNZY62YDSwhYUorxHn)s92Y(nr5Kqc)fHsILxfvx43AhgjtChBwEsjYf6(ixE2jpQYKaxqMJFkksEz4yZ9xRqygCtryZilhaUhXaYIrz7KAZCR2kTjEipdExCkkld2FM2X8HSyBn4bQqLpIdwu9C5yPCIIkqZWejIGU4EtnHUxkKW9Ec7d3XetWLLLtAD6SussIaHbmXD5nzfZ9AFLPBZnVmDSDOjHNmytI(JJ9ZiIHuLOFs3iOyq16jmfR3QeZ1ec5U8OzSXNqXJYyR6Asgp0AtatlgrLQaQT7CMEIwBI2A)osP1MGLNTtOT)efI9FMK0DcTjAZmtsEI(i2pHK))ru5WV1d00DBMBbupzKOOf6LETsJ3gi3gbH20LBa(0wCIPofto(KyVs71)PkOhCkdlkSrTK(2uB3307MFNxtbxv79dp8125V8FlEcMQxSsfF(UU2WWTpJycGcJfljQMeNcpfcUWxq3(7QiO(DfRy4)xouIbLFzub96OCongXfFaQ5t2IZSl(Y)HKalnTKgEWAYLF3Wmoc6MtpQu1Ehi9LUFBKTGL9FtcvHj8kpIsHt1sU1HLLuIhig6(orqNUHeHRdnWJXRZcVF2nLX9IV03AnHWFLSzMPiUalvBg2YbmXxUvJC4RUxno6vxOKYCHMAFR4dZmqgV1WeXRQx9(PLivYMS1GKUBDzp0T)qfj3733hTXwgPy)bx7PxvT3r73Fes1FWRwwRdjsFUGPEf3txfQUNjIYTU8IHle737gb7RNPrReUNR0gv8LF5xQRA7jtebNK8dcNnvPWRbrM7R2BARuoRuOaSNTyxE52WvfsovoBF8a0OZs2ChlfwVMp7iCQniaf869JfFx5Ox7zmi2dgToFik5p8uryjzJ)dgapF0DYHV3kiwM1M5mSpmt3hGNZ9pyu87cIUAquH0Zo3EC7uRdzzDE7JCV6s416Vx8FxjJ8JgzzK4xvl2z9owDQZzB1l7L92rQ2uNCw1vAPlvaeJKXoFILci7HawT0U(adWxAzvv7RnKOQ(vDotvxPdfPAb1Agr10KgbOAwwLVt1fedxadqg)Rc2jNvZO5rLWt3zviLuevlNa(HjodF17zFS4uzPzUJ94RAlHSmrdP1fNchm)K4exCeUe)H4mASa(GNJ(hM7o5CCxpf39ngNNbk0c6hLtp4cGZpWRXvNMNw)sc1p210QR1HofrS5IJYgJwJYMNb30o8a61uLV5jVkJH2pRekBQN3(Q98P(ziXAi1BzITmdluxIo2YmFlpCVLaZT86mFYrI1NvO(WHdmvVQvRObvzXVzoSAFSsVbT9719VhMocEF1fhjpSF)LdeZgpyAAuNREB5EQ3IkTWDxMLuxu7bpMRNlViA(eNRnZzZvQ81CcvTNToLuTS8Vc]] )