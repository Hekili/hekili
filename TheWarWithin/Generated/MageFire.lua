-- MageFire.lua
-- July 2024

local addon, ns = ...
local Hekili = _G[ addon ]
local class, state = Hekili.Class, Hekili.State

local spec = Hekili:NewSpecialization( 63 )

-- Resources
spec:RegisterResource( Enum.PowerType.Mana )
spec:RegisterResource( Enum.PowerType.ArcaneCharges )

spec:RegisterTalents( {
    -- Mage Talents
    accumulative_shielding    = { 62093, 382800, 1 }, -- Your barrier's cooldown recharges $s1% faster while the shield persists.
    alter_time                = { 62115, 342245, 1 }, -- Alters the fabric of time, returning you to your current location and health when cast a second time, or after ${$110909d+$s3} sec.  Effect negated by long distance or death.
    arcane_warding            = { 62114, 383092, 2 }, -- Reduces magic damage taken by $s1%.
    barrier_diffusion         = { 62091, 455428, 1 }, -- Whenever one of your Barriers is removed, reduce its cooldown by ${$s1/1000}  sec.
    blast_wave                = { 62103, 157981, 1 }, -- Causes an explosion around yourself, dealing $s1 Fire damage to all enemies within $A1 yds, knocking them back, and reducing movement speed by $s2% for $d.
    cryofreeze                = { 62107, 382292, 2 }, -- While inside Ice Block, you heal for ${$s1*10}% of your maximum health over the duration.
    displacement              = { 62095, 389713, 1 }, -- Teleports you back to where you last Blinked and heals you for ${$414462s1/100*$mhp} health. Only usable within $389714d of Blinking.
    diverted_energy           = { 62101, 382270, 2 }, -- Your Barriers heal you for $s1% of the damage absorbed.
    dragons_breath            = { 101883, 31661 , 1 }, -- Enemies in a cone in front of you take $s2 Fire damage and are disoriented for $d. Damage will cancel the effect.$?a235870[; Always deals a critical strike and contributes to Hot Streak.][]
    energized_barriers        = { 62100, 386828, 1 }, -- When your barrier receives melee attacks, you have a $s1% chance to be granted $?c1[Clearcasting]?c2[1 Fire Blast charge]$?c3[Fingers of Frost]. ; Casting your barrier removes all snare effects.
    flow_of_time              = { 62096, 382268, 2 }, -- The cooldowns of Blink and Shimmer are reduced by ${$s1/-1000} sec.
    freezing_cold             = { 62087, 386763, 1 }, -- Enemies hit by Cone of Cold are frozen in place for $386770d instead of snared.; When your roots expire or are dispelled, your target is snared by $394255s1%, decaying over $394255d.
    frigid_winds              = { 62128, 235224, 2 }, -- All of your snare effects reduce the target's movement speed by an additional $s1%.
    greater_invisibility      = { 93524, 110959, 1 }, -- Makes you invisible and untargetable for $110960d, removing all threat. Any action taken cancels this effect.; You take $113862s1% reduced damage while invisible and for 3 sec after reappearing.$?a382293[; Increases your movement speed by ${$382293s1*0.40}% for $337278d.][]
    ice_block                 = { 62122, 45438 , 1 }, -- Encases you in a block of ice, protecting you from all attacks and damage for $d, but during that time you cannot attack, move, or cast spells.$?a382292[; While inside Ice Block, you heal for ${$382292s1*10}% of your maximum health over the duration.][]; Causes Hypothermia, preventing you from recasting Ice Block for $41425d.
    ice_cold                  = { 62085, 414659, 1 }, -- Ice Block now reduces all damage taken by $414658s8% for $414658d but no longer grants Immunity, prevents movement, attacks, or casting spells. Does not incur the Global Cooldown.
    ice_floes                 = { 62105, 108839, 1 }, -- Makes your next Mage spell with a cast time shorter than $s2 sec castable while moving. Unaffected by the global cooldown and castable while casting.
    ice_nova                  = { 62088, 157997, 1 }, -- Causes a whirl of icy wind around the enemy, dealing $s1 Frost damage to the target and reduced damage to all other enemies within $a2 yds, and freezing them in place for $d.
    ice_ward                  = { 62086, 205036, 1 }, -- Frost Nova now has ${1+$m1} charges.
    improved_frost_nova       = { 62108, 343183, 1 }, -- Frost Nova duration is increased by ${$s1/1000} sec.
    incantation_of_swiftness  = { 62112, 382293, 2 }, -- $?s110959[Greater ][]Invisibility increases your movement speed by $s1% for $337278d.
    incanters_flow            = { 62118, 1463  , 1 }, -- Magical energy flows through you while in combat, building up to ${$116267m1*5}% increased damage and then diminishing down to $116267s1% increased damage, cycling every 10 sec.
    inspired_intellect        = { 62094, 458437, 1 }, -- Arcane Intellect grants you an additional $s1% Intellect.
    mass_barrier              = { 62092, 414660, 1 }, -- Cast $?c1[Prismatic]?c2[Blazing]?c3[Ice][] Barrier on yourself and $414661i allies within $s2 yds.
    mass_invisibility         = { 62092, 414664, 1 }, -- You and your allies within $A1 yards instantly become invisible for $d. Taking any action will cancel the effect.; $?a415945[]; [Does not affect allies in combat.]
    mass_polymorph            = { 62106, 383121, 1 }, -- Transforms all enemies within $a yards into sheep, wandering around incapacitated for $d. While affected, the victims cannot take actions but will regenerate health very quickly. Damage will cancel the effect.; Only works on Beasts, Humanoids and Critters.
    master_of_time            = { 62102, 342249, 1 }, -- Reduces the cooldown of Alter Time by ${$s1/-1000} sec. ; Alter Time resets the cooldown of Blink and Shimmer when you return to your original location.
    mirror_image              = { 62124, 55342 , 1 }, -- Creates $s2 copies of you nearby for $55342d, which cast spells and attack your enemies.; While your images are active damage taken is reduced by $s3%. Taking direct damage will cause one of your images to dissipate.$?a382820[; You are healed for $382998s1% of your maximum health whenever a Mirror Image dissipates due to direct damage.]?a382569[; Mirror Image's cooldown is reduced by ${$382569s1/1000} sec whenever a Mirror Image dissipates due to direct damage.][]
    overflowing_energy        = { 62120, 390218, 1 }, -- Your spell critical strike damage is increased by $s1%. When your direct damage spells fail to critically strike a target, your spell critical strike chance is increased by $394195s1%, up to ${$394195u*$394195s1}% for $394195d. ; When your spells critically strike Overflowing Energy is reset.
    quick_witted              = { 62104, 382297, 1 }, -- Successfully interrupting an enemy with Counterspell reduces its cooldown by ${$s1/1000} sec.
    reabsorption              = { 62125, 382820, 1 }, -- You are healed for $382998s1% of your maximum health whenever a Mirror Image dissipates due to direct damage.
    reduplication             = { 62125, 382569, 1 }, -- Mirror Image's cooldown is reduced by ${$s1/1000} sec whenever a Mirror Image dissipates due to direct damage.
    remove_curse              = { 62116, 475   , 1 }, -- Removes all Curses from a friendly target. $?s115700[If any Curses are successfully removed, you deal $115701s1% additional damage for $115701d.][]
    rigid_ice                 = { 62110, 382481, 1 }, -- Frost Nova can withstand $s1% more damage before breaking.
    ring_of_frost             = { 62088, 113724, 1 }, -- Summons a Ring of Frost for $d at the target location. Enemies entering the ring are incapacitated for $82691d. Limit 10 targets.; When the incapacitate expires, enemies are slowed by $321329s1% for $321329d.
    shifting_power            = { 62113, 382440, 1 }, -- Draw power from within, dealing ${$382445s1*$d/$t} Arcane damage over $d to enemies within $382445A1 yds. ; While channeling, your Mage ability cooldowns are reduced by ${-$s2/1000*$d/$t} sec over $d.
    shimmer                   = { 62105, 212653, 1 }, -- Teleports you $A1 yds forward, unless something is in the way. Unaffected by the global cooldown and castable while casting.$?a382289[; Gain a shield that absorbs $382289s1% of your maximum health for $382290d after you Shimmer.][]
    slow                      = { 62097, 31589 , 1 }, -- Reduces the target's movement speed by $s1% for $d.$?a391102[; Applies to enemies within $391104A1 yds of the target.][] 
    spellsteal                = { 62084, 30449 , 1 }, -- Steals $?s198100[all beneficial magic effects from the target. These effects lasts a maximum of 2 min.][a beneficial magic effect from the target. This effect lasts a maximum of 2 min.] $?s115713[If you successfully steal a spell, you are also healed for $115714s1% of your maximum health.][]
    supernova                 = { 101883, 157980, 1 }, -- Pulses arcane energy around the target enemy or ally, dealing $s2 Arcane damage to all enemies within $A2 yds, and knocking them upward. A primary enemy target will take $s1% increased damage.
    tempest_barrier           = { 62111, 382289, 2 }, -- Gain a shield that absorbs $s1% of your maximum health for $382290d after you Blink.
    temporal_velocity         = { 62099, 382826, 2 }, -- Increases your movement speed by $s2% for $384360d after casting Blink and $s1% for $382824d after returning from Alter Time.
    time_anomaly              = { 62094, 383243, 1 }, -- At any moment, you have a chance to gain $?c1[Arcane Surge for $s1 sec, Clearcasting]?c2[Combustion for $s4 sec, 1 Fire Blast charge]?c3[Icy Veins for $s5 sec, Brain Freeze][], or Time Warp for 6 sec.
    time_manipulation         = { 62129, 387807, 1 }, -- Casting $?c1[Clearcasting Arcane Missiles]?c2[Fire Blast]?c3[Ice Lance on Frozen targets][] reduces the cooldown of your loss of control abilities by ${-$s1/1000} sec.
    tome_of_antonidas         = { 62098, 382490, 1 }, -- Increases Haste by $s1%. 
    tome_of_rhonin            = { 62127, 382493, 1 }, -- Increases Critical Strike chance by $s1%.
    volatile_detonation       = { 62089, 389627, 1 }, -- Greatly increases the effect of Blast Wave's knockback. Blast Wave's cooldown is reduced by ${$s1/-1000} sec
    winters_protection        = { 62123, 382424, 2 }, -- The cooldown of Ice Block is reduced by ${$s1/-1000} sec.

    -- Fire Talents
    alexstraszas_fury         = { 101945, 235870, 1 }, -- Dragon's Breath always critically strikes, deals $s2% increased critical strike damage, and contributes to Hot Streak. 
    ashen_feather             = { 101945, 450813, 1 }, -- If Phoenix Flames only hits $s1 target, it deals $s2% increased damage and applies Ignite at $s3% effectiveness.
    blast_zone                = { 101022, 451755, 1 }, -- Lit Fuse now turns up to $s1 targets into Living Bombs.; Living Bombs can now spread to $s2 enemies.
    blazing_barrier           = { 62119, 235313, 1 }, -- Shields you in flame, absorbing $<shield> damage$?s194315[ and reducing Physical damage taken by $s3%][] for $d.; Melee attacks against you cause the attacker to take $235314s1 Fire damage.
    burden_of_power           = { 94644, 451035, 1 }, -- Conjuring a Spellfire Sphere increases the damage of your next $?c1[Arcane Blast by $451049s2% or your next Arcane Barrage by $451049s4%][Pyroblast by $451049s1% or your next Flamestrike by $451049s3%].
    call_of_the_sun_king      = { 100991, 343222, 1 }, -- Phoenix Flames gains $s1 additional charge and always critically strikes.
    codex_of_the_sunstriders  = { 94643, 449382, 1 }, -- [461145] Increases your spell damage by $?c1[$448604s1][$448604s6]%.
    combustion                = { 100995, 190319, 1 }, -- Engulfs you in flames for $d, increasing your spells' critical strike chance by $s1% $?a383967[and granting you Mastery equal to $s3% of your Critical Strike stat][]. Castable while casting other spells.$?a383489[; When you activate Combustion, you gain $383489s3% Critical Strike damage, and up to $383493I nearby allies gain $383489s4% Critical Strike for $383493d.][]
    controlled_destruction    = { 101002, 383669, 1 }, -- Damaging a target with Pyroblast increases the damage it receives from Ignite by ${$s2/100}.1%. Stacks up to $453268u times.
    convection                = { 100992, 416715, 1 }, -- When a Living Bomb expires, if it did not spread to another target, it reapplies itself at $s1% effectiveness.; A Living Bomb can only benefit from this effect once.
    critical_mass             = { 101029, 117216, 1 }, -- Your spells have a $s1% increased chance to deal a critical strike.; You gain $s2% more of the Critical Strike stat from all sources.
    deep_impact               = { 101000, 416719, 1 }, -- Meteor now turns $s2 $Ltarget:targets; hit into a Living Bomb. Additionally, its cooldown is reduced by ${$s1/-1000} sec.
    elemental_affinity        = { 94633, 431067, 1 }, -- $?c2[The cooldown of Frost spells with a base cooldown shorter than $s4 minutes is reduced by $s1%.]?c3[The cooldown of Fire spells is reduced by $s3%.][]
    excess_fire               = { 94637, 438595, 1 }, -- Reaching maximum stacks of Fire Mastery causes your next $?c2[Fire Blast]?c3[Ice Lance][] to apply Living Bomb at $s1% effectiveness.; When this Living Bomb explodes, $?c2[reduce the cooldown of Phoenix Flames by $s2 sec]?c3[gain Brain Freeze][].
    excess_frost              = { 94639, 438600, 1 }, -- Reaching maximum stacks of Frost Mastery causes your next $?c2[Phoenix Flames]?c3[Flurry][] to also cast Ice Nova at $s1% effectiveness.; When you consume Excess Frost, the cooldown of $?c2[Meteor]?c3[Comet Storm][] is reduced by $s2 sec.
    explosive_ingenuity       = { 101013, 451760, 1 }, -- Your chance of gaining Lit Fuse when consuming Hot Streak is increased by $s1%.; Living Bomb damage increased by $s2%.
    explosivo                 = { 100993, 451757, 1 }, -- Casting Combustion grants Lit Fuse and Living Bomb's damage is increased by $s2% while under the effects of Combustion.$?a450716[; Your chance of gaining Lit Fuse is increased by $s1% while under the effects of Combustion.][]
    feel_the_burn             = { 101014, 383391, 1 }, -- Fire Blast and Phoenix Flames increase your mastery by ${$s1*$mas}% for $383395d. This effect stacks up to $383395u times.
    fervent_flickering        = { 101027, 387044, 1 }, -- Fire Blast's cooldown is reduced by $s2 sec. 
    fevered_incantation       = { 101019, 383810, 2 }, -- Each consecutive critical strike you deal increases critical strike damage you deal by $s1%, up to ${ $s1*$383811u}% for $383811d.
    fiery_rush                = { 101003, 383634, 1 }, -- While Combustion is active, your Fire Blast and Phoenix Flames recharge $383637s2% faster.
    fire_blast                = { 100989, 108853, 1 }, -- Blasts the enemy for $s1 Fire damage. ; Fire: Castable while casting other spells. Always deals a critical strike.
    firefall                  = { 100996, 384033, 1 }, -- Damaging an enemy with $s1 Fireballs or Pyroblasts causes your next Fireball or Pyroblast to call down a Meteor on your target$?a134735[ at $s2% effectiveness][].
    fires_ire                 = { 101004, 450831, 2 }, -- When you're not under the effect of Combustion, your critical strike chance is increased by ${$w3/1000}.1%.; While you're under the effect of Combustion, your critical strike damage is increased by ${$w3/1000}.1%.
    firestarter               = { 102014, 205026, 1 }, -- Your Fireball and Pyroblast spells always deal a critical strike when the target is above $s1% health.
    flame_accelerant          = { 102012, 453282, 1 }, -- Every $s2 seconds, your next non-instant Fireball, Flamestrike, or Pyroblast has a $s3% reduced cast time.
    flame_and_frost           = { 94633, 431112, 1 }, -- $?c2[Cauterize resets the cooldown of your Frost spells with a base cooldown shorter than $s1 minutes when it activates.]?c3[Cold Snap additionally resets the cooldowns of your Fire spells.][]
    flame_on                  = { 101009, 205029, 1 }, -- Increases the maximum number of Fire Blast charges by $s1.
    flame_patch               = { 101021, 205037, 1 }, -- Flamestrike leaves behind a patch of flames that burns enemies within it for ${8*$205472s1} Fire damage over $205470d. Deals reduced damage beyond $205472s2 targets.
    flash_freezeburn          = { 94635, 431178, 1 }, -- Frostfire Empowerment grants you maximum benefit of Frostfire Mastery and refreshes its duration.; Activating Combustion or Icy Veins grants you Frostfire Empowerment.
    from_the_ashes            = { 100999, 342344, 1 }, -- Phoenix Flames damage increased by $s2% and your direct-damage spells reduce the cooldown of Phoenix Flames by ${$s1/-1000} sec.
    frostfire_bolt            = { 94641, 431044, 1 }, -- Launches a bolt of frostfire at the enemy, causing $s1 Frostfire damage, slowing movement speed by $s3%, and causing an additional $o2 Frostfire damage over $d.; Frostfire Bolt generates stacks for both Fire Mastery and Frost Mastery.
    frostfire_empowerment     = { 94632, 431176, 1 }, -- Your Frost and Fire spells have a chance to activate Frostfire Empowerment, causing your next Frostfire Bolt to be instant cast, deal $431177s3% increased damage, explode for $s2% of its damage to nearby enemies, and grant you maximum benefit of Frostfire Mastery and refresh its duration.
    frostfire_infusion        = { 94634, 431166, 1 }, -- Your Frost and Fire spells have a chance to trigger an additional bolt of Frostfire, dealing $431171s1 damage.; This effect generates Frostfire Mastery when activated.
    frostfire_mastery         = { 94636, 431038, 1 }, -- Your damaging Fire spells generate $s1 stack of Fire Mastery and Frost spells generate $s1 stack of Frost Mastery.; Fire Mastery increases your haste by $431040s1%, and Frost Mastery increases your Mastery by $431039s1% for $431039d, stacking up to $431039u times each.; Adding stacks does not refresh duration.
    glorious_incandescence    = { 94645, 449394, 1 }, -- Consuming Burden of Power causes your next cast of $?c1[Arcane Barrage to grant $s4 Arcane Charges and][Fire Blast to] call down a storm of $s1 Meteorites on its target.$?c1[][; Each Meteorite's impact reduces the cooldown of Fire Blast by ${$s2/1000}.1 sec.]
    gravity_lapse             = { 94651, 458513, 1 }, -- [449700] The snap of your fingers warps the gravity around your target and $s2 other nearby enemies, suspending them in the air for $449700d.; Upon landing, nearby enemies take $449715s1 Arcane damage.
    heat_shimmer              = { 102010, 457735, 1 }, -- Damage from Ignite has a $s1% chance to make your next Scorch have no cast time and deal damage as though your target was below $s2% health.
    hyperthermia              = { 101942, 383860, 1 }, -- While Combustion is not active, consuming Hot Streak has a low chance to cause all Pyroblasts and Flamestrikes to have no cast time and be guaranteed critical strikes for $383874d.
    ignite_the_future         = { 94648, 449558, 1 }, -- Generating a Spellfire Sphere while your Phoenix is active causes it to cast an exceptional spell.
    imbued_warding            = { 94642, 431066, 1 }, -- $?c2[Blazing Barrier also casts an Ice Barrier at $s1% effectiveness.]?c3[Ice Barrier also casts a Blazing Barrier at $s2% effectiveness.][]
    improved_combustion       = { 101007, 383967, 1 }, -- Combustion grants mastery equal to $s2% of your Critical Strike stat and lasts ${$s1/1000} sec longer. 
    improved_scorch           = { 101011, 383604, 1 }, -- Casting Scorch on targets below $s1% health increase the target's damage taken from you by $383608s1% for $383608d. This effect stacks up to $383608u times.
    inflame                   = { 102013, 417467, 1 }, -- Hot Streak increases the amount of Ignite damage from Pyroblast or Flamestrike by an additional $s1%.
    intensifying_flame        = { 101017, 416714, 1 }, -- While Ignite is on $s1 or fewer enemies it flares up dealing an additional $s2% of its damage to affected targets.
    invocation_arcane_phoenix = { 94652, 448658, 1 }, -- When you cast $?c1[Arcane Surge][Combustion], summon an Arcane Phoenix to aid you in battle.; $@spellicon448659  $@spellname448659; Your Arcane Phoenix aids you for the duration of your $?c1[Arcane Surge][Combustion], casting random Arcane and Fire spells.
    isothermic_core           = { 94638, 431095, 1 }, -- Comet Storm now also calls down a Meteor at $s1% effectiveness onto your target's location.; Meteor now also calls down a Comet Storm at $s2% effectiveness onto your target location.
    kindling                  = { 101024, 155148, 1 }, -- Your Fireball, Pyroblast, Fire Blast, Scorch and Phoenix Flames critical strikes reduce the remaining cooldown on Combustion by $<cdr> sec.; Flamestrike critical strikes reduce the remaining cooldown of Combustion by ${$s1/1000/$s2}.1 sec for each critical strike, up to ${$s1/1000} sec.
    lessons_in_debilitation   = { 94651, 449627, 1 }, -- Your Arcane Phoenix will Spellsteal when it is summoned and when it expires.
    lit_fuse                  = { 100994, 450716, 1 }, -- Consuming Hot Streak has a $s4% chance to grant you Lit Fuse.; $@spellicon450716 $@spellname450716:; Your next Fire Blast turns up to $s2 nearby $Ltarget:targets; into a Living Bomb that explodes after $217694d, dealing $44461s2 Fire damage to the target and reduced damage to all other enemies within $44461A2 yds.; Up to $s3 enemies hit by this explosion also become a Living Bomb, but this effect cannot spread further.
    majesty_of_the_phoenix    = { 101008, 451440, 1 }, -- When Phoenix Flames damages $s1 or more targets, your next $453329u Flamestrikes have their cast time reduced by ${$453329s2/1000*-1}.1 sec and their damage is increased by $453329s1%.
    mana_cascade              = { 94653, 449293, 1 }, -- $?c1[Casting Arcane Blast or Arcane Barrage][Consuming Hot Streak] grants you $?c1[${$449322s1}.1][${$449314s2/10}.1]% Haste for $449322d1. Stacks up to $449314u times. Multiple instances may overlap.
    mark_of_the_firelord      = { 100988, 450325, 1 }, -- Flamestrike and Living Bomb apply Mastery: Ignite at $s1% increased effectiveness.
    master_of_flame           = { 101006, 384174, 1 }, -- Ignite deals $s1% more damage while Combustion is not active. Fire Blast spreads Ignite to $s2 additional nearby targets during Combustion.
    meltdown                  = { 94642, 431131, 1 }, -- You melt slightly out of your Ice Block and Ice Cold, allowing you to move slowly during Ice Block and increasing your movement speed over time.; Ice Block and Ice Cold trigger a Blazing Barrier when they end.
    memory_of_alar            = { 94646, 449619, 1 }, -- [451038] Arcane Barrage grants Clearcasting and generates 4 Arcane Charges.
    merely_a_setback          = { 94649, 449330, 1 }, -- Your $?c1[Prismatic Barrier][Blazing Barrier] now grants 5% avoidance while active and 5% leech for 5 seconds when it breaks or expires.
    meteor                    = { 101016, 153561, 1 }, -- Calls down a meteor which lands at the target location after $177345d, dealing $351140s1 Fire damage$?a416719[, split evenly between all targets within 8 yds][ to all enemies hit reduced beyond 8 targets], and burns the ground, dealing ${8*$155158s1} Fire damage over $175396d to all enemies in the area.
    molten_fury               = { 101015, 457803, 1 }, -- Damage dealt to targets below $s1% health is increased by $458910s1%.
    phoenix_flames            = { 101012, 257541, 1 }, -- Hurls a Phoenix that deals $257542s2 Fire damage to the target and reduced damage to other nearby enemies.$?a343222[; Always deals a critical strike.][]
    phoenix_reborn            = { 101943, 453123, 1 }, -- When your direct damage spells hit an enemy $408673u times the damage of your next $409964u Phoenix Flames is increased by $409964s1% and they refund a charge on use.
    pyroblast                 = { 100998, 11366 , 1 }, -- Hurls an immense fiery boulder that causes $s1 Fire damage$?a321711[ and an additional $321712o2 Fire damage over $321712d][].
    pyromaniac                = { 101020, 451466, 1 }, -- Casting Pyroblast or Flamestrike while Hot Streak is active has an $s1% chance to repeat the spell cast at $s2% effectiveness.; This effect counts as consuming Hot Streak.
    pyrotechnics              = { 100997, 157642, 1 }, -- Each time your Fireball fails to critically strike a target, it gains a stacking $157644s1% increased critical strike chance. Effect ends when Fireball critically strikes.
    quickflame                = { 101021, 450807, 1 }, -- Flamestrike damage increased by $s1%.
    rondurmancy               = { 94648, 449596, 1 }, -- Spellfire Spheres can now stack up to $s2 times.
    savor_the_moment          = { 94650, 449412, 1 }, -- When you cast $?c1[Arcane Surge][Combustion], its duration is extended by ${$s1/1000}.1 sec for each Spellfire Sphere you have, up to ${$s2/1000}.1 sec.
    scald                     = { 101011, 450746, 1 }, -- Scorch deals $s1% increased damage to targets below $2948s2% health.
    scorch                    = { 100987, 2948  , 1 }, -- Scorches an enemy for $s1 Fire damage.; Scorch is a guaranteed critical strike$?a450746[, deals $450746s1% increased damage,][] and increases your movement speed by $236060s1% for $236060d when cast on a target below $s2% health.; Castable while moving.
    severe_temperatures       = { 94640, 431189, 1 }, -- Casting damaging Frost or Fire spells has a high chance to increase the damage of your next Frostfire Bolt by $431190s1%, stacking up to $431190u times.
    sparking_cinders          = { 102011, 457728, 1 }, -- Living Bomb explosions have a small chance to increase the damage of your next Pyroblast by $457729s1% or Flamestrike by $457729s2%.
    spellfire_spheres         = { 94647, 448601, 1 }, -- [448604] Increases your spell damage by $?c1[$s1][$s6]%. Stacks up to $u times.
    spontaneous_combustion    = { 101007, 451875, 1 }, -- Casting Combustion refreshes up to $s1 charges of Fire Blast and up to $s2 charges of Phoenix Flames.
    sun_kings_blessing        = { 101025, 383886, 1 }, -- After consuming $s1 Hot Streaks, your next non-instant Pyroblast or Flamestrike cast within $383883d grants you Combustion for $s2 sec and deals $383883s2% additional damage.
    sunfury_execution         = { 94650, 449349, 1 }, -- [384581] Arcane Barrage deals an additional $s2% damage against targets below $s1% health.
    surging_blaze             = { 101023, 343230, 1 }, -- Pyroblast and Flamestrike's cast time is reduced by ${$s1/-1000}.1 sec and their damage dealt is increased by $s2%.
    thermal_conditioning      = { 94640, 431117, 1 }, -- Frostfire Bolt's cast time is reduced by $s1%.
    unleashed_inferno         = { 101025, 416506, 1 }, -- While Combustion is active your Fireball, Pyroblast, Fire Blast, Scorch, and Phoenix Flames deal $s1% increased damage and reduce the cooldown of Combustion by ${$s2/1000}.2 sec.; While Combustion is active, Flamestrike deals $s4% increased damage and reduces the cooldown of Combustion by ${$s2/1000/$s3}.2 sec for each critical strike, up to ${$s2/1000}.2 sec.
    wildfire                  = { 101001, 383489, 1 }, -- Your critical strike damage is increased by $s2%. When you activate Combustion, you gain $s3% additional critical strike damage, and up to $383493I nearby allies gain $s4% critical strike for $383493d.
} )

-- PvP Talents
spec:RegisterPvpTalents( {
    ethereal_blink             = 5602, -- (410939) Blink and Shimmer apply Slow at $s2% effectiveness to all enemies you Blink through. For each enemy you Blink through, the cooldown of Blink and Shimmer are reduced by $s3 sec, up to $s4 sec.
    fireheart                  = 5656, -- (460942) Blazing Barrier's damage is increased by $s1%.
    glass_cannon               = 5495, -- (390428) Increases damage of Fireball, Scorch, and Ignite by $s1% but decreases your maximum health by $s2%.; 
    greater_pyroblast          = 648 , -- (203286) Hurls an immense fiery boulder that deals up to $s3% of the target's total health in Fire damage.
    ice_wall                   = 5489, -- (352278) Conjures an Ice Wall $s3 yards long that obstructs line of sight. The wall has $s4% of your maximum health and lasts up to $d.
    improved_mass_invisibility = 5621, -- (415945) The cooldown of Mass Invisibility is reduced by ${$s1/-60000} min and can affect allies in combat.
    master_shepherd            = 5588, -- (410248) While an enemy player is affected by your Polymorph or Mass Polymorph, your movement speed is increased by $410259s1% and your Versatility is increased by $410259s2%. ; Additionally, Polymorph and Mass Polymorph no longer heal enemies.
    ring_of_fire               = 5389, -- (353082) Summons a Ring of Fire for $353103d at the target location. Enemies entering the ring burn for ${$353084s2*3}% of their total health over $353084d.
    world_in_flames            = 644 , -- (203280) Empower Flamestrike, dealing up to $s2% more damage based on enemies' distance to the center of Flamestrike.
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
        -- fire_mage[137019] #17: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_2_VALUE, }
        -- fire_mage[137019] #18: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'pvp_multiplier': 0.0, 'points': -20.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_2_VALUE, }
        -- frigid_winds[235224] #6: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -10.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_2_VALUE, }
        -- volatile_detonation[389627] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -5000.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
        -- elemental_affinity[431067] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -30.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
        -- arcane_mage[137021] #6: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_2_VALUE, }
        -- arcane_mage[137021] #7: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'pvp_multiplier': 0.0, 'points': -20.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_2_VALUE, }
    },
    -- Absorbs $w1 damage.; Melee attackers take $235314s1 Fire damage. $?a449330[; Avoidance increased by $449336s1%.][]
    blazing_barrier = {
        id = 235313,
        duration = 60.0,
        max_stack = 1,

        -- Affected by:
        -- accumulative_shielding[382800] #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 30.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_4_VALUE, }
        -- blazing_barrier[235313] #3: { 'type': APPLY_AURA, 'subtype': ABILITY_PERIODIC_CRIT, 'target': TARGET_UNIT_CASTER, }
    },
    -- $s1% increased movement speed and unaffected by movement speed slowing effects.
    blazing_speed = {
        id = 108843,
        duration = 6.0,
        max_stack = 1,
    },
    -- Blinking.
    blink = {
        id = 1953,
        duration = 0.3,
        max_stack = 1,
    },
    -- Your next $?c1[Arcane Blast deals $s2% increased damage or your next Arcane Barrage deals $s4% increased damage][Pyroblast deals $s1% increased damage or your next Flamestrike deals $s3% increased damage].
    burden_of_power = {
        id = 451049,
        duration = 12.0,
        max_stack = 1,
    },
    -- Building up to Flame's Fury.
    calefaction = {
        id = 408673,
        duration = 60.0,
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
    -- Critical Strike chance of your spells increased by $w1%.$?e1[; Mastery increased by $w2.][]
    combustion = {
        id = 190319,
        duration = 10.0,
        tick_time = 0.5,
        max_stack = 1,

        -- Affected by:
        -- improved_combustion[383967] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 2000.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
        -- improved_combustion[383967] #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 75.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_3_VALUE, }
        -- unleashed_inferno[416506] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'pvp_multiplier': 0.3, 'points': 60.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_4_VALUE, }
        -- unleashed_inferno[416506] #3: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'pvp_multiplier': 0.0, 'points': 35.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_5_VALUE, }
        -- spellfire_sphere[448604] #2: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
    },
    -- Movement slowed by $s1%.
    cone_of_cold = {
        id = 120,
        duration = 0.0,
        max_stack = 1,

        -- Affected by:
        -- fire_mage[137019] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- fire_mage[137019] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- overflowing_energy[390218] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_15, }
        -- combustion[190319] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 100.0, 'target': TARGET_UNIT_CASTER, 'modifies': CRIT_CHANCE, }
        -- elemental_affinity[431067] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -30.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
        -- fires_ire[450831] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_15, }
        -- wildfire[383489] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.75, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_15, }
        -- arcane_mage[137021] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- arcane_mage[137021] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- incanters_flow[116267] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- incanters_flow[116267] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- overflowing_energy[394195] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': CRIT_CHANCE, }
        -- spellfire_sphere[448604] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- spellfire_sphere[448604] #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- improved_scorch[383608] #0: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'points': 6.0, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- molten_fury[458910] #0: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'points': 7.0, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- wildfire[383492] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_15, }
    },
    -- Taking ${$383669s2/100}.1% increased damage from Ignite.
    controlled_destruction = {
        id = 453268,
        duration = 180.0,
        max_stack = 1,
    },
    -- Disoriented.
    dragons_breath = {
        id = 31661,
        duration = 4.0,
        max_stack = 1,

        -- Affected by:
        -- fire_mage[137019] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- fire_mage[137019] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- overflowing_energy[390218] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_15, }
        -- alexstraszas_fury[235870] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 100000.0, 'target': TARGET_UNIT_CASTER, 'modifies': CRIT_CHANCE, }
        -- alexstraszas_fury[235870] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 50.0, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_15, }
        -- combustion[190319] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 100.0, 'target': TARGET_UNIT_CASTER, 'modifies': CRIT_CHANCE, }
        -- elemental_affinity[431067] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -30.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
        -- fires_ire[450831] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_15, }
        -- wildfire[383489] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.75, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_15, }
        -- arcane_mage[137021] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- arcane_mage[137021] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- incanters_flow[116267] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- incanters_flow[116267] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- overflowing_energy[394195] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': CRIT_CHANCE, }
        -- spellfire_sphere[448604] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- spellfire_sphere[448604] #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- improved_scorch[383608] #0: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'points': 6.0, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- molten_fury[458910] #0: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'points': 7.0, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- wildfire[383492] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_15, }
    },
    -- Time Warp also increases the rate at which time passes by $s1%.
    echoes_of_elisande = {
        id = 320919,
        duration = 3600,
        max_stack = 1,
    },
    -- Blink and Shimmer apply Slow at $s2% effectiveness to all enemies you Blink through. For each enemy you Blink through, the cooldown of Blink and Shimmer are reduced by $s3 sec, up to $s4 sec.
    ethereal_blink = {
        id = 410939,
        duration = 0.0,
        max_stack = 1,
    },
    -- Mastery increased by ${$w1*$mas}%.
    feel_the_burn = {
        id = 383395,
        duration = 5.0,
        max_stack = 1,
    },
    -- Your spells deal an additional $w1% critical hit damage.
    fevered_incantation = {
        id = 383811,
        duration = 6.0,
        max_stack = 1,
    },
    -- Your Fire Blast and Phoenix Flames recharge $s1% faster.
    fiery_rush = {
        id = 383637,
        duration = 3600,
        max_stack = 1,
    },
    -- Haste increased by $w1%.
    fire_mastery = {
        id = 431040,
        duration = 14.0,
        max_stack = 1,
    },
    -- Movement speed slowed by $s2%.
    flamestrike = {
        id = 2120,
        duration = 8.0,
        pandemic = true,
        max_stack = 1,

        -- Affected by:
        -- fire_mage[137019] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- fire_mage[137019] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- ice_floes[108839] #0: { 'type': APPLY_AURA, 'subtype': CAST_WHILE_WALKING, 'target': TARGET_UNIT_CASTER, }
        -- overflowing_energy[390218] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_15, }
        -- combustion[190319] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 100.0, 'target': TARGET_UNIT_CASTER, 'modifies': CRIT_CHANCE, }
        -- combustion[190319] #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- fires_ire[450831] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_15, }
        -- quickflame[450807] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- surging_blaze[343230] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -500.0, 'target': TARGET_UNIT_CASTER, 'modifies': CAST_TIME, }
        -- surging_blaze[343230] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- wildfire[383489] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.75, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_15, }
        -- arcane_mage[137021] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- arcane_mage[137021] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- incanters_flow[116267] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- incanters_flow[116267] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- overflowing_energy[394195] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': CRIT_CHANCE, }
        -- burden_of_power[451049] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 60.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- spellfire_sphere[448604] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- spellfire_sphere[448604] #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- hyperthermia[383874] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': CAST_TIME, }
        -- hyperthermia[383874] #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 100.0, 'target': TARGET_UNIT_CASTER, 'modifies': CRIT_CHANCE, }
        -- improved_scorch[383608] #0: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'points': 6.0, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- majesty_of_the_phoenix[453329] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'attributes': ['Suppress Points Stacking'], 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- majesty_of_the_phoenix[453329] #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'attributes': ['Suppress Points Stacking'], 'points': -1500.0, 'target': TARGET_UNIT_CASTER, 'modifies': CAST_TIME, }
        -- molten_fury[458910] #0: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'points': 7.0, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- sparking_cinders[457729] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- wildfire[383492] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_15, }
    },
    -- Frozen in place.
    freezing_cold = {
        id = 386770,
        duration = 5.0,
        max_stack = 1,
    },
    -- Frozen in place.
    frost_nova = {
        id = 122,
        duration = 6.0,
        max_stack = 1,

        -- Affected by:
        -- fire_mage[137019] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- fire_mage[137019] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- ice_ward[205036] #0: { 'type': APPLY_AURA, 'subtype': MOD_MAX_CHARGES, 'points': 1.0, 'target': TARGET_UNIT_CASTER, }
        -- improved_frost_nova[343183] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 2000.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
        -- overflowing_energy[390218] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_15, }
        -- combustion[190319] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 100.0, 'target': TARGET_UNIT_CASTER, 'modifies': CRIT_CHANCE, }
        -- elemental_affinity[431067] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -30.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
        -- fires_ire[450831] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_15, }
        -- wildfire[383489] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.75, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_15, }
        -- arcane_mage[137021] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- arcane_mage[137021] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- incanters_flow[116267] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- incanters_flow[116267] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- overflowing_energy[394195] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': CRIT_CHANCE, }
        -- spellfire_sphere[448604] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- spellfire_sphere[448604] #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- improved_scorch[383608] #0: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'points': 6.0, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- molten_fury[458910] #0: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'points': 7.0, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- wildfire[383492] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_15, }
    },
    -- Movement speed reduced by $w3% and receiving $w2 damage every $t2 sec.
    frostfire_bolt = {
        id = 431044,
        duration = 8.0,
        tick_time = 1.0,
        max_stack = 1,

        -- Affected by:
        -- frigid_winds[235224] #8: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -10.0, 'modifies': EFFECT_3_VALUE, }
        -- combustion[190319] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- thermal_conditioning[431117] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -10.0, 'target': TARGET_UNIT_CASTER, 'modifies': CAST_TIME, }
        -- glass_cannon[390428] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 30.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- pyrotechnics[157644] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': CRIT_CHANCE, }
        -- frostfire_empowerment[431177] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 100000.0, 'target': TARGET_UNIT_CASTER, 'modifies': CRIT_CHANCE, }
        -- frostfire_empowerment[431177] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': CAST_TIME, }
        -- frostfire_empowerment[431177] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 50.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- severe_temperatures[431190] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
    },
    -- Your next Frostfire Bolt always critically strikes, deals $s3% additional damage, explodes for $431176s2% of its damage to nearby enemies, and is instant cast.
    frostfire_empowerment = {
        id = 431177,
        duration = 20.0,
        max_stack = 1,
    },
    -- Your next non-instant Pyroblast or Flamestrike will grant you Combustion and deal $w2% additional damage.
    fury_of_the_sun_king = {
        id = 383883,
        duration = 30.0,
        max_stack = 1,
    },
    -- Your next $?c1[Arcane Barrage][Fire Blast] calls down a storm of $s1 Meteorites on its target.
    glorious_incandescence = {
        id = 449394,
        duration = 0.0,
        max_stack = 1,
    },
    -- Suspended in the air.
    gravity_lapse = {
        id = 449700,
        duration = 3.0,
        max_stack = 1,
    },
    -- Invisible$?$w3=0[][ and moving $87833s1% faster].
    greater_invisibility = {
        id = 110960,
        duration = 20.0,
        max_stack = 1,
    },
    -- Your next Pyroblast or Flamestrike spell is instant cast, and causes double the normal Ignite damage.
    hot_streak = {
        id = 195283,
        duration = 0.0,
        max_stack = 1,
    },
    -- Pyroblast and Flamestrike have no cast time and are guaranteed to critically strike.
    hyperthermia = {
        id = 383874,
        duration = 6.0,
        max_stack = 1,
    },
    -- Absorbs $w1 damage.; Melee attackers slowed by $205708s1%.$?s235297[; Armor increased by $s3%.][]
    ice_barrier = {
        id = 414661,
        duration = 60.0,
        max_stack = 1,

        -- Affected by:
        -- accumulative_shielding[382800] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 30.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_4_VALUE, }
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
    -- Frozen.
    ice_nova = {
        id = 157997,
        duration = 2.0,
        max_stack = 1,

        -- Affected by:
        -- elemental_affinity[431067] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -30.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
    },
    -- Deals $w1 Fire damage every $t1 sec.$?$w3>0[; Movement speed reduced by $w3%.][]
    ignite = {
        id = 12654,
        duration = 9.0,
        tick_time = 1.0,
        max_stack = 1,
    },
    -- A faint shimmer surrounds you.
    illusion = {
        id = 94632,
        duration = 120.0,
        max_stack = 1,
    },
    -- Taking $s1% increased damage from $@auracaster's spells and abilities.
    improved_scorch = {
        id = 383608,
        duration = 12.0,
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
    -- After $d, the target explodes, causing $w2 Fire damage to the target and all other enemies within $44461A2 yards, and spreading Living Bomb if it has not already spread.
    living_bomb = {
        id = 217694,
        duration = 2.0,
        tick_time = 1.0,
        pandemic = true,
        max_stack = 1,

        -- Affected by:
        -- explosive_ingenuity[451760] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 25.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
    },
    -- Flamestrike damage increased and cast time reduced.
    majesty_of_the_phoenix = {
        id = 453329,
        duration = 20.0,
        max_stack = 1,
    },
    -- Increases your mana regeneration by $s1%.
    mana_attunement = {
        id = 121039,
        duration = 0.0,
        max_stack = 1,
    },
    -- Haste increased by $s1%
    mana_cascade = {
        id = 449322,
        duration = 10.0,
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
    },
    -- Spell critical strike chance increased by $w1%.
    overflowing_energy = {
        id = 394195,
        duration = 8.0,
        max_stack = 1,
    },
    -- Incapacitated. Cannot attack or cast spells.  Increased health regeneration.
    polymorph = {
        id = 460392,
        duration = 60.0,
        max_stack = 1,
    },
    -- Reduces healing received from critical heals by $w1%.$?$w2>0[; Damage taken increased by $w2.][]
    pvp_rules_enabled_hardcoded = {
        id = 134735,
        duration = 20.0,
        max_stack = 1,
    },
    -- Suffering $w1 Fire damage every $t2 sec.
    pyroblast = {
        id = 321712,
        duration = 6.0,
        tick_time = 2.0,
        max_stack = 1,
    },
    -- Increases critical strike chance of Fireball by $s1%$?a337224[ and your Mastery by ${$s2}.1%][].
    pyrotechnics = {
        id = 157644,
        duration = 15.0,
        max_stack = 1,

        -- Affected by:
        -- flame_accretion[337224] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_2_VALUE, }
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
    -- The damage of your next Pyroblast is increased by $s1% or Flamestrike by $s2%.
    sparking_cinders = {
        id = 457729,
        duration = 20.0,
        max_stack = 1,
    },
    -- Spell damage increased by $w1%.
    spellfire_sphere = {
        id = 448604,
        duration = 604800.0,
        max_stack = 1,

        -- Affected by:
        -- rondurmancy[449596] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER_BY_LABEL, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': MAX_STACKS, }
        -- savor_the_moment[449412] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER_BY_LABEL, 'points': 500.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_3_VALUE, }
        -- savor_the_moment[449412] #2: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER_BY_LABEL, 'points': 500.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_4_VALUE, }
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
    -- Critical Strike increased by $w1%.
    wildfire = {
        id = 383492,
        duration = 10.0,
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
        -- fire_mage[137019] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- fire_mage[137019] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- overflowing_energy[390218] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_15, }
        -- combustion[190319] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 100.0, 'target': TARGET_UNIT_CASTER, 'modifies': CRIT_CHANCE, }
        -- fires_ire[450831] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_15, }
        -- wildfire[383489] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.75, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_15, }
        -- arcane_mage[137021] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- arcane_mage[137021] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- incanters_flow[116267] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- incanters_flow[116267] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- overflowing_energy[394195] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': CRIT_CHANCE, }
        -- spellfire_sphere[448604] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- spellfire_sphere[448604] #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- improved_scorch[383608] #0: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'points': 6.0, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- molten_fury[458910] #0: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'points': 7.0, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- wildfire[383492] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_15, }
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
        -- fire_mage[137019] #17: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_2_VALUE, }
        -- fire_mage[137019] #18: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'pvp_multiplier': 0.0, 'points': -20.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_2_VALUE, }
        -- frigid_winds[235224] #6: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -10.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_2_VALUE, }
        -- volatile_detonation[389627] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -5000.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
        -- elemental_affinity[431067] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -30.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
        -- arcane_mage[137021] #6: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_2_VALUE, }
        -- arcane_mage[137021] #7: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'pvp_multiplier': 0.0, 'points': -20.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_2_VALUE, }
    },

    -- Shields you in flame, absorbing $<shield> damage$?s194315[ and reducing Physical damage taken by $s3%][] for $d.; Melee attacks against you cause the attacker to take $235314s1 Fire damage.
    blazing_barrier = {
        id = 235313,
        cast = 0.0,
        cooldown = 25.0,
        gcd = "global",

        spend = 0.030,
        spendType = 'mana',

        talent = "blazing_barrier",
        startsCombat = false,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': SCHOOL_ABSORB, 'value': 127, 'schools': ['physical', 'holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], 'target': TARGET_UNIT_CASTER, }
        -- #1: { 'type': APPLY_AURA, 'subtype': DUMMY, 'points': 20.0, 'target': TARGET_UNIT_CASTER, }
        -- #2: { 'type': APPLY_AURA, 'subtype': MOD_DAMAGE_PERCENT_TAKEN, 'schools': ['physical'], 'target': TARGET_UNIT_CASTER, }
        -- #3: { 'type': APPLY_AURA, 'subtype': ABILITY_PERIODIC_CRIT, 'target': TARGET_UNIT_CASTER, }

        -- Affected by:
        -- accumulative_shielding[382800] #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 30.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_4_VALUE, }
        -- blazing_barrier[235313] #3: { 'type': APPLY_AURA, 'subtype': ABILITY_PERIODIC_CRIT, 'target': TARGET_UNIT_CASTER, }
    },

    -- Suppresses movement slowing effects and increases your movement speed by $s1% for $d.  Castable while another spell is in progress and unaffected by global cooldown.
    blazing_speed = {
        id = 108843,
        cast = 0.0,
        cooldown = 25.0,
        gcd = "none",

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': MOD_INCREASE_SPEED, 'points': 150.0, 'target': TARGET_UNIT_CASTER, }
        -- #1: { 'type': APPLY_AURA, 'subtype': MOD_MINIMUM_SPEED, 'points': 250.0, 'target': TARGET_UNIT_CASTER, }
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

    -- Engulfs you in flames for $d, increasing your spells' critical strike chance by $s1% $?a383967[and granting you Mastery equal to $s3% of your Critical Strike stat][]. Castable while casting other spells.$?a383489[; When you activate Combustion, you gain $383489s3% Critical Strike damage, and up to $383493I nearby allies gain $383489s4% Critical Strike for $383493d.][]
    combustion = {
        id = 190319,
        cast = 0.0,
        cooldown = 120.0,
        gcd = "none",

        spend = 0.100,
        spendType = 'mana',

        talent = "combustion",
        startsCombat = false,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 100.0, 'target': TARGET_UNIT_CASTER, 'modifies': CRIT_CHANCE, }
        -- #1: { 'type': APPLY_AURA, 'subtype': MOD_RATING, 'value': 33554432, 'target': TARGET_UNIT_CASTER, }
        -- #2: { 'type': APPLY_AURA, 'subtype': PERIODIC_DUMMY, 'tick_time': 0.5, 'target': TARGET_UNIT_CASTER, }
        -- #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- #5: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }

        -- Affected by:
        -- improved_combustion[383967] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 2000.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
        -- improved_combustion[383967] #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 75.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_3_VALUE, }
        -- unleashed_inferno[416506] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'pvp_multiplier': 0.3, 'points': 60.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_4_VALUE, }
        -- unleashed_inferno[416506] #3: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'pvp_multiplier': 0.0, 'points': 35.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_5_VALUE, }
        -- spellfire_sphere[448604] #2: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
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
        -- fire_mage[137019] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- fire_mage[137019] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- overflowing_energy[390218] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_15, }
        -- combustion[190319] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 100.0, 'target': TARGET_UNIT_CASTER, 'modifies': CRIT_CHANCE, }
        -- elemental_affinity[431067] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -30.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
        -- fires_ire[450831] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_15, }
        -- wildfire[383489] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.75, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_15, }
        -- arcane_mage[137021] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- arcane_mage[137021] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- incanters_flow[116267] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- incanters_flow[116267] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- overflowing_energy[394195] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': CRIT_CHANCE, }
        -- spellfire_sphere[448604] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- spellfire_sphere[448604] #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- improved_scorch[383608] #0: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'points': 6.0, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- molten_fury[458910] #0: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'points': 7.0, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- wildfire[383492] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_15, }
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
        -- fire_mage[137019] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- fire_mage[137019] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- overflowing_energy[390218] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_15, }
        -- alexstraszas_fury[235870] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 100000.0, 'target': TARGET_UNIT_CASTER, 'modifies': CRIT_CHANCE, }
        -- alexstraszas_fury[235870] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 50.0, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_15, }
        -- combustion[190319] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 100.0, 'target': TARGET_UNIT_CASTER, 'modifies': CRIT_CHANCE, }
        -- elemental_affinity[431067] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -30.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
        -- fires_ire[450831] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_15, }
        -- wildfire[383489] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.75, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_15, }
        -- arcane_mage[137021] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- arcane_mage[137021] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- incanters_flow[116267] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- incanters_flow[116267] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- overflowing_energy[394195] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': CRIT_CHANCE, }
        -- spellfire_sphere[448604] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- spellfire_sphere[448604] #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- improved_scorch[383608] #0: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'points': 6.0, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- molten_fury[458910] #0: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'points': 7.0, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- wildfire[383492] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_15, }
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
        -- combustion[190319] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- elemental_affinity[431067] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -30.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
        -- flame_on[205029] #0: { 'type': APPLY_AURA, 'subtype': MOD_MAX_CHARGES, 'points': 2.0, 'target': TARGET_UNIT_CASTER, }
        -- fire_blast[231568] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 100.0, 'target': TARGET_UNIT_CASTER, 'modifies': CRIT_CHANCE, }
    },

    -- Blasts the enemy for $s1 Fire damage. ; Fire: Castable while casting other spells. Always deals a critical strike.
    fire_blast_108853 = {
        id = 108853,
        cast = 0.0,
        cooldown = 0.5,
        gcd = "none",

        spend = 0.010,
        spendType = 'mana',

        talent = "fire_blast_108853",
        startsCombat = true,

        -- Effects:
        -- #0: { 'type': SCHOOL_DAMAGE, 'subtype': NONE, 'sp_bonus': 1.31538, 'pvp_multiplier': 0.92, 'variance': 0.05, 'target': TARGET_UNIT_TARGET_ENEMY, }

        -- Affected by:
        -- fire_mage[137019] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- fire_mage[137019] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- overflowing_energy[390218] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_15, }
        -- combustion[190319] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 100.0, 'target': TARGET_UNIT_CASTER, 'modifies': CRIT_CHANCE, }
        -- combustion[190319] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- elemental_affinity[431067] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -30.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
        -- fires_ire[450831] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_15, }
        -- flame_on[205029] #0: { 'type': APPLY_AURA, 'subtype': MOD_MAX_CHARGES, 'points': 2.0, 'target': TARGET_UNIT_CASTER, }
        -- wildfire[383489] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.75, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_15, }
        -- arcane_mage[137021] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- arcane_mage[137021] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- fire_blast[231568] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 100.0, 'target': TARGET_UNIT_CASTER, 'modifies': CRIT_CHANCE, }
        -- incanters_flow[116267] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- incanters_flow[116267] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- overflowing_energy[394195] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': CRIT_CHANCE, }
        -- spellfire_sphere[448604] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- spellfire_sphere[448604] #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- improved_scorch[383608] #0: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'points': 6.0, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- molten_fury[458910] #0: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'points': 7.0, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- wildfire[383492] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_15, }
        from = "spec_talent",
    },

    -- Throws a fiery ball that causes $s1 Fire damage.$?a157642[; Each time your Fireball fails to critically strike a target, it gains a stacking $157644s1% increased critical strike chance. Effect ends when Fireball critically strikes.][]
    fireball = {
        id = 133,
        cast = 2.25,
        cooldown = 0.0,
        gcd = "global",

        spend = 0.020,
        spendType = 'mana',

        startsCombat = true,

        -- Effects:
        -- #0: { 'type': SCHOOL_DAMAGE, 'subtype': NONE, 'attributes': ['Add Target (Dest) Combat Reach to AOE', 'Area Effects Use Target Radius', 'Chain from Initial Target'], 'sp_bonus': 1.29833, 'chain_targets': 1, 'pvp_multiplier': 1.35, 'variance': 0.05, 'target': TARGET_UNIT_TARGET_ENEMY, }

        -- Affected by:
        -- fire_mage[137019] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- fire_mage[137019] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- ice_floes[108839] #0: { 'type': APPLY_AURA, 'subtype': CAST_WHILE_WALKING, 'target': TARGET_UNIT_CASTER, }
        -- overflowing_energy[390218] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_15, }
        -- combustion[190319] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 100.0, 'target': TARGET_UNIT_CASTER, 'modifies': CRIT_CHANCE, }
        -- combustion[190319] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- fires_ire[450831] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_15, }
        -- wildfire[383489] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.75, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_15, }
        -- glass_cannon[390428] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 30.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- pyrotechnics[157644] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': CRIT_CHANCE, }
        -- arcane_mage[137021] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- arcane_mage[137021] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- incanters_flow[116267] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- incanters_flow[116267] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- overflowing_energy[394195] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': CRIT_CHANCE, }
        -- spellfire_sphere[448604] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- spellfire_sphere[448604] #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- improved_scorch[383608] #0: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'points': 6.0, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- molten_fury[458910] #0: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'points': 7.0, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- wildfire[383492] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_15, }
    },

    -- Calls down a pillar of fire, burning all enemies within the area for $s1 Fire damage and reducing their movement speed by $s2% for $d. Deals reduced damage beyond $s3 targets.$?a205037[; Leaves behind a patch of flames that burns enemies within it for ${8*$205472s1} Fire damage over $205470d.][]
    flamestrike = {
        id = 2120,
        cast = 3.5,
        cooldown = 0.0,
        gcd = "global",

        spend = 0.025,
        spendType = 'mana',

        startsCombat = true,

        -- Effects:
        -- #0: { 'type': SCHOOL_DAMAGE, 'subtype': NONE, 'sp_bonus': 0.660043, 'pvp_multiplier': 1.244, 'variance': 0.05, 'radius': 8.0, 'target': TARGET_UNIT_DEST_AREA_ENEMY, }
        -- #1: { 'type': APPLY_AURA, 'subtype': MOD_DECREASE_SPEED, 'mechanic': snared, 'points': -20.0, 'radius': 8.0, 'target': TARGET_UNIT_DEST_AREA_ENEMY, }
        -- #2: { 'type': DUMMY, 'subtype': NONE, }

        -- Affected by:
        -- fire_mage[137019] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- fire_mage[137019] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- ice_floes[108839] #0: { 'type': APPLY_AURA, 'subtype': CAST_WHILE_WALKING, 'target': TARGET_UNIT_CASTER, }
        -- overflowing_energy[390218] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_15, }
        -- combustion[190319] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 100.0, 'target': TARGET_UNIT_CASTER, 'modifies': CRIT_CHANCE, }
        -- combustion[190319] #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- fires_ire[450831] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_15, }
        -- quickflame[450807] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- surging_blaze[343230] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -500.0, 'target': TARGET_UNIT_CASTER, 'modifies': CAST_TIME, }
        -- surging_blaze[343230] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- wildfire[383489] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.75, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_15, }
        -- arcane_mage[137021] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- arcane_mage[137021] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- incanters_flow[116267] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- incanters_flow[116267] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- overflowing_energy[394195] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': CRIT_CHANCE, }
        -- burden_of_power[451049] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 60.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- spellfire_sphere[448604] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- spellfire_sphere[448604] #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- hyperthermia[383874] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': CAST_TIME, }
        -- hyperthermia[383874] #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 100.0, 'target': TARGET_UNIT_CASTER, 'modifies': CRIT_CHANCE, }
        -- improved_scorch[383608] #0: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'points': 6.0, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- majesty_of_the_phoenix[453329] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'attributes': ['Suppress Points Stacking'], 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- majesty_of_the_phoenix[453329] #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'attributes': ['Suppress Points Stacking'], 'points': -1500.0, 'target': TARGET_UNIT_CASTER, 'modifies': CAST_TIME, }
        -- molten_fury[458910] #0: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'points': 7.0, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- sparking_cinders[457729] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- wildfire[383492] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_15, }
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
        -- fire_mage[137019] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- fire_mage[137019] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- ice_ward[205036] #0: { 'type': APPLY_AURA, 'subtype': MOD_MAX_CHARGES, 'points': 1.0, 'target': TARGET_UNIT_CASTER, }
        -- improved_frost_nova[343183] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 2000.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
        -- overflowing_energy[390218] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_15, }
        -- combustion[190319] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 100.0, 'target': TARGET_UNIT_CASTER, 'modifies': CRIT_CHANCE, }
        -- elemental_affinity[431067] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -30.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
        -- fires_ire[450831] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_15, }
        -- wildfire[383489] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.75, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_15, }
        -- arcane_mage[137021] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- arcane_mage[137021] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- incanters_flow[116267] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- incanters_flow[116267] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- overflowing_energy[394195] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': CRIT_CHANCE, }
        -- spellfire_sphere[448604] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- spellfire_sphere[448604] #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- improved_scorch[383608] #0: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'points': 6.0, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- molten_fury[458910] #0: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'points': 7.0, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- wildfire[383492] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_15, }
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
        -- combustion[190319] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- thermal_conditioning[431117] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -10.0, 'target': TARGET_UNIT_CASTER, 'modifies': CAST_TIME, }
        -- glass_cannon[390428] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 30.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- pyrotechnics[157644] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': CRIT_CHANCE, }
        -- frostfire_empowerment[431177] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 100000.0, 'target': TARGET_UNIT_CASTER, 'modifies': CRIT_CHANCE, }
        -- frostfire_empowerment[431177] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': CAST_TIME, }
        -- frostfire_empowerment[431177] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 50.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- severe_temperatures[431190] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
    },

    -- The snap of your fingers warps the gravity around your target and $s2 other nearby enemies, suspending them in the air for $449700d.; Upon landing, nearby enemies take $449715s1 Arcane damage.
    gravity_lapse = {
        id = 449700,
        cast = 0.0,
        cooldown = 30.0,
        gcd = "global",

        startsCombat = true,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': BLOCK_SPELL_FAMILY, 'chain_targets': 3, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #1: { 'type': DUMMY, 'subtype': NONE, 'target': TARGET_UNIT_CASTER, }
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

    -- Hurls an immense fiery boulder that deals up to $s3% of the target's total health in Fire damage.
    greater_pyroblast = {
        id = 203286,
        color = 'pvp_talent',
        cast = 4.5,
        cooldown = 15.0,
        gcd = "global",

        spend = 0.050,
        spendType = 'mana',

        startsCombat = true,

        -- Effects:
        -- #0: { 'type': DAMAGE_FROM_MAX_HEALTH_PCT, 'subtype': NONE, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #1: { 'type': DUMMY, 'subtype': NONE, }
        -- #2: { 'type': DUMMY, 'subtype': NONE, }
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

    -- Calls down a meteor which lands at the target location after $177345d, dealing $351140s1 Fire damage$?a416719[, split evenly between all targets within 8 yds][ to all enemies hit reduced beyond 8 targets], and burns the ground, dealing ${8*$155158s1} Fire damage over $175396d to all enemies in the area.
    meteor = {
        id = 153561,
        cast = 0.0,
        cooldown = 45.0,
        gcd = "global",

        spend = 0.010,
        spendType = 'mana',

        talent = "meteor",
        startsCombat = true,

        -- Effects:
        -- #0: { 'type': DUMMY, 'subtype': NONE, 'radius': 8.0, 'target': TARGET_DEST_DEST, 'target2': TARGET_UNIT_DEST_AREA_ENEMY, }

        -- Affected by:
        -- deep_impact[416719] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -15000.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
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
    },

    -- Hurls a Phoenix that deals $257542s2 Fire damage to the target and reduced damage to other nearby enemies.$?a343222[; Always deals a critical strike.][]
    phoenix_flames = {
        id = 257541,
        cast = 0.0,
        cooldown = 0.0,
        gcd = "global",

        talent = "phoenix_flames",
        startsCombat = true,

        -- Effects:
        -- #0: { 'type': TRIGGER_MISSILE, 'subtype': NONE, 'trigger_spell': 257542, 'target': TARGET_UNIT_TARGET_ENEMY, }

        -- Affected by:
        -- call_of_the_sun_king[343222] #0: { 'type': APPLY_AURA, 'subtype': MOD_MAX_CHARGES, 'points': 1.0, 'target': TARGET_UNIT_CASTER, }
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

        -- Affected by:
        -- call_of_the_sun_king[343222] #0: { 'type': APPLY_AURA, 'subtype': MOD_MAX_CHARGES, 'points': 1.0, 'target': TARGET_UNIT_CASTER, }
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

    -- Hurls an immense fiery boulder that causes $s1 Fire damage$?a321711[ and an additional $321712o2 Fire damage over $321712d][].
    pyroblast = {
        id = 11366,
        cast = 4.0,
        cooldown = 0.0,
        gcd = "global",

        spend = 0.020,
        spendType = 'mana',

        talent = "pyroblast",
        startsCombat = true,

        -- Effects:
        -- #0: { 'type': SCHOOL_DAMAGE, 'subtype': NONE, 'sp_bonus': 1.806, 'pvp_multiplier': 1.124, 'variance': 0.05, 'target': TARGET_UNIT_TARGET_ENEMY, }

        -- Affected by:
        -- fire_mage[137019] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- fire_mage[137019] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- ice_floes[108839] #0: { 'type': APPLY_AURA, 'subtype': CAST_WHILE_WALKING, 'target': TARGET_UNIT_CASTER, }
        -- overflowing_energy[390218] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_15, }
        -- combustion[190319] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 100.0, 'target': TARGET_UNIT_CASTER, 'modifies': CRIT_CHANCE, }
        -- combustion[190319] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- fires_ire[450831] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_15, }
        -- surging_blaze[343230] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -500.0, 'target': TARGET_UNIT_CASTER, 'modifies': CAST_TIME, }
        -- surging_blaze[343230] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- wildfire[383489] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.75, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_15, }
        -- arcane_mage[137021] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- arcane_mage[137021] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- incanters_flow[116267] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- incanters_flow[116267] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- overflowing_energy[394195] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': CRIT_CHANCE, }
        -- burden_of_power[451049] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- spellfire_sphere[448604] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- spellfire_sphere[448604] #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- hyperthermia[383874] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': CAST_TIME, }
        -- hyperthermia[383874] #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 100.0, 'target': TARGET_UNIT_CASTER, 'modifies': CRIT_CHANCE, }
        -- improved_scorch[383608] #0: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'points': 6.0, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- molten_fury[458910] #0: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'points': 7.0, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- sparking_cinders[457729] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- wildfire[383492] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_15, }
    },

    -- [321711] Deals an additional $321712o2 Fire damage over $321712d.
    pyroblast_321712 = {
        id = 321712,
        cast = 0.0,
        cooldown = 30.0,
        gcd = "none",

        startsCombat = true,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': PERIODIC_DAMAGE, 'tick_time': 2.0, 'sp_bonus': 0.062, 'target': TARGET_UNIT_TARGET_ENEMY, }
        from = "from_description",
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

    -- Scorches an enemy for $s1 Fire damage.; Scorch is a guaranteed critical strike$?a450746[, deals $450746s1% increased damage,][] and increases your movement speed by $236060s1% for $236060d when cast on a target below $s2% health.; Castable while moving.
    scorch = {
        id = 2948,
        cast = 1.5,
        cooldown = 0.0,
        gcd = "global",

        spend = 0.010,
        spendType = 'mana',

        talent = "scorch",
        startsCombat = true,

        -- Effects:
        -- #0: { 'type': SCHOOL_DAMAGE, 'subtype': NONE, 'sp_bonus': 0.244, 'pvp_multiplier': 3.0, 'variance': 0.05, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #1: { 'type': DUMMY, 'subtype': NONE, 'target': TARGET_UNIT_CASTER, }

        -- Affected by:
        -- fire_mage[137019] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- fire_mage[137019] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- overflowing_energy[390218] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_15, }
        -- combustion[190319] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 100.0, 'target': TARGET_UNIT_CASTER, 'modifies': CRIT_CHANCE, }
        -- combustion[190319] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- fires_ire[450831] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_15, }
        -- wildfire[383489] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.75, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_15, }
        -- glass_cannon[390428] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 30.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- arcane_mage[137021] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- arcane_mage[137021] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- incanters_flow[116267] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- incanters_flow[116267] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- overflowing_energy[394195] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': CRIT_CHANCE, }
        -- spellfire_sphere[448604] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- spellfire_sphere[448604] #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- improved_scorch[383608] #0: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'points': 6.0, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- molten_fury[458910] #0: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'points': 7.0, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- wildfire[383492] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_15, }
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