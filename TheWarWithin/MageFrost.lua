
-- MageFrost.lua
-- January 2025

if UnitClassBase( "player" ) ~= "MAGE" then return end

local addon, ns = ...
local Hekili = _G[ addon ]
local class, state = Hekili.Class, Hekili.State

local GetSpellInfo = C_Spell.GetSpellInfo
local strformat = string.format

local spec = Hekili:NewSpecialization( 64 )

-- spec:RegisterResource( Enum.PowerType.ArcaneCharges )
spec:RegisterResource( Enum.PowerType.Mana )

-- Talents
spec:RegisterTalents( {
    -- Mage
    accumulative_shielding    = {  62093, 382800, 1 }, -- Your barrier's cooldown recharges 30% faster while the shield persists.
    alter_time                = {  62115, 342245, 1 }, -- Alters the fabric of time, returning you to your current location and health when cast a second time, or after 10 sec. Effect negated by long distance or death.
    arcane_warding            = {  62114, 383092, 2 }, -- Reduces magic damage taken by 3%.
    barrier_diffusion         = {  62091, 455428, 1 }, -- Whenever one of your Barriers is removed, reduce its cooldown by 4 sec.
    blast_wave                = {  62103, 157981, 1 }, -- Causes an explosion around yourself, dealing 43,335 Fire damage to all enemies within 8 yds, knocking them back, and reducing movement speed by 80% for 6 sec.
    burden_of_power           = {  94644, 451035, 1 }, -- Conjuring a Spellfire Sphere increases the damage of your next Pyroblast by 20% or your next Flamestrike by 30%.
    codex_of_the_sunstriders  = {  94643, 449382, 1 }, -- Over its duration, your Arcane Phoenix will consume each of your Spellfire Spheres to cast an exceptional spell. Upon consuming a Spellfire Sphere, your Arcane Phoenix will grant you Lingering Embers.  Lingering Embers Increases your spell damage by 1%.
    cryofreeze                = {  62107, 382292, 2 }, -- While inside Ice Block, you heal for 40% of your maximum health over the duration.
    displacement              = {  62095, 389713, 1 }, -- Teleports you back to where you last Blinked and heals you for 1.4 million health. Only usable within 8 sec of Blinking.
    diverted_energy           = {  62101, 382270, 2 }, -- Your Barriers heal you for 10% of the damage absorbed.
    dragons_breath            = { 101883,  31661, 1 }, -- Enemies in a cone in front of you take 53,426 Fire damage and are disoriented for 4 sec. Damage will cancel the effect.
    energized_barriers        = {  62100, 386828, 1 }, -- When your barrier receives melee attacks, you have a 10% chance to be granted Fingers of Frost. Casting your barrier removes all snare effects.
    flow_of_time              = {  62096, 382268, 2 }, -- The cooldowns of Blink and Shimmer are reduced by 2 sec.
    freezing_cold             = {  62087, 386763, 1 }, -- Enemies hit by Cone of Cold are frozen in place for 5 sec instead of snared. When your roots expire or are dispelled, your target is snared by 90%, decaying over 3 sec.
    frigid_winds              = {  62128, 235224, 2 }, -- All of your snare effects reduce the target's movement speed by an additional 10%.
    glorious_incandescence    = {  94645, 449394, 1 }, -- Consuming Burden of Power causes your next Arcane Barrage to deal 20% increased damage, grant 4 Arcane Charges, and call down a storm of 4 Meteorites at your target.
    gravity_lapse             = {  94651, 458513, 1 }, -- Your Supernova becomes Gravity Lapse. Gravity Lapse The snap of your fingers warps the gravity around your target and 4 other nearby enemies, suspending them in the air for 3 sec. Upon landing, nearby enemies take 39,876 Arcane damage.
    greater_invisibility      = {  93524, 110959, 1 }, -- Makes you invisible and untargetable for 20 sec, removing all threat. Any action taken cancels this effect. You take 60% reduced damage while invisible and for 3 sec after reappearing.
    ice_barrier               = {  62117,  11426, 1 }, -- Shields you with ice, absorbing 1.9 million damage for 1 min. Melee attacks against you reduce the attacker's movement speed by 60%.
    ice_block                 = {  62122,  45438, 1 }, -- Encases you in a block of ice, protecting you from all attacks and damage for 10 sec, but during that time you cannot attack, move, or cast spells. While inside Ice Block, you heal for 40% of your maximum health over the duration. Causes Hypothermia, preventing you from recasting Ice Block for 30 sec.
    ice_cold                  = {  62085, 414659, 1 }, -- Ice Block now reduces all damage taken by 70% for 6 sec but no longer grants Immunity, prevents movement, attacks, or casting spells. Does not incur the Global Cooldown.
    ice_floes                 = {  62105, 108839, 1 }, -- Makes your next Mage spell with a cast time shorter than 10 sec castable while moving. Unaffected by the global cooldown and castable while casting.
    ice_nova                  = {  62088, 157997, 1 }, -- Causes a whirl of icy wind around the enemy, dealing 110,058 Frost damage to the target and all other enemies within 8 yds, freezing them in place for 2 sec. Damage reduced beyond 8 targets.
    ice_ward                  = {  62086, 205036, 1 }, -- Frost Nova now has 2 charges.
    ignite_the_future         = {  94648, 449558, 1 }, -- Generating a Spellfire Sphere while your Phoenix is active causes it to cast an exceptional spell. Mana Cascade can now stack up to 15 times.
    improved_frost_nova       = {  62108, 343183, 1 }, -- Frost Nova duration is increased by 2 sec.
    incantation_of_swiftness  = {  62112, 382293, 2 }, -- Greater Invisibility increases your movement speed by 40% for 6 sec.
    incanters_flow            = {  62118,   1463, 1 }, -- Magical energy flows through you while in combat, building up to 10% increased damage and then diminishing down to 2% increased damage, cycling every 10 sec.
    inspired_intellect        = {  62094, 458437, 1 }, -- Arcane Intellect grants you an additional 3% Intellect.
    invocation_arcane_phoenix = {  94652, 448658, 1 }, -- When you cast Combustion, summon an Arcane Phoenix to aid you in battle.  Arcane Phoenix Your Arcane Phoenix aids you for the duration of your Combustion, casting random Arcane and Fire spells.
    lessons_in_debilitation   = {  94651, 449627, 1 }, -- Your Arcane Phoenix will Spellsteal when it is summoned and when it expires.
    mana_cascade              = {  94653, 449293, 1 }, -- Consuming Hot Streak grants you 0.5% Haste for 10 sec. Stacks up to 10 times. Multiple instances may overlap.
    mass_barrier              = {  62092, 414660, 1 }, -- Cast Ice Barrier on yourself and 4 allies within 40 yds.
    mass_invisibility         = {  62092, 414664, 1 }, -- You and your allies within 40 yards instantly become invisible for 12 sec. Taking any action will cancel the effect. Does not affect allies in combat.
    mass_polymorph            = {  62106, 383121, 1 }, -- Transforms all enemies within 10 yards into sheep, wandering around incapacitated for 15 sec. While affected, the victims cannot take actions but will regenerate health very quickly. Damage will cancel the effect. Only works on Beasts, Humanoids and Critters.
    master_of_time            = {  62102, 342249, 1 }, -- Reduces the cooldown of Alter Time by 10 sec. Alter Time resets the cooldown of Blink and Shimmer when you return to your original location.
    memory_of_alar            = {  94646, 449619, 1 }, -- While under the effects of a casted Combustion, you gain twice as many stacks of Mana Cascade. When your Arcane Phoenix expires, it empowers you, granting Hyperthermia for 2 sec, plus an additional 1.0 sec for each exceptional spell it had cast.  Hyperthermia: Pyroblast and Flamestrike have no cast time and are guaranteed to critically strike.
    merely_a_setback          = {  94649, 449330, 1 }, -- Your Blazing Barrier now grants 5% avoidance while active and 3% leech for 5 sec when it breaks or expires.
    mirror_image              = {  62124,  55342, 1 }, -- Creates 3 copies of you nearby for 40 sec, which cast spells and attack your enemies. While your images are active damage taken is reduced by 20%. Taking direct damage will cause one of your images to dissipate.
    overflowing_energy        = {  62120, 390218, 1 }, -- Your spell critical strike damage is increased by 10%. When your direct damage spells fail to critically strike a target, your spell critical strike chance is increased by 2%, up to 10% for 8 sec. When your spells critically strike Overflowing Energy is reset.
    quick_witted              = {  62104, 382297, 1 }, -- Successfully interrupting an enemy with Counterspell reduces its cooldown by 4 sec.
    reabsorption              = {  62125, 382820, 1 }, -- You are healed for 3% of your maximum health whenever a Mirror Image dissipates due to direct damage.
    reduplication             = {  62125, 382569, 1 }, -- Mirror Image's cooldown is reduced by 10 sec whenever a Mirror Image dissipates due to direct damage.
    remove_curse              = {  62116,    475, 1 }, -- Removes all Curses from a friendly target.
    rigid_ice                 = {  62110, 382481, 1 }, -- Frost Nova can withstand 80% more damage before breaking.
    ring_of_frost             = {  62088, 113724, 1 }, -- Summons a Ring of Frost for 10 sec at the target location. Enemies entering the ring are incapacitated for 10 sec. Limit 10 targets. When the incapacitate expires, enemies are slowed by 75% for 4 sec.
    rondurmancy               = {  94648, 449596, 1 }, -- Spellfire Spheres can now stack up to 5 times.
    savor_the_moment          = {  94650, 449412, 1 }, -- When you cast Combustion, its duration is extended by 0.5 sec for each Spellfire Sphere you have, up to 2.5 sec.
    shifting_power            = {  62113, 382440, 1 }, -- Draw power from within, dealing 194,452 Arcane damage over 3.0 sec to enemies within 18 yds. While channeling, your Mage ability cooldowns are reduced by 12 sec over 3.0 sec.
    shimmer                   = {  62105, 212653, 1 }, -- Teleports you 20 yds forward, unless something is in the way. Unaffected by the global cooldown and castable while casting.
    slow                      = {  62097,  31589, 1 }, -- Reduces the target's movement speed by 60% for 15 sec.
    spellfire_spheres         = {  94647, 448601, 1 }, -- Every 6 times you consume Hot Streak, conjure a Spellfire Sphere. While you're out of combat, you will slowly conjure Spellfire Spheres over time.  Spellfire Sphere Increases your spell damage by 1%. Stacks up to 3 times.
    spellsteal                = {  62084,  30449, 1 }, -- Steals a beneficial magic effect from the target. This effect lasts a maximum of 2 min.
    sunfury_execution         = {  94650, 449349, 1 }, -- Scorch's critical strike threshold is increased to 35%.  Scorch Scorches an enemy for 23,925 Fire damage. When cast on a target below 30% health, Scorch is a guaranteed critical strike and increases your movement speed by 30% for 3 sec. Castable while moving.
    supernova                 = { 101883, 157980, 1 }, -- Pulses arcane energy around the target enemy or ally, dealing 27,514 Arcane damage to all enemies within 8 yds, and knocking them upward. A primary enemy target will take 100% increased damage.
    tempest_barrier           = {  62111, 382289, 2 }, -- Gain a shield that absorbs 3% of your maximum health for 15 sec after you Blink.
    temporal_velocity         = {  62099, 382826, 2 }, -- Increases your movement speed by 5% for 3 sec after casting Blink and 20% for 6 sec after returning from Alter Time.
    time_anomaly              = {  62094, 383243, 1 }, -- At any moment, you have a chance to gain Icy Veins for 8 sec, Brain Freeze, or Time Warp for 6 sec.
    time_manipulation         = {  62129, 387807, 1 }, -- Casting Ice Lance on Frozen targets reduces the cooldown of your loss of control abilities by 2 sec.
    tome_of_antonidas         = {  62098, 382490, 1 }, -- Increases Haste by 2%.
    tome_of_rhonin            = {  62127, 382493, 1 }, -- Increases Critical Strike chance by 2%.
    volatile_detonation       = {  62089, 389627, 1 }, -- Greatly increases the effect of Blast Wave's knockback. Blast Wave's cooldown is reduced by 5 sec
    winters_protection        = {  62123, 382424, 2 }, -- The cooldown of Ice Block is reduced by 30 sec.

    -- Frost
    bone_chilling             = {  62167, 205027, 1 }, -- Whenever you attempt to chill a target, you gain Bone Chilling, increasing spell damage you deal by 0.5% for 8 sec, stacking up to 10 times.
    brain_freeze              = {  62179, 190447, 1 }, -- Frostbolt has a 30% chance to reset the remaining cooldown on Flurry and cause your next Flurry to deal 50% increased damage.
    chain_reaction            = {  62161, 278309, 1 }, -- Your Ice Lances against frozen targets increase the damage of your Ice Lances by 2% for 10 sec, stacking up to 5 times.
    cold_front                = {  62155, 382110, 1 }, -- Casting 30 Frostbolts or Flurries calls down a Frozen Orb toward your target. Hitting an enemy player counts as double.
    coldest_snap              = {  62185, 417493, 1 }, -- Cone of Cold's cooldown is increased to 45 sec and if Cone of Cold hits 3 or more enemies it resets the cooldown of Frozen Orb and Comet Storm. In addition, Cone of Cold applies Winter's Chill to all enemies hit. Cone of Cold's cooldown can no longer be reduced by your cooldown reduction effects.
    comet_storm               = {  62182, 153595, 1 }, -- Calls down a series of 7 icy comets on and around the target, that deals up to 385,926 Frost damage to all enemies within 6 yds of its impacts.
    cryopathy                 = {  62152, 417491, 1 }, -- Each time you consume Fingers of Frost the damage of your next Ray of Frost is increased by 5%, stacking up to 50%. Icy Veins grants 10 stacks instantly.
    deaths_chill              = { 101302, 450331, 1 }, -- While Icy Veins is active, damaging an enemy with Frostbolt increases spell damage by 1%. Stacks up to 15 times.
    deep_shatter              = {  62159, 378749, 2 }, -- Your Frostbolt deals 40% additional damage to Frozen targets.
    everlasting_frost         = {  81468, 385167, 1 }, -- Frozen Orb deals an additional 30% damage and its duration is increased by 2 sec.
    fingers_of_frost          = {  62164, 112965, 1 }, -- Frostbolt has a 18% chance and Frozen Orb damage has a 5% to grant a charge of Fingers of Frost. Fingers of Frost causes your next Ice Lance to deal damage as if the target were frozen. Maximum 2 charges.
    flash_freeze              = {  62168, 379993, 1 }, -- Each of your Icicles deals 10% additional damage, and when an Icicle deals damage you have a 5% chance to gain the Fingers of Frost effect.
    flurry                    = {  62178,  44614, 1 }, -- Unleash a flurry of ice, striking the target 3 times for a total of 163,711 Frost damage. Each hit reduces the target's movement speed by 80% for 1 sec and applies Winter's Chill to the target. Winter's Chill causes the target to take damage from your spells as if it were frozen.
    fractured_frost           = {  62151, 378448, 1 }, -- While Icy Veins is active, your Frostbolts hit up to 2 additional targets and their damage is increased by 15%.
    freezing_rain             = {  62150, 270233, 1 }, -- Frozen Orb makes Blizzard instant cast and increases its damage done by 60% for 12 sec.
    freezing_winds            = {  62184, 1216953, 1 }, -- Frozen Orb deals 15% increased damage to units affected by your Blizzard.
    frostbite                 = {  81467, 378756, 1 }, -- Gives your Chill effects a 10% chance to freeze the target for 4 sec.
    frozen_orb                = {  62177,  84714, 1 }, -- Launches an orb of swirling ice up to 40 yds forward which deals up to 378,428 Frost damage to all enemies it passes through over 15 sec. Deals reduced damage beyond 8 targets. Grants 1 charge of Fingers of Frost when it first damages an enemy. Enemies damaged by the Frozen Orb are slowed by 40% for 3 sec.
    frozen_touch              = {  62180, 205030, 1 }, -- Frostbolt grants you Fingers of Frost 25% more often and Brain Freeze 20% more often.
    glacial_assault           = {  62183, 378947, 1 }, -- Your Comet Storm now applies Numbing Blast, increasing the damage enemies take from you by 6% for 6 sec. Additionally, Flurry has a 25% chance each hit to call down an icy comet, crashing into your target and nearby enemies for 26,579 Frost damage.
    glacial_spike             = {  62157, 199786, 1 }, -- Conjures a massive spike of ice, and merges your current Icicles into it. It impales your target, dealing 610,909 damage plus all of the damage stored in your Icicles, and freezes the target in place for 4 sec. Damage may interrupt the freeze effect. Requires 5 Icicles to cast. Passive: Ice Lance no longer launches Icicles.
    hailstones                = {  62158, 381244, 1 }, -- Casting Ice Lance on Frozen targets has a 100% chance to generate an Icicle.
    ice_caller                = {  62170, 236662, 1 }, -- Each time Blizzard deals damage, the cooldown of Frozen Orb is reduced by 0.5 sec.
    ice_lance                 = {  62176,  30455, 1 }, -- Quickly fling a shard of ice at the target, dealing 77,989 Frost damage. Ice Lance damage is tripled against frozen targets.
    icy_veins                 = {  62171,  12472, 1 }, -- Accelerates your spellcasting for 30 sec, granting 20% haste and preventing damage from delaying your spellcasts. Activating Icy Veins summons a water elemental to your side for its duration. The water elemental's abilities grant you Frigid Empowerment, increasing the Frost damage you deal by 3%, up to 15%.
    lonely_winter             = {  62173, 205024, 1 }, -- Frostbolt, Ice Lance, and Flurry deal 15% increased damage.
    permafrost_lances         = {  62169, 460590, 1 }, -- Frozen Orb increases Ice Lance's damage by 15% for 15 sec.
    perpetual_winter          = {  62181, 378198, 1 }, -- Flurry now has 2 charges.
    piercing_cold             = {  62166, 378919, 1 }, -- Frostbolt and Icicle critical strike damage increased by 20%.
    ray_of_frost              = {  62153, 205021, 1 }, -- Channel an icy beam at the enemy for 3.7 sec, dealing 251,369 Frost damage every 0.7 sec and slowing movement by 70%. Each time Ray of Frost deals damage, its damage and snare increases by 10%. Generates 2 charges of Fingers of Frost over its duration.
    shatter                   = {  62165,  12982, 1 }, -- Multiplies the critical strike chance of your spells against frozen targets by 1.5, and adds an additional 50% critical strike chance.
    slick_ice                 = {  62156, 382144, 1 }, -- While Icy Veins is active, each Frostbolt you cast reduces the cast time of Frostbolt by 4% and increases its damage by 4%, stacking up to 5 times.
    splintering_cold          = {  62162, 379049, 2 }, -- Frostbolt and Flurry have a 30% chance to generate 2 Icicles.
    splintering_ray           = { 103771, 418733, 1 }, -- Ray of Frost deals 30% of its damage to 5 nearby enemies.
    splitting_ice             = {  62163,  56377, 1 }, -- Your Ice Lance and Icicles now deal 5% increased damage, and hit a second nearby target for 90% of their damage. Your Glacial Spike also hits a second nearby target for 100% of its damage.
    subzero                   = {  62160, 380154, 2 }, -- Your Frost spells deal 20% more damage to targets that are rooted and frozen.
    thermal_void              = {  62154, 155149, 1 }, -- Icy Veins' duration is increased by 5 sec. Your Ice Lances against frozen targets extend your Icy Veins by an additional 0.5 sec.
    winters_blessing          = {  62174, 417489, 1 }, -- Your Haste is increased by 8%. You gain 10% more of the Haste stat from all sources.
    wintertide                = {  62172, 378406, 2 }, -- Damage from Frostbolt and Flurry increases the damage of your Icicles and Glacial Spike by 4%. Stacks up to 2 times. Damage from Glacial Spike consumes all stacks of Wintertide.

    -- Spellslinger
    augury_abounds            = {  94662, 443783, 1 }, -- Casting Icy Veins conjures 8 Frost Splinters. During Icy Veins, whenever you conjure a Frost Splinter, you have a 100% chance to conjure an additional Frost Splinter.
    controlled_instincts      = {  94663, 444483, 1 }, -- While a target is under the effects of Blizzard, 30% of the direct damage dealt by a Frost Splinter is also dealt to nearby enemies. Damage reduced beyond 5 targets.
    force_of_will             = {  94656, 444719, 1 }, -- Gain 2% increased critical strike chance. Gain 5% increased critical strike damage.
    look_again                = {  94659, 444756, 1 }, -- Displacement has a 50% longer duration and 25% longer range.
    phantasmal_image          = {  94660, 444784, 1 }, -- Your Mirror Image summons one extra clone. Mirror Image now reduces all damage taken by an additional 5%.
    reactive_barrier          = {  94660, 444827, 1 }, -- Your Ice Barrier can absorb up to 50% more damage based on your missing Health. Max effectiveness when under 50% health.
    shifting_shards           = {  94657, 444675, 1 }, -- Shifting Power fires a barrage of 8 Frost Splinters at random enemies within 40 yds over its duration.
    signature_spell           = {  94657, 470021, 1 }, -- Consuming Winter's Chill with Glacial Spike conjures 2 additional Frost Splinters.
    slippery_slinging         = {  94659, 444752, 1 }, -- You have 40% increased movement speed during Alter Time.
    spellfrost_teachings      = {  94655, 444986, 1 }, -- Direct damage from Frost Splinters has a 2.5% chance to reset the cooldown of Frozen Orb and increase all damage dealt by Frozen Orb by 15% for 10 sec.
    splintering_orbs          = {  94661, 444256, 1 }, -- Enemies damaged by your Frozen Orb conjure 1 Frost Splinter, up to 5. Frozen Orb damage is increased by 10%.
    splintering_sorcery       = {  94664, 443739, 1, "spellslinger" }, -- When you consume Winter's Chill, conjure a Frost Splinter that fires at your target. Frost Splinter: Conjure raw Frost magic into a sharp projectile that deals 3,747 Frost damage. Frost Splinters embed themselves into their target, dealing 3,747 Frost damage over 18 sec. This effect stacks.
    splinterstorm             = {  94654, 443742, 1 }, -- Whenever you have 8 or more active Embedded Frost Splinters, you automatically cast a Splinterstorm at your target. Splinterstorm: Shatter all Embedded Frost Splinters, dealing their remaining periodic damage instantly. Conjure a Frost Splinter for each Splinter shattered, then unleash them all in a devastating barrage, dealing 29,144 Frost damage to your target for each Splinter in the Splinterstorm. Splinterstorm has a 5% chance to grant Brain Freeze.
    unerring_proficiency      = {  94658, 444974, 1 }, -- Each time you conjure a Frost Splinter, increase the damage of your next Ice Nova by 5%. Stacks up to 60 times.
    volatile_magic            = {  94658, 444968, 1 }, -- Whenever an Embedded Frost Splinter is removed, it explodes, dealing 7,975 Frost damage to nearby enemies. Deals reduced damage beyond 5 targets.

    -- Frostfire
    elemental_affinity        = {  94633, 431067, 1 }, -- The cooldown of Fire spells is reduced by 30%.
    excess_fire               = {  94637, 438595, 1 }, -- Casting Comet Storm causes your next Ice Lance to explode in a Frostfire Burst, dealing 211,822 Frostfire damage to nearby enemies. Damage reduced beyond 8 targets. Frostfire Burst, grants Brain Freeze.
    excess_frost              = {  94639, 438600, 1 }, -- Consuming Excess Fire causes your next Flurry to also cast Ice Nova at 200% effectiveness. Ice Novas cast this way do not freeze enemies in place. When you consume Excess Frost, the cooldown of Comet Storm is reduced by 5 sec.
    flame_and_frost           = {  94633, 431112, 1 }, -- Cold Snap additionally resets the cooldowns of your Fire spells.
    flash_freezeburn          = {  94635, 431178, 1 }, -- Frostfire Empowerment grants you maximum benefit of Frostfire Mastery, refreshes its duration, and grants you Excess Frost and Excess Fire. Activating Combustion or Icy Veins grants you Frostfire Empowerment.
    frostfire_bolt            = {  94641, 431044, 1 }, -- Launches a bolt of frostfire at the enemy, causing 116,020 Frostfire damage, slowing movement speed by 60%, and causing an additional 49,045 Frostfire damage over 8 sec. Frostfire Bolt generates stacks for both Fire Mastery and Frost Mastery.
    frostfire_empowerment     = {  94632, 431176, 1 }, -- Your Frost and Fire spells have a chance to activate Frostfire Empowerment, causing your next Frostfire Bolt to be instant cast, deal 60% increased damage, explode for 80% of its damage to nearby enemies.
    frostfire_infusion        = {  94634, 431166, 1 }, -- Your Frost and Fire spells have a chance to trigger an additional bolt of Frostfire, dealing 53,832 damage. This effect generates Frostfire Mastery when activated.
    frostfire_mastery         = {  94636, 431038, 1, "frostfire" }, -- Your damaging Fire spells generate 1 stack of Fire Mastery and Frost spells generate 1 stack of Frost Mastery. Fire Mastery increases your haste by 1%, and Frost Mastery increases your Mastery by 2% for 14 sec, stacking up to 6 times each. Adding stacks does not refresh duration.
    imbued_warding            = {  94642, 431066, 1 }, -- Ice Barrier also casts a Blazing Barrier at 25% effectiveness.
    isothermic_core           = {  94638, 431095, 1 }, -- Comet Storm now also calls down a Meteor at 150% effectiveness onto your target's location. Meteor now also calls down a Comet Storm at 200% effectiveness onto your target location.
    meltdown                  = {  94642, 431131, 1 }, -- You melt slightly out of your Ice Block and Ice Cold, allowing you to move slowly during Ice Block and increasing your movement speed over time. Ice Block and Ice Cold trigger a Blazing Barrier when they end.
    severe_temperatures       = {  94640, 431189, 1 }, -- Casting damaging Frost or Fire spells has a high chance to increase the damage of your next Frostfire Bolt by 10%, stacking up to 5 times.
    thermal_conditioning      = {  94640, 431117, 1 }, -- Frostfire Bolt's cast time is reduced by 10%.
} )

-- PvP Talents
spec:RegisterPvpTalents( {
    concentrated_coolness      =  632, -- (198148)
    ethereal_blink             = 5600, -- (410939) Blink and Shimmer apply Slow at 100% effectiveness to all enemies you Blink through. For each enemy you Blink through, the cooldown of Blink and Shimmer are reduced by 1 sec, up to 5 sec.
    frost_bomb                 = 5496, -- (390612) Places a Frost Bomb on the target. After 5 sec, the bomb explodes, dealing 530,352 Frost damage to the target and 265,287 Frost damage to all other enemies within 10 yards. All affected targets are slowed by 80% for 4 sec. If Frost Bomb is dispelled before it explodes, gain a charge of Brain Freeze.
    ice_form                   =  634, -- (198144) Your body turns into Ice, increasing your Frostbolt damage done by 30% and granting immunity to stun and knockback effects. Lasts 17 sec.
    ice_wall                   = 5390, -- (352278) Conjures an Ice Wall 30 yards long that obstructs line of sight. The wall has 40% of your maximum health and lasts up to 15 sec.
    icy_feet                   =   66, -- (407581)
    improved_mass_invisibility = 5622, -- (415945) The cooldown of Mass Invisibility is reduced by 4 min and can affect allies in combat.
    master_shepherd            = 5581, -- (410248) While an enemy player is affected by your Polymorph or Mass Polymorph, your movement speed is increased by 25% and your Versatility is increased by 12%. Additionally, Polymorph and Mass Polymorph no longer heal enemies.
    overpowered_barrier        = 5708, -- (1220739) Your barriers absorb 100% more damage and have an additional effect, but last 5 sec.  Ice Barrier If the barrier is fully absorbed, enemies within 10 yds suffer 518,389 Frost damage and are slowed by 70% for 4 sec.
    ring_of_fire               = 5490, -- (353082) Summons a Ring of Fire for 8 sec at the target location. Enemies entering the ring are disoriented and burn for 3% of their total health over 3 sec.
    snowdrift                  = 5497, -- (389794) Summon a strong Blizzard that surrounds you for 6 sec that slows enemies by 80% and deals 15,950 Frost damage every 1 sec. Enemies that are caught in Snowdrift for 2 sec consecutively become Frozen in ice, stunned for 4 sec.
} )

-- Auras
spec:RegisterAuras( {
    active_blizzard = {
        duration = function () return 12 * haste end,
        max_stack = 1,
        generate = function( t )
            if query_time - action.blizzard.lastCast < 12 * haste then
                t.count = 1
                t.applied = action.blizzard.lastCast
                t.expires = t.applied + ( 12 * haste )
                t.caster = "player"
                return
            end

            t.count = 0
            t.applied = 0
            t.expires = 0
            t.caster = "nobody"
        end,

    },

    active_comet_storm = {
        duration = 2.6,
        max_stack = 1,
        generate = function( t )
            if query_time - action.comet_storm.lastCast < 2.6 then
                t.count = 1
                t.applied = action.comet_storm.lastCast
                t.expires = t.applied + 2.6
                t.caster = "player"
                return
            end

            t.count = 0
            t.applied = 0
            t.expires = 0
            t.caster = "nobody"
        end,
    },
    arcane_power = {
        id = 12042,
        duration = 15,
        type = "Magic",
        max_stack = 1,
    },
    -- Talent: Movement speed reduced by $s2%.
    -- https://wowhead.com/beta/spell=157981
    blast_wave = {
        id = 157981,
        duration = 6,
        type = "Magic",
        max_stack = 1
    },
    -- Blinking.
    -- https://wowhead.com/beta/spell=1953
    blink = {
        id = 1953,
        duration = 0.3,
        type = "Magic",
        max_stack = 1
    },
    -- Talent: Movement speed reduced by $w1%.
    -- https://wowhead.com/beta/spell=12486
    blizzard = {
        id = 12486,
        duration = 3,
        mechanic = "snare",
        type = "Magic",
        max_stack = 1
    },
    -- Talent: Spell damage done increased by ${$W1}.1%.
    -- https://wowhead.com/beta/spell=205766
    bone_chilling = {
        id = 205766,
        duration = 8,
        max_stack = 10
    },
    brain_freeze = {
        id = 190446,
        duration = 15,
        max_stack = 1,
    },
    chain_reaction = {
        id = 278310,
        duration = 10,
        max_stack = 5,
    },
    -- Movement speed reduced by $w1%.
    -- https://wowhead.com/beta/spell=205708
    chilled = {
        id = 205708,
        duration = 8,
        max_stack = 1
    },
    cold_front = {
        id = 382113,
        duration = 30,
        max_stack = 30
    },
    cold_front_ready = {
        id = 382114,
        duration = 30,
        max_stack = 1
    },
    -- Movement speed reduced by $s1%.
    -- https://wowhead.com/beta/spell=212792
    cone_of_cold = {
        id = 212792,
        duration = 5,
        max_stack = 1
    },
    cryopathy = {
        id = 417492,
        duration = 60,
        max_stack = 16,
    },
    deaths_chill = {
        id = 454371,
        duration = function() return buff.icy_veins.up and buff.icy_veins.remains or spec.auras.icy_veins.duration end,
        max_stack = 15
    },
    -- Talent: Disoriented.
    -- https://wowhead.com/beta/spell=31661
    dragons_breath = {
        id = 31661,
        duration = 4,
        type = "Magic",
        max_stack = 1
    },
    embedded_frost_splinter = {
        id = 443740,
        duration = 18,
        max_stack = 8
    },
    excess_frost = {
        id = 438611,
        duration = 30,
        max_stack = 2,
        meta = {
            stack = function() return max( 0, ( state.buff.excess_frost.stack - ( action.flurry.in_flight and 1 or 0 ) ) ) end,
            stacks = function() return max( 0, ( state.buff.excess_frost.stack - ( action.flurry.in_flight and 1 or 0 ) ) ) end,
            react = function() return max( 0, ( state.buff.excess_frost.stack - ( action.flurry.in_flight and 1 or 0 ) ) ) end,
        }
    },
    fingers_of_frost = {
        id = 44544,
        duration = 15,
        max_stack = 2
    },
    fof_consumed = {
        -- Virtual buff to track if FoF is consumed (by Ice Lance) so we know whether to (virtually) consume Winter's Chill stacks.
        -- Appears to only happen during the addon's forecasting, need to determine if we need to also apply this buff in reset_precast to avoid recommendation flicker between IL cast and impact.
        -- Duration = 0.1 + max_range[ 40 ] / velocity[ 47 ]
        duration = 0.95,
        max_stack = 2
    },
    fire_mastery = {
        id = 431040,
        duration = 14,
        max_stack = 6
    },
    -- Talent: Movement slowed by $w1%.
    -- https://wowhead.com/beta/spell=228354
    flurry = {
        id = 228354,
        duration = 1,
        type = "Magic",
        max_stack = 1
    },
    focus_magic = {
        id = 321358,
        duration = 1800,
        max_stack = 1,
        friendly = true,
    },
    focus_magic_buff = {
        id = 321363,
        duration = 10,
        max_stack = 1,
    },
    freeze = {
        id = 33395,
        duration = 8,
        max_stack = 1,
        shared = "pet"
    },
    -- Talent: Blizzard is instant cast and deals $s2% increased damage.
    -- https://wowhead.com/beta/spell=270232
    freezing_rain = {
        id = 270232,
        duration = 12,
        max_stack = 1
    },
    frigid_empowerment = {
        id = 417488,
        duration = 60,
        max_stack = 5
    },
    -- Frozen in place.
    -- https://wowhead.com/beta/spell=122
    frost_nova = {
        id = 122,
        duration = 10,
        type = "Magic",
        max_stack = 1,
        copy = 235235
    },
    frost_mastery = {
        id = 431039,
        duration = 14,
        max_stack = 6
    },
    -- Talent: Frozen.
    -- https://wowhead.com/beta/spell=378760
    frostbite = {
        id = 378760,
        duration = 4,
        mechanic = "root",
        type = "Magic",
        max_stack = 1
    },
    frostbolt = {
        id = 59638,
        duration = 4,
        type = "Magic",
        max_stack = 1,
    },
    frostfire_bolt = {
        id = 468655,
        duration = 8,
        max_stack = 1
    },
    frozen_orb = {
        duration = function() return 10 + 2 * talent.everlasting_frost.rank end,
        max_stack = 1,
        generate = function( t )
            if query_time - action.frozen_orb.lastCast < t.duration then
                t.count = 1
                t.applied = action.frozen_orb.lastCast
                t.expires = t.applied + t.duration
                t.caster = "player"
                return
            end

            t.count = 0
            t.applied = 0
            t.expires = 0
            t.caster = "nobody"
        end,
    },
    -- Talent: Movement speed reduced by $w1%.
    -- https://wowhead.com/beta/spell=289308
    frozen_orb_snare = {
        id = 289308,
        duration = 3,
        max_stack = 1,
    },
    -- Talent: Frozen in place.
    -- https://wowhead.com/beta/spell=228600
    glacial_spike = {
        id = 228600,
        duration = 4,
        type = "Magic",
        max_stack = 1
    },
    glacial_spike_usable = {
        id = 199844,
        duration = 60,
        max_stack = 1
    },
    -- Talent: Absorbs $w1 damage.  Melee attackers slowed by $205708s1%.$?s235297[  Armor increased by $s3%.][]
    -- https://wowhead.com/beta/spell=11426
    ice_barrier = {
        id = 11426,
        duration = 60,
        type = "Magic",
        max_stack = 1
    },
    -- Frostbolt damage done increased by $m1%. Immune to stun and knockback effects.
    -- https://wowhead.com/beta/spell=198144
    ice_form = {
        id = 198144,
        duration = 12,
        type = "Magic",
        max_stack = 1
    },
    -- Talent: Frozen.
    -- https://wowhead.com/beta/spell=157997
    ice_nova = {
        id = 157997,
        duration = 2,
        type = "Magic",
        max_stack = 1
    },
    icicles = {
        id = 205473,
        duration = 60,
        max_stack = 5,
    },
    -- Talent: Haste increased by $w1% and immune to pushback.
    -- https://wowhead.com/beta/spell=12472
    icy_veins = {
        id = 12472,
        duration = function() return talent.thermal_void.enabled and 30 or 25 end,
        type = "Magic",
        max_stack = 1
    },
    incanters_flow = {
        id = 116267,
        duration = 3600,
        max_stack = 5,
        meta = {
            stack = function() return state.incanters_flow_stacks end,
            stacks = function() return state.incanters_flow_stacks end,
        }
    },
    preinvisibility = {
        id = 66,
        duration = 3,
        max_stack = 1,
    },
    invisibility = {
        id = 32612,
        duration = 20,
        max_stack = 1
    },
    -- Talent: Incapacitated. Cannot attack or cast spells.  Increased health regeneration.
    -- https://wowhead.com/beta/spell=383121
    mass_polymorph = {
        id = 383121,
        duration = 60,
        mechanic = "polymorph",
        type = "Magic",
        max_stack = 1
    },
    -- Talent: Movement speed reduced by $w1%.
    -- https://wowhead.com/beta/spell=391104
    mass_slow = {
        id = 391104,
        duration = 15,
        mechanic = "snare",
        type = "Magic",
        max_stack = 1
    },
    -- Talent: Damage taken is reduced by $s3% while your images are active.
    -- https://wowhead.com/beta/spell=55342
    mirror_image = {
        id = 55342,
        duration = 40,
        max_stack = 3,
        generate = function ()
            local mi = buff.mirror_image

            if action.mirror_image.lastCast > 0 and query_time < action.mirror_image.lastCast + 40 then
                mi.count = 1
                mi.applied = action.mirror_image.lastCast
                mi.expires = mi.applied + 40
                mi.caster = "player"
                return
            end

            mi.count = 0
            mi.applied = 0
            mi.expires = 0
            mi.caster = "nobody"
        end,
    },
    numbing_blast = {
        id = 417490,
        duration = 6,
        max_stack = 1
    },
    permafrost_lances = {
        id = 455122,
        duration = 15,
        max_stack = 1
    },
    polymorph = {
        id = 118,
        duration = 60,
        max_stack = 1
    },
    -- Talent: Movement slowed by $w1%.  Taking $w2 Frost damage every $t2 sec.
    -- https://wowhead.com/beta/spell=205021
    ray_of_frost = {
        id = 205021,
        duration = 5,
        type = "Magic",
        max_stack = 1
    },
    shatter = {
        id = 12982,
    },
    -- Talent: Every $t1 sec, deal $382445s1 Nature damage to enemies within $382445A1 yds and reduce the remaining cooldown of your abilities by ${-$s2/1000} sec.
    -- https://wowhead.com/beta/spell=382440
    shifting_power = {
        id = 382440,
        duration = 4,
        tick_time = 1,
        type = "Magic",
        max_stack = 1,
        copy = 314791
    },
    -- Talent: Shimmering.
    -- https://wowhead.com/beta/spell=212653
    shimmer = {
        id = 212653,
        duration = 0.65,
        type = "Magic",
        max_stack = 1
    },
    -- Talent: Cast time of Frostbolt reduced by $s1% and its damage is increased by $s2%.
    -- https://wowhead.com/beta/spell=382148
    slick_ice = {
        id = 382148,
        duration = 60,
        max_stack = 5,
        copy = 327509
    },
    -- Talent: Movement speed reduced by $w1%.
    -- https://wowhead.com/beta/spell=31589
    slow = {
        id = 31589,
        duration = 15,
        mechanic = "snare",
        type = "Magic",
        max_stack = 1
    },
    slow_fall = {
        id = 130,
        duration = 30,
        max_stack = 1,
    },
    -- Talent: Absorbs $w1 damage.
    -- https://wowhead.com/beta/spell=382290
    tempest_barrier = {
        id = 382290,
        duration = 15,
        type = "Magic",
        max_stack = 1
    },
    winters_chill = {
        id = 228358,
        duration = 8,
        type = "Magic",
        max_stack = 2
    },
    wintertide = {
        id = 1222865,
        duration = 15,
        max_stack = 4
    },

    frozen = {
        duration = 1,

        meta = {
            spell = function( t )
                if debuff.winters_chill.up and remaining_winters_chill > 0 then return debuff.winters_chill end
                local spell = debuff.frost_nova

                if debuff.frostbite.remains     > spell.remains then spell = debuff.frostbite     end
                if debuff.freeze.remains        > spell.remains then spell = debuff.freeze        end
                if debuff.glacial_spike.remains > spell.remains then spell = debuff.glacial_spike end

                return spell
            end,

            up = function( t )
                return t.spell.up
            end,
            down = function( t )
                return t.spell.down
            end,
            applied = function( t )
                return t.spell.applied
            end,
            expires = function( t )
                return t.spell.expires
            end,
            remains = function( t )
                return t.spell.remains
            end,
            count = function(t )
                return t.spell.count
            end,
            stack = function( t )
                return t.spell.stack
            end,
            stacks = function( t )
                return t.spell.stacks
            end,
        }
    },

    -- Azerite Powers (overrides)
    frigid_grasp = {
        id = 279684,
        duration = 20,
        max_stack = 1,
    },
    overwhelming_power = {
        id = 266180,
        duration = 25,
        max_stack = 25,
    },
    tunnel_of_ice = {
        id = 277904,
        duration = 300,
        max_stack = 3
    },

    -- Legendaries
    expanded_potential = {
        id = 327495,
        duration = 300,
        max_stack = 1
    },
} )

spec:RegisterPet( "water_elemental", 208441, "icy_veins", function() return talent.thermal_void.enabled and 30 or 25 end )

spec:RegisterStateExpr( "fingers_of_frost_active", function ()
    return false
end )

spec:RegisterStateFunction( "fingers_of_frost", function( active )
    fingers_of_frost_active = active
end )

local wc_spenders = {
    frostbolt = true,
    glacial_spike = true,
    ice_lance = true,
    frostfire_bolt = true,
}

spec:RegisterStateExpr( "remaining_winters_chill", function ()
    local wc = debuff.winters_chill
    local stacks, remains = wc.stack, wc.remains

    if stacks == 0 or remains == 0 then
        if Hekili.ActiveDebug then Hekili:Debug( "Remaining Winters Chill(%s): No stacks or remaining time.", this_action ) end
        return 0
    end

    if this_action == "ice_lance" and action.ice_lance.time_since > 0.3 and
            ( action.frostbolt.in_flight or action.glacial_spike.in_flight or action.frostfire_bolt.in_flight ) then
        -- Credit back the stack of Winter's Chill that these will consume so you can double-dip with Ice Lance.
        stacks = stacks + 1
    end

    local ability = class.abilities[ this_action ]
    local cast = ability and ability.cast or 0

    if remains < cast then
        if Hekili.ActiveDebug then Hekili:Debug( "Remaining Winters Chill(%s): No time to cast.", this_action ) end
        return 0
    end

    if stacks > 1 and remains < 0.1 + cast + gcd.max then
        if Hekili.ActiveDebug then
            Hekili:Debug( "Remaining Winters Chill(%s): Stacks reduced as cast time + GCD (%.2f) exceeds remaining time (%.2f).", this_action, 0.1 + cast + gcd.max, remains )
        end
        stacks = stacks - 1
    end

    local projectiles = 0
    local fof_consumed = buff.fof_consumed.remains

    for spender in pairs( wc_spenders ) do
        local a = action[ spender ]
        local in_flight_remains = a.in_flight_remains
        if in_flight_remains > 0 and in_flight_remains < remains then
            if spender == "ice_lance" and fof_consumed > in_flight_remains then
                if Hekili.ActiveDebug then Hekili:Debug( "Remaining Winters Chill(%s): Ice Lance in flight, but FoF consumed before it hits.", this_action ) end
            else
                if Hekili.ActiveDebug then Hekili:Debug( "Remaining Winters Chill(%s): Added %s projectile.", this_action, spender ) end
                projectiles = projectiles + 1
            end
        end
    end

    local result = max( 0, stacks - projectiles )

    if Hekili.ActiveDebug then
        Hekili:Debug( "Remaining Winters Chill(%s): FoF Consumed[%s], Winter's Chill[%d => %d, %.2f vs. %.2f], Projectiles[%d]; Value[%d]",
            this_action, buff.fof_consumed.up and "true" or "false",
            wc.stack, stacks, remains, cast,
            projectiles,
            result )
    end
    return result
end )


spec:RegisterStateTable( "ground_aoe", {
    frozen_orb = setmetatable( {}, {
        __index = setfenv( function( t, k )
            if k == "remains" then
                return buff.frozen_orb.remains
            end
        end, state )
    } ),

    blizzard = setmetatable( {}, {
        __index = setfenv( function( t, k )
            if k == "remains" then return buff.active_blizzard.remains end
        end, state )
    } )
} )

spec:RegisterStateExpr( "freezable", function ()
    return not target.is_boss or target.level < level + 3
end )

spec:RegisterStateTable( "frost_info", {
    last_target_actual = "nobody",
    last_target_virtual = "nobody",
    watching = true,

    -- real_brain_freeze = false,
    -- virtual_brain_freeze = false
} )

local lastCometCast = 0
local lastAutoComet = 0

local latestFingersLance = 0 -- Sorry, Lance
local numLances = 0
local lanceRemoved, lanceICD = 0, 0.3 -- Only count one Ice Lance impact per lanceICD seconds.

local numFingers = 0

local auraChanged = {
    SPELL_AURA_APPLIED = true,
    SPELL_AURA_REFRESH = true,
    SPELL_AURA_REMOVED = true,
    SPELL_AURA_APPLIED_DOSE = true,
    SPELL_AURA_REMOVED_DOSE = true
}

local auraSpent = {
    SPELL_AURA_REMOVED = true,
    SPELL_AURA_REMOVED_DOSE = true
}

spec:RegisterHook( "COMBAT_LOG_EVENT_UNFILTERED", function( _, subtype, _, sourceGUID, sourceName, _, _, destGUID, destName, destFlags, _, spellID, spellName )
    if sourceGUID == GUID then
        if subtype == "SPELL_CAST_SUCCESS" then
            if spellID == 116 then frost_info.last_target_actual = destGUID
            elseif spellID == 30455 then
                -- There appears to be a consistent ~0.1s delay between Ice Lance's cast and Fingers of Frost being consumed.
                local fof = GetPlayerAuraBySpellID( 44544 )

                if fof then
                    latestFingersLance = GetTime() + 1
                    numLances = numLances + 1
                    numFingers = numFingers + 1
                end
            end
        end

        if spellID == 44544 and auraSpent[ subtype ] then
            -- Decrement numberr of FoF stacks to remove.
            numFingers = max( 0, numFingers - 1 )
        end

        local now = GetTime()

        if subtype == "SPELL_DAMAGE" and spellID == 30455 and now - lanceRemoved > lanceICD then
            numLances = max( 0, numLances - 1 )
            if numLances == 0 then latestFingersLance = 0 end
        end

        if state.talent.glacial_spike.enabled and ( spellID == 205473 or spellID == 199844 ) and auraChanged[ subtype ] then
            Hekili:ForceUpdate( "ICICLES_CHANGED", true )
        end

        if spellID == 44544 and auraSpent[ subtype ] then
            local fof = GetPlayerAuraBySpellID( 44544 )
            pendingFinger = false

            -- print( "Fingers of Frost: ", subtype, spellID, spellName, fof and fof.expires or 0, fof and max( 1, fof.applications ) or 0, pendingFinger )
        end

        if ( spellID == 153595 or spellID == 153596 ) then
            local t = GetTime()

            if subtype == "SPELL_CAST_SUCCESS" then
                lastCometCast = t
            elseif subtype == "SPELL_DAMAGE" and t - lastCometCast > 3 and t - lastAutoComet > 3 then
                -- TODO:  Revisit strategy for detecting auto comets.
                lastAutoComet = t
            end
        end
    end
end, false )

spec:RegisterStateExpr( "brain_freeze_active", function ()
    return buff.brain_freeze.up -- frost_info.virtual_brain_freeze
end )


spec:RegisterStateTable( "rotation", setmetatable( {},
{
    __index = function( t, k )
        if k == "standard" then return true end
        return false
    end,
} ) )


spec:RegisterStateTable( "incanters_flow", {
    changed = 0,
    count = 0,
    direction = 0,

    startCount = 0,
    startTime = 0,
    startIndex = 0,

    values = {
        [0] = { 0, 1 },
        { 1, 1 },
        { 2, 1 },
        { 3, 1 },
        { 4, 1 },
        { 5, 0 },
        { 5, -1 },
        { 4, -1 },
        { 3, -1 },
        { 2, -1 },
        { 1, 0 }
    },

    f = CreateFrame( "Frame" ),
    fRegistered = false,

    reset = setfenv( function ()
        if talent.incanters_flow.enabled then
            if not incanters_flow.fRegistered then
                Hekili:ProfileFrame( "Incanters_Flow_Frost", incanters_flow.f )
                -- One-time setup.
                incanters_flow.f:RegisterUnitEvent( "UNIT_AURA", "player" )
                incanters_flow.f:SetScript( "OnEvent", function ()
                    -- Check to see if IF changed.
                    if state.talent.incanters_flow.enabled then
                        local flow = state.incanters_flow
                        local name, _, count = FindUnitBuffByID( "player", 116267, "PLAYER" )
                        local now = GetTime()

                        if name then
                            if count ~= flow.count then
                                if count == 1 then flow.direction = 0
                                elseif count == 5 then flow.direction = 0
                                else flow.direction = ( count > flow.count ) and 1 or -1 end

                                flow.changed = now
                                flow.count = count
                            end
                        else
                            flow.count = 0
                            flow.changed = now
                            flow.direction = 0
                        end
                    end
                end )

                incanters_flow.fRegistered = true
            end

            if now - incanters_flow.changed >= 1 then
                if incanters_flow.count == 1 and incanters_flow.direction == 0 then
                    incanters_flow.direction = 1
                    incanters_flow.changed = incanters_flow.changed + 1
                elseif incanters_flow.count == 5 and incanters_flow.direction == 0 then
                    incanters_flow.direction = -1
                    incanters_flow.changed = incanters_flow.changed + 1
                end
            end

            if incanters_flow.count == 0 then
                incanters_flow.startCount = 0
                incanters_flow.startTime = incanters_flow.changed + floor( now - incanters_flow.changed )
                incanters_flow.startIndex = 0
            else
                incanters_flow.startCount = incanters_flow.count
                incanters_flow.startTime = incanters_flow.changed + floor( now - incanters_flow.changed )
                incanters_flow.startIndex = 0

                for i, val in ipairs( incanters_flow.values ) do
                    if val[1] == incanters_flow.count and val[2] == incanters_flow.direction then incanters_flow.startIndex = i; break end
                end
            end
        else
            incanters_flow.count = 0
            incanters_flow.changed = 0
            incanters_flow.direction = 0
        end
    end, state ),
} )


spec:RegisterStateExpr( "bf_flurry", function () return false end )
spec:RegisterStateExpr( "comet_storm_remains", function () return buff.active_comet_storm.remains end )

-- The War Within
spec:RegisterGear( "tww2", 229346, 229344, 229342, 229343, 229341 )
spec:RegisterAuras( {
   --[[ 2-set
    jackpot = {
        -- spells have a chance to proc a jackpot that generates a frostbolt valley hitting a primary target and spreading to surrounding mobs (until 8). Casting Icy Veins always procs it
    },--]]
   -- 4-set
    extended_bankroll = {
        id = 1216914,
        duration = 30,
        max_stack = 1
    },

} )

-- Dragonflight

spec:RegisterGear( "tier31", 207288, 207289, 207290, 207291, 207293, 217232, 217234, 217235, 217231, 217233 )
spec:RegisterGear( "tier30", 202554, 202552, 202551, 202550, 202549 )
spec:RegisterGear( "tier29", 200318, 200320, 200315, 200317, 200319 )
spec:RegisterAura( "touch_of_ice", {
    id = 394994,
    duration = 6,
    max_stack = 1
} )


local BrainFreeze = setfenv( function()
    if talent.perpetual_winter.enabled then gainCharges( "flurry", 1 ) else setCooldown( "flurry", 0 ) end
    applyBuff( "brain_freeze" )
end, state )

spec:RegisterHook( "reset_precast", function ()
    frost_info.last_target_virtual = frost_info.last_target_actual

    local fof_remains = max( 0, latestFingersLance - query_time )
    if fof_remains > 0 then
        applyBuff( "fof_consumed", fof_remains, numLances )
        if Hekili.ActiveDebug then Hekili:Debug( "Applied fof_consumed for %.2f seconds with %d stacks.", fof_remains, numLances ) end
    end

    if numFingers > 0 then
        removeStack( "fingers_of_frost", numFingers )
        if Hekili.ActiveDebug then Hekili:Debug( "Removed %d stacks of fingers_of_frost due to buffed ice_lances in flight.", numFingers ) end
    end

    if Hekili.ActiveDebug then Hekili:Debug( "Buffed Ice Lances in-flight: %d, FoF Consumed stacks: %d, FoF Consumed Remains: %.2f, Remaining FoF: %d", numLances, buff.fof_consumed.stack, buff.fof_consumed.remains, buff.fingers_of_frost.stack ) end

    if action.flurry.in_flight then
        if Hekili.ActiveDebug then Hekili:Debug( "Flurry is in-flight, keep Winter's Chill stacks at 2." ) end
        applyDebuff( "target", "winters_chill", nil, 2 )
    end

    -- Icicles take a second to get used.
    if not state.talent.glacial_spike.enabled and action.ice_lance.time_since < gcd.max then removeBuff( "icicles" ) end

    incanters_flow.reset()

    local remaining_pet = class.auras.icy_veins.duration - action.icy_veins.time_since
    if remaining_pet > 0 then
        summonPet( "water_elemental", remaining_pet )
    end

    if  active_dot.glacial_spike > 0 and debuff.glacial_spike.down or
        active_dot.winters_chill > 0 and debuff.winters_chill.down or
        active_dot.freeze > 0 and debuff.freeze.down or
        active_dot.frostbite > 0 and debuff.frostbite.down or
        active_dot.frost_nova > 0 and debuff.frost_nova.down then
        active_dot.frozen = active_dot.frozen + 1
    end

    -- Trigger expr function for debug text.
    if Hekili.ActiveDebug then spec.stateExprs.remaining_winters_chill() end
end )

spec:RegisterHook( "runHandler", function( action )

    local ability = class.abilities[ action ]

    if buff.ice_floes.up and ability and ability.cast > 0 and ability.cast < 10 then removeStack( "ice_floes" ) end

    if talent.frostfire_mastery.enabled and ability then
        if ability.school == "fire" or ability.school == "frostfire" then
            if buff.fire_mastery.up then applyBuff( "fire_mastery", buff.fire_mastery.remains, min( spec.auras.fire_mastery.max_stack, buff.fire_mastery.stack + 1 ) )
            else addStack( "fire_mastery" ) end
        end
        if ability.school == "frost" or ability.school == "frostfire" then
            if buff.frost_mastery.up then applyBuff( "frost_mastery", buff.frost_mastery.remains, min( spec.auras.frost_mastery.max_stack, buff.frost_mastery.stack + 1 ) )
            else applyBuff( "frost_mastery" ) end
        end
    end

end )


Hekili:EmbedDisciplinaryCommand( spec )

-- Abilities
spec:RegisterAbilities( {
    -- Ice shards pelt the target area, dealing 986 Frost damage over 7.1 sec and reducing movement speed by 60% for 3 sec. Each time Blizzard deals damage, the cooldown of Frozen Orb is reduced by 0.50 sec.
    blizzard = {
        id = 190356,
        cast = function () return buff.freezing_rain.up and 0 or 2 * haste end,
        cooldown = 8,
        hasteCD = true,
        gcd = "spell",
        school = "frost",

        spend = 0.02,
        spendType = "mana",

        startsCombat = true,

        velocity = 20,

        usable = function ()
            if not buff.freezing_rain.up and moving and settings.prevent_hardcasts and action.blizzard.cast_time > buff.ice_floes.remains then return false, "prevent_hardcasts during movement and ice_floes is down" end
            return true
        end,

        handler = function ()
            applyDebuff( "target", "blizzard" )
            applyBuff( "active_blizzard" )

        end,
    },

    -- Resets the cooldown of your Ice Barrier, Frost Nova, $?a417493[][Cone of Cold, ]Ice Cold, and Ice Block.
    cold_snap = {
        id = 235219,
        cast = 0,
        cooldown = 300,
        gcd = "off",
        school = "physical",

        startsCombat = false,
        toggle = "cooldowns",

        handler = function ()
            setCooldown( "ice_barrier", 0 )
            setCooldown( "frost_nova", 0 )
            if not talent.coldest_snap.enabled then setCooldown( "cone_of_cold", 0 ) end
            setCooldown( "ice_cold", 0 )
            setCooldown( "ice_block", 0 )
        end,
    },

    -- Calls down a series of 7 icy comets on and around the target, that deals up to 3,625 Frost damage to all enemies within 6 yds of its impacts.
    comet_storm = {
        id = 153595,
        cast = 0,
        cooldown = 30,
        gcd = "spell",
        school = "frost",

        spend = 0.01,
        spendType = "mana",

        talent = "comet_storm",
        startsCombat = false,

        flightTime = 2.6,

        handler = function ()
            applyBuff( "active_comet_storm" )
        end,

        impact = function ()
            -- noop.
        end,
    },


    -- Targets in a cone in front of you take 383 Frost damage and have movement slowed by 70% for 5 sec.
    cone_of_cold = {
        id = 120,
        cast = 0,
        cooldown = function() return talent.coldest_snap.enabled and 45 or 12 end,
        gcd = "spell",
        school = "frost",

        spend = 0.04,
        spendType = "mana",

        startsCombat = true,

        usable = function () return not settings.check_cone_range or target.maxR <= 12, strformat( "check_cone_range enabled and distance is %d", target.maxR ) end,
        handler = function ()
            applyDebuff( "target", talent.freezing_cold.enabled and "freezing_cold" or "cone_of_cold" )
            active_dot.cone_of_cold = max( active_enemies, active_dot.cone_of_cold )
            removeDebuffStack( "target", "winters_chill" )

            if talent.coldest_snap.enabled then
                if true_active_enemies >= 3 then
                    setCooldown( "frozen_orb", 0 )
                    setCooldown( "comet_storm", 0 )
                end
                applyDebuff( "target", "winters_chill" )
                active_dot.winters_chill = max( active_enemies, active_dot.winters_chill )
            end
            if talent.bone_chilling.enabled then addStack( "bone_chilling" ) end
        end,
    },

    -- Unleash a flurry of ice, striking the target 3 times for a total of 1,462 Frost damage. Each hit reduces the target's movement speed by 80% for 1 sec and applies Winter's Chill to the target. Winter's Chill causes the target to take damage from your spells as if it were frozen.
    flurry = {
        id = 44614,
        cast = 0,
        charges = function() if talent.perpetual_winter.enabled then return 2 end end,
        cooldown = 30,
        recharge = function() if talent.perpetual_winter.enabled then return 30 end end,
        gcd = "spell",
        school = "frost",

        spend = 0.01,
        spendType = "mana",

        talent = "flurry",
        startsCombat = true,
        flightTime = 0.5,

        handler = function ()
            removeBuff( "brain_freeze" )
            applyDebuff( "target", "winters_chill", nil, 2 )
            if Hekili.ActiveDebug then Hekili:Debug( "Winter's Chill applied by Flurry." ) end
            applyDebuff( "target", "flurry" )

            if buff.expanded_potential.up then removeBuff( "expanded_potential" )
            elseif legendary.sinful_delight.enabled then gainChargeTime( "mirrors_of_torment", 4 )
            end

            if buff.cold_front_ready.up then
                spec.abilities.frozen_orb.handler()
                removeBuff( "cold_front_ready" )
            end

            if talent.cold_front.enabled or legendary.cold_front.enabled then
                if buff.cold_front.stack < 29 then addStack( "cold_front" )
                else
                    removeBuff( "cold_front" )
                    applyBuff( "cold_front_ready" )
                end
            end

            applyDebuff( "target", "flurry" )
            addStack( "icicles" )
            if talent.glacial_spike.enabled and buff.icicles.stack == buff.icicles.max_stack then
                applyBuff( "glacial_spike_usable" )
            end

            if talent.bone_chilling.enabled then addStack( "bone_chilling" ) end
            removeBuff( "ice_floes" )
        end,

        impact = function()
            -- This wipes out the effect of a prior projectile impacting and wiping out a stack when Flurry will re-max it.
            if Hekili.ActiveDebug then Hekili:Debug( "Winter's Chill reapplied by Flurry impact." ) end
            applyDebuff( "target", "winters_chill", nil, 2 )
            applyDebuff( "target", "flurry" )
            applyBuff( "bone_chilling", nil, 3 )
            if talent.frostfire_mastery.enabled then
                if buff.frost_mastery.up then applyBuff( "frost_mastery", buff.frost_mastery.expires, min( buff.frost_mastery.stacks + 3, 6) )
                else applyBuff( "frost_mastery", nil, 3 ) end
                if buff.excess_frost.up then
                    removeStack( "excess_frost" )
                    spec.abilities.ice_nova.handler()
                    reduceCooldown( "comet_storm", 3 )
                end
            end
        end,

        copy = 228354 -- ID of the Flurry impact.
    },

    -- Places a Frost Bomb on the target. After 5 sec, the bomb explodes, dealing 2,713 Frost damage to the target and 1,356 Frost damage to all other enemies within 10 yards. All affected targets are slowed by 80% for 4 sec.
    frost_bomb = {
        id = 390612,
        cast = 1.33,
        cooldown = 15,
        gcd = "spell",
        school = "frost",

        spend = 0.01,
        spendType = "mana",

        pvptalent = "frost_bomb",
        startsCombat = false,
        texture = 609814,

        handler = function ()
            if talent.bone_chilling.enabled then addStack( "bone_chilling" ) end
        end,
    },

    -- Launches a bolt of frost at the enemy, causing 890 Frost damage and slowing movement speed by 60% for 8 sec.
    frostbolt = {
        id = 116,
        cast = function ()
            if buff.frostfire_empowerment.up then return 0 end
            return 2 * ( 1 - 0.04 * buff.slick_ice.stack ) * haste
        end,
        cooldown = 0,
        gcd = "spell",
        school = "frost",

        spend = 0.02,
        spendType = "mana",

        notalent = "frostfire_bolt",
        startsCombat = true,
        velocity = 35,

        max_targets = function() return talent.fractured_frost.enabled and buff.icy_veins.up and min( 3, active_enemies ) or 1 end,

        usable = function ()
            if moving and settings.prevent_hardcasts and action.frostbolt.cast_time > buff.ice_floes.remains then return false, "prevent_hardcasts during movement and ice_floes is down" end
            return true
        end,

        handler = function ()
            addStack( "icicles" )

            if buff.frostfire_empowerment.up then
                if talent.flash_freezeburn.enabled then
                    applyBuff( "frost_mastery", nil, 6 )
                    addStack( "excess_frost" )
                    applyBuff( "fire_mastery", nil, 6 )
                    addStack( "excess_fire" )
                end
                removeBuff( "frostfire_empowerment" )
            end

            if talent.glacial_spike.enabled and buff.icicles.stack == buff.icicles.max_stack then
                applyBuff( "glacial_spike_usable" )
            end

            if talent.deaths_chill.enabled and buff.icy_veins.up then
                addStack( "deaths_chill", buff.icy_veins.remains, action.frostbolt.max_targets )
            end


            if buff.cold_front_ready.up then
                spec.abilities.frozen_orb.handler()
                removeBuff( "cold_front_ready" )
            end

            if talent.bone_chilling.enabled then addStack( "bone_chilling" ) end
            if talent.slick_ice.enabled or legendary.slick_ice.enabled then addStack( "slick_ice" ) end

            if talent.cold_front.enabled or legendary.cold_front.enabled then
                if buff.cold_front.stack < 29 then addStack( "cold_front" )
                else
                    removeBuff( "cold_front" )
                    applyBuff( "cold_front_ready" )
                end
            end

            if azerite.tunnel_of_ice.enabled then
                if frost_info.last_target_virtual == target.unit then
                    addStack( "tunnel_of_ice" )
                else
                    removeBuff( "tunnel_of_ice" )
                end
                frost_info.last_target_virtual = target.unit
            end
        end,

        impact = function ()
            applyDebuff( "target", "chilled" )
            if not action.flurry.in_flight then removeDebuffStack( "target", "winters_chill" ) end
        end,

        bind = "frostfire_bolt",
        copy = { 116, 228597 }
    },


    -- Launches a bolt of frost at the enemy, causing 890 Frost damage and slowing movement speed by 60% for 8 sec.
    frostfire_bolt = {
        id = 431044,
        cast = function ()
            if buff.frostfire_empowerment.up then return 0 end
            return 2 * ( 1 - 0.04 * buff.slick_ice.stack ) * haste
        end,
        cooldown = 0,
        gcd = "spell",
        school = "frostfire",

        spend = 0.02,
        spendType = "mana",

        talent = "frostfire_bolt",
        startsCombat = true,
        velocity = 35,

        max_targets = function() return talent.fractured_frost.enabled and buff.icy_veins.up and min( 3, active_enemies ) or 1 end,

        usable = function ()
            if moving and settings.prevent_hardcasts and action.frostfire_bolt.cast_time > buff.ice_floes.remains then return false, "prevent_hardcasts during movement and ice_floes is down" end
            return true
        end,

        handler = function ()
            addStack( "icicles" )

            if buff.frostfire_empowerment.up then
                if talent.flash_freezeburn.enabled then
                    applyBuff( "frost_mastery", nil, 6 )
                    addStack( "excess_frost" )
                    applyBuff( "fire_mastery", nil, 6 )
                    addStack( "excess_fire" )
                end
                removeBuff( "frostfire_empowerment" )
            end

            if talent.glacial_spike.enabled and buff.icicles.stack == buff.icicles.max_stack then
                applyBuff( "glacial_spike_usable" )
            end

            if talent.deaths_chill.enabled and buff.icy_veins.up then
                addStack( "deaths_chill", buff.icy_veins.remains, action.frostfire_bolt.max_targets )
            end


            if buff.cold_front_ready.up then
                spec.abilities.frozen_orb.handler()
                removeBuff( "cold_front_ready" )
            end

            if talent.bone_chilling.enabled then addStack( "bone_chilling" ) end
            if talent.slick_ice.enabled or legendary.slick_ice.enabled then addStack( "slick_ice" ) end

            if talent.cold_front.enabled or legendary.cold_front.enabled then
                if buff.cold_front.stack < 29 then addStack( "cold_front" )
                else
                    removeBuff( "cold_front" )
                    applyBuff( "cold_front_ready" )
                end
            end

            if azerite.tunnel_of_ice.enabled then
                if frost_info.last_target_virtual == target.unit then
                    addStack( "tunnel_of_ice" )
                else
                    removeBuff( "tunnel_of_ice" )
                end
                frost_info.last_target_virtual = target.unit
            end
        end,

        impact = function ()
            applyDebuff( "target", "chilled" )
            if not action.flurry.in_flight then removeDebuffStack( "target", "winters_chill" ) end
            applyDebuff( "target", "frostfire_bolt" )
        end,

        bind = "frostbolt"
    },

    -- Launches an orb of swirling ice up to 40 yards forward which deals up to 5,687 Frost damage to all enemies it passes through. Deals reduced damage beyond 8 targets. Grants 1 charge of Fingers of Frost when it first damages an enemy. While Frozen Orb is active, you gain Fingers of Frost every 2 sec. Enemies damaged by the Frozen Orb are slowed by 40% for 3 sec.
    frozen_orb = {
        id = 84714,
        cast = 0,
        cooldown = 60,
        gcd = "spell",
        school = "frost",

        spend = 0.01,
        spendType = "mana",

        talent = "frozen_orb",
        startsCombat = true,

        toggle = "cooldowns",
        -- velocity = 20,
        flightTime = 12,

        handler = function ()
            applyBuff( "frozen_orb" )
            if talent.freezing_rain.enabled then applyBuff( "freezing_rain" ) end
            if talent.permafrost_lances.enabled then applyBuff( "permafrost_lances" ) end
        end,

        impact = function() end,

        --[[ Not modeling because you can throw it off in a random direction and get no procs.  Just react.
        impact = function ()
            addStack( "fingers_of_frost" )
            applyDebuff( "target", "frozen_orb_snare" )
        end, ]]

        copy = 198149
    },

    -- Conjures a massive spike of ice, and merges your current Icicles into it. It impales your target, dealing 3,833 damage plus all of the damage stored in your Icicles, and freezes the target in place for 4 sec. Damage may interrupt the freeze effect. Requires 5 Icicles to cast. Passive: Ice Lance no longer launches Icicles.
    glacial_spike = {
        id = 199786,
        cast = 2.75,
        cooldown = 0,
        gcd = "spell",
        school = "frost",

        spend = 0.01,
        spendType = "mana",

        talent = "glacial_spike",
        startsCombat = true,
        velocity = 40,

        usable = function()
            if moving and settings.prevent_hardcasts and action.glacial_spike.cast_time > buff.ice_floes.remains then return false, "prevent_hardcasts during movement and ice_floes is down" end
            return buff.icicles.stack == 5 or buff.glacial_spike_usable.up, "requires 5 icicles or glacial_spike!"
        end,

        handler = function ()
            removeBuff( "icicles" )
            removeBuff( "glacial_spike_usable" )

            if talent.bone_chilling.enabled then addStack( "bone_chilling" ) end
            if talent.thermal_void.enabled and buff.icy_veins.up then buff.icy_veins.expires = buff.icy_veins.expires + ( debuff.frozen.up and 4 or 1 ) end
        end,

        impact = function()
            applyDebuff( "target", "glacial_spike" )
            if not action.flurry.in_flight then removeDebuffStack( "target", "winters_chill" ) end
        end,

        copy = 228600
    },

    -- Shields you with ice, absorbing 5,674 damage for 1 min. Melee attacks against you reduce the attacker's movement speed by 60%.
    ice_barrier = {
        id = 11426,
        cast = 0,
        cooldown = 25,
        gcd = "spell",
        school = "frost",

        spend = 0.03,
        spendType = "mana",

        talent = "ice_barrier",
        startsCombat = false,

        handler = function ()
            applyBuff( "ice_barrier" )
            if legendary.triune_ward.enabled then
                applyBuff( "blazing_barrier" )
                applyBuff( "prismatic_barrier" )
            end
        end,
    },

    -- Quickly fling a shard of ice at the target, dealing 477 Frost damage. Ice Lance damage is tripled against frozen targets.
    ice_lance = {
        id = 30455,
        cast = 0,
        cooldown = 0,
        gcd = "spell",
        school = "frost",

        spend = 0.01,
        spendType = "mana",

        talent = "ice_lance",
        startsCombat = true,
        velocity = 47,

        aura = function()
            if buff.fingers_of_frost.up then return end
            return "frozen"
        end,

        cycle_to = function()
            if buff.fingers_of_frost.up then return end
            return true
        end,

        handler = function ()
            applyDebuff( "target", "chilled" )

            if not talent.glacial_spike.enabled then removeStack( "icicles" ) end
            if talent.bone_chilling.enabled then addStack( "bone_chilling" ) end

            if azerite.whiteout.enabled then
                cooldown.frozen_orb.expires = max( 0, cooldown.frozen_orb.expires - 0.5 )
            end

            if buff.fingers_of_frost.up or debuff.frozen.up then
                if talent.chain_reaction.enabled then addStack( "chain_reaction" ) end
                if talent.thermal_void.enabled and buff.icy_veins.up then
                    buff.icy_veins.expires = buff.icy_veins.expires + 0.5
                    pet.water_elemental.expires = buff.icy_veins.expires
                end

                if buff.fingers_of_frost.up then
                    removeStack( "fingers_of_frost" )
                    addStack( "fof_consumed" )
                end

                if talent.hailstones.enabled then
                    addStack( "icicles" )
                    if talent.glacial_spike.enabled and buff.icicles.stack_pct == 100 then
                        applyBuff( "glacial_spike_usable" )
                    end
                end

                if talent.cryopathy.enabled then addStack( "cryopathy" ) end
                if set_bonus.tier29_4pc > 0 then applyBuff( "touch_of_ice" ) end
            end
        end,

        impact = function ()
            removeDebuff( "target", "frozen" )

            if talent.frostfire_mastery.enabled then
                if buff.excess_fire.up then
                    removeStack( "excess_fire" )
                    addStack( "excess_frost" )
                    BrainFreeze()
                end
            end

            if buff.fof_consumed.up then
                if Hekili.ActiveDebug then Hekili:Debug( "Fingers of Frost consumed by Ice Lance." ) end
                removeStack( "fof_consumed" )
            else
                if action.flurry.in_flight then
                    if Hekili.ActiveDebug then Hekili:Debug( "Winter's Chill not consumed by Ice Lance because Flurry is in-flight." ) end
                else
                    if Hekili.ActiveDebug then Hekili:Debug( "Winter's Chill consumed by Ice Lance." ) end
                    removeDebuffStack( "target", "winters_chill" )
                end
            end
        end,

        copy = 228598
    },

    -- Talent: Causes a whirl of icy wind around the enemy, dealing 1,226 Frost damage to the target and reduced damage to all other enemies within 8 yards, and freezing them in place for 2 sec.
    ice_nova = {
        id = 157997,
        cast = 0,
        cooldown = 25,
        gcd = "spell",
        school = "frost",

        talent = "ice_nova",
        startsCombat = true,

        handler = function ()
            applyDebuff( "target", "ice_nova" )
        end,
    },

    -- Conjures an Ice Wall 30 yards long that obstructs line of sight. The wall has 40% of your maximum health and lasts up to 15 sec.
    ice_wall = {
        id = 352278,
        cast = 1.33,
        cooldown = 90,
        gcd = "spell",
        school = "frost",

        spend = 0.08,
        spendType = "mana",

        pvptalent = "ice_wall",
        startsCombat = false,
        texture = 4226156,

        toggle = "interrupts",

        handler = function ()
        end,
    },

    -- Accelerates your spellcasting for 25 sec, granting 30% haste and preventing damage from delaying your spellcasts. Activating Icy Veins grants a charge of Brain Freeze and Fingers of Frost.
    icy_veins = {
        id = function ()
            return pvptalent.ice_form.enabled and 198144 or 12472
        end,
        cast = 0,
        cooldown = function () return ( essence.vision_of_perfection.enabled and 0.87 or 1 ) * 180 end,
        gcd = "off",
        school = "frost",

        toggle = "cooldowns",

        startsCombat = false,

        handler = function ()
            summonPet( "water_elemental" )

            if talent.bone_chilling.enabled then addStack( "bone_chilling" ) end
            if talent.cryopathy.enabled then addStack( "cryopathy", nil, 10 ) end

            if talent.flash_freezeburn.enabled then applyBuff( "frostfire_empowerment" ) end

            if pvptalent.ice_form.enabled then applyBuff( "ice_form" )
            else
                if buff.icy_veins.down then stat.haste = stat.haste + 0.30 end
                applyBuff( "icy_veins" )
            end

            if azerite.frigid_grasp.enabled then
                applyBuff( "frigid_grasp", 10 )
                addStack( "fingers_of_frost" )
            end
        end,

        copy = { 12472, 198144, "ice_form" }
    },

    -- Channel an icy beam at the enemy for 4.4 sec, dealing 1,479 Frost damage every 0.9 sec and slowing movement by 70%. Each time Ray of Frost deals damage, its damage and snare increases by 10%. Generates 2 charges of Fingers of Frost over its duration.
    ray_of_frost = {
        id = 205021,
        cast = 5,
        channeled = true,
        cooldown = 60,
        gcd = "spell",
        school = "frost",

        spend = 0.02,
        spendType = "mana",

        talent = "ray_of_frost",
        startsCombat = true,
        texture = 1698700,

        toggle = "cooldowns",

        start = function ()
            applyDebuff( "target", "ray_of_frost" )
            if talent.bone_chilling.enabled then addStack( "bone_chilling" ) end
        end,
    },

    -- Summons a Ring of Frost for 10 sec at the target location. Enemies entering the ring are incapacitated for 10 sec. Limit 10 targets. When the incapacitate expires, enemies are slowed by 65% for 4 sec.
    ring_of_frost = {
        id = 113724,
        cast = 2,
        cooldown = 45,
        gcd = "spell",
        school = "frost",

        spend = 0.08,
        spendType = "mana",

        talent = "ring_of_frost",
        startsCombat = false,

        handler = function ()
        end,
    },

    -- Talent: Draw power from the Night Fae, dealing 2,168 Nature damage over 3.6 sec to enemies within 18 yds. While channeling, your Mage ability cooldowns are reduced by 12 sec over 3.6 sec.
    shifting_power = {
        id = function() return talent.shifting_power.enabled and 382440 or 314791 end,
        cast = 4,
        channeled = true,
        cooldown = 60,
        gcd = "spell",
        school = "nature",
        toggle = "cooldowns",

        spend = 0.05,
        spendType = "mana",

        startsCombat = true,


        usable = function ()
            if moving and settings.prevent_hardcasts and action.shifting_power.cast_time > buff.ice_floes.remains then return false, "prevent_hardcasts during movement and ice_floes is down" end
            return true
        end,

        cdr = function ()
            return - action.shifting_power.execute_time / action.shifting_power.tick_time * ( -3 + conduit.discipline_of_the_grove.time_value )
        end,

        full_reduction = function ()
            return - action.shifting_power.execute_time / action.shifting_power.tick_time * ( -3 + conduit.discipline_of_the_grove.time_value )
        end,

        start = function ()
            applyBuff( "shifting_power" )
        end,

        tick = function ()
            local seen = {}
            for _, a in pairs( spec.abilities ) do
                if not seen[ a.key ] and ( not talent.coldest_snap.enabled or a.key ~= "cone_of_cold" ) then
                    reduceCooldown( a.key, 3 )
                    seen[ a.key ] = true
                end
            end
        end,

        finish = function ()
            removeBuff( "shifting_power" )
        end,

        copy = { 382440, 314791 }
    },

    -- Summon a strong Blizzard that surrounds you for 6 sec that slows enemies by 80% and deals 246 Frost damage every 1 sec. Enemies that are caught in Snowdrift for 3 sec consecutively become Frozen in ice, stunned for 4 sec.
    snowdrift = {
        id = 389794,
        cast = 1.33,
        cooldown = 60,
        gcd = "spell",
        school = "frost",

        spend = 0.02,
        spendType = "mana",

        pvptalent = "snowdrift",
        startsCombat = false,
        texture = 135783,

        toggle = "cooldowns",

        handler = function ()
            applyBuff( "snowdrift" )
            if talent.bone_chilling.enabled then addStack( "bone_chilling" ) end
        end,
    },

    splinterstorm = {

    }, -- TODO: Support action.splinterstorm.in_flight

    --[[ Summons a Water Elemental to follow and fight for you.
    water_elemental = {
        id = 31687,
        cast = 1.5,
        cooldown = 30,
        gcd = "spell",
        school = "frost",

        spend = 0.03,
        spendType = "mana",

        startsCombat = false,

        notalent = "lonely_winter",
        nomounted = true,

        usable = function () return not pet.alive, "must not have a pet" end,
        handler = function ()
            summonPet( "water_elemental" )
        end,

        copy = "summon_water_elemental"
    }, ]]

    -- Water Elemental Abilities
    freeze = {
        id = 33395,
        known = true,
        cast = 0,
        cooldown = 25,
        gcd = "off",
        school = "frost",
        dual_cast = true,

        startsCombat = true,

        usable = function ()
            if target.is_boss then return false, "target is a boss" end
            if not pet.water_elemental.alive then return false, "requires water elemental" end
            return true
        end,

        handler = function ()
            applyDebuff( "target", "freeze" )
        end
    },

    water_jet = {
        id = 135029,
        known = true,
        cast = 0,
        cooldown = 20,
        gcd = "off",
        school = "frost",

        startsCombat = true,
        usable = function ()
            if not settings.manual_water_jet then return false, "requires manual water jet setting" end
            return pet.water_elemental.alive, "requires a living water elemental"
        end,
        handler = function()
            BrainFreeze()
        end
    }
} )

spec:RegisterRanges( "frostbolt", "polymorph", "fire_blast" )

spec:RegisterOptions( {
    enabled = true,

    aoe = 3,
    cycle = false,

    nameplates = false,
    nameplateRange = 40,
    rangeFilter = false,

    damage = true,
    damageExpiration = 6,

    potion = "tempered_potion",

    package = "Frost Mage",
} )


spec:RegisterSetting( "prevent_hardcasts", false, {
    name = strformat( "%s, %s, %s: Instant-Only When Moving",
        Hekili:GetSpellLinkWithTexture( spec.abilities.blizzard.id ),
        Hekili:GetSpellLinkWithTexture( spec.abilities.glacial_spike.id ),
        Hekili:GetSpellLinkWithTexture( spec.abilities.frostbolt.id )
    ),
    desc = strformat( "If checked, non-instant %s, %s, and %s casts will not be recommended while you are moving.\n\nAn exception is made if %s is talented and active, and your cast " ..
                      "would be complete before %s expires.",
        Hekili:GetSpellLinkWithTexture( spec.abilities.blizzard.id ),
        Hekili:GetSpellLinkWithTexture( spec.abilities.glacial_spike.id ),
        Hekili:GetSpellLinkWithTexture( spec.abilities.frostbolt.id ),
        Hekili:GetSpellLinkWithTexture( 108839 ),
        Hekili:GetSpellLinkWithTexture( 108839 )
    ),
    type = "toggle",
    width = "full"
} )

spec:RegisterSetting( "check_cone_range", true, {
    name = strformat( "%s: Range Check", Hekili:GetSpellLinkWithTexture( spec.abilities.cone_of_cold.id ) ),
    desc = strformat( "If checked, %s will not be recommended when you are more than 10 yards from your target.\n\n" ..
        "This setting may be counterproductive by wasting the cooldown resets from %s if you stay out of range of your target.",
        Hekili:GetSpellLinkWithTexture( spec.abilities.cone_of_cold.id ),
        spec.abilities.cone_of_cold.name ),
    type = "toggle",
    width = "full"
} )

spec:RegisterPack( "Frost Mage", 20250301, [[Hekili:DZvApoUns7FlgbWX90t7XsUDFey7fydWlqgSjFXbiFZYQLP7wOTowD090dm8V93IuxKuSOKSLZo7IaepJivXIfR6PoyPzTX6)C9QT2jK1)H5eZztMoXySP5T3p9X1Rs(iKSEvOTZR2pd)bFBp4)))ffeNCCZVZEuO9h7dS3sPrCqAKd8OxsscJ)LV8LNDtEj9PXobEFj21lDVDIBGVtK9Ue6F35lRx9uQ7(KFZF9tQyGz3oB9k70KxcIwVALR3Vcu2D7ws20jXoRxrN(ntMEZeJF54M)8V(RJBwrSJd8pUX84M0qknp(1JFfM2T3yyEJPjmTvHF4zhNqIIpUX1lmk4nIhXpPAEgaf)8XnWVg3N9RPj9xZBMCh99boPoXNadsN0KBmnY)9rSjp5XBmVfg8xd8iGCCvsqKh)GtOuG(7dz)MX2kP0d8dgg5ge5M8r9PDFg38NVqoU5VSJG)hC046VE1E34Ky6zNZEI9BeRD7G)YFW0ii(2pTNSD9)egeOkjY1g0hS3dYQXBj2jVeB58I7(9JZN4XndpU5P0D7g768H1Bex)4XrepB43JBwECZJSjmkFocuiobuWoUz(Xn3ECZHdAMYc2ua6m44gBhQ(04DuTXDUreRNc2Nm213A3E3NFbeSxbQpS5SEL4KwNaAAO7XDreY3PpNTqHrK3SE2z7yJXpV32X1EVvCO7ReEAdZNqP50ZKMSbZKzU(pB9URpvnntcW27tyZylHjFegE82G39lKmm6hSBhBnYzVs211Hy5h8MnLHVfLH1YInTe72Ngf9bDbMHUaJkvwCbDVyoDGzz6aWIKRTjWavQBx1lIRrchhI6jzmc3WoulwRyMbRG6v5g(Ul(gMreY3CiXXwuoDCAy9Nt3gWaQ4W7PCyXJ52q8SnmTh4NgqVVt8TcIEsAwpIUDzSdtXGE2ebNrfmA(MKQh6yVFpjQyhwTEpT397F3oAlDjmMOFnKKNWX(SkcjAYsPgo2MonjJksgz)bO4NjIzuehjjxguOsr8cdENer92uilgO88uhULboiJtqWEQEncaSrM5q5SQouvnTr8kKCQjvQJuD2sIXpdzQDvDcYlerOOWuQrYkru8lU7sONAmHlteHdRLDIaZME8wsD6HbDTr0aeXo3B77KPkntYeH)Ks0mXqgwO0(dmaSY(lwuFXzEKTYIZYlp0K10)BLDaXkoUvUNDaribitSVDOG75bQp(ZvghHJ1jHdw9UIQuyAbZuQeOokIs))k0INZcJqBeclPwRZe0qCc8j0dBQyPlU(hPZtD7qS7wucNRVSweRsPBaCBerHGAF9x0WyuhRcEOe5NbP(KOigqquWoWRaX35dbT)expG3UPmYrE9IX7HCcSsJPtDEjiyBFdqf)E1C9DTYn69nT3Q7SmtdmFyr)SADN(qtl1fl2EdZMdUNoN6r33uG9f(gFSDH2OjIICzqC4EMwzMivulcvXUUisuzUwGd444yb2uiMRaXz2Zn5alBqr7AUGfY0wHdu7TFiiCRh9eo0z7c(a49D0ZqRYXUodUEPahvJc693JJO2R(7XHm7fWUkSzfrwCHcQaECtP83x5TCgYO25nUptJdxpVVehNBACtBhwxdHc3TKNWDbFI5oDUEhBhOZ)7NXdUt9(ea8X2NVJSh2taAIMVttytx6qwAkzJff05cwoYMYPtnUgE2pTTiLDbVvaqTBXn)asws9q(jA3bNRhPlLeOwkpncpIxYXA(yQuBnfrg5bZ493iy))drwkCSmNevgTucPwyMquUQ9CMOREMNEMbAYa4VRsBEUbBOjU)ZWis5k1uS89C1uXHz(Hn2cTPcHhIwFgjGHCGBAcfqg14ecfylzNDkq5IybQmEtz8AiHYPclRScBRwvNTX69qwcKj4JNhdGs63aLtFINljoRCKtP5zf56qLgCGbP(OmsESpADdoGdx9Vb2jowFgaDNxOEH6mRuDp1A98DscNZHHYepn6Hun305fnlTDT(jBscCkRjBtMWUCyaH6j76wK2ro2GZwkecegGJmyGj)C9CJIcISC9y9rIW8KTadaq8yss17(MnSjHrP)P9PWpGhk6dZ51eWlVZlKOG0yRKiB)yp3eqUyvY4qykzUGLTV0((vRp2e0AIGymwqt(4FW1SLjY8mTwbS4CVBj8ANAZJQNUT)2EXkT4EkAXTL068aoJquAj72UEQq)Q0mxkxGRmVT1pg6AmaCzfG4VhxD8KRgUuG34iNJ0xzyiQOPtuERH0qBeZ5Ui)jTaN8szMiT59ICC9n0ve)iwyF8mrAxCWduZ7dVuL8))C1e6UMRj0DfIKSnq3Ueln5APlp6SQo0XwRPPKT6PSfUTw2cQsuqg2QePO9jkKfJIwxDNliCxklw5wTZ3YqFbRIFaFzGvBvdfMlaqHpBW)vFcFQdte3P3pKqI4Eq7tBz52cuPPSS)VtWsMMkUc74MI)MFxhehZK2sIAacFQjtIBcNtF64gY)o1nmKSDCCzNHB9o5joR5IyklpsYglROofPImMkiIdTZ7wkuQEvnLv1n6ur7s0W0mLQKROIHifZQEK(uCualvQZjStAPS2unkIaFv53fNogtMXriowjIegeLW3(x0J3ReCLJyNotscJiteBLnEHOKerbGBPrKxijAhKrSLDSdXFlyp9Hvmjk1tb(MoMvROUGV0SAkaPldnincSgbaIx9dEhgJMwE)ZBkwf9y(ASJNPx3IpKoP3M6FR25VcsCDMH4YAeGdlomG9RwxgAu)PilE2FJHfjKaw(KvbUlflb7ZHjYnm7H)UTFQn4CZ5fBaZNMFqGx2nsTyYNpU59xCDEb(70pgKyxpGjsJjuHys(dT3UL(j04y77hKie)j7sTawEY4muhkBuVyeYUjaYBbKWlwLBIQ4sdc2ATlLUBeJlSXljb)CxhOtZ6SgC32YtGnoj6vayTk9JYdb3icJ9L5CHYDr9GgdOk7zHMlo1eo3FAJETywJ3cooPumpGd(L5dligF)x1hGzUKHaPJeqKdIS85LiA8JWk0H4oTnvPg9cSLvIwkwic57VghPWZ23ECOtsz0Rnt886vs(w4(GyEJy(ZwqEsRwO4w(EzXswisshRWB9gO5qNe9BB7wdtty1F3oIgWfypW(ISa0AWdgObgeDCZpxwH7FMgBgefrevofhqn9Sttc8StOpiZ4oE8XV(VC9HHmyFqz(WQXg(NvKgmqWKa1dvCGatzKX3UQKQZutvHyLLiRYUEsMU3DHO7JQPBvcXseTEMYYu0yQAsYLOLenvC9ETLO8zcjrvv9pufzp(vfAszxBtVOgXB8wB7w3UU2(9IOCAEHuIqu6v1F5sKxxlOlVk337QQiuuOCrsevzPKKP7dxKtpJjQjRuhwirzK(VOblb29L1lgcNTY1LsPf5W)SGPqOz)Js1thoNPgjYrZzI99Fp25iopptdY8tSB7v9tLAs5Tjs3uLq8elEP51KMQUrD5TmYoUhOmIdQEGYiXL1dugvP9SPmI7PZIYk1VC22XGPQbOawjVssqRZuvNGNLfAbt32cu9ZyCErAJDJ9rnzpr8q1c1IouOB8MXLXfGbIpGZgBfJWNKBGJF93yYqkHOf1nln0JBy)R5bmoTWKehit2BP37cej6(YEviECzpWC9IVi3Uoh)QQzX3OoQNrrnW)mTeFlAx338zwN7SWWunjlkAKwsQ(vlUIZp7UBHy()lxmv9RuEtg1FN5lmPs883cMlFxhk8CPB3iJZbqd(jj1HvzZjleOpN1qwlmO8GsCQH47gDKoowG0d6lAxwPIoZ5lmBlXpfEVfuNLqqZSDBOtR4qonOXzN2fkDLtHJj4rQgQUgMlFC4iKwqy(JhoGm0IhhoiJnK9aw2ycxPGr5lbhhBYJ2pe5BHq1UM2ywuYu23kdhHDL6hoOMUdPLI(M8TI6VTILpOARuuatX1FGIwhdNPgICLPlMmeT7c69ns19UJSlz1JKUnR1s8zQcMdr(6puqpEe1A(NoCqLJqLQrLldLqA)sowAm5WbnFbhkipFUNCmQuckyhEkiOWHEPKuO9dwmt1rd7szuk6tdhk8SIBIxhrobTTwb2K1waLpw87Py4af8UcYkEDZchR1XSmMmuZ3lbD4rdQN9NGEqTVlc4TWSZfTau0aeho0ELbehdCA3kD)7X9pVC8VsCClXvhOsIbNpJuJNiGZu9gQT1leHZUQsWZ70i3psTdsnEywUWy2vk2QDe1VGBeESs6EoMjdr7KR6luhCC0N(nAGtYftQQ7Cl8SmhS4AEwlVx55PA3pSbpB3fflrvm59tKrgM4HgzykgBK2WIYnFrIZHn655osEZHOl0kxudhvVp0qH(oCOs7gPvIvjl6QFGrcx3(1gZwIpFvRxFIVF(aj60EvP40Axfq2Jx3YCHzcIG44Hcs25tnV2CYNq6gTCVf16VTdhgnOwFTD4acvUItbRUVcQnNMHn5IdvDVRnN5H)N(PI6Cuiv2gyHvPHe74xza1cIcJhG9f7e0j6JWexhl4PjrP5uTyA)d2uakdg(m1aFY3a67WkEZZa0kXARBXFu6TayyB)elANiSlaMbevLBm96)l1LNpkhKrAZs(gXjnHyrXJV24t5Of8GixPxTq8mbrBWCcQpDdkUz93WyYS8xbPN7wUyQ5v5qUkm1H3URL9C5SjnSxX7VnomqvSIsrI(1QE)Q1hRrwpJHzZod7uI6CtyUlNsxsC7RRnmxk8c1KSLVc(2AEElQ9jtWoK(p8Z9y)LjZov4WucoFYytPQ7mNR8oshyXQGjC9Fl4vAl(aQA(GRs6wm7KLz4bya7sJlolOBFXhNJV3f6cGMGnpyzdknXPEE5yZuAxFij)hz0UQz4QnszFOPrl8rKqJMJOEAmR2PGBElTjpGyxSj4QQOAGxF5QS1T4HVDBxQSLiVwpZKMZlGNcQtnOpZcqzEgiBNs7hug4ui2O6bwoFgwEAN0wCK8hot5riwTZWoqprMoZbExkwd)QQmzajBIAzmXpoFstzb0kCVsaZulvk1eQv5eO(vLZzb7C0OTM95BKtQgt8uURPxCrkZu1RXlN4Epv)d4Ly9PKHn6JuyWpbq0uBF2hf3btpIRGwnOwJ521YXCkGrDJzQKn4ueNlKX9uEY12KEZRTV63xQa8iSK(spiEmwyCXqB1ysoTEEhPH1Tluw4Kq5VCW2ZGTck8cwEeEEPRqydQZvNAvtKoZ67QQDhEuz31YAQXZHkQEOGRWw4hSTwlDbFfRQocgyTgAT4zSqQZ)InO8zTpWdqvq5Bv(nAWPwt4(AoqFjQIQYbLVnIbQUoc679gxxcyQElj9zvW2z5FDgawqlPsMFmADOr3mSZxE5k7I9V(0dc8uCw0UBVUZX0EUBLUhpBXkQmw2IbBfMA9x7ecTSuaOiY5IX6kQ6pQbgwSF6lqlozNYaclpQBnIfRvxo7GD6GTcLHVQ(63hbXuUx6TaykOyJbVu)vALbvNcsrbF1v7KEm6JcwOhvTX8fxQJOvRM9D5T())d]] )