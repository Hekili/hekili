-- MonkBrewmaster.lua
-- July 2024

if UnitClassBase( "player" ) ~= "MONK" then return end

local addon, ns = ...
local Hekili = _G[ addon ]
local class, state = Hekili.Class, Hekili.State

local strformat = string.format

local spec = Hekili:NewSpecialization( 268 )
local GetSpellCount = C_Spell.GetSpellCastCount

spec:RegisterResource( Enum.PowerType.Mana )
spec:RegisterResource( Enum.PowerType.Energy )
spec:RegisterResource( Enum.PowerType.Chi )

spec:RegisterTalents( {
    -- Monk Talents
    ancient_arts                        = { 101184, 344359, 2 }, -- Reduces the cooldown of Paralysis by ${$abs($s0/1000)} sec and the cooldown of Leg Sweep by ${$s2/-1000} sec.
    bounce_back                         = { 101177, 389577, 1 }, -- When a hit deals more than $m2% of your maximum health, reduce all damage you take by $s1% for $390239d.; This effect cannot occur more than once every $m3 seconds.
    bounding_agility                    = { 101161, 450520, 1 }, -- Roll and Chi Torpedo travel a small distance further.
    calming_presence                    = { 101153, 388664, 1 }, -- Reduces all damage taken by $s1%.
    celerity                            = { 101183, 115173, 1 }, -- Reduces the cooldown of Roll by ${$m1/-1000} sec and increases its maximum number of charges by $m2.
    celestial_determination             = { 101180, 450638, 1 }, -- While your Celestial is active, you cannot be slowed below $s2% normal movement speed.
    chi_proficiency                     = { 101169, 450426, 2 }, -- Magical damage done increased by $s1% and healing done increased by $s2%.
    chi_torpedo                         = { 101183, 115008, 1 }, -- Torpedoes you forward a long distance and increases your movement speed by $119085m1% for $119085d, stacking up to 2 times.
    clash                               = { 101154, 324312, 1 }, -- You and the target charge each other, meeting halfway then rooting all targets within $128846A1 yards for $128846d.
    crashing_momentum                   = { 101149, 450335, 1 }, -- Targets you Roll through are snared by $450342s1% for $450342d.
    diffuse_magic                       = { 101165, 122783, 1 }, -- Reduces magic damage you take by $m1% for $d, and transfers all currently active harmful magical effects on you back to their original caster if possible.
    disable                             = { 101149, 116095, 1 }, -- Reduces the target's movement speed by $s1% for $d, duration refreshed by your melee attacks.$?s343731[ Targets already snared will be rooted for $116706d instead.][]
    elusive_mists                       = { 101144, 388681, 1 }, -- Reduces all damage taken by you and your target while channeling Soothing Mists by $s1%.
    energy_transfer                     = { 101151, 450631, 1 }, -- Successfully interrupting an enemy reduces the cooldown of Paralysis and Roll by ${$s1/-1000} sec.
    escape_from_reality                 = { 101176, 394110, 1 }, -- After you use Transcendence: Transfer, you can use Transcendence: Transfer again within $343249d, ignoring its cooldown.
    expeditious_fortification           = { 101174, 388813, 1 }, -- Fortifying Brew cooldown reduced by ${$s1/-1000} sec.
    fast_feet                           = { 101185, 388809, 1 }, -- Rising Sun Kick deals $s1% increased damage. Spinning Crane Kick deals $s2% additional damage.; 
    fatal_touch                         = { 101178, 394123, 1 }, -- Touch of Death increases your damage by $450832s1% for $450832d after being cast and its cooldown is reduced by ${$s1/-1000} sec.
    ferocity_of_xuen                    = { 101166, 388674, 1 }, -- Increases all damage dealt by $s1%.
    flow_of_chi                         = { 101170, 450569, 1 }, -- You gain a bonus effect based on your current health.; Above $s1% health: Movement speed increased by $450574s1%. This bonus stacks with similar effects.; Between $s1% and $s2% health: Damage taken reduced by $450572s1%.; Below $s2% health: Healing received increased by $450571s1%. 
    fortifying_brew                     = { 101173, 115203, 1 }, -- Turns your skin to stone for $120954d, increasing your current and maximum health by $<health>% and reducing all damage you take by $<damage>%.; Combines with other Fortifying Brew effects.
    grace_of_the_crane                  = { 101146, 388811, 1 }, -- Increases all healing taken by $s1%.
    hasty_provocation                   = { 101158, 328670, 1 }, -- Provoked targets move towards you at $s1% increased speed.
    healing_winds                       = { 101171, 450560, 1 }, -- Transcendence: Transfer immediately heals you for $450559s1% of your maximum health.
    improved_touch_of_death             = { 101140, 322113, 1 }, -- Touch of Death can now be used on targets with less than $s1% health remaining, dealing $s2% of your maximum health in damage.
    ironshell_brew                      = { 101174, 388814, 1 }, -- Increases your maximum health by an additional $s1% and your damage taken is reduced by an additional $s2% while Fortifying Brew is active.
    jade_walk                           = { 101160, 450553, 1 }, -- While out of combat, your movement speed is increased by $450552s1%.
    lighter_than_air                    = { 101168, 449582, 1 }, -- Roll causes you to become lighter than air, allowing you to double jump to dash forward a short distance once within $449609d, but the cooldown of Roll is increased by ${$s1/1000} sec.
    martial_instincts                   = { 101179, 450427, 2 }, -- Increases your Physical damage done by $s1% and Avoidance increased by $s2%.
    paralysis                           = { 101142, 115078, 1 }, -- Incapacitates the target for $d. Limit 1. Damage will cancel the effect.
    peace_and_prosperity                = { 101163, 450448, 1 }, -- Reduces the cooldown of Ring of Peace by ${$s1/-1000} sec and Song of Chi-Ji's cast time is reduced by ${$s2/-1000}.1 sec.
    pressure_points                     = { 101141, 450432, 1 }, -- Paralysis now removes all Enrage effects from its target.
    profound_rebuttal                   = { 101135, 392910, 1 }, -- Expel Harm's critical healing is increased by $s1%.
    quick_footed                        = { 101158, 450503, 1 }, -- The duration of snare effects on you is reduced by $s1%.
    ring_of_peace                       = { 101136, 116844, 1 }, -- Form a Ring of Peace at the target location for $d. Enemies that enter will be ejected from the Ring.
    rising_sun_kick                     = { 101186, 107428, 1 }, -- Kick upwards, dealing $?s137025[${$185099s1*$<CAP>/$AP}][$185099s1] Physical damage$?s128595[, and reducing the effectiveness of healing on the target for $115804d][].$?a388847[; Applies Renewing Mist for $388847s1 seconds to an ally within $388847r yds][]
    rushing_reflexes                    = { 101154, 450154, 1 }, -- Your heightened reflexes allow you to react swiftly to the presence of enemies, causing you to quickly lunge to the nearest enemy in front of you within $450156r yards after you Roll.
    save_them_all                       = { 101157, 389579, 1 }, -- When your healing spells heal an ally whose health is below $s3% maximum health, you gain an additional $s1% healing for the next $390105d.
    song_of_chiji                       = { 101136, 198898, 1 }, -- Conjures a cloud of hypnotic mist that slowly travels forward. Enemies touched by the mist fall asleep, Disoriented for $198909d.
    soothing_mist                       = { 101143, 115175, 1 }, -- Heals the target for $o1 over $d. While channeling, Enveloping Mist$?s227344[, Surging Mist,][]$?s124081[, Zen Pulse,][] and Vivify may be cast instantly on the target.$?s117907[; Each heal has a chance to cause a Gust of Mists on the target.][]$?s388477[; Soothing Mist heals a second injured ally within $388478A2 yds for $388477s1% of the amount healed.][]
    spear_hand_strike                   = { 101152, 116705, 1 }, -- Jabs the target in the throat, interrupting spellcasting and preventing any spell from that school of magic from being cast for $d.
    spirits_essence                     = { 101138, 450595, 1 }, -- Transcendence: Transfer snares targets within $450596A2 yds by $450596s1% for $450596d when cast.
    strength_of_spirit                  = { 101135, 387276, 1 }, -- Expel Harm's healing is increased by up to $s1%, based on your missing health.
    swift_art                           = { 101155, 450622, 1 }, -- Roll removes a snare effect once every $proccooldown sec.
    tiger_tail_sweep                    = { 101182, 264348, 1 }, -- Increases the range of Leg Sweep by $s1 yds.
    tigers_lust                         = { 101147, 116841, 1 }, -- Increases a friendly target's movement speed by $s1% for $d and removes all roots and snares.
    transcendence                       = { 101167, 101643, 1 }, -- Split your body and spirit, leaving your spirit behind for $d. Use Transcendence: Transfer to swap locations with your spirit.
    transcendence_linked_spirits        = { 101176, 434774, 1 }, -- Transcendence now tethers your spirit onto an ally for $434763d. Use Transcendence: Transfer to teleport to your ally's location.
    vigorous_expulsion                  = { 101156, 392900, 1 }, -- Expel Harm's healing increased by $s1% and critical strike chance increased by $s2%. 
    vivacious_vivification              = { 101145, 388812, 1 }, -- Every $t1 sec, your next Vivify becomes instant and its healing is increased by $392883s2%.$?c1[; This effect also reduces the energy cost of Vivify by $392883s3%.]?c3[; This effect also reduces the energy cost of Vivify by $392883s3%.][]; 
    winds_reach                         = { 101148, 450514, 1 }, -- The range of Disable is increased by $s1 yds.;  ; The duration of Crashing Momentum is increased by ${$s3/1000} sec and its snare now reduces movement speed by an additional $s2%.
    windwalking                         = { 101175, 157411, 1 }, -- You and your allies within $m2 yards have $s1% increased movement speed. Stacks with other similar effects.
    yulons_grace                        = { 101165, 414131, 1 }, -- Find resilience in the flow of chi in battle, gaining a magic absorb shield for ${$s1/10}.1% of your max health every $t sec in combat, stacking up to $s2%.

    -- Brewmaster Talents
    against_all_odds                    = { 101253, 450986, 1 }, -- Flurry Strikes increase your Agility by $451061s1% for $451061d, stacking up to $451061u times.
    anvil_stave                         = { 101081, 386937, 2 }, -- Each time you dodge or an enemy misses you, the remaining cooldown on your Brews is reduced by ${$s1/10}.1 sec. Effect reduced for each recent melee attacker.
    aspect_of_harmony                   = { 101223, 450508, 1 }, -- Store vitality from $?a137023[$s1%][$s2%] of your damage dealt and $?a137023[$s3%][$s4%] of your $?a137023[effective ][]healing.$?a137024[ Vitality stored from overhealing is reduced.][]; For $450711d after casting $?a137023[Celestial Brew][Thunder Focus Tea] your spells and abilities draw upon the stored vitality to deal $s6% additional $?a137023[damage over $450763d][healing over $450769d].
    august_blessing                     = { 101084, 454483, 1 }, -- When you would be healed above maximum health, you instead convert an amount equal to $s1% of your critical strike chance to a heal over time effect.
    balanced_stratagem                  = { 101230, 450889, 1 }, -- Casting a Physical spell or ability increases the damage and healing of your next Fire or Nature spell or ability by 5%, and vice versa. Stacks up to 5.
    black_ox_adept                      = { 101198, 455079, 1 }, -- Rising Sun Kick grants a charge of Ox Stance.
    black_ox_brew                       = { 101190, 115399, 1 }, -- Chug some Black Ox Brew, which instantly refills your Energy, Purifying Brew charges, and resets the cooldown of Celestial Brew.
    blackout_combo                      = { 101195, 196736, 1 }, -- Blackout Kick also empowers your next ability:; Tiger Palm: Damage increased by $s1%.; Breath of Fire: Damage increased by $228563s5%, and damage reduction increased by $228563s2%.; Keg Smash: Reduces the remaining cooldown on your Brews by $s3 additional sec.; Celestial Brew: Gain up to $s6 additional stacks of Purified Chi.; Purifying Brew: Pauses Stagger damage for $s4 sec.
    bob_and_weave                       = { 101190, 280515, 1 }, -- Increases the duration of Stagger by ${$s1/10}.1 sec.
    breath_of_fire                      = { 101069, 115181, 1 }, -- Breathe fire on targets in front of you, causing $s1 Fire damage. Deals reduced damage to secondary targets.; Targets affected by Keg Smash will also burn, taking $123725o1 Fire damage and dealing $123725s2% reduced damage to you for $123725d.
    call_to_arms                        = { 101192, 397251, 1 }, -- Weapons of Order calls forth $?c1[Niuzao, the Black Ox]?c2&s325197[Chi-Ji, the Red Crane]?c3[Xuen, the White Tiger][Yu'lon, the Jade Serpent] to assist you for ${$s1/1000} sec.; Triggering a bonus attack with Press the Advantage has a chance to call forth Niuzao, the Black Ox.
    celestial_brew                      = { 101067, 322507, 1 }, -- A swig of strong brew that coalesces purified chi escaping your body into a celestial guard, absorbing $<absorb> damage.; Purifying Stagger damage increases absorption by up to $322510s1%.
    celestial_flames                    = { 101070, 325177, 1 }, -- Drinking from Brews has a $h% chance to coat the Monk with Celestial Flames for $325190d.; While Celestial Flames is active, Spinning Crane Kick applies Breath of Fire and Breath of Fire reduces the damage affected enemies deal to you by an additional $s2%.; 
    charred_passions                    = { 101187, 386965, 1 }, -- Your Breath of Fire ignites your right leg in flame for $386963d, causing your Blackout Kick and Spinning Crane Kick to deal $s1% additional damage as Fire damage and refresh the duration of your Breath of Fire on the target.
    chi_burst                           = { 102433, 123986, 1 }, -- Hurls a torrent of Chi energy up to $460485s1 yds forward, dealing $148135s1 Nature damage to all enemies, and $130654s1 healing to the Monk and all allies in its path. Healing and damage reduced beyond $s1 targets.; $?c1[; Casting Chi Burst does not prevent avoiding attacks.][]
    chi_surge                           = { 101712, 393400, 1 }, -- Triggering a bonus attack from Press the Advantage or casting Weapons of Order releases a surge of chi at your target's location, dealing Nature damage split evenly between all targets over $393786d.; $@spellicon418359 $@spellname418359:; Deals $<ptadmg> Nature damage.; $@spellicon387184 $@spellname387184:; Deals $<dmg> Nature damage and reduces the cooldown of Weapons of Order by $s1 for each affected enemy, to a maximum of ${$s1*5} sec.
    chi_wave                            = { 102433, 450391, 1 }, -- Every $t1 sec, your next Rising Sun Kick or Vivify releases a wave of Chi energy that flows through friends and foes, dealing $132467s1 Nature damage or $132463s1 healing. Bounces up to $115098s1 times to targets within $132466a2 yards.
    clarity_of_purpose                  = { 101228, 451017, 1 }, -- Casting $?a137023[Purifying Brew][Vivify] stores $<value> vitality, increased based on $?a137023[Stagger level][your recent Gusts of Mist].
    coalescence                         = { 101227, 450529, 1 }, -- When Aspect of Harmony $?a450870[deals damage or heals]?a137023[deals damage][heals], it has a chance to spread to a nearby $?a450870[target]?a137023[enemy][ally]. When you directly $?a450870[attack or heal]?a137023[attack][heal] an affected target, it has a chance to intensify.; Targets damaged or healed by your Aspect of Harmony take $s2% increased damage or healing from you.
    counterstrike                       = { 101080, 383785, 1 }, -- Each time you dodge or an enemy misses you, your next Tiger Palm or Spinning Crane Kick deals $383800s1% increased damage.
    dampen_harm                         = { 101181, 122278, 1 }, -- Reduces all damage you take by $m2% to $m3% for $d, with larger attacks being reduced by more.
    dance_of_the_wind                   = { 101181, 414132, 1 }, -- Your dodge chance is increased by $s1%.
    detox                               = { 101090, 218164, 1 }, -- Removes all Poison and Disease effects from the target.
    dragonfire_brew                     = { 101187, 383994, 1 }, -- After using Breath of Fire, you breathe fire $s1 additional times, each dealing $387621s1 Fire damage.; Breath of Fire damage increased by up to $s2% based on your level of Stagger.
    efficient_training                  = { 101251, 450989, 1 }, -- Energy spenders deal an additional $s1% damage.; Every $s3 Energy spent reduces the cooldown of $?c1[Weapons of Order][Storm, Earth, and Fire] by ${$s4/1000} sec.
    elixir_of_determination             = { 101085, 455139, 1 }, -- When you fall below $s1% health, you gain an absorb for $s2% of your recently Purified damage, or a minimum of $s3% of your maximum health. Cannot occur more than once every $455180d.
    elusive_footwork                    = { 101194, 387046, 1 }, -- Blackout Kick deals an additional $s3% damage. Blackout Kick critical hits grant an additional $m2 $Lstack:stacks; of Elusive Brawler.
    endless_draught                     = { 101225, 450892, 1 }, -- $?a137023[Celestial Brew][Thunder Focus Tea] has $s1 additional charge.
    exploding_keg                       = { 101197, 325153, 1 }, -- Hurls a flaming keg at the target location, dealing $s1 Fire damage to nearby enemies, causing your attacks against them to deal $388867s1 additional Fire damage, and causing their melee attacks to deal $s2% reduced damage for the next $d.
    face_palm                           = { 101079, 389942, 1 }, -- Tiger Palm has a $s1% chance to deal $s2% of normal damage and reduce the remaining cooldown of your Brews by ${$s3/1000} additional sec.
    fluidity_of_motion                  = { 101078, 387230, 1 }, -- Blackout Kick's cooldown is reduced by ${-$s1/1000} sec and its damage is reduced by $s2%.
    flurry_strikes                      = { 101248, 450615, 1 }, -- Every $<value> damage you deal generates a Flurry Charge. For each $s2 energy you spend, unleash all Flurry Charges, dealing $450617s1 Physical damage per charge. 
    fortifying_brew_determination       = { 101068, 322960, 1 }, -- Fortifying Brew increases Stagger effectiveness by $s1% while active.; Combines with other Fortifying Brew effects.
    gai_plins_imperial_brew             = { 102004, 383700, 1 }, -- Purifying Brew instantly heals you for $s1% of the purified Stagger damage.
    gift_of_the_ox                      = { 101072, 124502, 1 }, -- [224863] Summon a Healing Sphere visible only to you. Moving through this Healing Sphere heals you for $124507s1.
    harmonic_gambit                     = { 101224, 450870, 1 }, -- During Aspect of Harmony, $?a137023[Expel Harm and Vivify withdraw vitality to heal][Rising Sun Kick, Blackout Kick, and Tiger Palm also withdraw vitality to damage enemies].
    heightened_guard                    = { 101711, 455081, 1 }, -- Ox Stance will now trigger when an attack is larger than ${$455068s2+$s1}% of your current health.
    high_impact                         = { 101247, 450982, 1 }, -- Enemies who die within $451037d of being damaged by a Flurry Strike explode, dealing $451039s1 physical damage to uncontrolled enemies within $451039a1 yds.
    high_tolerance                      = { 101189, 196737, 2 }, -- Stagger is $s1% more effective at delaying damage.; You gain up to $s4% Haste based on your current level of Stagger.
    hit_scheme                          = { 101071, 383695, 1 }, -- Dealing damage with Blackout Kick increases the damage of your next Keg Smash by $383696s1%, stacking up to $383696u times.
    improved_invoke_niuzao_the_black_ox = { 101073, 322740, 1 }, -- While Niuzao is active, Purifying Brew increases the damage of Niuzao's next Stomp, based on Stagger level.
    invoke_niuzao_the_black_ox          = { 101075, 132578, 1 }, -- Summons an effigy of Niuzao, the Black Ox for $d. Niuzao attacks your primary target, and frequently Stomps, damaging all nearby enemies$?s322740[ for $227291s1 plus $322740s1% of Stagger damage you have recently purified.][.]; While active, $s2% of damage delayed by Stagger is instead Staggered by Niuzao.
    keg_smash                           = { 101088, 121253, 1 }, -- Smash a keg of brew on the target, dealing $s2 Physical damage to all enemies within $A2 yds and reducing their movement speed by $m3% for $d. Deals reduced damage beyond $s7 targets.$?a322120[; Grants Shuffle for $s6 sec and reduces the remaining cooldown on your Brews by $s4 sec.][]
    lead_from_the_front                 = { 101254, 450985, 1 }, -- Chi Burst, Chi Wave, and Expel Harm now heal you for $s1% of damage dealt.
    light_brewing                       = { 101082, 325093, 1 }, -- Reduces the cooldown of Purifying Brew and Celestial Brew by $s1%.
    manifestation                       = { 101222, 450875, 1 }, -- Chi Burst and Chi Wave deal $s1% increased damage and healing.
    mantra_of_purity                    = { 101229, 451036, 1 }, -- $?a137023[Purifying Brew removes $s1% additional Stagger and causes you to absorb up to $<value> incoming Stagger][When cast on yourself, your single-target healing spells heal for $s2% more and restore an additional $451452o1 health over $451452d].
    mantra_of_tenacity                  = { 101229, 451029, 1 }, -- $?a137023[Fortifying Brew applies a Chi Cocoon][Fortifying Brew grants $s1% Stagger].
    martial_precision                   = { 101246, 450990, 1 }, -- Your attacks penetrate $s1% armor.
    one_versus_many                     = { 101250, 450988, 1 }, -- Damage dealt by Fists of Fury and Keg Smash counts as double towards Flurry Charge generation.; Fists of Fury damage increased by $s2%.; Keg Smash damage increased by $s3%.
    one_with_the_wind                   = { 101710, 454484, 1 }, -- You have a $s1% chance to not reset your Elusive Brawler stacks after a successful dodge.
    overwhelming_force                  = { 101220, 451024, 1 }, -- Rising Sun Kick, Blackout Kick, and Tiger Palm deal $s1% additional damage to enemies in a line in front of you. Damage reduced above $s2 targets.
    ox_stance                           = { 101199, 455068, 1 }, -- Casting Purifying Brew grants a charge of Ox Stance, increased based on Stagger level. When you take damage that is greater than $s1% of your current health, a charge is consumed to increase the amount you Stagger.
    path_of_resurgence                  = { 101226, 450912, 1 }, -- $?a450391[Chi Wave][Chi Burst] increases vitality stored by $451084s1% for $451084d.
    predictive_training                 = { 101245, 450992, 1 }, -- When you dodge or parry an attack, reduce all damage taken by $451230s1% for the next $451230d.
    press_the_advantage                 = { 101193, 418359, 1 }, -- Your main hand auto attacks reduce the cooldown on your brews by ${$s2/1000}.1 sec and block your target's chi, dealing $418360s1 additional Nature damage and increasing your damage dealt by $418361s1% for $418361d. ; Upon reaching $418361u stacks, your next cast of Rising Sun Kick or Keg Smash consumes all stacks to strike again at $418361s2% effectiveness. This bonus attack can trigger effects on behalf of Tiger Palm at reduced effectiveness.
    pretense_of_instability             = { 101077, 393516, 1 }, -- Activating Purifying Brew or Celestial Brew grants you $393515s1% dodge for $393515d.
    pride_of_pandaria                   = { 101247, 450979, 1 }, -- Flurry Strikes have $s1% additional chance to critically strike.
    protect_and_serve                   = { 101254, 450984, 1 }, -- Your Vivify always heals you for an additional $s1% of its total value.
    purified_spirit                     = { 101224, 450867, 1 }, -- When Aspect of Harmony ends, any remaining vitality is expelled as $?a137023[damage over $450820d][healing over $450805d], split among nearby targets.
    purifying_brew                      = { 101064, 119582, 1 }, -- Clears $s1% of your damage delayed with Stagger.$?s322510[; Increases the absorption of your next Celestial Brew by up to $322510s1%, based on your current level of Stagger][]$?s383700[; Instantly heals you for $383700s1% of the damage cleared.][]
    quick_sip                           = { 101063, 388505, 1 }, -- Purify $s1% of your Staggered damage each time you gain $s2 sec of Shuffle duration.
    roar_from_the_heavens               = { 101221, 451043, 1 }, -- Tiger's Lust grants $452701s1% movement speed to up to $452701i allies near its target.
    rushing_jade_wind                   = { 101202, 116847, 1 }, -- Summons a whirling tornado around you, causing ${(1+$d/$t1)*$148187s1} Physical damage over $d to all enemies within $107270A1 yards. Deals reduced damage beyond $s1 targets.
    salsalabims_strength                = { 101188, 383697, 1 }, -- When you use Keg Smash, the remaining cooldown on Breath of Fire is reset.
    scalding_brew                       = { 101188, 383698, 1 }, -- Keg Smash deals an additional $s1% damage to targets affected by Breath of Fire.
    shadowboxing_treads                 = { 101078, 387638, 1 }, -- Blackout Kick's damage increased by $s2% and it strikes an additional $s1 $ltarget;targets.
    shuffle                             = { 101087, 322120, 1 }, -- Niuzao's teachings allow you to shuffle during combat, increasing the effectiveness of your Stagger by $215479s3%.; Shuffle is granted by attacking enemies with your Keg Smash, Blackout Kick, and Spinning Crane Kick.
    special_delivery                    = { 101202, 196730, 1 }, -- Drinking from your Brews has a $h% chance to toss a keg high into the air that lands nearby after $s1 sec, dealing $196733s1 damage to all enemies within $196733A1 yards and reducing their movement speed by $196733m2% for $196733d.
    spirit_of_the_ox                    = { 101086, 400629, 1 }, -- [224863] Summon a Healing Sphere visible only to you. Moving through this Healing Sphere heals you for $124507s1.
    staggering_strikes                  = { 101065, 387625, 1 }, -- When you Blackout Kick, your Stagger is reduced by $<reduc>.
    stormstouts_last_keg                = { 101196, 383707, 1 }, -- Keg Smash deals $m1% additional damage, and has $m2 additional $?m2>1[charge][charges].
    strike_at_dawn                      = { 101076, 455043, 1 }, -- Rising Sun Kick grants a stack of Elusive Brawler.
    summon_black_ox_statue              = { 101172, 115315, 1 }, -- Summons a Black Ox Statue at the target location for $d, pulsing threat to all enemies within $163178A1 yards.; You may cast Provoke on the statue to taunt all enemies near the statue.
    tigers_vigor                        = { 101221, 451041, 1 }, -- Casting Tiger's Lust reduces the remaining cooldown on Roll by ${$s1/1000} sec.
    training_of_niuzao                  = { 101082, 383714, 1 }, -- Gain up to ${$s1*$s3}% Mastery based on your current level of Stagger.
    tranquil_spirit                     = { 101083, 393357, 1 }, -- When you consume a Healing Sphere or cast Expel Harm, your current Stagger amount is lowered by $s1%.
    veterans_eye                        = { 101249, 450987, 1 }, -- Striking the same target $451071u times within $451071d grants $451085s1% Haste.; Multiple instances of this effect may overlap, stacking up to $451085u times.
    vigilant_watch                      = { 101244, 450993, 1 }, -- Blackout Kick deals an additional $s1% critical damage and increases the damage of your next set of Flurry Strikes by $451233s1%.
    walk_with_the_ox                    = { 101074, 387219, 2 }, -- Abilities that grant Shuffle reduce the cooldown on Invoke Niuzao, the Black Ox by ${$s2/-1000}.2 sec, and Niuzao's Stomp deals an additional $s1% damage. 
    way_of_a_thousand_strikes           = { 101226, 450965, 1 }, -- Rising Sun Kick, Blackout Kick, and Tiger Palm contribute $s1% additional vitality.
    weapons_of_order                    = { 101193, 387184, 1 }, -- For the next $d, your Mastery is increased by $?c1[${$117906bc1*$s1}]?c2[${$117907bc1*$s1}][${$115636bc1*$s1}.1]%. Additionally, $?a137025[Rising Sun Kick reduces Chi costs by $311054s1 for $311054d, and Blackout Kick reduces the cooldown of affected abilities by an additional ${$s8/1000} sec.][]$?a137023 [Keg Smash cooldown is reset instantly and enemies hit by Keg Smash or Rising Sun Kick take $312106s1% increased damage from you for $312106d, stacking up to $312106u times.][]$?a137024[Essence Font cooldown is reset instantly and heals up to $311123s2 nearby allies for $311123s1 health on channel start and end.][]
    whirling_steel                      = { 101245, 450991, 1 }, -- When your health drops below $s1%, summon Whirling Steel, increasing your parry chance and avoidance by $451214s1% for $451214d.; This effect can not occur more than once every $proccooldown sec.
    wisdom_of_the_wall                  = { 101252, 450994, 1 }, -- [452684] Critical strike damage increased by $s1%.
    zen_meditation                      = { 101201, 115176, 1 }, -- Reduces all damage taken by $s2% for $d. Being hit by a melee attack, or taking another action$?s328682[ other than movement][] will cancel this effect.
} )


-- PvP Talents
spec:RegisterPvpTalents( {
    admonishment       = 843 , -- (207025) You focus the assault on this target, increasing their damage taken by 3% for 6 sec. Each unique player that attacks the target increases the damage taken by an additional 3%, stacking up to 5 times. Your melee attacks refresh the duration of Focused Assault.
    alpha_tiger        = 5552, -- (287503) Attacking new challengers with Tiger Palm fills you with the spirit of Xuen, granting you 20% haste for 8 sec. This effect cannot occur more than once every 30 sec per target.
    avert_harm         = 669 , -- (202162) Guard the 4 closest players within 15 yards for 15 sec, allowing you to Stagger 20% of damage they take.
    dematerialize      = 5541, -- (353361)
    double_barrel      = 672 , -- (202335) Your next Keg Smash deals 50% additional damage, and stuns all targets it hits for 3 sec.
    eerie_fermentation = 765 , -- (205147) You gain up to 30% movement speed and 15% magical damage reduction based on your current level of Stagger.
    grapple_weapon     = 5538, -- (233759) You fire off a rope spear, grappling the target's weapons and shield, returning them to you for 5 sec.
    guided_meditation  = 668 , -- (202200) The cooldown of Zen Meditation is reduced by 50%. While Zen Meditation is active, all harmful spells cast against your allies within 40 yards are redirected to you. Zen Meditation is no longer cancelled when being struck by a melee attack.
    hot_trub           = 667 , -- (410346) Purifying Brew deals 20% of cleared damage split among nearby enemies. After clearing 100% of your maximum health in Stagger damage, your next Breath of Fire incapacitates targets for 4 sec.
    microbrew          = 666 , -- (202107) Reduces the cooldown of Fortifying Brew by 50%.
    mighty_ox_kick     = 673 , -- (202370) You perform a Mighty Ox Kick, hurling your enemy a distance behind you.
    nimble_brew        = 670 , -- (354540) Douse allies in the targeted area with Nimble Brew, preventing the next full loss of control effect within 8 sec.
    niuzaos_essence    = 1958, -- (232876) Drinking a Purifying Brew will dispel all snares affecting you.
    rodeo              = 5417, -- (355917) Every 3 sec while Clash is off cooldown, your next Clash can be reactivated immediately to wildly Clash an additional enemy. This effect can stack up to 3 times.
} )


-- Auras
spec:RegisterAuras( {
    admonishment = {
        id = 207025,
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
    exploding_keg = {
        id = 325153,
        duration = 3,
        max_stack = 1,
    },
    -- Talent: $?$w1>0[Healing $w1 every $t1 sec.][Suffering $w2 Nature damage every $t2 sec.]
    -- https://wowhead.com/beta/spell=196608
    eye_of_the_tiger = {
        id = 196608,
        duration = 8,
        max_stack = 1
    },
    -- Fighting on a faeline has a $s2% chance of resetting the cooldown of Faeline Stomp.
    -- https://wowhead.com/beta/spell=388193
    faeline_stomp = {
        id = 388193,
        duration = 30,
        max_stack = 1,
        copy = "jadefire_stomp"
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
    graceful_exit = {
        id = 387254,
        duration = 3,
        max_stack = 3
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
        charges = function() return talent.improved_roll.enabled and 3 or 2 end,
        cooldown = 20,
        recharge = 20,
        gcd = "off",
        school = "physical",

        talent = "chi_torpedo",
        startsCombat = true,

        handler = function ()
            addStack( "chi_torpedo" )
            setDistance( 5 )
        end,
    },

    -- Talent: You and the target charge each other, meeting halfway then rooting all targets within 6 yards for 4 sec.
    clash = {
        id = 324312,
        cast = 0,
        cooldown = 30,
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

        spend = 20,
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

    -- Talent: Drink a healing elixir, healing you for 15% of your maximum health.
    healing_elixir = {
        id = 122281,
        cast = 0,
        charges = 2,
        cooldown = 30,
        recharge = 30,
        gcd = "off",
        school = "nature",

        talent = "healing_elixir",
        startsCombat = false,
        toggle = "defensives",

        handler = function ()
            gain( 0.15 * health.max, "health" )
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

        spend = 40,
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

            removeBuff( "blackout_combo" )
            addStack( "elusive_brawler" )
        end,
    },

    -- Knocks down all enemies within 6 yards, stunning them for 3 sec.
    leg_sweep = {
        id = 119381,
        cast = 0,
        cooldown = function () return talent.tiger_tail_sweep.enabled and 50 or 60 end,
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
        cooldown = function() return talent.improved_paralysis.enabled and 30 or 45 end,
        gcd = "spell",
        school = "physical",

        spend = 20,
        spendType = "energy",

        talent = "paralysis",
        startsCombat = true,

        handler = function ()
            applyDebuff( "target", "paralysis" )
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
        charges = function () return 2 end,
        cooldown = function () return ( talent.light_brewing.enabled and 12 or 15 ) * haste end,
        recharge = function () return ( talent.light_brewing.enabled and 12 or 15 ) * haste end,
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
        cooldown = 45,
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

            if buff.press_the_advantage.stack == 10 then
                removeBuff( "press_the_advantage" )
            end

            if set_bonus.tier30_4pc > 0 then addStack( "elusive_brawler" ) end
        end,
    },

    -- Roll a short distance.
    roll = {
        id = 109132,
        cast = 0,
        charges = function() return talent.improved_roll.enabled and 3 or 2 end,
        cooldown = function () return talent.celerity.enabled and 15 or 20 end,
        recharge = function () return talent.celerity.enabled and 15 or 20 end,
        gcd = "off",
        school = "physical",

        startsCombat = false,
        notalent = "chi_torpedo",

        handler = function ()
            setDistance( 5 )
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

        handler = function ()
            removeBuff( "blackout_combo" )
            removeBuff( "counterstrike" )

            reduceCooldown( "celestial_brew", 1 )
            reduceCooldown( "fortifying_brew", 1 )
            gainChargeTime( "purifying_brew", 1 )

            if talent.eye_of_the_tiger.enabled then
                applyDebuff( "target", "eye_of_the_tiger" )
                applyBuff( "eye_of_the_tiger" )
            end

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
        cast = 1.3,
        cooldown = 0.0,
        gcd = "global",

        spend = 30,
        spendType = 'energy',

        startsCombat = false,
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
        cooldown = function() return talent.fundamental_observation.enabled and 225 or 300 end,
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


spec:RegisterPack( "Brewmaster", 20240508, [[Hekili:TV1xZPnss8plU26iGtqwcmXjBbu16S3dj7DBsDoxTVHqinaAniPt)XyFLl9z)6Eg9NzgPrsyij7d3lyqZm90Dp909VUv7fgl(6I7CSIjl(9r6JUwFI(70mgn(6jJxCx8tbKf3fyzFV1g4lEw7HpVnKCyVvumjeh6PD(woijI8tcTHH3ghhe9ZxD1g34TjR0S93FvK7(KDwXU(E2HwRJXFBF1I7wL4Ul(JElwv)(V4oRK4T(WUCN7(pae21XHWMnjYEXD4ShQpzO(7(50L4usxMeGeksl9tPFIn84HgJGHtx(Vi79FGKUK8yCOv6YVKe6U(jxVnPlr5bEUxCOB5sH1zm0ymDPaTRqA6463qh)lwX2BtxAORnQM5PFZWrmw4F665hwmJ0LRd93Z4CHzB8Ey2)IJdm0h(T0LX(WoesIGfeVLGJ8GLxmCEKUmi01p0n(jy5dtx(VJGhD7VEB6Y9(HWx9xht8sx6U(QdBXV8h(Fg(fqg)KyC00Lrp5zlU1t(5snvfvu8wlyHREkWkkc5F)a8ivuunee1V(fqkDFe(a)LNV3WV81FjDPLNd7x3(zjr3qsHAOnjxHjmrD22qf5)(Jb78DO85VrGpoagEur8wFpItsuCo)7Uot)4g59k4PXw7GtDIdhLNmC01ukFlXY237kQoZAN7gV9WurMoD5oFVneuCiehPft1FPl)SFq0BsxgsC3hSJWw5ARD7wbxKGh7htVliSsQrC2jov9Wya2Xp9C)wYt(4a2BTG9NxRpA4O3sxny0qGz8v)eu9HNW)kXkg(kBJlivUDt6Y(wbbeRWi2GRGX27gfr1LLwNdO71xXvYUMv6bGNwjuJIkwnuP5dKDKOyxRDfpDZg0M29bYUNYmp(1VCNgkf0nYYXbL(TwajdScrXkElA8wkkrjbb(HX4xcFW9bRvU7W7clUBNBuCe6skiKaUFwzfd)43P(5SSrnpmIp7VepRv7iolUDrm4(bNr5tUZgKlsORf4hKAPOzV11CvsyuSw(SkiyXqiHg3fcDW6bs90bhbjZ1TrMOK9799mpSfEUzSlyvAgb2wj1qxLtDbYXGh11wj7QQNIqRdtWIZbMEO79K6uz5t2XD9AWiWCV1gxBPjQwLerIJbZLiTaQLJjylyAxAU0dmsHZB39aB7dK(rt4cq4g0uBA6Yn2oAWZsx(8ZGPrY61mQ4sCGP5QLeqjq1bcj7TC9y0G6J5soAnGroBF)Do(h80k4gZvGTRWAhjUYE0RNi3zUoKPwqzyoDt4S(YVJqjyBh1E3tVnXuexK72sd8Tec(PDmLyVmQ0KkzqPwz1o4(e4T0eVO4RHYlNXOaLr(CIeFQqIQAQwWTUEp4FpX0Zn5)A5BcUJmPSGP)JLCoWC1zvWwdD4asSwDKa5h4Yd4cWJyAd2)tqU(TDKRrCfHUbSbPXwaxWRD3Kq9)KXjW1Mn41h7KWWTb5(j5DjMhxKxnSj0N3ySg1ETIT8Mbws6SjYgqlWgCaoFwBRe1c38Jxle5VZ)hNsGExvxJAs8UVfkdWhq31fNOfr2ED86c6crvW7)HRconZHttdWBmyO)suf3Xix6Y)gdR1iDe75oWF)90pFYpbGAcYWimateafXZjIdE6wcaSe9SJGFk2jTmCTGQLbBxHPmfwvMKyHW9DCJO8)50ilFZMvOJBwLoR(Zcu3q1ZgNd9SHk98pmT8PzhF2uYgmLSAySOUiElB(a4LBMqjJRhWOOU3XcqUrmhhrPw2KP4AUKI9GMF7Rl)kI8HzFnqatbeRoM74ucubSlbepatz4Ek7QgzOe7or)SZU9Z4yoEk78AqjdljouM(6wtMWyc)uIXuYm9xB6GjKjpvz8jLQahcL)oqScaNNib8dDatHSNdway2qG4pMH3ldTL88Laf6JftOhMA(MTXMc4z5qPIq5b(yFeLhVHxCwTZ33XCDs4tYIY7eMgjmIeIWxLN275N2oKnIm)ZeNnyUYYPyOZp31UHe6UlplH0wS8SbGRHaWvBiTB5PkK0YkRnOAcsUX((i5z2AICbysSuiOw5LLPm3lmJjBuA5qudSJj7hMyAQSKvnzfwlVWaMbXw0TxDwbLPb8THdw5BZsmu4jYzhw4P7Eq51sY05Rr20uYzpBArA877RNDLyaI34UEwFv(A7Xgbs9hupMz5(erh65NlYPtKGAvZABEFJxlN7I0IYKUH6AgdgmO3XNPtV(f8tLBSz3kNFTohxRAwtNmG36i3TMSoOm3VJNxBoj(8DSb6uehujRLpMkPKLT(1NGmuyfQEUnNnoiNhJlzgJwto7NpEvoJCbE9Ioeryqx3j1rP63LT5COkQ48OM0AvGFGpFaYwZasOnnwtoPjpgq2vGkro9qrz1DpGeCiGiKU2Qc9oiNhZek6swnI40X3t2ygbjfTTUuWQEHQX7cf1D6s6UO8(t59(tu)lW8vYA604(t)sTi3jNRXlmmZf1fNjjyqVlofwn0flYUzuIhl2zZ427JVEks4MNO4zzFfuLBWexqd7R1fmXY32s4QT74UIaspnqk(aXe2X9UyfxH9YqyRyvsoWA3(syXnUpyG2qmuQvue7eGZIOioNaWIYPWlJHiqA0Wcrewc4(4mhZeZU5sh10JvFxUbu8hBuJYDOPY2NHj)m57V5DQd(dNYYmVZQZIiKykjfuzEbvogMFv2B6R0IVrpRhPQPc1h1UNpH1WCaleRH9glnblOYSxurWYRfceT4AbwRRr6TSdn6DPuHiUf1PnQs6X85euENqkFGwFBwHjrBrY(NwoeZdUEo142uEkuklKPTKJbjMq9D06D1jeYuYhzfUt0z4i13oL3l0ON7MyGRNhkL2HwEKI4dJesTMdUIKikKADXRtuCsJ1LNe7DxkmRyPmsLZ(Rb0InNkyPIGEvPUmyZD5s9mCdnShAStFtKAJ2kyqwtSu1X7ABhHJI3xBOVmV)CfnQMqMORS2SxAJ3BpgARS)GALa0HRIyxQdDwdrMuI0uWxGqoCvIZNe0Qf(BfUh3qTfu9MSeb(0cIpWK(4q8XRwAbowZPqC6aHoZwHvbtj4ern0aXJfdbVkIrnLMP64DNqsBnJGUHiZfyq6CK2MJi2mE7tkyBhGy)TXIOb41T5uIImuHNNgqnFIWcAaDCno1g1Q3PMXaBOzqPd81Od4lyA)wU8wYFLegupgrGrlA1gftOJnKBnXh8Pb5eXMRGJEF3qeujyFniceRFUsebWdEGeIoSY6wZXWLU7oyfISx0I7O9UfKrmTVSOD11RYATOxH9d3)jXL(sJJ8rS(wjX(7TIjcn12)W1dgcBcVp47b7fD4x1CpV8kwdH1YSYTBGz334Xbf71Kw2l14CuTVTxjazEW4T1ZeY5NiTJQsFPK8PF6J0tdKOxNxXQ0L0wKdgg7ro)1U7iLbilAAom6i9nBL(P6gRWgbdAMXpvAqo1lfTbLwjFhXv)cvgjIJsT2uCOsjJ4ijL7Wn(bf6On(bQcBOX2yRx)AAGTPzfa75NzoqzLcpVlT6v9H5f73qBYLzRDa3lhO(2uB6O852RMxYb27BCILijykvA7N1RFLYDjo36fIb9QlIe9nbOwzM17wZMWDO2HRw9u3Yy9AUDXs)0pL1kXNuJo1S9b9vpRuDuH5f325694Ez)ZRySjXKFpKhSNh((ioxQJgPDqKAT3J(MCcr31Ukrmw87GW8YoEoEzP4W5VQDd13KZC22otVzf5mrfjOrQtr9xJ2z6BH10lslbQd(aWLnMdYhLjho9Mj9Q2jqZl7cOl7RRn614hxspKhKflQUMtIFhLgxAxNOF07kRDeK7WObck8myw)0pL7yyQfCuhswp7v5)7uD4WbTd(WPRLd7)PkmjIzg66Vvhw)bs4qxpaRcqNxn)l4Vtx(XShm9kR55ggDLWJF3ngV76RYayo0F9qg(Z5)b7jmB3pJpJrEiHr7TyYuxtBmn77rpuO8ukMzXUjpc(X8qCdGI5nyJNmJkaM5caQZR9niuGPz2i9ETvb)tyZVOvAxsxXo7IFKI(NcjzxENiZh)8Zk2zaELFuupHg2A6ibSBL9KLWtlAbl(Nk1Xvc2)5nyf)df7Nkb6Z3(ucqjL6ZiMUMV6BVH1DsZm4W51q3mDeeFLVTaXVOluVmJdPseQgYPYLivw3cdALfjzA)BEnFbUhC(i9833JbZnVEhtNnUxTDpvsWZpFrJ1isnBvuuNYEZQboAGelnFSscxtTpWTqA9t6vB9O7PQw0k3oHcUsJxRyIvdsQSWXnVz51RgjbRwYVMVKYtNDTUAciuMUcBbv1wEAZ1v(8BvOmxC1seFjrvoRYADjfFEwnLlUjQuATqpb7xBfIHKS73CLHNdbKgOwnuDJUOPka3GbtLZ7Z(rMWf5wCAzO2YSsjz5CYRSIUNOtGrh767BOzmVVC9AhCzFJxZvJ2bdRuD2gpQZSmvoL8sD14eOvrR2GsSovQd(P()DoB36CwL6y51uQ8Q29QVeHq5gREPLSqlDABpf8zVMbwBC93tbPBGIFrTA3lLLAd6)rAT0g1oRI2PgvKrfrKCyDRhYMzd9560rQ1l1GmuP53gBNlhPWe9f2ZLNp(6LDZ4O8mFoB2uLcUugenhIHhDAFfWtvF2x2runGvrkxGzgQPNk8pVqaVNMrlW5DXbgKUL69PXxOvx9p(cP(l3vNaQ1c3eaCWoPqaogauJRyUrRLX5yyIxUavfGE9jcCeeOdjmCeu7OZxqYmwTZGZeo96UF2r3cYx)71CQlQT27uscgDi8PYP0a09YjK14eqge2yhN(oABtS4)b]] )