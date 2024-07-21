-- MonkWindwalker.lua
-- July 2024

local addon, ns = ...
local Hekili = _G[ addon ]
local class, state = Hekili.Class, Hekili.State

local spec = Hekili:NewSpecialization( 269 )

-- Resources
spec:RegisterResource( Enum.PowerType.Energy )
spec:RegisterResource( Enum.PowerType.Mana )
spec:RegisterResource( Enum.PowerType.Chi )

spec:RegisterTalents( {
    -- Monk Talents
    ancient_arts                   = { 101184, 344359, 2 }, -- Reduces the cooldown of Paralysis by ${$abs($s0/1000)} sec and the cooldown of Leg Sweep by ${$s2/-1000} sec.
    bounce_back                    = { 101177, 389577, 1 }, -- When a hit deals more than $m2% of your maximum health, reduce all damage you take by $s1% for $390239d.; This effect cannot occur more than once every $m3 seconds.
    bounding_agility               = { 101161, 450520, 1 }, -- Roll and Chi Torpedo travel a small distance further.
    calming_presence               = { 101153, 388664, 1 }, -- Reduces all damage taken by $s1%.
    celerity                       = { 101183, 115173, 1 }, -- Reduces the cooldown of Roll by ${$m1/-1000} sec and increases its maximum number of charges by $m2.
    celestial_determination        = { 101180, 450638, 1 }, -- While your Celestial is active, you cannot be slowed below $s2% normal movement speed.
    chi_proficiency                = { 101169, 450426, 2 }, -- Magical damage done increased by $s1% and healing done increased by $s2%.
    chi_torpedo                    = { 101183, 115008, 1 }, -- Torpedoes you forward a long distance and increases your movement speed by $119085m1% for $119085d, stacking up to 2 times.
    clash                          = { 101154, 324312, 1 }, -- You and the target charge each other, meeting halfway then rooting all targets within $128846A1 yards for $128846d.
    crashing_momentum              = { 101149, 450335, 1 }, -- Targets you Roll through are snared by $450342s1% for $450342d.
    diffuse_magic                  = { 101165, 122783, 1 }, -- Reduces magic damage you take by $m1% for $d, and transfers all currently active harmful magical effects on you back to their original caster if possible.
    disable                        = { 101149, 116095, 1 }, -- Reduces the target's movement speed by $s1% for $d, duration refreshed by your melee attacks.$?s343731[ Targets already snared will be rooted for $116706d instead.][]
    elusive_mists                  = { 101144, 388681, 1 }, -- Reduces all damage taken by you and your target while channeling Soothing Mists by $s1%.
    energy_transfer                = { 101151, 450631, 1 }, -- Successfully interrupting an enemy reduces the cooldown of Paralysis and Roll by ${$s1/-1000} sec.
    escape_from_reality            = { 101176, 394110, 1 }, -- After you use Transcendence: Transfer, you can use Transcendence: Transfer again within $343249d, ignoring its cooldown.
    expeditious_fortification      = { 101174, 388813, 1 }, -- Fortifying Brew cooldown reduced by ${$s1/-1000} sec.
    fast_feet                      = { 101185, 388809, 1 }, -- Rising Sun Kick deals $s1% increased damage. Spinning Crane Kick deals $s2% additional damage.; 
    fatal_touch                    = { 101178, 394123, 1 }, -- Touch of Death increases your damage by $450832s1% for $450832d after being cast and its cooldown is reduced by ${$s1/-1000} sec.
    ferocity_of_xuen               = { 101166, 388674, 1 }, -- Increases all damage dealt by $s1%.
    flow_of_chi                    = { 101170, 450569, 1 }, -- You gain a bonus effect based on your current health.; Above $s1% health: Movement speed increased by $450574s1%. This bonus stacks with similar effects.; Between $s1% and $s2% health: Damage taken reduced by $450572s1%.; Below $s2% health: Healing received increased by $450571s1%. 
    fortifying_brew                = { 101173, 115203, 1 }, -- Turns your skin to stone for $120954d, increasing your current and maximum health by $<health>% and reducing all damage you take by $<damage>%.; Combines with other Fortifying Brew effects.
    grace_of_the_crane             = { 101146, 388811, 1 }, -- Increases all healing taken by $s1%.
    hasty_provocation              = { 101158, 328670, 1 }, -- Provoked targets move towards you at $s1% increased speed.
    healing_winds                  = { 101171, 450560, 1 }, -- Transcendence: Transfer immediately heals you for $450559s1% of your maximum health.
    improved_touch_of_death        = { 101140, 322113, 1 }, -- Touch of Death can now be used on targets with less than $s1% health remaining, dealing $s2% of your maximum health in damage.
    ironshell_brew                 = { 101174, 388814, 1 }, -- Increases your maximum health by an additional $s1% and your damage taken is reduced by an additional $s2% while Fortifying Brew is active.
    jade_walk                      = { 101160, 450553, 1 }, -- While out of combat, your movement speed is increased by $450552s1%.
    lighter_than_air               = { 101168, 449582, 1 }, -- Roll causes you to become lighter than air, allowing you to double jump to dash forward a short distance once within $449609d, but the cooldown of Roll is increased by ${$s1/1000} sec.
    martial_instincts              = { 101179, 450427, 2 }, -- Increases your Physical damage done by $s1% and Avoidance increased by $s2%.
    paralysis                      = { 101142, 115078, 1 }, -- Incapacitates the target for $d. Limit 1. Damage will cancel the effect.
    peace_and_prosperity           = { 101163, 450448, 1 }, -- Reduces the cooldown of Ring of Peace by ${$s1/-1000} sec and Song of Chi-Ji's cast time is reduced by ${$s2/-1000}.1 sec.
    pressure_points                = { 101141, 450432, 1 }, -- Paralysis now removes all Enrage effects from its target.
    profound_rebuttal              = { 101135, 392910, 1 }, -- Expel Harm's critical healing is increased by $s1%.
    quick_footed                   = { 101158, 450503, 1 }, -- The duration of snare effects on you is reduced by $s1%.
    ring_of_peace                  = { 101136, 116844, 1 }, -- Form a Ring of Peace at the target location for $d. Enemies that enter will be ejected from the Ring.
    rising_sun_kick                = { 101186, 107428, 1 }, -- Kick upwards, dealing $?s137025[${$185099s1*$<CAP>/$AP}][$185099s1] Physical damage$?s128595[, and reducing the effectiveness of healing on the target for $115804d][].$?a388847[; Applies Renewing Mist for $388847s1 seconds to an ally within $388847r yds][]
    rushing_reflexes               = { 101154, 450154, 1 }, -- Your heightened reflexes allow you to react swiftly to the presence of enemies, causing you to quickly lunge to the nearest enemy in front of you within $450156r yards after you Roll.
    save_them_all                  = { 101157, 389579, 1 }, -- When your healing spells heal an ally whose health is below $s3% maximum health, you gain an additional $s1% healing for the next $390105d.
    song_of_chiji                  = { 101136, 198898, 1 }, -- Conjures a cloud of hypnotic mist that slowly travels forward. Enemies touched by the mist fall asleep, Disoriented for $198909d.
    soothing_mist                  = { 101143, 115175, 1 }, -- Heals the target for $o1 over $d. While channeling, Enveloping Mist$?s227344[, Surging Mist,][]$?s124081[, Zen Pulse,][] and Vivify may be cast instantly on the target.$?s117907[; Each heal has a chance to cause a Gust of Mists on the target.][]$?s388477[; Soothing Mist heals a second injured ally within $388478A2 yds for $388477s1% of the amount healed.][]
    spear_hand_strike              = { 101152, 116705, 1 }, -- Jabs the target in the throat, interrupting spellcasting and preventing any spell from that school of magic from being cast for $d.
    spirits_essence                = { 101138, 450595, 1 }, -- Transcendence: Transfer snares targets within $450596A2 yds by $450596s1% for $450596d when cast.
    strength_of_spirit             = { 101135, 387276, 1 }, -- Expel Harm's healing is increased by up to $s1%, based on your missing health.
    swift_art                      = { 101155, 450622, 1 }, -- Roll removes a snare effect once every $proccooldown sec.
    tiger_tail_sweep               = { 101182, 264348, 1 }, -- Increases the range of Leg Sweep by $s1 yds.
    tigers_lust                    = { 101147, 116841, 1 }, -- Increases a friendly target's movement speed by $s1% for $d and removes all roots and snares.
    transcendence                  = { 101167, 101643, 1 }, -- Split your body and spirit, leaving your spirit behind for $d. Use Transcendence: Transfer to swap locations with your spirit.
    transcendence_linked_spirits   = { 101176, 434774, 1 }, -- Transcendence now tethers your spirit onto an ally for $434763d. Use Transcendence: Transfer to teleport to your ally's location.
    vigorous_expulsion             = { 101156, 392900, 1 }, -- Expel Harm's healing increased by $s1% and critical strike chance increased by $s2%. 
    vivacious_vivification         = { 101145, 388812, 1 }, -- Every $t1 sec, your next Vivify becomes instant and its healing is increased by $392883s2%.$?c1[; This effect also reduces the energy cost of Vivify by $392883s3%.]?c3[; This effect also reduces the energy cost of Vivify by $392883s3%.][]; 
    winds_reach                    = { 101148, 450514, 1 }, -- The range of Disable is increased by $s1 yds.;  ; The duration of Crashing Momentum is increased by ${$s3/1000} sec and its snare now reduces movement speed by an additional $s2%.
    windwalking                    = { 101175, 157411, 1 }, -- You and your allies within $m2 yards have $s1% increased movement speed. Stacks with other similar effects.
    yulons_grace                   = { 101165, 414131, 1 }, -- Find resilience in the flow of chi in battle, gaining a magic absorb shield for ${$s1/10}.1% of your max health every $t sec in combat, stacking up to $s2%.

    -- Windwalker Talents
    acclamation                    = { 101036, 451432, 1 }, -- Rising Sun Kick increases the damage your target receives from you by $451433s1% for $451433d. Multiple instances may overlap.
    against_all_odds               = { 101253, 450986, 1 }, -- Flurry Strikes increase your Agility by $451061s1% for $451061d, stacking up to $451061u times.
    ascension                      = { 101037, 115396, 1 }, -- Increases your maximum Chi by $s1, maximum Energy by $s3, and your Energy regeneration by $s2%.
    august_dynasty                 = { 101235, 442818, 1 }, -- Casting Jadefire Stomp increases the $?c2[damage or healing of your next Rising Sun Kick by $442850s1% or Vivify by $442850s2%]?c3[damage of your next Rising Sun Kick by $442850s1%][].; This effect can only activate once every $proccooldown sec.
    brawlers_intensity             = { 101038, 451485, 1 }, -- The cooldown of Rising Sun Kick is reduced by ${$s1/-1000}.1 sec and the damage of Blackout Kick is increased by $s2%.
    celestial_conduit              = { 101243, 443028, 1 }, -- $?c2[The August Celestials empower you, causing you to radiate ${$443039s1*$s7} healing onto up to $s3 injured allies and ${$443038s1*$s7} Nature damage onto enemies within $s6 yds over $d, split evenly among them. Healing and damage increased by $s1% per target, up to ${$s1*$s3}%.]?c3[The August Celestials empower you, causing you to radiate ${$443038s1*$s7} Nature damage onto enemies and ${$443039s1*$s7} healing onto up to $s3 injured allies within $443038A2 yds over $d, split evenly among them. Healing and damage increased by $s1% per enemy struck, up to ${$s1*$s3}%.][]; You may move while channeling, but casting other healing or damaging spells cancels this effect.; 
    chi_burst                      = { 101159, 460485, 1 }, -- Your damaging spells and abilities have a chance to activate Chi Burst, allowing you to hurl a torrent of Chi energy up to $s1 yds forward, dealing $148135s1 Nature damage to all enemies, and $130654s1 healing to the Monk and all allies in its path. Healing and damage reduced beyond $123986s1 targets.; $?c1[; Casting Chi Burst does not prevent avoiding attacks.][]
    chi_wave                       = { 101159, 450391, 1 }, -- Every $t1 sec, your next Rising Sun Kick or Vivify releases a wave of Chi energy that flows through friends and foes, dealing $132467s1 Nature damage or $132463s1 healing. Bounces up to $115098s1 times to targets within $132466a2 yards.
    chijis_swiftness               = { 101240, 443566, 1 }, -- Your movement speed is increased by $s1% during Celestial Conduit and by $443569s1% for $443569d after being assisted by any Celestial.; 
    combat_wisdom                  = { 101217, 121817, 1 }, -- [451968] Expel negative chi from your body, healing for $s1 and dealing $s2% of the amount healed as Nature damage to an enemy within $115129A1 yards.$?s322102[; Draws in the positive chi of all your Healing Spheres to increase the healing of Expel Harm.][]$?s342928[; Generates ${$s3+$342928s2} Chi.][]
    communion_with_wind            = { 101041, 451576, 1 }, -- Strike of the Windlord's cooldown is reduced by ${$s1/-1000} sec and its damage is increased by $s2%.
    courage_of_the_white_tiger     = { 101242, 443087, 1 }, -- $?c2[Tiger Palm and Vivify have a chance to cause Xuen to claw a nearby enemy for $457917s1 Physical damage, healing a nearby ally for $s2% of the damage done.]?c3[Tiger Palm has a chance to cause Xuen to claw your target for $457917s1 Physical damage, healing a nearby ally for $s2% of the damage done.][Xuen claws your target for $457917s1 Physical damage, healing a nearby ally for $s2% of the damage done.]; $?c2[Invoke Yu'lon, the Jade Serpent or Invoke Chi-Ji, the Red Crane]?c3[Invoke Xuen, the White Tiger][Invoking a celestial] guarantees your next cast activates this effect.
    courageous_impulse             = { 101061, 451495, 1 }, -- The Blackout Kick! effect also increases the damage of your next Blackout Kick by $s1%.
    crane_vortex                   = { 101055, 388848, 1 }, -- Spinning Crane Kick damage increased by $s1% and its radius is increased by $s2%.
    dance_of_chiji                 = { 101060, 325201, 1 }, -- Spending Chi has a chance to make your next Spinning Crane Kick free and deal an additional $s1% damage.
    dance_of_the_wind              = { 101137, 432181, 1 }, -- Your dodge chance is increased by $s2% and an additional $432180s1% every $t1 sec until you dodge an attack, stacking up to $432180u times. 
    darting_hurricane              = { 102250, 459839, 1 }, -- After you cast Strike of the Windlord, the global cooldown of your next $s2 Tiger Palms is reduced by $459841s1%.; Your damaging spells and abilities have a chance to grant $s1 stack of Darting Hurricane.
    detox                          = { 101150, 218164, 1 }, -- Removes all Poison and Disease effects from the target.
    drinking_horn_cover            = { 101052, 391370, 1 }, -- The duration of $?s152173[Serenity][Storm, Earth, and Fire] is extended by $?s152173[${$s2/100}.2 sec every time you cast a Chi spender][${$s1/100}.2 sec for every Chi you spend].
    dual_threat                    = { 101213, 451823, 1 }, -- Your auto attacks have a $s1% chance to instead kick your target dealing $451839s1 Physical damage and increasing your damage dealt by $451833s1% for $451833d.
    efficient_training             = { 101251, 450989, 1 }, -- Energy spenders deal an additional $s1% damage.; Every $s3 Energy spent reduces the cooldown of $?c1[Weapons of Order][Storm, Earth, and Fire] by ${$s4/1000} sec.
    energy_burst                   = { 101056, 451498, 1 }, -- When you consume Blackout Kick!, you have a $s1% chance to generate $s2 Chi.
    ferociousness                  = { 101035, 458623, 1 }, -- Critical Strike chance increased by $s1%. This effect is increased by $s2% while Xuen, the White Tiger is active.
    fists_of_fury                  = { 101218, 113656, 1 }, -- Pummels all targets in front of you, dealing ${5*$117418s1} Physical damage to your primary target and ${5*$117418s1*$s6/100} damage to all other enemies over $113656d. Deals reduced damage beyond $s1 targets. Can be channeled while moving.
    flight_of_the_red_crane        = { 101234, 443255, 1 }, -- $?c2[Refreshing Jade Wind and Spinning Crane Kick have a chance to cause Chi-Ji to grant you a stack of Mana Tea and quickly rush to $s1 allies, healing each target for $443272s1.]?c3[Rushing Jade Wind and Spinning Crane Kick have a chance to cause Chi-Ji to increase your energy regeneration by $457459s1% for $457459d and quickly rush to $s1 enemies, dealing $443263s1 Physical damage to each target struck.][]
    flurry_of_xuen                 = { 101216, 452137, 1 }, -- Your spells and abilities have a chance to activate Flurry of Xuen, unleashing a barrage of deadly swipes to deal ${$452130s1*$s1} Physical damage in a $452130A1 yd cone, damage reduced beyond $s2 targets.; Invoking Xuen, the White Tiger activates Flurry of Xuen.
    flurry_strikes                 = { 101248, 450615, 1 }, -- Every $<value> damage you deal generates a Flurry Charge. For each $s2 energy you spend, unleash all Flurry Charges, dealing $450617s1 Physical damage per charge. 
    fury_of_xuen                   = { 101211, 396166, 1 }, -- Your Combo Strikes grant a stacking ${$396167s3/100}% chance for your next Fists of Fury to grant $396168s1% critical strike, haste, and mastery and invoke Xuen, The White Tiger for $396168d.
    gale_force                     = { 101045, 451580, 1 }, -- Targets hit by Strike of the Windlord have a $451582h% chance to be struck for $451582s1% additional Nature damage from your spells and abilities for $451582d.
    glory_of_the_dawn              = { 101039, 392958, 1 }, -- Rising Sun Kick has a chance equal to $s2% of your haste to trigger a second time, dealing $392959s1 Physical damage and restoring $s3 Chi.
    hardened_soles                 = { 101047, 391383, 1 }, -- Blackout Kick critical strike chance increased by $s1% and critical damage increased by $s2%.
    heart_of_the_jade_serpent      = { 101237, 443294, 1 }, -- Consuming $?c2[$443506u stacks of Sheilun's Gift calls]?c3[$443424u Chi causes your next Strike of the Windlord to call][] upon Yu'lon to decrease the cooldown time of $?c2[Renewing Mist, Rising Sun Kick, Life Cocoon, and Thunder Focus Tea]?c3[Rising Sun Kick, Fists of Fury, Strike of the Windlord, and Whirling Dragon Punch][] by $443421s2% for $443421d.$?c3[ ; The channel time of Fists of Fury is reduced by $443421s5% while Yu'lon is active.][]
    high_impact                    = { 101247, 450982, 1 }, -- Enemies who die within $451037d of being damaged by a Flurry Strike explode, dealing $451039s1 physical damage to uncontrolled enemies within $451039a1 yds.
    hit_combo                      = { 101216, 196740, 1 }, -- Each successive attack that triggers Combo Strikes in a row grants $196741s1% increased damage, stacking up to $196741u times.
    inner_compass                  = { 101235, 443571, 1 }, -- You switch between alignments after an August Celestial assists you, increasing a corresponding secondary stat by $443572s1%.; Crane Stance:; Haste; Tiger Stance:; Critical Strike; Ox Stance:; Versatility; Serpent Stance: ; Mastery
    inner_peace                    = { 101214, 397768, 1 }, -- Increases maximum Energy by $s1. Tiger Palm's Energy cost reduced by $s2.
    invoke_xuen_the_white_tiger    = { 101206, 123904, 1 }, -- Summons an effigy of Xuen, the White Tiger for $d. Xuen attacks your primary target, and strikes 3 enemies within $123996A1 yards every $123999t1 sec with Tiger Lightning for $123996s1 Nature damage.$?s323999[; Every $323999s1 sec, Xuen strikes your enemies with Empowered Tiger Lightning dealing $323999s2% of the damage you have dealt to those targets in the last $323999s1 sec.][]
    invokers_delight               = { 101207, 388661, 1 }, -- You gain $388663m1% haste for $?a388212[${$s2-$s3} sec][$388663d] after summoning your Celestial. 
    jade_ignition                  = { 101050, 392979, 1 }, -- Whenever you deal damage to a target with Fists of Fury, you gain a stack of Chi Energy up to a maximum of $m2 stacks.; Using Spinning Crane Kick will cause the energy to detonate in a Chi Explosion, dealing $393056s1 Nature damage to all enemies within $393056A1 yards, reduced beyond $s3 targets. The damage is increased by $393057m1% for each stack of Chi Energy.
    jade_sanctuary                 = { 101238, 443059, 1 }, -- You heal for $s2% of your maximum health instantly when you activate Celestial Conduit and receive $s1% less damage for its duration. ; This effect lingers for an additional $448508d after Celestial Conduit ends.
    jadefire_fists                 = { 101044, 457974, 1 }, -- [388193] Strike the ground fiercely to expose a path of jade for $d$?a137025[ that increases your movement speed by $451943s1% while inside][], dealing $388207s1 Nature damage to $?a451573[$s1 enemy][up to $s1 enemies], and restoring $388207s2 health to $?a451573[$s1 ally][up to $s4 allies] within $388207a1 yds caught in the path.$?a137024[]?a137025[ Up to 5 enemies caught in the path][Stagger is $s3% more effective for $347480d against enemies caught in the path.]$?a137023[]?a137024[][ suffer an additional $388201s1 damage.]$?a137024[; Your abilities have a $s2% chance of resetting the cooldown of Jadefire Stomp while fighting within the path.][]
    jadefire_harmony               = { 101042, 391412, 1 }, -- Enemies and allies hit by Jadefire Stomp are affected by Jadefire Brand, increasing your damage and healing against them by $395413s1% for $395413d.
    jadefire_stomp                 = { 101044, 388193, 1 }, -- Strike the ground fiercely to expose a path of jade for $d$?a137025[ that increases your movement speed by $451943s1% while inside][], dealing $388207s1 Nature damage to $?a451573[$s1 enemy][up to $s1 enemies], and restoring $388207s2 health to $?a451573[$s1 ally][up to $s4 allies] within $388207a1 yds caught in the path.$?a137024[]?a137025[ Up to 5 enemies caught in the path][Stagger is $s3% more effective for $347480d against enemies caught in the path.]$?a137023[]?a137024[][ suffer an additional $388201s1 damage.]$?a137024[; Your abilities have a $s2% chance of resetting the cooldown of Jadefire Stomp while fighting within the path.][]
    knowledge_of_the_broken_temple = { 101203, 451529, 1 }, -- Whirling Dragon Punch grants $s1 stacks of Teachings of the Monastery and its damage is increased by $s2%.; Teachings of the Monastery can now stack up to $s4 times.
    last_emperors_capacitor        = { 101058, 392989, 1 }, -- Chi spenders increase the damage of your next Crackling Jade Lightning by $393039s1% and reduce its cost by $393039s2%, stacking up to $393039u times.
    lead_from_the_front            = { 101254, 450985, 1 }, -- Chi Burst, Chi Wave, and Expel Harm now heal you for $s1% of damage dealt.
    martial_mixture                = { 101057, 451454, 1 }, -- Blackout Kick increases the damage of your next Tiger Palm by $451457s1%, stacking up to $451457u times.
    martial_precision              = { 101246, 450990, 1 }, -- Your attacks penetrate $s1% armor.
    memory_of_the_monastery        = { 101209, 454969, 1 }, -- Tiger Palm's chance to activate Blackout Kick! is increased by $s1% and consuming Teachings of the Monastery grants you ${$454970s1}.1% haste for $454970d equal to the amount of stacks consumed.
    meridian_strikes               = { 101038, 391330, 1 }, -- When you Combo Strike, the cooldown of Touch of Death is reduced by ${$s2/100}.2 sec.; Touch of Death deals an additional $s1% damage.
    momentum_boost                 = { 101048, 451294, 1 }, -- Fists of Fury's damage is increased by $s1% of your haste and Fists of Fury does $451297s1% more damage each time it deals damage, resetting when Fists of Fury ends.; Your auto attack speed is increased by $451298s1% for $451298d after Fists of Fury ends.
    niuzaos_protection             = { 101238, 442747, 1 }, -- Fortifying Brew grants you an absorb shield for $442749s2% of your maximum health.
    one_versus_many                = { 101250, 450988, 1 }, -- Damage dealt by Fists of Fury and Keg Smash counts as double towards Flurry Charge generation.; Fists of Fury damage increased by $s2%.; Keg Smash damage increased by $s3%.
    ordered_elements               = { 101051, 451463, 1 }, -- During Storm, Earth, and Fire, Rising Sun Kick reduces Chi costs by $451462s1 for $451462d and Blackout Kick reduces the cooldown of affected abilities by an additional ${$s1/1000} sec. ; Activating Storm, Earth, and Fire resets the remaining cooldown of Rising Sun Kick and grants $s2 Chi.
    path_of_jade                   = { 101043, 392994, 1 }, -- Increases the initial damage of Jadefire Stomp by ${$s1}% per target hit by that damage, up to a maximum of ${$s1*$s2}% additional damage.
    power_of_the_thunder_king      = { 102251, 459809, 1 }, -- Crackling Jade Lightning now chains to $s1 additional targets and its channel time is reduced by $s2%.
    predictive_training            = { 101245, 450992, 1 }, -- When you dodge or parry an attack, reduce all damage taken by $451230s1% for the next $451230d.
    pride_of_pandaria              = { 101247, 450979, 1 }, -- Flurry Strikes have $s1% additional chance to critically strike.
    protect_and_serve              = { 101254, 450984, 1 }, -- Your Vivify always heals you for an additional $s1% of its total value.
    restore_balance                = { 101233, 442719, 1 }, -- $?c2[Gain Refreshing Jade Wind while Chi-Ji, the Red Crane or Yu'lon, the Jade Serpent is active.]?c3[Gain Rushing Jade Wind while Xuen, the White Tiger is active.][]
    revolving_whirl                = { 101203, 451524, 1 }, -- Whirling Dragon Punch has a $s1% chance to activate Dance of Chi-Ji and its cooldown is reduced by ${$s2/-1000} sec.
    rising_star                    = { 101205, 388849, 1 }, -- Rising Sun Kick damage increased by $s1% and critical strike damage increased by $s2%.
    rushing_jade_wind              = { 101046, 451505, 1 }, -- Strike of the Windlord applies Mark of the Crane to all enemies struck and summons a whirling tornado around you, causing ${(1+$116847d/$116847t1)*$148187s1} Physical damage over $116847d to all enemies within $107270A1 yards. ; Deals reduced damage beyond $116847s1 targets.
    sequenced_strikes              = { 101059, 451515, 1 }, -- You have a $s1% chance to gain Blackout Kick! after consuming Dance of Chi-Ji.
    shadowboxing_treads            = { 101062, 392982, 1 }, -- Blackout Kick damage increased by $s2% and strikes an additional $s1 $ltarget;targets at $s3% effectiveness.
    singularly_focused_jade        = { 101043, 451573, 1 }, -- Jadefire Stomp's initial hit now strikes $s4 target, but deals $s2% increased damage and healing.
    spiritual_focus                = { 101052, 280197, 1 }, -- Every $s1 Chi you spend reduces the cooldown of $?s152173[Serenity][Storm, Earth, and Fire] by $?s152173[${$m3/1000}.1][${$m2/1000}.1] sec.
    storm_earth_and_fire           = { 101053, 137639, 1 }, -- Split into 3 elemental spirits for $d, each spirit dealing ${100+$m1}% of normal damage and healing.; You directly control the Storm spirit, while Earth and Fire spirits mimic your attacks on nearby enemies.; While active, casting Storm, Earth, and Fire again will cause the spirits to fixate on your target.
    strength_of_the_black_ox       = { 101241, 443110, 1 }, -- $?c2[After Xuen assists you, your next Enveloping Mist's cast time is reduced by $443112s1% and causes Niuzao to grant an absorb shield to $443113s3 nearby allies for $443113s2% of your maximum health.]?c3[After Xuen assists you, your next Blackout Kick refunds $s3 stacks of Teachings of the Monastery and causes Niuzao to stomp at your target's location, dealing $443127s1 damage to nearby enemies, reduced beyond $s2 targets.][]
    strike_of_the_windlord         = { 101215, 392983, 1 }, -- Strike with both fists at all enemies in front of you, dealing ${$395519s1+$395521s1} Physical damage and reducing movement speed by $s2% for $d.
    summon_white_tiger_statue      = { 101162, 450639, 1 }, -- Invoking Xuen, the White Tiger also spawns a White Tiger Statue at your location that pulses $389541s1 damage to all enemies every $s1 sec for $388686d.
    teachings_of_the_monastery     = { 101054, 116645, 1 }, -- Tiger Palm causes your next Blackout Kick to strike an additional time, stacking up to $202090u.; Blackout Kick has a $s1% chance to reset the remaining cooldown on Rising Sun Kick.; $?a210802[Each additional Blackout Kick restores ${$210803m1/100}.2% mana.][]
    temple_training                = { 101236, 442743, 1 }, -- $?c2[The healing of Enveloping Mist and Vivify is increased by $s1%.]?c3[Fists of Fury and Spinning Crane Kick deal $s2% more damage.][]
    thunderfist                    = { 101040, 392985, 1 }, -- Strike of the Windlord grants you $s1 stacks of Thunderfist and an additional stack for each additional enemy struck. ; Thunderfist discharges upon melee strikes, dealing $242390s1 Nature damage.
    touch_of_the_tiger             = { 101049, 388856, 1 }, -- Tiger Palm damage increased by $s1%.
    transfer_the_power             = { 101212, 195300, 1 }, -- Blackout Kick, Rising Sun Kick, and Spinning Crane Kick increase damage dealt by your next Fists of Fury by $s1%, stacking up to $195321u times.
    unity_within                   = { 101239, 443589, 1 }, -- Celestial Conduit can be recast once during its duration to call upon all of the August Celestials to assist you at $s1% effectiveness.; Unity Within is automatically cast when Celestial Conduit ends if not used before expiration.
    veterans_eye                   = { 101249, 450987, 1 }, -- Striking the same target $451071u times within $451071d grants $451085s1% Haste.; Multiple instances of this effect may overlap, stacking up to $451085u times.
    vigilant_watch                 = { 101244, 450993, 1 }, -- Blackout Kick deals an additional $s1% critical damage and increases the damage of your next set of Flurry Strikes by $451233s1%.
    whirling_dragon_punch          = { 101204, 152175, 1 }, -- Performs a devastating whirling upward strike, dealing ${3*$158221s1} damage to all nearby enemies and an additional $451767s1 damage to the first target struck. Damage reduced beyond $s1 targets.; Only usable while both Fists of Fury and Rising Sun Kick are on cooldown.
    whirling_steel                 = { 101245, 450991, 1 }, -- When your health drops below $s1%, summon Whirling Steel, increasing your parry chance and avoidance by $451214s1% for $451214d.; This effect can not occur more than once every $proccooldown sec.
    wisdom_of_the_wall             = { 101252, 450994, 1 }, -- [452684] Critical strike damage increased by $s1%.
    xuens_battlegear               = { 101210, 392993, 1 }, -- Rising Sun Kick critical strikes reduce the cooldown of Fists of Fury by ${$m2/1000} sec.; When Fists of Fury ends, the critical strike chance of Rising Sun Kick is increased by $337482m1% for $337482d.
    xuens_bond                     = { 101208, 392986, 1 }, -- Abilities cast by you or your Storm, Earth, and Fire clones that activate Combo Strikes reduce the cooldown of Invoke Xuen, the White Tiger by ${$s2/-1000}.2 sec, and Xuen's damage is increased by ${$s1}%.
    xuens_guidance                 = { 101236, 442687, 1 }, -- Teachings of the Monastery has a $s1% chance to refund a charge when consumed. ; The damage of Tiger Palm is increased by $s2%.
    yulons_knowledge               = { 101233, 443625, 1 }, -- $?c2[Refreshing Jade Wind's duration is increased by ${$s1/1000} sec.]?c3[Rushing Jade Wind's duration is increased by ${$s1/1000} sec.][]
} )

-- PvP Talents
spec:RegisterPvpTalents( {
    absolute_serenity   = 5641, -- (455945) Celestial Conduit now prevents incapacitate, disorient, snare, and root effects for its duration.
    grapple_weapon      = 3052, -- (233759) You fire off a rope spear, grappling the target's weapons and shield, returning them to you for $d.
    perpetual_paralysis = 5448, -- (357495) Paralysis range reduced by $s2 yards, but spreads to $s1 new enemies when removed.
    predestination      = 3744, -- (345829) Killing a player with Touch of Death $@switch<$s1>[reduces the remaining cooldown of][resets the cooldown of] Touch of Karma$@switch<$s1>[ by $s2 sec.][.]
    reverse_harm        = 852 , -- (342928) Increases the healing done by Expel Harm by $m1%.
    ride_the_wind       = 77  , -- (201372) Flying Serpent Kick clears all snares from you when used and forms a path of wind in its wake, causing all allies who stand in it to have $201447m1% increased movement speed and to be immune to movement slowing effects.
    rising_dragon_sweep = 5643, -- (460276) Whirling Dragon Punch knocks enemies up into the air and causes them to fall slowly until they reach the ground.
    rodeo               = 5644, -- (355917) Every $s1 sec while Clash is off cooldown, your next Clash can be reactivated immediately to wildly Clash an additional enemy. This effect can stack up to $355918u times.
    stormspirit_strikes = 5610, -- (411098) Striking more than one enemy with Fists of Fury summons a Storm Spirit to focus your secondary target for $s1 sec, which will mimic any of your attacks that do not also strike the target for $s2% of normal damage.
    tigereye_brew       = 675 , -- (247483) Consumes up to $s2 stacks of Tigereye Brew to empower your Physical abilities with wind for $d per stack consumed. Damage of your strikes are reduced, but bypass armor.; For each $s3 Chi you consume, you gain a stack of Tigereye Brew.
    turbo_fists         = 3745, -- (287681) Fists of Fury now reduces all targets movement speed by $m1%, and you Parry all attacks while channelling Fists of Fury.
    wind_waker          = 3737, -- (357633) Your movement enhancing abilities increases Windwalking on allies by $166646s1%, stacking $s1 additional times. Movement impairing effects are removed at ${$s1+1} stacks.
} )

-- Auras
spec:RegisterAuras( {
    -- Damage received from $@auracaster increased by $w1%.
    acclamation = {
        id = 451433,
        duration = 12.0,
        max_stack = 1,
    },
    -- Agility increased by $w1%.
    against_all_odds = {
        id = 451061,
        duration = 6.0,
        max_stack = 1,
    },
    -- The $?c2[damage of your next Rising Sun Kick is increased by $s1% or the healing of your next Vivify is increased by by $s2%]?c3[damage of your next Rising Sun Kick is increased by $s1%][].
    august_dynasty = {
        id = 442850,
        duration = 12.0,
        max_stack = 1,
    },
    -- Your next Blackout Kick costs no Chi$?a451495[ and deals $w3% more damage][].
    blackout_kick = {
        id = 116768,
        duration = 15.0,
        max_stack = 1,

        -- Affected by:
        -- courageous_impulse[451495] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'pvp_multiplier': 0.6, 'points': 125.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_3_VALUE, }
    },
    -- Reduces damage by $w1%.
    bounce_back = {
        id = 390239,
        duration = 4.0,
        max_stack = 1,
    },
    -- Reduces all damage taken by $w1%.
    calming_presence = {
        id = 388664,
        duration = 0.0,
        max_stack = 1,
    },
    -- Channeling the power of the August Celestials, $?c2[healing $s3 nearby allies.]?c3[damaging nearby enemies.][]$?a443059[; Damage taken reduced by $w2%.][]$?a443566[; Movement speed increased by $w5%.][]
    celestial_conduit = {
        id = 443028,
        duration = 4.0,
        max_stack = 1,

        -- Affected by:
        -- chijis_swiftness[443566] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER_BY_LABEL, 'points': 75.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_5_VALUE, }
        -- jade_sanctuary[443059] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER_BY_LABEL, 'points': -15.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_2_VALUE, }
        -- jade_sanctuary[443059] #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER_BY_LABEL, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_4_VALUE, }
    },
    -- Chi Burst can be cast!
    chi_burst = {
        id = 460490,
        duration = 20.0,
        max_stack = 1,
    },
    -- Increases the damage done by your next Chi Explosion by $s1%.; Chi Explosion is triggered whenever you use Spinning Crane Kick.
    chi_energy = {
        id = 393057,
        duration = 45.0,
        max_stack = 1,
    },
    -- Healing taken increased by $s1%.
    chi_harmony = {
        id = 423439,
        duration = 8.0,
        max_stack = 1,
    },
    -- Movement speed increased by $w1%.
    chi_torpedo = {
        id = 119085,
        duration = 10.0,
        max_stack = 1,
    },
    -- Movement speed increased by $w1%.
    chijis_swiftness = {
        id = 443569,
        duration = 3.0,
        max_stack = 1,
    },
    -- Stunned.
    clash = {
        id = 128846,
        duration = 4.0,
        max_stack = 1,
    },
    -- Taking $w1 damage every $t1 sec.
    crackling_jade_lightning = {
        id = 117952,
        duration = 4.0,
        tick_time = 1.0,
        pandemic = true,
        max_stack = 1,

        -- Affected by:
        -- windwalker_monk[137025] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- windwalker_monk[137025] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- windwalker_monk[137025] #11: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -500.0, 'target': TARGET_UNIT_CASTER, 'modifies': GLOBAL_COOLDOWN, }
        -- windwalker_monk_twohand_adjustment[346104] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- windwalker_monk_twohand_adjustment[346104] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- efficient_training[450989] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- efficient_training[450989] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- power_of_the_thunder_king[459809] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 4.0, 'target': TARGET_UNIT_CASTER, 'modifies': CHAINED_TARGETS, }
        -- power_of_the_thunder_king[459809] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -50.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
        -- power_of_the_thunder_king[459809] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -50.0, 'target': TARGET_UNIT_CASTER, 'modifies': AURA_PERIOD, }
        -- storm_earth_and_fire[137639] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -60.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- storm_earth_and_fire[137639] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -60.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- fatal_touch[450832] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- fatal_touch[450832] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- the_emperors_capacitor[393039] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 200.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- the_emperors_capacitor[393039] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -5.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- hit_combo[196741] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 1.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- hit_combo[196741] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 1.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- the_emperors_capacitor[235054] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.5, 'points': 100.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- the_emperors_capacitor[235054] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -5.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
    },
    -- Haste increased by $w1%.
    crane_stance = {
        id = 443572,
        duration = 3600,
        max_stack = 1,
    },
    -- Movement slowed by $w1%.
    crashing_momentum = {
        id = 450342,
        duration = 5.0,
        pandemic = true,
        max_stack = 1,

        -- Affected by:
        -- winds_reach[450514] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': RANGE, }
        -- winds_reach[450514] #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER_BY_LABEL, 'points': -20.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_1_VALUE, }
        -- winds_reach[450514] #2: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER_BY_LABEL, 'points': 3000.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
    },
    -- Your next Spinning Crane Kick is free and deals an additional $325201s1% damage.
    dance_of_chiji = {
        id = 325202,
        duration = 15.0,
        max_stack = 1,
    },
    -- Your dodge chance is increased by $w1% until you dodge an attack.
    dance_of_the_wind = {
        id = 432180,
        duration = 10.0,
        max_stack = 1,
    },
    -- Spell damage taken reduced by $m1%.
    diffuse_magic = {
        id = 122783,
        duration = 6.0,
        max_stack = 1,
    },
    -- Rooted for $d.
    disable = {
        id = 116706,
        duration = 8.0,
        max_stack = 1,
    },
    -- Transcendence: Transfer has no cooldown.; Vivify's healing is increased by $w3% and you're refunded $m2% of the cost when cast on yourself.
    escape_from_reality = {
        id = 343249,
        duration = 10.0,
        max_stack = 1,
    },
    -- Healing taken from $@auracaster increased by $s1%
    fae_exposure = {
        id = 356774,
        duration = 10.0,
        max_stack = 1,
    },
    -- Your spells and abilities deal $s1% more damage.
    fatal_touch = {
        id = 450832,
        duration = 30.0,
        max_stack = 1,
    },
    -- Increases all damage dealt by $w1%.
    ferocity_of_xuen = {
        id = 388674,
        duration = 0.0,
        max_stack = 1,
    },
    -- Stunned.
    fists_of_fury = {
        id = 120086,
        duration = 4.0,
        max_stack = 1,

        -- Affected by:
        -- monk[137022] #0: { 'type': APPLY_AURA, 'subtype': MOD_COOLDOWN_BY_HASTE_REGEN, 'target': TARGET_UNIT_CASTER, }
        -- turbo_fists[287681] #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 200.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_4_VALUE, }
        -- ordered_elements[451462] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -1.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
    },
    -- Increases all healing taken by $w1%.
    flow_of_chi = {
        id = 450571,
        duration = 3600,
        max_stack = 1,
    },
    -- Movement speed reduced by $m2%.
    flying_serpent_kick = {
        id = 123586,
        duration = 4.0,
        max_stack = 1,

        -- Affected by:
        -- windwalker_monk[137025] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- windwalker_monk[137025] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- windwalker_monk_twohand_adjustment[346104] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- windwalker_monk_twohand_adjustment[346104] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- tigereye_brew[247483] #0: { 'type': APPLY_AURA, 'subtype': MOD_ABILITY_SCHOOL_MASK, 'value': 8, 'schools': ['nature'], 'target': TARGET_UNIT_CASTER, }
        -- tigereye_brew[247483] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -25.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- fatal_touch[450832] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- fatal_touch[450832] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- hit_combo[196741] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 1.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- hit_combo[196741] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 1.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
    },
    -- $?$w1>0[Health increased by $<health>%, damage taken reduced by $<damage>%.][]$?$w6>0[; Effectiveness of Stagger increased by $115203s1%.][]$?a451029&$c2[; Staggering $451029s1% of incoming damage.][]
    fortifying_brew = {
        id = 120954,
        duration = 15.0,
        max_stack = 1,
    },
    -- Your next Fists of Fury has a ${$w3/100}.1% chance to grant $w1 Haste and invoke Xuen, The White Tiger for $287063d.
    fury_of_xuen = {
        id = 287062,
        duration = 20.0,
        max_stack = 1,
    },
    -- $@auracaster's abilities to have a $h% chance to strike for $s1% additional Nature damage.
    gale_force = {
        id = 451582,
        duration = 10.0,
        max_stack = 1,
    },
    -- Increases all healing taken  by $w1%.
    grace_of_the_crane = {
        id = 388811,
        duration = 0.0,
        max_stack = 1,
    },
    -- Disarmed.
    grapple_weapon = {
        id = 233759,
        duration = 5.0,
        max_stack = 1,
    },
    -- Gathering Yu'lon's energy.
    heart_of_the_jade_serpent = {
        id = 443506,
        duration = 60.0,
        max_stack = 1,
    },
    -- Movement speed reduced by $w1%.
    heavyhanded_strikes = {
        id = 201787,
        duration = 2.0,
        max_stack = 1,
    },
    -- Damage dealt increased by $s1%.
    hit_combo = {
        id = 196741,
        duration = 30.0,
        max_stack = 1,
    },
    -- [274586] Vivify heals all allies with your Renewing Mist active for $425804s1, reduced beyond $s1 allies.; 
    invigorating_mists = {
        id = 425804,
        duration = 0.0,
        max_stack = 1,
    },
    -- Haste increased by $w1%.
    invokers_delight = {
        id = 388663,
        duration = 20.0,
        max_stack = 1,

        -- Affected by:
        -- windwalker_monk[137025] #29: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER_BY_LABEL, 'points': -18.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_1_VALUE, }
    },
    -- Damage taken reduced by $w1%.
    jade_sanctuary = {
        id = 448508,
        duration = 8.0,
        max_stack = 1,
    },
    -- Movement speed increased by $w1%.
    jade_walk = {
        id = 450552,
        duration = 5.0,
        max_stack = 1,
    },
    -- Healing taken from $@auracaster increased by $s1%
    jadefire_brand = {
        id = 395413,
        duration = 10.0,
        max_stack = 1,
    },
    -- $?c2[Fighting within jadefire has a $s2% chance of resetting the cooldown of Jadefire Stomp.]c3[A Jadefire Stomp is active.]
    jadefire_stomp = {
        id = 388193,
        duration = 30.0,
        max_stack = 1,

        -- Affected by:
        -- singularly_focused_jade[451573] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -4.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_1_VALUE, }
        -- singularly_focused_jade[451573] #2: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -4.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_4_VALUE, }
    },
    -- Stunned.
    leg_sweep = {
        id = 119381,
        duration = 3.0,
        max_stack = 1,

        -- Affected by:
        -- windwalker_monk[137025] #11: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -500.0, 'target': TARGET_UNIT_CASTER, 'modifies': GLOBAL_COOLDOWN, }
        -- ancient_arts[344359] #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -10000.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
        -- tiger_tail_sweep[264348] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 4.0, 'target': TARGET_UNIT_CASTER, 'modifies': RADIUS, }
    },
    -- You may jump twice to dash forward a short distance.
    lighter_than_air = {
        id = 449609,
        duration = 5.0,
        max_stack = 1,
    },
    -- The damage of your next Tiger Palm is increased by $w1%.
    martial_mixture = {
        id = 451457,
        duration = 15.0,
        max_stack = 1,
    },
    -- Haste increased by ${$w1}.1%.
    memory_of_the_monastery = {
        id = 454970,
        duration = 5.0,
        max_stack = 1,
    },
    -- Fists of Fury's damage increased by $s1%.
    momentum_boost = {
        id = 451297,
        duration = 10.0,
        max_stack = 1,
    },
    -- Physical damage taken increased by $w1%.
    mystic_touch = {
        id = 113746,
        duration = 3600,
        max_stack = 1,
    },
    -- Absorbing $w1 damage.
    niuzaos_protection = {
        id = 442749,
        duration = 15.0,
        max_stack = 1,
    },
    -- Reduces the Chi Cost of your abilities by $s1.
    ordered_elements = {
        id = 451462,
        duration = 7.0,
        max_stack = 1,
    },
    -- Incapacitated.
    paralysis = {
        id = 115078,
        duration = 60.0,
        max_stack = 1,

        -- Affected by:
        -- windwalker_monk[137025] #11: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -500.0, 'target': TARGET_UNIT_CASTER, 'modifies': GLOBAL_COOLDOWN, }
        -- ancient_arts[344359] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -15000.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
        -- perpetual_paralysis[357495] #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -5.0, 'target': TARGET_UNIT_CASTER, 'modifies': RANGE, }
    },
    -- Damage taken reduced by $w1%.
    predictive_training = {
        id = 451230,
        duration = 6.0,
        max_stack = 1,
    },
    -- Rising Sun Kick critical strike chance increased by $w1%.
    pressure_point = {
        id = 337482,
        duration = 5.0,
        max_stack = 1,
    },
    -- Taunted. Movement speed increased by $s3%.
    provoke = {
        id = 116189,
        duration = 3.0,
        max_stack = 1,

        -- Affected by:
        -- hasty_provocation[328670] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 50.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_3_VALUE, }
    },
    -- Restores $w1 health every $t1 sec.$?a448392[; Healing received from $@auracaster increased by $457013s1% for the first $457013d.][]$?e1[; Healing received from $@auracaster increased by $w2%.][]
    renewing_mist = {
        id = 119611,
        duration = 20.0,
        pandemic = true,
        max_stack = 1,

        -- Affected by:
        -- renewing_mist[119611] #1: { 'type': APPLY_AURA, 'subtype': MOD_HEALING_RECEIVED, 'target': TARGET_UNIT_TARGET_ALLY, }
        -- chi_proficiency[450426] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- save_them_all[390105] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- save_them_all[390105] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- jadefire_brand[395413] #0: { 'type': APPLY_AURA, 'subtype': MOD_HEALING_RECEIVED, 'points': 6.0, 'target': TARGET_UNIT_TARGET_ALLY, }
        -- chi_harmony[423439] #0: { 'type': APPLY_AURA, 'subtype': MOD_HEALING_RECEIVED, 'pvp_multiplier': 0.3, 'points': 50.0, 'target': TARGET_UNIT_TARGET_ALLY, }
    },
    -- Movement speed increased by $w1%.; Immune to movement speed reduction effects.
    ride_the_wind = {
        id = 201447,
        duration = 1.0,
        max_stack = 1,
    },
    -- Nearby enemies will be knocked out of the Ring of Peace.
    ring_of_peace = {
        id = 116844,
        duration = 5.0,
        max_stack = 1,

        -- Affected by:
        -- windwalker_monk[137025] #11: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -500.0, 'target': TARGET_UNIT_CASTER, 'modifies': GLOBAL_COOLDOWN, }
        -- peace_and_prosperity[450448] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -5000.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
    },
    -- Slow falling.
    rising_dragon_sweep = {
        id = 460280,
        duration = 20.0,
        max_stack = 1,
    },
    -- Clash can be reactivated.
    rodeo = {
        id = 355918,
        duration = 3.0,
        max_stack = 1,
    },
    -- Dealing physical damage to nearby enemies every $116847t1 sec.
    rushing_jade_wind = {
        id = 116847,
        duration = 6.0,
        pandemic = true,
        max_stack = 1,

        -- Affected by:
        -- windwalker_monk[137025] #5: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 12.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- windwalker_monk[137025] #11: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -500.0, 'target': TARGET_UNIT_CASTER, 'modifies': GLOBAL_COOLDOWN, }
        -- windwalker_monk[137025] #26: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 7000.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
        -- monk[137022] #0: { 'type': APPLY_AURA, 'subtype': MOD_COOLDOWN_BY_HASTE_REGEN, 'target': TARGET_UNIT_CASTER, }
        -- storm_earth_and_fire[137639] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -60.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- storm_earth_and_fire[137639] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -60.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- yulons_knowledge[443625] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 4000.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
        -- tigereye_brew[247483] #0: { 'type': APPLY_AURA, 'subtype': MOD_ABILITY_SCHOOL_MASK, 'value': 8, 'schools': ['nature'], 'target': TARGET_UNIT_CASTER, }
        -- tigereye_brew[247483] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -25.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- ordered_elements[451462] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -1.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
    },
    -- Healing increased by $w1%.
    save_them_all = {
        id = 390105,
        duration = 4.0,
        max_stack = 1,
    },
    -- Disoriented.
    song_of_chiji = {
        id = 198909,
        duration = 20.0,
        max_stack = 1,
    },
    -- Healing for $w1 every $t1 sec.$?a388681[; Damage taken reduced by $w2%.][]
    soothing_mist = {
        id = 115175,
        duration = 8.0,
        pandemic = true,
        max_stack = 1,

        -- Affected by:
        -- renewing_mist[119611] #1: { 'type': APPLY_AURA, 'subtype': MOD_HEALING_RECEIVED, 'target': TARGET_UNIT_TARGET_ALLY, }
        -- chi_proficiency[450426] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- elusive_mists[388681] #2: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -6.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_2_VALUE, }
        -- save_them_all[390105] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- save_them_all[390105] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- jadefire_brand[395413] #0: { 'type': APPLY_AURA, 'subtype': MOD_HEALING_RECEIVED, 'points': 6.0, 'target': TARGET_UNIT_TARGET_ALLY, }
        -- chi_harmony[423439] #0: { 'type': APPLY_AURA, 'subtype': MOD_HEALING_RECEIVED, 'pvp_multiplier': 0.3, 'points': 50.0, 'target': TARGET_UNIT_TARGET_ALLY, }
    },
    -- Attacking all nearby enemies for Physical damage every $101546t1 sec.; Movement speed reduced by $s2%.
    spinning_crane_kick = {
        id = 107270,
        duration = 0.0,
        max_stack = 1,

        -- Affected by:
        -- windwalker_monk[137025] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- windwalker_monk[137025] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- windwalker_monk[137025] #7: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 165.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- windwalker_monk_twohand_adjustment[346104] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- windwalker_monk_twohand_adjustment[346104] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- fast_feet[388809] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- crane_vortex[388848] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- crane_vortex[388848] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': RADIUS, }
        -- efficient_training[450989] #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- storm_earth_and_fire[137639] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -60.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- storm_earth_and_fire[137639] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -60.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- temple_training[442743] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- tigereye_brew[247483] #0: { 'type': APPLY_AURA, 'subtype': MOD_ABILITY_SCHOOL_MASK, 'value': 8, 'schools': ['nature'], 'target': TARGET_UNIT_CASTER, }
        -- tigereye_brew[247483] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -25.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- fatal_touch[450832] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- fatal_touch[450832] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- cyclone_strikes[220358] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 18.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- hit_combo[196741] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 1.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- hit_combo[196741] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 1.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
    },
    -- Movement slowed by $w1%.
    spirits_essence = {
        id = 450596,
        duration = 4.0,
        max_stack = 1,
    },
    -- Elemental spirits summoned, mirroring all of the Monk's attacks.; The Monk and spirits each do ${100+$m1}% of normal damage and healing.
    storm_earth_and_fire = {
        id = 137639,
        duration = 15.0,
        max_stack = 1,

        -- Affected by:
        -- ordered_elements[451463] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 1000.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_5_VALUE, }
        -- storm_earth_and_fire[137639] #5: { 'type': APPLY_AURA, 'subtype': OVERRIDE_ACTIONBAR_SPELLS, 'spell': 221771, 'value': 127, 'schools': ['physical', 'holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], 'target': TARGET_UNIT_CASTER, }
    },
    -- Absorbing $w1 damage.
    strength_of_the_black_ox = {
        id = 443113,
        duration = 10.0,
        max_stack = 1,
    },
    -- Movement speed reduced by $s2%.
    strike_of_the_windlord = {
        id = 392983,
        duration = 6.0,
        max_stack = 1,

        -- Affected by:
        -- windwalker_monk[137025] #13: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 26.5, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- communion_with_wind[451576] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -10000.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
        -- communion_with_wind[451576] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 80.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- storm_earth_and_fire[137639] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -60.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- storm_earth_and_fire[137639] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -60.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- tigereye_brew[247483] #0: { 'type': APPLY_AURA, 'subtype': MOD_ABILITY_SCHOOL_MASK, 'value': 8, 'schools': ['nature'], 'target': TARGET_UNIT_CASTER, }
        -- tigereye_brew[247483] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -25.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- ordered_elements[451462] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -1.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
    },
    -- Your next Blackout Kick strikes an additional $m1 $Ltime:times;$?s210802[ and restores ${$210803m~1*$m1/100}.2% mana][].
    teachings_of_the_monastery = {
        id = 202090,
        duration = 20.0,
        max_stack = 1,

        -- Affected by:
        -- knowledge_of_the_broken_temple[451529] #2: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER_BY_LABEL, 'pvp_multiplier': 0.5, 'points': 4.0, 'target': TARGET_UNIT_CASTER, 'modifies': MAX_STACKS, }
    },
    -- Damage of next Crackling Jade Lightning increased by $s1%.; Energy cost of next Crackling Jade Lightning reduced by $s2%.
    the_emperors_capacitor = {
        id = 235054,
        duration = 3600,
        max_stack = 1,
    },
    -- Physical abilities now deal Nature damage.
    tigereye_brew = {
        id = 247483,
        duration = 2.0,
        max_stack = 1,
    },
    -- Moving $s1% faster.
    tigers_lust = {
        id = 116841,
        duration = 6.0,
        max_stack = 1,

        -- Affected by:
        -- windwalker_monk[137025] #11: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -500.0, 'target': TARGET_UNIT_CASTER, 'modifies': GLOBAL_COOLDOWN, }
    },
    -- $w1 Nature damage every $t1 sec.
    touch_of_karma = {
        id = 124280,
        duration = 6.0,
        tick_time = 1.0,
        pandemic = true,
        max_stack = 1,
    },
    -- Your spirit is tethered to another player, allowing you to use Transcendence: Transfer to teleport to their location.
    transcendence = {
        id = 434767,
        duration = 3600.0,
        max_stack = 1,
    },
    -- Damage of your next Fists of Fury increased by $s1%.
    transfer_the_power = {
        id = 195321,
        duration = 30.0,
        max_stack = 1,
    },
    -- Damage of your next set of Flurry Strikes increased by $w1%.
    vigilant_watch = {
        id = 451233,
        duration = 30.0,
        max_stack = 1,
    },
    -- Your next Vivify is instant and its healing is increased by $s2%.$?c1[; The cost of Vivify is reduced by $s3%.]?c3[; The cost of Vivify is reduced by $s4%.][]
    vivacious_vivification = {
        id = 392883,
        duration = 3600,
        max_stack = 1,

        -- Affected by:
        -- windwalker_monk[137025] #15: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER_BY_LABEL, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_2_VALUE, }
    },
    -- Parry and Avoidance increased by $w1%.
    whirling_steel = {
        id = 451214,
        duration = 6.0,
        max_stack = 1,
    },
    -- Movement speed increased by $w1%.
    windwalking = {
        id = 166646,
        duration = 3600,
        max_stack = 1,
    },
    -- Flying.
    zen_flight = {
        id = 125883,
        duration = 3600,
        max_stack = 1,
    },
} )

-- Abilities
spec:RegisterAbilities( {
    -- [387624] Reduces Stagger by $<reduc>.
    blackout_kick = {
        id = 100784,
        cast = 0.0,
        cooldown = 3.0,
        gcd = "global",

        spend = 3,
        spendType = 'chi',

        startsCombat = true,

        -- Effects:
        -- #0: { 'type': SCHOOL_DAMAGE, 'subtype': NONE, 'chain_targets': 1, 'ap_bonus': 0.847, 'pvp_multiplier': 1.3, 'variance': 0.05, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #1: { 'type': DUMMY, 'subtype': NONE, 'chain_targets': 1, 'ap_bonus': 0.77, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #2: { 'type': DUMMY, 'subtype': NONE, }

        -- Affected by:
        -- windwalker_monk[137025] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- windwalker_monk[137025] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- windwalker_monk[137025] #8: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
        -- windwalker_monk[137025] #11: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -500.0, 'target': TARGET_UNIT_CASTER, 'modifies': GLOBAL_COOLDOWN, }
        -- windwalker_monk[137025] #23: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- blackout_kick[261916] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -2.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- windwalker_monk_twohand_adjustment[346104] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- windwalker_monk_twohand_adjustment[346104] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- brawlers_intensity[451485] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 15.0, 'target': TARGET_DEST_DB, 'modifies': DAMAGE_HEALING, }
        -- hardened_soles[391383] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': CRIT_CHANCE, }
        -- hardened_soles[391383] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_15, }
        -- shadowboxing_treads[392982] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': CHAINED_TARGETS, }
        -- shadowboxing_treads[392982] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- storm_earth_and_fire[137639] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -60.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- storm_earth_and_fire[137639] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -60.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- storm_earth_and_fire[137639] #4: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_3_VALUE, }
        -- vigilant_watch[450993] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_15, }
        -- tigereye_brew[247483] #0: { 'type': APPLY_AURA, 'subtype': MOD_ABILITY_SCHOOL_MASK, 'value': 8, 'schools': ['nature'], 'target': TARGET_UNIT_CASTER, }
        -- tigereye_brew[247483] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -25.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- fatal_touch[450832] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- fatal_touch[450832] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- blackout_kick[116768] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- blackout_kick[116768] #1: { 'type': APPLY_AURA, 'subtype': ABILITY_IGNORE_AURASTATE, 'points': 1.0, 'target': TARGET_UNIT_CASTER, }
        -- blackout_kick[116768] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- hit_combo[196741] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 1.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- hit_combo[196741] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 1.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- ordered_elements[451462] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -1.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
    },

    -- $?c2[The August Celestials empower you, causing you to radiate ${$443039s1*$s7} healing onto up to $s3 injured allies and ${$443038s1*$s7} Nature damage onto enemies within $s6 yds over $d, split evenly among them. Healing and damage increased by $s1% per target, up to ${$s1*$s3}%.]?c3[The August Celestials empower you, causing you to radiate ${$443038s1*$s7} Nature damage onto enemies and ${$443039s1*$s7} healing onto up to $s3 injured allies within $443038A2 yds over $d, split evenly among them. Healing and damage increased by $s1% per enemy struck, up to ${$s1*$s3}%.][]; You may move while channeling, but casting other healing or damaging spells cancels this effect.; 
    celestial_conduit = {
        id = 443028,
        cast = 0.0,
        cooldown = 90.0,
        gcd = "global",

        spend = 0.050,
        spendType = 'mana',

        talent = "celestial_conduit",
        startsCombat = false,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': PERIODIC_TRIGGER_SPELL, 'tick_time': 1.0, 'points': 6.0, 'target': TARGET_UNIT_CASTER, }
        -- #1: { 'type': APPLY_AURA, 'subtype': MOD_DAMAGE_PERCENT_TAKEN, 'schools': ['physical', 'holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], 'target': TARGET_UNIT_CASTER, }
        -- #2: { 'type': APPLY_AURA, 'subtype': DUMMY, 'points': 5.0, 'target': TARGET_UNIT_CASTER, }
        -- #3: { 'type': HEAL_PCT, 'subtype': NONE, 'target': TARGET_UNIT_CASTER, }
        -- #4: { 'type': APPLY_AURA, 'subtype': MOD_INCREASE_SPEED, 'target': TARGET_UNIT_CASTER, }
        -- #5: { 'type': APPLY_AURA, 'subtype': DUMMY, 'points': 20.0, 'target': TARGET_UNIT_CASTER, }
        -- #6: { 'type': APPLY_AURA, 'subtype': DUMMY, 'points': 5.0, 'target': TARGET_UNIT_CASTER, }
        -- #7: { 'type': APPLY_AURA, 'subtype': MECHANIC_IMMUNITY, 'target': TARGET_UNIT_CASTER, 'mechanic': 26, }

        -- Affected by:
        -- chijis_swiftness[443566] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER_BY_LABEL, 'points': 75.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_5_VALUE, }
        -- jade_sanctuary[443059] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER_BY_LABEL, 'points': -15.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_2_VALUE, }
        -- jade_sanctuary[443059] #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER_BY_LABEL, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_4_VALUE, }
    },

    -- You and the target charge each other, meeting halfway then rooting all targets within $128846A1 yards for $128846d.
    clash = {
        id = 324312,
        cast = 0.0,
        cooldown = 45.0,
        gcd = "global",

        talent = "clash",
        startsCombat = true,

        -- Effects:
        -- #0: { 'type': DUMMY, 'subtype': NONE, 'target': TARGET_UNIT_TARGET_ENEMY, }

        -- Affected by:
        -- rodeo[355918] #0: { 'type': APPLY_AURA, 'subtype': OVERRIDE_ACTIONBAR_SPELLS_TRIGGERED, 'attributes': ['Suppress Points Stacking'], 'trigger_spell': 324312, 'triggers': clash, 'points': 355919.0, 'value': 324312, 'schools': ['nature', 'frost', 'arcane'], 'target': TARGET_UNIT_CASTER, }
    },

    -- Deals $s1 Nature damage.
    claw_of_the_white_tiger = {
        id = 389541,
        cast = 0.0,
        cooldown = 2.0,
        gcd = "none",

        startsCombat = true,

        -- Effects:
        -- #0: { 'type': SCHOOL_DAMAGE, 'subtype': NONE, 'ap_bonus': 0.5, 'radius': 10.0, 'target': TARGET_DEST_CASTER, 'target2': TARGET_UNIT_DEST_AREA_ENEMY, }
    },

    -- You have a $m1% chance when you Tiger Palm to cause your next Blackout Kick to cost no Chi within $116768d.
    combo_breaker = {
        id = 137384,
        cast = 0.0,
        cooldown = 0.0,
        gcd = "global",

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': DUMMY, 'points': 8.0, 'target': TARGET_UNIT_CASTER, }

        -- Affected by:
        -- memory_of_the_monastery[454969] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_1_VALUE, }
    },

    -- Channel Jade lightning, causing $o1 Nature damage over $117952d to the target$?a154436[, generating 1 Chi each time it deals damage,][] and sometimes knocking back melee attackers.
    crackling_jade_lightning = {
        id = 117952,
        cast = 4.0,
        channeled = true,
        cooldown = 0.0,
        gcd = "global",

        spend = 20,
        spendType = 'energy',

        spend = 20,
        spendType = 'energy',

        startsCombat = true,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': PERIODIC_DAMAGE, 'tick_time': 1.0, 'ap_bonus': 0.056, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #1: { 'type': APPLY_AURA, 'subtype': DUMMY, 'points': 200.0, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #2: { 'type': APPLY_AURA, 'subtype': DUMMY, 'points': 200.0, 'target': TARGET_UNIT_CASTER, }

        -- Affected by:
        -- windwalker_monk[137025] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- windwalker_monk[137025] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- windwalker_monk[137025] #11: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -500.0, 'target': TARGET_UNIT_CASTER, 'modifies': GLOBAL_COOLDOWN, }
        -- windwalker_monk_twohand_adjustment[346104] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- windwalker_monk_twohand_adjustment[346104] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- efficient_training[450989] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- efficient_training[450989] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- power_of_the_thunder_king[459809] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 4.0, 'target': TARGET_UNIT_CASTER, 'modifies': CHAINED_TARGETS, }
        -- power_of_the_thunder_king[459809] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -50.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
        -- power_of_the_thunder_king[459809] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -50.0, 'target': TARGET_UNIT_CASTER, 'modifies': AURA_PERIOD, }
        -- storm_earth_and_fire[137639] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -60.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- storm_earth_and_fire[137639] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -60.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- fatal_touch[450832] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- fatal_touch[450832] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- the_emperors_capacitor[393039] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 200.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- the_emperors_capacitor[393039] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -5.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- hit_combo[196741] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 1.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- hit_combo[196741] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 1.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- the_emperors_capacitor[235054] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.5, 'points': 100.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- the_emperors_capacitor[235054] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -5.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
    },

    -- Removes all Poison and Disease effects from the target.
    detox = {
        id = 218164,
        cast = 0.0,
        cooldown = 0.0,
        gcd = "global",

        spend = 10,
        spendType = 'energy',

        talent = "detox",
        startsCombat = false,

        -- Effects:
        -- #0: { 'type': DISPEL, 'subtype': NONE, 'points': 100.0, 'value': 3, 'schools': ['physical', 'holy'], 'target': TARGET_UNIT_TARGET_ALLY, }
        -- #1: { 'type': DISPEL, 'subtype': NONE, 'points': 100.0, 'value': 4, 'schools': ['fire'], 'target': TARGET_UNIT_TARGET_ALLY, }
    },

    -- Reduces magic damage you take by $m1% for $d, and transfers all currently active harmful magical effects on you back to their original caster if possible.
    diffuse_magic = {
        id = 122783,
        cast = 0.0,
        cooldown = 90.0,
        gcd = "none",

        talent = "diffuse_magic",
        startsCombat = false,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': MOD_DAMAGE_PERCENT_TAKEN, 'sp_bonus': 0.25, 'points': -60.0, 'schools': ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], 'target': TARGET_UNIT_CASTER, }
    },

    -- Reduces the target's movement speed by $s1% for $d, duration refreshed by your melee attacks.$?s343731[ Targets already snared will be rooted for $116706d instead.][]
    disable = {
        id = 116095,
        cast = 0.0,
        cooldown = 0.0,
        gcd = "global",

        spend = 15,
        spendType = 'energy',

        spend = 0.007,
        spendType = 'mana',

        spend = 15,
        spendType = 'energy',

        talent = "disable",
        startsCombat = true,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': MOD_DECREASE_SPEED, 'mechanic': snared, 'points': -50.0, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #1: { 'type': APPLY_AURA, 'subtype': PERIODIC_DUMMY, 'tick_time': 1.0, 'mechanic': snared, 'points': 1.0, 'target': TARGET_UNIT_TARGET_ENEMY, }

        -- Affected by:
        -- windwalker_monk[137025] #11: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -500.0, 'target': TARGET_UNIT_CASTER, 'modifies': GLOBAL_COOLDOWN, }
        -- winds_reach[450514] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': RANGE, }
    },

    -- Expel negative chi from your body, healing for $s1 and dealing $s2% of the amount healed as Nature damage to an enemy within $115129A1 yards.$?s322102[; Draws in the positive chi of all your Healing Spheres to increase the healing of Expel Harm.][]$?s342928[; Generates ${$s3+$342928s2} Chi.][]
    expel_harm = {
        id = 322101,
        cast = 0.0,
        cooldown = 15.0,
        gcd = "global",

        spend = 15,
        spendType = 'energy',

        spend = 0.014,
        spendType = 'mana',

        spend = 15,
        spendType = 'energy',

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': HEAL, 'subtype': NONE, 'sp_bonus': 1.2, 'variance': 0.05, 'target': TARGET_UNIT_CASTER, }
        -- #1: { 'type': DUMMY, 'subtype': NONE, 'target': TARGET_UNIT_CASTER, }

        -- Affected by:
        -- windwalker_monk[137025] #21: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 75.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- windwalker_monk[137025] #28: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 100.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- profound_rebuttal[392910] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 50.0, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_15, }
        -- vigorous_expulsion[392900] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- vigorous_expulsion[392900] #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': CRIT_CHANCE, }
        -- reverse_harm[342928] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 30.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
    },

    -- Pummels all targets in front of you, dealing ${5*$117418s1} Physical damage to your primary target and ${5*$117418s1*$s6/100} damage to all other enemies over $113656d. Deals reduced damage beyond $s1 targets. Can be channeled while moving.
    fists_of_fury = {
        id = 113656,
        cast = 4.0,
        channeled = true,
        cooldown = 24.0,
        gcd = "global",

        spend = 3,
        spendType = 'chi',

        talent = "fists_of_fury",
        startsCombat = true,

        -- Effects:
        -- #0: { 'type': DUMMY, 'subtype': NONE, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #1: { 'type': APPLY_AURA, 'subtype': PERIODIC_DUMMY, 'tick_time': 0.166, 'trigger_spell': 120086, 'target': TARGET_UNIT_CASTER, }
        -- #2: { 'type': APPLY_AURA, 'subtype': PERIODIC_DUMMY, 'tick_time': 0.166, 'trigger_spell': 117418, 'triggers': fists_of_fury, 'points': 1.0, 'target': TARGET_UNIT_CASTER, }
        -- #3: { 'type': APPLY_AURA, 'subtype': MOD_PARRY_PERCENT, 'target': TARGET_UNIT_CASTER, }
        -- #4: { 'type': SCHOOL_DAMAGE, 'subtype': NONE, 'ap_bonus': 1.2075, 'pvp_multiplier': 1.15, 'variance': 0.05, }
        -- #5: { 'type': DUMMY, 'subtype': NONE, 'target': TARGET_UNIT_CASTER, }

        -- Affected by:
        -- windwalker_monk[137025] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- windwalker_monk[137025] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- windwalker_monk_twohand_adjustment[346104] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- windwalker_monk_twohand_adjustment[346104] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- monk[137022] #0: { 'type': APPLY_AURA, 'subtype': MOD_COOLDOWN_BY_HASTE_REGEN, 'target': TARGET_UNIT_CASTER, }
        -- turbo_fists[287681] #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 200.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_4_VALUE, }
        -- fatal_touch[450832] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- fatal_touch[450832] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- hit_combo[196741] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 1.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- hit_combo[196741] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 1.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- ordered_elements[451462] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -1.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
    },

    -- Soar forward through the air at high speed for $d.;  ; If used again while active, you will land, reducing the movement speed of enemies within $123586A1 yds by $123586s2% for $123586d.
    flying_serpent_kick = {
        id = 101545,
        cast = 0.0,
        cooldown = 30.0,
        gcd = "global",

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': MOD_SPEED_NO_CONTROL, 'attributes': ['Uncontrolled No Backwards'], 'points': 300.0, 'target': TARGET_UNIT_CASTER, }
        -- #1: { 'type': APPLY_AURA, 'subtype': OVERRIDE_ACTIONBAR_SPELLS, 'spell': 115057, 'target': TARGET_UNIT_CASTER, }
        -- #2: { 'type': APPLY_AURA, 'subtype': MOD_PACIFY_SILENCE, 'value': 127, 'schools': ['physical', 'holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], 'target': TARGET_UNIT_CASTER, }
        -- #3: { 'type': APPLY_AURA, 'subtype': WATER_WALK, 'target': TARGET_UNIT_CASTER, }
        -- #4: { 'type': APPLY_AURA, 'subtype': MOD_MINIMUM_SPEED, 'points': 400.0, 'target': TARGET_UNIT_CASTER, }
        -- #5: { 'type': APPLY_AURA, 'subtype': USE_NORMAL_MOVEMENT_SPEED, 'points': 36.0, 'target': TARGET_UNIT_CASTER, }
        -- #6: { 'type': APPLY_AURA, 'subtype': DUMMY, 'target': TARGET_UNIT_CASTER, }
        -- #7: { 'type': APPLY_AURA, 'subtype': DUMMY, 'target': TARGET_UNIT_CASTER, }

        -- Affected by:
        -- flying_serpent_kick[101545] #1: { 'type': APPLY_AURA, 'subtype': OVERRIDE_ACTIONBAR_SPELLS, 'spell': 115057, 'target': TARGET_UNIT_CASTER, }
    },

    -- [120954] Turns your skin to stone for $120954d$?a388917[, increasing your current and maximum health by $<health>%][]$?s322960[, increasing the effectiveness of Stagger by $322960s1%][]$?a388917[, reducing all damage you take by $<damage>%][]$?a451029&$c2[, and Staggering $451029s1% of incoming damage][].
    fortifying_brew = {
        id = 115203,
        cast = 0.0,
        cooldown = 360.0,
        gcd = "none",

        talent = "fortifying_brew",
        startsCombat = false,

        -- Effects:
        -- #0: { 'type': DUMMY, 'subtype': NONE, 'target': TARGET_UNIT_CASTER, }
        -- #1: { 'type': DUMMY, 'subtype': NONE, 'pvp_multiplier': 1.5, 'target': TARGET_UNIT_CASTER, }

        -- Affected by:
        -- windwalker_monk[137025] #25: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -240000.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
        -- expeditious_fortification[388813] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -30000.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
        -- ironshell_brew[388814] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_1_VALUE, }
        -- ironshell_brew[388814] #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -10.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_2_VALUE, }
    },

    -- You fire off a rope spear, grappling the target's weapons and shield, returning them to you for $d.
    grapple_weapon = {
        id = 233759,
        color = 'pvp_talent',
        cast = 0.0,
        cooldown = 45.0,
        gcd = "global",

        startsCombat = true,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': MOD_DISARM, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #1: { 'type': APPLY_AURA, 'subtype': MOD_DISARM_OFFHAND, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #2: { 'type': APPLY_AURA, 'subtype': MOD_DISARM_RANGED, 'target': TARGET_UNIT_TARGET_ENEMY, }
    },

    -- Summons an effigy of Xuen, the White Tiger for $d. Xuen attacks your primary target, and strikes 3 enemies within $123996A1 yards every $123999t1 sec with Tiger Lightning for $123996s1 Nature damage.$?s323999[; Every $323999s1 sec, Xuen strikes your enemies with Empowered Tiger Lightning dealing $323999s2% of the damage you have dealt to those targets in the last $323999s1 sec.][]
    invoke_xuen_the_white_tiger = {
        id = 123904,
        cast = 0.0,
        cooldown = 120.0,
        gcd = "global",

        talent = "invoke_xuen_the_white_tiger",
        startsCombat = false,

        -- Effects:
        -- #0: { 'type': SUMMON, 'subtype': NONE, 'value': 63508, 'schools': ['fire', 'frost'], 'value1': 3262, 'radius': 3.0, 'target': TARGET_DEST_TARGET_ANY, 'target2': TARGET_DEST_DEST_RANDOM, }
        -- #1: { 'type': APPLY_AURA, 'subtype': PERIODIC_DUMMY, 'tick_time': 4.0, 'target': TARGET_UNIT_CASTER, }
        -- #2: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER_BY_LABEL, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_1_VALUE, }
    },

    -- Strike the ground fiercely to expose a path of jade for $d$?a137025[ that increases your movement speed by $451943s1% while inside][], dealing $388207s1 Nature damage to $?a451573[$s1 enemy][up to $s1 enemies], and restoring $388207s2 health to $?a451573[$s1 ally][up to $s4 allies] within $388207a1 yds caught in the path.$?a137024[]?a137025[ Up to 5 enemies caught in the path][Stagger is $s3% more effective for $347480d against enemies caught in the path.]$?a137023[]?a137024[][ suffer an additional $388201s1 damage.]$?a137024[; Your abilities have a $s2% chance of resetting the cooldown of Jadefire Stomp while fighting within the path.][]
    jadefire_stomp = {
        id = 388193,
        cast = 0.0,
        cooldown = 0.5,
        gcd = "global",

        spend = 0.040,
        spendType = 'mana',

        talent = "jadefire_stomp",
        startsCombat = false,

        -- Effects:
        -- #0: { 'type': DUMMY, 'subtype': NONE, 'radius': 0.0, 'target': TARGET_DEST_CASTER, 'target2': TARGET_DEST_DEST_BACK, }
        -- #1: { 'type': APPLY_AURA, 'subtype': DUMMY, 'points': 6.0, 'target': TARGET_UNIT_CASTER, }
        -- #2: { 'type': APPLY_AURA, 'subtype': DUMMY, 'points': 5.0, 'target': TARGET_UNIT_CASTER, }
        -- #3: { 'type': DUMMY, 'subtype': NONE, 'target': TARGET_UNIT_CASTER, }

        -- Affected by:
        -- singularly_focused_jade[451573] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -4.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_1_VALUE, }
        -- singularly_focused_jade[451573] #2: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -4.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_4_VALUE, }
    },

    -- Knocks down all enemies within $A1 yards, stunning them for $d.
    leg_sweep = {
        id = 119381,
        cast = 0.0,
        cooldown = 60.0,
        gcd = "global",

        startsCombat = true,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': MOD_STUN, 'attributes': ['Area Effects Use Target Radius'], 'mechanic': stunned, 'radius': 6.0, 'target': TARGET_SRC_CASTER, 'target2': TARGET_UNIT_SRC_AREA_ENEMY, }

        -- Affected by:
        -- windwalker_monk[137025] #11: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -500.0, 'target': TARGET_UNIT_CASTER, 'modifies': GLOBAL_COOLDOWN, }
        -- ancient_arts[344359] #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -10000.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
        -- tiger_tail_sweep[264348] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 4.0, 'target': TARGET_UNIT_CASTER, 'modifies': RADIUS, }
    },

    -- Incapacitates the target for $d. Limit 1. Damage will cancel the effect.
    paralysis = {
        id = 115078,
        cast = 0.0,
        cooldown = 45.0,
        gcd = "global",

        spend = 20,
        spendType = 'energy',

        spend = 20,
        spendType = 'energy',

        talent = "paralysis",
        startsCombat = true,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': MOD_STUN, 'points': 1.0, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #1: { 'type': UNKNOWN, 'subtype': NONE, 'points': 60.0, }
        -- #2: { 'type': DISPEL, 'subtype': NONE, 'sp_bonus': 0.25, 'points': 10.0, 'value': 9, 'schools': ['physical', 'nature'], 'target': TARGET_UNIT_TARGET_ENEMY, }

        -- Affected by:
        -- windwalker_monk[137025] #11: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -500.0, 'target': TARGET_UNIT_CASTER, 'modifies': GLOBAL_COOLDOWN, }
        -- ancient_arts[344359] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -15000.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
        -- perpetual_paralysis[357495] #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -5.0, 'target': TARGET_UNIT_CASTER, 'modifies': RANGE, }
    },

    -- Taunts the target to attack you$?s328670[ and causes them to move toward you at $116189m3% increased speed.][.]$?s115315[; This ability can be targeted on your Statue of the Black Ox, causing the same effect on all enemies within  $118635A1 yards of the statue.][]
    provoke = {
        id = 115546,
        cast = 0.0,
        cooldown = 8.0,
        gcd = "none",

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': DUMMY, 'subtype': NONE, 'target': TARGET_UNIT_TARGET_ANY, }

        -- Affected by:
        -- hasty_provocation[328670] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 50.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_3_VALUE, }
    },

    -- Returns the spirit to the body, restoring a dead target to life with $s1% of maximum health and mana. Cannot be cast when in combat.
    resuscitate = {
        id = 115178,
        cast = 10.0,
        cooldown = 0.0,
        gcd = "global",

        spend = 0.008,
        spendType = 'mana',

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': RESURRECT, 'subtype': NONE, 'points': 35.0, }
    },

    -- Form a Ring of Peace at the target location for $d. Enemies that enter will be ejected from the Ring.
    ring_of_peace = {
        id = 116844,
        cast = 0.0,
        cooldown = 45.0,
        gcd = "global",

        talent = "ring_of_peace",
        startsCombat = false,

        -- Effects:
        -- #0: { 'type': DUMMY, 'subtype': NONE, 'radius': 8.0, 'target': TARGET_DEST_DEST, }
        -- #1: { 'type': CREATE_AREATRIGGER, 'subtype': NONE, 'points': 1.0, 'value': 718, 'schools': ['holy', 'fire', 'nature', 'arcane'], 'target': TARGET_DEST_DEST, }

        -- Affected by:
        -- windwalker_monk[137025] #11: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -500.0, 'target': TARGET_UNIT_CASTER, 'modifies': GLOBAL_COOLDOWN, }
        -- peace_and_prosperity[450448] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -5000.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
    },

    -- Kick upwards, dealing $?s137025[${$185099s1*$<CAP>/$AP}][$185099s1] Physical damage$?s128595[, and reducing the effectiveness of healing on the target for $115804d][].$?a388847[; Applies Renewing Mist for $388847s1 seconds to an ally within $388847r yds][]
    rising_sun_kick = {
        id = 107428,
        cast = 0.0,
        cooldown = 10.0,
        gcd = "global",

        spend = 2,
        spendType = 'chi',

        spend = 0.025,
        spendType = 'mana',

        talent = "rising_sun_kick",
        startsCombat = true,

        -- Effects:
        -- #0: { 'type': TRIGGER_SPELL, 'subtype': NONE, 'trigger_spell': 185099, 'points': 1.0, 'target': TARGET_UNIT_TARGET_ENEMY, }

        -- Affected by:
        -- windwalker_monk[137025] #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 16.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- windwalker_monk[137025] #11: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -500.0, 'target': TARGET_UNIT_CASTER, 'modifies': GLOBAL_COOLDOWN, }
        -- windwalker_monk[137025] #14: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 40.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- monk[137022] #0: { 'type': APPLY_AURA, 'subtype': MOD_COOLDOWN_BY_HASTE_REGEN, 'target': TARGET_UNIT_CASTER, }
        -- fast_feet[388809] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 70.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- brawlers_intensity[451485] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -1000.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
        -- rising_star[388849] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- rising_star[388849] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_15, }
        -- storm_earth_and_fire[137639] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -60.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- storm_earth_and_fire[137639] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -60.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- tigereye_brew[247483] #0: { 'type': APPLY_AURA, 'subtype': MOD_ABILITY_SCHOOL_MASK, 'value': 8, 'schools': ['nature'], 'target': TARGET_UNIT_CASTER, }
        -- tigereye_brew[247483] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -25.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- august_dynasty[442850] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 30.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- ordered_elements[451462] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -1.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- pressure_point[337482] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 40.0, 'target': TARGET_UNIT_CASTER, 'modifies': CRIT_CHANCE, }
    },

    -- Roll a short distance.
    roll = {
        id = 109132,
        cast = 0.0,
        cooldown = 0.8,
        gcd = "none",

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': DUMMY, 'subtype': NONE, 'target': TARGET_UNIT_CASTER, }

        -- Affected by:
        -- celerity[115173] #1: { 'type': APPLY_AURA, 'subtype': MOD_MAX_CHARGES, 'points': 1.0, 'target': TARGET_UNIT_CASTER, }
    },

    -- Summons a whirling tornado around you, causing ${(1+$d/$t1)*$148187s1} Physical damage over $d to all enemies within $107270A1 yards. Deals reduced damage beyond $s1 targets.
    rushing_jade_wind = {
        id = 116847,
        cast = 0.0,
        cooldown = 6.0,
        gcd = "global",

        spend = 1,
        spendType = 'chi',

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': PERIODIC_TRIGGER_SPELL, 'tick_time': 0.75, 'trigger_spell': 148187, 'points': 5.0, 'target': TARGET_UNIT_CASTER, }
        -- #1: { 'type': DUMMY, 'subtype': NONE, }

        -- Affected by:
        -- windwalker_monk[137025] #5: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 12.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- windwalker_monk[137025] #11: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -500.0, 'target': TARGET_UNIT_CASTER, 'modifies': GLOBAL_COOLDOWN, }
        -- windwalker_monk[137025] #26: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 7000.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
        -- monk[137022] #0: { 'type': APPLY_AURA, 'subtype': MOD_COOLDOWN_BY_HASTE_REGEN, 'target': TARGET_UNIT_CASTER, }
        -- storm_earth_and_fire[137639] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -60.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- storm_earth_and_fire[137639] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -60.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- yulons_knowledge[443625] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 4000.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
        -- tigereye_brew[247483] #0: { 'type': APPLY_AURA, 'subtype': MOD_ABILITY_SCHOOL_MASK, 'value': 8, 'schools': ['nature'], 'target': TARGET_UNIT_CASTER, }
        -- tigereye_brew[247483] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -25.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- ordered_elements[451462] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -1.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
    },

    -- Draws in all nearby clouds of mist generated by Sheilun, healing the target for $s1 per cloud absorbed.
    sheiluns_gift = {
        id = 205406,
        color = 'artifact',
        cast = 2.0,
        cooldown = 0.0,
        gcd = "global",

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': HEAL, 'subtype': NONE, 'sp_bonus': 0.5, 'target': TARGET_UNIT_TARGET_ALLY, }
    },

    -- Conjures a cloud of hypnotic mist that slowly travels forward. Enemies touched by the mist fall asleep, Disoriented for $198909d.
    song_of_chiji = {
        id = 198898,
        cast = 1.8,
        cooldown = 30.0,
        gcd = "global",

        talent = "song_of_chiji",
        startsCombat = false,

        -- Effects:
        -- #0: { 'type': CREATE_AREATRIGGER, 'subtype': NONE, 'attributes': ['Position is facing relative'], 'value': 5484, 'schools': ['fire', 'nature', 'shadow', 'arcane'], 'target': TARGET_DEST_CASTER, }

        -- Affected by:
        -- peace_and_prosperity[450448] #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER_BY_LABEL, 'points': -500.0, 'target': TARGET_UNIT_CASTER, 'modifies': CAST_TIME, }
    },

    -- Heals the target for $o1 over $d.; While channeling, Effuse and Enveloping Mist are instant cast, and will heal the soothed target without breaking the Soothing Mist channel.
    soothing_mist = {
        id = 209525,
        color = 'pvp_talent',
        cast = 20.0,
        channeled = true,
        cooldown = 1.0,
        gcd = "global",

        spendType = 'mana',

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': PERIODIC_HEAL, 'amplitude': 1.0, 'tick_time': 0.5, 'sp_bonus': 0.225, 'chain_amp': 100.0, 'chain_targets': 1, 'target': TARGET_UNIT_TARGET_ALLY, }
        -- #1: { 'type': APPLY_AURA, 'subtype': CAST_WHILE_WALKING, 'target': TARGET_UNIT_CASTER, }

        -- Affected by:
        -- elusive_mists[388681] #2: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -6.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_2_VALUE, }
    },

    -- Heals the target for $o1 over $d. While channeling, Enveloping Mist$?s227344[, Surging Mist,][]$?s124081[, Zen Pulse,][] and Vivify may be cast instantly on the target.$?s117907[; Each heal has a chance to cause a Gust of Mists on the target.][]$?s388477[; Soothing Mist heals a second injured ally within $388478A2 yds for $388477s1% of the amount healed.][]
    soothing_mist_115175 = {
        id = 115175,
        cast = 8.0,
        channeled = true,
        cooldown = 0.0,
        gcd = "global",

        spendType = 'mana',

        spendType = 'energy',

        spendType = 'energy',

        talent = "soothing_mist_115175",
        startsCombat = false,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': PERIODIC_HEAL, 'amplitude': 1.0, 'tick_time': 1.0, 'sp_bonus': 1.4, 'target': TARGET_UNIT_TARGET_ALLY, }
        -- #1: { 'type': APPLY_AURA, 'subtype': MOD_DAMAGE_PERCENT_TAKEN, 'schools': ['physical', 'holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], 'target': TARGET_UNIT_TARGET_ALLY, }

        -- Affected by:
        -- renewing_mist[119611] #1: { 'type': APPLY_AURA, 'subtype': MOD_HEALING_RECEIVED, 'target': TARGET_UNIT_TARGET_ALLY, }
        -- chi_proficiency[450426] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- elusive_mists[388681] #2: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -6.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_2_VALUE, }
        -- save_them_all[390105] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- save_them_all[390105] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- jadefire_brand[395413] #0: { 'type': APPLY_AURA, 'subtype': MOD_HEALING_RECEIVED, 'points': 6.0, 'target': TARGET_UNIT_TARGET_ALLY, }
        -- chi_harmony[423439] #0: { 'type': APPLY_AURA, 'subtype': MOD_HEALING_RECEIVED, 'pvp_multiplier': 0.3, 'points': 50.0, 'target': TARGET_UNIT_TARGET_ALLY, }
        from = "class_talent",
    },

    -- Jabs the target in the throat, interrupting spellcasting and preventing any spell from that school of magic from being cast for $d.
    spear_hand_strike = {
        id = 116705,
        cast = 0.0,
        cooldown = 15.0,
        gcd = "none",

        talent = "spear_hand_strike",
        startsCombat = true,
        interrupt = true,

        -- Effects:
        -- #0: { 'type': INTERRUPT_CAST, 'subtype': NONE, 'mechanic': interrupted, 'points': 1.0, 'target': TARGET_UNIT_TARGET_ENEMY, }
    },

    -- Spin while kicking in the air, dealing $?s137025[${4*$107270s1*$<CAP>/$AP}][${4*$107270s1}] Physical damage over $d to all enemies within $107270A1 yds. Deals reduced damage beyond $s1 targets.$?a220357[; Spinning Crane Kick's damage is increased by $220358s1% for each unique target you've struck in the last $220358d with Tiger Palm, Blackout Kick, or Rising Sun Kick. Stacks up to $228287i times.][]
    spinning_crane_kick = {
        id = 101546,
        cast = 1.5,
        channeled = true,
        cooldown = 0.0,
        gcd = "global",

        spend = 2,
        spendType = 'chi',

        spend = 0.010,
        spendType = 'mana',

        spend = 40,
        spendType = 'energy',

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': PERIODIC_TRIGGER_SPELL, 'tick_time': 0.5, 'trigger_spell': 107270, 'points': 5.0, 'target': TARGET_UNIT_CASTER, }
        -- #1: { 'type': APPLY_AURA, 'subtype': DUMMY, 'target': TARGET_UNIT_CASTER, }
        -- #2: { 'type': APPLY_AURA, 'subtype': DUMMY, 'points': 15.0, 'target': TARGET_UNIT_CASTER, }

        -- Affected by:
        -- windwalker_monk[137025] #11: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -500.0, 'target': TARGET_UNIT_CASTER, 'modifies': GLOBAL_COOLDOWN, }
        -- fast_feet[388809] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- crane_vortex[388848] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- crane_vortex[388848] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': RADIUS, }
        -- efficient_training[450989] #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- dance_of_chiji[325202] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -2.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- ordered_elements[451462] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -1.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
    },

    -- Split into 3 elemental spirits for $d, each spirit dealing ${100+$m1}% of normal damage and healing.; You directly control the Storm spirit, while Earth and Fire spirits mimic your attacks on nearby enemies.; While active, casting Storm, Earth, and Fire again will cause the spirits to fixate on your target.
    storm_earth_and_fire = {
        id = 137639,
        cast = 0.0,
        cooldown = 16.0,
        gcd = "none",

        talent = "storm_earth_and_fire",
        startsCombat = false,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -60.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -60.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- #2: { 'type': APPLY_AURA, 'subtype': MOD_AUTOATTACK_DAMAGE, 'points': -60.0, 'target': TARGET_UNIT_CASTER, }
        -- #3: { 'type': APPLY_AURA, 'subtype': DUMMY, 'points': -60.0, 'target': TARGET_UNIT_CASTER, }
        -- #4: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_3_VALUE, }
        -- #5: { 'type': APPLY_AURA, 'subtype': OVERRIDE_ACTIONBAR_SPELLS, 'spell': 221771, 'value': 127, 'schools': ['physical', 'holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], 'target': TARGET_UNIT_CASTER, }
        -- #6: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'points': -60.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- #7: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'points': -60.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }

        -- Affected by:
        -- ordered_elements[451463] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 1000.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_5_VALUE, }
        -- storm_earth_and_fire[137639] #5: { 'type': APPLY_AURA, 'subtype': OVERRIDE_ACTIONBAR_SPELLS, 'spell': 221771, 'value': 127, 'schools': ['physical', 'holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], 'target': TARGET_UNIT_CASTER, }
    },

    -- Strike with both fists at all enemies in front of you, dealing ${$395519s1+$395521s1} Physical damage and reducing movement speed by $s2% for $d.
    strike_of_the_windlord = {
        id = 392983,
        cast = 0.0,
        cooldown = 40.0,
        gcd = "global",

        spend = 2,
        spendType = 'chi',

        talent = "strike_of_the_windlord",
        startsCombat = true,

        -- Effects:
        -- #0: { 'type': DUMMY, 'subtype': NONE, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #1: { 'type': APPLY_AURA, 'subtype': MOD_DECREASE_SPEED, 'mechanic': snared, 'points': -50.0, 'radius': 12.0, 'target': TARGET_UNIT_RECT_CASTER_ENEMY, }
        -- #2: { 'type': TRIGGER_SPELL, 'subtype': NONE, 'trigger_spell': 395519, 'target': TARGET_UNIT_CASTER, }
        -- #3: { 'type': TRIGGER_SPELL, 'subtype': NONE, 'trigger_spell': 395521, 'value': 500, 'schools': ['fire', 'frost', 'shadow', 'arcane'], 'target': TARGET_UNIT_CASTER, }

        -- Affected by:
        -- windwalker_monk[137025] #13: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 26.5, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- communion_with_wind[451576] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -10000.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
        -- communion_with_wind[451576] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 80.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- storm_earth_and_fire[137639] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -60.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- storm_earth_and_fire[137639] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -60.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- tigereye_brew[247483] #0: { 'type': APPLY_AURA, 'subtype': MOD_ABILITY_SCHOOL_MASK, 'value': 8, 'schools': ['nature'], 'target': TARGET_UNIT_CASTER, }
        -- tigereye_brew[247483] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -25.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- ordered_elements[451462] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -1.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
    },

    -- Strike with the palm of your hand, dealing $s1 Physical damage.$?a137384[; Tiger Palm has an $137384m1% chance to make your next Blackout Kick cost no Chi.][]$?a137023[; Reduces the remaining cooldown on your Brews by $s3 sec.][]$?a137025[; Generates $s2 Chi.][]
    tiger_palm = {
        id = 100780,
        cast = 0.0,
        cooldown = 0.0,
        gcd = "global",

        spend = 50,
        spendType = 'energy',

        startsCombat = true,

        -- Effects:
        -- #0: { 'type': SCHOOL_DAMAGE, 'subtype': NONE, 'ap_bonus': 0.27027, 'pvp_multiplier': 1.3, 'variance': 0.05, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #1: { 'type': ENERGIZE, 'subtype': NONE, 'target': TARGET_UNIT_CASTER, 'resource': chi, }
        -- #2: { 'type': DUMMY, 'subtype': NONE, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #3: { 'type': DUMMY, 'subtype': NONE, 'target': TARGET_UNIT_TARGET_ENEMY, }

        -- Affected by:
        -- windwalker_monk[137025] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- windwalker_monk[137025] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- windwalker_monk[137025] #3: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_2_VALUE, }
        -- windwalker_monk[137025] #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 16.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- windwalker_monk[137025] #6: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 125.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- windwalker_monk[137025] #11: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -500.0, 'target': TARGET_UNIT_CASTER, 'modifies': GLOBAL_COOLDOWN, }
        -- windwalker_monk[137025] #13: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 26.5, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- windwalker_monk[137025] #27: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- windwalker_monk_twohand_adjustment[346104] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- windwalker_monk_twohand_adjustment[346104] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- efficient_training[450989] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- efficient_training[450989] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- inner_peace[397768] #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -5.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- storm_earth_and_fire[137639] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -60.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- storm_earth_and_fire[137639] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -60.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- touch_of_the_tiger[388856] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 25.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- xuens_guidance[442687] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- tigereye_brew[247483] #0: { 'type': APPLY_AURA, 'subtype': MOD_ABILITY_SCHOOL_MASK, 'value': 8, 'schools': ['nature'], 'target': TARGET_UNIT_CASTER, }
        -- tigereye_brew[247483] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -25.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- fatal_touch[450832] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- fatal_touch[450832] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- darting_hurricane[459841] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'attributes': ['Suppress Points Stacking'], 'points': -50.0, 'target': TARGET_UNIT_CASTER, 'modifies': GLOBAL_COOLDOWN, }
        -- martial_mixture[451457] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- hit_combo[196741] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 1.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- hit_combo[196741] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 1.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
    },

    -- Consumes up to $s2 stacks of Tigereye Brew to empower your Physical abilities with wind for $d per stack consumed. Damage of your strikes are reduced, but bypass armor.; For each $s3 Chi you consume, you gain a stack of Tigereye Brew.
    tigereye_brew = {
        id = 247483,
        color = 'pvp_talent',
        cast = 0.0,
        cooldown = 1.0,
        gcd = "global",

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': MOD_ABILITY_SCHOOL_MASK, 'value': 8, 'schools': ['nature'], 'target': TARGET_UNIT_CASTER, }
        -- #1: { 'type': APPLY_AURA, 'subtype': DUMMY, 'points': 10.0, 'target': TARGET_UNIT_CASTER, }
        -- #2: { 'type': APPLY_AURA, 'subtype': DUMMY, 'points': 3.0, 'target': TARGET_UNIT_CASTER, }
        -- #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -25.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
    },

    -- Increases a friendly target's movement speed by $s1% for $d and removes all roots and snares.
    tigers_lust = {
        id = 116841,
        cast = 0.0,
        cooldown = 30.0,
        gcd = "global",

        talent = "tigers_lust",
        startsCombat = false,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': MOD_INCREASE_SPEED, 'points': 70.0, 'target': TARGET_UNIT_TARGET_ALLY, }

        -- Affected by:
        -- windwalker_monk[137025] #11: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -500.0, 'target': TARGET_UNIT_CASTER, 'modifies': GLOBAL_COOLDOWN, }
    },

    -- You exploit the enemy target's weakest point, instantly killing $?s322113[creatures if they have less health than you.][them.; Only usable on creatures that have less health than you]$?s322113[ Deals damage equal to $s3% of your maximum health against players and stronger creatures under $s2% health.][.]$?s325095[; Reduces delayed Stagger damage by $325095s1% of damage dealt.]?s325215[; Spawns $325215s1 Chi Spheres, granting 1 Chi when you walk through them.]?s344360[; Increases the Monk's Physical damage by $344361s1% for $344361d.][]
    touch_of_death = {
        id = 322109,
        cast = 0.0,
        cooldown = 180.0,
        gcd = "global",

        startsCombat = true,

        -- Effects:
        -- #0: { 'type': SCHOOL_DAMAGE, 'subtype': NONE, 'chain_targets': 1, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #1: { 'type': DUMMY, 'subtype': NONE, }
        -- #2: { 'type': DUMMY, 'subtype': NONE, 'target': TARGET_UNIT_TARGET_ENEMY, }

        -- Affected by:
        -- fatal_touch[394123] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -90000.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
        -- meridian_strikes[391330] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.4, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
    },

    -- Instantly kills any creature under level $m2, or player under $m3% health.
    touch_of_fatality = {
        id = 169340,
        cast = 0.0,
        cooldown = 90.0,
        gcd = "global",

        startsCombat = true,

        -- Effects:
        -- #0: { 'type': INSTAKILL, 'subtype': NONE, 'points': 1.0, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #1: { 'type': DUMMY, 'subtype': NONE, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #2: { 'type': DUMMY, 'subtype': NONE, 'target': TARGET_UNIT_TARGET_ENEMY, }
    },

    -- Absorbs all damage taken for $d, up to $s3% of your maximum health, and redirects $s4% of that amount to the enemy target as Nature damage over $124280d.
    touch_of_karma = {
        id = 122470,
        cast = 0.0,
        cooldown = 90.0,
        gcd = "none",

        startsCombat = true,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': DUMMY, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #1: { 'type': APPLY_AURA, 'subtype': SCHOOL_ABSORB, 'value': 127, 'schools': ['physical', 'holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], 'value1': -30, 'target': TARGET_UNIT_CASTER, }
        -- #2: { 'type': DUMMY, 'subtype': NONE, 'pvp_multiplier': 1.6, }
        -- #3: { 'type': DUMMY, 'subtype': NONE, }
        -- #4: { 'type': DUMMY, 'subtype': NONE, 'target': TARGET_UNIT_CASTER, }
    },

    -- Split your body and spirit, leaving your spirit behind for $d. Use Transcendence: Transfer to swap locations with your spirit.
    transcendence = {
        id = 101643,
        cast = 0.0,
        cooldown = 10.0,
        gcd = "global",

        talent = "transcendence",
        startsCombat = false,

        -- Effects:
        -- #0: { 'type': SUMMON, 'subtype': NONE, 'value': 54569, 'schools': ['physical', 'nature', 'shadow'], 'value1': 3234, 'target': TARGET_DEST_CASTER, }
        -- #1: { 'type': APPLY_AURA, 'subtype': DUMMY, 'target': TARGET_UNIT_CASTER, }

        -- Affected by:
        -- windwalker_monk[137025] #11: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -500.0, 'target': TARGET_UNIT_CASTER, 'modifies': GLOBAL_COOLDOWN, }
    },

    -- Split your body and spirit, tethering your spirit onto an ally for $d. Use Transcendence: Transfer to teleport to your ally's location.
    transcendence_434763 = {
        id = 434763,
        cast = 0.0,
        cooldown = 10.0,
        gcd = "global",

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': DUMMY, 'target': TARGET_UNIT_TARGET_RAID, }
        -- #1: { 'type': TRIGGER_SPELL, 'subtype': NONE, 'trigger_spell': 434767, 'target': TARGET_UNIT_CASTER, }
        -- #2: { 'type': TRIGGER_SPELL, 'subtype': NONE, 'trigger_spell': 434782, 'target': TARGET_UNIT_TARGET_RAID, }
        from = "from_description",
    },

    -- [434763] Split your body and spirit, tethering your spirit onto an ally for $d. Use Transcendence: Transfer to teleport to your ally's location.
    transcendence_434767 = {
        id = 434767,
        cast = 0.0,
        cooldown = 15.0,
        gcd = "global",

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': DUMMY, 'target': TARGET_UNIT_CASTER, }
        from = "triggered_spell",
    },

    -- Transcendence now tethers your spirit onto an ally for $434763d. Use Transcendence: Transfer to teleport to your ally's location.
    transcendence_linked_spirits = {
        id = 434774,
        cast = 0.0,
        cooldown = 10.0,
        gcd = "global",

        talent = "transcendence_linked_spirits",
        startsCombat = false,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': DUMMY, 'target': TARGET_UNIT_CASTER, }
    },

    -- Causes a surge of invigorating mists, healing the target for $<healing>$?s274586[ and all allies with your Renewing Mist active for $425804s1, reduced beyond $274586s1 allies][].
    vivify = {
        id = 116670,
        cast = 1.5,
        cooldown = 0.0,
        gcd = "global",

        spend = 0.030,
        spendType = 'mana',

        spend = 30,
        spendType = 'energy',

        spend = 30,
        spendType = 'energy',

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': HEAL, 'subtype': NONE, 'sp_bonus': 2.58, 'variance': 0.05, 'target': TARGET_UNIT_TARGET_ALLY, }

        -- Affected by:
        -- windwalker_monk[137025] #19: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.34, 'points': 150.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- renewing_mist[119611] #1: { 'type': APPLY_AURA, 'subtype': MOD_HEALING_RECEIVED, 'target': TARGET_UNIT_TARGET_ALLY, }
        -- chi_proficiency[450426] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- temple_training[442743] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- temple_training[442743] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- vivacious_vivification[392883] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -1500.0, 'target': TARGET_UNIT_CASTER, 'modifies': CAST_TIME, }
        -- vivacious_vivification[392883] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- vivacious_vivification[392883] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -75.0, 'target': TARGET_UNIT_CASTER, 'modifies': IGNORE_SHAPESHIFT, }
        -- vivacious_vivification[392883] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -75.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- august_dynasty[442850] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 50.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- escape_from_reality[343249] #2: { 'type': APPLY_AURA, 'subtype': MOD_HEALING_RECEIVED, 'points': 70.0, 'target': TARGET_UNIT_CASTER, }
        -- save_them_all[390105] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- save_them_all[390105] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- jadefire_brand[395413] #0: { 'type': APPLY_AURA, 'subtype': MOD_HEALING_RECEIVED, 'points': 6.0, 'target': TARGET_UNIT_TARGET_ALLY, }
        -- chi_harmony[423439] #0: { 'type': APPLY_AURA, 'subtype': MOD_HEALING_RECEIVED, 'pvp_multiplier': 0.3, 'points': 50.0, 'target': TARGET_UNIT_TARGET_ALLY, }
    },

    -- Performs a devastating whirling upward strike, dealing ${3*$158221s1} damage to all nearby enemies and an additional $451767s1 damage to the first target struck. Damage reduced beyond $s1 targets.; Only usable while both Fists of Fury and Rising Sun Kick are on cooldown.
    whirling_dragon_punch = {
        id = 152175,
        cast = 0.0,
        cooldown = 30.0,
        gcd = "global",

        talent = "whirling_dragon_punch",
        startsCombat = false,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': PERIODIC_DUMMY, 'tick_time': 0.25, 'points': 5.0, 'target': TARGET_UNIT_CASTER, }
        -- #1: { 'type': KNOCK_BACK_DEST, 'subtype': NONE, 'points': 100.0, 'target': TARGET_UNIT_CASTER, 'target2': TARGET_DEST_CASTER, }

        -- Affected by:
        -- monk[137022] #0: { 'type': APPLY_AURA, 'subtype': MOD_COOLDOWN_BY_HASTE_REGEN, 'target': TARGET_UNIT_CASTER, }
        -- knowledge_of_the_broken_temple[451529] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- revolving_whirl[451524] #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -5000.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
        -- storm_earth_and_fire[137639] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -60.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- storm_earth_and_fire[137639] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -60.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- tigereye_brew[247483] #0: { 'type': APPLY_AURA, 'subtype': MOD_ABILITY_SCHOOL_MASK, 'value': 8, 'schools': ['nature'], 'target': TARGET_UNIT_CASTER, }
        -- tigereye_brew[247483] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -25.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
    },

    -- You fly through the air at a quick speed on a meditative cloud.
    zen_flight = {
        id = 125883,
        cast = 0.0,
        cooldown = 0.0,
        gcd = "global",

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': FLY, 'points': 1.0, 'target': TARGET_UNIT_CASTER, }
        -- #1: { 'type': APPLY_AURA, 'subtype': MOD_INCREASE_VEHICLE_FLIGHT_SPEED, 'points': 60.0, 'target': TARGET_UNIT_CASTER, }
        -- #2: { 'type': APPLY_AURA, 'subtype': MOD_NO_ACTIONS, 'target': TARGET_UNIT_CASTER, }
    },

    -- Your spirit travels to your home temple, leaving your body behind. ; Use Zen Pilgrimage again to return back to near your departure point.
    zen_pilgrimage = {
        id = 126892,
        cast = 10.0,
        cooldown = 60.0,
        gcd = "global",

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': TELEPORT_UNITS, 'subtype': NONE, 'points': 1.0, 'target': TARGET_UNIT_CASTER, 'target2': TARGET_DEST_DB, }
        -- #1: { 'type': TRIGGER_SPELL, 'subtype': NONE, 'value': 1000, 'schools': ['nature', 'shadow', 'arcane'], 'target': TARGET_UNIT_CASTER, }
        -- #2: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_CRIT_CHANCE_SCHOOL, 'target': TARGET_UNIT_CASTER, }
        -- #3: { 'type': APPLY_AURA, 'subtype': OVERRIDE_ACTIONBAR_SPELLS, 'spell': 293866, 'value': 126892, 'schools': ['fire', 'nature', 'shadow'], 'target': TARGET_UNIT_CASTER, }
    },

    -- $?a200617[Returns your spirit back to its body, returning you near to where you once were.; Leaving the Wandering Isle will cancel Zen Pilgrimage: Return.]; [Returns your spirit back to its body, returning you near to where you once were.; Leaving Peak of Serenity will cancel Zen Pilgrimage: Return.]
    zen_pilgrimage_return = {
        id = 126895,
        cast = 10.0,
        cooldown = 0.0,
        gcd = "global",

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': SCRIPT_EFFECT, 'subtype': NONE, 'points': 1.0, 'target': TARGET_UNIT_CASTER, }
    },

} )