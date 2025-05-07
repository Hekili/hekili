
-- MageFire.lua
-- January 2025

--[[ 11.1 TODO List
- Implement tier set effects
    - Combustion guaranteed jackpot CDR

--]]

if UnitClassBase( "player" ) ~= "MAGE" then return end

local addon, ns = ...
local Hekili = _G[ addon ]
local class, state = Hekili.Class, Hekili.State

local strformat = string.format

local spec = Hekili:NewSpecialization( 63 )

spec:RegisterResource( Enum.PowerType.ArcaneCharges )
spec:RegisterResource( Enum.PowerType.Mana )

-- Talents
spec:RegisterTalents( {
    -- Mage
    accumulative_shielding    = {  62093, 382800, 1 }, -- Your barrier's cooldown recharges 30% faster while the shield persists.
    alter_time                = {  62115, 342245, 1 }, -- Alters the fabric of time, returning you to your current location and health when cast a second time, or after 10 sec. Effect negated by long distance or death.
    arcane_warding            = {  62114, 383092, 2 }, -- Reduces magic damage taken by 3%.
    augury_abounds            = {  94662, 443783, 1 }, -- Casting Icy Veins conjures 8 Frost Splinters. During Icy Veins, whenever you conjure a Frost Splinter, you have a 100% chance to conjure an additional Frost Splinter.
    barrier_diffusion         = {  62091, 455428, 1 }, -- Whenever one of your Barriers is removed, reduce its cooldown by 4 sec.
    blast_wave                = {  62103, 157981, 1 }, -- Causes an explosion around yourself, dealing 45,935 Fire damage to all enemies within 8 yds, knocking them back, and reducing movement speed by 80% for 6 sec.
    blazing_barrier           = {  62119, 235313, 1 }, -- Shields you in flame, absorbing 1.5 million damage for 1 min. Melee attacks against you cause the attacker to take 12,152 Fire damage.
    controlled_instincts      = {  94663, 444483, 1 }, -- While a target is under the effects of Blizzard, 30% of the direct damage dealt by a Frost Splinter is also dealt to nearby enemies. Damage reduced beyond 5 targets.
    cryofreeze                = {  62107, 382292, 2 }, -- While inside Ice Block, you heal for 40% of your maximum health over the duration.
    displacement              = {  62095, 389713, 1 }, -- Teleports you back to where you last Blinked and heals you for 1.4 million health. Only usable within 8 sec of Blinking.
    diverted_energy           = {  62101, 382270, 2 }, -- Your Barriers heal you for 10% of the damage absorbed.
    dragons_breath            = { 101883,  31661, 1 }, -- Enemies in a cone in front of you take 56,631 Fire damage and are disoriented for 4 sec. Damage will cancel the effect.
    energized_barriers        = {  62100, 386828, 1 }, -- When your barrier receives melee attacks, you have a 10% chance to be granted 1 Fire Blast charge. Casting your barrier removes all snare effects.
    flow_of_time              = {  62096, 382268, 2 }, -- The cooldowns of Blink and Shimmer are reduced by 2 sec.
    force_of_will             = {  94656, 444719, 1 }, -- Gain 2% increased critical strike chance. Gain 5% increased critical strike damage.
    freezing_cold             = {  62087, 386763, 1 }, -- Enemies hit by Cone of Cold are frozen in place for 5 sec instead of snared. When your roots expire or are dispelled, your target is snared by 90%, decaying over 3 sec.
    frigid_winds              = {  62128, 235224, 2 }, -- All of your snare effects reduce the target's movement speed by an additional 10%.
    greater_invisibility      = {  93524, 110959, 1 }, -- Makes you invisible and untargetable for 20 sec, removing all threat. Any action taken cancels this effect. You take 60% reduced damage while invisible and for 3 sec after reappearing.
    ice_block                 = {  62122,  45438, 1 }, -- Encases you in a block of ice, protecting you from all attacks and damage for 10 sec, but during that time you cannot attack, move, or cast spells. While inside Ice Block, you heal for 40% of your maximum health over the duration. Causes Hypothermia, preventing you from recasting Ice Block for 30 sec.
    ice_cold                  = {  62085, 414659, 1 }, -- Ice Block now reduces all damage taken by 70% for 6 sec but no longer grants Immunity, prevents movement, attacks, or casting spells. Does not incur the Global Cooldown.
    ice_floes                 = {  62105, 108839, 1 }, -- Makes your next Mage spell with a cast time shorter than 10 sec castable while moving. Unaffected by the global cooldown and castable while casting.
    ice_nova                  = {  62088, 157997, 1 }, -- Causes a whirl of icy wind around the enemy, dealing 116,662 Frost damage to the target and all other enemies within 8 yds, freezing them in place for 2 sec. Damage reduced beyond 8 targets.
    ice_ward                  = {  62086, 205036, 1 }, -- Frost Nova now has 2 charges.
    improved_frost_nova       = {  62108, 343183, 1 }, -- Frost Nova duration is increased by 2 sec.
    incantation_of_swiftness  = {  62112, 382293, 2 }, -- Greater Invisibility increases your movement speed by 40% for 6 sec.
    incanters_flow            = {  62118,   1463, 1 }, -- Magical energy flows through you while in combat, building up to 10% increased damage and then diminishing down to 2% increased damage, cycling every 10 sec.
    inspired_intellect        = {  62094, 458437, 1 }, -- Arcane Intellect grants you an additional 3% Intellect.
    look_again                = {  94659, 444756, 1 }, -- Displacement has a 50% longer duration and 25% longer range.
    mass_barrier              = {  62092, 414660, 1 }, -- Cast Blazing Barrier on yourself and 4 allies within 40 yds.
    mass_invisibility         = {  62092, 414664, 1 }, -- You and your allies within 40 yards instantly become invisible for 12 sec. Taking any action will cancel the effect. Does not affect allies in combat.
    mass_polymorph            = {  62106, 383121, 1 }, -- Transforms all enemies within 10 yards into sheep, wandering around incapacitated for 15 sec. While affected, the victims cannot take actions but will regenerate health very quickly. Damage will cancel the effect. Only works on Beasts, Humanoids and Critters.
    master_of_time            = {  62102, 342249, 1 }, -- Reduces the cooldown of Alter Time by 10 sec. Alter Time resets the cooldown of Blink and Shimmer when you return to your original location.
    mirror_image              = {  62124,  55342, 1 }, -- Creates 3 copies of you nearby for 40 sec, which cast spells and attack your enemies. While your images are active damage taken is reduced by 20%. Taking direct damage will cause one of your images to dissipate.
    overflowing_energy        = {  62120, 390218, 1 }, -- Your spell critical strike damage is increased by 10%. When your direct damage spells fail to critically strike a target, your spell critical strike chance is increased by 2%, up to 10% for 8 sec. When your spells critically strike Overflowing Energy is reset.
    phantasmal_image          = {  94660, 444784, 1 }, -- Your Mirror Image summons one extra clone. Mirror Image now reduces all damage taken by an additional 5%.
    quick_witted              = {  62104, 382297, 1 }, -- Successfully interrupting an enemy with Counterspell reduces its cooldown by 4 sec.
    reabsorption              = {  62125, 382820, 1 }, -- You are healed for 3% of your maximum health whenever a Mirror Image dissipates due to direct damage.
    reactive_barrier          = {  94660, 444827, 1 }, -- Your Ice Barrier can absorb up to 50% more damage based on your missing Health. Max effectiveness when under 50% health.
    reduplication             = {  62125, 382569, 1 }, -- Mirror Image's cooldown is reduced by 10 sec whenever a Mirror Image dissipates due to direct damage.
    remove_curse              = {  62116,    475, 1 }, -- Removes all Curses from a friendly target.
    rigid_ice                 = {  62110, 382481, 1 }, -- Frost Nova can withstand 80% more damage before breaking.
    ring_of_frost             = {  62088, 113724, 1 }, -- Summons a Ring of Frost for 10 sec at the target location. Enemies entering the ring are incapacitated for 10 sec. Limit 10 targets. When the incapacitate expires, enemies are slowed by 75% for 4 sec.
    shifting_power            = {  62113, 382440, 1 }, -- Draw power from within, dealing 206,132 Arcane damage over 3.3 sec to enemies within 18 yds. While channeling, your Mage ability cooldowns are reduced by 12 sec over 3.3 sec.
    shifting_shards           = {  94657, 444675, 1 }, -- Shifting Power fires a barrage of 8 Frost Splinters at random enemies within 40 yds over its duration.
    shimmer                   = {  62105, 212653, 1 }, -- Teleports you 20 yds forward, unless something is in the way. Unaffected by the global cooldown and castable while casting.
    signature_spell           = {  94657, 470021, 1 }, -- Consuming Winter's Chill with Glacial Spike conjures 2 additional Frost Splinters.
    slippery_slinging         = {  94659, 444752, 1 }, -- You have 40% increased movement speed during Alter Time.
    slow                      = {  62097,  31589, 1 }, -- Reduces the target's movement speed by 60% for 15 sec.
    spellfrost_teachings      = {  94655, 444986, 1 }, -- Direct damage from Frost Splinters has a 2.5% chance to reset the cooldown of Frozen Orb and increase all damage dealt by Frozen Orb by 30% for 10 sec.
    spellsteal                = {  62084,  30449, 1 }, -- Steals a beneficial magic effect from the target. This effect lasts a maximum of 2 min.
    splintering_orbs          = {  94661, 444256, 1 }, -- Enemies damaged by your Frozen Orb conjure 1 Frost Splinter, up to 5. Frozen Orb damage is increased by 10%.
    splintering_sorcery       = {  94664, 443739, 1 }, -- When you consume Winter's Chill or Fingers of Frost, conjure a Frost Splinter that fires at your target. Frost Splinter: Conjure raw Frost magic into a sharp projectile that deals 21,979 Frost damage. Frost Splinters embed themselves into their target, dealing 21,912 Frost damage over 18 sec. This effect stacks.
    splinterstorm             = {  94654, 443742, 1 }, -- Whenever you have 8 or more active Embedded Frost Splinters, you automatically cast a Splinterstorm at your target. Splinterstorm: Shatter all Embedded Frost Splinters, dealing their remaining periodic damage instantly. Conjure a Frost Splinter for each Splinter shattered, then unleash them all in a devastating barrage, dealing 21,979 Frost damage to your target for each Splinter in the Splinterstorm. Splinterstorm has a 5% chance to grant Brain Freeze.
    supernova                 = { 101883, 157980, 1 }, -- Pulses arcane energy around the target enemy or ally, dealing 29,165 Arcane damage to all enemies within 8 yds, and knocking them upward. A primary enemy target will take 100% increased damage.
    tempest_barrier           = {  62111, 382289, 2 }, -- Gain a shield that absorbs 3% of your maximum health for 15 sec after you Blink.
    temporal_velocity         = {  62099, 382826, 2 }, -- Increases your movement speed by 5% for 3 sec after casting Blink and 20% for 6 sec after returning from Alter Time.
    time_anomaly              = {  62094, 383243, 1 }, -- At any moment, you have a chance to gain Combustion for 5 sec, 1 Fire Blast charge, or Time Warp for 6 sec.
    time_manipulation         = {  62129, 387807, 1 }, -- Casting Fire Blast reduces the cooldown of your loss of control abilities by 2 sec.
    tome_of_antonidas         = {  62098, 382490, 1 }, -- Increases Haste by 2%.
    tome_of_rhonin            = {  62127, 382493, 1 }, -- Increases Critical Strike chance by 2%.
    unerring_proficiency      = {  94658, 444974, 1 }, -- Each time you conjure a Frost Splinter, increase the damage of your next Ice Nova by 5%. Stacks up to 60 times.
    volatile_detonation       = {  62089, 389627, 1 }, -- Greatly increases the effect of Blast Wave's knockback. Blast Wave's cooldown is reduced by 5 sec
    volatile_magic            = {  94658, 444968, 1 }, -- Whenever an Embedded Frost Splinter is removed, it explodes, dealing 8,454 Frost damage to nearby enemies. Deals reduced damage beyond 5 targets.
    winters_protection        = {  62123, 382424, 2 }, -- The cooldown of Ice Block is reduced by 30 sec.

    -- Fire
    alexstraszas_fury         = { 101945, 235870, 1 }, -- Dragon's Breath always critically strikes, deals 50% increased critical strike damage, and contributes to Hot Streak.
    ashen_feather             = { 101945, 450813, 1 }, -- If Phoenix Flames only hits 1 target, it deals 50% increased damage and applies Ignite at 150% effectiveness.
    blast_zone                = { 101022, 451755, 1 }, -- Lit Fuse now turns up to 3 targets into Living Bombs. Living Bombs can now spread to 5 enemies.
    call_of_the_sun_king      = { 100991, 343222, 1 }, -- Phoenix Flames deals 15% increased damage and always critically strikes.
    combustion                = { 100995, 190319, 1 }, -- Engulfs you in flames for 12 sec, increasing your spells' critical strike chance by 100% and granting you Mastery equal to 75% of your Critical Strike stat. Castable while casting other spells. When you activate Combustion, you gain 2% Critical Strike damage, and up to 4 nearby allies gain 1% Critical Strike for 10 sec.
    controlled_destruction    = { 101002, 383669, 1 }, -- Damaging a target with Pyroblast or Fireball increases the damage it receives from Ignite by 0.5%. Stacks up to 50 times.
    convection                = { 100992, 416715, 1 }, -- When a Living Bomb expires, if it did not spread to another target, it reapplies itself at 100% effectiveness. A Living Bomb can only benefit from this effect once.
    cratermaker               = { 100993, 451757, 1 }, -- Casting Combustion grants Lit Fuse and Living Bomb's damage is increased by 30% while under the effects of Combustion.
    critical_mass             = { 101029, 117216, 1 }, -- Your spells have a 5% increased chance to deal a critical strike. You gain 10% more of the Critical Strike stat from all sources.
    deep_impact               = { 101000, 416719, 1 }, -- Meteor now turns 1 target hit into a Living Bomb. Additionally, its cooldown is reduced by 10 sec.
    explosive_ingenuity       = { 101013, 451760, 1 }, -- Your chance of gaining Lit Fuse when consuming Hot Streak is increased by 4%. Living Bomb damage increased by 50%.
    feel_the_burn             = { 101014, 383391, 1 }, -- Fire Blast and Phoenix Flames increase your mastery by 2% for 5 sec. This effect stacks up to 3 times.
    fervent_flickering        = { 101027, 387044, 1 }, -- Fire Blast's cooldown is reduced by 2 sec.
    fevered_incantation       = { 101019, 383810, 2 }, -- Each consecutive critical strike you deal increases critical strike damage you deal by 1%, up to 4% for 6 sec.
    fiery_rush                = { 101003, 383634, 1 }, -- While Combustion is active, your Fire Blast and Phoenix Flames recharge 50% faster.
    fire_blast                = { 100989, 108853, 1 }, -- Blasts the enemy for 111,198 Fire damage. Fire: Castable while casting other spells. Always deals a critical strike.
    firefall                  = { 100996, 384033, 1 }, -- Damaging an enemy with 15 Fireballs or Pyroblasts causes your next Fireball or Pyroblast to call down a Meteor on your target.
    fires_ire                 = { 101004, 450831, 2 }, -- When you're not under the effect of Combustion, your critical strike chance is increased by 2.5%. While you're under the effect of Combustion, your critical strike damage is increased by 2.5%.
    firestarter               = { 102014, 205026, 1 }, -- Your Fireball and Pyroblast spells always deal a critical strike when the target is above 90% health.
    flame_accelerant          = { 102012, 453282, 1 }, -- Every 12 seconds, your next non-instant Fireball, Flamestrike, or Pyroblast has a 40% reduced cast time.
    flame_on                  = { 101009, 205029, 1 }, -- Increases the maximum number of Fire Blast charges by 2.
    flame_patch               = { 101021, 205037, 1 }, -- Flamestrike leaves behind a patch of flames that burns enemies within it for 31,650 Fire damage over 8 sec. Deals reduced damage beyond 8 targets.
    from_the_ashes            = { 100999, 342344, 1 }, -- Phoenix Flames damage increased by 15% and your direct-damage spells reduce the cooldown of Phoenix Flames by 1 sec.
    heat_shimmer              = { 102010, 457735, 1 }, -- Scorch damage increased by 10%. Damage from Ignite has a 5% chance to make your next Scorch deal damage as though your target was below 30% health.
    hyperthermia              = { 101942, 383860, 1 }, -- While Combustion is not active, consuming Hot Streak has a low chance to cause all Pyroblasts and Flamestrikes to have no cast time and be guaranteed critical strikes for 5 sec.
    improved_combustion       = { 101007, 383967, 1 }, -- Combustion grants mastery equal to 75% of your Critical Strike stat and lasts 2 sec longer.
    improved_scorch           = { 101011, 383604, 1 }, -- Casting Scorch on targets below 30% health increase the target's damage taken from you by 7% for 12 sec. This effect stacks up to 2 times.
    inflame                   = { 102013, 417467, 1 }, -- Hot Streak increases the amount of Ignite damage from Pyroblast or Flamestrike by an additional 10%.
    intensifying_flame        = { 101017, 416714, 1 }, -- While Ignite is on 3 or fewer enemies it flares up dealing an additional 20% of its damage to affected targets.
    kindling                  = { 101024, 155148, 1 }, -- Your Fireball, Pyroblast, Fire Blast, Scorch and Phoenix Flames critical strikes reduce the remaining cooldown on Combustion by 1.0 sec. Flamestrike critical strikes reduce the remaining cooldown of Combustion by 0.2 sec for each critical strike, up to 1 sec.
    lit_fuse                  = { 100994, 450716, 1 }, -- Consuming Hot Streak has a 6% chance to grant you Lit Fuse.  Lit Fuse: Your next Fire Blast turns up to 1 nearby target into a Living Bomb that explodes after 1.6 sec, dealing 22,656 Fire damage to the target and reduced damage to all other enemies within 10 yds. Up to 3 enemies hit by this explosion also become a Living Bomb, but this effect cannot spread further.
    majesty_of_the_phoenix    = { 101008, 451440, 1 }, -- Casting Phoenix Flames causes your next Flamestrike to have its critical strike chance increased by 20% and critical strike damage increased by 20%. Stacks up to 3 times.
    mark_of_the_firelord      = { 100988, 450325, 1 }, -- Flamestrike and Living Bomb apply Mastery: Ignite at 100% increased effectiveness.
    master_of_flame           = { 101006, 384174, 1 }, -- Ignite deals 15% more damage and Fireball deals 15% more damage while Combustion is not active. Fire Blast spreads Ignite to 2 additional nearby targets during Combustion.
    meteor                    = { 101016, 153561, 1 }, -- Calls down a meteor which lands at the target location after 3 sec, dealing 312,788 Fire damage to all enemies hit reduced beyond 8 targets, and burns the ground, dealing 57,747 Fire damage over 8.5 sec to all enemies in the area.
    molten_fury               = { 101015, 457803, 1 }, -- Damage dealt to targets below 35% health is increased by 7%.
    phoenix_flames            = { 101012, 257541, 1 }, -- Hurls a Phoenix that deals 86,086 Fire damage to the target and reduced damage to other nearby enemies. Always deals a critical strike.
    phoenix_reborn            = { 101943, 453123, 1 }, -- When your direct damage spells hit an enemy 25 times, gain 1 stack of Born of Flame.  Born of Flame Phoenix Flames refunds a charge on use and its damage is increased by 200%.
    pyroblast                 = { 100998,  11366, 1 }, -- Hurls an immense fiery boulder that causes 209,244 Fire damage.
    pyromaniac                = { 101020, 451466, 1 }, -- Casting Pyroblast or Flamestrike while Hot Streak is active has an 6% chance to repeat the spell cast at 50% effectiveness. This effect counts as consuming Hot Streak.
    pyrotechnics              = { 100997, 157642, 1 }, -- Each time your Fireball fails to critically strike a target, it gains a stacking 20% increased critical strike chance. Effect ends when Fireball critically strikes.
    quickflame                = { 101021, 450807, 1 }, -- Flamestrike damage increased by 25%.
    scald                     = { 101011, 450746, 1 }, -- Scorch deals 300% increased damage to targets below 30% health.
    scorch                    = { 100987,   2948, 1 }, -- Scorches an enemy for 27,897 Fire damage. When cast on a target below 30% health, Scorch is a guaranteed critical strike and increases your movement speed by 30% for 3 sec. Castable while moving.
    sparking_cinders          = { 102011, 457728, 1 }, -- Living Bomb explosions have a small chance to increase the damage of your next Pyroblast by 15% or Flamestrike by 15%.
    spontaneous_combustion    = { 101007, 451875, 1 }, -- Casting Combustion refreshes up to 3 charges of Fire Blast and up to 3 charges of Phoenix Flames.
    sun_kings_blessing        = { 101025, 383886, 1 }, -- After consuming 10 Hot Streaks, your next non-instant Pyroblast or Flamestrike cast within 30 sec grants you Combustion for 6 sec and deals 280% additional damage.
    surging_blaze             = { 101023, 343230, 1 }, -- Pyroblast and Flamestrike's cast time is reduced by 0.5 sec and their damage dealt is increased by 5%.
    unleashed_inferno         = { 101025, 416506, 1 }, -- While Combustion is active your Fireball, Pyroblast, Fire Blast, Scorch, and Phoenix Flames deal 60% increased damage and reduce the cooldown of Combustion by 1.25 sec. While Combustion is active, Flamestrike deals 35% increased damage and reduces the cooldown of Combustion by 0.25 sec for each critical strike, up to 1.25 sec.
    wildfire                  = { 101001, 383489, 1 }, -- Your critical strike damage is increased by 3%. When you activate Combustion, you gain 2% additional critical strike damage, and up to 4 nearby allies gain 1% critical strike for 10 sec.

    -- Sunfury
    burden_of_power           = {  94644, 451035, 1 }, -- Conjuring a Spellfire Sphere increases the damage of your next Pyroblast by 20% or your next Flamestrike by 30%.
    codex_of_the_sunstriders  = {  94643, 449382, 1 }, -- Over its duration, your Arcane Phoenix will consume each of your Spellfire Spheres to cast an exceptional spell. Upon consuming a Spellfire Sphere, your Arcane Phoenix will grant you Lingering Embers.  Lingering Embers Increases your spell damage by 1%.
    glorious_incandescence    = {  94645, 449394, 1 }, -- Consuming Burden of Power causes your next cast of Fire Blast to strike up to 2 additional targets and call down a storm of 4 Meteorites on its target. Each Meteorite's impact reduces the cooldown of Fire Blast by 2.0 sec.
    gravity_lapse             = {  94651, 458513, 1 }, -- Your Supernova becomes Gravity Lapse. Gravity Lapse The snap of your fingers warps the gravity around your target and 4 other nearby enemies, suspending them in the air for 3 sec. Upon landing, nearby enemies take 41,037 Arcane damage.
    ignite_the_future         = {  94648, 449558, 1 }, -- Generating a Spellfire Sphere while your Phoenix is active causes it to cast an exceptional spell. Mana Cascade can now stack up to 15 times.
    invocation_arcane_phoenix = {  94652, 448658, 1 }, -- When you cast Combustion, summon an Arcane Phoenix to aid you in battle.  Arcane Phoenix Your Arcane Phoenix aids you for the duration of your Combustion, casting random Arcane and Fire spells.
    lessons_in_debilitation   = {  94651, 449627, 1 }, -- Your Arcane Phoenix will Spellsteal when it is summoned and when it expires.
    mana_cascade              = {  94653, 449293, 1 }, -- Consuming Hot Streak grants you 0.5% Haste for 10 sec. Stacks up to 10 times. Multiple instances may overlap.
    memory_of_alar            = {  94646, 449619, 1 }, -- While under the effects of a casted Combustion, you gain twice as many stacks of Mana Cascade. When your Arcane Phoenix expires, it empowers you, granting Hyperthermia for 2 sec, plus an additional 1.0 sec for each exceptional spell it had cast.  Hyperthermia: Pyroblast and Flamestrike have no cast time and are guaranteed to critically strike.
    merely_a_setback          = {  94649, 449330, 1 }, -- Your Blazing Barrier now grants 5% avoidance while active and 3% leech for 5 sec when it breaks or expires.
    rondurmancy               = {  94648, 449596, 1 }, -- Spellfire Spheres can now stack up to 5 times.
    savor_the_moment          = {  94650, 449412, 1 }, -- When you cast Combustion, its duration is extended by 0.5 sec for each Spellfire Sphere you have, up to 2.5 sec.
    spellfire_spheres         = {  94647, 448601, 1, "sunfury" }, -- Every 6 times you consume Hot Streak, conjure a Spellfire Sphere. While you're out of combat, you will slowly conjure Spellfire Spheres over time.  Spellfire Sphere Increases your spell damage by 1%. Stacks up to 3 times.
    sunfury_execution         = {  94650, 449349, 1 }, -- Scorch's critical strike threshold is increased to 35%.  Scorch Scorches an enemy for 27,897 Fire damage. When cast on a target below 30% health, Scorch is a guaranteed critical strike and increases your movement speed by 30% for 3 sec. Castable while moving.

    -- Frostfire
    elemental_affinity        = {  94633, 431067, 1 }, -- The cooldown of Frost spells with a base cooldown shorter than 4 minutes is reduced by 30%.
    excess_fire               = {  94637, 438595, 1 }, -- Casting Meteor causes your next Fire Blast to explode in a Frostfire Burst, dealing 224,531 Frostfire damage to nearby enemies. Damage reduced beyond 8 targets. Frostfire Burst, reduces the cooldown of Phoenix Flames by 10 sec.
    excess_frost              = {  94639, 438600, 1 }, -- Consuming Excess Fire causes your next Phoenix Flames to also cast Ice Nova at 200% effectiveness. Ice Novas cast this way do not freeze enemies in place. When you consume Excess Frost, the cooldown of Meteor is reduced by 5 sec.
    flame_and_frost           = {  94633, 431112, 1 }, -- Cauterize resets the cooldown of your Frost spells with a base cooldown shorter than 4 minutes when it activates.
    flash_freezeburn          = {  94635, 431178, 1 }, -- Frostfire Empowerment grants you maximum benefit of Frostfire Mastery, refreshes its duration, and grants you Excess Frost and Excess Fire. Activating Combustion or Icy Veins grants you Frostfire Empowerment.
    frostfire_bolt            = {  94641, 431044, 1 }, -- Launches a bolt of frostfire at the enemy, causing 176,785 Frostfire damage, slowing movement speed by 60%, and causing an additional 47,365 Frostfire damage over 8 sec. Frostfire Bolt generates stacks for both Fire Mastery and Frost Mastery.
    frostfire_empowerment     = {  94632, 431176, 1 }, -- Your Frost and Fire spells have a chance to activate Frostfire Empowerment, causing your next Frostfire Bolt to be instant cast, deal 60% increased damage, explode for 80% of its damage to nearby enemies.
    frostfire_infusion        = {  94634, 431166, 1 }, -- Your Frost and Fire spells have a chance to trigger an additional bolt of Frostfire, dealing 57,062 damage. This effect generates Frostfire Mastery when activated.
    frostfire_mastery         = {  94636, 431038, 1, "frostfire" }, -- Your damaging Fire spells generate 1 stack of Fire Mastery and Frost spells generate 1 stack of Frost Mastery. Fire Mastery increases your haste by 1%, and Frost Mastery increases your Mastery by 2% for 14 sec, stacking up to 6 times each. Adding stacks does not refresh duration.
    imbued_warding            = {  94642, 431066, 1 }, -- Blazing Barrier also casts an Ice Barrier at 25% effectiveness.
    isothermic_core           = {  94638, 431095, 1 }, -- Comet Storm now also calls down a Meteor at 150% effectiveness onto your target's location. Meteor now also calls down a Comet Storm at 200% effectiveness onto your target location.
    meltdown                  = {  94642, 431131, 1 }, -- You melt slightly out of your Ice Block and Ice Cold, allowing you to move slowly during Ice Block and increasing your movement speed over time. Ice Block and Ice Cold trigger a Blazing Barrier when they end.
    severe_temperatures       = {  94640, 431189, 1 }, -- Casting damaging Frost or Fire spells has a high chance to increase the damage of your next Frostfire Bolt by 10%, stacking up to 5 times.
    thermal_conditioning      = {  94640, 431117, 1 }, -- Frostfire Bolt's cast time is reduced by 10%.
} )

-- PvP Talents
spec:RegisterPvpTalents( {
    ethereal_blink             = 5602, -- (410939) Blink and Shimmer apply Slow at 100% effectiveness to all enemies you Blink through. For each enemy you Blink through, the cooldown of Blink and Shimmer are reduced by 1 sec, up to 5 sec.
    fireheart                  = 5656, -- (460942) Blazing Barrier's damage is increased by 800%.
    glass_cannon               = 5495, -- (390428) Increases damage of Fireball, Scorch, and Ignite by 20% but decreases your maximum health by 30%.
    greater_pyroblast          =  648, -- (203286) Hurls an immense fiery boulder that deals up to 30% of the target's total health in Fire damage.
    ice_wall                   = 5489, -- (352278) Conjures an Ice Wall 30 yards long that obstructs line of sight. The wall has 40% of your maximum health and lasts up to 15 sec.
    ignition_burst             = 5685, -- (1217359) Heat Shimmer now additionally causes your next Scorch to become instant cast and cast at 100% effectiveness.
    improved_mass_invisibility = 5621, -- (415945) The cooldown of Mass Invisibility is reduced by 4 min and can affect allies in combat.
    master_shepherd            = 5588, -- (410248) While an enemy player is affected by your Polymorph or Mass Polymorph, your movement speed is increased by 25% and your Versatility is increased by 12%. Additionally, Polymorph and Mass Polymorph no longer heal enemies.
    overpowered_barrier        = 5706, -- (1220739) Your barriers absorb 100% more damage and have an additional effect, but last 5 sec.  Blazing Barrier Reflects 100% of damage absorbed.
    ring_of_fire               = 5389, -- (353082) Summons a Ring of Fire for 8 sec at the target location. Enemies entering the ring are disoriented and burn for 3% of their total health over 3 sec.
    world_in_flames            =  644, -- (203280) Empower Flamestrike, dealing up to 50% more damage based on enemies' distance to the center of Flamestrike.
} )

-- Auras
spec:RegisterAuras( {
    -- Talent: Altering Time. Returning to past location and health when duration expires.
    -- https://wowhead.com/beta/spell=342246
    alter_time = {
        id = 110909,
        duration = 10,
        type = "Magic",
        max_stack = 1,
        copy = 342246
    },
    arcane_intellect = {
        id = 1459,
        duration = 3600,
        type = "Magic",
        max_stack = 1,
        shared = "player", -- use anyone's buff on the player, not just player's.
    },
    -- Talent: Movement speed reduced by $s2%.
    -- https://wowhead.com/beta/spell=157981
    blast_wave = {
        id = 157981,
        duration = 6,
        type = "Magic",
        max_stack = 1
    },
    -- Talent: Absorbs $w1 damage.  Melee attackers take $235314s1 Fire damage.
    -- https://wowhead.com/beta/spell=235313
    blazing_barrier = {
        id = 235313,
        duration = 60,
        type = "Magic",
        max_stack = 1
    },
    -- $s1% increased movement speed and unaffected by movement speed slowing effects.
    -- https://wowhead.com/beta/spell=108843
    blazing_speed = {
        id = 108843,
        duration = 6,
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
    -- Movement speed reduced by $w1%.
    -- https://wowhead.com/beta/spell=12486
    blizzard = {
        id = 12486,
        duration = 3,
        mechanic = "snare",
        type = "Magic",
        max_stack = 1
    },
    born_of_flame = {
        id = 1219307,
        duration = 30,
        max_stack = 2
    },
    calefaction = {
        id = 408673,
        duration = 60,
        max_stack = 25
    },
    -- Talent: Burning away $s1% of maximum health every $t1 sec.
    -- https://wowhead.com/beta/spell=87023
    cauterize = {
        id = 87023,
        duration = 6,
        max_stack = 1
    },
    -- You have recently benefited from Cauterize and cannot benefit from it again.
    -- https://wowhead.com/beta/spell=87024
    cauterized = {
        id = 87024,
        duration = 300,
        max_stack = 1
    },
    -- Movement speed reduced by $w1%.
    -- https://wowhead.com/beta/spell=205708
    chilled = {
        id = 205708,
        duration = 8,
        max_stack = 1
    },
    -- Talent: Critical Strike chance of your spells increased by $w1%.$?a383967[  Mastery increased by $w2.][]
    -- https://wowhead.com/beta/spell=190319
    combustion = {
        id = 190319,
        duration = function()
            return talent.improved_combustion.enabled and 12 or 10 + ( talent.savor_the_moment.enabled and buff.spellfire_spheres.stacks * 0.5 or 0 )
        end,
        type = "Magic",
        max_stack = 1
    },
    -- Movement speed reduced by $s1%.
    -- https://wowhead.com/beta/spell=212792
    cone_of_cold = {
        id = 212792,
        duration = 5,
        max_stack = 1
    },
    controlled_destruction = {
        id = 453268,
        duration = 180,
        max_stack = 50
    },
    -- Able to teleport back to where last Blinked from.
    -- https://wowhead.com/beta/spell=389714
    displacement_beacon = {
        id = 389714,
        duration = 8,
        type = "Magic",
        max_stack = 1
    },
    -- Talent: Disoriented.
    -- https://wowhead.com/beta/spell=31661
    dragons_breath = {
        id = 31661,
        duration = 4,
        type = "Magic",
        max_stack = 1
    },
    -- Time Warp also increases the rate at which time passes by $s1%.
    -- https://wowhead.com/beta/spell=320919
    echoes_of_elisande = {
        id = 320919,
        duration = 3600,
        max_stack = 3
    },
    excess_fire = {
        id = 438624,
        duration = 30,
        max_stack = 2
    },
    excess_frost = {
        id = 438611,
        duration = 30,
        max_stack = 2
    },
    -- Talent: Mastery increased by ${$w1*$mas}%.
    -- https://wowhead.com/beta/spell=383395
    feel_the_burn = {
        id = 383395,
        duration = 5,
        max_stack = 3,
        copy = { "infernal_cascade", 336832 }
    },
    -- Talent: Your spells deal an additional $w1% critical hit damage.
    -- https://wowhead.com/beta/spell=383811
    fevered_incantation = {
        id = 383811,
        duration = 6,
        type = "Magic",
        max_stack = 4,
        copy = 333049
    },
    -- Talent: Your Fire Blast and Phoenix Flames recharge $s1% faster.
    -- https://wowhead.com/beta/spell=383637
    fiery_rush = {
        id = 383637,
        duration = 3600,
        type = "Magic",
        max_stack = 1
    },
    fire_mastery = {
        id = 431040,
        duration = 14,
        max_stack = 6
    },
    firefall = {
        id = 384035,
        duration = 30,
        max_stack = 15
    },
    firefall_ready = {
        id = 384038,
        duration = 30,
        max_stack = 1
    },
    fires_ire = {
        id = 453385,
        duration = 3600,
        max_stack = 1
    },
    -- Your next Fireball, Flamestrike, or Pyroblast has a 40% reduced cast time.
    flame_accelerant = {
        id = 453283,
        duration = 3600,
        max_stack = 1
    },
    -- Talent: Burning
    -- https://wowhead.com/beta/spell=205470
    flame_patch = {
        id = 205470,
        duration = 8,
        type = "Magic",
        max_stack = 1
    },
    flames_fury = {
        id = 409964,
        duration = 30,
        max_stack = 2
    },
    -- Talent: Movement speed slowed by $s2%.
    -- https://wowhead.com/beta/spell=2120
    flamestrike = {
        id = 2120,
        duration = 8,
        type = "Magic",
        max_stack = 1
    },
    -- Talent: Frozen in place.
    -- https://wowhead.com/beta/spell=386770
    freezing_cold = {
        id = 386770,
        duration = 5,
        type = "Magic",
        max_stack = 1
    },
    -- Talent: Movement speed reduced by $w1%
    -- https://wowhead.com/beta/spell=394255
    freezing_cold_snare = {
        id = 394255,
        duration = 3,
        mechanic = "snare",
        type = "Magic",
        max_stack = 1
    },
    -- Movement speed increased by $s1%.
    -- https://wowhead.com/beta/spell=236060
    frenetic_speed = {
        id = 236060,
        duration = 3,
        max_stack = 1
    },
    frost_mastery = {
        id = 431039,
        duration = 14,
        max_stack = 6
    },
    -- Frozen in place.
    -- https://wowhead.com/beta/spell=122
    frost_nova = {
        id = 122,
        duration = function() return talent.improved_frost_nova.enabled and 8 or 6 end,
        type = "Magic",
        max_stack = 1
    },
    frostfire_bolt = {
        id = 468655,
        duration = 8,
        max_stack = 1
    },
    frostfire_empowerment = {
        id = 431177,
        duration = 20,
        max_stack = 1
    },
    -- Movement speed reduced by $w1%.
    -- https://wowhead.com/beta/spell=289308
    frozen_orb = {
        id = 289308,
        duration = 3,
        mechanic = "snare",
        max_stack = 1
    },
    -- Frozen in place.
    -- https://wowhead.com/beta/spell=228600
    glacial_spike = {
        id = 228600,
        duration = 4,
        type = "Magic",
        max_stack = 1
    },
    heat_shimmer = {
        id = 458964,
        duration = 10,
        max_stack = 1
    },
    heating_up = {
        id = 48107,
        duration = 10,
        max_stack = 1,
    },
    hot_streak = {
        id = 48108,
        duration = 15,
        type = "Magic",
        max_stack = 1,
    },
    -- Talent: Pyroblast and Flamestrike have no cast time and are guaranteed to critically strike.
    -- https://wowhead.com/beta/spell=383874
    hyperthermia = {
        id = 383874,
        duration = 5,
        max_stack = 1
    },
    -- Cannot be made invulnerable by Ice Block.
    -- https://wowhead.com/beta/spell=41425
    hypothermia = {
        id = 41425,
        duration = 30,
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
    -- Deals $w1 Fire damage every $t1 sec.$?$w3>0[  Movement speed reduced by $w3%.][]
    -- https://wowhead.com/beta/spell=12654
    ignite = {
        id = 12654,
        duration = 9,
        tick_time = 1,
        type = "Magic",
        max_stack = 1
    },
    -- Talent: Taking $383604s3% increased damage from $@auracaster's spells and abilities.
    -- https://wowhead.com/beta/spell=383608
    improved_scorch = {
        id = 383608,
        duration = 12,
        type = "Magic",
        max_stack = 2
    },
    incantation_of_swiftness = {
        id = 382294,
        duration = 6,
        max_stack = 1,
        copy = 337278,
    },
    -- Talent: Increases spell damage by $w1%.
    -- https://wowhead.com/beta/spell=116267
    incanters_flow = {
        id = 116267,
        duration = 25,
        max_stack = 5,
        meta = {
            stack = function() return state.incanters_flow_stacks end,
            stacks = function() return state.incanters_flow_stacks end,
        }
    },
    -- Spell damage increased by $w1%.
    -- https://wowhead.com/beta/spell=384280
    invigorating_powder = {
        id = 384280,
        duration = 12,
        type = "Magic",
        max_stack = 1
    },
    lit_fuse = {
        id = 453207,
        duration = 10,
        max_stack = 1
    },
    -- Talent: Causes $w1 Fire damage every $t1 sec. After $d, the target explodes, causing $w2 Fire damage to the target and all other enemies within $44461A2 yards, and spreading Living Bomb.
    -- https://wowhead.com/beta/spell=217694
    living_bomb = {
        id = 217694,
        duration = 4,
        tick_time = 1,
        type = "Magic",
        max_stack = 1
    },
    -- Talent: Causes $w1 Fire damage every $t1 sec. After $d, the target explodes, causing $w2 Fire damage to the target and all other enemies within $44461A2 yards.
    -- https://wowhead.com/beta/spell=244813
    living_bomb_spread = { -- TODO: Check for differentiation in SimC.
        id = 244813,
        duration = 4,
        tick_time = 1,
        type = "Magic",
        max_stack = 1
    },
    majesty_of_the_phoenix = {
        id = 453329,
        duration = 20,
        max_stack = 3
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
    -- Burning for $w1 Fire damage every $t1 sec.
    -- https://wowhead.com/beta/spell=155158
    meteor_burn = {
        id = 155158,
        duration = 10,
        tick_time = 1,
        type = "Magic",
        max_stack = 3
    },
    --[[ Burning for $w1 Fire damage every $t1 sec.
    -- https://wowhead.com/beta/spell=175396
    meteor_burn = { -- AOE ground effect?
        id = 175396,
        duration = 8.5,
        type = "Magic",
        max_stack = 1
    }, ]]
    -- Talent: Damage taken is reduced by $s3% while your images are active.
    -- https://wowhead.com/beta/spell=55342
    mirror_image = {
        id = 55342,
        duration = 40,
        max_stack = 3,
        generate = function( mi )
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
    -- Covenant: Attacking, casting a spell or ability, consumes a mirror to inflict Shadow damage and reduce cast and movement speed by $320035s3%.     Your final mirror will instead Root and Silence you for $317589d.
    -- https://wowhead.com/beta/spell=314793
    mirrors_of_torment = {
        id = 314793,
        duration = 25,
        type = "Magic",
        max_stack = 3
    },
    phoenix_reborn = {
        id = 1219304,
        duration = 60,
        max_stack = 24
    },
    -- Absorbs $w1 damage.  Magic damage taken reduced by $s3%.  Duration of all harmful Magic effects reduced by $w4%.
    -- https://wowhead.com/beta/spell=235450
    prismatic_barrier = {
        id = 235450,
        duration = 60,
        type = "Magic",
        max_stack = 1
    },
    -- Talent: Suffering $w1 Fire damage every $t2 sec.
    -- https://wowhead.com/beta/spell=321712
    pyroblast = {
        id = 321712,
        duration = 6,
        tick_time = 2,
        type = "Magic",
        max_stack = 1
    },
    -- Talent: Increases critical strike chance of Fireball by $s1%$?a337224[ and your Mastery by ${$s2}.1%][].
    -- https://wowhead.com/beta/spell=157644
    pyrotechnics = {
        id = 157644,
        duration = 15,
        max_stack = 10,
        copy = "fireball"
    },
    -- Talent: Incapacitated.
    -- https://wowhead.com/beta/spell=82691
    ring_of_frost = {
        id = 82691,
        duration = 10,
        mechanic = "freeze",
        type = "Magic",
        max_stack = 1
    },
    -- Talent: Movement speed slowed by $s1%.
    -- https://wowhead.com/beta/spell=321329
    ring_of_frost_snare = {
        id = 321329,
        duration = 4,
        type = "Magic",
        max_stack = 1
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
    -- Talent: Movement speed reduced by $w1%.
    -- https://wowhead.com/beta/spell=31589
    slow = {
        id = 31589,
        duration = 15,
        mechanic = "snare",
        type = "Magic",
        max_stack = 1
    },
    sparking_cinders = {
        id = 457729,
        duration = 20,
        max_stack = 1
    },
    sun_kings_blessing = {
        id = 383882,
        duration = 30,
        max_stack = 9,
        copy = 333314
    },
    -- Talent: Your next non-instant Pyroblast will grant you Combustion.
    -- https://wowhead.com/beta/spell=383883
    sun_kings_blessing_ready = {
        id = 383883,
        duration = 15,
        max_stack = 1,
        copy = { 333315, "fury_of_the_sun_king" },
        meta = {
            expiration_delay_remains = function()
                return buff.sun_kings_blessing_ready_expiration_delay.remains
            end,
        },
    },
    sun_kings_blessing_ready_expiration_delay = {
        duration = 0.03,
    },
    -- Talent: Absorbs $w1 damage.
    -- https://wowhead.com/beta/spell=382290
    tempest_barrier = {
        id = 382290,
        duration = 15,
        type = "Magic",
        max_stack = 1
    },
    -- Talent: Movement speed increased by $w1%.
    -- https://wowhead.com/beta/spell=382824
    temporal_velocity_alter_time = {
        id = 382824,
        duration = 5,
        max_stack = 1
    },
    -- Talent: Movement speed increased by $w1%.
    -- https://wowhead.com/beta/spell=384360
    temporal_velocity_blink = {
        id = 384360,
        duration = 2,
        max_stack = 1
    },
    -- Talent: Haste increased by $w1%.
    -- https://wowhead.com/beta/spell=386540
    temporal_warp = {
        id = 386540,
        duration = 40,
        max_stack = 1
    },
    -- Frozen in time for $d.
    -- https://wowhead.com/beta/spell=356346
    timebreakers_paradox = {
        id = 356346,
        duration = 8,
        mechanic = "stun",
        max_stack = 1
    },
    -- Rooted and Silenced.
    -- https://wowhead.com/beta/spell=317589
    tormenting_backlash = {
        id = 317589,
        duration = 4,
        type = "Magic",
        max_stack = 1
    },
    -- Suffering $w1 Fire damage every $t1 sec.
    -- https://wowhead.com/beta/spell=277703
    trailing_embers = {
        id = 277703,
        duration = 6,
        tick_time = 2,
        type = "Magic",
        max_stack = 1
    },
    -- Talent: Critical Strike increased by $w1%.
    -- https://wowhead.com/beta/spell=383492
    wildfire = {
        id = 383492,
        duration = 10,
        max_stack = 1
    },
    -- Sunfury
	-- Spellfire Spheres actual buff
	-- Spellfire Spheres has two diffrent counter. 449400 for create a Sphere, 448604 is Sphere number
	-- https://www.wowhead.com/spell=449400/spellfire-spheres
    burden_of_power = {
        id = 451049,
        duration = 12,
        max_stack = 1
    },
    glorious_incandescence = {
        id = 451073,
        duration = 12,
        max_stack = 1
    },
    lingering_embers = {
        id = 461145,
        duration = 10,
        max_stack = 15
    },
    next_blast_spheres = {
        id = 449400,
        duration = 30,
        max_stack = 5,
    },
    spellfire_spheres = {
        id = 448604,
        duration = 3600,
        max_stack = function() return 3 + ( talent.rondurmancy.enabled and 2 or 0 ) end,
    },

    -- Legendaries
    expanded_potential = {
        id = 327495,
        duration = 300,
        max_stack = 1
    },
    firestorm = {
        id = 333100,
        duration = 4,
        max_stack = 1
    },
    molten_skyfall = {
        id = 333170,
        duration = 30,
        max_stack = 18
    },
    molten_skyfall_ready = {
        id = 333182,
        duration = 30,
        max_stack = 1
    },
} )


spec:RegisterCombatLogEvent( function( _, subtype, _,  sourceGUID, sourceName, _, _, destGUID, destName, destFlags, _, spellID, spellName )
    if sourceGUID == state.GUID and subtype == "SPELL_AURA_APPLIED" and ( spellID == spec.auras.heating_up.id or spellID == spec.auras.hot_streak.id ) then
        Hekili:ForceUpdate( spellName, true )
    end
end )


spec:RegisterStateTable( "firestarter", setmetatable( {}, {
    __index = setfenv( function( t, k )
        if k == "active" then return talent.firestarter.enabled and target.health.pct > 90
        elseif k == "remains" then
            if not talent.firestarter.enabled or target.health.pct <= 90 then return 0 end
            return target.time_to_pct_90
        end
    end, state )
} ) )

spec:RegisterStateTable( "scorch_execute", setmetatable( {}, {
    __index = setfenv( function( t, k )
        if k == "active" then
            return buff.heat_shimmer.up or target.health.pct < 30
        elseif k == "remains" then
            if target.health.pct < 30 then return target.time_to_die end
            if buff.heat_shimmer.up then return buff.heat_shimmer.remains end
            return 0
        end
    end, state )
} ) )

spec:RegisterStateTable( "improved_scorch", setmetatable( {}, {
    __index = setfenv( function( t, k )
        if k == "active" then return debuff.improved_scorch.up
        elseif k == "remains" then
            return debuff.improved_scorch.remains
        end
    end, state )
} ) )


-- The War Within
spec:RegisterGear( "tww2", 229346, 229344, 229342, 229343, 229341 )
spec:RegisterAuras( {
   -- 2-set
rollin_hot = {
    id = 1219035,
    duration = 15,
    max_stack = 1
},
   --[[ 4-set
    jackpot = {
        -- When you hit Jackpot you gain 7% more dps for 12s. If you gain jackpot from combustion the duration is increased by 100%
    }, ]]--

} )

-- Dragonflight
spec:RegisterGear( "tier31", 207288, 207289, 207290, 207291, 207293 )
spec:RegisterAura( "searing_rage", {
    id = 424285,
    duration = 12,
    max_stack = 5
} )

spec:RegisterGear( "tier30", 202554, 202552, 202551, 202550, 202549, 217232, 217234, 217235, 217231, 217233 )
spec:RegisterAuras( {
    charring_embers = {
        id = 408665,
        duration = 14,
        max_stack = 1,
        copy = 453122
    },
    calefaction = {
        id = 408673,
        duration = 60,
        max_stack = 20
    },
    flames_fury = {
        id = 409964,
        duration = 30,
        max_stack = 2
    }
} )


spec:RegisterGear( "tier29", 200318, 200320, 200315, 200317, 200319 )

local TriggerHyperthermia = setfenv( function()

    if buff.hyperthermia.up then
        buff.hyperthermia.expires = buff.hyperthermia.expires + ( 2 + ( buff.lingering_embers.stacks ) )
    else
        applyBuff( "hyperthermia", 2 + ( buff.lingering_embers.stacks ) )
    end
end, state )

spec:RegisterHook( "reset_precast", function ()


    if buff.combustion.up and talent.memory_of_alar.enabled then
        state:QueueAuraEvent( "combustion", TriggerHyperthermia, buff.combustion.expires, "AURA_EXPIRATION" )
    end

    incanters_flow.reset()
end )

spec:RegisterHook( "runHandler", function( action )
    local ability = class.abilities[ action ]

    if buff.ice_floes.up then
        if ability and ability.cast > 0 and ability.cast < 10 then removeStack( "ice_floes" ) end
    end

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

spec:RegisterHook( "advance", function ( time )
    if Hekili.ActiveDebug then Hekili:Debug( "\n*** Hot Streak (Advance) ***\n    Heating Up:  %.2f\n    Hot Streak:  %.2f\n", state.buff.heating_up.remains, state.buff.hot_streak.remains ) end
end )


local ConsumeHotStreak = setfenv( function()

    removeBuff( "hot_streak" )
    -- Sunfury
    if talent.spellfire_spheres.enabled then
        if buff.next_blast_spheres.stacks == 5 then
            removeBuff( "next_blast_spheres" )
            addStack( "spellfire_spheres" )
            applyBuff( "burden_of_power" )
        else addStack( "next_blast_spheres" )
        end
    end
    -- SKB
    if talent.sun_kings_blessing.enabled then
        if buff.sun_kings_blessing.stack == buff.sun_kings_blessing.max_stack then
            removeBuff( "sun_kings_blessing" )
            applyBuff( "sun_kings_blessing_ready" )
        else
            addStack( "sun_kings_blessing" )
        end
    end

end, state )

spec:RegisterStateFunction( "hot_streak", function( willCrit, deferBy )
    willCrit = willCrit or buff.combustion.up or stat.crit >= 100

    if Hekili.ActiveDebug then Hekili:Debug( "*** HOT STREAK (Cast/Impact) ***\n    Heating Up: %s, %.2f\n    Hot Streak: %s, %.2f\n    Crit: %s, %.2f", buff.heating_up.up and "Yes" or "No", buff.heating_up.remains, buff.hot_streak.up and "Yes" or "No", buff.hot_streak.remains, willCrit and "Yes" or "No", stat.crit ) end

    if willCrit then
        if buff.heating_up.up then removeBuff( "heating_up" ); applyBuff( "hot_streak" ); buff.hot_streak.applied = buff.hot_streak.applied + ( deferBy or 0 )
        elseif buff.hot_streak.down then applyBuff( "heating_up" ); buff.heating_up.applied = buff.heating_up.applied + ( deferBy or 0 ) end

        if talent.fevered_incantation.enabled then addStack( "fevered_incantation" ) end

        if Hekili.ActiveDebug then Hekili:Debug( "*** HOT STREAK END ***\nHeating Up: %s, %.2f\nHot Streak: %s, %.2f", buff.heating_up.up and "Yes" or ( buff.heating_up.applied > query_time and "Trigger in 0.1" ) or "No", buff.heating_up.remains, buff.hot_streak.up and "Yes" or ( buff.hot_streak.applied > query_time and "Trigger in 0.1" ) or "No", buff.hot_streak.remains ) end
        return true
    end

    -- Apparently it's safe to not crit within 0.2 seconds.
    if buff.heating_up.up then
        if query_time - buff.heating_up.applied > 0.2 then
            if Hekili.ActiveDebug then Hekili:Debug( "May not crit; Heating Up was applied %.2f ago, so removing Heating Up..", query_time - buff.heating_up.applied ) end
            removeBuff( "heating_up" )
        else
            if Hekili.ActiveDebug then Hekili:Debug( "May not crit; Heating Up was applied %.2f ago, so ignoring the non-crit impact.", query_time - buff.heating_up.applied ) end
        end
    end

    if Hekili.ActiveDebug then Hekili:Debug( "*** HOT STREAK END ***\nHeating Up: %s, %.2f\nHot Streak: %s, %.2f\n***", buff.heating_up.up and "Yes" or "No", buff.heating_up.remains, buff.hot_streak.up and "Yes" or "No", buff.hot_streak.remains ) end
end )


local hot_streak_spells = {
    -- "dragons_breath",
    "fireball",
    -- "fire_blast",
    "phoenix_flames",
    "pyroblast",
    "scorch",
}
spec:RegisterStateExpr( "hot_streak_spells_in_flight", function ()
    local count = 0

    for i, spell in ipairs( hot_streak_spells ) do
        if state:IsInFlight( spell ) then count = count + 1 end
    end

    return count
end )

spec:RegisterStateExpr( "expected_kindling_reduction", function ()
    -- This only really works well in combat; we'll use the old APL value instead of dynamically updating for now.
    return 0.4
end )


Hekili:EmbedDisciplinaryCommand( spec )


local ExpireSKB = setfenv( function()
    removeBuff( "sun_kings_blessing_ready" )
end, state )


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
                Hekili:ProfileFrame( "Incanters_Flow_Arcane", incanters_flow.f )
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

                                flow.changed = GetTime()
                                flow.count = count
                            end
                        else
                            flow.count = 0
                            flow.changed = GetTime()
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

spec:RegisterStateExpr( "incanters_flow_stacks", function ()
    if not talent.incanters_flow.enabled then return 0 end

    local index = incanters_flow.startIndex + floor( query_time - incanters_flow.startTime )
    if index > 10 then index = index % 10 end

    return incanters_flow.values[ index ][ 1 ]
end )

spec:RegisterStateExpr( "incanters_flow_dir", function()
    if not talent.incanters_flow.enabled then return 0 end

    local index = incanters_flow.startIndex + floor( query_time - incanters_flow.startTime )
    if index > 10 then index = index % 10 end

    return incanters_flow.values[ index ][ 2 ]
end )

-- Seemingly, a very silly way to track Incanter's Flow...
local incanters_flow_time_obj = setmetatable( { __stack = 0 }, {
    __index = function( t, k )
        if not state.talent.incanters_flow.enabled then return 0 end

        local stack = t.__stack
        local ticks = #state.incanters_flow.values

        local start = state.incanters_flow.startIndex + floor( state.offset + state.delay )

        local low_pos, high_pos

        if k == "up" then low_pos = 5
        elseif k == "down" then high_pos = 6 end

        local time_since = ( state.query_time - state.incanters_flow.changed ) % 1

        for i = 0, 10 do
            local index = ( start + i )
            if index > 10 then index = index % 10 end

            local values = state.incanters_flow.values[ index ]

            if values[ 1 ] == stack and ( not low_pos or index <= low_pos ) and ( not high_pos or index >= high_pos ) then
                return max( 0, i - time_since )
            end
        end

        return 0
    end
} )

spec:RegisterStateTable( "incanters_flow_time_to", setmetatable( {}, {
    __index = function( t, k )
        incanters_flow_time_obj.__stack = tonumber( k ) or 0
        return incanters_flow_time_obj
    end
} ) )


-- Abilities
spec:RegisterAbilities( {
    -- Talent: Alters the fabric of time, returning you to your current location and health when cast a second time, or after 10 seconds. Effect negated by long distance or death.
    alter_time = {
        id = function () return buff.alter_time.down and 342247 or 342245 end,
        cast = 0,
        cooldown = function () return talent.master_of_time.enabled and 50 or 60 end,
        gcd = "off",
        school = "arcane",

        spend = 0.01,
        spendType = "mana",

        talent = "alter_time",
        startsCombat = false,

        handler = function ()
            if buff.alter_time.down then
                applyBuff( "alter_time" )
            else
                removeBuff( "alter_time" )
                if talent.master_of_time.enabled then setCooldown( "blink", 0 ) end
            end
        end,

        copy = { 342247, 342245 }
    },

    -- Causes an explosion of magic around the caster, dealing 513 Arcane damage to all enemies within 10 yards.
    arcane_explosion = {
        id = 1449,
        cast = 0,
        cooldown = 0,
        gcd = "spell",
        school = "arcane",

        spend = 0.1,
        spendType = "mana",

        startsCombat = false,

        handler = function ()
        end,
    },

    -- Infuses the target with brilliance, increasing their Intellect by 5% for 1 |4hour:hrs;. If the target is in your party or raid, all party and raid members will be affected.
    arcane_intellect = {
        id = 1459,
        cast = 0,
        cooldown = 0,
        gcd = "spell",
        school = "arcane",

        spend = 0.04,
        spendType = "mana",

        startsCombat = false,
        nobuff = "arcane_intellect",
        essential = true,

        handler = function ()
            applyBuff( "arcane_intellect" )
        end,
    },

    -- Talent: Causes an explosion around yourself, dealing 482 Fire damage to all enemies within 8 yards, knocking them back, and reducing movement speed by 70% for 6 sec.
    blast_wave = {
        id = 157981,
        cast = 0,
        cooldown = function() return talent.volatile_detonation.enabled and 25 or 30 end,
        gcd = "spell",
        school = "fire",

        talent = "blast_wave",
        startsCombat = true,

        usable = function () return target.maxR < 8, "target must be in range" end,
        handler = function ()
            applyDebuff( "target", "blast_wave" )
        end,
    },

    -- Talent: Shields you in flame, absorbing 4,240 damage for 1 min. Melee attacks against you cause the attacker to take 127 Fire damage.
    blazing_barrier = {
        id = 235313,
        cast = 0,
        cooldown = 25,
        gcd = "spell",
        school = "fire",

        spend = 0.03,
        spendType = "mana",

        talent = "blazing_barrier",
        startsCombat = false,

        handler = function ()
            applyBuff( "blazing_barrier" )
            if legendary.triune_ward.enabled then
                applyBuff( "ice_barrier" )
                applyBuff( "prismatic_barrier" )
            end
        end,
    },

    -- Talent: Engulfs you in flames for 10 sec, increasing your spells' critical strike chance by 100% . Castable while casting other spells.
    combustion = {
        id = 190319,
        cast = 0,
        cooldown = 120,
        gcd = "off",
        dual_cast = true,
        school = "fire",

        spend = 0.1,
        spendType = "mana",

        talent = "combustion",
        startsCombat = false,

        toggle = "cooldowns",

        usable = function () return time > 0, "must already be in combat" end,
        handler = function ()
            applyBuff( "combustion" )
            stat.crit = stat.crit + 100
            removeBuff( "fires_ire" )
            if talent.explosivo.enabled then applyBuff( "lit_fuse" ) end
            if talent.spontaneous_combustion.enabled then gainCharges( "fire_blast", min( 3, action.fire_blast.charges ) ) end
            if talent.wildfire.enabled or azerite.wildfire.enabled then applyBuff( "wildfire" ) end
            if talent.flash_freezeburn.enabled then applyBuff( "frostfire_empowerment" ) end
            if set_bonus.tww2 >= 2 then
                reduceCooldown( "combustion", 4 )
                if set_bonus.tww2 >= 4 then
                    applyBuff( "rolling_hot", 15 )
                end
            end
        end,
    },

    -- Talent: Enemies in a cone in front of you take 595 Fire damage and are disoriented for 4 sec. Damage will cancel the effect. Always deals a critical strike and contributes to Hot Streak.
    dragons_breath = {
        id = 31661,
        cast = 0,
        cooldown = 45,
        gcd = "spell",
        school = "fire",

        spend = 0.04,
        spendType = "mana",

        talent = "dragons_breath",
        startsCombat = true,

        -- usable = function () return target.within12, "target must be within 12 yds" end,
        handler = function ()
            applyDebuff( "target", "dragons_breath" )
            if talent.alexstraszas_fury.enabled then
                hot_streak( true )
                applyDebuff( "target", "ignite" )
            end
        end,
    },

    -- Talent: Blasts the enemy for 962 Fire damage. Fire: Castable while casting other spells. Always deals a critical strike.
    fire_blast = {
        id = 108853,
        cast = 0,
        charges = function () return 1 + 2 * talent.flame_on.rank end,
        cooldown = function ()
            return ( ( talent.flame_on.enabled and 12 or 14 ) - ( 2 * talent.fervent_flickering.rank ) )
            * ( talent.fiery_rush.enabled and buff.combustion.up and 0.5 or 1 )
            * ( buff.memory_of_lucid_dreams.up and 0.5 or 1 ) * haste
        end,
        recharge = function ()
            return ( ( talent.flame_on.enabled and 12 or 14 ) - ( 2 * talent.fervent_flickering.rank ) )
            * ( talent.fiery_rush.enabled and buff.combustion.up and 0.5 or 1 )
            * ( buff.memory_of_lucid_dreams.up and 0.5 or 1 ) * haste
        end,
        icd = 0.5,
        gcd = "off",
        dual_cast = function() return state.spec.fire end,
        school = "fire",

        spend = 0.01,
        spendType = "mana",

        talent = "fire_blast",
        startsCombat = true,

        usable = function ()
            if time == 0 then return false, "no fire_blast out of combat" end
            return true
        end,

        handler = function ()
            hot_streak( true )
            applyDebuff( "target", "ignite" )

            if buff.excess_fire.up then
                reduceCooldown( "phoenix_flames", 5 )
                removeStack( "excess_fire" )
            end

            if buff.lit_fuse.up then
                removeBuff( "lit_fuse" )
                active_dot.living_bomb = min( active_dot.living_bomb + ( talent.blast_zone.enabled and 3 or 1 ), true_active_enemies )
            end

            if talent.unleashed_inferno.enabled and buff.combustion.up then reduceCooldown( "combustion", 1.25 ) end

            if talent.feel_the_burn.enabled then addStack( "feel_the_burn" ) end
            if talent.kindling.enabled then setCooldown( "combustion", max( 0, cooldown.combustion.remains - 1 ) ) end
            if talent.master_of_flame.enabled and buff.combustion.up then active_dot.ignite = min( active_enemies, active_dot.ignite + 4 ) end

            if talent.phoenix_reborn.enabled then
                if buff.phoenix_reborn.stack == 24 then
                    removeBuff( "phoenix_reborn" )
                    applyBuff( "born_of_flame", nil, 2 )
                else
                    addStack( "phoenix_reborn" )
                end
            end

            if set_bonus.tier30_4pc > 0 and debuff.charring_embers.up then
                if buff.calefaction.stack == 24 then
                    removeBuff( "calefaction" )
                    applyBuff( "flames_fury", nil, 2 )
                else
                    addStack( "calefaction" )
                end
            end

            if buff.glorious_incandescence.up then
                removeBuff( "glorious_incandescence" )
                reduceCooldown( "fire_blast" , 8)
            end


            if talent.from_the_ashes.enabled then reduceCooldown( "phoenix_flames", 1 ) end
            if azerite.blaster_master.enabled then addStack( "blaster_master" ) end
            if conduit.infernal_cascade.enabled and buff.combustion.up then addStack( "infernal_cascade" ) end
            if legendary.sinful_delight.enabled then gainChargeTime( "mirrors_of_torment", 4 ) end
        end,
    },

    -- Throws a fiery ball that causes 749 Fire damage. Each time your Fireball fails to critically strike a target, it gains a stacking 10% increased critical strike chance. Effect ends when Fireball critically strikes.
    fireball = {
        id = function() return talent.frostfire_bolt.enabled and 431044 or 133 end,
        cast = function()
            if buff.frostfire_empowerment.up then return 0 end
            return 2.25 * ( buff.flame_accelerant.up and 0.6 or 1 ) * haste
        end,
        cooldown = 0,
        gcd = "spell",
        school = "fire",

        spend = 0.02,
        spendType = "mana",

        startsCombat = false,
        velocity = function() return talent.frostfire_bolt.enabled and 40 or 45 end,

        usable = function ()
            if moving and settings.prevent_hardcasts and action.fireball.cast_time > buff.ice_floes.remains then return false, "prevent_hardcasts during movement and ice_floes is down" end
            return true
        end,

        handler = function ()
            removeBuff( "molten_skyfall_ready" )

            if buff.frostfire_empowerment.up then
                applyBuff( "frost_mastery", nil, 6 )
                if talent.excess_frost.enabled then applyBuff( "excess_frost" ) end
                applyBuff( "fire_mastery", nil, 6 )
                if talent.excess_fire.enabled then addStack( "excess_fire" ) end
                removeBuff( "frostfire_empowerment" )
            end

            if talent.controlled_destruction.enabled then
                applyDebuff( "target", "controlled_destruction", nil, min( 50, debuff.controlled_destruction.stack + 1 ) )
            end

            if buff.flame_accelerant.up and ( hardcast or cast_time > 0 ) then
                removeBuff( "flame_accelerant" )
            end
        end,

        impact = function ()
            if hot_streak( firestarter.active or stat.crit + buff.fireball.stack * 10 >= 100 ) then
                removeBuff( "fireball" )
                if talent.kindling.enabled then reduceCooldown( "combustion", 1 ) end
            else
                addStack( "fireball" )
                if conduit.flame_accretion.enabled then addStack( "flame_accretion" ) end
            end

            if buff.firefall_ready.up then
                class.abilities.meteor.impact()
                removeBuff( "firefall_ready" )
            end

            if talent.unleashed_inferno.enabled and buff.combustion.up then reduceCooldown( "combustion", 1.25 ) end

            if talent.firefall.enabled then
                addStack( "firefall" )
                if buff.firefall.stack == buff.firefall.max_stack then
                    applyBuff( "firefall_ready" )
                    removeBuff( "firefall" )
                end
            end
            if talent.flame_accelerant.enabled then
                applyBuff( "flame_accelerant" )
                buff.flame_accelerant.applied = query_time + 8
                buff.flame_accelerant.expires = query_time + 8 + 3600
            end
            if talent.from_the_ashes.enabled then reduceCooldown( "phoenix_flames", 1 ) end

            if talent.frostfire_bolt.enabled then
                applyDebuff( "target", "frostfire_bolt" )
            end

            if talent.phoenix_reborn.enabled then
                if buff.phoenix_reborn.stack == 24 then
                    removeBuff( "phoenix_reborn" )
                    applyBuff( "born_of_flame", nil, 2 )
                else
                    addStack( "phoenix_reborn" )
                end
            end

            if set_bonus.tier30_4pc > 0 and debuff.charring_embers.up then
                if buff.calefaction.stack == 19 then
                    removeBuff( "calefaction" )
                    applyBuff( "flames_fury", nil, 2 )
                else
                    addStack( "calefaction" )
                end
            end

            if legendary.molten_skyfall.enabled and buff.molten_skyfall_ready.down then
                addStack( "molten_skyfall" )
                if buff.molten_skyfall.stack == 18 then
                    removeBuff( "molten_skyfall" )
                    applyBuff( "molten_skyfall_ready" )
                end
            end

            applyDebuff( "target", "ignite" )
        end,

        copy = { 133, "frostfire_bolt", 431044 , 468655 }
    },

    -- Talent: Calls down a pillar of fire, burning all enemies within the area for 526 Fire damage and reducing their movement speed by 20% for 8 sec.
    flamestrike = {
        id = 2120,
        cast = function ()
            if ( buff.hot_streak.up or buff.firestorm.up or buff.hyperthermia.up ) then return 0 end
            return ( 4 - ( 0.5 * talent.surging_blaze.rank ) - ( buff.majesty_of_the_phoenix.up and 1.5 or 0 ) ) * ( buff.flame_accelerant.up and 0.6 or 1 ) * haste end,
        cooldown = 0,
        gcd = "spell",
        school = "fire",

        spend = 0.015,
        spendType = "mana",

        startsCombat = true,

        handler = function ()
            removeStack( "sparking_cinders" )
            if buff.majesty_of_the_phoenix.up then removeStack( "majesty_of_the_phoenix" ) end

            if buff.burden_of_power.up then -- Has to be processed before handling hotstreak
                removeBuff( "burden_of_power" )
                applyBuff( "glorious_incandescence" )
            end
            if hardcast or cast_time > 0 then
                removeBuff( "flame_accelerant" )
                if buff.sun_kings_blessing_ready.up then
                    applyBuff( "combustion", 6 )
                    if Hekili.ActiveDebug then Hekili:Debug( "Applied Combustion." ) end
                    buff.sun_kings_blessing_ready.expires = query_time + 0.03
                    applyBuff( "sun_kings_blessing_ready_expiration_delay" )
                    state:QueueAuraExpiration( "sun_kings_blessing_ready_expiration_delay", ExpireSKB, buff.sun_kings_blessing_ready_expiration_delay.expires )
                end
            else -- instant cast
                if buff.expanded_potential.up then removeBuff( "expanded_potential" ) -- Legendary
                else
                    if buff.hot_streak.up then
                        ConsumeHotStreak( false )
                    end
                    if buff.majesty_of_the_phoenix.up then removeStack( "majesty_of_the_phoenix" ) end
                end
            end

            if buff.hyperthermia.up then applyBuff( "hot_streak" ) end
            applyDebuff( "target", "ignite" )
            applyDebuff( "target", "flamestrike" )
        end,
    },

    frostbolt = {
        id = 116,
        cast = 1.874,
        cooldown = 0,
        gcd = "spell",
        school = "frost",

        spend = 0.02,
        spendType = "mana",

        startsCombat = true,

        handler = function ()
            applyDebuff( "target", "chilled" )
            if debuff.radiant_spark.up and buff.radiant_spark_consumed.down then handle_radiant_spark() end
            if talent.from_the_ashes.enabled then reduceCooldown( "phoenix_flames", 1 ) end

            if talent.phoenix_reborn.enabled or set_bonus.tier30_4pc > 0 and debuff.charring_embers.up then
                if buff.calefaction.stack == 24 then
                    removeBuff( "calefaction" )
                    applyBuff( "flames_fury", nil, 2 )
                else
                    addStack( "calefaction" )
                end
            end
        end,
    },

    invisibility = {
        id = 66,
        cast = 0,
        cooldown = 300,
        gcd = "spell",

        discipline = "arcane",

        spend = 0.03,
        spendType = "mana",

        notalent = "greater_invisibility",
        toggle = "defensives",
        startsCombat = false,

        handler = function ()
            applyBuff( "preinvisibility" )
            applyBuff( "invisibility", 23 )
            if talent.incantation_of_swiftness.enabled or conduit.incantation_of_swiftness.enabled then applyBuff( "incantation_of_swiftness" ) end
        end,
    },

    -- Talent: The target becomes a Living Bomb, taking 245 Fire damage over 3.6 sec, and then exploding to deal an additional 143 Fire damage to the target and reduced damage to all other enemies within 10 yards. Other enemies hit by this explosion also become a Living Bomb, but this effect cannot spread further.
    living_bomb = {
        id = 44457,
        cast = 0,
        cooldown = 30,
        gcd = "spell",
        school = "fire",

        spend = 0.015,
        spendType = "mana",

        talent = "living_bomb",
        startsCombat = true,

        -- TODO:  Living Bomb applications are slightly desynced to minimize overlapping.
        handler = function ()
            applyDebuff( "target", "living_bomb" )
            applyDebuff( "target", "ignite" )
        end,
    },

    -- Talent: Transforms all enemies within 10 yards into sheep, wandering around incapacitated for 1 min. While affected, the victims cannot take actions but will regenerate health very quickly. Damage will cancel the effect. Only works on Beasts, Humanoids and Critters.
    mass_polymorph = {
        id = 383121,
        cast = 1.7,
        cooldown = 60,
        gcd = "spell",
        school = "arcane",

        spend = 0.04,
        spendType = "mana",

        talent = "mass_polymorph",
        startsCombat = false,

        handler = function ()
            applyDebuff( "target", "mass_polymorph" )
        end,
    },

    -- Talent: Calls down a meteor which lands at the target location after 3 sec, dealing 2,657 Fire damage, split evenly between all targets within 8 yards, and burns the ground, dealing 675 Fire damage over 8.5 sec to all enemies in the area.
    meteor = {
        id = 153561,
        cast = 0,
        cooldown = function() return talent.deep_impact.enabled and 35 or 45 end,
        gcd = "spell",
        school = "fire",

        spend = 0.01,
        spendType = "mana",

        talent = "meteor",
        startsCombat = false,

        flightTime = 3,

        impact = function ()
            applyDebuff( "target", "meteor_burn" )
            if talent.deep_impact.enabled then active_dot.living_bomb = min( active_dot.living_bomb + 1, true_active_enemies ) end
        end,
    },

    -- Talent: Creates 3 copies of you nearby for 40 sec, which cast spells and attack your enemies. While your images are active damage taken is reduced by 20%. Taking direct damage will cause one of your images to dissipate.
    mirror_image = {
        id = 55342,
        cast = 0,
        cooldown = 120,
        gcd = "spell",
        school = "arcane",

        spend = 0.02,
        spendType = "mana",

        talent = "mirror_image",
        startsCombat = false,

        toggle = "cooldowns",

        handler = function ()
            applyBuff( "mirror_image" )
        end,
    },

    -- Talent: Hurls a Phoenix that deals 864 Fire damage to the target and reduced damage to other nearby enemies. Always deals a critical strike.
    phoenix_flames = {
        id = 257541,
        cast = 0,
        charges = function() return talent.call_of_the_sun_king.enabled and 3 or 2 end,
        cooldown = function() return 25 * ( talent.fiery_rush.enabled and buff.combustion.up and 0.5 or 1 ) end,
        recharge = function() return 25 * ( talent.fiery_rush.enabled and buff.combustion.up and 0.5 or 1 ) end,
        gcd = "spell",
        school = "fire",

        talent = "phoenix_flames",
        startsCombat = true,
        velocity = 50,

        handler = function()
            if buff.flames_fury.up then
                removeStack( "flames_fury" )
                gainCharges( "phoenix_flames", 1 )
            end

            if buff.excess_frost.up then
                removeBuff( "excess_frost" )
                class.abilities.ice_nova.handler()
                reduceCooldown( "meteor", 5 )
            end
        end,

        impact = function ()
            if hot_streak( firestarter.active or talent.call_of_the_sun_king.enabled ) and talent.kindling.enabled then
                setCooldown( "combustion", max( 0, cooldown.combustion.remains - 1 ) )
            end

            applyDebuff( "target", "ignite" )
            if active_dot.ignite < active_enemies then active_dot.ignite = active_enemies end

            if talent.feel_the_burn.enabled then
                addStack( "feel_the_burn" )
            end

            if talent.majesty_of_the_phoenix.enabled and true_active_enemies > 2 then
                applyBuff( "majesty_of_the_phoenix", nil, 2 )
            end

            if talent.unleashed_inferno.enabled and buff.combustion.up then reduceCooldown( "combustion", 1.25 ) end

            if talent.phoenix_reborn.enabled then
                if buff.phoenix_reborn.stack == 24 then
                    removeBuff( "phoenix_reborn" )
                    applyBuff( "born_of_flame", nil, 2 )
                else
                    addStack( "phoenix_reborn" )
                end
            end

            if set_bonus.tier30_4pc > 0 and debuff.charring_embers.up then
                if buff.calefaction.stack == 19 then
                    removeBuff( "calefaction" )
                    applyBuff( "flames_fury", nil, 2 )
                else
                    addStack( "calefaction" )
                end
            end

            if set_bonus.tier30_2pc > 0 then
                applyDebuff( "target", "charring_embers" )
            end
        end,
    },


    polymorph = {
        id = 118,
        cast = 1.7,
        cooldown = 0,
        gcd = "spell",

        discipline = "arcane",

        spend = 0.04,
        spendType = "mana",

        startsCombat = false,
        texture = 136071,

        handler = function ()
            applyDebuff( "target", "polymorph" )
        end,
    },

    -- Talent: Hurls an immense fiery boulder that causes 1,311 Fire damage. Pyroblast's initial damage is increased by 5% when the target is above 70% health or below 30% health.
    pyroblast = {
        id = 11366,
        cast = function ()
            if ( buff.hot_streak.up or buff.firestorm.up or buff.hyperthermia.up ) then return 0 end
            return ( 4.5 - ( talent.surging_blaze.enabled and 0.5 or 0 ) ) * ( buff.flame_accelerant.up and 0.6 or 1 ) * haste end,
        cooldown = 0,
        gcd = "spell",
        school = "fire",

        spend = 0.015,
        spendType = "mana",

        talent = "pyroblast",
        startsCombat = true,

        usable = function ()
            if action.pyroblast.cast > 0 then
                if moving and settings.prevent_hardcasts and action.fireball.cast_time > buff.ice_floes.remains then return false, "prevent_hardcasts during movement and ice_floes is down" end
                if combat == 0 and not boss and not settings.pyroblast_pull then return false, "opener pyroblast disabled and/or target is not a boss" end
            end
            return true
        end,

        handler = function ()
            removeStack( "sparking_cinders" )

            if buff.burden_of_power.up then -- Process before hot streak
                removeBuff( "burden_of_power" )
                applyBuff( "glorious_incandescence" )
            end

            if hardcast or cast_time > 0 then
                removeBuff( "flame_accelerant" )
                if buff.sun_kings_blessing_ready.up then
                    applyBuff( "combustion", 6 )
                    buff.sun_kings_blessing_ready.expires = query_time + 0.03
                    applyBuff( "sun_kings_blessing_ready_expiration_delay" )
                    state:QueueAuraExpiration( "sun_kings_blessing_ready_expiration_delay", ExpireSKB, buff.sun_kings_blessing_ready_expiration_delay.expires )
                end
            else -- Instant cast
                if buff.hot_streak.up then
                    if buff.expanded_potential.up then removeBuff( "expanded_potential" ) -- Legendary
                    else ConsumeHotStreak( true )
                    end
                end
            end
            removeBuff( "molten_skyfall_ready" )

            if talent.firefall.enabled then
                addStack( "firefall" )
                if buff.firefall.stack == buff.firefall.max_stack then
                    applyBuff( "firefall_ready" )
                    removeBuff( "firefall" )
                end
            end

            if talent.unleashed_inferno.enabled and buff.combustion.up then reduceCooldown( "combustion", 1.25 ) end
        end,

        velocity = 35,

        impact = function ()
            if hot_streak( firestarter.active or buff.firestorm.up or buff.hyperthermia.up ) then
                if talent.kindling.enabled then
                    reduceCooldown( "combustion", 1 )
                end
            end

            if talent.phoenix_reborn.enabled then
                if buff.phoenix_reborn.stack == 24 then
                    removeBuff( "phoenix_reborn" )
                    applyBuff( "born_of_flame", nil, 2 )
                else
                    addStack( "phoenix_reborn" )
                end
            end

            if set_bonus.tier30_4pc > 0 and debuff.charring_embers.up then
                if buff.calefaction.stack == 19 then
                    removeBuff( "calefaction" )
                    applyBuff( "flames_fury", nil, 2 )
                else
                    addStack( "calefaction" )
                end
            end

            if legendary.molten_skyfall.enabled and buff.molten_skyfall_ready.down then
                addStack( "molten_skyfall" )
                if buff.molten_skyfall.stack == 18 then
                    removeBuff( "molten_skyfall" )
                    applyBuff( "molten_skyfall_ready" )
                end
            end

            applyDebuff( "target", "ignite" )

            if talent.controlled_destruction.enabled then
                applyDebuff( "target", "controlled_destruction", nil, min( 50, debuff.controlled_destruction.stack + 1 ) )
            end

            if talent.from_the_ashes.enabled then reduceCooldown( "phoenix_flames", 1 ) end
        end,
    },

    -- Talent: Removes all Curses from a friendly target.
    remove_curse = {
        id = 475,
        cast = 0,
        cooldown = 8,
        gcd = "spell",
        school = "arcane",

        spend = 0.013,
        spendType = "mana",

        talent = "remove_curse",
        startsCombat = false,
        debuff = "dispellable_curse",
        handler = function ()
            removeDebuff( "player", "dispellable_curse" )
        end,
    },

    -- Talent: Scorches an enemy for 170 Fire damage. Castable while moving.
    scorch = {
        id = 2948,
        cast = 1.5,
        cooldown = 0,
        gcd = "spell",
        school = "fire",

        spend = 0.01,
        spendType = "mana",

        talent = "scorch",
        startsCombat = true,

        handler = function ()
            hot_streak( buff.heat_shimmer.up or target.health_pct < ( talent.sunfury_execution.enabled and 35 or 30 ), 0.1 )
            applyDebuff( "target", "ignite" )
            if talent.from_the_ashes.enabled then reduceCooldown( "phoenix_flames", 1 ) end
            if talent.unleashed_inferno.enabled and buff.combustion.up then reduceCooldown( "combustion", 1.25 ) end
            if target.health.pct < 30 or buff.heat_shimmer.up then
                if talent.frenetic_speed.enabled then applyBuff( "frenetic_speed" ) end
                if talent.improved_scorch.enabled then applyDebuff( "target", "improved_scorch", nil, debuff.improved_scorch.stack + 1 ) end
            end
            if talent.phoenix_reborn.enabled then
                if buff.phoenix_reborn.stack == 24 then
                    removeBuff( "phoenix_reborn" )
                    applyBuff( "born_of_flame", nil, 2 )
                else
                    addStack( "phoenix_reborn" )
                end
            end
            removeBuff( "heat_shimmer" )
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

        cdr = function ()
            return - action.shifting_power.execute_time / action.shifting_power.tick_time * ( -3 + conduit.discipline_of_the_grove.time_value )
        end,

        full_reduction = function ()
            return - action.shifting_power.execute_time / action.shifting_power.tick_time * ( -3 + conduit.discipline_of_the_grove.time_value )
        end,

        tick_reduction = 3,

        start = function ()
            applyBuff( "shifting_power" )
        end,

        tick  = function ()
            local seen = {}
            for _, a in pairs( spec.abilities ) do
                if not seen[ a.key ] then
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

    -- Talent: Reduces the target's movement speed by 50% for 15 sec.
    slow = {
        id = 31589,
        cast = 0,
        cooldown = 0,
        gcd = "spell",
        school = "arcane",

        spend = 0.01,
        spendType = "mana",

        talent = "slow",
        startsCombat = true,

        handler = function ()
            applyDebuff( "target", "slow" )
        end,
    },
} )

spec:RegisterRanges( "fireball", "polymorph", "phoenix_flames" )

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

    package = "Fire",
} )

spec:RegisterSetting( "pyroblast_pull", false, {
    name = strformat( "%s: Non-Instant Opener", Hekili:GetSpellLinkWithTexture( spec.abilities.pyroblast.id ) ),
    desc = strformat( "If checked, a non-instant %s may be recommended as an opener against bosses.", Hekili:GetSpellLinkWithTexture( spec.abilities.pyroblast.id ) ),
    type = "toggle",
    width = "full"
} )

spec:RegisterSetting( "prevent_hardcasts", false, {
    name = strformat( "%s and %s: Instant-Only When Moving", Hekili:GetSpellLinkWithTexture( spec.abilities.pyroblast.id ), Hekili:GetSpellLinkWithTexture( spec.abilities.fireball.id ) ),
    desc = function()
        return strformat( "If checked, non-instant %s and %s casts will not be recommended while you are moving.\n\nAn exception is made if %s is talented and active and your cast " ..
                          "would be complete before %s expires.",
                          Hekili:GetSpellLinkWithTexture( spec.abilities.pyroblast.id ),
                          Hekili:GetSpellLinkWithTexture( spec.abilities.fireball.id ),
                          Hekili:GetSpellLinkWithTexture( class.auras.ice_floes.id ),
                          Hekili:GetSpellLinkWithTexture( class.auras.ice_floes.id ) )
    end,
    type = "toggle",
    width = "full"
} )

spec:RegisterStateExpr( "fireball_hardcast_prevented", function()
    return settings.prevent_hardcasts and moving and action.fireball.cast_time > 0 and buff.ice_floes.down
end )

spec:RegisterSetting( "check_explosion_range", true, {
    name = strformat( "%s: Range Check", Hekili:GetSpellLinkWithTexture( 1449 ) ),
    desc = strformat( "If checked, %s will not be recommended when you are more than 10 yards from your target.", Hekili:GetSpellLinkWithTexture( 1449 ) ),
    type = "toggle",
    width = "full"
} )

spec:RegisterPack( "Fire", 20250303, [[Hekili:T3tAZTTrw(BrvQqtAjrtsz5yNssBLRjjEMntQrjB(MOajBkIvGaCWHK1wQ4V9996l03aGIsJZSBv5WMOXR7(DF1nUA8v)2vxUiQKC1Vmz0KthDYOtgoE8O3(2XxDz5dBixD5MO53gDd8hsJwd)3)sCo9hFijlAb(Yfzv5ZHFAvz5MIV(nV5M4YvvZgopB9BkIxxLevgNLoppAzj(3N)MRUCwvCs5pNE1m7zE0jtGjoQQCvw(vxEz86VdaC8Ife2OjfZV6sC0hp6e4F(6Tx)B)XFS96ljrfzPBVEY2RR2GGC7h3(ryyV94XJpEYPhT96XtoE07GHJq0AqJE)XJXbn6dhp6dS))4r8)p)3NmH))FVxG8vhp5d4cAfz71)ruo8FaerC6vxMexuwGykaLmRQarhtlJxhNEd8J)cLaqsJMLqwC13E1LvfKP3VkoHmDEemwyqWqO7884n47E1L)ejzdbMG7IYJX3B71LRIk3E98S0YO40c8Vd)y08YQOKTxtaWSgwQlGFpETC00XKs(e8h)o5cB713hNaVZm4z5KOfpm8QlZ2aezs5vxExusfb3gzjlYUpDy9(zyoznoZtjFAdzomv4GZNY4yu22uqIBEcBJMTC50BMVGUfHLlD3j2vxvcmgDh5qX)4tf72SL89AXgcU1y7(6T5MCcB4XPLzQ4chBD2AC4sqgywusYq8fNYMMxV96(uCE8DKPKuY6ycqioRMkPGUMUmbWmfL5X3cV5GTxFi7nrqx)KMH(fN3oWFS7HrHpNY5HGXroDGKDsRizwVPfSvq9I1fUiMwMnTE9jjmU2EkmBW66TTADPXk99KKOh0LowMbYDGQmu8d1ewugLt)lvPjKIcf88Y6NQSGbUmyqW(IZCTo6ta(opggvCeSdJsiPLQV7q(sE7192E9bncFB8ihbPcsjj3MkeezdyXt3lyXQ0Yyq67Y)63YWhuk12RxuLdqqdXgclvuLo9w4fkModX9WFsdzPUJzco0FEw1YLdxwL)aGLMc6fMkaZquNMx8xF(B6ysHv3uyIMFlvqZ3O4JyGqw(e6FaMf89HFFxOgVBVqnO80)ys0I4OYSCGC8TrlUHCunpDmQVmRkzbtH5ceeisojl9gK3h0OIgFhHm2GnOffUzUj)ZQ4nBilgEJCUModNkkDrAvX8Pc2vk2fNevDQUuj4Hc24eSluGVYGci32UafDzq5pSTCAVS3nIjx0s9NaBYOOaqhxI0YxvG(UmS59277o31)ikg4l(H7aXZcWxiVkqxSanhhDpsvr7ZGWa(7RZYj0NwOBMoHAFwNDB8P1SBuVUkiiFbGJHxokNK(Qs09M5ahmqcsGLr2g0pOe0qpmceUW(G4Hznh2jtj4gziUEgs(e6fhLt18rZZaKoZy8johaOxlIT7Vax3E5qnFp05XUZs(HNmz7BsUp6bKlbrP6(gwUcqYvjPK8OzXjXLpW2Tatg9LbLgz3rYZJxG0X0h4klayHobJ6mIMLHkIrpTwhHUNuuH0CufZnKs2KcdBfjNO6)LtcJyHa6buipHDfGQ(WnmItDrj0gavN9b(aq1MotVmzfa634rDNa(7feVo0J)Rq3NqhGuFEAwjtPUWXDgPzbtWL5288vKfvuRQzPeMGQZhWb5QiqjpmtmBhw2gWPBjvoNcKLX3ScwcKARgg07MiNhQy6qrTATmhZC7yQ5d4pmA4BPV0OHtOplKlxduhbypFrIMtgWJp78GgJ2E9Jp2WaUGJdMQBMRTE2(0z4k1C4xGllKXMkMGnzS)FnNPianXiMLKLTyk6BLXOmJjOM6AAnuveAgjVGKJUrj9Fx8iAay4SzmrNQoOO05yqqrjGCtsIXinDDIHWmDnOgywpXHXFgmw9aeCE5kKgn9(CqT095rBuCUW3ZRrkUhbLff8NKAlen2mHQUtjKu2dhoFvu(nOvqymJye4fKLrvjLw0uQPlanJrg7IY6KMjvJoA4PkShRYiPXFIh7PlQUCsbQXu2FzkAwWza81CKSuLi2Omlj1kFKj7yZM8SprZZHiW)7xHQHuvfwSQ2lwMDMOu0teGSkbuA16zOxgOBjsvwCVQkPqendeqKEilJp2XsZZ5JJyrnKhysA6UneuhYH8WoCO)Zs(1rqCsTUEDATjnysnWfRIxIMOMUj7E1inR1jPpIPmJbAAO04g(VmYXLizwfu6lqqas1LCqU96FfHPAYDyuznloMwih6sDqZOK(nqtuJsbi(OA35vLGMxMnbpHbOtRlUD20AUawcaKOAGLz905lMoE8Bhx)6dOJRp9FkHWPVLuoSC8WvrftRDcON2ZKqucKaRDwYQub(KaaFsNb(fut1du5yyBu6qMYcK3LY3Azi7Do1r2EwRzXphIwmEepzcAMOH9W7hrxViTKHTBbuy5gyZdRb10GwxaEBYYlfPgag3jN6z2Ex9SnlROWZOMCQwIeuMP7jZaS1YLGpEc5q9h6iEpUpeGziqxBEwvXuWyAAX64sAIzSvARK1BqOeiJ)90JPEMIuWcr4dGXM5Xyyyu0ptPyHtp(8iwHiZgre1ybFBahHkX53wdMFPyQOI5GJPGFepmf8ePADnqdnM2VtoXP)(D2vK2oJximIQiTcoBEkDvywhc2QiLuHoqv8qk4bcM55vOxvTG6pHs9RKu)qo9PkP8vmARnjDScj13Qc3h(9Brn7Po0PiHoQrITMr41U8zRHo(va7cO6cmexmgymFMBV(BrNZky)(gG1nMAvJMpefJrBVgtMbMu07Kw(W)wAwDcqqJAhX9Djcd4kFX8SfOHoQTj2lebZWnP4pcyWsWvshLZWYPbHcCVovoDzo7zOamZqqtEMWHLHNblRaNaZbx44E19AvZEn4Iavv4BumfQSoRnxEm1sYzUhgMZwPFYhQAr6os(g4fMwp4I2nzombu)8gbWaKW)L0LCVM9Sqt8q1wzc5Miqtu9umf3mixARkEZ4DOkj)Kf7hLNMfIgnyf5sWK)l82ecF59Q7TDEtz6VR)arAPIuCPnYTFCvBArm)EQkOAX20ZjUlLLTai(Iezd49dd1Sdvq4Bw8FxviQF8DgUNJLGoplPqtPhQXkctZpMAPIim)F6QePZiTm(Sca9BzvZxXvJnNv5gMVdxwbyV)kmgmj2FRO0koZBKzTY05CyUd2uDKKmQfZZYNVAk5teWMbrTCs2Ak5A2yAx40YlmQ3t4020cgDK253dyV617tdHaCEjh0ZTykBBj3oiF7cc9LnhIQjAfEuf17SXPZ)EqOYTHskd0g2QSYPfO7A3sFOWHzE6qi5RJJ02ksXd9CpuNaeuoDmBF1KOeMHsvxN1mbrr3MUhhmerbPuSYK0Xwg9yGi6z(Srx0CCVX23fd4H(XwAW95WyDxTNXiynkCQW9Whl8F)eMWVI)hi4oKNRwooyofQvA9RmudOFIIB0uCrsfLQa(Djlwe(ti1fxqgoZjsbvkHaMhhIEeJ1HI6uS1mLvvwqlBcM4jByGKaLPDoMvDmbhzZWw(bNCr1Z9KKdDvJnIDPS8TRusDsNBtbOmsQv1BJUG(7Y6DfT(CHXk4PQ)(vXiCBBfjIYgxTr8eHQDLoYHBaqlWKrdpLRIXHlY880oW2tfnoY)GsJPEsXqSc(c60EKP9s78yImO3qWcrH5)8NWQ6qd892cECcuo4pvsW)8FHqs48jFBvoYBiuHvt0OPa2mY0244KxBpEOmnYqO5eJAxVO4HoD12UoPZXw1W)M7YWcAopAZMyr3OiDKrkaYDzb(7PPeg3TrAivrkUvRY4Mesg9zc5MAUpZNs5Y453QQuULkn75MFFaff6p45gjtoZKgRLAqU45LAyFBoifImqGtxGc55zLSKyJRn)fr6aSCaoCqtjDnZjttZUlYGu)ZZbe8Va)UIcvM8Kqz6AWjO1eS8(m1WUCrLwdv2msZL8KgsVVf(r60bDtWQyd6gpmUi7A2eLdRvY040ssscbWRHRBtOsQ6Rh1oJk2XDvPrEktxxD1vA2(iPlZ9R)TTxxBw(Vt)5V2oti0ChUmwl7)HlWJJEkByD9WU84XUQuvRCTR2uIQDijA7urLN54V)zfiVshyTSOIil9jt3evcorR6Gd4427mRt9sS1tLdcgXh(WheZ2bHHOM)sUwsdE6ugRYOvIQZOP(IkhfJcokMO0S1fYtitQ7qNm1UPlYQHAv8T2rSD5ZHKwd4)xk0gSoaKc1w0oI1yzGCzmO8i3dg0TdwceyNkFOJEk()xAP7KD)sl0aq0115XTFxzlYjbUtfdvwx3BN5KYEYEJY(Nq6MoPYTB7q0NfvONE)fiIvLJRGmxxUjIg47AQNRwsTrQh3PcYN2KKvWh1lSQTVHUe2E9piwdDqNMBuK5MQgh5kxoG)bDflnDDuQPpL7k6zdjFoWUst3aUDrqJBWKS7dHIyT6GSn(4idP)nVDKR6C2kwcfTegzdBx4nAbdGvBCq9jFNvTPVORP9w1BTLeFfqRFWzApgGfrh7fPBhKcgjoUs29RKrqjyHvR7WEjnE0WtCwb3wUVCvXRwVPAViVSxQW)Iwm1SKWPkslYN2MizHg47waDTg7znT9VZ6(2Ch88otZx19mLD1TRZskU(J8ukcR(kYQ8XnVSGDIY6Yt3lmvgFiLz0zT7AO)nelGa9hHvLZAE1h4qEGw5Lp2ZSAmQ1zzPjXLWUnUyTXZIXUmVIMUTByHOR94InzXjfyvhsjjalwEvH5saKgNrxgOwcWBbrwuKJyvwEkcbyVLL7rxaRfMSZNhl40iAkKPchylfOA3hZfGU4okmjNBNLNRvkU1AQkjHbBPy962IgwWwkOU)4CzIL3Zufc5u4VFZn8TwbGwXTZ8OsYnzO3l1nwcvuHHeQbHMDQ)JM0GZrTYADj20RJZZZYNgVMESK1Y(HvvA0ZbN)Ck7jyEz2cv(rzMXfpCZd5z8mjQUyk9NUYwFUFBmBL)bppKY0ghZoAQS(0)xfRSJO(zcA6b8)pXY832R)9nmoXiTamoOJz0pyQ15PUCjFvzNa9ly1evR0p8xsIwvtu6aVzWeIqqHksBP5IPXyioSJyW5IMROFO(vLEqevYMVOJeL16FjHKqlK5mm15ALq08e95iBCDcZAUl59jyx2OIOK0w0QXj1WEYI20aMJrEKf9Eud194NxY1ji5FJsFa7GSBoIxNmDpfYu0)OYYIQBWsRHNUfJQBWuRYWd0KFGvaHFuvyNmUT69h8p(DFp78OWeHqqA5zkTZeUlkoHs(8u)KsPoh2S7uSFUABR6QzsCKvDvcKsb3R7gvjJvhBEfvPsWO8Dixbd0kkFjLKmZga8)K(JcxyPNViACjXR3aVhTf0KXXXNVWshnvrxTs35QAtE0knq7f157fTUJK7fpIHYxiqFtOGDwaoJaXZpf9ROCLPUAApS8n17j01rwu)2((BuzbqE47PWM6Ujf6bsOqRu0pKXJAxTLGSP7Gzu96SQtqKSHAD5bRIu(S(2iBdEWLJkwbuQ40LK80mBvEKpHNmuQrzHEvufUfFUJQdmxVCoTCd5YDbhzJULiARS)ivL7RvBcoaQIqkXFk9O)vBFMg1SpcHz4b1lEFIk9AUdJoZ6SXZeNHiEUdTImCmVzJUYUWzwPU0Gw98ID0iSMPHRf9oHNkK33(IFW0zb1A)UbVfysjyGvkkgvZLAWnRAdw1pGpCX1LTUrN8u7sI6eZQjGOU(AYhqTz1CeoM2bHCBS2QP)M8BNBBoUMLZ9oaL7ocABV7UbaoX0WLDZQCWwJoXtbFXr7E8s)aVW0lazVvqNqz48M67LVxTNLegIO5wzj1SOWK0rch8m9jSqy6eGWd8IHWdYKcypDM1qWMOL3LKyw4QICngvhn1BKbsPNSonlSQTRAMcC4muYEyvRfc828nT72xW0wKPr0EEAljW5MHN6rMWFxvRVcnZQC9AXsvTxPVEHe7mTaEwJEA4rxSvkFnnlKNvus3CK10Wzwt9IyJ(ohzeCMOvtIaSfXSpVEnOhVouyH(55rjlCw6ltDdgQSdHn8vDvBdKJ1oX2ghAxJCP0(dWRsZ7WxMIqECLyYa(4icDTj))96XTRSwQfJLF2TdujtHDHuewTKVzwwsPLnm3CddCsw874sq)aTlXvpwPJgUbJ7k4y5vVsSySkbOmVBDFz5PDjKstQ)OJqKiPzv3SswLOJyHus1VcUfgH1bHgOtKrBqO2AdYZ9uDfhOoNiQAb(VZRYZb6iAyjLChlvL4byPIhV04rLdRZQOLUaZS9zDclCeiL2U9VZm4iVZfCvlewCDmthUYplZUO5iXchfXV))0ROeIYO5aHAMKpAVLZa0inFyij)5E7TTwCIMPcjbofNJ8DawQVLkCeo4oQMQ9xsfsxKFcXu45av8eIdHzSVHJ5G(ufug2QHoAw69NDuqdC1CKYTSyrgez9Qy1YoqxgChPIzsCDRfkF(ig9Fk0J6CgtBsLO5ZjGIPiQRfA2b0CwXV1Rd6M1P4ImMRGZb5LCIDoqCHfBndKRmL0q03pP5ZNpqte2UdKYbnl7n0C0A9vKcjR24UBVc3HtJvR37U8yWFHUAqcP9(66kx9ksY3JgBLzb)iA5)PhVaXmS96FOEkqjFH9T6Iuz0Hdrmt88PyOROmAkoOMknI)gvN(G2K68EQ5FWz0XUEMEIjC56UABLOLfepPEX9tFcZJVST45XpHzsXgINnL1a2Lz7GwPmKpLm9ydvyx8)SN0A5jR927cUP8TeUVGLzsr9srgLitwNH)5LXPX4YMLEd2Ofv(HoUzzv8Q0LaUyQ63OCEDgoEtY0nL(ZETjfDELxdK)ovhdERr5DB2)aMsLMKVg4uHKzY5SsBxq9Ch6oBlSMNvRMUSJUZar1pcY946iDZUppvtENcT2tIJyjqbxGIURxjTvTnN9(JQ67WldKKiikJTx)t)gVcUAx1WQXiGJDkor1zhXxQd8qjc6fT7mZOM2zVjUBNG7XnLE924h)Lmd56hJq7wWClT7nxfJHQVjpodWvp4UR3cNMsFzTRHGa8CCX1eI8bA)oz3PCx6WF0gPqDAD63J69yf2CMqQg8NDFhOvqM9UvTZMclRNZohWZs7qkUkyZsy0fgDqaZxh)ZY7sHZ(MaN66Cs9YrG(ta(wx0XF5jcghudMDfpr0)aiu8wPaRdqDReF73kjyNUJ0D9rUK9Toj1MkE)CUahwNHznbVF35DVanFOxY12hB0ioO7SRijB8Fa7zEcBClFjRePmczMBZ4LbbdOOJ34H)HKFhr1zz7Bs1aN95G8YE4kBFY18Roq5VHQQdyjzYPTj55LxD5DKCADhWphqVD8KrV7QlVpkhpOef8MWhyGYWgBI605Ru4jkP3IGVcDV7Fwft7jzmpJaYVQmJ)TVbpQ(3qkgU9J)Ty8q082VgPZ0wLcF8RuoYG8MW4vm6KJNiyDHr0F8NgiH5PUHPDkNmaT)CszodJh9mSS9buXvETbenVjSRb32p6GoPSauBc6UrTM4zBR2bFMBCxn9AdRv(HkPBRT3zU24xZO6x7QYvN7BLvtAIFGAELQ6aWogYZiWBeStcJiSECRwR23TSoa8UIi2nGlb7xfKJacY2dZa7jARqFGAIxqnXhOgFIoSY2qy(TvWS69kt1)4MRNiHCsjxh3fKh2pqEtpuK5LqxQuVU2z)gUqPg8LHUjfpE8znCFpEOCMCDY3cd8(wyi(tc(Ad(YVCCVaiOZ0k9PGE(NdIXBEojgHbUxIrWxBqNOf1YowAk2)M2F))opfwTYJXmy9CFtWKXpJ7bNofipRLDZTapUSSxwNSz4e3Zq9nEGbKTVkeAjevULfmaPJ7FH2cZy2DZHjaJ1VYoAl0EgwHpb8ONab2)q8jTV9bZDJY8cUcFc4rp6X3)q8jTVFbH5oTZDQNKNah2RVFIVl6PB1W5s16qpTxwTwf21y16TWVMKklN(zVV7Z2HXKe(aG0YzsTcngW3vDLmH6yF2OXCdAUEvZxyBbKrQenaPNenAbCpPaApW0XNapQV2B8j(Ma9gt2uvHZUwUbbgLKTr7T1UjV8CJh8aFJEOWKlXDhw0s1M7r34cQSVUf0CQX3Ud1mH(hEgXnEG9EJU(CU2h7rj(tu1N3Wt6QQpFa6jQ6B7h)zQGncY3l6mf2xvnuEflaE2Y4ezTvkgkd)5WZFJ5Lp62p(fBVEhUEGEc3ENB)ORfMywoc7OKZvt5CTMRJ4z398JhFe9wr5CVIQhfV8CTwoYgANnAx38LT52WAVCbz2gCL7tsLgcW9qoFehlE6R7ZrK1Um(4JAQPOoMo4W39AXVYJL4Wp8Hp86(hyp2EhybYbpV4798nRzRq9UoMm6yExJqI4XBeXNvCYUETt2MnV7s6QT7DpK)9IVB)Cfr2geUrx0OHPnEMefFsRrXF2GqFs3JKTbpAEq50qKMpCVjRUhVFi3Lnj9WcknG(2rhLT5C6LlydBQwqW649(yBw9kko0RGHp1l6JQden4VThVvh74EtTjZL0MrdpPTeN2lOTNV9gBZ(0vbHQ3K6BXD9kASnRd1JSiNT4DT59A3n3ihIJN4gKv8VfHbbjffShUYbBZUsH7lJE98X3aEV3hF8XMUZhvgH299OYVBExpQ8ih3ZJQtP9D8OYt1UFhPyX)1FPi2gIqM6n8iNamzKpDBSr7gUQxLIUhHHhd6nP3fnfJGBykButmCu(aGFw9RrU6VR3qC4QajRNH3TlsHFL9B5F2(GHRHdmo0YwsD8DNk6H(H9grl0cIB81d)IaZ8H(QGofV(c8P3wDByO1THgpGZ1hyZDH)RQqwtn6DUJT(4WYNTqnwXzYNPjD(4JE6PYl089wG47DGCvh74779GE97x6S7Y65VfU8SYgCyF39Nvp)nbLpqDX4bQOtPvlLV40NR)bNgzx7B1wu9S6UPE(qFJh1tRvno79Jg84J9TAkeLXtFKNp)2xCYPgW7Di8WBNaJFFYPdQv78e(Kx7eHfYmVM(DhmGJh5z9cl3VqOoeNTfzt95CszuXThPCiWoFSuVIcoTAZJpAmjJ8VD8)TYUPD0j(bQPBgnakPYGJp1hXZ8lwT)52ZNFAxykb33xzIWgFQl4tnUDGCFyRiIU4)m97lTtfQ68svMh0t43OOuVF3I5AE)ZrZW9V5DMiZd52(5E(PWo4Lpi0A9833jhPOLXSjnqNpY2aoQ9RvocOozkFvM7jPi2kkA8Lzr0)z3NG5NfITZRQlhs923AIxCYR5NifDfQ2tvpVLasDlzNejNkK6FG7J11Jpg(aDDHK8k1iXEEnpZbHouFd4pw74QXC3X6JNCV(s2p3F2Kp78Xp(yiw0jJg4m(G)VWNrx)bny8LEMY35V8InhpH3yZo(0Z4mjn(DF(qFKAjS2VgaBVPezneSXndKvmiYSpBej6k9FDFRCvzaQ1M0cvDnPhkKZRJ6X0J4kTlUkqyVdukzTqVPlve9LNNZyX5AxQFTgCMxalyMxavew(ADX5tg0Sjy1QPRMAxFkvDSvcIRywi3tFeFdqUDqGDlnjVRp613we9m3VJ(h33asl9SPGTGgy1(JhHu65LSTrywrxejkoF))10vDJi(e(sfKCFjEQAWMoaF8uyAh)I67UMo8vlOoFMCjsgHbNs2TXdnVg2Em6lngNjTWJjVOREIkCFq5B1aZ08NBFPbcG20V)wPj31J2)E2X4G6hCOxBaFOMFFha5i05WXNoWRRAdusjTQp4clP1jCTXHnljlBb3UvtdLKxqYVL73Gn7tJaGf(fmFnosmvfiAnzkQAql1q(EL407YUfRfmOcguZtVTC4o9q9dioDzLOq48uqR(ZcnepLjsOUdD(TOcV4bKtM9J4tydtw48j1XxN7MnE7cn9(Cqp795rBO20C)efpaaRM(ZKX5J46Q(tYvfRt0gns72esUC3fkvAoZBU7mFoAhwo6kOyg22lxRPbxlgvzZPIUqrag4HwXygyS(UkxoFuWKwudAo2Z2pvZRWNqidz5bF(rf93fCb3qSvdyR66LR9vThcIiCSAeAr6im6HzNoD1ossy2Uy2TXHxeDRMcdQ(zt65X4AVd673rwTwhRgRggLg2pV2T8LY4VW3UPpnkdJf03LyeULEzVShdRQv(tTls5axUHN7ocKGPEaEN(CtSMx)J9C971r66kDSQDD1JpQy6w)kATN7NSdW2X1gzpppAhGUDG(Ql(azbO5z4apAZ4a38(l13VVdZyRvS6zkzHr11l8YgLO3BzlYFMM9WN3ykOFRiJ5dczuef1cXxoWs4emi7kZtbKWzz(ulLgVUVYLw6fJgC2eMgUgVPpBWbq5L)PMx80KLlv867I0dxapLlkZU4pyFhyqVUAPaofWG5xGbf9lFZUcNJ5csQGjSnAB35mVTt74BBxLdn(T2doR76thztZ05MgqpDD9u7aJhxMcl2EMSqxQ8J769kzxyj3BUG7L)ZiKHDlSfV9duDj3oXBI1uYox7zQ2BiMpF3VwoN6ZpuNQ(z)MXfO5ttiPFdsjkg36M4Clxws1gkxlM9KX6GNYtzk8nwIDFb9f8VDDFwElwgwmrRiK7hoSUqGcjv0t(NU4CPg1wSa5PN7NaulMFoxnJborIMoMNNnrR0Uq06X82i3vnNv7PwQpnUrYL0Uk8WU3(fkWGcEksGxG6aXpJhniYCClu3d2u)KzBiPXhw3CZ3G17K6yotrUiNNjJ98UtTnA47pUJSYq0Kp)197My5arJBOgWKxO1OtwdoUPqD2Vyj7yMn73kNCjus)3JwG0zyzXiTepAkQhDBST4XS9y81CW(OvZCGVG4jhj7ZTz2MZXUeITBvl1mhpRuqkLN27GM2bEWm8ZfGrqkUoN7VS7CMBdoUYkKFGAp23iOpDWR7l9eDGcoZrE(CupF)E6ilUSpUSFuw3gWQfTrGR5YOv0ToVxuxLqvUI(Cf0jLIFL5CD(7Ejq6sTRMfFsL5Z7bRQxJV(XtgDwG0I1apQ6prD4e9XaJWoUel8deC0ll2YJjC6U4FeHD7XpChwYMVoGkPflqdsr06NHwOoH5nZAw9AwSOq3qflXp6SlJpvHDbT7H(IrxHm)LsFvjAdhDUfqayb3Y2Gg7ty(KXZlCb5LMzlhqrtj3rRSoSrhgtlxR5Vs(eEpG0Z8NPNmRlo)eRhipLrJp1fH4BsUp6HcEV6P7sdwmX7QsqFrNfNexIFTNPVmf6438tSjOZPHPs7YDQ4Bb74CrZM(SmSRurVhwhHFuie9vi6IBzHip3Ri5KNFuTfowS1ajV40xFG7NuTXGgO8moLiSb4Z8nJ1Hj4XNsAfE5kqeI1sTLYtKO0hpkAEbtSI5wh)40rlRmpOaNpGdYvrGsmyMyAMT08ACqXwY(mgrEr0j3gpDq6u4rCOlFLfIhVU)4J7pA4BpC0WjV22DIbIF7w(nR(GZc1ewbB)8l0Qb(XtenqWFW71ng6qTkviPt(9n)O23vphutz80tF2z9UR552ztlA61UrHjUqjxXTix1Az77WqvEASsVtBDMcb(azprEXyrjI1Aajr2iMi9usP0JLk0gqFhTxcoIR5u)a3JfAuCEJ1ih8g8afMnABvMZMmMm5PyLlzYSTBia(JF33Ze)ySh0eRBEupJvlq6WDGzq7mMfKnWKqr95SjALqotLg0lazrJTjiHEqpuU7IrQ9kMvlvANYuVbb6(St3Zrw)58vgjqFq4LrDFh4T6yAPKdW)mm8ztcd4gYnV7f7(bL1(KdhmRR(ZKA4LzJzKSTPTV3b2FWX6ioF)URXycupce1158YQuAZmETSPHfACmvsvO0EbpOMfXzekG9CqpgYDzrtDhjUK25BIqKJQnD9gPvl9lBfn7wQNGPmf4WnAipwtATI8Wgys9PhZNjohX82pKcV6g(25L56GgIyUx)(EmsIktBY(jR9(pWvD(c2sc998mnapWLvxS2KUpSxD(evr1BDUNhktMXJp6Ot8pzGZZdXb8TLDf19xCdNNOcRwp5GagWgmObL6DLh0LQ4EoodhJhEQdkuh0j1QIQ6MARRT)SgSp2m(PJvqiSIE5U4fOgpbr2EQIIRX2UwCneeSBpFdtYJ75)0A1oeRhrFzVc6TxE0ViJhiC3qNe1GyKRlZnVoDyo4E4LI2WnZldmg6fNMYHYGKMvH9bc)Mq7iwG3XSwd8MOyET6y2ZuoyBBvUCj3koZ913hxuf5IJ2p(VZRYZbKeAEoLCh7ghcpT2v8y5gpQSjRCT0vmNhbT2jCE1L4vJXv)Y7oH(jG7Q)3]] )