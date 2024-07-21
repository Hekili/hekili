-- MageArcane.lua
-- July 2024

local addon, ns = ...
local Hekili = _G[ addon ]
local class, state = Hekili.Class, Hekili.State

local spec = Hekili:NewSpecialization( 62 )

-- Resources
spec:RegisterResource( Enum.PowerType.Mana )
spec:RegisterResource( Enum.PowerType.ArcaneCharges )

spec:RegisterTalents( {
    -- Mage Talents
    accumulative_shielding     = { 62093, 382800, 1 }, -- Your barrier's cooldown recharges $s1% faster while the shield persists.
    alter_time                 = { 62115, 342245, 1 }, -- Alters the fabric of time, returning you to your current location and health when cast a second time, or after ${$110909d+$s3} sec.  Effect negated by long distance or death.
    arcane_warding             = { 62114, 383092, 2 }, -- Reduces magic damage taken by $s1%.
    barrier_diffusion          = { 62091, 455428, 1 }, -- Whenever one of your Barriers is removed, reduce its cooldown by ${$s1/1000}  sec.
    blast_wave                 = { 62103, 157981, 1 }, -- Causes an explosion around yourself, dealing $s1 Fire damage to all enemies within $A1 yds, knocking them back, and reducing movement speed by $s2% for $d.
    cryofreeze                 = { 62107, 382292, 2 }, -- While inside Ice Block, you heal for ${$s1*10}% of your maximum health over the duration.
    displacement               = { 62095, 389713, 1 }, -- Teleports you back to where you last Blinked and heals you for ${$414462s1/100*$mhp} health. Only usable within $389714d of Blinking.
    diverted_energy            = { 62101, 382270, 2 }, -- Your Barriers heal you for $s1% of the damage absorbed.
    dragons_breath             = { 101883, 31661 , 1 }, -- Enemies in a cone in front of you take $s2 Fire damage and are disoriented for $d. Damage will cancel the effect.$?a235870[; Always deals a critical strike and contributes to Hot Streak.][]
    energized_barriers         = { 62100, 386828, 1 }, -- When your barrier receives melee attacks, you have a $s1% chance to be granted $?c1[Clearcasting]?c2[1 Fire Blast charge]$?c3[Fingers of Frost]. ; Casting your barrier removes all snare effects.
    flow_of_time               = { 62096, 382268, 2 }, -- The cooldowns of Blink and Shimmer are reduced by ${$s1/-1000} sec.
    freezing_cold              = { 62087, 386763, 1 }, -- Enemies hit by Cone of Cold are frozen in place for $386770d instead of snared.; When your roots expire or are dispelled, your target is snared by $394255s1%, decaying over $394255d.
    frigid_winds               = { 62128, 235224, 2 }, -- All of your snare effects reduce the target's movement speed by an additional $s1%.
    greater_invisibility       = { 93524, 110959, 1 }, -- Makes you invisible and untargetable for $110960d, removing all threat. Any action taken cancels this effect.; You take $113862s1% reduced damage while invisible and for 3 sec after reappearing.$?a382293[; Increases your movement speed by ${$382293s1*0.40}% for $337278d.][]
    ice_block                  = { 62122, 45438 , 1 }, -- Encases you in a block of ice, protecting you from all attacks and damage for $d, but during that time you cannot attack, move, or cast spells.$?a382292[; While inside Ice Block, you heal for ${$382292s1*10}% of your maximum health over the duration.][]; Causes Hypothermia, preventing you from recasting Ice Block for $41425d.
    ice_cold                   = { 62085, 414659, 1 }, -- Ice Block now reduces all damage taken by $414658s8% for $414658d but no longer grants Immunity, prevents movement, attacks, or casting spells. Does not incur the Global Cooldown.
    ice_floes                  = { 62105, 108839, 1 }, -- Makes your next Mage spell with a cast time shorter than $s2 sec castable while moving. Unaffected by the global cooldown and castable while casting.
    ice_nova                   = { 62088, 157997, 1 }, -- Causes a whirl of icy wind around the enemy, dealing $s1 Frost damage to the target and reduced damage to all other enemies within $a2 yds, and freezing them in place for $d.
    ice_ward                   = { 62086, 205036, 1 }, -- Frost Nova now has ${1+$m1} charges.
    improved_frost_nova        = { 62108, 343183, 1 }, -- Frost Nova duration is increased by ${$s1/1000} sec.
    incantation_of_swiftness   = { 62112, 382293, 2 }, -- $?s110959[Greater ][]Invisibility increases your movement speed by $s1% for $337278d.
    incanters_flow             = { 62118, 1463  , 1 }, -- Magical energy flows through you while in combat, building up to ${$116267m1*5}% increased damage and then diminishing down to $116267s1% increased damage, cycling every 10 sec.
    inspired_intellect         = { 62094, 458437, 1 }, -- Arcane Intellect grants you an additional $s1% Intellect.
    mass_barrier               = { 62092, 414660, 1 }, -- Cast $?c1[Prismatic]?c2[Blazing]?c3[Ice][] Barrier on yourself and $414661i allies within $s2 yds.
    mass_invisibility          = { 62092, 414664, 1 }, -- You and your allies within $A1 yards instantly become invisible for $d. Taking any action will cancel the effect.; $?a415945[]; [Does not affect allies in combat.]
    mass_polymorph             = { 62106, 383121, 1 }, -- Transforms all enemies within $a yards into sheep, wandering around incapacitated for $d. While affected, the victims cannot take actions but will regenerate health very quickly. Damage will cancel the effect.; Only works on Beasts, Humanoids and Critters.
    master_of_time             = { 62102, 342249, 1 }, -- Reduces the cooldown of Alter Time by ${$s1/-1000} sec. ; Alter Time resets the cooldown of Blink and Shimmer when you return to your original location.
    mirror_image               = { 62124, 55342 , 1 }, -- Creates $s2 copies of you nearby for $55342d, which cast spells and attack your enemies.; While your images are active damage taken is reduced by $s3%. Taking direct damage will cause one of your images to dissipate.$?a382820[; You are healed for $382998s1% of your maximum health whenever a Mirror Image dissipates due to direct damage.]?a382569[; Mirror Image's cooldown is reduced by ${$382569s1/1000} sec whenever a Mirror Image dissipates due to direct damage.][]
    overflowing_energy         = { 62120, 390218, 1 }, -- Your spell critical strike damage is increased by $s1%. When your direct damage spells fail to critically strike a target, your spell critical strike chance is increased by $394195s1%, up to ${$394195u*$394195s1}% for $394195d. ; When your spells critically strike Overflowing Energy is reset.
    quick_witted               = { 62104, 382297, 1 }, -- Successfully interrupting an enemy with Counterspell reduces its cooldown by ${$s1/1000} sec.
    reabsorption               = { 62125, 382820, 1 }, -- You are healed for $382998s1% of your maximum health whenever a Mirror Image dissipates due to direct damage.
    reduplication              = { 62125, 382569, 1 }, -- Mirror Image's cooldown is reduced by ${$s1/1000} sec whenever a Mirror Image dissipates due to direct damage.
    remove_curse               = { 62116, 475   , 1 }, -- Removes all Curses from a friendly target. $?s115700[If any Curses are successfully removed, you deal $115701s1% additional damage for $115701d.][]
    rigid_ice                  = { 62110, 382481, 1 }, -- Frost Nova can withstand $s1% more damage before breaking.
    ring_of_frost              = { 62088, 113724, 1 }, -- Summons a Ring of Frost for $d at the target location. Enemies entering the ring are incapacitated for $82691d. Limit 10 targets.; When the incapacitate expires, enemies are slowed by $321329s1% for $321329d.
    shifting_power             = { 62113, 382440, 1 }, -- Draw power from within, dealing ${$382445s1*$d/$t} Arcane damage over $d to enemies within $382445A1 yds. ; While channeling, your Mage ability cooldowns are reduced by ${-$s2/1000*$d/$t} sec over $d.
    shimmer                    = { 62105, 212653, 1 }, -- Teleports you $A1 yds forward, unless something is in the way. Unaffected by the global cooldown and castable while casting.$?a382289[; Gain a shield that absorbs $382289s1% of your maximum health for $382290d after you Shimmer.][]
    slow                       = { 62097, 31589 , 1 }, -- Reduces the target's movement speed by $s1% for $d.$?a391102[; Applies to enemies within $391104A1 yds of the target.][] 
    spellsteal                 = { 62084, 30449 , 1 }, -- Steals $?s198100[all beneficial magic effects from the target. These effects lasts a maximum of 2 min.][a beneficial magic effect from the target. This effect lasts a maximum of 2 min.] $?s115713[If you successfully steal a spell, you are also healed for $115714s1% of your maximum health.][]
    supernova                  = { 101883, 157980, 1 }, -- Pulses arcane energy around the target enemy or ally, dealing $s2 Arcane damage to all enemies within $A2 yds, and knocking them upward. A primary enemy target will take $s1% increased damage.
    tempest_barrier            = { 62111, 382289, 2 }, -- Gain a shield that absorbs $s1% of your maximum health for $382290d after you Blink.
    temporal_velocity          = { 62099, 382826, 2 }, -- Increases your movement speed by $s2% for $384360d after casting Blink and $s1% for $382824d after returning from Alter Time.
    time_anomaly               = { 62094, 383243, 1 }, -- At any moment, you have a chance to gain $?c1[Arcane Surge for $s1 sec, Clearcasting]?c2[Combustion for $s4 sec, 1 Fire Blast charge]?c3[Icy Veins for $s5 sec, Brain Freeze][], or Time Warp for 6 sec.
    time_manipulation          = { 62129, 387807, 1 }, -- Casting $?c1[Clearcasting Arcane Missiles]?c2[Fire Blast]?c3[Ice Lance on Frozen targets][] reduces the cooldown of your loss of control abilities by ${-$s1/1000} sec.
    tome_of_antonidas          = { 62098, 382490, 1 }, -- Increases Haste by $s1%. 
    tome_of_rhonin             = { 62127, 382493, 1 }, -- Increases Critical Strike chance by $s1%.
    volatile_detonation        = { 62089, 389627, 1 }, -- Greatly increases the effect of Blast Wave's knockback. Blast Wave's cooldown is reduced by ${$s1/-1000} sec
    winters_protection         = { 62123, 382424, 2 }, -- The cooldown of Ice Block is reduced by ${$s1/-1000} sec.

    -- Arcane Talents
    aether_attunement          = { 102476, 453600, 1 }, -- Every $458388u times you consume Clearcasting, gain Aether Attunement.; $@spellicon453600$@spellname453600:; Your next Arcane Missiles deals $453601s1% increased damage to your primary target and fires at up to ${$453601s2-1} nearby enemies dealing $453601s4% increased damage.
    amplification              = { 102445, 236628, 1 }, -- Arcane Missiles fires $s2 additional $lmissile:missiles;.
    arcane_bombardment         = { 102465, 384581, 1 }, -- Arcane Barrage deals an additional $s2% damage against targets below $s1% health.
    arcane_debilitation        = { 102463, 453598, 2 }, -- Damaging a target with Arcane Missiles increases the damage they take from Arcane Missiles, Arcane Barrage, and Arcane Blast by ${$s1}.1% for $453599d. Multiple instances may overlap.
    arcane_echo                = { 102457, 342231, 1 }, -- Direct damage you deal to enemies affected by Touch of the Magi, causes an explosion that deals $342232s1 Arcane damage to all nearby enemies. Deals reduced damage beyond $s1 targets.
    arcane_familiar            = { 102439, 205022, 1 }, -- Casting Arcane Intellect summons a Familiar that attacks your enemies and increases your maximum mana by $210126s1% for $210126d.
    arcane_harmony             = { 102447, 384452, 1 }, -- Each time Arcane Missiles hits an enemy, the damage of your next Arcane Barrage is increased by $384455s1%. $?a134735[This effect stacks up to $s2 times.][This effect stacks up to $384455u times.]
    arcane_missiles            = { 102467, 5143  , 1 }, -- Only castable when you have Clearcasting.; Launches five waves of Arcane Missiles at the enemy over $5143d, causing a total of ${5*$7268s1} Arcane damage.
    arcane_surge               = { 102449, 365350, 1 }, -- Expend all of your current mana to annihilate your enemy target and nearby enemies for up to ${$s1*$s2} Arcane damage based on Mana spent. Deals reduced damage beyond $s3 targets. Generates Clearcasting.; For the next $365362d, your Mana regeneration is increased by $365362s3% and spell damage is increased by $365362s1%.
    arcane_tempo               = { 102436, 383980, 1 }, -- Consuming Arcane Charges increases your Haste by $s1% for $383997d, stacks up to $383997u times.
    arcing_cleave              = { 102458, 231564, 1 }, -- For each Arcane Charge, Arcane Barrage hits $s1 additional nearby $Ltarget:targets; for $44425s2% damage.
    augury_abounds             = { 94662, 443783, 1 }, -- Casting $?c1[Arcane Surge][Icy Veins] conjures $s1 $?c1[Arcane][Frost] Splinters.; During $?c1[Arcane Surge][Icy Veins], whenever you conjure $?c1[an Arcane][a Frost] Splinter, you have a $s2% chance to conjure an additional $?c1[Arcane][Frost] Splinter.
    big_brained                = { 102446, 461261, 1 }, -- Gaining Clearcasting increases your Intellect by $461531s1% for $461531d. Multiple instances may overlap.
    burden_of_power            = { 94644, 451035, 1 }, -- Conjuring a Spellfire Sphere increases the damage of your next $?c1[Arcane Blast by $451049s2% or your next Arcane Barrage by $451049s4%][Pyroblast by $451049s1% or your next Flamestrike by $451049s3%].
    charged_orb                = { 102466, 384651, 1 }, -- Arcane Orb gains $s1 additional charge.
    codex_of_the_sunstriders   = { 94643, 449382, 1 }, -- [461145] Increases your spell damage by $?c1[$448604s1][$448604s6]%.
    concentrated_power         = { 102461, 414379, 1 }, -- Arcane Missiles channels $s2% faster.; Clearcasting makes Arcane Explosion echo for $s1% damage.
    concentration              = { 102438, 384374, 1 }, -- Arcane Blast has a small chance to make your next cast of Arcane Blast free.
    consortiums_bauble         = { 102448, 461260, 1 }, -- Reduces Arcane Blast's mana cost by $s1% and increases its damage by $s2%.
    controlled_instincts       = { 94663, 444483, 1 }, -- $?c1[For 8 seconds after being struck by an Arcane Orb][While a target is under the effects of Blizzard], $?c1[$s1%][$s4%] of the direct damage dealt by $?c1[an Arcane Splinter][a Frost Splinter] is also dealt to nearby enemies. Damage reduced beyond $s5 targets.
    dematerialize              = { 102456, 461456, 1 }, -- Spells empowered by Nether Precision cause their target to suffer an additional $s1% of the damage dealt over 6 sec.
    energized_familiar         = { 102462, 452997, 1 }, -- During Arcane Surge, your Familiar fires $s1 bolts instead of 1.; Damage from your Arcane Familiar has a small chance to grant you up to $454020s1% of your maximum mana.
    energy_reconstitution      = { 102454, 461457, 1 }, -- Damage from Dematerialize has a small chance to summon an Arcane Explosion at its target's location at $s1% effectiveness.; Arcane Explosions summoned from $@spellname461457 do not generate Arcane Charges.
    enlightened                = { 102470, 321387, 1 }, -- Arcane damage dealt while above $s1% mana is increased by $321388s1%, Mana Regen while below $s1% is increased by $321390s1%.
    eureka                     = { 102455, 452198, 1 }, -- When a spell consumes Clearcasting, its damage is increased by $s1%.
    evocation                  = { 102459, 12051 , 1 }, -- Increases your mana regeneration by $s1% for $d and grants Clearcasting.; While channeling Evocation, your Intellect is increased by $384267s1% every $12051t2 sec. Lasts $384267d.
    force_of_will              = { 94656, 444719, 1 }, -- Gain 2% increased critical strike chance.; Gain 5% increased critical strike damage.
    glorious_incandescence     = { 94645, 449394, 1 }, -- Consuming Burden of Power causes your next cast of $?c1[Arcane Barrage to grant $s4 Arcane Charges and][Fire Blast to] call down a storm of $s1 Meteorites on its target.$?c1[][; Each Meteorite's impact reduces the cooldown of Fire Blast by ${$s2/1000}.1 sec.]
    gravity_lapse              = { 94651, 458513, 1 }, -- [449700] The snap of your fingers warps the gravity around your target and $s2 other nearby enemies, suspending them in the air for $449700d.; Upon landing, nearby enemies take $449715s1 Arcane damage.
    high_voltage               = { 102472, 461248, 1 }, -- Damage from Arcane Missiles has a $s1% chance to grant you $461524s1 Arcane Charge.; Chance is increased by $461525s1% every time your Arcane Missiles fails to grant you an Arcane Charge.
    ignite_the_future          = { 94648, 449558, 1 }, -- Generating a Spellfire Sphere while your Phoenix is active causes it to cast an exceptional spell.
    illuminated_thoughts       = { 102444, 384060, 1 }, -- Clearcasting has a $s1% increased chance to proc.
    impetus                    = { 102480, 383676, 1 }, -- Arcane Blast has a $s1% chance to generate an additional Arcane Charge. If you were to gain an Arcane Charge while at maximum charges instead gain $393939s1% Arcane damage for $393939d. 
    improved_clearcasting      = { 102471, 321420, 1 }, -- Clearcasting can stack up to $s1 additional times.
    improved_touch_of_the_magi = { 102452, 453002, 1 }, -- Your Touch of the Magi now accumulates $s2% of the damage you deal.
    invocation_arcane_phoenix  = { 94652, 448658, 1 }, -- When you cast $?c1[Arcane Surge][Combustion], summon an Arcane Phoenix to aid you in battle.; $@spellicon448659  $@spellname448659; Your Arcane Phoenix aids you for the duration of your $?c1[Arcane Surge][Combustion], casting random Arcane and Fire spells.
    lessons_in_debilitation    = { 94651, 449627, 1 }, -- Your Arcane Phoenix will Spellsteal when it is summoned and when it expires.
    leydrinker                 = { 102474, 452196, 1 }, -- Consuming Nether Precision has a $s1% chance to make your next Arcane Blast or Arcane Barrage echo, repeating its damage at $s2% effectiveness to the primary target and up to four nearby enemies.
    leysight                   = { 102477, 452187, 1 }, -- Nether Precision damage bonus increased to $s2%.
    look_again                 = { 94659, 444756, 1 }, -- Displacement has a $s1% longer duration and $s2% longer range.
    magis_spark                = { 102435, 454016, 1 }, -- Your Touch of the Magi now also conjures a spark, causing the damage from your next Arcane Barrage, Arcane Blast, and Arcane Missiles to echo for $454016s1% of their damage.; Upon receiving damage from all three spells, the spark explodes, dealing $453925s1 Arcane damage to all nearby enemies.
    mana_cascade               = { 94653, 449293, 1 }, -- $?c1[Casting Arcane Blast or Arcane Barrage][Consuming Hot Streak] grants you $?c1[${$449322s1}.1][${$449314s2/10}.1]% Haste for $449322d1. Stacks up to $449314u times. Multiple instances may overlap.
    memory_of_alar             = { 94646, 449619, 1 }, -- [451038] Arcane Barrage grants Clearcasting and generates 4 Arcane Charges.
    merely_a_setback           = { 94649, 449330, 1 }, -- Your $?c1[Prismatic Barrier][Blazing Barrier] now grants 5% avoidance while active and 5% leech for 5 seconds when it breaks or expires.
    nether_munitions           = { 102435, 450206, 1 }, -- When your Touch of the Magi detonates, it increases the damage all affected targets take from you by $454004s1% for $454004d.
    nether_precision           = { 102473, 383782, 1 }, -- Consuming Clearcasting increases the damage of your next 2 Arcane Blasts or Arcane Barrages by $s1%.
    orb_barrage                = { 102443, 384858, 1 }, -- Arcane Barrage has a $s1% chance per Arcane Charge consumed to launch an Arcane Orb in front of you at $s2% effectiveness.
    phantasmal_image           = { 94660, 444784, 1 }, -- Your Mirror Image summons one extra clone.; Mirror Image now reduces all damage taken by an additional $s2%.
    presence_of_mind           = { 102460, 205025, 1 }, -- Causes your next $n Arcane $LBlast:Blasts; to be instant cast$?a134735[ and deal $s2% of normal damage][].
    prismatic_barrier          = { 62121, 235450, 1 }, -- Shields you with an arcane force, absorbing $<shield> damage and reducing magic damage taken by $s3% for $d.; The duration of harmful Magic effects against you is reduced by $s4%.
    prodigious_savant          = { 102450, 384612, 2 }, -- Arcane Charges further increase Mastery effectiveness of Arcane Blast and Arcane Barrage by $s1%.
    reactive_barrier           = { 94660, 444827, 1 }, -- Your $?c1[Prismatic][Ice] Barrier can absorb up to $s1% more damage based on your missing Health.; Max effectiveness when under $s1% health.
    resonance                  = { 102437, 205028, 1 }, -- Arcane Barrage deals $s1% increased damage per target it hits.
    resonant_orbs              = { 102453, 461453, 1 }, -- Arcane Orb damage increased by $s1%.
    reverberate                = { 102441, 281482, 1 }, -- If Arcane Explosion hits at least $s2 targets, it has a $s1% chance to generate an extra Arcane Charge.
    rondurmancy                = { 94648, 449596, 1 }, -- Spellfire Spheres can now stack up to $s2 times.
    savor_the_moment           = { 94650, 449412, 1 }, -- When you cast $?c1[Arcane Surge][Combustion], its duration is extended by ${$s1/1000}.1 sec for each Spellfire Sphere you have, up to ${$s2/1000}.1 sec.
    shifting_shards            = { 94657, 444675, 1 }, -- Shifting Power fires a barrage of $s1 $?c1[Arcane][Frost] Splinters at random enemies within 40 yds over its duration.
    slippery_slinging          = { 94659, 444752, 1 }, -- You have $s1% increased movement speed during Alter Time$?a236457[ and Evocation][].; 
    slipstream                 = { 102469, 236457, 1 }, -- Arcane Missiles can now be channeled while moving.; Evocation can be channeled while moving.
    spellfire_spheres          = { 94647, 448601, 1 }, -- [448604] Increases your spell damage by $?c1[$s1][$s6]%. Stacks up to $u times.
    spellfrost_teachings       = { 94655, 444986, 1 }, -- Direct damage from $?c1[Arcane][Frost] Splinters has a small chance to $?c1[launch an Arcane Orb at $s1% effectiveness][reset the cooldown of Frozen Orb] and increase all damage dealt by $?c1[Arcane Orb by $458411s1][Frozen Orb by $458411s2]% for $458411d.
    splintering_orbs           = { 94661, 444256, 1 }, -- $?c1[The first enemy][Enemies] damaged by your $?c1[Arcane Orb][Frozen Orb] conjures $?c1[$s4 Arcane Splinters][a Frost Splinter, up to $s1].; $?c1[Arcane Orb][Frozen Orb] damage is increased by $s2%.
    splintering_sorcery        = { 94664, 443739, 1 }, -- [443763] Conjure raw Arcane magic into a sharp projectile that deals $s1 Arcane damage.; $@spellname443763s embed themselves into their target, dealing $444735o1 Arcane damage over $444735d. This effect stacks.
    splinterstorm              = { 94654, 443742, 1 }, -- Whenever you have $s1 or more active Embedded $?c1[Arcane][Frost] Splinters, you automatically cast a Splinterstorm at your target.; $@spellicon443742$@spellname443742:; Shatter all Embedded $?c1[Arcane][Frost] Splinters, dealing their remaining periodic damage instantly.; Conjure $?c1[an Arcane][a Frost] Splinter for each Splinter shattered, then unleash them all in a devastating barrage, dealing $?c1[$443763s1 Arcane][$443722s1 Frost] damage to your target for each Splinter in the Splinterstorm.$?c1[][; Splinterstorm applies Winter's Chill to its target.]
    static_cloud               = { 102475, 461257, 1 }, -- Each time you cast Arcane Explosion, its damage increases by $461515s1%.; Bonus resets after reaching ${$461515s1*$461515u}% damage.
    sunfury_execution          = { 94650, 449349, 1 }, -- [384581] Arcane Barrage deals an additional $s2% damage against targets below $s1% health.
    surging_urge               = { 102440, 457521, 1 }, -- Arcane Surge damage increased by ${$s2/$s1}% per Arcane Charge.
    time_loop                  = { 102451, 452924, 1 }, -- When you apply a stack of Arcane Debilitation, you have a $s1% chance to apply another stack of Arcane Debilitation.; This effect can trigger off of itself.
    touch_of_the_magi          = { 102468, 321507, 1 }, -- Applies Touch of the Magi to your current target, accumulating $?a453002[$453002s2%][$s1%] of the damage you deal to the target for $210824d, and then exploding for that amount of Arcane damage to the target and reduced damage to all nearby enemies.; Generates $s2 Arcane Charges.
    unerring_proficiency       = { 94658, 444974, 1 }, -- Each time you conjure $?c1[an Arcane][a Frost] Splinter, increase the damage of your next $?c1[Supernova by $444981s1%][Ice Nova by $444976s1%].; Stacks up to $?c1[$444981u][$444976u] times.
    volatile_magic             = { 94658, 444968, 1 }, -- Whenever an Embedded $?c1[Arcane][Frost] Splinter is removed, it explodes, dealing $?c1[$444966s1 Arcane][$444967s1 Frost] damage to nearby enemies. Deals reduced damage beyond $s2 targets.
} )

-- PvP Talents
spec:RegisterPvpTalents( {
    arcanosphere               = 5397, -- (353128) Builds a sphere of Arcane energy, gaining power over $d. Upon release, the sphere passes through any barriers, knocking enemies back and dealing up to $<wave> Arcane damage.
    chrono_shift               = 5661, -- (235711) Arcane Barrage slows enemies by $236298s% and increases your movement speed by $236299s% for $236299d.
    ethereal_blink             = 5601, -- (410939) Blink and Shimmer apply Slow at $s2% effectiveness to all enemies you Blink through. For each enemy you Blink through, the cooldown of Blink and Shimmer are reduced by $s3 sec, up to $s4 sec.
    ice_wall                   = 5488, -- (352278) Conjures an Ice Wall $s3 yards long that obstructs line of sight. The wall has $s4% of your maximum health and lasts up to $d.
    improved_mass_invisibility = 637 , -- (415945) The cooldown of Mass Invisibility is reduced by ${$s1/-60000} min and can affect allies in combat.
    kleptomania                = 3529, -- (198100) Unleash a flurry of disruptive magic onto your target, stealing a beneficial magic effect every ${$t2}.1 sec for $d.; Castable while moving, but movement speed is reduced by $s3% while channeling.
    master_of_escape           = 635 , -- (210476) Reduces the cooldown of Greater Invisibility by ${($m1/1000)*-1} sec.
    master_shepherd            = 5589, -- (410248) While an enemy player is affected by your Polymorph or Mass Polymorph, your movement speed is increased by $410259s1% and your Versatility is increased by $410259s2%. ; Additionally, Polymorph and Mass Polymorph no longer heal enemies.
    ring_of_fire               = 5491, -- (353082) Summons a Ring of Fire for $353103d at the target location. Enemies entering the ring burn for ${$353084s2*3}% of their total health over $353084d.
    temporal_shield            = 3517, -- (198111) Envelops you in a temporal shield for $115610d. $s1% of all damage taken while shielded will be instantly restored when the shield ends.
} )

-- Auras
spec:RegisterAuras( {
    -- Building up to an Aether Attunement.
    aether_attunement = {
        id = 458388,
        duration = 180.0,
        max_stack = 1,
    },
    -- Altering Time. Returning to past location and health when duration expires.
    alter_time = {
        id = 110909,
        duration = 10.0,
        max_stack = 1,
    },
    -- Increases the mana cost of Arcane Blast by $36032w2%$?{$w5<0}[, and reduces the cast time of Arcane Blast by $w5%.][.]; Increases the number of targets hit by Arcane Barrage for 50% damage by $36032w3.
    arcane_charge = {
        id = 195302,
        duration = 0.0,
        max_stack = 1,
    },
    -- Damage taken from $@auracaster's Arcane Missiles, Arcane Barrage, and Arcane Blast increased by $s1%.
    arcane_debilitation = {
        id = 453599,
        duration = 6.0,
        max_stack = 1,

        -- Affected by:
        -- arcane_debilitation[453598] #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER_BY_LABEL, 'points': 0.5, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_1_VALUE, }
    },
    -- Maximum mana increased by $s1%.
    arcane_familiar = {
        id = 210126,
        duration = 3600.0,
        max_stack = 1,
    },
    -- Increases the damage of your next Arcane Barrage by $s1%.
    arcane_harmony = {
        id = 384455,
        duration = 3600,
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
    -- Spell damage increased by $w1% and Mana Regeneration increase $w3%.
    arcane_surge = {
        id = 365362,
        duration = 15.0,
        max_stack = 1,

        -- Affected by:
        -- spellfire_sphere[448604] #3: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER_BY_LABEL, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
    },
    -- Haste increased by $w1%.
    arcane_tempo = {
        id = 383997,
        duration = 12.0,
        max_stack = 1,
    },
    -- Your Intellect is increased by $s1%.
    big_brained = {
        id = 461531,
        duration = 8.0,
        max_stack = 1,
    },
    -- Movement speed reduced by $s2%.
    blast_wave = {
        id = 157981,
        duration = 6.0,
        max_stack = 1,

        -- Affected by:
        -- arcane_mage[137021] #6: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_2_VALUE, }
        -- arcane_mage[137021] #7: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'pvp_multiplier': 0.0, 'points': -20.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_2_VALUE, }
        -- frigid_winds[235224] #6: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -10.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_2_VALUE, }
        -- volatile_detonation[389627] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -5000.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
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
    -- Movement speed reduced by $w1%.
    chilled = {
        id = 205708,
        duration = 8.0,
        max_stack = 1,

        -- Affected by:
        -- frigid_winds[235224] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -10.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_1_VALUE, }
    },
    -- Movement speed slowed by $s1%.
    chrono_shift = {
        id = 236299,
        duration = 5.0,
        max_stack = 1,
    },
    -- Your next Arcane Blast is free.
    concentration = {
        id = 384379,
        duration = 30.0,
        max_stack = 1,
    },
    -- Movement slowed by $s1%.
    cone_of_cold = {
        id = 120,
        duration = 0.0,
        max_stack = 1,

        -- Affected by:
        -- arcane_mage[137021] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- arcane_mage[137021] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- overflowing_energy[390218] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_15, }
        -- force_of_will[444719] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'modifies': SHOULD_NEVER_SEE_15, }
        -- incanters_flow[116267] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- incanters_flow[116267] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- overflowing_energy[394195] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': CRIT_CHANCE, }
        -- arcane_surge[365362] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.72, 'points': 35.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- arcane_surge[365362] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.72, 'points': 35.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- spellfire_sphere[448604] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- spellfire_sphere[448604] #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- nether_munitions[454004] #0: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'points': 8.0, 'radius': 8.0, 'target': TARGET_UNIT_DEST_AREA_ENEMY, }
        -- radiant_spark_vulnerability[307454] #0: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'points': 10.0, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- radiant_spark_vulnerability[376104] #0: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'points': 10.0, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- forethought[424293] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.5, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- forethought[424293] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.5, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
    },
    -- Disoriented.
    dragons_breath = {
        id = 31661,
        duration = 4.0,
        max_stack = 1,

        -- Affected by:
        -- arcane_mage[137021] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- arcane_mage[137021] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- overflowing_energy[390218] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_15, }
        -- force_of_will[444719] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'modifies': SHOULD_NEVER_SEE_15, }
        -- alexstraszas_fury[235870] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 100000.0, 'target': TARGET_UNIT_CASTER, 'modifies': CRIT_CHANCE, }
        -- alexstraszas_fury[235870] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 50.0, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_15, }
        -- incanters_flow[116267] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- incanters_flow[116267] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- overflowing_energy[394195] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': CRIT_CHANCE, }
        -- arcane_surge[365362] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.72, 'points': 35.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- arcane_surge[365362] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.72, 'points': 35.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- spellfire_sphere[448604] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- spellfire_sphere[448604] #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- nether_munitions[454004] #0: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'points': 8.0, 'radius': 8.0, 'target': TARGET_UNIT_DEST_AREA_ENEMY, }
        -- radiant_spark_vulnerability[307454] #0: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'points': 10.0, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- radiant_spark_vulnerability[376104] #0: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'points': 10.0, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- forethought[424293] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.5, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- forethought[424293] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.5, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
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
        -- mastery_savant[190740] #5: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'sp_bonus': 1.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
    },
    -- Dealing $s1 Frost damage every $t1 sec.
    embedded_frost_splinter = {
        id = 443740,
        duration = 18.0,
        tick_time = 1.0,
        max_stack = 1,

        -- Affected by:
        -- mastery_savant[190740] #5: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'sp_bonus': 1.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
    },
    -- Mana regen increased by $s1%.
    enlightened = {
        id = 321390,
        duration = 3600,
        max_stack = 1,
    },
    -- Blink and Shimmer apply Slow at $s2% effectiveness to all enemies you Blink through. For each enemy you Blink through, the cooldown of Blink and Shimmer are reduced by $s3 sec, up to $s4 sec.
    ethereal_blink = {
        id = 410939,
        duration = 0.0,
        max_stack = 1,
    },
    -- Mana regeneration increased by $s1%.
    evocation = {
        id = 12051,
        duration = 3.0,
        tick_time = 0.5,
        pandemic = true,
        max_stack = 1,

        -- Affected by:
        -- ice_floes[108839] #0: { 'type': APPLY_AURA, 'subtype': CAST_WHILE_WALKING, 'target': TARGET_UNIT_CASTER, }
        -- slipstream[236457] #0: { 'type': APPLY_AURA, 'subtype': CAST_WHILE_WALKING, 'target': TARGET_UNIT_CASTER, }
    },
    -- Spell damage increased by $w1%.
    forethought = {
        id = 424293,
        duration = 20.0,
        max_stack = 1,
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
        -- arcane_mage[137021] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- arcane_mage[137021] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- ice_ward[205036] #0: { 'type': APPLY_AURA, 'subtype': MOD_MAX_CHARGES, 'points': 1.0, 'target': TARGET_UNIT_CASTER, }
        -- improved_frost_nova[343183] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 2000.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
        -- overflowing_energy[390218] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_15, }
        -- force_of_will[444719] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'modifies': SHOULD_NEVER_SEE_15, }
        -- incanters_flow[116267] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- incanters_flow[116267] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- overflowing_energy[394195] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': CRIT_CHANCE, }
        -- arcane_surge[365362] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.72, 'points': 35.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- arcane_surge[365362] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.72, 'points': 35.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- spellfire_sphere[448604] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- spellfire_sphere[448604] #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- nether_munitions[454004] #0: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'points': 8.0, 'radius': 8.0, 'target': TARGET_UNIT_DEST_AREA_ENEMY, }
        -- radiant_spark_vulnerability[307454] #0: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'points': 10.0, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- radiant_spark_vulnerability[376104] #0: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'points': 10.0, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- forethought[424293] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.5, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- forethought[424293] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.5, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
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

        -- Affected by:
        -- mastery_savant[190740] #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 1.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- unerring_proficiency[444981] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 16.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
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
    },
    -- A faint shimmer surrounds you.
    illusion = {
        id = 94632,
        duration = 120.0,
        max_stack = 1,
    },
    -- Arcane damage dealt increased by $s1%.
    impetus = {
        id = 393939,
        duration = 10.0,
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

        -- Affected by:
        -- phantasmal_image[444784] #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER_BY_LABEL, 'points': -5.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_3_VALUE, }
    },
    -- Receiving $s1% increased damage from $@auracaster
    nether_munitions = {
        id = 454004,
        duration = 12.0,
        max_stack = 1,
    },
    -- Deals $w1 Arcane damage and an additional $w1 Arcane damage to all enemies within $114954A1 yards every $t sec.
    nether_tempest = {
        id = 114923,
        duration = 12.0,
        tick_time = 1.0,
        pandemic = true,
        max_stack = 1,

        -- Affected by:
        -- arcane_mage[137021] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- arcane_mage[137021] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- overflowing_energy[390218] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_15, }
        -- force_of_will[444719] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'modifies': SHOULD_NEVER_SEE_15, }
        -- incanters_flow[116267] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- incanters_flow[116267] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- overflowing_energy[394195] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': CRIT_CHANCE, }
        -- arcane_surge[365362] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.72, 'points': 35.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- arcane_surge[365362] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.72, 'points': 35.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- spellfire_sphere[448604] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- spellfire_sphere[448604] #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- nether_munitions[454004] #0: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'points': 8.0, 'radius': 8.0, 'target': TARGET_UNIT_DEST_AREA_ENEMY, }
        -- radiant_spark_vulnerability[376104] #0: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'points': 10.0, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- forethought[424293] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.5, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- forethought[424293] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.5, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
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
    -- Arcane Blast is instant cast.
    presence_of_mind = {
        id = 205025,
        duration = 3600,
        max_stack = 1,
    },
    -- Absorbs $w1 damage.; Magic damage taken reduced by $s3%.; Duration of all harmful Magic effects reduced by $w4%.$?a449330[; Avoidance increased by $449330s1%.][]
    prismatic_barrier = {
        id = 235450,
        duration = 60.0,
        max_stack = 1,

        -- Affected by:
        -- improved_prismatic_barrier[321745] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -10.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_3_VALUE, }
        -- improved_prismatic_barrier[321745] #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -15.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_4_VALUE, }
        -- accumulative_shielding[382800] #2: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 30.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_5_VALUE, }
        -- prismatic_barrier[235450] #4: { 'type': APPLY_AURA, 'subtype': ABILITY_PERIODIC_CRIT, 'target': TARGET_UNIT_CASTER, }
    },
    -- Reduces healing received from critical heals by $w1%.$?$w2>0[; Damage taken increased by $w2.][]
    pvp_rules_enabled_hardcoded = {
        id = 134735,
        duration = 20.0,
        max_stack = 1,
    },
    -- Suffering $w2 Arcane damage every $t2 sec.
    radiant_spark = {
        id = 376103,
        duration = 12.0,
        tick_time = 2.0,
        max_stack = 1,

        -- Affected by:
        -- mastery_savant[190740] #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 1.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
    },
    -- Damage taken from $@auracaster  increased by $w1%.
    radiant_spark_vulnerability = {
        id = 376104,
        duration = 12.0,
        max_stack = 1,
    },
    -- Incapacitated.
    ring_of_frost = {
        id = 82691,
        duration = 10.0,
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
    -- Intellect increased by $s1%
    siphon_storm = {
        id = 384267,
        duration = 20.0,
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
    -- $?c1[Arcane Orb][Frozen Orb] damage increased by $s1%.
    spellfrost_teachings = {
        id = 458411,
        duration = 10.0,
        max_stack = 1,
    },
    -- The damage of your next Arcane Explosion is increased by $s1%.
    static_cloud = {
        id = 461515,
        duration = 60.0,
        max_stack = 1,
    },
    -- Absorbs $w1 damage.
    tempest_barrier = {
        id = 382290,
        duration = 15.0,
        max_stack = 1,
    },
    -- $s1% of all damage taken will be restored when the shield ends.
    temporal_shield = {
        id = 198111,
        duration = 4.0,
        max_stack = 1,
    },
    -- Movement speed increased by $w1%.
    temporal_velocity = {
        id = 384360,
        duration = 3.0,
        max_stack = 1,
    },
    -- Aluneth will echo your next Arcane Explosion.
    time_and_space = {
        id = 240692,
        duration = 6.0,
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
    -- Will explode for $w1 Arcane damage upon expiration.
    touch_of_the_magi = {
        id = 210824,
        duration = 12.0,
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

    -- Launches bolts of arcane energy at the enemy target, causing $s1 Arcane damage. ; For each Arcane Charge, deals $36032s2% additional damage$?a321526[, grants you ${$321526s1/100}.1% of your maximum mana,][]$?a231564[ and hits $36032s3 additional nearby $Ltarget:targets; for $s2% of its damage][].; Consumes all Arcane Charges.
    arcane_barrage = {
        id = 44425,
        cast = 0.0,
        cooldown = 0.0,
        gcd = "global",

        startsCombat = true,

        -- Effects:
        -- #0: { 'type': SCHOOL_DAMAGE, 'subtype': NONE, 'attributes': ['Area Effects Use Target Radius'], 'sp_bonus': 0.972, 'chain_targets': 1, 'variance': 0.05, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #1: { 'type': DUMMY, 'subtype': NONE, 'chain_targets': -10, 'target': TARGET_UNIT_TARGET_ENEMY, }

        -- Affected by:
        -- arcane_mage[137021] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- arcane_mage[137021] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- mage[137018] #0: { 'type': APPLY_AURA, 'subtype': MOD_COOLDOWN_BY_HASTE_REGEN, 'target': TARGET_UNIT_CASTER, }
        -- overflowing_energy[390218] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_15, }
        -- force_of_will[444719] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'modifies': SHOULD_NEVER_SEE_15, }
        -- arcane_charge[36032] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 30.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- arcane_charge[36032] #2: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': CHAINED_TARGETS, }
        -- arcane_harmony[384455] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- incanters_flow[116267] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- incanters_flow[116267] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- overflowing_energy[394195] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': CRIT_CHANCE, }
        -- arcane_debilitation[453599] #0: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'points': 0.5, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- arcane_surge[365362] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.72, 'points': 35.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- arcane_surge[365362] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.72, 'points': 35.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- burden_of_power[451049] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 30.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- spellfire_sphere[448604] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- spellfire_sphere[448604] #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- nether_munitions[454004] #0: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'points': 8.0, 'radius': 8.0, 'target': TARGET_UNIT_DEST_AREA_ENEMY, }
        -- radiant_spark_vulnerability[307454] #0: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'points': 10.0, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- radiant_spark_vulnerability[376104] #0: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'points': 10.0, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- forethought[424293] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.5, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- forethought[424293] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.5, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
    },

    -- Blasts the target with energy, dealing $30451s1 Arcane damage.; Each Arcane Charge increases damage by $36032s1% and mana cost by $36032s5%, and reduces cast time by $36032s4%.; Generates 1 Arcane Charge.
    arcane_blast = {
        id = 30451,
        cast = 2.25,
        cooldown = 0.0,
        gcd = "global",

        spend = 0.028,
        spendType = 'mana',

        startsCombat = true,

        -- Effects:
        -- #0: { 'type': SCHOOL_DAMAGE, 'subtype': NONE, 'attributes': ['Always AOE Line of Sight', 'Area Effects Use Target Radius', 'Chain from Initial Target'], 'sp_bonus': 0.752, 'chain_targets': 1, 'pvp_multiplier': 1.134, 'variance': 0.05, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #1: { 'type': ENERGIZE, 'subtype': NONE, 'points': 1.0, 'target': TARGET_UNIT_CASTER, 'resource': arcane_charges, }

        -- Affected by:
        -- arcane_mage[137021] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- arcane_mage[137021] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- ice_floes[108839] #0: { 'type': APPLY_AURA, 'subtype': CAST_WHILE_WALKING, 'target': TARGET_UNIT_CASTER, }
        -- overflowing_energy[390218] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_15, }
        -- consortiums_bauble[461260] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -3.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- consortiums_bauble[461260] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- force_of_will[444719] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'modifies': SHOULD_NEVER_SEE_15, }
        -- presence_of_mind[205025] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': CAST_TIME, }
        -- arcane_charge[36032] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 60.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- arcane_charge[36032] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -8.0, 'target': TARGET_UNIT_CASTER, 'modifies': CAST_TIME, }
        -- arcane_charge[36032] #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 100.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- concentration[384379] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- incanters_flow[116267] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- incanters_flow[116267] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- overflowing_energy[394195] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': CRIT_CHANCE, }
        -- arcane_debilitation[453599] #0: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'points': 0.5, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- arcane_surge[365362] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.72, 'points': 35.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- arcane_surge[365362] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.72, 'points': 35.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- burden_of_power[451049] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- spellfire_sphere[448604] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- spellfire_sphere[448604] #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- nether_munitions[454004] #0: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'points': 8.0, 'radius': 8.0, 'target': TARGET_UNIT_DEST_AREA_ENEMY, }
        -- radiant_spark_vulnerability[307454] #0: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'points': 10.0, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- radiant_spark_vulnerability[376104] #0: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'points': 10.0, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- forethought[424293] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.5, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- forethought[424293] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.5, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
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
        -- mastery_savant[190740] #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 1.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- arcane_mage[137021] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- arcane_mage[137021] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- overflowing_energy[390218] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_15, }
        -- force_of_will[444719] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'modifies': SHOULD_NEVER_SEE_15, }
        -- incanters_flow[116267] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- incanters_flow[116267] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- overflowing_energy[394195] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': CRIT_CHANCE, }
        -- arcane_surge[365362] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.72, 'points': 35.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- arcane_surge[365362] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.72, 'points': 35.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- spellfire_sphere[448604] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- spellfire_sphere[448604] #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- nether_munitions[454004] #0: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'points': 8.0, 'radius': 8.0, 'target': TARGET_UNIT_DEST_AREA_ENEMY, }
        -- static_cloud[461515] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 25.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- radiant_spark_vulnerability[307454] #0: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'points': 10.0, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- radiant_spark_vulnerability[376104] #0: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'points': 10.0, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- forethought[424293] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.5, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- forethought[424293] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.5, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
    },

    -- Causes an explosion of magic around the caster, dealing $s2 Arcane damage to all enemies within $A2 yards.$?a137021[; Generates $s1 Arcane Charge if any targets are hit.][]
    arcane_explosion_414381 = {
        id = 414381,
        cast = 0.0,
        cooldown = 0.0,
        gcd = "global",

        startsCombat = true,

        -- Effects:
        -- #0: { 'type': ENERGIZE, 'subtype': NONE, 'points': 1.0, 'target': TARGET_UNIT_CASTER, 'resource': arcane_charges, }
        -- #1: { 'type': SCHOOL_DAMAGE, 'subtype': NONE, 'sp_bonus': 0.228684, 'variance': 0.05, 'radius': 10.0, 'target': TARGET_SRC_CASTER, 'target2': TARGET_UNIT_SRC_AREA_ENEMY, }
        -- #2: { 'type': ENERGIZE, 'subtype': NONE, 'points': 1.0, 'target': TARGET_UNIT_CASTER, 'resource': arcane_charges, }

        -- Affected by:
        -- mastery_savant[190740] #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 1.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- static_cloud[461515] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 25.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        from = "affected_by_mastery",
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

    -- Only castable when you have Clearcasting.; Launches five waves of Arcane Missiles at the enemy over $5143d, causing a total of ${5*$7268s1} Arcane damage.
    arcane_missiles = {
        id = 5143,
        cast = 2.5,
        channeled = true,
        cooldown = 0.0,
        gcd = "global",

        spend = 0.150,
        spendType = 'mana',

        talent = "arcane_missiles",
        startsCombat = true,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': PERIODIC_DUMMY, 'tick_time': 0.625, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #1: { 'type': APPLY_AURA, 'subtype': PERIODIC_TRIGGER_SPELL, 'tick_time': 0.625, 'trigger_spell': 7268, 'target': TARGET_UNIT_CASTER, }
        -- #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 100.0, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_9, }
        -- #3: { 'type': TRIGGER_SPELL, 'subtype': NONE, 'trigger_spell': 7268, 'value': 100, 'schools': ['fire', 'shadow', 'arcane'], 'target': TARGET_UNIT_TARGET_ENEMY, }

        -- Affected by:
        -- ice_floes[108839] #0: { 'type': APPLY_AURA, 'subtype': CAST_WHILE_WALKING, 'target': TARGET_UNIT_CASTER, }
        -- arcane_missiles[5143] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 100.0, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_9, }
        -- arcane_debilitation[453599] #0: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'points': 0.5, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- radiant_spark_vulnerability[307454] #0: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'points': 10.0, 'target': TARGET_UNIT_TARGET_ENEMY, }
    },

    -- Launches an Arcane Orb forward from your position, traveling up to 40 yds, dealing $153640s1 Arcane damage to enemies it passes through.; Grants 1 Arcane Charge when cast and every time it deals damage.
    arcane_orb = {
        id = 153626,
        cast = 0.0,
        cooldown = 0.0,
        gcd = "global",

        spend = 0.010,
        spendType = 'mana',

        startsCombat = true,

        -- Effects:
        -- #0: { 'type': CREATE_AREATRIGGER, 'subtype': NONE, 'points': 100.0, 'value': 1612, 'schools': ['fire', 'nature', 'arcane'], 'target': TARGET_DEST_CASTER, 'target2': TARGET_UNIT_DEST_AREA_ENEMY, }
        -- #1: { 'type': ENERGIZE, 'subtype': NONE, 'points': 1.0, 'target': TARGET_UNIT_CASTER, 'resource': arcane_charges, }

        -- Affected by:
        -- charged_orb[384651] #0: { 'type': APPLY_AURA, 'subtype': MOD_MAX_CHARGES, 'points': 1.0, 'target': TARGET_UNIT_CASTER, }
    },

    -- Expend all of your current mana to annihilate your enemy target and nearby enemies for up to ${$s1*$s2} Arcane damage based on Mana spent. Deals reduced damage beyond $s3 targets. Generates Clearcasting.; For the next $365362d, your Mana regeneration is increased by $365362s3% and spell damage is increased by $365362s1%.
    arcane_surge = {
        id = 365350,
        cast = 2.5,
        cooldown = 90.0,
        gcd = "global",

        spend = 1,
        spendType = 'mana',

        talent = "arcane_surge",
        startsCombat = true,

        -- Effects:
        -- #0: { 'type': SCHOOL_DAMAGE, 'subtype': NONE, 'sp_bonus': 2.1574, 'radius': 8.0, 'target': TARGET_DEST_TARGET_ENEMY, 'target2': TARGET_UNIT_DEST_AREA_ENEMY, }
        -- #1: { 'type': DUMMY, 'subtype': NONE, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #2: { 'type': DUMMY, 'subtype': NONE, }

        -- Affected by:
        -- mastery_savant[190740] #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 1.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
    },

    -- Expend all of your current mana to annihilate your enemy target and nearby enemies for up to ${$s1*$s2} Arcane damage based on Mana spent. Deals reduced damage beyond $s3 targets.; For the next $365362d, your Mana regeneration is increased by $365362s3% and spell damage is increased by $365362s1%.
    arcane_surge_453326 = {
        id = 453326,
        cast = 2.5,
        cooldown = 90.0,
        gcd = "global",

        startsCombat = true,

        -- Effects:
        -- #0: { 'type': SCHOOL_DAMAGE, 'subtype': NONE, 'sp_bonus': 2.0, 'radius': 8.0, 'target': TARGET_DEST_TARGET_ENEMY, 'target2': TARGET_UNIT_DEST_AREA_ENEMY, }
        -- #1: { 'type': DUMMY, 'subtype': NONE, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #2: { 'type': DUMMY, 'subtype': NONE, }

        -- Affected by:
        -- mastery_savant[190740] #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 1.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        from = "affected_by_mastery",
    },

    -- Builds a sphere of Arcane energy, gaining power over $d. Upon release, the sphere passes through any barriers, knocking enemies back and dealing up to $<wave> Arcane damage.
    arcanosphere = {
        id = 353128,
        color = 'pvp_talent',
        cast = 0.0,
        cooldown = 45.0,
        gcd = "global",

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': PERIODIC_DUMMY, 'tick_time': 1.0, 'target': TARGET_UNIT_CASTER, }
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
        -- arcane_mage[137021] #6: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_2_VALUE, }
        -- arcane_mage[137021] #7: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'pvp_multiplier': 0.0, 'points': -20.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_2_VALUE, }
        -- frigid_winds[235224] #6: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -10.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_2_VALUE, }
        -- volatile_detonation[389627] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -5000.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
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

    -- Throws a spread of 6 cinders that travel in an arc, each dealing $198928s1 Fire damage to enemies it hits. Damage increased by $s1% if the target is affected by your Ignite.
    cinderstorm = {
        id = 198929,
        cast = 1.5,
        cooldown = 9.0,
        gcd = "global",

        spend = 0.010,
        spendType = 'mana',

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': CREATE_AREATRIGGER, 'subtype': NONE, 'points': 30.0, 'value': 5487, 'schools': ['physical', 'holy', 'fire', 'nature', 'shadow', 'arcane'], 'target': TARGET_DEST_CASTER, }
        -- #1: { 'type': CREATE_AREATRIGGER, 'subtype': NONE, 'value': 5489, 'schools': ['physical', 'frost', 'shadow', 'arcane'], 'target': TARGET_DEST_CASTER, }
        -- #2: { 'type': CREATE_AREATRIGGER, 'subtype': NONE, 'value': 5490, 'schools': ['holy', 'frost', 'shadow', 'arcane'], 'target': TARGET_DEST_CASTER, }
        -- #3: { 'type': CREATE_AREATRIGGER, 'subtype': NONE, 'value': 5491, 'schools': ['physical', 'holy', 'frost', 'shadow', 'arcane'], 'target': TARGET_DEST_CASTER, }
        -- #4: { 'type': CREATE_AREATRIGGER, 'subtype': NONE, 'value': 5492, 'schools': ['fire', 'frost', 'shadow', 'arcane'], 'target': TARGET_DEST_CASTER, }
        -- #5: { 'type': CREATE_AREATRIGGER, 'subtype': NONE, 'value': 5493, 'schools': ['physical', 'fire', 'frost', 'shadow', 'arcane'], 'target': TARGET_DEST_CASTER, }

        -- Affected by:
        -- mastery_savant[190740] #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 1.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- mage[137018] #0: { 'type': APPLY_AURA, 'subtype': MOD_COOLDOWN_BY_HASTE_REGEN, 'target': TARGET_UNIT_CASTER, }
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
        -- arcane_mage[137021] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- arcane_mage[137021] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- overflowing_energy[390218] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_15, }
        -- force_of_will[444719] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'modifies': SHOULD_NEVER_SEE_15, }
        -- incanters_flow[116267] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- incanters_flow[116267] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- overflowing_energy[394195] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': CRIT_CHANCE, }
        -- arcane_surge[365362] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.72, 'points': 35.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- arcane_surge[365362] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.72, 'points': 35.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- spellfire_sphere[448604] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- spellfire_sphere[448604] #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- nether_munitions[454004] #0: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'points': 8.0, 'radius': 8.0, 'target': TARGET_UNIT_DEST_AREA_ENEMY, }
        -- radiant_spark_vulnerability[307454] #0: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'points': 10.0, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- radiant_spark_vulnerability[376104] #0: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'points': 10.0, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- forethought[424293] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.5, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- forethought[424293] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.5, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
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
        -- arcane_mage[137021] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- arcane_mage[137021] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- overflowing_energy[390218] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_15, }
        -- force_of_will[444719] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'modifies': SHOULD_NEVER_SEE_15, }
        -- alexstraszas_fury[235870] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 100000.0, 'target': TARGET_UNIT_CASTER, 'modifies': CRIT_CHANCE, }
        -- alexstraszas_fury[235870] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 50.0, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_15, }
        -- incanters_flow[116267] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- incanters_flow[116267] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- overflowing_energy[394195] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': CRIT_CHANCE, }
        -- arcane_surge[365362] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.72, 'points': 35.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- arcane_surge[365362] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.72, 'points': 35.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- spellfire_sphere[448604] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- spellfire_sphere[448604] #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- nether_munitions[454004] #0: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'points': 8.0, 'radius': 8.0, 'target': TARGET_UNIT_DEST_AREA_ENEMY, }
        -- radiant_spark_vulnerability[307454] #0: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'points': 10.0, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- radiant_spark_vulnerability[376104] #0: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'points': 10.0, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- forethought[424293] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.5, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- forethought[424293] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.5, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
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

    -- Increases your mana regeneration by $s1% for $d and grants Clearcasting.; While channeling Evocation, your Intellect is increased by $384267s1% every $12051t2 sec. Lasts $384267d.
    evocation = {
        id = 12051,
        cast = 0.0,
        cooldown = 0.0,
        gcd = "global",

        talent = "evocation",
        startsCombat = false,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': MOD_POWER_REGEN_PERCENT, 'points': 1500.0, 'target': TARGET_UNIT_CASTER, 'resource': mana, }
        -- #1: { 'type': APPLY_AURA, 'subtype': PERIODIC_DUMMY, 'tick_time': 0.5, 'target': TARGET_UNIT_CASTER, }

        -- Affected by:
        -- ice_floes[108839] #0: { 'type': APPLY_AURA, 'subtype': CAST_WHILE_WALKING, 'target': TARGET_UNIT_CASTER, }
        -- slipstream[236457] #0: { 'type': APPLY_AURA, 'subtype': CAST_WHILE_WALKING, 'target': TARGET_UNIT_CASTER, }
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
        -- fire_blast[231568] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 100.0, 'target': TARGET_UNIT_CASTER, 'modifies': CRIT_CHANCE, }
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
        -- arcane_mage[137021] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- arcane_mage[137021] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- ice_ward[205036] #0: { 'type': APPLY_AURA, 'subtype': MOD_MAX_CHARGES, 'points': 1.0, 'target': TARGET_UNIT_CASTER, }
        -- improved_frost_nova[343183] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 2000.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
        -- overflowing_energy[390218] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_15, }
        -- force_of_will[444719] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'modifies': SHOULD_NEVER_SEE_15, }
        -- incanters_flow[116267] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- incanters_flow[116267] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- overflowing_energy[394195] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': CRIT_CHANCE, }
        -- arcane_surge[365362] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.72, 'points': 35.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- arcane_surge[365362] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.72, 'points': 35.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- spellfire_sphere[448604] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- spellfire_sphere[448604] #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- nether_munitions[454004] #0: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'points': 8.0, 'radius': 8.0, 'target': TARGET_UNIT_DEST_AREA_ENEMY, }
        -- radiant_spark_vulnerability[307454] #0: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'points': 10.0, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- radiant_spark_vulnerability[376104] #0: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'points': 10.0, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- forethought[424293] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.5, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- forethought[424293] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.5, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
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
        -- radiant_spark_vulnerability[307454] #0: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'points': 10.0, 'target': TARGET_UNIT_TARGET_ENEMY, }
    },

    -- Causes an explosion of magic around the caster, dealing $s2 Arcane damage to all enemies within $A2 yards.; Generates $s1 Arcane Charge if any targets are hit.
    ggo_test_nova = {
        id = 306256,
        cast = 0.0,
        cooldown = 0.0,
        gcd = "global",

        startsCombat = true,

        -- Effects:
        -- #0: { 'type': ENERGIZE, 'subtype': NONE, 'points': 1.0, 'target': TARGET_UNIT_CASTER, 'resource': arcane_charges, }
        -- #1: { 'type': SCHOOL_DAMAGE, 'subtype': NONE, 'sp_bonus': 0.6, 'radius': 10.0, 'target': TARGET_SRC_CASTER, 'target2': TARGET_UNIT_SRC_AREA_ENEMY, }
        -- #2: { 'type': ENERGIZE, 'subtype': NONE, 'points': 1.0, 'target': TARGET_UNIT_CASTER, 'resource': arcane_charges, }

        -- Affected by:
        -- mastery_savant[190740] #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 1.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- static_cloud[461515] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 25.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
    },

    -- Causes an explosion of magic around the caster, dealing $s2 Arcane damage to all enemies within $A2 yards.; Generates $s1 Arcane Charge if any targets are hit.
    ggo_test_spell_vertical_impact = {
        id = 331124,
        cast = 0.0,
        cooldown = 0.0,
        gcd = "global",

        startsCombat = true,

        -- Effects:
        -- #0: { 'type': DUMMY, 'subtype': NONE, 'target': TARGET_UNIT_TARGET_ENEMY, }

        -- Affected by:
        -- mastery_savant[190740] #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 1.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- static_cloud[461515] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 25.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
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

        -- Affected by:
        -- mastery_savant[190740] #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 1.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- unerring_proficiency[444981] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 16.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
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

        -- Affected by:
        -- master_of_escape[210476] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -45000.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
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

        -- Affected by:
        -- master_of_escape[210476] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -45000.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
    },

    -- Unleash a flurry of disruptive magic onto your target, stealing a beneficial magic effect every ${$t2}.1 sec for $d.; Castable while moving, but movement speed is reduced by $s3% while channeling.
    kleptomania = {
        id = 198100,
        color = 'pvp_talent',
        cast = 4.0,
        channeled = true,
        cooldown = 20.0,
        gcd = "global",

        spend = 0.200,
        spendType = 'mana',

        startsCombat = true,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- #1: { 'type': APPLY_AURA, 'subtype': PERIODIC_TRIGGER_SPELL, 'tick_time': 0.5, 'trigger_spell': 30449, 'triggers': spellsteal, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #2: { 'type': APPLY_AURA, 'subtype': MOD_DECREASE_SPEED, 'points': -40.0, 'target': TARGET_UNIT_CASTER, }
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
        -- arcane_mage[137021] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- arcane_mage[137021] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- overflowing_energy[390218] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_15, }
        -- force_of_will[444719] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'modifies': SHOULD_NEVER_SEE_15, }
        -- incanters_flow[116267] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- incanters_flow[116267] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- overflowing_energy[394195] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': CRIT_CHANCE, }
        -- arcane_surge[365362] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.72, 'points': 35.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- arcane_surge[365362] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.72, 'points': 35.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- spellfire_sphere[448604] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- spellfire_sphere[448604] #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- nether_munitions[454004] #0: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'points': 8.0, 'radius': 8.0, 'target': TARGET_UNIT_DEST_AREA_ENEMY, }
        -- radiant_spark_vulnerability[376104] #0: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'points': 10.0, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- forethought[424293] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.5, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- forethought[424293] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.5, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
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

    -- Causes your next $n Arcane $LBlast:Blasts; to be instant cast$?a134735[ and deal $s2% of normal damage][].
    presence_of_mind = {
        id = 205025,
        cast = 0.0,
        cooldown = 45.0,
        gcd = "none",

        talent = "presence_of_mind",
        startsCombat = false,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': CAST_TIME, }
        -- #1: { 'type': APPLY_AURA, 'subtype': DUMMY, 'pvp_multiplier': 0.85, 'points': 100.0, 'target': TARGET_UNIT_CASTER, }
    },

    -- Shields you with an arcane force, absorbing $<shield> damage and reducing magic damage taken by $s3% for $d.; The duration of harmful Magic effects against you is reduced by $s4%.
    prismatic_barrier = {
        id = 235450,
        cast = 0.0,
        cooldown = 25.0,
        gcd = "global",

        spend = 0.030,
        spendType = 'mana',

        talent = "prismatic_barrier",
        startsCombat = false,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': SCHOOL_ABSORB, 'value': 127, 'schools': ['physical', 'holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], 'target': TARGET_UNIT_CASTER, }
        -- #1: { 'type': APPLY_AURA, 'subtype': DUMMY, 'points': 1.0, 'target': TARGET_UNIT_CASTER, }
        -- #2: { 'type': APPLY_AURA, 'subtype': MOD_DAMAGE_PERCENT_TAKEN, 'amplitude': 1.0, 'pvp_multiplier': 0.67, 'points': -15.0, 'schools': ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], 'target': TARGET_UNIT_CASTER, }
        -- #3: { 'type': APPLY_AURA, 'subtype': MOD_AURA_DURATION_BY_DISPEL, 'pvp_multiplier': 0.6, 'points': -25.0, 'value': 1, 'schools': ['physical'], 'target': TARGET_UNIT_CASTER, }
        -- #4: { 'type': APPLY_AURA, 'subtype': ABILITY_PERIODIC_CRIT, 'target': TARGET_UNIT_CASTER, }
        -- #5: { 'type': APPLY_AURA, 'subtype': DUMMY, 'points': 20.0, 'target': TARGET_UNIT_CASTER, }

        -- Affected by:
        -- improved_prismatic_barrier[321745] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -10.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_3_VALUE, }
        -- improved_prismatic_barrier[321745] #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -15.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_4_VALUE, }
        -- accumulative_shielding[382800] #2: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 30.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_5_VALUE, }
        -- prismatic_barrier[235450] #4: { 'type': APPLY_AURA, 'subtype': ABILITY_PERIODIC_CRIT, 'target': TARGET_UNIT_CASTER, }
    },

    -- Conjure a radiant spark that causes $s1 Arcane damage instantly, and an additional $o2 damage over $d.; The target takes $307454s1% increased damage from your direct damage spells, stacking each time they are struck. This effect ends after $307454u spells.; 
    radiant_spark = {
        id = 307443,
        color = 'kyrian',
        cast = 1.5,
        cooldown = 30.0,
        gcd = "global",

        spend = 0.020,
        spendType = 'mana',

        startsCombat = true,

        -- Effects:
        -- #0: { 'type': SCHOOL_DAMAGE, 'subtype': NONE, 'sp_bonus': 0.912, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #1: { 'type': APPLY_AURA, 'subtype': PERIODIC_DAMAGE, 'tick_time': 2.0, 'sp_bonus': 0.099, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #2: { 'type': APPLY_AURA, 'subtype': PROC_TRIGGER_SPELL, 'trigger_spell': 307454, 'target': TARGET_UNIT_CASTER, }
        -- #3: { 'type': INTERRUPT_CAST, 'subtype': NONE, 'target': TARGET_UNIT_TARGET_ENEMY, }

        -- Affected by:
        -- mastery_savant[190740] #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 1.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
    },

    -- Conjure a radiant spark that causes $s1 Arcane damage instantly, and an additional $o2 damage over $d.; The target takes $376104s1% increased damage from your direct damage spells, stacking each time they are struck. This effect ends after $376104u spells.; 
    radiant_spark_376103 = {
        id = 376103,
        cast = 1.5,
        cooldown = 30.0,
        gcd = "global",

        spend = 0.020,
        spendType = 'mana',

        startsCombat = true,

        -- Effects:
        -- #0: { 'type': SCHOOL_DAMAGE, 'subtype': NONE, 'sp_bonus': 1.0488, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #1: { 'type': APPLY_AURA, 'subtype': PERIODIC_DAMAGE, 'tick_time': 2.0, 'sp_bonus': 0.1139, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #2: { 'type': APPLY_AURA, 'subtype': PROC_TRIGGER_SPELL, 'trigger_spell': 376104, 'target': TARGET_UNIT_CASTER, }
        -- #3: { 'type': INTERRUPT_CAST, 'subtype': NONE, 'target': TARGET_UNIT_TARGET_ENEMY, }

        -- Affected by:
        -- mastery_savant[190740] #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 1.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        from = "affected_by_mastery",
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
        -- kleptomania[198100] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
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
        -- mastery_savant[190740] #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 1.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- unerring_proficiency[444981] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 16.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
    },

    -- Pulses arcane energy around the target enemy or ally, dealing $s2 Arcane damage to nearby enemies, and knocking them upward. A primary enemy target will take $s1% increased damage.
    supernova_372373 = {
        id = 372373,
        color = 'offensive',
        cast = 0.0,
        cooldown = 10.0,
        gcd = "global",

        startsCombat = true,

        -- Effects:
        -- #0: { 'type': DUMMY, 'subtype': NONE, 'target': TARGET_UNIT_TARGET_ANY, }
        -- #1: { 'type': SCHOOL_DAMAGE, 'subtype': NONE, 'sp_bonus': 0.4, 'variance': 0.05, 'radius': 8.0, 'target': TARGET_DEST_TARGET_ANY, 'target2': TARGET_UNIT_DEST_AREA_ENEMY, }
        -- #2: { 'type': KNOCK_BACK_DEST, 'subtype': NONE, 'points': 150.0, 'radius': 8.0, 'target': TARGET_DEST_TARGET_ANY, 'target2': TARGET_UNIT_DEST_AREA_ENEMY, }

        -- Affected by:
        -- mastery_savant[190740] #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 1.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- unerring_proficiency[444981] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 16.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        from = "affected_by_mastery",
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

    -- Envelops you in a temporal shield for $115610d. $s1% of all damage taken while shielded will be instantly restored when the shield ends.
    temporal_shield = {
        id = 198111,
        color = 'pvp_talent',
        cast = 0.0,
        cooldown = 45.0,
        gcd = "none",

        spend = 0.030,
        spendType = 'mana',

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': DUMMY, 'points': 60.0, 'target': TARGET_UNIT_CASTER, }
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

    -- Applies Touch of the Magi to your current target, accumulating $?a453002[$453002s2%][$s1%] of the damage you deal to the target for $210824d, and then exploding for that amount of Arcane damage to the target and reduced damage to all nearby enemies.; Generates $s2 Arcane Charges.
    touch_of_the_magi = {
        id = 321507,
        cast = 0.0,
        cooldown = 45.0,
        gcd = "none",

        spend = 0.050,
        spendType = 'mana',

        talent = "touch_of_the_magi",
        startsCombat = true,

        -- Effects:
        -- #0: { 'type': TRIGGER_SPELL, 'subtype': NONE, 'trigger_spell': 210824, 'points': 20.0, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #1: { 'type': ENERGIZE, 'subtype': NONE, 'points': 4.0, 'target': TARGET_UNIT_CASTER, 'resource': arcane_charges, }

        -- Affected by:
        -- mastery_savant[190740] #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 1.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
    },

} )