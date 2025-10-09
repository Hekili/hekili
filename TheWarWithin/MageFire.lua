-- MageFire.lua
-- August 2025
-- Patch 11.2

if UnitClassBase( "player" ) ~= "MAGE" then return end

local addon, ns = ...
local Hekili = _G[ addon ]
local class, state = Hekili.Class, Hekili.State
local spec = Hekili:NewSpecialization( 63 )

---- Local function declarations for increased performance
-- Strings
local strformat = string.format
-- Tables
local insert, remove, sort, wipe = table.insert, table.remove, table.sort, table.wipe
-- Math
local abs, ceil, floor, max, sqrt = math.abs, math.ceil, math.floor, math.max, math.sqrt

-- Common WoW APIs, comment out unneeded per-spec
-- local GetSpellCastCount = C_Spell.GetSpellCastCount
-- local GetSpellInfo = C_Spell.GetSpellInfo
-- local GetSpellInfo = ns.GetUnpackedSpellInfo
-- local GetPlayerAuraBySpellID = C_UnitAuras.GetPlayerAuraBySpellID
local FindUnitBuffByID, FindUnitDebuffByID = ns.FindUnitBuffByID, ns.FindUnitDebuffByID
-- local IsSpellOverlayed = C_SpellActivationOverlay.IsSpellOverlayed
-- local IsSpellKnownOrOverridesKnown = C_SpellBook.IsSpellInSpellBook
-- local IsActiveSpell = ns.IsActiveSpell

-- Specialization-specific local functions (if any)

spec:RegisterResource( Enum.PowerType.ArcaneCharges )
spec:RegisterResource( Enum.PowerType.Mana )

-- Talents
spec:RegisterTalents( {

    -- Mage
    accumulative_shielding         = {  62093,  382800, 1 }, -- Your barrier's cooldown recharges $s1% faster while the shield persists
    alter_time                     = {  62115,  342245, 1 }, -- Alters the fabric of time, returning you to your current location and health when cast a second time, or after $s1 sec. Effect negated by long distance or death
    arcane_warding                 = {  62114,  383092, 2 }, -- Reduces magic damage taken by $s1%
    barrier_diffusion              = {  62091,  455428, 1 }, -- Whenever one of your Barriers is removed, reduce its cooldown by $s1 sec
    blast_wave                     = {  62103,  157981, 1 }, -- Causes an explosion around yourself, dealing $s$s2 Fire damage to all enemies within $s3 yds, knocking them back, and reducing movement speed by $s4% for $s5 sec
    cryofreeze                     = {  62107,  382292, 2 }, -- While inside Ice Block, you heal for $s1% of your maximum health over the duration
    displacement                   = {  62095,  389713, 1 }, -- Teleports you back to where you last Blinked and heals you for $s1 million health. Only usable within $s2 sec of Blinking
    diverted_energy                = {  62101,  382270, 2 }, -- Your Barriers heal you for $s1% of the damage absorbed
    dragons_breath                 = { 101883,   31661, 1 }, -- Enemies in a cone in front of you take $s$s2 Fire damage and are disoriented for $s3 sec. Damage will cancel the effect
    energized_barriers             = {  62100,  386828, 1 }, -- When your barrier receives melee attacks, you have a $s1% chance to be granted $s2 Fire Blast charge. Casting your barrier removes all snare effects
    flow_of_time                   = {  62096,  382268, 2 }, -- The cooldowns of Blink and Shimmer are reduced by $s1 sec
    freezing_cold                  = {  62087,  386763, 1 }, -- Enemies hit by Cone of Cold are frozen in place for $s1 sec instead of snared. When your roots expire or are dispelled, your target is snared by $s2%, decaying over $s3 sec
    frigid_winds                   = {  62128,  235224, 2 }, -- All of your snare effects reduce the target's movement speed by an additional $s1%
    greater_invisibility           = {  93524,  110959, 1 }, -- Makes you invisible and untargetable for $s1 sec, removing all threat. Any action taken cancels this effect. You take $s2% reduced damage while invisible and for $s3 sec after reappearing
    ice_block                      = {  62122,   45438, 1 }, -- Encases you in a block of ice, protecting you from all attacks and damage for $s1 sec, but during that time you cannot attack, move, or cast spells. While inside Ice Block, you heal for $s2% of your maximum health over the duration. Causes Hypothermia, preventing you from recasting Ice Block for $s3 sec
    ice_cold                       = {  62085,  414659, 1 }, -- Ice Block now reduces all damage taken by $s1% for $s2 sec but no longer grants Immunity, prevents movement, attacks, or casting spells. Does not incur the Global Cooldown
    ice_floes                      = {  62105,  108839, 1 }, -- Makes your next Mage spell with a cast time shorter than $s1 sec castable while moving. Unaffected by the global cooldown and castable while casting
    ice_nova                       = {  62088,  157997, 1 }, -- Causes a whirl of icy wind around the enemy, dealing $s$s2 Frost damage to the target and all other enemies within $s3 yds, freezing them in place for $s4 sec. Damage reduced beyond $s5 targets
    ice_ward                       = {  62086,  205036, 1 }, -- Frost Nova now has $s1 charges
    improved_frost_nova            = {  62108,  343183, 1 }, -- Frost Nova duration is increased by $s1 sec
    incantation_of_swiftness       = {  62112,  382293, 2 }, -- Greater Invisibility increases your movement speed by $s1% for $s2 sec
    incanters_flow                 = {  62118,    1463, 1 }, -- Magical energy flows through you while in combat, building up to $s1% increased damage and then diminishing down to $s2% increased damage, cycling every $s3 sec
    inspired_intellect             = {  62094,  458437, 1 }, -- Arcane Intellect grants you an additional $s1% Intellect
    mass_barrier                   = {  62092,  414660, 1 }, -- Cast Blazing Barrier on yourself and $s1 allies within $s2 yds
    mass_invisibility              = {  62092,  414664, 1 }, -- You and your allies within $s1 yards instantly become invisible for $s2 sec. Taking any action will cancel the effect. Does not affect allies in combat
    mass_polymorph                 = {  62106,  383121, 1 }, -- Transforms all enemies within $s1 yards into sheep, wandering around incapacitated for $s2 sec. While affected, the victims cannot take actions but will regenerate health very quickly. Damage will cancel the effect. Only works on Beasts, Humanoids and Critters
    master_of_time                 = {  62102,  342249, 1 }, -- Reduces the cooldown of Alter Time by $s1 sec. Alter Time resets the cooldown of Blink and Shimmer when you return to your original location
    mirror_image                   = {  62124,   55342, 1 }, -- Creates $s1 copies of you nearby for $s2 sec, which cast spells and attack your enemies. While your images are active damage taken is reduced by $s3%. Taking direct damage will cause one of your images to dissipate
    overflowing_energy             = {  62120,  390218, 1 }, -- Your spell critical strike damage is increased by $s1%. When your direct damage spells fail to critically strike a target, your spell critical strike chance is increased by $s2%, up to $s3% for $s4 sec. When your spells critically strike Overflowing Energy is reset
    quick_witted                   = {  62104,  382297, 1 }, -- Successfully interrupting an enemy with Counterspell reduces its cooldown by $s1 sec
    reabsorption                   = {  62125,  382820, 1 }, -- You are healed for $s1% of your maximum health whenever a Mirror Image dissipates due to direct damage
    reduplication                  = {  62125,  382569, 1 }, -- Mirror Image's cooldown is reduced by $s1 sec whenever a Mirror Image dissipates due to direct damage
    remove_curse                   = {  62116,     475, 1 }, -- Removes all Curses from a friendly target
    rigid_ice                      = {  62110,  382481, 1 }, -- Frost Nova can withstand $s1% more damage before breaking
    ring_of_frost                  = {  62088,  113724, 1 }, -- Summons a Ring of Frost for $s1 sec at the target location. Enemies entering the ring are incapacitated for $s2 sec. Limit $s3 targets. When the incapacitate expires, enemies are slowed by $s4% for $s5 sec
    shifting_power                 = {  62113,  382440, 1 }, -- Draw power from within, dealing $s$s2 Arcane damage over $s3 sec to enemies within $s4 yds. While channeling, your Mage ability cooldowns are reduced by $s5 sec over $s6 sec
    shimmer                        = {  62105,  212653, 1 }, -- Teleports you $s1 yds forward, unless something is in the way. Unaffected by the global cooldown and castable while casting
    slow                           = {  62097,   31589, 1 }, -- Reduces the target's movement speed by $s1% for $s2 sec
    spellsteal                     = {  62084,   30449, 1 }, -- Steals a beneficial magic effect from the target. This effect lasts a maximum of $s1 min
    supernova                      = { 101883,  157980, 1 }, -- Pulses arcane energy around the target enemy or ally, dealing $s$s2 Arcane damage to all enemies within $s3 yds, and knocking them upward. A primary enemy target will take $s4% increased damage
    tempest_barrier                = {  62111,  382289, 2 }, -- Gain a shield that absorbs $s1% of your maximum health for $s2 sec after you Blink
    temporal_velocity              = {  62099,  382826, 2 }, -- Increases your movement speed by $s1% for $s2 sec after casting Blink and $s3% for $s4 sec after returning from Alter Time
    time_manipulation              = {  62129,  387807, 1 }, -- Casting Fire Blast reduces the cooldown of your loss of control abilities by $s1 sec
    tome_of_antonidas              = {  62098,  382490, 1 }, -- Increases Haste by $s1%
    tome_of_rhonin                 = {  62127,  382493, 1 }, -- Increases Critical Strike chance by $s1%
    volatile_detonation            = {  62089,  389627, 1 }, -- Greatly increases the effect of Blast Wave's knockback. Blast Wave's cooldown is reduced by $s1 sec
    winters_protection             = {  62123,  382424, 2 }, -- The cooldown of Ice Block is reduced by $s1 sec

    -- Fire
    alexstraszas_fury              = { 101945,  235870, 1 }, -- Dragon's Breath always critically strikes, deals $s1% increased critical strike damage, and contributes to Hot Streak
    ashen_feather                  = { 101945,  450813, 1 }, -- If Phoenix Flames only hits $s1 target, it deals $s2% increased damage and applies Ignite at $s3% effectiveness
    blast_zone                     = { 101022,  451755, 1 }, -- Lit Fuse now turns up to $s1 targets into Living Bombs. Living Bombs can now spread to $s2 enemies
    call_of_the_sun_king           = { 100991,  343222, 1 }, -- Phoenix Flames deals $s1% increased damage and always critically strikes
    combustion                     = { 100995,  190319, 1 }, -- Engulfs you in flames for $s1 sec, increasing your spells' critical strike chance by $s2% and granting you Mastery equal to $s3% of your Critical Strike stat. Castable while casting other spells. When you activate Combustion, you gain $s4% Critical Strike damage, and up to $s5 nearby allies gain $s6% Critical Strike for $s7 sec
    controlled_destruction         = { 101002,  383669, 1 }, -- Damaging a target with Pyroblast or Fireball increases the damage it receives from Ignite by $s1%. Stacks up to $s2 times
    convection                     = { 100992,  416715, 1 }, -- When a Living Bomb expires, if it did not spread to another target, it reapplies itself at $s1% effectiveness. A Living Bomb can only benefit from this effect once
    cratermaker                    = { 100993,  451757, 1 }, -- Casting Combustion grants Lit Fuse and Living Bomb's damage is increased by $s1% while under the effects of Combustion
    critical_mass                  = { 101029,  117216, 1 }, -- Your spells have a $s1% increased chance to deal a critical strike. You gain $s2% more of the Critical Strike stat from all sources
    deep_impact                    = { 101000,  416719, 1 }, -- Meteor now turns $s1 target hit into a Living Bomb. Additionally, its cooldown is reduced by $s2 sec
    explosive_ingenuity            = { 101013,  451760, 1 }, -- Your chance of gaining Lit Fuse when consuming Hot Streak is increased by $s1%. Living Bomb damage increased by $s2%
    feel_the_burn                  = { 101014,  383391, 1 }, -- Fire Blast and Phoenix Flames increase your mastery by $s1% for $s2 sec. This effect stacks up to $s3 times
    fervent_flickering             = { 101027,  387044, 1 }, -- Fire Blast's cooldown is reduced by $s1 sec
    fevered_incantation            = { 101019,  383810, 2 }, -- Each consecutive critical strike you deal increases critical strike damage you deal by $s1%, up to $s2% for $s3 sec
    fiery_rush                     = { 101003,  383634, 1 }, -- While Combustion is active, your Fire Blast and Phoenix Flames recharge $s1% faster
    fire_blast                     = { 100989,  108853, 1 }, -- Blasts the enemy for $s$s2 Fire damage. Fire: Castable while casting other spells. Always deals a critical strike
    firefall                       = { 100996,  384033, 1 }, -- Damaging an enemy with $s1 Fireballs or Pyroblasts causes your next Fireball or Pyroblast to call down a Meteor on your target
    fires_ire                      = { 101004,  450831, 2 }, -- When you're not under the effect of Combustion, your critical strike chance is increased by $s1%. While you're under the effect of Combustion, your critical strike damage is increased by $s2%
    firestarter                    = { 102014,  205026, 1 }, -- Your Fireball and Pyroblast spells always deal a critical strike when the target is above $s1% health
    flame_accelerant               = { 102012,  453282, 1 }, -- Every $s1 seconds, your next non-instant Fireball, Flamestrike, or Pyroblast has a $s2% reduced cast time
    flame_on                       = { 101009,  205029, 1 }, -- Increases the maximum number of Fire Blast charges by $s1
    flame_patch                    = { 101021,  205037, 1 }, -- Flamestrike leaves behind a patch of flames that burns enemies within it for $s$s2 Fire damage over $s3 sec. Deals reduced damage beyond $s4 targets
    from_the_ashes                 = { 100999,  342344, 1 }, -- Phoenix Flames damage increased by $s1% and your direct-damage spells reduce the cooldown of Phoenix Flames by $s2 sec
    heat_shimmer                   = { 102010,  457735, 1 }, -- Scorch damage increased by $s1%. Damage from Ignite has a $s2% chance to make your next Scorch deal damage as though your target was below $s3% health
    hyperthermia                   = { 101942,  383860, 1 }, -- While Combustion is not active, consuming Hot Streak has a low chance to cause all Pyroblasts and Flamestrikes to have no cast time and be guaranteed critical strikes for $s1 sec. Each cast of Pyroblast or Flamestrike during Hyperthermia increases the damage of Pyroblast and Flamestrike by $s2%, up to $s3%
    improved_combustion            = { 101007,  383967, 1 }, -- Combustion grants mastery equal to $s1% of your Critical Strike stat and lasts $s2 sec longer
    improved_scorch                = { 101011,  383604, 1 }, -- Casting Scorch on targets below $s1% health increase the target's damage taken from you by $s2% for $s3 sec. This effect stacks up to $s4 times
    inflame                        = { 102013,  417467, 1 }, -- Hot Streak increases the amount of Ignite damage from Pyroblast or Flamestrike by an additional $s1%
    intensifying_flame             = { 101017,  416714, 1 }, -- While Ignite is on $s1 or fewer enemies it flares up dealing an additional $s2% of its damage to affected targets
    kindling                       = { 101024,  155148, 1 }, -- Your Fireball, Pyroblast, Fire Blast, Scorch and Phoenix Flames critical strikes reduce the remaining cooldown on Combustion by $s1 sec. Flamestrike critical strikes reduce the remaining cooldown of Combustion by $s2 sec for each critical strike, up to $s3 sec
    lit_fuse                       = { 100994,  450716, 1 }, -- Consuming Hot Streak has a $s2% chance to grant you Lit Fuse.  Lit Fuse: Your next Fire Blast turns up to $s5 nearby target into a Living Bomb that explodes after $s6 sec, dealing $s$s7 Fire damage to the target and reduced damage to all other enemies within $s8 yds. Up to $s9 enemies hit by this explosion also become a Living Bomb, but this effect cannot spread further
    majesty_of_the_phoenix         = { 101008,  451440, 1 }, -- Casting Phoenix Flames causes your next Flamestrike to have its critical strike chance increased by $s1% and critical strike damage increased by $s2%. Stacks up to $s3 times
    mark_of_the_firelord           = { 100988,  450325, 1 }, -- Flamestrike and Living Bomb apply Mastery: Ignite at $s1% increased effectiveness
    master_of_flame                = { 101006,  384174, 1 }, -- Ignite deals $s1% more damage and Fireball deals $s2% more damage while Combustion is not active. Fire Blast spreads Ignite to $s3 additional nearby targets during Combustion
    meteor                         = { 101016,  153561, 1 }, -- Calls down a meteor which lands at the target location after $s3 sec, dealing $s$s4 Fire damage to all enemies, and burns the ground, dealing $s$s5 Fire damage over $s6 sec to all enemies in the area. The enemy closest to the center of the Meteor's impact takes $s7% increased damage. Damage reduced beyond $s8 targets
    molten_fury                    = { 101015,  457803, 1 }, -- Damage dealt to targets below $s1% health is increased by $s2%
    phoenix_flames                 = { 101012,  257541, 1 }, -- Hurls a Phoenix that deals $s$s2 Fire damage to the target and reduced damage to other nearby enemies. Always deals a critical strike
    phoenix_reborn                 = { 101943,  453123, 1 }, -- When your direct damage spells hit an enemy $s1 times, gain $s2 stack of Born of Flame.  Born of Flame Phoenix Flames refunds a charge on use and its damage is increased by $s5%
    pyroblast                      = { 100998,   11366, 1 }, -- Hurls an immense fiery boulder that causes $s$s2 Fire damage
    pyromaniac                     = { 101020,  451466, 1 }, -- Casting Pyroblast or Flamestrike while Hot Streak is active has a $s1% chance to repeat the spell cast at $s2% effectiveness. This effect counts as consuming Hot Streak
    pyrotechnics                   = { 100997,  157642, 1 }, -- Each time your Fireball fails to critically strike a target, it gains a stacking $s1% increased critical strike chance. Effect ends when Fireball critically strikes
    quickflame                     = { 101021,  450807, 1 }, -- Flamestrike damage increased by $s1%
    scald                          = { 101011,  450746, 1 }, -- Scorch deals $s1% increased damage to targets below $s2% health
    scorch                         = { 100987,    2948, 1 }, -- Scorches an enemy for $s$s2 Fire damage. When cast on a target below $s3% health, Scorch is a guaranteed critical strike and increases your movement speed by $s4% for $s5 sec. Castable while moving
    sparking_cinders               = { 102011,  457728, 1 }, -- Living Bomb explosions have a small chance to increase the damage of your next Pyroblast by $s1% or Flamestrike by $s2%
    spontaneous_combustion         = { 101007,  451875, 1 }, -- Casting Combustion refreshes up to $s1 charges of Fire Blast and up to $s2 charges of Phoenix Flames
    sun_kings_blessing             = { 101025,  383886, 1 }, -- After consuming $s1 Hot Streaks, your next non-instant Pyroblast or Flamestrike cast within $s2 sec grants you Combustion for $s3 sec and deals $s4% additional damage
    surging_blaze                  = { 101023,  343230, 1 }, -- Pyroblast and Flamestrike's cast time is reduced by $s1 sec and their damage dealt is increased by $s2%
    unleashed_inferno              = { 101025,  416506, 1 }, -- While Combustion is active your Fireball, Pyroblast, Fire Blast, Scorch, and Phoenix Flames deal $s1% increased damage and reduce the cooldown of Combustion by $s2 sec. While Combustion is active, Flamestrike deals $s3% increased damage and reduces the cooldown of Combustion by $s4 sec for each critical strike, up to $s5 sec
    wildfire                       = { 101001,  383489, 1 }, -- Your critical strike damage is increased by $s1%. When you activate Combustion, you gain $s2% additional critical strike damage, and up to $s3 nearby allies gain $s4% critical strike for $s5 sec

    -- Frostfire
    elemental_affinity             = {  94633,  431067, 1 }, -- The cooldown of Frost spells with a base cooldown shorter than $s1 minutes is reduced by $s2%
    excess_fire                    = {  94637,  438595, 1 }, -- Casting Meteor causes your next Fire Blast to explode in a Frostfire Burst, dealing $s$s2 Frostfire damage to nearby enemies. Damage reduced beyond $s3 targets. Frostfire Burst reduces the cooldown of Phoenix Flames by $s4 sec
    excess_frost                   = {  94639,  438600, 1 }, -- Consuming Excess Fire causes your next Phoenix Flames to also cast Ice Nova at $s1% effectiveness. Ice Novas cast this way do not freeze enemies in place. When you consume Excess Frost, the cooldown of Meteor is reduced by $s2 sec
    flame_and_frost                = {  94633,  431112, 1 }, -- Cauterize resets the cooldown of your Frost spells with a base cooldown shorter than $s1 minutes when it activates
    flash_freezeburn               = {  94635,  431178, 1 }, -- Frostfire Empowerment grants you maximum benefit of Frostfire Mastery, refreshes its duration, and grants you Excess Frost and Excess Fire. Casting Combustion or Icy Veins grants you Frostfire Empowerment
    frostfire_bolt                 = {  94641,  431044, 1 }, -- Launches a bolt of frostfire at the enemy, causing $s$s3 Frostfire damage, slowing movement speed by $s4%, and causing an additional $s$s5 Frostfire damage over $s6 sec. Frostfire Bolt generates stacks for both Fire Mastery and Frost Mastery
    frostfire_empowerment          = {  94632,  431176, 1 }, -- Your Frost and Fire spells have a chance to activate Frostfire Empowerment, causing your next Frostfire Bolt to be instant cast, deal $s1% increased damage, explode for $s2% of its damage to nearby enemies
    frostfire_infusion             = {  94634,  431166, 1 }, -- Your Frost and Fire spells have a chance to trigger an additional bolt of Frostfire, dealing $s1 damage. This effect generates Frostfire Mastery when activated
    frostfire_mastery              = {  94636,  431038, 1 }, -- Your damaging Fire spells generate $s1 stack of Fire Mastery and Frost spells generate $s2 stack of Frost Mastery. Fire Mastery increases your haste by $s3%, and Frost Mastery increases your Mastery by $s4% for $s5 sec, stacking up to $s6 times each. Adding stacks does not refresh duration
    imbued_warding                 = {  94642,  431066, 1 }, -- Blazing Barrier also casts an Ice Barrier at $s1% effectiveness
    isothermic_core                = {  94638,  431095, 1 }, -- Comet Storm now also calls down a Meteor at $s1% effectiveness onto your target's location. Meteor now also calls down a Comet Storm at $s2% effectiveness onto your target location
    meltdown                       = {  94642,  431131, 1 }, -- You melt slightly out of your Ice Block and Ice Cold, allowing you to move slowly during Ice Block and increasing your movement speed over time. Ice Block and Ice Cold trigger a Blazing Barrier when they end
    severe_temperatures            = {  94640,  431189, 1 }, -- Casting damaging Frost or Fire spells has a high chance to increase the damage of your next Frostfire Bolt by $s1%, stacking up to $s2 times
    thermal_conditioning           = {  94640,  431117, 1 }, -- Frostfire Bolt's cast time is reduced by $s1%

    -- Sunfury
    burden_of_power                = {  94644,  451035, 1 }, -- Conjuring a Spellfire Sphere increases the damage of your next Pyroblast by $s1% or your next Flamestrike by $s2%
    codex_of_the_sunstriders       = {  94643,  449382, 1 }, -- Over its duration, your Arcane Phoenix will consume each of your Spellfire Spheres to cast an exceptional spell. Upon consuming a Spellfire Sphere, your Arcane Phoenix will grant you Lingering Embers.  Lingering Embers Increases your spell damage by $s3%
    glorious_incandescence         = {  94645,  449394, 1 }, -- Consuming Burden of Power causes your next cast of Fire Blast to strike up to $s1 additional targets and call down a storm of $s2 Meteorites on its target. Each Meteorite's impact reduces the cooldown of Fire Blast by $s3 sec
    gravity_lapse                  = {  94651,  458513, 1 }, -- Your Supernova becomes Gravity Lapse. Gravity Lapse
    ignite_the_future              = {  94648,  449558, 1 }, -- Generating a Spellfire Sphere while your Phoenix is active causes it to cast an exceptional spell. Mana Cascade can now stack up to $s1 times
    invocation_arcane_phoenix      = {  94652,  448658, 1 }, -- When you cast Combustion, summon an Arcane Phoenix to aid you in battle.  Arcane Phoenix Your Arcane Phoenix aids you for the duration of your Combustion, casting random Arcane and Fire spells
    lessons_in_debilitation        = {  94651,  449627, 1 }, -- Your Arcane Phoenix will Spellsteal when it is summoned and when it expires
    mana_cascade                   = {  94653,  449293, 1 }, -- Consuming Hot Streak grants you $s1% Haste for $s2 sec. Stacks up to $s3 times. Multiple instances may overlap
    memory_of_alar                 = {  94646,  449619, 1 }, -- While under the effects of a casted Combustion, you gain twice as many stacks of Mana Cascade. When your Arcane Phoenix expires, it empowers you, granting Hyperthermia for $s1 sec, plus an additional $s2 sec for each exceptional spell it had cast.  Hyperthermia: Pyroblast and Flamestrike have no cast time, are guaranteed to critically strike, and increase the damage of Pyroblast and Flamestrike by $s5%
    merely_a_setback               = {  94649,  449330, 1 }, -- Your Blazing Barrier now grants $s1% avoidance while active and $s2% leech for $s3 sec when it breaks or expires
    rondurmancy                    = {  94648,  449596, 1 }, -- Spellfire Spheres can now stack up to $s1 times
    savor_the_moment               = {  94650,  449412, 1 }, -- When you cast Combustion, its duration is extended by $s1 sec for each Spellfire Sphere you have, up to $s2 sec
    spellfire_spheres              = {  94647,  448601, 1 }, -- Every $s1 times you consume Hot Streak, conjure a Spellfire Sphere. While you're out of combat, you will slowly conjure Spellfire Spheres over time.  Spellfire Sphere Increases your spell damage by $s4%. Stacks up to $s5 times
    sunfury_execution              = {  94650,  449349, 1 }, -- Scorch's critical strike threshold is increased to $s2%.  Scorch Scorches an enemy for $s$s5 Fire damage. When cast on a target below $s6% health, Scorch is a guaranteed critical strike and increases your movement speed by $s7% for $s8 sec. Castable while moving
} )

-- PvP Talents
spec:RegisterPvpTalents( {
    ethereal_blink                 = 5602, -- (410939) Blink and Shimmer apply Slow at $s1% effectiveness to all enemies you Blink through. For each enemy you Blink through, the cooldown of Blink and Shimmer are reduced by $s2 sec, up to $s3 sec
    glass_cannon                   = 5495, -- (390428) Increases damage of Fireball, Scorch, and Ignite by $s1% but decreases your maximum health by $s2%
    greater_pyroblast              =  648, -- (203286) Hurls an immense fiery boulder that deals up to $s1% of the target's total health in Fire damage
    ice_wall                       = 5489, -- (352278) Conjures an Ice Wall $s1 yards long that obstructs line of sight. The wall has $s2% of your maximum health and lasts up to $s3 sec
    ignition_burst                 = 5685, -- (1217359) Heat Shimmer now additionally causes your next Scorch to become instant cast and cast at $s1% effectiveness
    improved_mass_invisibility     = 5621, -- (415945) The cooldown of Mass Invisibility is reduced by $s1 min and can affect allies in combat
    master_shepherd                = 5588, -- (410248) While an enemy player is affected by your Polymorph or Mass Polymorph, your movement speed is increased by $s1% and your Versatility is increased by $s2%. Additionally, Polymorph and Mass Polymorph no longer heal enemies
    overpowered_barrier            = 5706, -- (1220739) Your barriers absorb $s1% more damage and have an additional effect, but last $s2 sec.  Blazing Barrier Reflects $s5% of damage absorbed
    ring_of_fire                   = 5389, -- (353082) Summons a Ring of Fire for $s1 sec at the target location. Enemies entering the ring are disoriented and burn for $s2% of their total health over $s3 sec
    world_in_flames                =  644, -- (203280) Empower Flamestrike, dealing up to $s1% more damage based on enemies' distance to the center of Flamestrike
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
    -- Hyperthermia Pyroblast and Flamestrike damage increased by $s1%. $s2 seconds remaining
    -- https://www.wowhead.com/spell=1242220
    hyperthermia_damage = {
        id = 1242220,
        duration = 5,
        max_stack = 10
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

spec:RegisterGear({
    -- The War Within
    tww3 = {
        items = { 237721, 237719, 237718, 237716, 237717 },
        auras = {
            -- Sunfury
            flame_quills = {
                id = 1236145,
                duration = 13,
                max_stack = 1
            },
            lesser_time_warp = {
                id = 1236231,
                duration = 13,
                max_stack = 1
            },
        }
    },
    tww2 = {
        items = { 229346, 229344, 229342, 229343, 229341 },
        auras = {
            rollin_hot = {
                id = 1219035,
                duration = 15,
                max_stack = 1
            }
        }
    },
    -- Dragonflight
    tier31 = {
        items = { 207288, 207289, 207290, 207291, 207293 },
        auras = {
            searing_rage = {
                id = 424285,
                duration = 12,
                max_stack = 5
            }
        }
    },
    tier30 = {
        items = { 202554, 202552, 202551, 202550, 202549, 217232, 217234, 217235, 217231, 217233 },
        auras = {
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
        }
    },
    tier29 = {
        items = { 200318, 200320, 200315, 200317, 200319 }
    }
} )

local TriggerHyperthermia = setfenv( function()

    local mod = 1

    if set_bonus.tww3 >= 4 then
        mod = 1.3
        applyBuff( "lesser_time_warp" )
        applyBuff( "flame_quills" )
    end

    if buff.hyperthermia.up then
        buff.hyperthermia.expires = buff.hyperthermia.expires + 2 + ( buff.lingering_embers.stacks * mod )
    else
        applyBuff( "hyperthermia", 2 + ( buff.lingering_embers.stacks * mod ) )
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
        id = 342245,
        cast = 0,
        cooldown = function () return talent.master_of_time.enabled and 50 or 60 end,
        gcd = "off",
        school = "arcane",

        texture = 609811,

        spend = 0.01,
        spendType = "mana",
        nobuff = "alter_time",

        talent = "alter_time",
        startsCombat = false,

        toggle = "defensives",

        handler = function ()
            applyBuff( "alter_time" )
            setCooldown( "alter_time_return", 0 )
        end,

        copy = { 342247, 342245 }
    },

    alter_time_return = {
        id = 342247,
        cast = 0,
        cooldown = function () return talent.master_of_time.enabled and 50 or 60 end,
        gcd = "off",
        school = "arcane",

        texture = 985088,

        spend = 0.01,
        spendType = "mana",
        buff = "alter_time",

        talent = "alter_time",
        startsCombat = false,

        toggle = "defensives",

        handler = function ()
            removeBuff( "alter_time" )
            if talent.master_of_time.enabled then setCooldown( "blink", 0 ) end
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

        -- FIXME: Skeleton Generator strange edgecase doesn't find this talent
        -- talent = "blazing_barrier",
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
                reduceCooldown( "combustion", 2 )
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

spec:RegisterPack( "Fire", 20251008, [[Hekili:TZvBVnUns4FlgfW1o7AhBN4SzxKSh617oCDrrrbspSFZYYY02crwYNOuYMdb(3(nKuVqsrsr5iLnfOaBBsKiN3i5mpC4qTy6I)yXDRDtql(TztMnF6KjxpE2fx(HjZxCxYthqlU7GR39UBHFj0Dp8))x(X0h(uqK7AsNXrPXEWJ2LKCa)PZpFRFYU0vJ9I2Fo2FFAGBIFuOxS7MeYF7D(QGOvNNSd9OB8Jqt9dp)N8in53J9JI9tE6x9Xj4ZxJ24MgKC(EG1oBaEoM05f3Tk1pi5xcxSsLuF18lwCNBAYUO4f3DN)(FgKk)1RrSMJWq)hn64Y)yh64YV6gd)pQaCC5DixCe8Zlo(fc9gnDYOjx)PJl)PF)xHx(uOx2ZNC9OjZHNdgbCc71F54xmtZz599c4FqF)JV(v(xUm9arrOn6YrtNoA283FC50zJMCf0yIsi1eqgMsAYKpoAYhz)C6KSFM98zZY(51AiXhgn7JFQQqV4UaIXNmQUzdy1dcqXWF8B0jjOq3vbO1l(7lUlfJCECNFaYXZfN4hUL0K78GrpuSVlzqAZMX7qUKx5KEyC6HJl7FCPlDCEmz0CLBqWy03qEPK2y4TiNy0Ex)q8XL3a604502oG(pVOOG1rpgsMRTkft7ErR)8XLp4csdiZJpanKikj(7bfE4XLp)8XLjUbOWKX40qN7HxIDGwIXWVnottHwYu1iWyS1BnvjzsjyFaXe6bO(lsGjHTQb6WtXrusR2cj)6kMiBL6lAOu374sMGhL4GtIrU3Nl4fVrNkH9II92PwFeE3FogVVS1SC52GD(BOwUdrpIILStV10(5TM2dQv5dDWhqbbyh)qNnb(B3boyFN65v3qDCoKsc27HivXqmL49(U50g0HX8ZLi)9E3V9M0IELKfT0296jP5s2EuccIFcs1hmjv(7peh9aATt2Yxs3FaXyyXyMdmVE)EycD2ysMKi33sXG2Q1ikbKBf)G5fhxEM4qkmj7qm6bIHE80mFkLkv2Fdk11Avkkt3Kg)emG5atMCYny8RvFa5Gcr79red)TCw(IaMWKxaOemL2)Ee34n3dbP4JMLcvZNBrUpDIw2xXgYTitPZ92sKKXyiBru65STyUC8B7MuusVIqYuQjhx18GRoQihJP5Jr6OSS)BtMAD0qVhR68vbt(kxwke2Jsy9oDSWnwUzytCeoH6IfTNs69KEYRn5WmP8uVpHbzee9npGxou6sNaARF1CFtdkb4wiBRIcsgt8u7aDYdvI4HZB8HDrOq)VLnnMkT69DyHaXc(XM24Kb5YcF3dv5kDg1nsflkNSrMRCx2w5uTrcYEYI9pWiW)KjnGqIEaf)eyFPbXsiBsbyseSnfFykK7dU(b0f5L82lkneSbmeeQaKlagzGw8ikwzXP5EG25W(dhYgLyBxYHTVyV1yvyQRm4in8ZpW0ZaAM6abCdV3VYg4aAebuwgGGIbyosin8gdtE0PJGx1YoQchScmFk0f(HafVM(cYexyaLU64r3ywiNHVDmfyztHENQgh4TJBL7gxbyrBiaMJaj0iieP3TCrzorCJ9Cdrag8eyLeYlrC1CL1vrGlvmkPS)5gEYVfKc)yY4z0NMVmHmcKnurhjuTOPEQoDopaqEgWJaw1uulO9Kjny4RKZcRoCKGyip9OtfdfqFumVXkr44Yr0vCZNqn4zsXE347ZbereMGO41cb9yD6Yl570)n137EQmjSVJQHVioXPQi(a4zaHvPLytgBzmeVcA6SUutvpEkJAXcTCgVqGaX8Wb06XKqGEa)JsHLKXUH49(jqB4fcnnXPWrcDR)Q2zJX(xkR6AGQDRuVIwOABdCx77cyhaSqUR3M53VonxQv7JIcd8taL1hVx6D(X(RrPeKHUBjGmLEn(qKFaMmbkefKSZnofllcGFQvuXG61YnGKwyHwSlkoKqbq3i51waZ0x3HirpburhxMIj2aaKucAp5ViZ6sIyr5oU8NlwTWGrvqEbVZLlPG)bKq5wZmA)ZjfR)oaIUOnB4N2Pk0CgZe1T)D0JhxcMJTGkG2efJevc8UO0aIkg7hEpkbtqk6Mq)7TBZmjyWItmdEUjOTremL5ihoUKqJiMXRKeHrjeUXmF)TI5tas3ITjMR079JJJID83tpCeHOKg2bOLGbeFFn7hSxHJhspWjUXjKCikttr8kSDbwSnJIn3jJExeOZjCya5B7rDw)hyxI)lN0iJFOilxzKrzMMhytYMnYd9zYt0SEsNeGeeugezt6tV6omLE1Eyc6tkRqItRprQLZ(2c(N8jUsHDZ6gswlJGT1wgcSaYTMgMVVApyv7we1NkvhCdyjoy8hudBNx4gWjFNvqk6KKHVKuopKL1zBtOBtpAfntdmFOkVwNtutpTJtszEzNkOTQstp6c9lp1On1FspN8jHzRoQp1CYAdlqy2wQl3AmjtQflIil40OuktkK(83PI7ksFKcKTVSCbRFRcLm32SZBBQx7cPYqw7TpVT6tZUTQMokRpLBN0Pfz9rbDPyMaQoJKHgRqOftOQeWTl5BA(Hij2ebCtAt6jjDGkalv)wxQjnHNPeYe3I3ZYdkBYKxbpehb4JWZIA(odT(S8dtvBle8MWgv1jAfSRU9hBTDObkAF1o5Y8)LlrvpWY216yYDBE(g0duvZE54Z8PkqQCBpHkuGmnPgOwaESRYAseMHtCdbaLqqRlMZTUlI(tfyJYBHBS7)d7aIsQBGdSFpY2Q0h9OzscSbUSmrOGlkG4KltHO0yOD4NcDpGjUY35civJ7cbthRuGAjx6KZUr7kwOnBqE5jqUcRua0OWVP)2qusEwZoqQRVNAxrllZyQ4JciifYvA4QGOO1oqVt29ezZUDGqvHjka0Klrb(bfhSmceeyRoopICFOLhjzsMEMPaYtraU0WDreCNG7pCxivImqfmNCrbqgGcw7cZatIirCBlzbIONjlsCqfEjoSzXOW1ryNd(bGFA6UhBpzIZ(OKrQaCLlAmZjmq75gVUtgZK4GQmEvSMlkniaLqHpgNUQB8diZdvPllxGO5M)r4)CiPEiaWxd)ExivQzubcsvdCSddfc4V25XyFCYJXqOaEztDlgxU)pgGIzLOzuPiIBRM1XXfzkHe8VyGwTeruIR4HbtMoqs7Cf802VBWMBMlWnaHjbysG3mV6lOJ2JTRqXyumPolOSSMk6QDyjnWcPAKOO4Qz)GNml5Rqhk0AcBxKNn43MLfUTjhPP5N97xnpxxDu9GQA(0wZqtZpz9P1Yubm3PQstZozNwnYARRLYeDCcv8YBZmWlOj8IxT5GVtNp00u8sOICw6MjUcVlMPu3WqxBMmwY5DWCyvMz(KH2GY1Tgqfnp9WnG36rwyB(tBBjQPLs(jnkYLhhHK((NGusxSteXAnwcOAD1STy6P5OAzAM1Fa9kDXWVX28BCrTLMT4ejYqzvK8e06pj8sXCEpwR395CZowLv1jSYysWgxTKK17mrzLgR089b(blT5vFZlTCeKHgxCgyMHH261PaBqFmxqdbUi)6tKl6oI4bwEkX2ZP)QUleBqNx3fNcaKH5yq4eeTxUf7Wr00DsOXWBERu)vLo0yvPPWG1VGqJ2u)wcp59)ARowtLo8sUlFn8S5RbsAZUaz2N9kwWR6oOoLqnSpFvfrivDflPVq35z2NBdXNWTbLOxApQyLyiSpJy6l(K2)Mi2W5sgQKcBbe3jIvDqKTbR)3Tl1yLlWx)8uNujgcxyuYmqnEanFh9UYgWSaC2hqXysBOFgtMCn5RUcSJRqGp4f3r)8CalaIIbrzd5(V9Jz3LUF84YysbCtlUzCezHNBAs0Ex61NdW3hc47hF8l)QFi8QPF64Y)tio9aHsKgWemGCc3BUFCm5JzYVSpVvFOSH0pliWRjdtrWEtHzj)Wpae9aDaFpq)xJV(lh)cHP3vq2FMqwArHV3pH9DAbKKPUt3C11Ryn(FawKprsIo5dWYhhn7JevKPv4XfxEHBLV1tkAZ7U988fpVNC4i3wbT67PvWZTtgpZMUZNZMSEoD(z5UoTGaAxb)E)n3QSkIYzZKjws)QzHOLOT2IFJJ(vk(NswmAW8jNz4c6mC0GlV8SkxgNHwkAgv7xOyn7efl7Uao5YYmIax7TCrjBZpkpJSfwCDCzlC3tSrZ5MOWUMizkP274ZZpxNMZ1cH72d3ZLVxpCVsXD6HNLvVppCVv4U8qTIF)VLl2miiCBEYgaMnHmlt)15rnD5V2mQBHKJfDECu35sPG0XEvVxmQ7wr0Fs8byuPX3f9cYsLbUOQcVq6cKNnbFnMkRdQcJQFfurd5PN0n(vrCbTwV(9yCtmhW9hy4mhUr5ynFTf(8Zv3fz9cmwwGvlA52hPhtFOImwp87IUue0S(PTgmhmsWdvbMJyYXiVGNT6ujZpBaJGkQy2Zg0t9ETE(58ojx9Q3KHwz4W3PPfNnqxF)8T5DUVA2cevxexJArTcB)QlZE(5Ec137lsFaIvLddhoYqAoLgMzLklDge82BNuDQywV)8vWRIW4(c1WXnxmxMIIb1RwcSeE1mEmBIzEOPAwBvgXvGQ3kdcOvzeBDPIQnTd4IC5J2(SqBDG2(SsO4oBFYlwVMnN(tRzHIYAVS5SPo1qSCkBF6lxFKTphuwRJTpBuxoIe(uBHr(5BN1xJW0NlAIyXqERw5bl)cXIqSnu9Y6lSvOwrPd2guJg4LqXMtSPtyzMrKG(HpeDp4o6Bz(Ji0mppjpci78d3Kssuwb)eFmnDU9hyqsK0O5dBMuSk7dPfzvkoLKe7cjP6RyzmNd9MaKCXnPWDqh3o99voKg4zkSWuTvgduX5S0Vc8iPJz5g9qra0lzDw(aOlOQUtM2kQQ4G8kiS2tXZkklFAt9hO6fwrt9dCLUioTboY2y0jV90pG2ZG1tbyZ(CNCm)VNdbU)adND87y0Jpz3dVzwgB0DIADPbRQ803G5O25sKYR97J4QyGTUfQDTW2tH0QAcLU5SMxIzw6fZUQPPxu2uEswF(26pfl98TyMrDCvpjyEa15yw)U1MPNKmlOwF99QKhO(v35zw8pPtATV6tz95N1STBZZ3wPbCdlIxtgRRobRTgHL4wvtNMLOTf)Rodt8iJTRJ2i2giLWrswiisNcA)bvJSueiOipgcHcQF6HeWhwUSov3vTOJ0(dmLqWpRSyQb4f5jgQY3u1HDTA2kH3oz5svyavHlo5qdVrhpmf(tZDC5prAsdr(DZS80LkL1DLOkFvScLbFFD4xzK5b6YpEdc7oSV5VOj3CrEjaOiMVMPfTeqQQN6T98tE6rhWhBIh2f8THGvSLlNgmudDx(2CuF3SXIAbzQbHt5cjbVNKEAA570j6DcMdcv7szMIO7JaVgDQcIPbQGmzYbs)EfzEr334DsGVAD0OxVgWAK01PqThidrrKHPHFH5NkxR7Our1jP2rwNBA0v5Da9wj1o9mEvqZMQO9Eh(8ZvVCqFE64pODtT3miJZNL1XHdBkiJH3mRthw6se2VQI7PTVNovyFftGKS0xtktgunbjQpzEZ2h7s4rLEE6yi0wAKwZnBIR3Q83A4ag7OnITnZgAem9AXJFz1sYTIwiGCOorS(PBsrMp59)1PosozPQ7ZRqJ3vy3Py5cRUeh8gsuByqBsMbuwqE5RZSUm9E9rXO6dxHkCmFNgDKDnptze1ty8YSrR1uxXOrTZKetHRmTLBdcwddkFICXMOATcFRnJan0MBnx0gQVnY6awBce00grqHsr7v3NYmkwzLNg9r9HRiOcfBETC1)ys1j9uzPqu3hLbWJ18Sbn5pgd1P8kttGEVtSlNg4fXBXVD1f0BM2I))d]] )