-- MageFrost.lua
-- July 2024

local addon, ns = ...
local Hekili = _G[ addon ]
local class, state = Hekili.Class, Hekili.State

local spec = Hekili:NewSpecialization( 64 )

-- Resources
spec:RegisterResource( Enum.PowerType.Mana )
spec:RegisterResource( Enum.PowerType.ArcaneCharges )

spec:RegisterTalents( {
    -- Mage Talents
    accumulative_shielding   = { 62093, 382800, 1 }, -- Your barrier's cooldown recharges $s1% faster while the shield persists.
    alter_time               = { 62115, 342245, 1 }, -- Alters the fabric of time, returning you to your current location and health when cast a second time, or after ${$110909d+$s3} sec.  Effect negated by long distance or death.
    arcane_warding           = { 62114, 383092, 2 }, -- Reduces magic damage taken by $s1%.
    barrier_diffusion        = { 62091, 455428, 1 }, -- Whenever one of your Barriers is removed, reduce its cooldown by ${$s1/1000}  sec.
    blast_wave               = { 62103, 157981, 1 }, -- Causes an explosion around yourself, dealing $s1 Fire damage to all enemies within $A1 yds, knocking them back, and reducing movement speed by $s2% for $d.
    cryofreeze               = { 62107, 382292, 2 }, -- While inside Ice Block, you heal for ${$s1*10}% of your maximum health over the duration.
    displacement             = { 62095, 389713, 1 }, -- Teleports you back to where you last Blinked and heals you for ${$414462s1/100*$mhp} health. Only usable within $389714d of Blinking.
    diverted_energy          = { 62101, 382270, 2 }, -- Your Barriers heal you for $s1% of the damage absorbed.
    dragons_breath           = { 101883, 31661 , 1 }, -- Enemies in a cone in front of you take $s2 Fire damage and are disoriented for $d. Damage will cancel the effect.$?a235870[; Always deals a critical strike and contributes to Hot Streak.][]
    energized_barriers       = { 62100, 386828, 1 }, -- When your barrier receives melee attacks, you have a $s1% chance to be granted $?c1[Clearcasting]?c2[1 Fire Blast charge]$?c3[Fingers of Frost]. ; Casting your barrier removes all snare effects.
    flow_of_time             = { 62096, 382268, 2 }, -- The cooldowns of Blink and Shimmer are reduced by ${$s1/-1000} sec.
    freezing_cold            = { 62087, 386763, 1 }, -- Enemies hit by Cone of Cold are frozen in place for $386770d instead of snared.; When your roots expire or are dispelled, your target is snared by $394255s1%, decaying over $394255d.
    frigid_winds             = { 62128, 235224, 2 }, -- All of your snare effects reduce the target's movement speed by an additional $s1%.
    greater_invisibility     = { 93524, 110959, 1 }, -- Makes you invisible and untargetable for $110960d, removing all threat. Any action taken cancels this effect.; You take $113862s1% reduced damage while invisible and for 3 sec after reappearing.$?a382293[; Increases your movement speed by ${$382293s1*0.40}% for $337278d.][]
    ice_block                = { 62122, 45438 , 1 }, -- Encases you in a block of ice, protecting you from all attacks and damage for $d, but during that time you cannot attack, move, or cast spells.$?a382292[; While inside Ice Block, you heal for ${$382292s1*10}% of your maximum health over the duration.][]; Causes Hypothermia, preventing you from recasting Ice Block for $41425d.
    ice_cold                 = { 62085, 414659, 1 }, -- Ice Block now reduces all damage taken by $414658s8% for $414658d but no longer grants Immunity, prevents movement, attacks, or casting spells. Does not incur the Global Cooldown.
    ice_floes                = { 62105, 108839, 1 }, -- Makes your next Mage spell with a cast time shorter than $s2 sec castable while moving. Unaffected by the global cooldown and castable while casting.
    ice_nova                 = { 62088, 157997, 1 }, -- Causes a whirl of icy wind around the enemy, dealing $s1 Frost damage to the target and reduced damage to all other enemies within $a2 yds, and freezing them in place for $d.
    ice_ward                 = { 62086, 205036, 1 }, -- Frost Nova now has ${1+$m1} charges.
    improved_frost_nova      = { 62108, 343183, 1 }, -- Frost Nova duration is increased by ${$s1/1000} sec.
    incantation_of_swiftness = { 62112, 382293, 2 }, -- $?s110959[Greater ][]Invisibility increases your movement speed by $s1% for $337278d.
    incanters_flow           = { 62118, 1463  , 1 }, -- Magical energy flows through you while in combat, building up to ${$116267m1*5}% increased damage and then diminishing down to $116267s1% increased damage, cycling every 10 sec.
    inspired_intellect       = { 62094, 458437, 1 }, -- Arcane Intellect grants you an additional $s1% Intellect.
    mass_barrier             = { 62092, 414660, 1 }, -- Cast $?c1[Prismatic]?c2[Blazing]?c3[Ice][] Barrier on yourself and $414661i allies within $s2 yds.
    mass_invisibility        = { 62092, 414664, 1 }, -- You and your allies within $A1 yards instantly become invisible for $d. Taking any action will cancel the effect.; $?a415945[]; [Does not affect allies in combat.]
    mass_polymorph           = { 62106, 383121, 1 }, -- Transforms all enemies within $a yards into sheep, wandering around incapacitated for $d. While affected, the victims cannot take actions but will regenerate health very quickly. Damage will cancel the effect.; Only works on Beasts, Humanoids and Critters.
    master_of_time           = { 62102, 342249, 1 }, -- Reduces the cooldown of Alter Time by ${$s1/-1000} sec. ; Alter Time resets the cooldown of Blink and Shimmer when you return to your original location.
    mirror_image             = { 62124, 55342 , 1 }, -- Creates $s2 copies of you nearby for $55342d, which cast spells and attack your enemies.; While your images are active damage taken is reduced by $s3%. Taking direct damage will cause one of your images to dissipate.$?a382820[; You are healed for $382998s1% of your maximum health whenever a Mirror Image dissipates due to direct damage.]?a382569[; Mirror Image's cooldown is reduced by ${$382569s1/1000} sec whenever a Mirror Image dissipates due to direct damage.][]
    overflowing_energy       = { 62120, 390218, 1 }, -- Your spell critical strike damage is increased by $s1%. When your direct damage spells fail to critically strike a target, your spell critical strike chance is increased by $394195s1%, up to ${$394195u*$394195s1}% for $394195d. ; When your spells critically strike Overflowing Energy is reset.
    quick_witted             = { 62104, 382297, 1 }, -- Successfully interrupting an enemy with Counterspell reduces its cooldown by ${$s1/1000} sec.
    reabsorption             = { 62125, 382820, 1 }, -- You are healed for $382998s1% of your maximum health whenever a Mirror Image dissipates due to direct damage.
    reduplication            = { 62125, 382569, 1 }, -- Mirror Image's cooldown is reduced by ${$s1/1000} sec whenever a Mirror Image dissipates due to direct damage.
    remove_curse             = { 62116, 475   , 1 }, -- Removes all Curses from a friendly target. $?s115700[If any Curses are successfully removed, you deal $115701s1% additional damage for $115701d.][]
    rigid_ice                = { 62110, 382481, 1 }, -- Frost Nova can withstand $s1% more damage before breaking.
    ring_of_frost            = { 62088, 113724, 1 }, -- Summons a Ring of Frost for $d at the target location. Enemies entering the ring are incapacitated for $82691d. Limit 10 targets.; When the incapacitate expires, enemies are slowed by $321329s1% for $321329d.
    shifting_power           = { 62113, 382440, 1 }, -- Draw power from within, dealing ${$382445s1*$d/$t} Arcane damage over $d to enemies within $382445A1 yds. ; While channeling, your Mage ability cooldowns are reduced by ${-$s2/1000*$d/$t} sec over $d.
    shimmer                  = { 62105, 212653, 1 }, -- Teleports you $A1 yds forward, unless something is in the way. Unaffected by the global cooldown and castable while casting.$?a382289[; Gain a shield that absorbs $382289s1% of your maximum health for $382290d after you Shimmer.][]
    slow                     = { 62097, 31589 , 1 }, -- Reduces the target's movement speed by $s1% for $d.$?a391102[; Applies to enemies within $391104A1 yds of the target.][] 
    spellsteal               = { 62084, 30449 , 1 }, -- Steals $?s198100[all beneficial magic effects from the target. These effects lasts a maximum of 2 min.][a beneficial magic effect from the target. This effect lasts a maximum of 2 min.] $?s115713[If you successfully steal a spell, you are also healed for $115714s1% of your maximum health.][]
    supernova                = { 101883, 157980, 1 }, -- Pulses arcane energy around the target enemy or ally, dealing $s2 Arcane damage to all enemies within $A2 yds, and knocking them upward. A primary enemy target will take $s1% increased damage.
    tempest_barrier          = { 62111, 382289, 2 }, -- Gain a shield that absorbs $s1% of your maximum health for $382290d after you Blink.
    temporal_velocity        = { 62099, 382826, 2 }, -- Increases your movement speed by $s2% for $384360d after casting Blink and $s1% for $382824d after returning from Alter Time.
    time_anomaly             = { 62094, 383243, 1 }, -- At any moment, you have a chance to gain $?c1[Arcane Surge for $s1 sec, Clearcasting]?c2[Combustion for $s4 sec, 1 Fire Blast charge]?c3[Icy Veins for $s5 sec, Brain Freeze][], or Time Warp for 6 sec.
    time_manipulation        = { 62129, 387807, 1 }, -- Casting $?c1[Clearcasting Arcane Missiles]?c2[Fire Blast]?c3[Ice Lance on Frozen targets][] reduces the cooldown of your loss of control abilities by ${-$s1/1000} sec.
    tome_of_antonidas        = { 62098, 382490, 1 }, -- Increases Haste by $s1%. 
    tome_of_rhonin           = { 62127, 382493, 1 }, -- Increases Critical Strike chance by $s1%.
    volatile_detonation      = { 62089, 389627, 1 }, -- Greatly increases the effect of Blast Wave's knockback. Blast Wave's cooldown is reduced by ${$s1/-1000} sec
    winters_protection       = { 62123, 382424, 2 }, -- The cooldown of Ice Block is reduced by ${$s1/-1000} sec.

    -- Frost Talents
    augury_abounds           = { 94662, 443783, 1 }, -- Casting $?c1[Arcane Surge][Icy Veins] conjures $s1 $?c1[Arcane][Frost] Splinters.; During $?c1[Arcane Surge][Icy Veins], whenever you conjure $?c1[an Arcane][a Frost] Splinter, you have a $s2% chance to conjure an additional $?c1[Arcane][Frost] Splinter.
    bone_chilling            = { 62167, 205027, 1 }, -- Whenever you attempt to chill a target, you gain Bone Chilling, increasing spell damage you deal by ${$m1/10}.1% for $205766d, stacking up to $205766u times.
    brain_freeze             = { 62179, 190447, 1 }, -- Frostbolt has a $m1% chance to reset the remaining cooldown on Flurry and cause your next Flurry to deal $190446s2% increased damage.
    chain_reaction           = { 62161, 278309, 1 }, -- Your Ice Lances against frozen targets increase the damage of your Ice Lances by $s1% for $278310d, stacking up to $278310u times.
    cold_front               = { 62155, 382110, 1 }, -- Casting $s1 Frostbolts or Flurries calls down a Frozen Orb toward your target. Hitting an enemy player counts as double.
    coldest_snap             = { 62185, 417493, 1 }, -- Cone of Cold's cooldown is increased to $s2 sec and if Cone of Cold hits $s3 or more enemies it resets the cooldown of Frozen Orb and Comet Storm. In addition, Cone of Cold applies Winter's Chill to all enemies hit.; Cone of Cold's cooldown can no longer be reduced by your cooldown reduction effects.
    comet_storm              = { 62182, 153595, 1 }, -- Calls down a series of 7 icy comets on and around the target, that deals up to ${7*$153596s1} Frost damage to all enemies within $228601A1 yds of its impacts.
    controlled_instincts     = { 94663, 444483, 1 }, -- $?c1[For 8 seconds after being struck by an Arcane Orb][While a target is under the effects of Blizzard], $?c1[$s1%][$s4%] of the direct damage dealt by $?c1[an Arcane Splinter][a Frost Splinter] is also dealt to nearby enemies. Damage reduced beyond $s5 targets.
    cryopathy                = { 62152, 417491, 1 }, -- Each time you consume Fingers of Frost the damage of your next Ray of Frost is increased by $417492s1%, stacking up to ${$417492s1*$417492u}%. Icy Veins grants $417492u stacks instantly.
    deaths_chill             = { 101302, 450331, 1 }, -- While Icy Veins is active, damaging an enemy with Frostbolt increases spell damage by $454371s1%. Stacks up to $454371u times.
    deep_shatter             = { 62159, 378749, 2 }, -- Your Frostbolt deals $m1% additional damage to Frozen targets.
    elemental_affinity       = { 94633, 431067, 1 }, -- $?c2[The cooldown of Frost spells with a base cooldown shorter than $s4 minutes is reduced by $s1%.]?c3[The cooldown of Fire spells is reduced by $s3%.][]
    everlasting_frost        = { 81468, 385167, 1 }, -- Frozen Orb deals an additional $s1% damage and its duration is increased by ${$s2/1000} sec.
    excess_fire              = { 94637, 438595, 1 }, -- Reaching maximum stacks of Fire Mastery causes your next $?c2[Fire Blast]?c3[Ice Lance][] to apply Living Bomb at $s1% effectiveness.; When this Living Bomb explodes, $?c2[reduce the cooldown of Phoenix Flames by $s2 sec]?c3[gain Brain Freeze][].
    excess_frost             = { 94639, 438600, 1 }, -- Reaching maximum stacks of Frost Mastery causes your next $?c2[Phoenix Flames]?c3[Flurry][] to also cast Ice Nova at $s1% effectiveness.; When you consume Excess Frost, the cooldown of $?c2[Meteor]?c3[Comet Storm][] is reduced by $s2 sec.
    fingers_of_frost         = { 62164, 112965, 1 }, -- Frostbolt has a $s1% chance and Frozen Orb damage has a $s2% to grant a charge of Fingers of Frost.; Fingers of Frost causes your next Ice Lance to deal damage as if the target were frozen.; Maximum $44544s1 charges.
    flame_and_frost          = { 94633, 431112, 1 }, -- $?c2[Cauterize resets the cooldown of your Frost spells with a base cooldown shorter than $s1 minutes when it activates.]?c3[Cold Snap additionally resets the cooldowns of your Fire spells.][]
    flash_freeze             = { 62168, 379993, 1 }, -- Each of your Icicles deals $s2% additional damage, and when an Icicle deals damage you have a $s1% chance to gain the Fingers of Frost effect.
    flash_freezeburn         = { 94635, 431178, 1 }, -- Frostfire Empowerment grants you maximum benefit of Frostfire Mastery and refreshes its duration.; Activating Combustion or Icy Veins grants you Frostfire Empowerment.
    flurry                   = { 62178, 44614 , 1 }, -- Unleash a flurry of ice, striking the target $s1 times for a total of ${$228354s2*$m1} Frost damage. Each hit reduces the target's movement speed by $228354s1% for $228354d$?a378947[, has a $378947s1% chance to activate Glacial Assault,][] and applies Winter's Chill to the target.; Winter's Chill causes the target to take damage from your spells as if it were frozen.
    force_of_will            = { 94656, 444719, 1 }, -- Gain 2% increased critical strike chance.; Gain 5% increased critical strike damage.
    fractured_frost          = { 62151, 378448, 1 }, -- While Icy Veins is active, your Frostbolts hit up to ${$s3-1} additional targets and their damage is increased by $s4%.
    freezing_rain            = { 62150, 270233, 1 }, -- Frozen Orb makes Blizzard instant cast and increases its damage done by $270232s2% for $270232d.
    freezing_winds           = { 62184, 382103, 1 }, -- While Frozen Orb is active, you gain Fingers of Frost every $382106t1 sec.
    frostbite                = { 81467, 378756, 1 }, -- Gives your Chill effects a $h% chance to freeze the target for $378760d.
    frostfire_bolt           = { 94641, 431044, 1 }, -- Launches a bolt of frostfire at the enemy, causing $s1 Frostfire damage, slowing movement speed by $s3%, and causing an additional $o2 Frostfire damage over $d.; Frostfire Bolt generates stacks for both Fire Mastery and Frost Mastery.
    frostfire_empowerment    = { 94632, 431176, 1 }, -- Your Frost and Fire spells have a chance to activate Frostfire Empowerment, causing your next Frostfire Bolt to be instant cast, deal $431177s3% increased damage, explode for $s2% of its damage to nearby enemies, and grant you maximum benefit of Frostfire Mastery and refresh its duration.
    frostfire_infusion       = { 94634, 431166, 1 }, -- Your Frost and Fire spells have a chance to trigger an additional bolt of Frostfire, dealing $431171s1 damage.; This effect generates Frostfire Mastery when activated.
    frostfire_mastery        = { 94636, 431038, 1 }, -- Your damaging Fire spells generate $s1 stack of Fire Mastery and Frost spells generate $s1 stack of Frost Mastery.; Fire Mastery increases your haste by $431040s1%, and Frost Mastery increases your Mastery by $431039s1% for $431039d, stacking up to $431039u times each.; Adding stacks does not refresh duration.
    frozen_orb               = { 62177, 84714 , 1 }, -- Launches an orb of swirling ice up to $s1 yds forward which deals up to ${20*$84721s1} Frost damage to all enemies it passes through over $d. Deals reduced damage beyond $84721s2 targets. Grants 1 charge of Fingers of Frost when it first damages an enemy.$?a382103[; While Frozen Orb is active, you gain Fingers of Frost every $382106t1 sec.][]; Enemies damaged by the Frozen Orb are slowed by $289308s1% for $289308d.
    frozen_touch             = { 62180, 205030, 1 }, -- Frostbolt grants you Fingers of Frost $s1% more often and Brain Freeze $s2% more often.
    glacial_assault          = { 62183, 378947, 1 }, -- Your Comet Storm now increases the damage enemies take from you by $417490s1% for $417490d and Flurry has a $s1% chance each hit to call down an icy comet, crashing into your target and nearby enemies for $379029s1 Frost damage.
    glacial_spike            = { 62157, 199786, 1 }, -- Conjures a massive spike of ice, and merges your current Icicles into it. It impales your target, dealing $228600s1 damage plus all of the damage stored in your Icicles, and freezes the target in place for $228600d. Damage may interrupt the freeze effect.; Requires 5 Icicles to cast.; Passive: Ice Lance no longer launches Icicles.
    hailstones               = { 62158, 381244, 1 }, -- Casting Ice Lance on Frozen targets has a $s1% chance to generate an Icicle.
    ice_barrier              = { 62117, 11426 , 1 }, -- Shields you with ice, absorbing $<shield> damage$?s235297[ and increasing your armor by $s3%][] for $d.; Melee attacks against you reduce the attacker's movement speed by $205708s1%.
    ice_caller               = { 62170, 236662, 1 }, -- Each time Blizzard deals damage, the cooldown of Frozen Orb is reduced by ${$s1/100}.1 sec.
    ice_lance                = { 62176, 30455 , 1 }, -- Quickly fling a shard of ice at the target, dealing $228598s1 Frost damage$?s56377[, and ${$228598s1*$56377m2/100} Frost damage to a second nearby target][].; Ice Lance damage is tripled against frozen targets.
    icy_veins                = { 62171, 12472 , 1 }, -- Accelerates your spellcasting for $d, granting $m1% haste and preventing damage from delaying your spellcasts.; Activating Icy Veins summons a water elemental to your side for its duration. The water elemental's abilities grant you Frigid Empowerment, increasing the Frost damage you deal by $417488s1%, up to ${$417488s1*$417488u}%.
    imbued_warding           = { 94642, 431066, 1 }, -- $?c2[Blazing Barrier also casts an Ice Barrier at $s1% effectiveness.]?c3[Ice Barrier also casts a Blazing Barrier at $s2% effectiveness.][]
    isothermic_core          = { 94638, 431095, 1 }, -- Comet Storm now also calls down a Meteor at $s1% effectiveness onto your target's location.; Meteor now also calls down a Comet Storm at $s2% effectiveness onto your target location.
    lonely_winter            = { 62173, 205024, 1 }, -- Frostbolt, Ice Lance, and Flurry deal $s1% increased damage. 
    look_again               = { 94659, 444756, 1 }, -- Displacement has a $s1% longer duration and $s2% longer range.
    meltdown                 = { 94642, 431131, 1 }, -- You melt slightly out of your Ice Block and Ice Cold, allowing you to move slowly during Ice Block and increasing your movement speed over time.; Ice Block and Ice Cold trigger a Blazing Barrier when they end.
    permafrost_lances        = { 62169, 460590, 1 }, -- Frozen Orb increases Ice Lance's damage by $455122s1% for $455122d.
    perpetual_winter         = { 62181, 378198, 1 }, -- Flurry now has ${$s1+1} charges. 
    phantasmal_image         = { 94660, 444784, 1 }, -- Your Mirror Image summons one extra clone.; Mirror Image now reduces all damage taken by an additional $s2%.
    piercing_cold            = { 62166, 378919, 1 }, -- Frostbolt and $?s199786[Glacial Spike][Icicle] critical strike damage increased by $s1%.
    ray_of_frost             = { 62153, 205021, 1 }, -- Channel an icy beam at the enemy for $d, dealing $s2 Frost damage every $t2 sec and slowing movement by $s4%. Each time Ray of Frost deals damage, its damage and snare increases by $208141s1%.; Generates $s3 charges of Fingers of Frost over its duration.
    reactive_barrier         = { 94660, 444827, 1 }, -- Your $?c1[Prismatic][Ice] Barrier can absorb up to $s1% more damage based on your missing Health.; Max effectiveness when under $s1% health.
    severe_temperatures      = { 94640, 431189, 1 }, -- Casting damaging Frost or Fire spells has a high chance to increase the damage of your next Frostfire Bolt by $431190s1%, stacking up to $431190u times.
    shatter                  = { 62165, 12982 , 1 }, -- Multiplies the critical strike chance of your spells against frozen targets by 1.5, and adds an additional $s2% critical strike chance.
    shifting_shards          = { 94657, 444675, 1 }, -- Shifting Power fires a barrage of $s1 $?c1[Arcane][Frost] Splinters at random enemies within 40 yds over its duration.
    slick_ice                = { 62156, 382144, 1 }, -- While Icy Veins is active, each Frostbolt you cast reduces the cast time of Frostbolt by $382148s1% and increases its damage by $382148s2%, stacking up to $382148u times.
    slippery_slinging        = { 94659, 444752, 1 }, -- You have $s1% increased movement speed during Alter Time$?a236457[ and Evocation][].; 
    spellfrost_teachings     = { 94655, 444986, 1 }, -- Direct damage from $?c1[Arcane][Frost] Splinters has a small chance to $?c1[launch an Arcane Orb at $s1% effectiveness][reset the cooldown of Frozen Orb] and increase all damage dealt by $?c1[Arcane Orb by $458411s1][Frozen Orb by $458411s2]% for $458411d.
    splintering_cold         = { 62162, 379049, 2 }, -- Frostbolt and Flurry have a $s2% chance to generate $s1 Icicles.
    splintering_orbs         = { 94661, 444256, 1 }, -- $?c1[The first enemy][Enemies] damaged by your $?c1[Arcane Orb][Frozen Orb] conjures $?c1[$s4 Arcane Splinters][a Frost Splinter, up to $s1].; $?c1[Arcane Orb][Frozen Orb] damage is increased by $s2%.
    splintering_ray          = { 103771, 418733, 1 }, -- Ray of Frost deals $s1% of its damage to ${$384685i} nearby enemies.
    splintering_sorcery      = { 94664, 443739, 1 }, -- [443763] Conjure raw Arcane magic into a sharp projectile that deals $s1 Arcane damage.; $@spellname443763s embed themselves into their target, dealing $444735o1 Arcane damage over $444735d. This effect stacks.
    splinterstorm            = { 94654, 443742, 1 }, -- Whenever you have $s1 or more active Embedded $?c1[Arcane][Frost] Splinters, you automatically cast a Splinterstorm at your target.; $@spellicon443742$@spellname443742:; Shatter all Embedded $?c1[Arcane][Frost] Splinters, dealing their remaining periodic damage instantly.; Conjure $?c1[an Arcane][a Frost] Splinter for each Splinter shattered, then unleash them all in a devastating barrage, dealing $?c1[$443763s1 Arcane][$443722s1 Frost] damage to your target for each Splinter in the Splinterstorm.$?c1[][; Splinterstorm applies Winter's Chill to its target.]
    splitting_ice            = { 62163, 56377 , 1 }, -- Your Ice Lance and Icicles now deal $s3% increased damage, and hit a second nearby target for $s2% of their damage.; Your Glacial Spike also hits a second nearby target for $s4% of its damage.
    subzero                  = { 62160, 380154, 2 }, -- Your Frost spells deal $s1% more damage to targets that are rooted and frozen.
    thermal_conditioning     = { 94640, 431117, 1 }, -- Frostfire Bolt's cast time is reduced by $s1%.
    thermal_void             = { 62154, 155149, 1 }, -- Icy Veins' duration is increased by ${$s2/1000} sec.; Your Ice Lances against frozen targets extend your Icy Veins by an additional ${$s1/1000}.1 sec$?s199786[ and Glacial Spike extends it an addtional ${$s3/1000}.1 sec][].
    unerring_proficiency     = { 94658, 444974, 1 }, -- Each time you conjure $?c1[an Arcane][a Frost] Splinter, increase the damage of your next $?c1[Supernova by $444981s1%][Ice Nova by $444976s1%].; Stacks up to $?c1[$444981u][$444976u] times.
    volatile_magic           = { 94658, 444968, 1 }, -- Whenever an Embedded $?c1[Arcane][Frost] Splinter is removed, it explodes, dealing $?c1[$444966s1 Arcane][$444967s1 Frost] damage to nearby enemies. Deals reduced damage beyond $s2 targets.
    winters_blessing         = { 62174, 417489, 1 }, -- Your Haste is increased by $s1%.; You gain $s2% more of the Haste stat from all sources.
    wintertide               = { 62172, 378406, 2 }, -- Increases Frostbolt damage by $s1%. Fingers of Frost empowered Ice Lances deal $s2% increased damage to Frozen targets.
} )

-- PvP Talents
spec:RegisterPvpTalents( {
    concentrated_coolness      = 632 , -- (198148) Frozen Orb's damage is increased by $m2% and is now castable at a location with a $198149R yard range but no longer moves. 
    ethereal_blink             = 5600, -- (410939) Blink and Shimmer apply Slow at $s2% effectiveness to all enemies you Blink through. For each enemy you Blink through, the cooldown of Blink and Shimmer are reduced by $s3 sec, up to $s4 sec.
    frost_bomb                 = 5496, -- (390612) Places a Frost Bomb on the target. After $d, the bomb explodes, dealing $390614s1 Frost damage to the target and $390614s2 Frost damage to all other enemies within $390614A2 yards. All affected targets are slowed by $390614s3% for $390614d. ; If Frost Bomb is dispelled before it explodes, gain a charge of Brain Freeze.
    ice_form                   = 634 , -- (198144) Your body turns into Ice, increasing your Frostbolt damage done by $m1% and granting immunity to stun and knockback effects. Lasts $d.
    ice_wall                   = 5390, -- (352278) Conjures an Ice Wall $s3 yards long that obstructs line of sight. The wall has $s4% of your maximum health and lasts up to $d.
    icy_feet                   = 66  , -- (407581) When your Frost Nova or Water Elemental's Freeze is dispelled or removed, become immune to snares for $407582d. ; This effect can only occur once every $407648d.
    improved_mass_invisibility = 5622, -- (415945) The cooldown of Mass Invisibility is reduced by ${$s1/-60000} min and can affect allies in combat.
    master_shepherd            = 5581, -- (410248) While an enemy player is affected by your Polymorph or Mass Polymorph, your movement speed is increased by $410259s1% and your Versatility is increased by $410259s2%. ; Additionally, Polymorph and Mass Polymorph no longer heal enemies.
    ring_of_fire               = 5490, -- (353082) Summons a Ring of Fire for $353103d at the target location. Enemies entering the ring burn for ${$353084s2*3}% of their total health over $353084d.
    snowdrift                  = 5497, -- (389794) Summon a strong Blizzard that surrounds you for $d that slows enemies by $389823s2% and deals $390171s1 Frost damage every $390171d. ; Enemies that are caught in Snowdrift for $389823d consecutively become Frozen in ice, stunned for $389831d.
} )

-- Auras
spec:RegisterAuras( {
    -- Altering Time. Returning to past location and health when duration expires.
    alter_time = {
        id = 110909,
        duration = 10.0,
        max_stack = 1,
    },
    -- Intellect increased by $w1%.
    arcane_intellect = {
        id = 1459,
        duration = 3600.0,
        max_stack = 1,
    },
    -- You are able to comprehend your allies' racial languages.
    arcane_linguist = {
        id = 210086,
        duration = 0.0,
        max_stack = 1,
    },
    -- Movement speed reduced by $s2%.
    blast_wave = {
        id = 157981,
        duration = 6.0,
        max_stack = 1,

        -- Affected by:
        -- frost_mage[137020] #7: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_2_VALUE, }
        -- frost_mage[137020] #8: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'pvp_multiplier': 0.0, 'points': -20.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_2_VALUE, }
        -- frigid_winds[235224] #6: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -10.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_2_VALUE, }
        -- volatile_detonation[389627] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -5000.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
        -- elemental_affinity[431067] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -30.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
        -- arcane_mage[137021] #6: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_2_VALUE, }
        -- arcane_mage[137021] #7: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'pvp_multiplier': 0.0, 'points': -20.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_2_VALUE, }
    },
    -- Blinking.
    blink = {
        id = 1953,
        duration = 0.3,
        max_stack = 1,
    },
    -- Spell damage done increased by ${$W1}.1%.
    bone_chilling = {
        id = 205766,
        duration = 8.0,
        max_stack = 1,
    },
    -- Your next Flurry deals $s2% increased damage.
    brain_freeze = {
        id = 190446,
        duration = 15.0,
        max_stack = 1,
    },
    -- Ice Lance damage increased by $278309s1%.
    chain_reaction = {
        id = 278310,
        duration = 10.0,
        max_stack = 1,
    },
    -- Movement speed reduced by $w1%.
    chilled = {
        id = 205708,
        duration = 8.0,
        max_stack = 1,

        -- Affected by:
        -- frigid_winds[235224] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -10.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_1_VALUE, }
    },
    -- Movement slowed by $s1%.
    cone_of_cold = {
        id = 120,
        duration = 0.0,
        max_stack = 1,

        -- Affected by:
        -- frost_mage[137020] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- frost_mage[137020] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- overflowing_energy[390218] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_15, }
        -- coldest_snap[417493] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 33000.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
        -- elemental_affinity[431067] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -30.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
        -- force_of_will[444719] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'modifies': SHOULD_NEVER_SEE_15, }
        -- shatter[12982] #0: { 'type': APPLY_AURA, 'subtype': OVERRIDE_CLASS_SCRIPTS, 'points': 10.0, 'value': 911, 'schools': ['physical', 'holy', 'fire', 'nature'], 'target': TARGET_UNIT_CASTER, }
        -- bone_chilling[205766] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 1.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- bone_chilling[205766] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 1.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- arcane_mage[137021] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- arcane_mage[137021] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- incanters_flow[116267] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- incanters_flow[116267] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- overflowing_energy[394195] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': CRIT_CHANCE, }
        -- numbing_blast[417490] #0: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'pvp_multiplier': 0.5, 'points': 6.0, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- frigid_empowerment[417488] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.6667, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- frigid_empowerment[417488] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.6667, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
    },
    -- The damage of your next Ray of Frost is increased by $w1%.
    cryopathy = {
        id = 417492,
        duration = 60.0,
        max_stack = 1,
    },
    -- Your spell damage is increased by $s1%.
    deaths_chill = {
        id = 454371,
        duration = 3600,
        max_stack = 1,
    },
    -- Disoriented.
    dragons_breath = {
        id = 31661,
        duration = 4.0,
        max_stack = 1,

        -- Affected by:
        -- frost_mage[137020] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- frost_mage[137020] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- overflowing_energy[390218] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_15, }
        -- elemental_affinity[431067] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -30.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
        -- force_of_will[444719] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'modifies': SHOULD_NEVER_SEE_15, }
        -- shatter[12982] #0: { 'type': APPLY_AURA, 'subtype': OVERRIDE_CLASS_SCRIPTS, 'points': 10.0, 'value': 911, 'schools': ['physical', 'holy', 'fire', 'nature'], 'target': TARGET_UNIT_CASTER, }
        -- bone_chilling[205766] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 1.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- bone_chilling[205766] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 1.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- arcane_mage[137021] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- arcane_mage[137021] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- alexstraszas_fury[235870] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 100000.0, 'target': TARGET_UNIT_CASTER, 'modifies': CRIT_CHANCE, }
        -- alexstraszas_fury[235870] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 50.0, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_15, }
        -- incanters_flow[116267] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- incanters_flow[116267] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- overflowing_energy[394195] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': CRIT_CHANCE, }
        -- numbing_blast[417490] #0: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'pvp_multiplier': 0.5, 'points': 6.0, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- frigid_empowerment[417488] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.6667, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- frigid_empowerment[417488] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.6667, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
    },
    -- Time Warp also increases the rate at which time passes by $s1%.
    echoes_of_elisande = {
        id = 320919,
        duration = 3600,
        max_stack = 1,
    },
    -- Dealing $s1 Arcane damage every $t1 sec.
    embedded_arcane_splinter = {
        id = 444735,
        duration = 18.0,
        tick_time = 1.0,
        max_stack = 1,

        -- Affected by:
        -- mastery_icicles[321684] #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'sp_bonus': 0.75, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
    },
    -- Blink and Shimmer apply Slow at $s2% effectiveness to all enemies you Blink through. For each enemy you Blink through, the cooldown of Blink and Shimmer are reduced by $s3 sec, up to $s4 sec.
    ethereal_blink = {
        id = 410939,
        duration = 0.0,
        max_stack = 1,
    },
    -- Your next Ice Lance deals damage as if the target were frozen.
    fingers_of_frost = {
        id = 44544,
        duration = 15.0,
        max_stack = 1,
    },
    -- Haste increased by $w1%.
    fire_mastery = {
        id = 431040,
        duration = 14.0,
        max_stack = 1,
    },
    -- Movement slowed by $w1%.
    flurry = {
        id = 228354,
        duration = 1.0,
        max_stack = 1,

        -- Affected by:
        -- frigid_winds[235224] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -10.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_1_VALUE, }
        -- lonely_winter[205024] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
    },
    -- Frozen in place.
    freezing_cold = {
        id = 386770,
        duration = 5.0,
        max_stack = 1,
    },
    -- Blizzard is instant cast and deals $s2% increased damage.
    freezing_rain = {
        id = 270232,
        duration = 12.0,
        max_stack = 1,
    },
    -- Gaining Fingers of Frost every $t1 sec.
    freezing_winds = {
        id = 382106,
        duration = 10.0,
        max_stack = 1,

        -- Affected by:
        -- frost_mage[137020] #5: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER_BY_LABEL, 'points': 2000.0, 'target': TARGET_UNIT_CASTER, 'modifies': AURA_PERIOD, }
        -- frost_mage[137020] #6: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER_BY_LABEL, 'pvp_multiplier': 0.0, 'points': -2000.0, 'target': TARGET_UNIT_CASTER, 'modifies': AURA_PERIOD, }
        -- everlasting_frost[385167] #2: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER_BY_LABEL, 'points': 2000.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
    },
    -- Your elemental is empowering you increasing your Frost damage dealt by $s1%.
    frigid_empowerment = {
        id = 417488,
        duration = 60.0,
        max_stack = 1,
    },
    -- Slowed by $s3%.
    frost_bomb = {
        id = 390614,
        duration = 4.0,
        max_stack = 1,

        -- Affected by:
        -- frigid_winds[235224] #2: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -10.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_3_VALUE, }
        -- frigid_winds[235224] #3: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -10.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_4_VALUE, }
    },
    -- Frozen in place.
    frost_nova = {
        id = 122,
        duration = 6.0,
        max_stack = 1,

        -- Affected by:
        -- frost_mage[137020] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- frost_mage[137020] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- ice_ward[205036] #0: { 'type': APPLY_AURA, 'subtype': MOD_MAX_CHARGES, 'points': 1.0, 'target': TARGET_UNIT_CASTER, }
        -- improved_frost_nova[343183] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 2000.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
        -- overflowing_energy[390218] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_15, }
        -- elemental_affinity[431067] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -30.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
        -- force_of_will[444719] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'modifies': SHOULD_NEVER_SEE_15, }
        -- shatter[12982] #0: { 'type': APPLY_AURA, 'subtype': OVERRIDE_CLASS_SCRIPTS, 'points': 10.0, 'value': 911, 'schools': ['physical', 'holy', 'fire', 'nature'], 'target': TARGET_UNIT_CASTER, }
        -- bone_chilling[205766] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 1.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- bone_chilling[205766] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 1.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- arcane_mage[137021] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- arcane_mage[137021] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- incanters_flow[116267] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- incanters_flow[116267] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- overflowing_energy[394195] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': CRIT_CHANCE, }
        -- numbing_blast[417490] #0: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'pvp_multiplier': 0.5, 'points': 6.0, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- frigid_empowerment[417488] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.6667, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- frigid_empowerment[417488] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.6667, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
    },
    -- Frozen.
    frostbite = {
        id = 378760,
        duration = 4.0,
        max_stack = 1,
    },
    -- Movement speed reduced by $w3% and receiving $w2 damage every $t2 sec.
    frostfire_bolt = {
        id = 431044,
        duration = 8.0,
        tick_time = 1.0,
        max_stack = 1,

        -- Affected by:
        -- frigid_winds[235224] #8: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -10.0, 'modifies': EFFECT_3_VALUE, }
        -- lonely_winter[205024] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- piercing_cold[378919] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.5, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_15, }
        -- thermal_conditioning[431117] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -10.0, 'target': TARGET_UNIT_CASTER, 'modifies': CAST_TIME, }
        -- wintertide[378406] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- ice_form[198144] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 30.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- frostfire_empowerment[431177] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 100000.0, 'target': TARGET_UNIT_CASTER, 'modifies': CRIT_CHANCE, }
        -- frostfire_empowerment[431177] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': CAST_TIME, }
        -- frostfire_empowerment[431177] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 50.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- severe_temperatures[431190] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- slick_ice[382148] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -4.0, 'target': TARGET_UNIT_CASTER, 'modifies': CAST_TIME, }
        -- slick_ice[382148] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -4.0, 'target': TARGET_UNIT_CASTER, 'modifies': GLOBAL_COOLDOWN, }
        -- slick_ice[382148] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 4.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
    },
    -- Your next Frostfire Bolt always critically strikes, deals $s3% additional damage, explodes for $431176s2% of its damage to nearby enemies, and is instant cast.
    frostfire_empowerment = {
        id = 431177,
        duration = 20.0,
        max_stack = 1,
    },
    -- Movement slowed by $s1%.
    frozen_orb = {
        id = 84721,
        duration = 0.0,
        max_stack = 1,

        -- Affected by:
        -- mastery_icicles[76613] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- frost_mage[137020] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- frost_mage[137020] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- mastery_icicles[321684] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 1.125, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- overflowing_energy[390218] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_15, }
        -- everlasting_frost[385167] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 30.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- force_of_will[444719] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'modifies': SHOULD_NEVER_SEE_15, }
        -- shatter[12982] #0: { 'type': APPLY_AURA, 'subtype': OVERRIDE_CLASS_SCRIPTS, 'points': 10.0, 'value': 911, 'schools': ['physical', 'holy', 'fire', 'nature'], 'target': TARGET_UNIT_CASTER, }
        -- splintering_orbs[444256] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- concentrated_coolness[198148] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- bone_chilling[205766] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 1.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- bone_chilling[205766] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 1.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- arcane_mage[137021] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- arcane_mage[137021] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- incanters_flow[116267] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- incanters_flow[116267] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- overflowing_energy[394195] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': CRIT_CHANCE, }
        -- numbing_blast[417490] #0: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'pvp_multiplier': 0.5, 'points': 6.0, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- frigid_empowerment[417488] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.6667, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- frigid_empowerment[417488] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.6667, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- spellfrost_teachings[458411] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- spellfrost_teachings[458411] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
    },
    -- Frozen in place.
    glacial_spike = {
        id = 228600,
        duration = 4.0,
        max_stack = 1,

        -- Affected by:
        -- mastery_icicles[321684] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 0.75, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- piercing_cold[378919] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.5, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_15, }
    },
    -- Invisible$?$w3=0[][ and moving $87833s1% faster].
    greater_invisibility = {
        id = 110960,
        duration = 20.0,
        max_stack = 1,
    },
    -- Absorbs $w1 damage.; Melee attackers slowed by $205708s1%.$?s235297[; Armor increased by $s3%.][]
    ice_barrier = {
        id = 414661,
        duration = 60.0,
        max_stack = 1,

        -- Affected by:
        -- accumulative_shielding[382800] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 30.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_4_VALUE, }
        -- ice_barrier[11426] #3: { 'type': APPLY_AURA, 'subtype': ABILITY_PERIODIC_CRIT, 'target': TARGET_UNIT_CASTER, }
        -- ice_barrier[414661] #3: { 'type': APPLY_AURA, 'subtype': ABILITY_PERIODIC_CRIT, 'radius': 100.0, 'target': TARGET_DEST_CASTER, 'target2': TARGET_UNIT_DEST_AREA_ALLY, }
    },
    -- Immune to all attacks and damage.; Cannot attack, move, or use spells.
    ice_block = {
        id = 45438,
        duration = 10.0,
        pandemic = true,
        max_stack = 1,

        -- Affected by:
        -- cryofreeze[382292] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 4.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_4_VALUE, }
        -- winters_protection[382424] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -30000.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
    },
    -- Damage taken reduced by $s8%.
    ice_cold = {
        id = 414658,
        duration = 6.0,
        pandemic = true,
        max_stack = 1,

        -- Affected by:
        -- cryofreeze[382292] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 4.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_4_VALUE, }
        -- winters_protection[382424] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -30000.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
    },
    -- Able to move while casting spells.
    ice_floes = {
        id = 108839,
        duration = 15.0,
        max_stack = 1,
    },
    -- Frostbolt damage done increased by $m1%. Immune to stun and knockback effects.
    ice_form = {
        id = 198144,
        duration = 12.0,
        max_stack = 1,

        -- Affected by:
        -- thermal_void[155149] #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 5000.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
    },
    -- Frozen.
    ice_nova = {
        id = 157997,
        duration = 2.0,
        max_stack = 1,

        -- Affected by:
        -- elemental_affinity[431067] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -30.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
    },
    -- Immune to snares.
    icy_feet = {
        id = 407582,
        duration = 3.0,
        max_stack = 1,
    },
    -- Haste increased by $w1% and immune to pushback.
    icy_veins = {
        id = 12472,
        duration = 25.0,
        max_stack = 1,

        -- Affected by:
        -- thermal_void[155149] #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 5000.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
    },
    -- A faint shimmer surrounds you.
    illusion = {
        id = 94632,
        duration = 120.0,
        max_stack = 1,
    },
    -- Movement speed increased by $w%
    incantation_of_swiftness = {
        id = 337278,
        duration = 6.0,
        max_stack = 1,
    },
    -- Increases spell damage by $w1%.
    incanters_flow = {
        id = 116267,
        duration = 25.0,
        max_stack = 1,
    },
    -- Invisible$?$w3=0[][ and moving $87833s1% faster].
    invisibility = {
        id = 32612,
        duration = 20.0,
        max_stack = 1,
    },
    -- Increases your mana regeneration by $s1%.
    mana_attunement = {
        id = 121039,
        duration = 0.0,
        max_stack = 1,
    },
    -- Reduces movement speed by $s1%.
    mark_of_aluneth = {
        id = 211056,
        duration = 6.0,
        max_stack = 1,
    },
    -- Invisible. Taking any action will cancel the effect.
    mass_invisibility = {
        id = 414664,
        duration = 12.0,
        max_stack = 1,

        -- Affected by:
        -- improved_mass_invisibility[415945] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -240000.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
    },
    -- Incapacitated. Cannot attack or cast spells.  Increased health regeneration.
    mass_polymorph = {
        id = 383121,
        duration = 15.0,
        max_stack = 1,
    },
    -- Movement speed reduced by $w1%.
    mass_slow = {
        id = 391104,
        duration = 15.0,
        max_stack = 1,

        -- Affected by:
        -- frigid_winds[235224] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -10.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_1_VALUE, }
    },
    -- Movement speed is increased by $s1% and your Versatility is increased by $s2%.
    master_shepherd = {
        id = 410259,
        duration = 3600,
        max_stack = 1,
    },
    -- Damage taken is reduced by $s3% while your images are active.
    mirror_image = {
        id = 55342,
        duration = 40.0,
        max_stack = 1,

        -- Affected by:
        -- phantasmal_image[444784] #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER_BY_LABEL, 'points': -5.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_3_VALUE, }
    },
    -- Deals $w1 Arcane damage and an additional $w1 Arcane damage to all enemies within $114954A1 yards every $t sec.
    nether_tempest = {
        id = 114923,
        duration = 12.0,
        tick_time = 1.0,
        pandemic = true,
        max_stack = 1,

        -- Affected by:
        -- frost_mage[137020] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- frost_mage[137020] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- overflowing_energy[390218] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_15, }
        -- force_of_will[444719] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'modifies': SHOULD_NEVER_SEE_15, }
        -- shatter[12982] #0: { 'type': APPLY_AURA, 'subtype': OVERRIDE_CLASS_SCRIPTS, 'points': 10.0, 'value': 911, 'schools': ['physical', 'holy', 'fire', 'nature'], 'target': TARGET_UNIT_CASTER, }
        -- bone_chilling[205766] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 1.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- bone_chilling[205766] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 1.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- arcane_mage[137021] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- arcane_mage[137021] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- incanters_flow[116267] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- incanters_flow[116267] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- overflowing_energy[394195] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': CRIT_CHANCE, }
        -- numbing_blast[417490] #0: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'pvp_multiplier': 0.5, 'points': 6.0, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- frigid_empowerment[417488] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.6667, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- frigid_empowerment[417488] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.6667, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
    },
    -- Damage taken from $@auracaster's spells increased by $s1%
    numbing_blast = {
        id = 417490,
        duration = 6.0,
        max_stack = 1,
    },
    -- Spell critical strike chance increased by $w1%.
    overflowing_energy = {
        id = 394195,
        duration = 8.0,
        max_stack = 1,
    },
    -- The damage of Ice Lance is increased by $s1%.
    permafrost_lances = {
        id = 455122,
        duration = 15.0,
        max_stack = 1,
    },
    -- Incapacitated. Cannot attack or cast spells.  Increased health regeneration.
    polymorph = {
        id = 460392,
        duration = 60.0,
        max_stack = 1,
    },
    -- Ray of Frost's damage increased by $s1%.; Ray of Frost's snare increased by $s2%.
    ray_of_frost = {
        id = 208141,
        duration = 10.0,
        max_stack = 1,
    },
    -- Incapacitated.
    ring_of_frost = {
        id = 82691,
        duration = 10.0,
        max_stack = 1,

        -- Affected by:
        -- elemental_affinity[431067] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -30.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
    },
    -- The damage of your next Frostfire Bolt is increased by $w1%.
    severe_temperatures = {
        id = 431190,
        duration = 15.0,
        max_stack = 1,
    },
    -- Every $t1 sec, deal $382445s1 Arcane damage to enemies within $382445A1 yds and reduce the remaining cooldown of your abilities by ${-$s2/1000} sec.
    shifting_power = {
        id = 382440,
        duration = 4.0,
        max_stack = 1,
    },
    -- Shimmering.
    shimmer = {
        id = 212653,
        duration = 0.65,
        max_stack = 1,
    },
    -- Cast time of Frostbolt reduced by $s1% and its damage is increased by $s2%.
    slick_ice = {
        id = 382148,
        duration = 60.0,
        max_stack = 1,
    },
    -- Movement speed reduced by $w1%.
    slow = {
        id = 31589,
        duration = 15.0,
        max_stack = 1,

        -- Affected by:
        -- frigid_winds[235224] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -10.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_1_VALUE, }
    },
    -- Slows falling speed.
    slow_fall = {
        id = 130,
        duration = 30.0,
        max_stack = 1,
    },
    -- Slowed by $s2%. If this effect lasts $d, become Stunned and Frozen.
    snowdrift = {
        id = 389823,
        duration = 2.0,
        max_stack = 1,

        -- Affected by:
        -- frigid_winds[235224] #4: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER_BY_LABEL, 'points': -10.0, 'modifies': EFFECT_2_VALUE, }
    },
    -- $?c1[Arcane Orb][Frozen Orb] damage increased by $s1%.
    spellfrost_teachings = {
        id = 458411,
        duration = 10.0,
        max_stack = 1,
    },
    -- Absorbs $w1 damage.
    tempest_barrier = {
        id = 382290,
        duration = 15.0,
        max_stack = 1,
    },
    -- Movement speed increased by $w1%.
    temporal_velocity = {
        id = 384360,
        duration = 3.0,
        max_stack = 1,
    },
    -- Haste increased by $w1%. $?$W4>0[Time rate increased by $w4%.][]$?$W3=1[; When the effect ends, all affected players are frozen in time for $356346d.][]
    time_warp = {
        id = 80353,
        duration = 40.0,
        max_stack = 1,

        -- Affected by:
        -- echoes_of_elisande[320919] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 30.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_4_VALUE, }
    },
    -- Frozen in time for $d.
    timebreakers_paradox = {
        id = 356346,
        duration = 8.0,
        max_stack = 1,
    },
    -- Supernova damage increased by $w1%.
    unerring_proficiency = {
        id = 444981,
        duration = 60.0,
        max_stack = 1,
    },
} )

-- Abilities
spec:RegisterAbilities( {
    -- Alters the fabric of time, returning you to your current location and health when cast a second time, or after ${$110909d+$s3} sec.  Effect negated by long distance or death.
    alter_time = {
        id = 342245,
        cast = 0.0,
        cooldown = 60.0,
        gcd = "none",

        spend = 0.010,
        spendType = 'mana',

        talent = "alter_time",
        startsCombat = false,

        -- Effects:
        -- #0: { 'type': SUMMON, 'subtype': NONE, 'value': 58542, 'schools': ['holy', 'fire', 'nature', 'shadow'], 'value1': 3189, 'target': TARGET_DEST_CASTER, 'target2': TARGET_DEST_DEST, }
        -- #1: { 'type': TRIGGER_SPELL, 'subtype': NONE, 'trigger_spell': 342246, 'target': TARGET_UNIT_CASTER, }
        -- #2: { 'type': DUMMY, 'subtype': NONE, }

        -- Affected by:
        -- master_of_time[342249] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER_BY_LABEL, 'points': -10000.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
    },

    -- Creates a portal, teleporting group members that use it to Dalaran.
    ancient_portal_dalaran = {
        id = 120146,
        cast = 10.0,
        cooldown = 60.0,
        gcd = "global",

        spend = 0.040,
        spendType = 'mana',

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': TRANS_DOOR, 'subtype': NONE, 'value': 211835, 'schools': ['physical', 'holy', 'nature', 'frost', 'shadow', 'arcane'], 'radius': 3.0, 'target': TARGET_DEST_CASTER_FRONT, }
    },

    -- Teleports you to Dalaran.
    ancient_teleport_dalaran = {
        id = 120145,
        cast = 10.0,
        cooldown = 0.0,
        gcd = "global",

        spend = 0.030,
        spendType = 'mana',

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': TELEPORT_UNITS, 'subtype': NONE, 'amplitude': 1.0, 'target': TARGET_UNIT_CASTER, 'target2': TARGET_DEST_DB, }
        -- #1: { 'type': SCRIPT_EFFECT, 'subtype': NONE, 'sp_bonus': 0.25, 'target': TARGET_UNIT_CASTER, }
    },

    -- Causes an explosion of magic around the caster, dealing $s2 Arcane damage to all enemies within $A2 yards.$?a137021[; Generates $s1 Arcane Charge if any targets are hit.][]
    arcane_explosion = {
        id = 1449,
        cast = 0.0,
        cooldown = 0.0,
        gcd = "global",

        spend = 0.100,
        spendType = 'mana',

        startsCombat = true,

        -- Effects:
        -- #0: { 'type': ENERGIZE, 'subtype': NONE, 'points': 1.0, 'target': TARGET_UNIT_CASTER, 'resource': arcane_charges, }
        -- #1: { 'type': SCHOOL_DAMAGE, 'subtype': NONE, 'sp_bonus': 0.57171, 'variance': 0.05, 'radius': 10.0, 'target': TARGET_SRC_CASTER, 'target2': TARGET_UNIT_SRC_AREA_ENEMY, }
        -- #2: { 'type': ENERGIZE, 'subtype': NONE, 'points': 1.0, 'target': TARGET_UNIT_CASTER, 'resource': arcane_charges, }

        -- Affected by:
        -- frost_mage[137020] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- frost_mage[137020] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- overflowing_energy[390218] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_15, }
        -- force_of_will[444719] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'modifies': SHOULD_NEVER_SEE_15, }
        -- shatter[12982] #0: { 'type': APPLY_AURA, 'subtype': OVERRIDE_CLASS_SCRIPTS, 'points': 10.0, 'value': 911, 'schools': ['physical', 'holy', 'fire', 'nature'], 'target': TARGET_UNIT_CASTER, }
        -- bone_chilling[205766] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 1.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- bone_chilling[205766] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 1.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- arcane_mage[137021] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- arcane_mage[137021] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- incanters_flow[116267] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- incanters_flow[116267] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- overflowing_energy[394195] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': CRIT_CHANCE, }
        -- numbing_blast[417490] #0: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'pvp_multiplier': 0.5, 'points': 6.0, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- frigid_empowerment[417488] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.6667, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- frigid_empowerment[417488] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.6667, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
    },

    -- Infuses the target with brilliance, increasing their Intellect by $s1% for $d.  ; If the target is in your party or raid, all party and raid members will be affected.
    arcane_intellect = {
        id = 1459,
        cast = 0.0,
        cooldown = 0.0,
        gcd = "global",

        spend = 0.040,
        spendType = 'mana',

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': MOD_TOTAL_STAT_PERCENTAGE, 'points': 5.0, 'radius': 100.0, 'target': TARGET_UNIT_TARGET_ALLY_OR_RAID, 'modifies': unknown, }
    },

    -- Causes an explosion around yourself, dealing $s1 Fire damage to all enemies within $A1 yds, knocking them back, and reducing movement speed by $s2% for $d.
    blast_wave = {
        id = 157981,
        cast = 0.0,
        cooldown = 30.0,
        gcd = "global",

        talent = "blast_wave",
        startsCombat = true,

        -- Effects:
        -- #0: { 'type': SCHOOL_DAMAGE, 'subtype': NONE, 'sp_bonus': 0.543375, 'variance': 0.05, 'radius': 8.0, 'target': TARGET_DEST_CASTER, 'target2': TARGET_UNIT_DEST_AREA_ENEMY, }
        -- #1: { 'type': APPLY_AURA, 'subtype': MOD_DECREASE_SPEED, 'mechanic': snared, 'points': -70.0, 'radius': 8.0, 'target': TARGET_DEST_CASTER, 'target2': TARGET_UNIT_DEST_AREA_ENEMY, }

        -- Affected by:
        -- frost_mage[137020] #7: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_2_VALUE, }
        -- frost_mage[137020] #8: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'pvp_multiplier': 0.0, 'points': -20.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_2_VALUE, }
        -- frigid_winds[235224] #6: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -10.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_2_VALUE, }
        -- volatile_detonation[389627] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -5000.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
        -- elemental_affinity[431067] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -30.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
        -- arcane_mage[137021] #6: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_2_VALUE, }
        -- arcane_mage[137021] #7: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'pvp_multiplier': 0.0, 'points': -20.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_2_VALUE, }
    },

    -- Teleports you forward $A1 yds or until reaching an obstacle, and frees you from all stuns and bonds.$?a382289[; Gain a shield that absorbs $382289s1% of your maximum health for $382290d after you Blink.][]
    blink = {
        id = 1953,
        cast = 0.0,
        cooldown = 0.5,
        gcd = "global",

        spend = 0.020,
        spendType = 'mana',

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': LEAP, 'subtype': NONE, 'radius': 20.0, 'target': TARGET_UNIT_CASTER, 'target2': TARGET_DEST_CASTER_FRONT_LEAP, }
        -- #1: { 'type': APPLY_AURA, 'subtype': MECHANIC_IMMUNITY, 'sp_bonus': 0.25, 'target': TARGET_UNIT_CASTER, 'mechanic': 12, }
        -- #2: { 'type': APPLY_AURA, 'subtype': MECHANIC_IMMUNITY, 'sp_bonus': 0.25, 'target': TARGET_UNIT_CASTER, 'mechanic': 7, }
    },

    -- Ice shards pelt the target area, dealing ${$190357m1*8} Frost damage over $d and reducing movement speed by $12486s1% for $12486d.$?a236662[; Each time Blizzard deals damage, the cooldown of Frozen Orb is reduced by ${$236662s1/100}.2 sec.][]
    blizzard = {
        id = 190356,
        cast = 2.0,
        cooldown = 8.0,
        gcd = "global",

        spend = 0.025,
        spendType = 'mana',

        startsCombat = true,

        -- Effects:
        -- #0: { 'type': DUMMY, 'subtype': NONE, 'radius': 8.0, 'target': TARGET_DEST_DEST, 'target2': TARGET_UNIT_DEST_AREA_ENEMY, }
        -- #1: { 'type': CREATE_AREATRIGGER, 'subtype': NONE, 'points': 50.0, 'value': 4658, 'schools': ['holy', 'frost', 'shadow'], 'radius': 8.0, 'target': TARGET_DEST_DEST, 'target2': TARGET_UNIT_DEST_AREA_ENEMY, }

        -- Affected by:
        -- mastery_icicles[321684] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 1.125, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- mage[137018] #0: { 'type': APPLY_AURA, 'subtype': MOD_COOLDOWN_BY_HASTE_REGEN, 'target': TARGET_UNIT_CASTER, }
        -- freezing_rain[270232] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': CAST_TIME, }
        -- freezing_rain[270232] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 60.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
    },

    -- Resets the cooldown of your Ice Barrier, Frost Nova, $?a417493[][Cone of Cold, ]Ice Cold, and Ice Block.
    cold_snap = {
        id = 235219,
        cast = 0.0,
        cooldown = 300.0,
        gcd = "none",

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': SCRIPT_EFFECT, 'subtype': NONE, 'points': 1.0, 'target': TARGET_UNIT_CASTER, }
    },

    -- Calls down a series of 7 icy comets on and around the target, that deals up to ${7*$153596s1} Frost damage to all enemies within $228601A1 yds of its impacts.
    comet_storm = {
        id = 153595,
        cast = 0.0,
        cooldown = 30.0,
        gcd = "global",

        spend = 0.010,
        spendType = 'mana',

        talent = "comet_storm",
        startsCombat = true,

        -- Effects:
        -- #0: { 'type': DUMMY, 'subtype': NONE, 'target': TARGET_DEST_TARGET_ENEMY, 'target2': TARGET_UNIT_TARGET_ENEMY, }

        -- Affected by:
        -- mastery_icicles[321684] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 1.125, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
    },

    -- Targets in a cone in front of you take $s1 Frost damage and $?a386763[are frozen in place for $386770d][have movement slowed by $212792m1% for $212792d].
    cone_of_cold = {
        id = 120,
        cast = 0.0,
        cooldown = 12.0,
        gcd = "global",

        spend = 0.040,
        spendType = 'mana',

        startsCombat = true,

        -- Effects:
        -- #0: { 'type': SCHOOL_DAMAGE, 'subtype': NONE, 'sp_bonus': 0.43125, 'variance': 0.05, 'radius': 12.0, 'target': TARGET_UNIT_CONE_CASTER_TO_DEST_ENEMY, }

        -- Affected by:
        -- frost_mage[137020] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- frost_mage[137020] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- overflowing_energy[390218] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_15, }
        -- coldest_snap[417493] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 33000.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
        -- elemental_affinity[431067] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -30.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
        -- force_of_will[444719] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'modifies': SHOULD_NEVER_SEE_15, }
        -- shatter[12982] #0: { 'type': APPLY_AURA, 'subtype': OVERRIDE_CLASS_SCRIPTS, 'points': 10.0, 'value': 911, 'schools': ['physical', 'holy', 'fire', 'nature'], 'target': TARGET_UNIT_CASTER, }
        -- bone_chilling[205766] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 1.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- bone_chilling[205766] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 1.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- arcane_mage[137021] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- arcane_mage[137021] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- incanters_flow[116267] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- incanters_flow[116267] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- overflowing_energy[394195] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': CRIT_CHANCE, }
        -- numbing_blast[417490] #0: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'pvp_multiplier': 0.5, 'points': 6.0, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- frigid_empowerment[417488] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.6667, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- frigid_empowerment[417488] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.6667, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
    },

    -- Conjures mana food for you and your allies. Conjured items disappear if logged out for more than 15 minutes.
    conjure_refreshment = {
        id = 190336,
        cast = 3.0,
        cooldown = 15.0,
        gcd = "global",

        spend = 0.030,
        spendType = 'mana',

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': DUMMY, 'subtype': NONE, 'target': TARGET_UNIT_CASTER, }
    },

    -- Counters the enemy's spellcast, preventing any spell from that school of magic from being cast for $d$?s12598[ and silencing the target for $55021d][].
    counterspell = {
        id = 2139,
        cast = 0.0,
        cooldown = 24.0,
        gcd = "none",

        spend = 0.020,
        spendType = 'mana',

        startsCombat = true,
        interrupt = true,

        -- Effects:
        -- #0: { 'type': INTERRUPT_CAST, 'subtype': NONE, 'target': TARGET_UNIT_TARGET_ENEMY, }
    },

    -- Teleports you back to where you last Blinked and heals you for ${$414462s1/100*$mhp} health. Only usable within $389714d of Blinking.
    displacement = {
        id = 389713,
        cast = 0.0,
        cooldown = 45.0,
        gcd = "global",

        talent = "displacement",
        startsCombat = false,

        -- Effects:
        -- #0: { 'type': DUMMY, 'subtype': NONE, 'target': TARGET_UNIT_CASTER, }

        -- Affected by:
        -- look_again[444756] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 50.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
        -- look_again[444756] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 25.0, 'target': TARGET_UNIT_CASTER, 'modifies': RANGE, }
    },

    -- Enemies in a cone in front of you take $s2 Fire damage and are disoriented for $d. Damage will cancel the effect.$?a235870[; Always deals a critical strike and contributes to Hot Streak.][]
    dragons_breath = {
        id = 31661,
        cast = 0.0,
        cooldown = 45.0,
        gcd = "global",

        spend = 0.040,
        spendType = 'mana',

        talent = "dragons_breath",
        startsCombat = true,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': MOD_CONFUSE, 'attributes': ['Area Effects Use Target Radius'], 'mechanic': disoriented, 'radius': 12.0, 'target': TARGET_UNIT_CONE_CASTER_TO_DEST_ENEMY, }
        -- #1: { 'type': SCHOOL_DAMAGE, 'subtype': NONE, 'attributes': ['Area Effects Use Target Radius'], 'sp_bonus': 0.6699, 'pvp_multiplier': 1.16, 'variance': 0.05, 'radius': 12.0, 'target': TARGET_UNIT_CONE_CASTER_TO_DEST_ENEMY, }

        -- Affected by:
        -- frost_mage[137020] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- frost_mage[137020] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- overflowing_energy[390218] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_15, }
        -- elemental_affinity[431067] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -30.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
        -- force_of_will[444719] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'modifies': SHOULD_NEVER_SEE_15, }
        -- shatter[12982] #0: { 'type': APPLY_AURA, 'subtype': OVERRIDE_CLASS_SCRIPTS, 'points': 10.0, 'value': 911, 'schools': ['physical', 'holy', 'fire', 'nature'], 'target': TARGET_UNIT_CASTER, }
        -- bone_chilling[205766] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 1.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- bone_chilling[205766] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 1.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- arcane_mage[137021] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- arcane_mage[137021] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- alexstraszas_fury[235870] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 100000.0, 'target': TARGET_UNIT_CASTER, 'modifies': CRIT_CHANCE, }
        -- alexstraszas_fury[235870] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 50.0, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_15, }
        -- incanters_flow[116267] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- incanters_flow[116267] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- overflowing_energy[394195] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': CRIT_CHANCE, }
        -- numbing_blast[417490] #0: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'pvp_multiplier': 0.5, 'points': 6.0, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- frigid_empowerment[417488] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.6667, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- frigid_empowerment[417488] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.6667, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
    },

    -- Deals $228599s1 Shadowfrost damage and causes Brain Freeze.
    ebonbolt = {
        id = 214634,
        color = 'artifact',
        cast = 3.0,
        cooldown = 45.0,
        gcd = "global",

        startsCombat = true,

        -- Effects:
        -- #0: { 'type': TRIGGER_MISSILE, 'subtype': NONE, 'trigger_spell': 228599, 'points': 1.0, 'target': TARGET_UNIT_TARGET_ENEMY, }
    },

    -- Blasts the enemy for $s1 Fire damage.$?a231568[; Fire: Always deals a critical strike.][]
    fire_blast = {
        id = 319836,
        cast = 0.0,
        cooldown = 0.5,
        gcd = "global",

        spend = 0.010,
        spendType = 'mana',

        startsCombat = true,

        -- Effects:
        -- #0: { 'type': SCHOOL_DAMAGE, 'subtype': NONE, 'sp_bonus': 0.828, 'variance': 0.05, 'target': TARGET_UNIT_TARGET_ENEMY, }

        -- Affected by:
        -- elemental_affinity[431067] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -30.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
        -- fire_blast[231568] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 100.0, 'target': TARGET_UNIT_CASTER, 'modifies': CRIT_CHANCE, }
    },

    -- Unleash a flurry of ice, striking the target $s1 times for a total of ${$228354s2*$m1} Frost damage. Each hit reduces the target's movement speed by $228354s1% for $228354d$?a378947[, has a $378947s1% chance to activate Glacial Assault,][] and applies Winter's Chill to the target.; Winter's Chill causes the target to take damage from your spells as if it were frozen.
    flurry = {
        id = 44614,
        cast = 0.0,
        cooldown = 0.0,
        gcd = "global",

        spend = 0.010,
        spendType = 'mana',

        talent = "flurry",
        startsCombat = true,

        -- Effects:
        -- #0: { 'type': DUMMY, 'subtype': NONE, 'mechanic': snared, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #1: { 'type': TRIGGER_MISSILE, 'subtype': NONE, 'trigger_spell': 228354, 'variance': 0.1, 'target': TARGET_UNIT_TARGET_ENEMY, }

        -- Affected by:
        -- ice_floes[108839] #0: { 'type': APPLY_AURA, 'subtype': CAST_WHILE_WALKING, 'target': TARGET_UNIT_CASTER, }
        -- perpetual_winter[378198] #0: { 'type': APPLY_AURA, 'subtype': MOD_MAX_CHARGES, 'points': 1.0, 'target': TARGET_UNIT_CASTER, }
        -- brain_freeze[190446] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 50.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
    },

    -- Places a Frost Bomb on the target. After $d, the bomb explodes, dealing $390614s1 Frost damage to the target and $390614s2 Frost damage to all other enemies within $390614A2 yards. All affected targets are slowed by $390614s3% for $390614d. ; If Frost Bomb is dispelled before it explodes, gain a charge of Brain Freeze.
    frost_bomb = {
        id = 390612,
        cast = 1.5,
        cooldown = 15.0,
        gcd = "global",

        spend = 0.013,
        spendType = 'mana',

        startsCombat = true,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': DUMMY, 'target': TARGET_UNIT_TARGET_ENEMY, }

        -- Affected by:
        -- frigid_winds[235224] #2: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -10.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_3_VALUE, }
        -- frigid_winds[235224] #3: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -10.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_4_VALUE, }
    },

    -- Blasts enemies within $A2 yds of you for $s2 Frost damage and freezes them in place for $d. Damage may interrupt the freeze effect.
    frost_nova = {
        id = 122,
        cast = 0.0,
        cooldown = 0.0,
        gcd = "global",

        spend = 0.020,
        spendType = 'mana',

        startsCombat = true,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': MOD_ROOT_2, 'mechanic': rooted, 'radius': 12.0, 'target': TARGET_SRC_CASTER, 'target2': TARGET_UNIT_SRC_AREA_ENEMY, }
        -- #1: { 'type': SCHOOL_DAMAGE, 'subtype': NONE, 'sp_bonus': 0.05149, 'variance': 0.05, 'radius': 12.0, 'target': TARGET_SRC_CASTER, 'target2': TARGET_UNIT_SRC_AREA_ENEMY, }

        -- Affected by:
        -- frost_mage[137020] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- frost_mage[137020] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- ice_ward[205036] #0: { 'type': APPLY_AURA, 'subtype': MOD_MAX_CHARGES, 'points': 1.0, 'target': TARGET_UNIT_CASTER, }
        -- improved_frost_nova[343183] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 2000.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
        -- overflowing_energy[390218] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_15, }
        -- elemental_affinity[431067] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -30.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
        -- force_of_will[444719] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'modifies': SHOULD_NEVER_SEE_15, }
        -- shatter[12982] #0: { 'type': APPLY_AURA, 'subtype': OVERRIDE_CLASS_SCRIPTS, 'points': 10.0, 'value': 911, 'schools': ['physical', 'holy', 'fire', 'nature'], 'target': TARGET_UNIT_CASTER, }
        -- bone_chilling[205766] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 1.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- bone_chilling[205766] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 1.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- arcane_mage[137021] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- arcane_mage[137021] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- incanters_flow[116267] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- incanters_flow[116267] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- overflowing_energy[394195] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': CRIT_CHANCE, }
        -- numbing_blast[417490] #0: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'pvp_multiplier': 0.5, 'points': 6.0, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- frigid_empowerment[417488] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.6667, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- frigid_empowerment[417488] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.6667, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
    },

    -- Launches a bolt of frost at the enemy, causing $228597s1 Frost damage and slowing movement speed by $205708s1% for $205708d.$?a378749[; Frostbolt deals $378749m1% additional damage to Frozen targets.][]
    frostbolt = {
        id = 116,
        cast = 2.0,
        cooldown = 0.0,
        gcd = "global",

        spend = 0.020,
        spendType = 'mana',

        startsCombat = true,

        -- Effects:
        -- #0: { 'type': TRIGGER_MISSILE, 'subtype': NONE, 'attributes': ['Add Target (Dest) Combat Reach to AOE', 'Area Effects Use Target Radius', 'Chain from Initial Target'], 'trigger_spell': 228597, 'points': 1.0, 'target': TARGET_UNIT_TARGET_ENEMY, }

        -- Affected by:
        -- ice_floes[108839] #0: { 'type': APPLY_AURA, 'subtype': CAST_WHILE_WALKING, 'target': TARGET_UNIT_CASTER, }
        -- icy_veins[12472] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 100.0, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_9, }
        -- lonely_winter[205024] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- piercing_cold[378919] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.5, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_15, }
        -- wintertide[378406] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- ice_form[198144] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 30.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- slick_ice[382148] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -4.0, 'target': TARGET_UNIT_CASTER, 'modifies': CAST_TIME, }
        -- slick_ice[382148] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -4.0, 'target': TARGET_UNIT_CASTER, 'modifies': GLOBAL_COOLDOWN, }
        -- slick_ice[382148] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 4.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
    },

    -- Launches a bolt of frostfire at the enemy, causing $s1 Frostfire damage, slowing movement speed by $s3%, and causing an additional $o2 Frostfire damage over $d.; Frostfire Bolt generates stacks for both Fire Mastery and Frost Mastery.
    frostfire_bolt = {
        id = 431044,
        cast = 2.0,
        cooldown = 0.0,
        gcd = "global",

        spend = 0.020,
        spendType = 'mana',

        talent = "frostfire_bolt",
        startsCombat = true,

        -- Effects:
        -- #0: { 'type': SCHOOL_DAMAGE, 'subtype': NONE, 'sp_bonus': 1.1, 'variance': 0.05, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #1: { 'type': APPLY_AURA, 'subtype': PERIODIC_DAMAGE, 'tick_time': 1.0, 'sp_bonus': 0.05, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #2: { 'type': APPLY_AURA, 'subtype': MOD_DECREASE_SPEED, 'attributes': ['Suppress Points Stacking'], 'mechanic': snared, 'points': -50.0, 'target': TARGET_UNIT_TARGET_ENEMY, }

        -- Affected by:
        -- frigid_winds[235224] #8: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -10.0, 'modifies': EFFECT_3_VALUE, }
        -- lonely_winter[205024] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- piercing_cold[378919] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.5, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_15, }
        -- thermal_conditioning[431117] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -10.0, 'target': TARGET_UNIT_CASTER, 'modifies': CAST_TIME, }
        -- wintertide[378406] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- ice_form[198144] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 30.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- frostfire_empowerment[431177] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 100000.0, 'target': TARGET_UNIT_CASTER, 'modifies': CRIT_CHANCE, }
        -- frostfire_empowerment[431177] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': CAST_TIME, }
        -- frostfire_empowerment[431177] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 50.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- severe_temperatures[431190] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- slick_ice[382148] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -4.0, 'target': TARGET_UNIT_CASTER, 'modifies': CAST_TIME, }
        -- slick_ice[382148] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -4.0, 'target': TARGET_UNIT_CASTER, 'modifies': GLOBAL_COOLDOWN, }
        -- slick_ice[382148] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 4.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
    },

    -- Launches an orb of swirling ice up to $s1 yds forward which deals up to ${20*$84721s1} Frost damage to all enemies it passes through over $d. Deals reduced damage beyond $84721s2 targets. Grants 1 charge of Fingers of Frost when it first damages an enemy.$?a382103[; While Frozen Orb is active, you gain Fingers of Frost every $382106t1 sec.][]; Enemies damaged by the Frozen Orb are slowed by $289308s1% for $289308d.
    frozen_orb = {
        id = 84714,
        cast = 0.0,
        cooldown = 60.0,
        gcd = "global",

        spend = 0.010,
        spendType = 'mana',

        talent = "frozen_orb",
        startsCombat = false,

        -- Effects:
        -- #0: { 'type': CREATE_AREATRIGGER, 'subtype': NONE, 'points': 40.0, 'value': 8661, 'schools': ['physical', 'fire', 'frost', 'arcane'], 'radius': 0.0, 'target': TARGET_DEST_CASTER_FRONT, }

        -- Affected by:
        -- splintering_orbs[444256] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- concentrated_coolness[198148] #0: { 'type': APPLY_AURA, 'subtype': OVERRIDE_ACTIONBAR_SPELLS, 'spell': 198149, 'target': TARGET_UNIT_CASTER, }
    },

    -- Launches a Frozen Orb at the target location, releasing swirling ice which deals ${20*$84721s1} Frost damage over $d to all nearby enemies. Grants 1 charge of Fingers of Frost when it first damages an enemy.; Enemies damaged by the Frost Orb are slowed by $289308s1% for $289308d.
    frozen_orb_198149 = {
        id = 198149,
        cast = 0.0,
        cooldown = 60.0,
        gcd = "global",

        spend = 0.010,
        spendType = 'mana',

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': DUMMY, 'subtype': NONE, 'radius': 10.0, 'target': TARGET_DEST_DEST, }
        -- #1: { 'type': CREATE_AREATRIGGER, 'subtype': NONE, 'points': 1.0, 'value': 8800, 'schools': ['shadow', 'arcane'], 'target': TARGET_DEST_DEST, }

        -- Affected by:
        -- splintering_orbs[444256] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- concentrated_coolness[198148] #0: { 'type': APPLY_AURA, 'subtype': OVERRIDE_ACTIONBAR_SPELLS, 'spell': 198149, 'target': TARGET_UNIT_CASTER, }
        from = "from_description",
    },

    -- Conjures a massive spike of ice, and merges your current Icicles into it. It impales your target, dealing $228600s1 damage plus all of the damage stored in your Icicles, and freezes the target in place for $228600d. Damage may interrupt the freeze effect.; Requires 5 Icicles to cast.; Passive: Ice Lance no longer launches Icicles.
    glacial_spike = {
        id = 199786,
        cast = 2.75,
        cooldown = 0.0,
        gcd = "global",

        spend = 0.010,
        spendType = 'mana',

        talent = "glacial_spike",
        startsCombat = true,

        -- Effects:
        -- #0: { 'type': DUMMY, 'subtype': NONE, 'chain_amp': 0.8, 'chain_targets': 1, 'target': TARGET_UNIT_TARGET_ENEMY, }

        -- Affected by:
        -- mastery_icicles[321684] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 0.75, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- piercing_cold[378919] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.5, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_15, }
        -- splitting_ice[56377] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 1.0, 'target': TARGET_UNIT_CASTER, 'modifies': CHAINED_TARGETS, }
    },

    -- Makes you invisible and untargetable for $110960d, removing all threat. Any action taken cancels this effect.; You take $113862s1% reduced damage while invisible and for 3 sec after reappearing.$?a382293[; Increases your movement speed by ${$382293s1*0.40}% for $337278d.][]
    greater_invisibility = {
        id = 110959,
        cast = 0.0,
        cooldown = 120.0,
        gcd = "global",

        talent = "greater_invisibility",
        startsCombat = false,

        -- Effects:
        -- #0: { 'type': TRIGGER_SPELL, 'subtype': NONE, 'trigger_spell': 110960, 'target': TARGET_UNIT_CASTER, }
    },

    -- Shields you with ice, absorbing $<shield> damage$?s235297[ and increasing your armor by $s3%][] for $d.; Melee attacks against you reduce the attacker's movement speed by $205708s1%.
    ice_barrier = {
        id = 11426,
        cast = 0.0,
        cooldown = 25.0,
        gcd = "global",

        spend = 0.030,
        spendType = 'mana',

        talent = "ice_barrier",
        startsCombat = false,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': SCHOOL_ABSORB, 'value': 127, 'schools': ['physical', 'holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], 'target': TARGET_UNIT_CASTER, }
        -- #1: { 'type': APPLY_AURA, 'subtype': DUMMY, 'points': 24.0, 'target': TARGET_UNIT_CASTER, }
        -- #2: { 'type': APPLY_AURA, 'subtype': MOD_BASE_RESISTANCE_PCT, 'value': 1, 'schools': ['physical'], 'target': TARGET_UNIT_CASTER, }
        -- #3: { 'type': APPLY_AURA, 'subtype': ABILITY_PERIODIC_CRIT, 'target': TARGET_UNIT_CASTER, }

        -- Affected by:
        -- accumulative_shielding[382800] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 30.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_4_VALUE, }
        -- ice_barrier[11426] #3: { 'type': APPLY_AURA, 'subtype': ABILITY_PERIODIC_CRIT, 'target': TARGET_UNIT_CASTER, }
        -- ice_barrier[414661] #3: { 'type': APPLY_AURA, 'subtype': ABILITY_PERIODIC_CRIT, 'radius': 100.0, 'target': TARGET_DEST_CASTER, 'target2': TARGET_UNIT_DEST_AREA_ALLY, }
    },

    -- Encases you in a block of ice, protecting you from all attacks and damage for $d, but during that time you cannot attack, move, or cast spells.$?a382292[; While inside Ice Block, you heal for ${$382292s1*10}% of your maximum health over the duration.][]; Causes Hypothermia, preventing you from recasting Ice Block for $41425d.
    ice_block = {
        id = 45438,
        cast = 0.0,
        cooldown = 240.0,
        gcd = "global",

        talent = "ice_block",
        startsCombat = false,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': MOD_STUN, 'target': TARGET_UNIT_CASTER, }
        -- #1: { 'type': APPLY_AURA, 'subtype': SCHOOL_IMMUNITY, 'value': 1, 'schools': ['physical'], 'target': TARGET_UNIT_CASTER, }
        -- #2: { 'type': APPLY_AURA, 'subtype': SCHOOL_IMMUNITY, 'value': 127, 'schools': ['physical', 'holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], 'target': TARGET_UNIT_CASTER, }
        -- #3: { 'type': APPLY_AURA, 'subtype': OBS_MOD_HEALTH, 'tick_time': 1.0, 'target': TARGET_UNIT_CASTER, }
        -- #4: { 'type': APPLY_AURA, 'subtype': MOD_PACIFY_SILENCE, 'value': 127, 'schools': ['physical', 'holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], 'target': TARGET_UNIT_CASTER, }
        -- #5: { 'type': APPLY_AURA, 'subtype': USE_NORMAL_MOVEMENT_SPEED, 'points': 1.0, 'target': TARGET_UNIT_CASTER, }
        -- #6: { 'type': APPLY_AURA, 'subtype': OBS_MOD_HEALTH, 'tick_time': 1.0, 'points': 6.0, 'target': TARGET_UNIT_CASTER, }

        -- Affected by:
        -- cryofreeze[382292] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 4.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_4_VALUE, }
        -- winters_protection[382424] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -30000.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
    },

    -- Your blood runs cold, reducing all damage you take by $s8% for $d.$?a382292[; While Ice Cold is active, you heal for ${$382292s1*10}% of your maximum health over the duration.][]; Causes Hypothermia, preventing you from recasting Ice Cold for $41425d.
    ice_cold = {
        id = 414658,
        cast = 0.0,
        cooldown = 240.0,
        gcd = "none",

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': DUMMY, 'target': TARGET_UNIT_CASTER, }
        -- #1: { 'type': APPLY_AURA, 'subtype': DUMMY, 'target': TARGET_UNIT_CASTER, }
        -- #2: { 'type': APPLY_AURA, 'subtype': DUMMY, 'target': TARGET_UNIT_CASTER, }
        -- #3: { 'type': APPLY_AURA, 'subtype': OBS_MOD_HEALTH, 'tick_time': 0.6, 'target': TARGET_UNIT_CASTER, }
        -- #4: { 'type': APPLY_AURA, 'subtype': MOD_PACIFY_SILENCE, 'value': 127, 'schools': ['physical', 'holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], 'target': TARGET_UNIT_CASTER, }
        -- #5: { 'type': APPLY_AURA, 'subtype': USE_NORMAL_MOVEMENT_SPEED, 'points': 1.0, 'target': TARGET_UNIT_CASTER, }
        -- #6: { 'type': APPLY_AURA, 'subtype': OBS_MOD_HEALTH, 'tick_time': 0.6, 'points': 6.0, 'target': TARGET_UNIT_CASTER, }
        -- #7: { 'type': APPLY_AURA, 'subtype': MOD_DAMAGE_PERCENT_TAKEN, 'points': -70.0, 'schools': ['physical', 'holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], 'target': TARGET_UNIT_CASTER, }
        -- #8: { 'type': APPLY_AURA, 'subtype': MOD_INCREASE_SPEED, 'target': TARGET_UNIT_CASTER, }

        -- Affected by:
        -- cryofreeze[382292] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 4.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_4_VALUE, }
        -- winters_protection[382424] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -30000.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
    },

    -- Your body turns into Ice, increasing your Frostbolt damage done by $m1% and granting immunity to stun and knockback effects. Lasts $d.
    ice_form = {
        id = 198144,
        color = 'pvp_talent',
        cast = 0.0,
        cooldown = 60.0,
        gcd = "none",

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 30.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- #1: { 'type': APPLY_AURA, 'subtype': MECHANIC_IMMUNITY_MASK, 'points': 100.0, 'value': 1808, 'schools': ['frost'], 'target': TARGET_UNIT_CASTER, }
        -- #2: { 'type': APPLY_AURA, 'subtype': MECHANIC_IMMUNITY, 'target': TARGET_UNIT_CASTER, 'mechanic': 12, }

        -- Affected by:
        -- thermal_void[155149] #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 5000.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
    },

    -- Quickly fling a shard of ice at the target, dealing $228598s1 Frost damage$?s56377[, and ${$228598s1*$56377m2/100} Frost damage to a second nearby target][].; Ice Lance damage is tripled against frozen targets.
    ice_lance = {
        id = 30455,
        cast = 0.0,
        cooldown = 0.0,
        gcd = "global",

        spend = 0.010,
        spendType = 'mana',

        talent = "ice_lance",
        startsCombat = true,

        -- Effects:
        -- #0: { 'type': SCRIPT_EFFECT, 'subtype': NONE, 'chain_amp': 0.5, 'chain_targets': 1, 'target': TARGET_UNIT_TARGET_ENEMY, }

        -- Affected by:
        -- mastery_icicles[321684] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 0.75, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- lonely_winter[205024] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- splitting_ice[56377] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 1.0, 'target': TARGET_UNIT_CASTER, 'modifies': CHAINED_TARGETS, }
        -- splitting_ice[56377] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- chain_reaction[278310] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- permafrost_lances[455122] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
    },

    -- [30455] Quickly fling a shard of ice at the target, dealing $228598s1 Frost damage$?s56377[, and ${$228598s1*$56377m2/100} Frost damage to a second nearby target][].; Ice Lance damage is tripled against frozen targets.
    ice_lance_228598 = {
        id = 228598,
        cast = 0.0,
        cooldown = 0.0,
        gcd = "global",

        startsCombat = true,

        -- Effects:
        -- #0: { 'type': SCHOOL_DAMAGE, 'subtype': NONE, 'attributes': ['Area Effects Use Target Radius'], 'sp_bonus': 0.55, 'chain_amp': 0.8, 'chain_targets': 1, 'pvp_multiplier': 1.315, 'variance': 0.05, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #1: { 'type': DUMMY, 'subtype': NONE, }

        -- Affected by:
        -- mastery_icicles[321684] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 0.75, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- lonely_winter[205024] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- splitting_ice[56377] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- chain_reaction[278310] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- permafrost_lances[455122] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        from = "from_description",
    },

    -- Causes a whirl of icy wind around the enemy, dealing $s1 Frost damage to the target and reduced damage to all other enemies within $a2 yds, and freezing them in place for $d.
    ice_nova = {
        id = 157997,
        cast = 0.0,
        cooldown = 25.0,
        gcd = "global",

        talent = "ice_nova",
        startsCombat = true,

        -- Effects:
        -- #0: { 'type': SCHOOL_DAMAGE, 'subtype': NONE, 'sp_bonus': 1.38, 'pvp_multiplier': 1.08, 'variance': 0.05, 'radius': 8.0, 'target': TARGET_DEST_TARGET_ENEMY, 'target2': TARGET_UNIT_DEST_AREA_ENEMY, }
        -- #1: { 'type': APPLY_AURA, 'subtype': MOD_ROOT_2, 'mechanic': rooted, 'radius': 8.0, 'target': TARGET_DEST_TARGET_ENEMY, 'target2': TARGET_UNIT_DEST_AREA_ENEMY, }
        -- #2: { 'type': DUMMY, 'subtype': NONE, 'target': TARGET_UNIT_TARGET_ENEMY, }

        -- Affected by:
        -- elemental_affinity[431067] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -30.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
    },

    -- Conjures an Ice Wall $s3 yards long that obstructs line of sight. The wall has $s4% of your maximum health and lasts up to $d.
    ice_wall = {
        id = 352278,
        color = 'pvp_talent',
        cast = 1.5,
        cooldown = 90.0,
        gcd = "global",

        spend = 0.080,
        spendType = 'mana',

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': SUMMON, 'subtype': NONE, 'points': 1.0, 'value': 178819, 'schools': ['physical', 'holy'], 'value1': 5168, 'radius': 0.1, 'target': TARGET_DEST_DEST_FRONT, }
        -- #1: { 'type': TRANS_DOOR, 'subtype': NONE, 'value': 368620, 'schools': ['fire', 'nature', 'shadow', 'arcane'], 'target': TARGET_DEST_DEST, }
        -- #2: { 'type': APPLY_AURA, 'subtype': DUMMY, 'points': 30.0, 'target': TARGET_UNIT_CASTER, }
        -- #3: { 'type': DUMMY, 'subtype': NONE, }
    },

    -- Accelerates your spellcasting for $d, granting $m1% haste and preventing damage from delaying your spellcasts.; Activating Icy Veins summons a water elemental to your side for its duration. The water elemental's abilities grant you Frigid Empowerment, increasing the Frost damage you deal by $417488s1%, up to ${$417488s1*$417488u}%.
    icy_veins = {
        id = 12472,
        cast = 0.0,
        cooldown = 120.0,
        gcd = "none",

        talent = "icy_veins",
        startsCombat = false,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': MELEE_SLOW, 'points': 20.0, 'target': TARGET_UNIT_CASTER, }
        -- #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 100.0, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_9, }

        -- Affected by:
        -- thermal_void[155149] #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 5000.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
    },

    -- Turns you invisible over $66d, reducing threat each second. While invisible, you are untargetable by enemies. Lasts $32612d. Taking any action cancels the effect.$?a382293[; Increases your movement speed by $382293s1% for $337278d.][]
    invisibility = {
        id = 66,
        cast = 0.0,
        cooldown = 300.0,
        gcd = "global",

        spend = 0.030,
        spendType = 'mana',

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': DUMMY, 'target': TARGET_UNIT_CASTER, }
        -- #1: { 'type': APPLY_AURA, 'subtype': PERIODIC_TRIGGER_SPELL, 'tick_time': 1.0, 'trigger_spell': 35009, 'target': TARGET_UNIT_CASTER, }
        -- #2: { 'type': UNKNOWN, 'subtype': NONE, 'points': 100.0, }
    },

    -- Creates a runic prison at the target's location, slowing enemy movement speed by ${$211056s1/-1}%, inflicting ${$211088s1*6} Arcane damage over $d, and then detonating for Arcane damage equal to $s1% of your maximum mana.; 
    mark_of_aluneth = {
        id = 210726,
        color = 'artifact',
        cast = 2.0,
        cooldown = 60.0,
        gcd = "global",

        startsCombat = true,

        -- Effects:
        -- #0: { 'type': CREATE_AREATRIGGER, 'subtype': NONE, 'points': 15.0, 'value': 6845, 'schools': ['physical', 'fire', 'nature', 'frost', 'shadow'], 'target': TARGET_DEST_TARGET_ENEMY, 'target2': TARGET_DEST_DEST, }
    },

    -- Creates a rune around the target, inflicting ${$211088s1*6} Arcane damage over $d to all enemies within $211088A1 yds, and then detonating for Arcane damage equal to $s1% of your maximum mana.
    mark_of_aluneth_224968 = {
        id = 224968,
        color = 'artifact',
        cast = 2.0,
        cooldown = 60.0,
        gcd = "global",

        startsCombat = true,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': PERIODIC_DUMMY, 'tick_time': 1.0, 'points': 20.0, 'target': TARGET_UNIT_TARGET_ENEMY, 'target2': TARGET_DEST_DEST, }
        from = "class",
    },

    -- Cast $?c1[Prismatic]?c2[Blazing]?c3[Ice][] Barrier on yourself and $414661i allies within $s2 yds.
    mass_barrier = {
        id = 414660,
        cast = 0.0,
        cooldown = 180.0,
        gcd = "global",

        spend = 0.120,
        spendType = 'mana',

        talent = "mass_barrier",
        startsCombat = false,

        -- Effects:
        -- #0: { 'type': DUMMY, 'subtype': NONE, 'target': TARGET_UNIT_CASTER, }
        -- #1: { 'type': DUMMY, 'subtype': NONE, 'target': TARGET_UNIT_CASTER, }
    },

    -- You and your allies within $A1 yards instantly become invisible for $d. Taking any action will cancel the effect.; $?a415945[]; [Does not affect allies in combat.]
    mass_invisibility = {
        id = 414664,
        cast = 0.0,
        cooldown = 300.0,
        gcd = "global",

        spend = 0.060,
        spendType = 'mana',

        talent = "mass_invisibility",
        startsCombat = false,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': MOD_INVISIBILITY, 'points': 200.0, 'radius': 40.0, 'target': TARGET_SRC_CASTER, 'target2': TARGET_UNIT_CASTER_AREA_RAID, }
        -- #1: { 'type': APPLY_AURA, 'subtype': UNKNOWN, 'points': 1.0, 'radius': 40.0, 'target': TARGET_SRC_CASTER, 'target2': TARGET_UNIT_CASTER_AREA_RAID, }
        -- #2: { 'type': APPLY_AURA, 'subtype': SCREEN_EFFECT, 'value': 1421, 'schools': ['physical', 'fire', 'nature'], 'value1': 7, 'radius': 40.0, 'target': TARGET_SRC_CASTER, 'target2': TARGET_UNIT_CASTER_AREA_RAID, }
        -- #3: { 'type': SANCTUARY_2, 'subtype': NONE, 'radius': 40.0, 'target': TARGET_SRC_CASTER, 'target2': TARGET_UNIT_CASTER_AREA_RAID, }

        -- Affected by:
        -- improved_mass_invisibility[415945] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -240000.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
    },

    -- Transforms all enemies within $a yards into sheep, wandering around incapacitated for $d. While affected, the victims cannot take actions but will regenerate health very quickly. Damage will cancel the effect.; Only works on Beasts, Humanoids and Critters.
    mass_polymorph = {
        id = 383121,
        cast = 1.7,
        cooldown = 60.0,
        gcd = "global",

        spend = 0.040,
        spendType = 'mana',

        talent = "mass_polymorph",
        startsCombat = true,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': MOD_CONFUSE, 'radius': 10.0, 'target': TARGET_SRC_CASTER, 'target2': TARGET_UNIT_SRC_AREA_ENEMY, }
        -- #1: { 'type': APPLY_AURA, 'subtype': TRANSFORM, 'value': 16372, 'schools': ['fire', 'frost', 'shadow', 'arcane'], 'value1': 9, 'radius': 10.0, 'target': TARGET_SRC_CASTER, 'target2': TARGET_UNIT_SRC_AREA_ENEMY, }
    },

    -- Creates $s2 copies of you nearby for $55342d, which cast spells and attack your enemies.; While your images are active damage taken is reduced by $s3%. Taking direct damage will cause one of your images to dissipate.$?a382820[; You are healed for $382998s1% of your maximum health whenever a Mirror Image dissipates due to direct damage.]?a382569[; Mirror Image's cooldown is reduced by ${$382569s1/1000} sec whenever a Mirror Image dissipates due to direct damage.][]
    mirror_image = {
        id = 55342,
        cast = 0.0,
        cooldown = 120.0,
        gcd = "global",

        spend = 0.020,
        spendType = 'mana',

        talent = "mirror_image",
        startsCombat = false,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': MOD_TOTAL_THREAT, 'points': -90000000.0, 'target': TARGET_UNIT_CASTER, }
        -- #1: { 'type': DUMMY, 'subtype': NONE, 'target': TARGET_UNIT_CASTER, }
        -- #2: { 'type': APPLY_AURA, 'subtype': MOD_DAMAGE_PERCENT_TAKEN, 'points': -20.0, 'schools': ['physical', 'holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], 'target': TARGET_UNIT_CASTER, }

        -- Affected by:
        -- phantasmal_image[444784] #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER_BY_LABEL, 'points': -5.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_3_VALUE, }
    },

    -- Places a Nether Tempest on the target which deals $114923o1 Arcane damage over $114923d to the target and nearby enemies within 10 yds. Limit 1 target. Deals reduced damage to secondary targets.; Damage increased by $36032s1% per Arcane Charge.
    nether_tempest = {
        id = 114923,
        cast = 0.0,
        cooldown = 0.0,
        gcd = "global",

        spend = 0.015,
        spendType = 'mana',

        startsCombat = true,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': PERIODIC_DAMAGE, 'tick_time': 1.0, 'sp_bonus': 0.018803, 'pvp_multiplier': 2.5, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #1: { 'type': APPLY_AURA, 'subtype': DUMMY, 'points': 10.0, 'target': TARGET_UNIT_TARGET_ENEMY, }

        -- Affected by:
        -- frost_mage[137020] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- frost_mage[137020] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- overflowing_energy[390218] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_15, }
        -- force_of_will[444719] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'modifies': SHOULD_NEVER_SEE_15, }
        -- shatter[12982] #0: { 'type': APPLY_AURA, 'subtype': OVERRIDE_CLASS_SCRIPTS, 'points': 10.0, 'value': 911, 'schools': ['physical', 'holy', 'fire', 'nature'], 'target': TARGET_UNIT_CASTER, }
        -- bone_chilling[205766] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 1.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- bone_chilling[205766] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 1.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- arcane_mage[137021] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- arcane_mage[137021] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- incanters_flow[116267] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- incanters_flow[116267] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- overflowing_energy[394195] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': CRIT_CHANCE, }
        -- numbing_blast[417490] #0: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'pvp_multiplier': 0.5, 'points': 6.0, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- frigid_empowerment[417488] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.6667, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- frigid_empowerment[417488] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.6667, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
    },

    -- Hurls a Phoenix that causes $s1 Fire damage to the target and splashes $224637s2 Fire damage to other nearby enemies. This damage is always a critical strike.
    phoenixs_flames = {
        id = 194466,
        color = 'artifact',
        cast = 0.0,
        cooldown = 0.0,
        gcd = "global",

        startsCombat = true,

        -- Effects:
        -- #0: { 'type': SCHOOL_DAMAGE, 'subtype': NONE, 'sp_bonus': 0.9735, 'chain_amp': 0.75, 'chain_targets': 1, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #1: { 'type': SCRIPT_EFFECT, 'subtype': NONE, 'chain_targets': 1, 'target': TARGET_UNIT_TARGET_ENEMY, }
    },

    -- Transforms the enemy into a sheep, wandering around incapacitated for $d. While affected, the victim cannot take actions but will regenerate health very quickly. Damage will cancel the effect. Limit 1.; Only works on Beasts, Humanoids and Critters.$?s56382[ When critters are affected, can affect multiple targets, and has a duration of 1 day.][]
    polymorph = {
        id = 118,
        color = 'sheep',
        cast = 1.7,
        cooldown = 0.0,
        gcd = "global",

        spend = 0.040,
        spendType = 'mana',

        startsCombat = true,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': MOD_CONFUSE, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #1: { 'type': APPLY_AURA, 'subtype': TRANSFORM, 'value': 16372, 'schools': ['fire', 'frost', 'shadow', 'arcane'], 'value1': 9, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #2: { 'type': APPLY_AURA, 'subtype': MOD_SCALE, 'target': TARGET_UNIT_TARGET_ENEMY, }

        -- Affected by:
        -- ice_floes[108839] #0: { 'type': APPLY_AURA, 'subtype': CAST_WHILE_WALKING, 'target': TARGET_UNIT_CASTER, }
        -- icy_veins[12472] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 100.0, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_9, }
    },

    -- Transforms the enemy into a porcupine, wandering around incapacitated for $d. While affected, the victim cannot take actions but will regenerate health very quickly. Damage will cancel the effect. Limit 1.; Only works on Beasts, Humanoids and Critters.$?s56382[ When critters are affected, can affect multiple targets, and has a duration of 1 day.][]
    polymorph_126819 = {
        id = 126819,
        color = 'porcupine',
        cast = 1.7,
        cooldown = 0.0,
        gcd = "global",

        spend = 0.040,
        spendType = 'mana',

        startsCombat = true,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': MOD_CONFUSE, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #1: { 'type': APPLY_AURA, 'subtype': TRANSFORM, 'value': 64857, 'schools': ['physical', 'nature', 'frost', 'arcane'], 'value1': 9, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #2: { 'type': APPLY_AURA, 'subtype': MOD_SCALE, 'target': TARGET_UNIT_TARGET_ENEMY, }
        from = "class",
    },

    -- Transforms the enemy into a polar bear cub, wandering around incapacitated for $d. While affected, the victim cannot take actions but will regenerate health very quickly. Damage will cancel the effect. Limit 1.; Only works on Beasts, Humanoids and Critters.$?s56382[ When critters are affected, can affect multiple targets, and has a duration of 1 day.][]
    polymorph_161353 = {
        id = 161353,
        color = 'polar_bear_cub',
        cast = 1.7,
        cooldown = 0.0,
        gcd = "global",

        spend = 0.040,
        spendType = 'mana',

        startsCombat = true,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': MOD_CONFUSE, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #1: { 'type': APPLY_AURA, 'subtype': TRANSFORM, 'value': 79941, 'schools': ['physical', 'fire', 'arcane'], 'value1': 9, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #2: { 'type': APPLY_AURA, 'subtype': MOD_SCALE, 'target': TARGET_UNIT_TARGET_ENEMY, }
        from = "class",
    },

    -- Transforms the enemy into a monkey, wandering around incapacitated for $d. While affected, the victim cannot take actions but will regenerate health very quickly. Damage will cancel the effect. Limit 1.; Only works on Beasts, Humanoids and Critters.$?s56382[ When critters are affected, can affect multiple targets, and has a duration of 1 day.][]
    polymorph_161354 = {
        id = 161354,
        color = 'monkey',
        cast = 1.7,
        cooldown = 0.0,
        gcd = "global",

        spend = 0.040,
        spendType = 'mana',

        startsCombat = true,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': MOD_CONFUSE, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #1: { 'type': APPLY_AURA, 'subtype': TRANSFORM, 'value': 79943, 'schools': ['physical', 'holy', 'fire', 'arcane'], 'value1': 9, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #2: { 'type': APPLY_AURA, 'subtype': MOD_SCALE, 'target': TARGET_UNIT_TARGET_ENEMY, }
        from = "class",
    },

    -- Transforms the enemy into a penguin, wandering around incapacitated for $d. While affected, the victim cannot take actions but will regenerate health very quickly. Damage will cancel the effect. Limit 1.; Only works on Beasts, Humanoids and Critters.$?s56382[ When critters are affected, can affect multiple targets, and has a duration of 1 day.][]
    polymorph_161355 = {
        id = 161355,
        color = 'penguin',
        cast = 1.7,
        cooldown = 0.0,
        gcd = "global",

        spend = 0.040,
        spendType = 'mana',

        startsCombat = true,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': MOD_CONFUSE, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #1: { 'type': APPLY_AURA, 'subtype': TRANSFORM, 'value': 79942, 'schools': ['holy', 'fire', 'arcane'], 'value1': 9, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #2: { 'type': APPLY_AURA, 'subtype': MOD_SCALE, 'target': TARGET_UNIT_TARGET_ENEMY, }
        from = "class",
    },

    -- Transforms the enemy into a peacock, wandering around incapacitated for $d. While affected, the victim cannot take actions but will regenerate health very quickly. Damage will cancel the effect. Limit 1.; Only works on Beasts, Humanoids and Critters.$?s56382[ When critters are affected, can affect multiple targets, and has a duration of 1 day.][]
    polymorph_161372 = {
        id = 161372,
        color = 'peacock',
        cast = 1.7,
        cooldown = 0.0,
        gcd = "global",

        spend = 0.040,
        spendType = 'mana',

        startsCombat = true,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': MOD_CONFUSE, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #1: { 'type': APPLY_AURA, 'subtype': TRANSFORM, 'value': 79952, 'schools': ['frost', 'arcane'], 'value1': 9, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #2: { 'type': APPLY_AURA, 'subtype': MOD_SCALE, 'target': TARGET_UNIT_TARGET_ENEMY, }
        from = "class",
    },

    -- Transforms the enemy into a baby direhorn, wandering around incapacitated for $d. While affected, the victim cannot take actions but will regenerate health very quickly. Damage will cancel the effect. Limit 1.; Only works on Beasts, Humanoids and Critters.$?s56382[ When critters are affected, can affect multiple targets, and has a duration of 1 day.][]
    polymorph_277787 = {
        id = 277787,
        color = 'direhorn',
        cast = 1.7,
        cooldown = 0.0,
        gcd = "global",

        spend = 0.040,
        spendType = 'mana',

        startsCombat = true,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': MOD_CONFUSE, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #1: { 'type': APPLY_AURA, 'subtype': TRANSFORM, 'value': 142225, 'schools': ['physical', 'frost'], 'value1': 9, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #2: { 'type': APPLY_AURA, 'subtype': MOD_SCALE, 'target': TARGET_UNIT_TARGET_ENEMY, }
        from = "class",
    },

    -- Transforms the enemy into a bumblebee, wandering around incapacitated for $d. While affected, the victim cannot take actions but will regenerate health very quickly. Damage will cancel the effect. Limit 1.; Only works on Beasts, Humanoids and Critters.$?s56382[ When critters are affected, can affect multiple targets, and has a duration of 1 day.][]
    polymorph_277792 = {
        id = 277792,
        color = 'bumblebee',
        cast = 1.7,
        cooldown = 0.0,
        gcd = "global",

        spend = 0.040,
        spendType = 'mana',

        startsCombat = true,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': MOD_CONFUSE, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #1: { 'type': APPLY_AURA, 'subtype': TRANSFORM, 'value': 142226, 'schools': ['holy', 'frost'], 'value1': 9, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #2: { 'type': APPLY_AURA, 'subtype': MOD_SCALE, 'target': TARGET_UNIT_TARGET_ENEMY, }
        from = "class",
    },

    -- Transforms the enemy into a turtle, wandering around incapacitated for $d. While affected, the victim cannot take actions but will regenerate health very quickly. Damage will cancel the effect. Limit 1.; Only works on Beasts, Humanoids and Critters.$?s56382[ When critters are affected, can affect multiple targets, and has a duration of 1 day.][]
    polymorph_28271 = {
        id = 28271,
        color = 'turtle',
        cast = 1.7,
        cooldown = 0.0,
        gcd = "global",

        spend = 0.040,
        spendType = 'mana',

        startsCombat = true,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': MOD_CONFUSE, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #1: { 'type': APPLY_AURA, 'subtype': TRANSFORM, 'value': 16377, 'schools': ['physical', 'nature', 'frost', 'shadow', 'arcane'], 'value1': 9, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #2: { 'type': APPLY_AURA, 'subtype': MOD_SCALE, 'target': TARGET_UNIT_TARGET_ENEMY, }

        -- Affected by:
        -- ice_floes[108839] #0: { 'type': APPLY_AURA, 'subtype': CAST_WHILE_WALKING, 'target': TARGET_UNIT_CASTER, }
        -- icy_veins[12472] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 100.0, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_9, }
        from = "class",
    },

    -- Transforms the enemy into a pig, wandering around incapacitated for $d. While affected, the victim cannot take actions but will regenerate health very quickly. Damage will cancel the effect. Limit 1.; Only works on Beasts, Humanoids and Critters.$?s56382[ When critters are affected, can affect multiple targets, and has a duration of 1 day.][]
    polymorph_28272 = {
        id = 28272,
        color = 'pig',
        cast = 1.7,
        cooldown = 0.0,
        gcd = "global",

        spend = 0.040,
        spendType = 'mana',

        startsCombat = true,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': MOD_CONFUSE, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #1: { 'type': APPLY_AURA, 'subtype': TRANSFORM, 'value': 16371, 'schools': ['physical', 'holy', 'frost', 'shadow', 'arcane'], 'value1': 9, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #2: { 'type': APPLY_AURA, 'subtype': MOD_SCALE, 'target': TARGET_UNIT_TARGET_ENEMY, }

        -- Affected by:
        -- ice_floes[108839] #0: { 'type': APPLY_AURA, 'subtype': CAST_WHILE_WALKING, 'target': TARGET_UNIT_CASTER, }
        -- icy_veins[12472] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 100.0, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_9, }
        from = "class",
    },

    -- Transforms the enemy into a mawrat, wandering around incapacitated for $d. While affected, the victim cannot take actions but will regenerate health very quickly. Damage will cancel the effect. Limit 1.; Only works on Undead, Beasts, Humanoids and Critters.$?s56382[ When critters are affected, can affect multiple targets, and has a duration of 1 day.][]
    polymorph_321395 = {
        id = 321395,
        color = 'mawrat',
        cast = 1.7,
        cooldown = 0.0,
        gcd = "global",

        spend = 0.040,
        spendType = 'mana',

        startsCombat = true,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': MOD_CONFUSE, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #1: { 'type': APPLY_AURA, 'subtype': TRANSFORM, 'value': 165081, 'schools': ['physical', 'nature', 'frost', 'arcane'], 'value1': 9, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #2: { 'type': APPLY_AURA, 'subtype': MOD_SCALE, 'target': TARGET_UNIT_TARGET_ENEMY, }
        from = "class",
    },

    -- Transforms the enemy into a duck, wandering around incapacitated for $d. While affected, the victim cannot take actions but will regenerate health very quickly. Damage will cancel the effect. Limit 1.; Only works on Beasts, Humanoids and Critters.$?s56382[ When critters are affected, can affect multiple targets, and has a duration of 1 day.][]
    polymorph_391622 = {
        id = 391622,
        color = 'duck',
        cast = 1.7,
        cooldown = 0.0,
        gcd = "global",

        spend = 0.040,
        spendType = 'mana',

        startsCombat = true,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': MOD_CONFUSE, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #1: { 'type': APPLY_AURA, 'subtype': TRANSFORM, 'value': 197731, 'schools': ['physical', 'holy', 'shadow', 'arcane'], 'value1': 9, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #2: { 'type': APPLY_AURA, 'subtype': MOD_SCALE, 'target': TARGET_UNIT_TARGET_ENEMY, }
        from = "class",
    },

    -- Transforms the enemy into a mosswool, wandering around incapacitated for $d. While affected, the victim cannot take actions but will regenerate health very quickly. Damage will cancel the effect. Limit 1.; Only works on Beasts, Humanoids and Critters.$?s56382[ When critters are affected, can affect multiple targets, and has a duration of 1 day.][]
    polymorph_460392 = {
        id = 460392,
        color = 'mosswool',
        cast = 1.7,
        cooldown = 0.0,
        gcd = "global",

        spend = 0.040,
        spendType = 'mana',

        startsCombat = true,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': MOD_CONFUSE, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #1: { 'type': APPLY_AURA, 'subtype': TRANSFORM, 'value': 228627, 'schools': ['physical', 'holy', 'frost'], 'value1': 9, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #2: { 'type': APPLY_AURA, 'subtype': MOD_SCALE, 'target': TARGET_UNIT_TARGET_ENEMY, }
        from = "class",
    },

    -- Transforms the enemy into a harmless serpent, wandering around incapacitated for $d. While affected, the victim cannot take actions but will regenerate health very quickly. Damage will cancel the effect. Limit 1.; Only works on Beasts, Humanoids and Critters.$?s56382[ When critters are affected, can affect multiple targets, and has a duration of 1 day.][]
    polymorph_61025 = {
        id = 61025,
        color = 'serpent',
        cast = 1.7,
        cooldown = 0.0,
        gcd = "global",

        spend = 0.040,
        spendType = 'mana',

        startsCombat = true,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': MOD_CONFUSE, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #1: { 'type': APPLY_AURA, 'subtype': TRANSFORM, 'value': 79945, 'schools': ['physical', 'nature', 'arcane'], 'value1': 9, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #2: { 'type': APPLY_AURA, 'subtype': MOD_SCALE, 'target': TARGET_UNIT_TARGET_ENEMY, }

        -- Affected by:
        -- ice_floes[108839] #0: { 'type': APPLY_AURA, 'subtype': CAST_WHILE_WALKING, 'target': TARGET_UNIT_CASTER, }
        from = "class",
    },

    -- Transforms the enemy into a harmless black cat, wandering around incapacitated for $d. While affected, the victim cannot take actions but will regenerate health very quickly. Damage will cancel the effect. Limit 1.; Only works on Beasts, Humanoids and Critters.$?s56382[ When critters are affected, can affect multiple targets, and has a duration of 1 day.][]
    polymorph_61305 = {
        id = 61305,
        color = 'black_cat',
        cast = 1.7,
        cooldown = 0.0,
        gcd = "global",

        spend = 0.040,
        spendType = 'mana',

        startsCombat = true,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': MOD_CONFUSE, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #1: { 'type': APPLY_AURA, 'subtype': TRANSFORM, 'value': 32570, 'schools': ['holy', 'nature', 'frost', 'shadow'], 'value1': 9, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #2: { 'type': APPLY_AURA, 'subtype': MOD_SCALE, 'target': TARGET_UNIT_TARGET_ENEMY, }

        -- Affected by:
        -- ice_floes[108839] #0: { 'type': APPLY_AURA, 'subtype': CAST_WHILE_WALKING, 'target': TARGET_UNIT_CASTER, }
        from = "class",
    },

    -- Transforms the enemy into a harmless rabbit, wandering around incapacitated for $d. While affected, the victim cannot take actions but will regenerate health very quickly. Damage will cancel the effect. Limit 1.; Only works on Beasts, Humanoids and Critters.$?s56382[ When critters are affected, can affect multiple targets, and has a duration of 1 day.][]
    polymorph_61721 = {
        id = 61721,
        color = 'rabbit',
        cast = 1.7,
        cooldown = 0.0,
        gcd = "global",

        spend = 0.040,
        spendType = 'mana',

        startsCombat = true,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': MOD_CONFUSE, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #1: { 'type': APPLY_AURA, 'subtype': TRANSFORM, 'value': 32789, 'schools': ['physical', 'fire', 'frost'], 'value1': 9, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #2: { 'type': APPLY_AURA, 'subtype': MOD_SCALE, 'target': TARGET_UNIT_TARGET_ENEMY, }

        -- Affected by:
        -- ice_floes[108839] #0: { 'type': APPLY_AURA, 'subtype': CAST_WHILE_WALKING, 'target': TARGET_UNIT_CASTER, }
        from = "class",
    },

    -- Transforms the enemy into a turkey, wandering around incapacitated for $d. While affected, the victim cannot take actions but will regenerate health very quickly. Damage will cancel the effect. Limit 1.; Only works on Beasts, Humanoids and Critters.$?s56382[ When critters are affected, can affect multiple targets, and has a duration of 1 day.][]
    polymorph_61780 = {
        id = 61780,
        color = 'turkey',
        cast = 1.7,
        cooldown = 0.0,
        gcd = "global",

        spend = 0.040,
        spendType = 'mana',

        startsCombat = true,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': MOD_CONFUSE, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #1: { 'type': APPLY_AURA, 'subtype': TRANSFORM, 'value': 79948, 'schools': ['fire', 'nature', 'arcane'], 'value1': 9, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #2: { 'type': APPLY_AURA, 'subtype': MOD_SCALE, 'target': TARGET_UNIT_TARGET_ENEMY, }

        -- Affected by:
        -- ice_floes[108839] #0: { 'type': APPLY_AURA, 'subtype': CAST_WHILE_WALKING, 'target': TARGET_UNIT_CASTER, }
        from = "class",
    },

    -- Creates a portal, teleporting group members that use it to Boralus.
    portal_boralus = {
        id = 281400,
        cast = 10.0,
        cooldown = 60.0,
        gcd = "global",

        spend = 0.040,
        spendType = 'mana',

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': TRANS_DOOR, 'subtype': NONE, 'value': 302854, 'schools': ['holy', 'fire'], 'radius': 3.0, 'target': TARGET_DEST_CASTER_FRONT, }
    },

    -- Creates a portal, teleporting group members that use it to Dalaran in the Broken Isles.
    portal_dalaran_broken_isles = {
        id = 224871,
        cast = 10.0,
        cooldown = 60.0,
        gcd = "global",

        spend = 0.040,
        spendType = 'mana',

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': TRANS_DOOR, 'subtype': NONE, 'value': 254237, 'schools': ['physical', 'fire', 'nature', 'frost'], 'radius': 3.0, 'target': TARGET_DEST_CASTER_FRONT, }
    },

    -- Creates a portal, teleporting group members that use it to Dalaran.
    portal_dalaran_northrend = {
        id = 53142,
        cast = 10.0,
        cooldown = 60.0,
        gcd = "global",

        spend = 0.040,
        spendType = 'mana',

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': TRANS_DOOR, 'subtype': NONE, 'value': 191164, 'schools': ['fire', 'nature', 'frost', 'shadow'], 'radius': 3.0, 'target': TARGET_DEST_CASTER_FRONT, }
    },

    -- Creates a portal, teleporting group members that use it to Darnassus.
    portal_darnassus = {
        id = 11419,
        cast = 10.0,
        cooldown = 60.0,
        gcd = "global",

        spend = 0.040,
        spendType = 'mana',

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': TRANS_DOOR, 'subtype': NONE, 'value': 176498, 'schools': ['holy', 'frost', 'shadow', 'arcane'], 'radius': 3.0, 'target': TARGET_DEST_CASTER_FRONT, }

        -- Affected by:
        -- icy_veins[12472] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 100.0, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_9, }
    },

    -- Creates a portal, teleporting group members that use it to Dazar'alor.
    portal_dazaralor = {
        id = 281402,
        cast = 10.0,
        cooldown = 60.0,
        gcd = "global",

        spend = 0.040,
        spendType = 'mana',

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': TRANS_DOOR, 'subtype': NONE, 'value': 302855, 'schools': ['physical', 'holy', 'fire'], 'radius': 3.0, 'target': TARGET_DEST_CASTER_FRONT, }
    },

    -- Creates a portal, teleporting group members that use it to Dornogal.
    portal_dornogal = {
        id = 446534,
        cast = 10.0,
        cooldown = 60.0,
        gcd = "global",

        spend = 0.040,
        spendType = 'mana',

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': TRANS_DOOR, 'subtype': NONE, 'value': 441968, 'schools': ['frost', 'shadow', 'arcane'], 'radius': 3.0, 'target': TARGET_DEST_CASTER_FRONT, }
    },

    -- Creates a portal, teleporting group members that use it to Exodar.
    portal_exodar = {
        id = 32266,
        cast = 10.0,
        cooldown = 60.0,
        gcd = "global",

        spend = 0.040,
        spendType = 'mana',

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': TRANS_DOOR, 'subtype': NONE, 'value': 182351, 'schools': ['physical', 'holy', 'fire', 'nature', 'arcane'], 'radius': 3.0, 'target': TARGET_DEST_CASTER_FRONT, }
    },

    -- Creates a portal, teleporting group members that use it to Ironforge.
    portal_ironforge = {
        id = 11416,
        cast = 10.0,
        cooldown = 60.0,
        gcd = "global",

        spend = 0.040,
        spendType = 'mana',

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': TRANS_DOOR, 'subtype': NONE, 'value': 176497, 'schools': ['physical', 'frost', 'shadow', 'arcane'], 'radius': 3.0, 'target': TARGET_DEST_CASTER_FRONT, }

        -- Affected by:
        -- icy_veins[12472] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 100.0, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_9, }
    },

    -- Creates a portal, teleporting group members that use it to Orgrimmar.
    portal_orgrimmar = {
        id = 11417,
        cast = 10.0,
        cooldown = 60.0,
        gcd = "global",

        spend = 0.040,
        spendType = 'mana',

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': TRANS_DOOR, 'subtype': NONE, 'value': 176499, 'schools': ['physical', 'holy', 'frost', 'shadow', 'arcane'], 'radius': 3.0, 'target': TARGET_DEST_CASTER_FRONT, }

        -- Affected by:
        -- icy_veins[12472] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 100.0, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_9, }
    },

    -- Creates a portal, teleporting group members that use it to Oribos.
    portal_oribos = {
        id = 344597,
        cast = 10.0,
        cooldown = 60.0,
        gcd = "global",

        spend = 0.040,
        spendType = 'mana',

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': TRANS_DOOR, 'subtype': NONE, 'value': 364440, 'schools': ['nature', 'frost'], 'radius': 3.0, 'target': TARGET_DEST_CASTER_FRONT, }
    },

    -- Creates a portal, teleporting group members that use it to Shattrath.
    portal_shattrath = {
        id = 33691,
        cast = 10.0,
        cooldown = 60.0,
        gcd = "global",

        spend = 0.040,
        spendType = 'mana',

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': TRANS_DOOR, 'subtype': NONE, 'value': 183384, 'schools': ['nature', 'frost', 'arcane'], 'radius': 3.0, 'target': TARGET_DEST_CASTER_FRONT, }
    },

    -- Creates a portal, teleporting group members that use it to Shattrath.
    portal_shattrath_35717 = {
        id = 35717,
        cast = 10.0,
        cooldown = 60.0,
        gcd = "global",

        spend = 0.040,
        spendType = 'mana',

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': TRANS_DOOR, 'subtype': NONE, 'value': 184594, 'schools': ['holy', 'frost'], 'radius': 3.0, 'target': TARGET_DEST_CASTER_FRONT, }
        from = "class",
    },

    -- Creates a portal, teleporting group members that use it to Silvermoon.
    portal_silvermoon = {
        id = 32267,
        cast = 10.0,
        cooldown = 60.0,
        gcd = "global",

        spend = 0.040,
        spendType = 'mana',

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': TRANS_DOOR, 'subtype': NONE, 'value': 182352, 'schools': ['frost', 'arcane'], 'radius': 3.0, 'target': TARGET_DEST_CASTER_FRONT, }
    },

    -- Creates a portal, teleporting group members that use it to Stonard.
    portal_stonard = {
        id = 49361,
        cast = 10.0,
        cooldown = 60.0,
        gcd = "global",

        spend = 0.040,
        spendType = 'mana',

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': TRANS_DOOR, 'subtype': NONE, 'value': 189994, 'schools': ['holy', 'nature', 'shadow'], 'radius': 3.0, 'target': TARGET_DEST_CASTER_FRONT, }
    },

    -- Creates a portal, teleporting group members that use it to Stormshield.
    portal_stormshield = {
        id = 176246,
        cast = 10.0,
        cooldown = 60.0,
        gcd = "global",

        spend = 0.040,
        spendType = 'mana',

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': TRANS_DOOR, 'subtype': NONE, 'value': 237623, 'schools': ['physical', 'holy', 'fire', 'frost', 'shadow'], 'radius': 3.0, 'target': TARGET_DEST_CASTER_FRONT, }
    },

    -- Creates a portal, teleporting group members that use it to Stormwind.
    portal_stormwind = {
        id = 10059,
        cast = 10.0,
        cooldown = 60.0,
        gcd = "global",

        spend = 0.040,
        spendType = 'mana',

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': TRANS_DOOR, 'subtype': NONE, 'value': 176296, 'schools': ['nature', 'shadow'], 'radius': 3.0, 'target': TARGET_DEST_CASTER_FRONT, }

        -- Affected by:
        -- icy_veins[12472] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 100.0, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_9, }
    },

    -- Creates a portal, teleporting group members that use it to Theramore.
    portal_theramore = {
        id = 49360,
        cast = 10.0,
        cooldown = 60.0,
        gcd = "global",

        spend = 0.040,
        spendType = 'mana',

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': TRANS_DOOR, 'subtype': NONE, 'value': 189993, 'schools': ['physical', 'nature', 'shadow'], 'radius': 3.0, 'target': TARGET_DEST_CASTER_FRONT, }
    },

    -- Creates a portal, teleporting group members that use it to Thunder Bluff.
    portal_thunder_bluff = {
        id = 11420,
        cast = 10.0,
        cooldown = 60.0,
        gcd = "global",

        spend = 0.040,
        spendType = 'mana',

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': TRANS_DOOR, 'subtype': NONE, 'value': 176500, 'schools': ['fire', 'frost', 'shadow', 'arcane'], 'radius': 3.0, 'target': TARGET_DEST_CASTER_FRONT, }

        -- Affected by:
        -- icy_veins[12472] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 100.0, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_9, }
    },

    -- Creates a portal, teleporting group members that use it to Tol Barad.
    portal_tol_barad = {
        id = 88345,
        cast = 10.0,
        cooldown = 60.0,
        gcd = "global",

        spend = 0.040,
        spendType = 'mana',

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': TRANS_DOOR, 'subtype': NONE, 'value': 206615, 'schools': ['physical', 'holy', 'fire', 'frost'], 'radius': 3.0, 'target': TARGET_DEST_CASTER_FRONT, }
    },

    -- Creates a portal, teleporting group members that use it to Tol Barad.
    portal_tol_barad_88346 = {
        id = 88346,
        cast = 10.0,
        cooldown = 60.0,
        gcd = "global",

        spend = 0.040,
        spendType = 'mana',

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': TRANS_DOOR, 'subtype': NONE, 'value': 206616, 'schools': ['nature', 'frost'], 'radius': 3.0, 'target': TARGET_DEST_CASTER_FRONT, }
        from = "class",
    },

    -- Creates a portal, teleporting group members that use it to Undercity.
    portal_undercity = {
        id = 11418,
        cast = 10.0,
        cooldown = 60.0,
        gcd = "global",

        spend = 0.040,
        spendType = 'mana',

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': TRANS_DOOR, 'subtype': NONE, 'value': 176501, 'schools': ['physical', 'fire', 'frost', 'shadow', 'arcane'], 'radius': 3.0, 'target': TARGET_DEST_CASTER_FRONT, }

        -- Affected by:
        -- icy_veins[12472] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 100.0, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_9, }
    },

    -- Creates a portal, teleporting group members that use it to Valdrakken.
    portal_valdrakken = {
        id = 395289,
        cast = 10.0,
        cooldown = 60.0,
        gcd = "global",

        spend = 0.040,
        spendType = 'mana',

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': TRANS_DOOR, 'subtype': NONE, 'value': 384641, 'schools': ['physical'], 'radius': 3.0, 'target': TARGET_DEST_CASTER_FRONT, }
    },

    -- Creates a portal, teleporting group members that use it to Vale of Eternal Blossoms.
    portal_vale_of_eternal_blossoms = {
        id = 132620,
        cast = 10.0,
        cooldown = 60.0,
        gcd = "global",

        spend = 0.040,
        spendType = 'mana',

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': TRANS_DOOR, 'subtype': NONE, 'value': 216057, 'schools': ['physical', 'nature', 'frost', 'shadow', 'arcane'], 'radius': 3.0, 'target': TARGET_DEST_CASTER_FRONT, }
    },

    -- Creates a portal, teleporting group members that use it to Vale of Eternal Blossoms.
    portal_vale_of_eternal_blossoms_132626 = {
        id = 132626,
        cast = 10.0,
        cooldown = 60.0,
        gcd = "global",

        spend = 0.040,
        spendType = 'mana',

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': TRANS_DOOR, 'subtype': NONE, 'value': 216058, 'schools': ['holy', 'nature', 'frost', 'shadow', 'arcane'], 'radius': 3.0, 'target': TARGET_DEST_CASTER_FRONT, }
        from = "class",
    },

    -- Creates a portal, teleporting group members that use it to Warspear.
    portal_warspear = {
        id = 176244,
        cast = 10.0,
        cooldown = 60.0,
        gcd = "global",

        spend = 0.040,
        spendType = 'mana',

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': TRANS_DOOR, 'subtype': NONE, 'value': 237624, 'schools': ['nature', 'frost', 'shadow'], 'radius': 3.0, 'target': TARGET_DEST_CASTER_FRONT, }
    },

    -- Channel an icy beam at the enemy for $d, dealing $s2 Frost damage every $t2 sec and slowing movement by $s4%. Each time Ray of Frost deals damage, its damage and snare increases by $208141s1%.; Generates $s3 charges of Fingers of Frost over its duration.
    ray_of_frost = {
        id = 205021,
        cast = 5.0,
        channeled = true,
        cooldown = 60.0,
        gcd = "global",

        spend = 0.020,
        spendType = 'mana',

        talent = "ray_of_frost",
        startsCombat = true,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': MOD_DECREASE_SPEED, 'attributes': ['Suppress Points Stacking'], 'mechanic': snared, 'points': -60.0, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #1: { 'type': APPLY_AURA, 'subtype': PERIODIC_DAMAGE, 'tick_time': 1.0, 'sp_bonus': 1.954, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #2: { 'type': DUMMY, 'subtype': NONE, }
        -- #3: { 'type': DUMMY, 'subtype': NONE, }

        -- Affected by:
        -- mastery_icicles[321684] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 0.75, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- frigid_winds[235224] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -10.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_1_VALUE, }
        -- frigid_winds[235224] #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -10.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_4_VALUE, }
        -- cryopathy[417492] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.5, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- ray_of_frost[208141] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- ray_of_frost[208141] #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -10.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_1_VALUE, }
    },

    -- Removes all Curses from a friendly target. $?s115700[If any Curses are successfully removed, you deal $115701s1% additional damage for $115701d.][]
    remove_curse = {
        id = 475,
        cast = 0.0,
        cooldown = 8.0,
        gcd = "global",

        spend = 0.013,
        spendType = 'mana',

        talent = "remove_curse",
        startsCombat = false,

        -- Effects:
        -- #0: { 'type': DISPEL, 'subtype': NONE, 'points': 100.0, 'value': 2, 'schools': ['holy'], 'target': TARGET_UNIT_TARGET_ALLY, }
    },

    -- Summons a Ring of Fire for $353103d at the target location. Enemies entering the ring burn for ${$353084s2*3}% of their total health over $353084d.
    ring_of_fire = {
        id = 353082,
        color = 'pvp_talent',
        cast = 2.0,
        cooldown = 30.0,
        gcd = "global",

        spend = 0.025,
        spendType = 'mana',

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': CREATE_AREATRIGGER, 'subtype': NONE, 'points': 1.0, 'value': 22981, 'schools': ['physical', 'fire', 'arcane'], 'target': TARGET_DEST_DEST, }
        -- #1: { 'type': DUMMY, 'subtype': NONE, 'radius': 8.5, 'target': TARGET_DEST_DEST, }

        -- Affected by:
        -- elemental_affinity[431067] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -30.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
    },

    -- Summons a Ring of Frost for $d at the target location. Enemies entering the ring are incapacitated for $82691d. Limit 10 targets.; When the incapacitate expires, enemies are slowed by $321329s1% for $321329d.
    ring_of_frost = {
        id = 113724,
        cast = 2.0,
        cooldown = 45.0,
        gcd = "global",

        spend = 0.080,
        spendType = 'mana',

        talent = "ring_of_frost",
        startsCombat = false,

        -- Effects:
        -- #0: { 'type': SUMMON, 'subtype': NONE, 'points': 1.0, 'value': 44199, 'schools': ['physical', 'holy', 'fire', 'shadow'], 'value1': 3018, 'target': TARGET_DEST_DEST, }
        -- #1: { 'type': TRIGGER_SPELL, 'subtype': NONE, 'trigger_spell': 136511, 'points': 10.0, 'target': TARGET_UNIT_CASTER, }
        -- #2: { 'type': DUMMY, 'subtype': NONE, 'radius': 6.5, 'target': TARGET_DEST_DEST, }

        -- Affected by:
        -- ice_floes[108839] #0: { 'type': APPLY_AURA, 'subtype': CAST_WHILE_WALKING, 'target': TARGET_UNIT_CASTER, }
        -- elemental_affinity[431067] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -30.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
    },

    -- Summons a Ring of Frost at the target location. Enemies entering the ring will become frozen for $82691d. Lasts $d. $s2 yd radius. Limit 10 targets.
    ring_of_frost_136511 = {
        id = 136511,
        cast = 0.0,
        cooldown = 45.0,
        gcd = "none",

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': PERIODIC_TRIGGER_SPELL, 'tick_time': 0.1, 'points': 10.0, 'target': TARGET_UNIT_CASTER, }

        -- Affected by:
        -- elemental_affinity[431067] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -30.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
        from = "triggered_spell",
    },

    -- Draw power from within, dealing ${$382445s1*$d/$t} Arcane damage over $d to enemies within $382445A1 yds. ; While channeling, your Mage ability cooldowns are reduced by ${-$s2/1000*$d/$t} sec over $d.
    shifting_power = {
        id = 382440,
        cast = 0.0,
        cooldown = 60.0,
        gcd = "global",

        spend = 0.050,
        spendType = 'mana',

        talent = "shifting_power",
        startsCombat = false,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': PERIODIC_TRIGGER_SPELL, 'tick_time': 1.0, 'trigger_spell': 382445, 'target': TARGET_UNIT_CASTER, }
        -- #1: { 'type': APPLY_AURA, 'subtype': DUMMY, 'points': -3000.0, 'target': TARGET_UNIT_CASTER, }
    },

    -- Teleports you $A1 yds forward, unless something is in the way. Unaffected by the global cooldown and castable while casting.$?a382289[; Gain a shield that absorbs $382289s1% of your maximum health for $382290d after you Shimmer.][]
    shimmer = {
        id = 212653,
        cast = 0.0,
        cooldown = 0.5,
        gcd = "none",

        spend = 0.020,
        spendType = 'mana',

        talent = "shimmer",
        startsCombat = false,

        -- Effects:
        -- #0: { 'type': LEAP, 'subtype': NONE, 'radius': 20.0, 'target': TARGET_UNIT_CASTER, 'target2': TARGET_DEST_CASTER_FRONT_LEAP, }
        -- #1: { 'type': APPLY_AURA, 'subtype': CAST_WHILE_WALKING_2, 'target': TARGET_UNIT_CASTER, }
    },

    -- Reduces the target's movement speed by $s1% for $d.$?a391102[; Applies to enemies within $391104A1 yds of the target.][] 
    slow = {
        id = 31589,
        cast = 0.0,
        cooldown = 0.0,
        gcd = "global",

        spend = 0.010,
        spendType = 'mana',

        talent = "slow",
        startsCombat = true,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': MOD_DECREASE_SPEED, 'chain_targets': 1, 'mechanic': snared, 'points': -50.0, 'target': TARGET_UNIT_TARGET_ENEMY, }

        -- Affected by:
        -- frigid_winds[235224] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -10.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_1_VALUE, }
    },

    -- Slows a group member's falling speed for $d.
    slow_fall = {
        id = 130,
        cast = 0.0,
        cooldown = 0.0,
        gcd = "global",

        spend = 0.010,
        spendType = 'mana',

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': FEATHER_FALL, 'target': TARGET_UNIT_TARGET_RAID, }
    },

    -- Summon a strong Blizzard that surrounds you for $d that slows enemies by $389823s2% and deals $390171s1 Frost damage every $390171d. ; Enemies that are caught in Snowdrift for $389823d consecutively become Frozen in ice, stunned for $389831d.
    snowdrift = {
        id = 389794,
        cast = 0.0,
        cooldown = 45.0,
        gcd = "global",

        spend = 0.025,
        spendType = 'mana',

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': AREA_TRIGGER, 'value': 26730, 'schools': ['holy', 'nature', 'shadow', 'arcane'], 'target': TARGET_UNIT_CASTER, }
    },

    -- Steals $?s198100[all beneficial magic effects from the target. These effects lasts a maximum of 2 min.][a beneficial magic effect from the target. This effect lasts a maximum of 2 min.] $?s115713[If you successfully steal a spell, you are also healed for $115714s1% of your maximum health.][]
    spellsteal = {
        id = 30449,
        cast = 0.0,
        cooldown = 0.0,
        gcd = "global",

        spend = 0.210,
        spendType = 'mana',

        talent = "spellsteal",
        startsCombat = true,

        -- Effects:
        -- #0: { 'type': STEAL_BENEFICIAL_BUFF, 'subtype': NONE, 'points': 1.0, 'value': 1, 'schools': ['physical'], 'target': TARGET_UNIT_TARGET_ENEMY, }

        -- Affected by:
        -- arcane_mage[137021] #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -67.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
    },

    -- Pulses arcane energy around the target enemy or ally, dealing $s2 Arcane damage to all enemies within $A2 yds, and knocking them upward. A primary enemy target will take $s1% increased damage.
    supernova = {
        id = 157980,
        cast = 0.0,
        cooldown = 45.0,
        gcd = "global",

        talent = "supernova",
        startsCombat = true,

        -- Effects:
        -- #0: { 'type': DUMMY, 'subtype': NONE, 'target': TARGET_UNIT_TARGET_ANY, }
        -- #1: { 'type': SCHOOL_DAMAGE, 'subtype': NONE, 'sp_bonus': 0.345, 'variance': 0.05, 'radius': 8.0, 'target': TARGET_DEST_TARGET_ANY, 'target2': TARGET_UNIT_DEST_AREA_ENEMY, }
        -- #2: { 'type': KNOCK_BACK_DEST, 'subtype': NONE, 'mechanic': knockbacked, 'points': 100.0, 'radius': 8.0, 'target': TARGET_DEST_TARGET_ANY, 'target2': TARGET_UNIT_DEST_AREA_ENEMY, }

        -- Affected by:
        -- unerring_proficiency[444981] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 16.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
    },

    -- Teleports you to Boralus.
    teleport_boralus = {
        id = 281403,
        cast = 10.0,
        cooldown = 0.0,
        gcd = "global",

        spend = 0.040,
        spendType = 'mana',

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': RITUAL_ACTIVATE_PORTAL, 'subtype': NONE, 'amplitude': 1.0, 'value': 1500, 'schools': ['fire', 'nature', 'frost', 'arcane'], 'value1': 208631, 'target': TARGET_UNIT_CASTER, 'target2': TARGET_DEST_DB, }
        -- #1: { 'type': SCRIPT_EFFECT, 'subtype': NONE, 'sp_bonus': 0.25, 'target': TARGET_UNIT_CASTER, }
    },

    -- Teleports you to Dalaran in the Broken Isles.
    teleport_dalaran_broken_isles = {
        id = 224869,
        cast = 10.0,
        cooldown = 0.0,
        gcd = "global",

        spend = 0.030,
        spendType = 'mana',

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': RITUAL_ACTIVATE_PORTAL, 'subtype': NONE, 'amplitude': 1.0, 'value': 1500, 'schools': ['fire', 'nature', 'frost', 'arcane'], 'value1': 208631, 'target': TARGET_UNIT_CASTER, 'target2': TARGET_DEST_DB, }
        -- #1: { 'type': SCRIPT_EFFECT, 'subtype': NONE, 'sp_bonus': 0.25, 'target': TARGET_UNIT_CASTER, }
    },

    -- Teleports you to Dalaran in Northrend.
    teleport_dalaran_northrend = {
        id = 53140,
        cast = 10.0,
        cooldown = 0.0,
        gcd = "global",

        spend = 0.030,
        spendType = 'mana',

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': RITUAL_ACTIVATE_PORTAL, 'subtype': NONE, 'amplitude': 1.0, 'value': 1500, 'schools': ['fire', 'nature', 'frost', 'arcane'], 'value1': 208631, 'target': TARGET_UNIT_CASTER, 'target2': TARGET_DEST_DB, }
        -- #1: { 'type': SCRIPT_EFFECT, 'subtype': NONE, 'sp_bonus': 0.25, 'target': TARGET_UNIT_CASTER, }
    },

    -- Teleports you to Darnassus.
    teleport_darnassus = {
        id = 3565,
        cast = 10.0,
        cooldown = 0.0,
        gcd = "global",

        spend = 0.030,
        spendType = 'mana',

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': RITUAL_ACTIVATE_PORTAL, 'subtype': NONE, 'amplitude': 1.0, 'value': 1500, 'schools': ['fire', 'nature', 'frost', 'arcane'], 'value1': 208631, 'target': TARGET_UNIT_CASTER, 'target2': TARGET_DEST_DB, }
        -- #1: { 'type': SCRIPT_EFFECT, 'subtype': NONE, 'sp_bonus': 0.25, 'target': TARGET_UNIT_CASTER, }
    },

    -- Teleports you to Dazar'alor.
    teleport_dazaralor = {
        id = 281404,
        cast = 10.0,
        cooldown = 0.0,
        gcd = "global",

        spend = 0.040,
        spendType = 'mana',

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': RITUAL_ACTIVATE_PORTAL, 'subtype': NONE, 'amplitude': 1.0, 'value': 1500, 'schools': ['fire', 'nature', 'frost', 'arcane'], 'value1': 208631, 'target': TARGET_UNIT_CASTER, 'target2': TARGET_DEST_DB, }
        -- #1: { 'type': SCRIPT_EFFECT, 'subtype': NONE, 'sp_bonus': 0.25, 'target': TARGET_UNIT_CASTER, }
    },

    -- Teleports you to Dornogal.
    teleport_dornogal = {
        id = 446540,
        cast = 10.0,
        cooldown = 0.0,
        gcd = "global",

        spend = 0.030,
        spendType = 'mana',

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': RITUAL_ACTIVATE_PORTAL, 'subtype': NONE, 'amplitude': 1.0, 'value': 1500, 'schools': ['fire', 'nature', 'frost', 'arcane'], 'value1': 208631, 'target': TARGET_UNIT_CASTER, 'target2': TARGET_DEST_DB, }
        -- #1: { 'type': SCRIPT_EFFECT, 'subtype': NONE, 'sp_bonus': 0.25, 'target': TARGET_UNIT_CASTER, }
    },

    -- Teleports you to Exodar.
    teleport_exodar = {
        id = 32271,
        cast = 10.0,
        cooldown = 0.0,
        gcd = "global",

        spend = 0.030,
        spendType = 'mana',

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': RITUAL_ACTIVATE_PORTAL, 'subtype': NONE, 'amplitude': 1.0, 'value': 1500, 'schools': ['fire', 'nature', 'frost', 'arcane'], 'value1': 208631, 'target': TARGET_UNIT_CASTER, 'target2': TARGET_DEST_DB, }
        -- #1: { 'type': SCRIPT_EFFECT, 'subtype': NONE, 'sp_bonus': 0.25, 'target': TARGET_UNIT_CASTER, }
    },

    -- Teleports you to the Hall of the Guardian.
    teleport_hall_of_the_guardian = {
        id = 193759,
        cast = 10.0,
        cooldown = 60.0,
        gcd = "global",

        spend = 0.001,
        spendType = 'mana',

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': TELEPORT_UNITS, 'subtype': NONE, 'amplitude': 1.0, 'value': 1317, 'schools': ['physical', 'fire', 'shadow'], 'target': TARGET_UNIT_CASTER, 'target2': TARGET_DEST_DB, }
        -- #1: { 'type': KILL_CREDIT, 'subtype': NONE, 'value': 103132, 'schools': ['fire', 'nature', 'frost', 'arcane'], 'target': TARGET_UNIT_CASTER, }
    },

    -- Teleports you to Ironforge.
    teleport_ironforge = {
        id = 3562,
        cast = 10.0,
        cooldown = 0.0,
        gcd = "global",

        spend = 0.030,
        spendType = 'mana',

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': RITUAL_ACTIVATE_PORTAL, 'subtype': NONE, 'amplitude': 1.0, 'value': 1500, 'schools': ['fire', 'nature', 'frost', 'arcane'], 'value1': 208631, 'target': TARGET_UNIT_CASTER, 'target2': TARGET_DEST_DB, }
        -- #1: { 'type': SCRIPT_EFFECT, 'subtype': NONE, 'sp_bonus': 0.25, 'target': TARGET_UNIT_CASTER, }
    },

    -- Teleports you to Orgrimmar.
    teleport_orgrimmar = {
        id = 3567,
        cast = 10.0,
        cooldown = 0.0,
        gcd = "global",

        spend = 0.030,
        spendType = 'mana',

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': RITUAL_ACTIVATE_PORTAL, 'subtype': NONE, 'amplitude': 1.0, 'value': 1500, 'schools': ['fire', 'nature', 'frost', 'arcane'], 'value1': 208631, 'target': TARGET_UNIT_CASTER, 'target2': TARGET_DEST_DB, }
        -- #1: { 'type': SCRIPT_EFFECT, 'subtype': NONE, 'sp_bonus': 0.25, 'target': TARGET_UNIT_CASTER, }
    },

    -- Teleports you to Oribos.
    teleport_oribos = {
        id = 344587,
        cast = 10.0,
        cooldown = 0.0,
        gcd = "global",

        spend = 0.030,
        spendType = 'mana',

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': RITUAL_ACTIVATE_PORTAL, 'subtype': NONE, 'amplitude': 1.0, 'value': 1500, 'schools': ['fire', 'nature', 'frost', 'arcane'], 'value1': 208631, 'target': TARGET_UNIT_CASTER, 'target2': TARGET_DEST_DB, }
        -- #1: { 'type': SCRIPT_EFFECT, 'subtype': NONE, 'sp_bonus': 0.25, 'target': TARGET_UNIT_CASTER, }
    },

    -- Teleports you to Shattrath.
    teleport_shattrath = {
        id = 33690,
        cast = 10.0,
        cooldown = 0.0,
        gcd = "global",

        spend = 0.030,
        spendType = 'mana',

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': RITUAL_ACTIVATE_PORTAL, 'subtype': NONE, 'amplitude': 1.0, 'value': 1500, 'schools': ['fire', 'nature', 'frost', 'arcane'], 'value1': 208631, 'target': TARGET_UNIT_CASTER, 'target2': TARGET_DEST_DB, }
        -- #1: { 'type': SCRIPT_EFFECT, 'subtype': NONE, 'sp_bonus': 0.25, 'target': TARGET_UNIT_CASTER, }
    },

    -- Teleports you to Shattrath.
    teleport_shattrath_35715 = {
        id = 35715,
        cast = 10.0,
        cooldown = 0.0,
        gcd = "global",

        spend = 0.030,
        spendType = 'mana',

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': RITUAL_ACTIVATE_PORTAL, 'subtype': NONE, 'amplitude': 1.0, 'value': 1500, 'schools': ['fire', 'nature', 'frost', 'arcane'], 'value1': 208631, 'target': TARGET_UNIT_CASTER, 'target2': TARGET_DEST_DB, }
        -- #1: { 'type': SCRIPT_EFFECT, 'subtype': NONE, 'sp_bonus': 0.25, 'target': TARGET_UNIT_CASTER, }
        from = "class",
    },

    -- Teleports you to Silvermoon.
    teleport_silvermoon = {
        id = 32272,
        cast = 10.0,
        cooldown = 0.0,
        gcd = "global",

        spend = 0.030,
        spendType = 'mana',

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': RITUAL_ACTIVATE_PORTAL, 'subtype': NONE, 'amplitude': 1.0, 'value': 1500, 'schools': ['fire', 'nature', 'frost', 'arcane'], 'value1': 208631, 'target': TARGET_UNIT_CASTER, 'target2': TARGET_DEST_DB, }
        -- #1: { 'type': SCRIPT_EFFECT, 'subtype': NONE, 'sp_bonus': 0.25, 'target': TARGET_UNIT_CASTER, }
    },

    -- Teleports you to Stonard.
    teleport_stonard = {
        id = 49358,
        cast = 10.0,
        cooldown = 0.0,
        gcd = "global",

        spend = 0.030,
        spendType = 'mana',

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': RITUAL_ACTIVATE_PORTAL, 'subtype': NONE, 'amplitude': 1.0, 'value': 1500, 'schools': ['fire', 'nature', 'frost', 'arcane'], 'value1': 208631, 'target': TARGET_UNIT_CASTER, 'target2': TARGET_DEST_DB, }
        -- #1: { 'type': SCRIPT_EFFECT, 'subtype': NONE, 'sp_bonus': 0.25, 'target': TARGET_UNIT_CASTER, }
    },

    -- Teleports you to Stormshield.
    teleport_stormshield = {
        id = 176248,
        cast = 10.0,
        cooldown = 0.0,
        gcd = "global",

        spend = 0.030,
        spendType = 'mana',

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': RITUAL_ACTIVATE_PORTAL, 'subtype': NONE, 'amplitude': 1.0, 'value': 1500, 'schools': ['fire', 'nature', 'frost', 'arcane'], 'value1': 208631, 'target': TARGET_UNIT_CASTER, 'target2': TARGET_DEST_DB, }
        -- #1: { 'type': SCRIPT_EFFECT, 'subtype': NONE, 'sp_bonus': 0.25, 'target': TARGET_UNIT_CASTER, }
    },

    -- Teleports you to Stormwind.
    teleport_stormwind = {
        id = 3561,
        cast = 10.0,
        cooldown = 0.0,
        gcd = "global",

        spend = 0.030,
        spendType = 'mana',

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': RITUAL_ACTIVATE_PORTAL, 'subtype': NONE, 'amplitude': 1.0, 'value': 1500, 'schools': ['fire', 'nature', 'frost', 'arcane'], 'value1': 208631, 'target': TARGET_UNIT_CASTER, 'target2': TARGET_DEST_DB, }
        -- #1: { 'type': SCRIPT_EFFECT, 'subtype': NONE, 'sp_bonus': 0.25, 'target': TARGET_UNIT_CASTER, }
    },

    -- Teleports you to Theramore.
    teleport_theramore = {
        id = 49359,
        cast = 10.0,
        cooldown = 0.0,
        gcd = "global",

        spend = 0.030,
        spendType = 'mana',

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': RITUAL_ACTIVATE_PORTAL, 'subtype': NONE, 'amplitude': 1.0, 'value': 1500, 'schools': ['fire', 'nature', 'frost', 'arcane'], 'value1': 208631, 'target': TARGET_UNIT_CASTER, 'target2': TARGET_DEST_DB, }
        -- #1: { 'type': SCRIPT_EFFECT, 'subtype': NONE, 'sp_bonus': 0.25, 'target': TARGET_UNIT_CASTER, }
    },

    -- Teleports you to Thunder Bluff.
    teleport_thunder_bluff = {
        id = 3566,
        cast = 10.0,
        cooldown = 0.0,
        gcd = "global",

        spend = 0.030,
        spendType = 'mana',

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': RITUAL_ACTIVATE_PORTAL, 'subtype': NONE, 'amplitude': 1.0, 'value': 1500, 'schools': ['fire', 'nature', 'frost', 'arcane'], 'value1': 208631, 'target': TARGET_UNIT_CASTER, 'target2': TARGET_DEST_DB, }
        -- #1: { 'type': SCRIPT_EFFECT, 'subtype': NONE, 'sp_bonus': 0.25, 'target': TARGET_UNIT_CASTER, }
    },

    -- Teleports you to Tol Barad.
    teleport_tol_barad = {
        id = 88342,
        cast = 10.0,
        cooldown = 0.0,
        gcd = "global",

        spend = 0.030,
        spendType = 'mana',

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': RITUAL_ACTIVATE_PORTAL, 'subtype': NONE, 'amplitude': 1.0, 'value': 1500, 'schools': ['fire', 'nature', 'frost', 'arcane'], 'value1': 208631, 'target': TARGET_UNIT_CASTER, 'target2': TARGET_DEST_DB, }
        -- #1: { 'type': SCRIPT_EFFECT, 'subtype': NONE, 'sp_bonus': 0.25, 'target': TARGET_UNIT_CASTER, }
    },

    -- Teleports you to Tol Barad.
    teleport_tol_barad_88344 = {
        id = 88344,
        cast = 10.0,
        cooldown = 0.0,
        gcd = "global",

        spend = 0.030,
        spendType = 'mana',

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': RITUAL_ACTIVATE_PORTAL, 'subtype': NONE, 'amplitude': 1.0, 'value': 1500, 'schools': ['fire', 'nature', 'frost', 'arcane'], 'value1': 208631, 'target': TARGET_UNIT_CASTER, 'target2': TARGET_DEST_DB, }
        -- #1: { 'type': SCRIPT_EFFECT, 'subtype': NONE, 'sp_bonus': 0.25, 'target': TARGET_UNIT_CASTER, }
        from = "class",
    },

    -- Teleports you to Undercity.
    teleport_undercity = {
        id = 3563,
        cast = 10.0,
        cooldown = 0.0,
        gcd = "global",

        spend = 0.030,
        spendType = 'mana',

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': RITUAL_ACTIVATE_PORTAL, 'subtype': NONE, 'amplitude': 1.0, 'value': 1500, 'schools': ['fire', 'nature', 'frost', 'arcane'], 'value1': 208631, 'target': TARGET_UNIT_CASTER, 'target2': TARGET_DEST_DB, }
        -- #1: { 'type': SCRIPT_EFFECT, 'subtype': NONE, 'sp_bonus': 0.25, 'target': TARGET_UNIT_CASTER, }
    },

    -- Teleports you to Valdrakken.
    teleport_valdrakken = {
        id = 395277,
        cast = 10.0,
        cooldown = 0.0,
        gcd = "global",

        spend = 0.030,
        spendType = 'mana',

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': RITUAL_ACTIVATE_PORTAL, 'subtype': NONE, 'amplitude': 1.0, 'value': 1500, 'schools': ['fire', 'nature', 'frost', 'arcane'], 'value1': 208631, 'target': TARGET_UNIT_CASTER, 'target2': TARGET_DEST_DB, }
        -- #1: { 'type': SCRIPT_EFFECT, 'subtype': NONE, 'sp_bonus': 0.25, 'target': TARGET_UNIT_CASTER, }
    },

    -- Teleports you to Vale of Eternal Blossoms.
    teleport_vale_of_eternal_blossoms = {
        id = 132621,
        cast = 10.0,
        cooldown = 0.0,
        gcd = "global",

        spend = 0.030,
        spendType = 'mana',

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': RITUAL_ACTIVATE_PORTAL, 'subtype': NONE, 'amplitude': 1.0, 'value': 1500, 'schools': ['fire', 'nature', 'frost', 'arcane'], 'value1': 208631, 'target': TARGET_UNIT_CASTER, 'target2': TARGET_DEST_DB, }
        -- #1: { 'type': SCRIPT_EFFECT, 'subtype': NONE, 'sp_bonus': 0.25, 'target': TARGET_UNIT_CASTER, }
    },

    -- Teleports you to Vale of Eternal Blossoms.
    teleport_vale_of_eternal_blossoms_132627 = {
        id = 132627,
        cast = 10.0,
        cooldown = 0.0,
        gcd = "global",

        spend = 0.030,
        spendType = 'mana',

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': RITUAL_ACTIVATE_PORTAL, 'subtype': NONE, 'amplitude': 1.0, 'value': 1500, 'schools': ['fire', 'nature', 'frost', 'arcane'], 'value1': 208631, 'target': TARGET_UNIT_CASTER, 'target2': TARGET_DEST_DB, }
        -- #1: { 'type': SCRIPT_EFFECT, 'subtype': NONE, 'sp_bonus': 0.25, 'target': TARGET_UNIT_CASTER, }
        from = "class",
    },

    -- Teleports you to Warspear.
    teleport_warspear = {
        id = 176242,
        cast = 10.0,
        cooldown = 0.0,
        gcd = "global",

        spend = 0.030,
        spendType = 'mana',

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': RITUAL_ACTIVATE_PORTAL, 'subtype': NONE, 'amplitude': 1.0, 'value': 1500, 'schools': ['fire', 'nature', 'frost', 'arcane'], 'value1': 208631, 'target': TARGET_UNIT_CASTER, 'target2': TARGET_DEST_DB, }
        -- #1: { 'type': SCRIPT_EFFECT, 'subtype': NONE, 'sp_bonus': 0.25, 'target': TARGET_UNIT_CASTER, }
    },

    -- Warp the flow of time, increasing haste by $s1% $?a320919[and time rate by $s4% ][]for all party and raid members for $d.; Allies will be unable to benefit from Bloodlust, Heroism, or Time Warp again for $57724d.$?a320920[; When the effect ends, all affected players are frozen in time for $356346d.][]
    time_warp = {
        id = 80353,
        cast = 0.0,
        cooldown = 300.0,
        gcd = "none",

        spend = 0.040,
        spendType = 'mana',

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': MELEE_SLOW, 'sp_bonus': 0.25, 'points': 30.0, 'radius': 50000.0, 'target': TARGET_UNIT_CASTER_AREA_RAID, }
        -- #1: { 'type': APPLY_AURA, 'subtype': MOD_SCALE, 'points': 30.0, 'radius': 50000.0, 'target': TARGET_UNIT_CASTER_AREA_RAID, }
        -- #2: { 'type': APPLY_AURA, 'subtype': DUMMY, 'target': TARGET_UNIT_CASTER, }
        -- #3: { 'type': APPLY_AURA, 'subtype': MOD_TIME_RATE, 'target': TARGET_UNIT_CASTER, }

        -- Affected by:
        -- echoes_of_elisande[320919] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 30.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_4_VALUE, }
    },

} )