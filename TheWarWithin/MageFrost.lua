-- MageFrost.lua
-- August 2025
-- Patch 11.2

if UnitClassBase( "player" ) ~= "MAGE" then return end

local addon, ns = ...
local Hekili = _G[ addon ]
local class, state = Hekili.Class, Hekili.State
local spec = Hekili:NewSpecialization( 64 )

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
local GetPlayerAuraBySpellID = C_UnitAuras.GetPlayerAuraBySpellID
local FindUnitBuffByID, FindUnitDebuffByID = ns.FindUnitBuffByID, ns.FindUnitDebuffByID
-- local IsSpellOverlayed = C_SpellActivationOverlay.IsSpellOverlayed
-- local IsSpellKnownOrOverridesKnown = C_SpellBook.IsSpellInSpellBook
-- local IsActiveSpell = ns.IsActiveSpell

-- Specialization-specific local functions (if any)

-- spec:RegisterResource( Enum.PowerType.ArcaneCharges )
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
    energized_barriers             = {  62100,  386828, 1 }, -- When your barrier receives melee attacks, you have a $s1% chance to be granted Fingers of Frost. Casting your barrier removes all snare effects
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
    mass_barrier                   = {  62092,  414660, 1 }, -- Cast Ice Barrier on yourself and $s1 allies within $s2 yds
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
    time_manipulation              = {  62129,  387807, 1 }, -- Casting Ice Lance on Frozen targets reduces the cooldown of your loss of control abilities by $s1 sec
    tome_of_antonidas              = {  62098,  382490, 1 }, -- Increases Haste by $s1%
    tome_of_rhonin                 = {  62127,  382493, 1 }, -- Increases Critical Strike chance by $s1%
    volatile_detonation            = {  62089,  389627, 1 }, -- Greatly increases the effect of Blast Wave's knockback. Blast Wave's cooldown is reduced by $s1 sec
    winters_protection             = {  62123,  382424, 2 }, -- The cooldown of Ice Block is reduced by $s1 sec

    -- Frost
    bone_chilling                  = {  62167,  205027, 1 }, -- Whenever you attempt to chill a target, you gain Bone Chilling, increasing spell damage you deal by $s1% for $s2 sec, stacking up to $s3 times
    brain_freeze                   = {  62179,  190447, 1 }, -- Frostbolt has a $s1% chance to reset the remaining cooldown on Flurry and cause your next Flurry to deal $s2% increased damage
    chain_reaction                 = {  62161,  278309, 1 }, -- Your Ice Lances against frozen targets increase the damage of your Ice Lances by $s1% for $s2 sec, stacking up to $s3 times
    cold_front                     = {  62155,  382110, 1 }, -- Casting $s1 Frostbolts or Flurries summons a Frozen Orb that travels toward your target. Hitting an enemy player counts as double
    coldest_snap                   = {  62185,  417493, 1 }, -- Cone of Cold's cooldown is increased to $s1 sec and if Cone of Cold hits $s2 or more enemies it resets the cooldown of Frozen Orb and Comet Storm. In addition, Cone of Cold applies Winter's Chill to all enemies hit. Cone of Cold's cooldown can no longer be reduced by your cooldown reduction effects
    comet_storm                    = {  62182,  153595, 1 }, -- Calls down a series of $s2 icy comets on and around the target, that deals up to $s$s3 Frost damage to all enemies within $s4 yds of its impacts
    cryopathy                      = {  62152,  417491, 1 }, -- Each time you consume Fingers of Frost the damage of your next Ray of Frost is increased by $s1%, stacking up to $s2%. Icy Veins grants $s3 stacks instantly
    deaths_chill                   = { 101302,  450331, 1 }, -- While Icy Veins is active, damaging an enemy with Frostbolt increases spell damage by $s1%. Stacks up to $s2 times
    deep_shatter                   = {  62159,  378749, 2 }, -- Your Frostbolt deals $s1% additional damage to Frozen targets
    everlasting_frost              = {  81468,  385167, 1 }, -- Frozen Orb deals an additional $s1% damage and its duration is increased by $s2 sec
    fingers_of_frost               = {  62164,  112965, 1 }, -- Frostbolt has a $s1% chance and Frozen Orb damage has a $s2% to grant a charge of Fingers of Frost. Fingers of Frost causes your next Ice Lance to deal damage as if the target were frozen. Maximum $s3 charges
    flash_freeze                   = {  62168,  379993, 1 }, -- Each of your Icicles deals $s1% additional damage, and when an Icicle deals damage you have a $s2% chance to gain the Fingers of Frost effect
    flurry                         = {  62178,   44614, 1 }, -- Unleash a flurry of ice, striking the target $s2 times for a total of $s$s3 Frost damage. Each hit reduces the target's movement speed by $s4% for $s5 sec and applies Winter's Chill to the target. Winter's Chill causes the target to take damage from your spells as if it were frozen
    fractured_frost                = {  62151,  378448, 1 }, -- While Icy Veins is active, your Frostbolts hit up to $s1 additional targets and their damage is increased by $s2%
    freezing_rain                  = {  62150,  270233, 1 }, -- Frozen Orb makes Blizzard instant cast and increases its damage done by $s1% for $s2 sec
    freezing_winds                 = {  62184, 1216953, 1 }, -- Frozen Orb deals $s1% increased damage to units affected by your Blizzard
    frostbite                      = {  81467,  378756, 1 }, -- Gives your Chill effects a $s1% chance to freeze the target for $s2 sec
    frozen_orb                     = {  62177,   84714, 1 }, -- Launches an orb of swirling ice up to $s3 yds forward which deals up to $s$s4 Frost damage to all enemies it passes through over $s5 sec. Deals reduced damage beyond $s6 targets. Grants $s7 charge of Fingers of Frost when it first damages an enemy$s$s8 Enemies damaged by the Frozen Orb are slowed by $s9% for $s10 sec
    frozen_touch                   = {  62180,  205030, 1 }, -- Frostbolt grants you Fingers of Frost $s1% more often and Brain Freeze $s2% more often
    glacial_assault                = {  62183,  378947, 1 }, -- Your Comet Storm now applies Numbing Blast, increasing the damage enemies take from you by $s2% for $s3 sec. Additionally, Flurry has a $s4% chance each hit to call down an icy comet, crashing into your target and nearby enemies for $s$s5 Frost damage
    glacial_spike                  = {  62157,  199786, 1 }, -- Conjures a massive spike of ice, and merges your current Icicles into it. It impales your target, dealing $s$s2 million damage plus all of the damage stored in your Icicles, and freezes the target in place for $s3 sec. Damage may interrupt the freeze effect. Requires $s4 Icicles to cast. : Ice Lance no longer launches Icicles
    hailstones                     = {  62158,  381244, 1 }, -- Casting Ice Lance on Frozen targets has a $s1% chance to generate an Icicle
    ice_caller                     = {  62170,  236662, 1 }, -- Each time Blizzard deals damage, the cooldown of Frozen Orb is reduced by $s1 sec
    ice_lance                      = {  62176,   30455, 1 }, -- Quickly fling a shard of ice at the target, dealing $s$s2 Frost damage. Ice Lance damage is tripled against frozen targets
    icy_veins                      = {  62171,   12472, 1 }, -- Accelerates your spellcasting for $s1 sec, granting $s2% haste and preventing damage from delaying your spellcasts. Activating Icy Veins summons a water elemental to your side for its duration. The water elemental's abilities grant you Frigid Empowerment, increasing the Frost damage you deal by $s3%, up to $s4%
    lonely_winter                  = {  62173,  205024, 1 }, -- Frostbolt, Ice Lance, and Flurry deal $s1% increased damage
    permafrost_lances              = {  62169,  460590, 1 }, -- Frozen Orb increases Ice Lance's damage by $s1% for $s2 sec
    perpetual_winter               = {  62181,  378198, 1 }, -- Flurry now has $s1 charges
    piercing_cold                  = {  62166,  378919, 1 }, -- Frostbolt and Glacial Spike critical strike damage increased by $s1%
    ray_of_frost                   = {  62153,  205021, 1 }, -- Channel an icy beam at the enemy for $s2 sec, dealing $s$s3 Frost damage every $s4 sec and slowing movement by $s5%. Each time Ray of Frost deals damage, its damage and snare increases by $s6%. Generates $s7 charges of Fingers of Frost over its duration
    shatter                        = {  62165,   12982, 1 }, -- Multiplies the critical strike chance of your spells against frozen targets by $s1, and adds an additional $s2% critical strike chance
    slick_ice                      = {  62156,  382144, 1 }, -- While Icy Veins is active, each Frostbolt you cast reduces the cast time of Frostbolt by $s1% and increases its damage by $s2%, stacking up to $s3 times
    splintering_cold               = {  62162,  379049, 2 }, -- Frostbolt and Flurry have a $s1% chance to generate $s2 Icicles
    splintering_ray                = { 103771,  418733, 1 }, -- Ray of Frost deals $s1% of its damage to $s2 nearby enemies
    splitting_ice                  = {  62163,   56377, 1 }, -- Your Ice Lance and Icicles now deal $s1% increased damage, and hit a second nearby target for $s2% of their damage. Your Glacial Spike also hits a second nearby target for $s3% of its damage
    subzero                        = {  62160,  380154, 2 }, -- Your Frost spells deal $s1% more damage to targets that are rooted and frozen
    thermal_void                   = {  62154,  155149, 1 }, -- Icy Veins' duration is increased by $s1 sec. Your Ice Lances against frozen targets extend your Icy Veins by an additional $s2 sec and Glacial Spike extends it an addtional $s3 sec
    winters_blessing               = {  62174,  417489, 1 }, -- Your Haste is increased by $s1%. You gain $s2% more of the Haste stat from all sources
    wintertide                     = {  62172,  378406, 2 }, -- Damage from Frostbolt and Flurry increases the damage of your Icicles and Glacial Spike by $s1%. Stacks up to $s2 times

    -- Frostfire
    elemental_affinity             = {  94633,  431067, 1 }, -- The cooldown of Fire spells is reduced by $s1%
    excess_fire                    = {  94637,  438595, 1 }, -- Casting Comet Storm causes your next Ice Lance to explode in a Frostfire Burst, dealing $s$s2 Frostfire damage to nearby enemies. Damage reduced beyond $s3 targets. Frostfire Burst has an $s4% chance to grant Brain Freeze
    excess_frost                   = {  94639,  438600, 1 }, -- Consuming Excess Fire causes your next Flurry to also cast Ice Nova at $s1% effectiveness. Ice Novas cast this way do not freeze enemies in place. When you consume Excess Frost, the cooldown of Comet Storm is reduced by $s2 sec
    flame_and_frost                = {  94633,  431112, 1 }, -- Cold Snap additionally resets the cooldowns of your Fire spells
    flash_freezeburn               = {  94635,  431178, 1 }, -- Frostfire Empowerment grants you maximum benefit of Frostfire Mastery, refreshes its duration, and grants you Excess Frost and Excess Fire. Casting Combustion or Icy Veins grants you Frostfire Empowerment
    frostfire_bolt                 = {  94641,  431044, 1 }, -- Launches a bolt of frostfire at the enemy, causing $s$s3 Frostfire damage, slowing movement speed by $s4%, and causing an additional $s$s5 Frostfire damage over $s6 sec. Frostfire Bolt generates stacks for both Fire Mastery and Frost Mastery
    frostfire_empowerment          = {  94632,  431176, 1 }, -- Your Frost and Fire spells have a chance to activate Frostfire Empowerment, causing your next Frostfire Bolt to be instant cast, deal $s1% increased damage, explode for $s2% of its damage to nearby enemies
    frostfire_infusion             = {  94634,  431166, 1 }, -- Your Frost and Fire spells have a chance to trigger an additional bolt of Frostfire, dealing $s1 damage. This effect generates Frostfire Mastery when activated
    frostfire_mastery              = {  94636,  431038, 1 }, -- Your damaging Fire spells generate $s1 stack of Fire Mastery and Frost spells generate $s2 stack of Frost Mastery. Fire Mastery increases your haste by $s3%, and Frost Mastery increases your Mastery by $s4% for $s5 sec, stacking up to $s6 times each. Adding stacks does not refresh duration
    imbued_warding                 = {  94642,  431066, 1 }, -- Ice Barrier also casts a Blazing Barrier at $s1% effectiveness
    isothermic_core                = {  94638,  431095, 1 }, -- Comet Storm now also calls down a Meteor at $s1% effectiveness onto your target's location. Meteor now also calls down a Comet Storm at $s2% effectiveness onto your target location
    meltdown                       = {  94642,  431131, 1 }, -- You melt slightly out of your Ice Block and Ice Cold, allowing you to move slowly during Ice Block and increasing your movement speed over time. Ice Block and Ice Cold trigger a Blazing Barrier when they end
    severe_temperatures            = {  94640,  431189, 1 }, -- Casting damaging Frost or Fire spells has a high chance to increase the damage of your next Frostfire Bolt by $s1%, stacking up to $s2 times
    thermal_conditioning           = {  94640,  431117, 1 }, -- Frostfire Bolt's cast time is reduced by $s1%

    -- Spellslinger
    augury_abounds                 = {  94662,  443783, 1 }, -- Casting Icy Veins conjures $s1 Frost Splinters. During Icy Veins, whenever you conjure a Frost Splinter, you have a $s2% chance to conjure an additional Frost Splinter
    controlled_instincts           = {  94663,  444483, 1 }, -- While a target is under the effects of Blizzard, $s1% of the direct damage dealt by a Frost Splinter is also dealt to nearby enemies. Damage reduced beyond $s2 targets
    force_of_will                  = {  94656,  444719, 1 }, -- Gain $s1% increased critical strike chance. Gain $s2% increased critical strike damage
    look_again                     = {  94659,  444756, 1 }, -- Displacement has a $s1% longer duration and $s2% longer range
    phantasmal_image               = {  94660,  444784, 1 }, -- Your Mirror Image summons one extra clone. Mirror Image now reduces all damage taken by an additional $s1%
    reactive_barrier               = {  94660,  444827, 1 }, -- Your Ice Barrier can absorb up to $s1% more damage based on your missing Health. Max effectiveness when under $s2% health
    shifting_shards                = {  94657,  444675, 1 }, -- Shifting Power fires a barrage of $s1 Frost Splinters at random enemies within $s2 yds over its duration
    signature_spell                = {  94657,  470021, 1 }, -- Consuming Winter's Chill with Glacial Spike conjures $s1 additional Frost Splinters
    slippery_slinging              = {  94659,  444752, 1 }, -- You have $s1% increased movement speed during Alter Time
    spellfrost_teachings           = {  94655,  444986, 1 }, -- Direct damage from Frost Splinters reduces the cooldown of Frozen Orb by $s1 sec
    splintering_orbs               = {  94661,  444256, 1 }, -- Enemies damaged by your Frozen Orb conjure $s1 Frost Splinter, up to $s2. Frozen Orb damage is increased by $s3%
    splintering_sorcery            = {  94664,  443739, 1 }, -- When you consume Winter's Chill or Fingers of Frost, conjure a Frost Splinter. Frost Splinter:
    splinterstorm                  = {  94654,  443742, 1 }, -- Whenever you have $s2 or more active Embedded Frost Splinters, you automatically cast a Splinterstorm at your target. Splinterstorm: Shatter all Embedded Frost Splinters, dealing their remaining periodic damage instantly. Conjure a Frost Splinter for each Splinter shattered, then unleash them all in a devastating barrage, dealing $s$s5 Frost damage to your target for each Splinter in the Splinterstorm. Splinterstorm has a $s6% chance to grant Brain Freeze
    unerring_proficiency           = {  94658,  444974, 1 }, -- Each time you conjure a Frost Splinter, increase the damage of your next Ice Nova by $s1%. Stacks up to $s2 times
    volatile_magic                 = {  94658,  444968, 1 }, -- Whenever an Embedded Frost Splinter is removed, it explodes, dealing $s$s2 Frost damage to nearby enemies. Deals reduced damage beyond $s3 targets
} )

-- PvP Talents
spec:RegisterPvpTalents( {
    concentrated_coolness          =  632, -- (198148) Frozen Orb's damage is increased by $s1% and is now castable at a location with a $s2 yard range but no longer moves
    ethereal_blink                 = 5600, -- (410939) Blink and Shimmer apply Slow at $s1% effectiveness to all enemies you Blink through. For each enemy you Blink through, the cooldown of Blink and Shimmer are reduced by $s2 sec, up to $s3 sec
    frost_bomb                     = 5496, -- (390612) Places a Frost Bomb on the target. After $s2 sec, the bomb explodes, dealing $s3 million Frost damage to the target and $s$s4 Frost damage to all other enemies within $s5 yards. All affected targets are slowed by $s6% for $s7 sec. If Frost Bomb is dispelled before it explodes, gain a charge of Brain Freeze
    ice_form                       =  634, -- (198144) Your body turns into Ice, increasing your Frostbolt damage done by $s1% and granting immunity to stun and knockback effects. Lasts $s2 sec
    ice_wall                       = 5390, -- (352278) Conjures an Ice Wall $s1 yards long that obstructs line of sight. The wall has $s2% of your maximum health and lasts up to $s3 sec
    icy_feet                       =   66, -- (407581) When your Frost Nova or Water Elemental's Freeze is dispelled or removed, become immune to snares for $s1 sec. This effect can only occur once every $s2 sec
    improved_mass_invisibility     = 5622, -- (415945) The cooldown of Mass Invisibility is reduced by $s1 min and can affect allies in combat
    master_shepherd                = 5581, -- (410248) While an enemy player is affected by your Polymorph or Mass Polymorph, your movement speed is increased by $s1% and your Versatility is increased by $s2%. Additionally, Polymorph and Mass Polymorph no longer heal enemies
    overpowered_barrier            = 5708, -- (1220739) Your barriers absorb $s2% more damage and have an additional effect, but last $s3 sec.  Ice Barrier If the barrier is fully absorbed, enemies within $s6 yds suffer $s$s7 Frost damage and are slowed by $s8% for $s9 sec
    ring_of_fire                   = 5490, -- (353082) Summons a Ring of Fire for $s1 sec at the target location. Enemies entering the ring are disoriented and burn for $s2% of their total health over $s3 sec
    snowdrift                      = 5497, -- (389794) Summon a strong Blizzard that surrounds you for $s2 sec that slows enemies by $s3% and deals $s$s4 Frost damage every $s5 sec. Enemies that are caught in Snowdrift for $s6 sec consecutively become Frozen in ice, stunned for $s7 sec
} )

-- Auras
spec:RegisterAuras( {
    active_blizzard = {
        duration = function () return 15 * haste end,
        max_stack = 1,
        generate = function( t )
            if query_time - action.blizzard.lastCast < 15 * haste then
                t.count = 1
                t.applied = action.blizzard.lastCast
                t.expires = t.applied + ( 15 * haste )
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
            ( action.frostbolt.in_flight or action.frostfire_bolt.in_flight ) then
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

    -- Add incoming Winter's Chill stacks from Flurry projectiles
    local incoming_wc_stacks = 0
    if action.flurry.in_flight and action.flurry.lastCast > 0 then
        local distance = target.maxR or 30
        local gcdMax = gcd.max
        local flurryCastTime = action.flurry.lastCast
        local timeSinceCast = query_time - flurryCastTime

        -- Calculate when each projectile would impact (absolute times)
        local impact1Time = distance / 48
        local impact2Time = impact1Time + (0.31 * gcdMax)
        local impact3Time = impact1Time + (0.56 * gcdMax)

        -- Count projectiles that have NOT YET landed by query_time
        local projectiles_still_incoming = 0

        if timeSinceCast < impact1Time then
            projectiles_still_incoming = projectiles_still_incoming + 1
            if Hekili.ActiveDebug then
                Hekili:Debug( "Remaining Winters Chill(%s): Flurry projectile 1 still incoming (%.3fs remaining)", this_action, impact1Time - timeSinceCast )
            end
        end

        if timeSinceCast < impact2Time then
            projectiles_still_incoming = projectiles_still_incoming + 1
            if Hekili.ActiveDebug then
                Hekili:Debug( "Remaining Winters Chill(%s): Flurry projectile 2 still incoming (%.3fs remaining)", this_action, impact2Time - timeSinceCast )
            end
        end

        if timeSinceCast < impact3Time then
            projectiles_still_incoming = projectiles_still_incoming + 1
            if Hekili.ActiveDebug then
                Hekili:Debug( "Remaining Winters Chill(%s): Flurry projectile 3 still incoming (%.3fs remaining)", this_action, impact3Time - timeSinceCast )
            end
        end

        -- Only count incoming stacks that will land before Winter's Chill expires
        local remaining_flight_time = max(0, max(impact1Time, impact2Time, impact3Time) - timeSinceCast)
        if remaining_flight_time < remains then
            incoming_wc_stacks = projectiles_still_incoming -- Let final calculation handle max stacks
            if Hekili.ActiveDebug then
                Hekili:Debug( "Remaining Winters Chill(%s): +%d stacks from %d incoming Flurry projectiles", this_action, incoming_wc_stacks, projectiles_still_incoming )
            end
        else
            if Hekili.ActiveDebug then
                Hekili:Debug( "Remaining Winters Chill(%s): Flurry projectiles won't land before Winter's Chill expires", this_action )
            end
        end
    end

    -- Count consumer projectiles that will remove Winter's Chill stacks

    for spender in pairs( wc_spenders ) do
        local a = action[ spender ]
        local in_flight_remains = a.in_flight_remains
        if in_flight_remains > 0 and in_flight_remains < remains then
            if spender == "ice_lance" and fof_consumed > in_flight_remains then
                if Hekili.ActiveDebug then Hekili:Debug( "Remaining Winters Chill(%s): Ice Lance in flight, but FoF consumed before it hits.", this_action ) end
            else
                if Hekili.ActiveDebug then Hekili:Debug( "Remaining Winters Chill(%s): -%s projectile will consume stack.", this_action, spender ) end
                projectiles = projectiles + 1
            end
        end
    end

    -- Calculate final result: current stacks + incoming stacks - consumed stacks
    local result = max( 0, min( 2, stacks + incoming_wc_stacks ) - projectiles )

    if Hekili.ActiveDebug then
        Hekili:Debug( "Remaining Winter's Chill(%s): Current=%d stacks/%.2fs, Incoming=+%d, Consumers=-%d, Available=%d",
            this_action, wc.stack, remains, incoming_wc_stacks, projectiles, result )
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

        if subtype == "SPELL_DAMAGE" and spellID == 228598 and now - lanceRemoved > lanceICD then
            numLances = max( 0, numLances - 1 )
            lanceRemoved = now
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

-- Track basic Flurry cast data for distance calculation
local flurryCastData = {}

-- Track Flurry cast and damage events
spec:RegisterCombatLogEvent( function( _, subtype, _, sourceGUID, _, _, _, targetGUID, _, _, _, spellID, _, _, _, amount )
    if sourceGUID ~= state.GUID then return end
    local now = GetTime()

    -- Flurry cast
    if spellID == 44614 and subtype == "SPELL_CAST_SUCCESS" then
        -- Get current distance to target
        local distance = state.target.maxR
        -- Get current GCD max
        local gcdMax = 1.5  -- Default fallback
        if state and state.gcd and state.gcd.max then
            gcdMax = state.gcd.max
        end

        -- Store cast data for impact tracking
        flurryCastData[targetGUID] = {
            castTime = now,
            distance = distance,
            gcdMax = gcdMax,
            impactsReceived = 0
        }

        -- Calculate impact timings using the provided formulas
        local impact1Time = distance / 48
        local impact2Time = impact1Time + ( 0.31 * gcdMax )
        local impact3Time = impact1Time + ( 0.56 * gcdMax )

        -- Queue all 3 impacts with proper timing for the addon's prediction system
        state:QueueEvent( "flurry", now, impact1Time, "PROJECTILE_IMPACT", targetGUID, true )
        state:QueueEvent( "flurry", now, impact2Time, "PROJECTILE_IMPACT", targetGUID, true )
        state:QueueEvent( "flurry", now, impact3Time, "PROJECTILE_IMPACT", targetGUID, true )

        if Hekili.ActiveDebug then
            Hekili:Debug("Flurry cast: Distance=%.1f, GCD=%.3f, Impacts at %.3f/%.3f/%.3f",
                distance, gcdMax, impact1Time, impact2Time, impact3Time)
        end

    -- Flurry damage events (projectile impacts)
    elseif spellID == 228354 and ( subtype == "SPELL_DAMAGE" or subtype == "SPELL_MISSED" ) then
        local castData = flurryCastData[ targetGUID ]
        if castData then
            castData.impactsReceived = castData.impactsReceived + 1
            local delay = now - castData.castTime

            if Hekili.ActiveDebug then
                Hekili:Debug("Flurry impact %d: %.3fs after cast (predicted: %.3f)",
                    castData.impactsReceived, delay,
                    castData.impactsReceived == 1 and castData.distance / 48 or
                    castData.impactsReceived == 2 and ( castData.distance / 48 + 0.31 * castData.gcdMax ) or
                    ( castData.distance / 48 + 0.56 * castData.gcdMax ) )
            end

            -- Clean up after all 3 impacts received
            if castData.impactsReceived >= 3 then
                flurryCastData[targetGUID] = nil
            end
        end
    end
end)

--[[ Optional: Clean up old cast data periodically
local function cleanupOldCastData()
    local now = GetTime()
    for targetGUID, data in pairs( flurryCastData ) do
        -- Remove data older than 10 seconds
        if now - data.castTime > 10 then
            flurryCastData[ targetGUID ] = nil
        end
    end
end

-- Clean up every 30 seconds
C_Timer.NewTicker( 30, cleanupOldCastData )

--]]

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

spec:RegisterGear({
    -- The War Within
    tww3 = {
        items = { 237721, 237719, 237718, 237716, 237717 },
        auras = {
            -- Spellslinger
            -- Spherical Sorcery Your spell damage is increased by $s1% $s2 seconds remaining
            -- https://www.wowhead.com/spell=1247525
            spherical_sorcery = {
                id = 1247525,
                duration = 10,
                max_stack = 1
            },
            -- Frostfire
            -- Frost mage version
            ignite = {
                id = 1236160,
                duration = 9,
                max_stack = 1
            },
        }
    },
    tww2 = {
        items = { 229346, 229344, 229342, 229343, 229341 },
        auras = {
            extended_bankroll = {
                id = 1216914,
                duration = 30,
                max_stack = 1
            }
        }
    },
    -- Dragonflight
    tier31 = {
        items = { 207288, 207289, 207290, 207291, 207293, 217232, 217234, 217235, 217231, 217233 }
    },
    tier30 = {
        items = { 202554, 202552, 202551, 202550, 202549 }
    },
    tier29 = {
        items = { 200318, 200320, 200315, 200317, 200319 },
        auras = {
            touch_of_ice = {
                id = 394994,
                duration = 6,
                max_stack = 1
            }
        }
    }
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
        cooldown = 15,
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
        -- Remove flightTime to prevent generic projectile handling, flurry gets its own queued event handler
        -- flightTime = function () return 0.5 + target.maxR * 0.0175 end,

        handler = function ()
            removeBuff( "brain_freeze" )
            -- Don't apply Winter's Chill directly - let the impacts handle it
            if Hekili.ActiveDebug then Hekili:Debug( "Flurry handler - queueing virtual projectiles." ) end
            applyDebuff( "target", "flurry" )

            -- Queue 3 separate projectile impacts for virtual predictions
            local distance = target.maxR or 30  -- Fallback distance if not available
            local gcdMax = gcd.max
            local impact1Time = distance / 48

            -- Queue all 3 impacts with proper timing (virtual queue)
            state:QueueEvent( "flurry", query_time, impact1Time, "PROJECTILE_IMPACT", target.unit, false )
            state:QueueEvent( "flurry", query_time, impact1Time + (0.31 * gcdMax), "PROJECTILE_IMPACT", target.unit, false )
            state:QueueEvent( "flurry", query_time, impact1Time + (0.56 * gcdMax), "PROJECTILE_IMPACT", target.unit, false )

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
            -- Handle individual projectile impact - each adds 1 Winter's Chill stack
            if Hekili.ActiveDebug then Hekili:Debug( "Flurry projectile impact - adding Winter's Chill stack." ) end

            -- Add 1 Winter's Chill stack (max 2)
            local currentStacks = debuff.winters_chill.stack or 0
            if currentStacks < 2 then
                applyDebuff( "target", "winters_chill", nil, currentStacks + 1 )
            end
            applyDebuff( "target", "flurry" )
            -- Add incremental effects per projectile
            if talent.bone_chilling.enabled then addStack( "bone_chilling" ) end
            if talent.frostfire_mastery.enabled then
                if buff.frost_mastery.up then applyBuff( "frost_mastery", buff.frost_mastery.expires, min( buff.frost_mastery.stacks + 1, 6) )
                else applyBuff( "frost_mastery", nil, 1 ) end
                -- Only handle Excess Frost consumption on final stack (when we reach 2 stacks)
                if currentStacks == 1 and buff.excess_frost.up then
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
            -- Always consume Winter's Chill if available (Flurry projectiles apply stacks progressively)
            removeDebuffStack( "target", "winters_chill" )
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
            -- Always consume Winter's Chill if available (Flurry projectiles apply stacks progressively)
            removeDebuffStack( "target", "winters_chill" )
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
            -- Always consume Winter's Chill if available (Flurry projectiles apply stacks progressively)
            removeDebuffStack( "target", "winters_chill" )
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

        -- FIXME: Skeleton Generator strange edgecase doesn't find this talent
        -- talent = "ice_barrier",
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
                    -- BrainFreeze() currently nerfed to 50% chance, cannot predict
                end
            end

            if buff.fof_consumed.up then
                if Hekili.ActiveDebug then Hekili:Debug( "Fingers of Frost consumed by Ice Lance." ) end
                removeStack( "fof_consumed" )
            else
                if Hekili.ActiveDebug then Hekili:Debug( "Winter's Chill consumed by Ice Lance." ) end
                -- Always consume Winter's Chill if available (Flurry projectiles apply stacks progressively)
                removeDebuffStack( "target", "winters_chill" )
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

spec:RegisterPack( "Frost Mage", 20250829, [[Hekili:T3vFZTTnt(plE6mkYn2Ys0rj2zS9nPPn3Lm96tV6Ex)JBotrrbzZZuKQ8L4OmA0N9B3fGKaGaKuYYPjxFM2j2waeyXI9LFl2fu3m6MF)MRN5LXU5xCg6mE4zoNpy04xmC8lU56Svlz3C9sp)79Uf(LiVfW)(UK40Snt(3PpAP3QWyVz4yKgNN4dF0DzzltF9jNCBq2D5th4hV4K0Gf5HEzbXr(jEZZW)2)KPHXtpj7o2dEjpaDni6K34JD5xtcItcYw9ZbPzPNmJn3lpm7KfW05ohN6b4tFZ1tZdcZEF0ntns9NE2nx7LNDxCYnxFDWI3cKvWSzmE3zPWZF8XBM873X2m5p8sG)HOGntUM5Lgd)80nFahVJhE2XoN)AS9Omws6MjV9UGWWntozZK3fMNKSAZK3Vyzs8hzlyrzPvp1ih4PEZV(ZWqUkYFZey2yNn7Ch)Xv9z4yOpVlibzNyx)WMp0mv5u8SVG)S4ktmbIgo94HJGg(9)4pKFQj5lrEe1PxaK2Xoi1D9Yvl8s5lRGQfrrVgbJ2rBMa)C0R4)0Xb)PZXdFz5CRoWdHMWUm8yNrIFEU5Uo88JDEb00BJxWGv)1zXjlQAAi(04ppJ)to5AyuotUPLcbh9o9kovOZwV56qucdfDNp31lMb)2VqAdSiVPHSz38dGmejsEZ1(Xrm345U(XHZ4sqjbl5n9tFcyHrEHPqVGPNLe4bAoEHaRCa2DwAMBAK3YbIHDZKEiTY(O7T(ZgmcvqyqpqoWnzGySfkyEcJ9zM2C)MB9cIqXhQv8z2mjZl5wgikwWpc(m8H)kYLFhneBM4fbeX79HF7xI)Oh8eXBMKENxgq7BM8Vg65h4fIIhb3x0z5TPbYRtP5fwvCADGmZAqwWcMBAqeoDxTzYzuh7RWbULpLUP8zeApHTawybr36(axXZ1NR3Djipq9ygBA(85duAEWS4ha591RTXF3m5qKfFQglUA5CG4jJbjc8PNl4y9u4WB5kv0xLv5GGi35Hb3Ex2t96TuakWN5gb73ih4f7ch4rrK9AJpijPtgwrYCmsMvkaXFMf5gNmvM0HE9sRlgIAyFYNLM6opiHnind8LreSdrs(XWghqFYmTb5lvzAHEWwkorVY6eju3XE77fgYsQu2XDhrZeVe5FjaFSOhvZ10WGp)zVKz4uDMvRaGhqCP4onomtZAWpMNaJoQAd2a)VyGLbqVMVI)rMx2DpRY)fQYpc4bpa)jS7EpJTKE0Fqqdc9(3r88nt(hjt3mb9LuYWmS6NHZrXUUSXoABiWFL7hrAc4VfAgudkpMGCVyZKZ5SoRD5sQlW4CqPKLkZrwfJu7p3cpTApwJDgh9m4zxKh5F3Mj)ejgr(Rbg2u28y8NGUsAkX5Yq3lo6glbpRrI2ElyRayIZXFle6wk7pZzWSoayVrHRq9Rq2h9IqR5XjITSQDmeVZS0TNVV1I)jmVzK23OHwDgw5XsLL9VrRmvgaTyW98czUugy2CwQOfv2IY6tI8KmZYndLs2yXHdLsS1ZIvIUB9A8W0LHKrlU25kf2yt29CQ4kWJHZmjestQUNCn7sb(b(HSuPnLXvdMIrsA00DAPzTuDF4TEiOGceQK)9Lmu2SukMqsB1wj1kyheNyDFfftC6DbZZqUYY4hyjAeacXca1M49z0OZVfKLJqkExmanbac)N5blxIC3ysW3NO2RfJhawbhqOX8S0GzcHdzBA46Xh2CbiEtwqQHa01Kqpqg7bAEtZNY1UYKFqLLBFYWrbLmWdO0u3eIoDNZjZsZpvMU4(Youv5PQzzrZs3)wuYu6jovhu6NqUJLcIAtAHZcLr6LBM89BMGUTx49jAZBCZYGvwmzlOTrmaGcd0hyWcISVrnFr401IR45W2lQ)uOMy3v7i7(ATOoABGotddHI7tfCeJS5GaDP7Y)dxmMbEKdU8WHxicB6g8)Ug4tGsT3hBmyIcvw)vqFDf41XUlTkBdSKI2wPI(DK2Y8J5Jj4yCUrm9Oc0cp83cYKG(Jo4NgJkqcAAGPasQOXMH71oCrz32QESnbgCRmaYT)uzs567aDL0cnmuFYxXej3Ub6pc)nWYd5AN3hjZNch5HCOrO5fIdSpzkfoKkSUMsuED)6OhoulkkZL8ZjmxBZATnqo)sCbehIp9oUgk3MR4KEcslmZgagjsYiikz35fj)GVx4nRl68siqeRwvX8cYFFfbGU97M2hADhWmmOgJoOnhnY215sZd8Vd1atjKWoD0DJuKgTs7AoVBiIdvKiMGzOBDjaeDwfNJQyrswxqtnaVoU4W0KIgPqVdmjGOcddJFaLs4kN1fPmGCslwBbxKum4mgRB4gdnOMBs5a3eUhTgZN5i6QHMUD9eBU0S6xPWqQ2207JuXpXrDX(iURWnXrhg0p7rhDbFJWKHG8OSGqXE7DGpoGDdFk4UdBC0WAHSq7p7qilBBOIN1EOINzkurJrjwd2UblODamsnF7MWWxnoTzFWMDShVDJMSjWX(Bq8sf3KoiZDa3085GHucuw6sVfMap1kpxYhAF6)FmNgfH3gfQ63HtxOA)rXU0vxI5rahOdnHNXoUQwr4Q55XUy1oeOP9JgSvzWgcW5rkiApmMogCUIb0TpkL67X4kXYW)QohXHnFUBHIdeWb0EJ6lpwePTfkY2iA)yPL(Mv1UGGaOgfTrmLfXrVdHE0kk0TxZ5jafAlb8VnebW0hvnp6hVLDLOVjG7QJw)VvWD1T70UqYEdgCBiT7oky74PB1)zZWP)QhvMtNqLz78s2cNleQShlyShdmSU4CrRhnDq4CLUtFE5XvWpCNBZH9xG6yLQVbLz0rxBhE2FDvs80qAGnQGpaR1a8qt8ctXdAJ5H7Q)zolNrJBj1ChMAnmam(hxGuyZKFa2olOwhzQLskhEy3(El5jSd1jdvnA8y3sS4JvaNTBozBgwARkOAo1S7zTJW)0DE1QxYTbX8l7e6aBoC(NPrPnh992RPrPd()6Uti7EZAve3GZSofZG1t)zlSRlkQUsl7vQD5eTUKHuQY0AZQBJZQ)S0MneuwyekHwxUzj8p8rMllITiaTaswHaTMSKa)mkNjL645rwjerbE1OPKdKQtJNyYbcAtqo2neT90c3K3wskaNrKWQ2W0)fIGQYGMbJMBd7PFBoPKcYkmW)ExqJ0uJvjAXuRwpjZY2zlDfOkKTc1jEH2PI1OLRgziB9Uah5xJw4AtKyRNt(rzqgOWCVfVyQxDtuEa0NiMlAtfc2Wx36Oc04fbjjXjUblOsvwPF6MKIbl8Pmj8MF0dwKqR4VfMd)aqDBkYGmWbQ)DSK48u3mafz6IaCRMgaX6YsxClxKUONBtgNA85ROvBDWG9f(iI(3IcWUVWlYZDkjDUsY3K52B0cHflJfdPCmG21Q1hKluHXvfRtr4j7NKT3HI0eHwi6J9dcwQtYGpKlmuCfnQa7JvC46jWzoIXtaHBvCEYMQQ8DwmlfbOXtitTZAiF5rfD(40hqSDumeu0i05puenIOubkdhrnWNJmeFcV6TKlmyDfqLcfRr9VhfaC9SuygaERy(72HEywKwxVOOp)t09F5r3B38YwIU32XZlNjWgSQCq7GeAj81AsluHPuRwEf10YrfN4q9C6YpNcVOvf2ckpDHIS0YfG0pjdtiaumgBRuKFt4dERslRYgDthEzIJxrLAOpkeeSXhkkFXuscVoDjNAzt5z1AHR29qKWqx6GxfLf91yCtawsu(cS8MIEWKvjfMyPvjSRNrMxlS)wwNWx)7N8wYRgS0xcEctQDivt5NJuavp2iacrP0(M8BZXH6ntH440RvyWheD(Jdh4yeS(f61KtrjXQOIvZeFPEDlg4l6)Yy(pvyC)Q4dTAsw2sWirMEMgJfYkqVZrNVULDbwJNo2eAQ2Gljn9ggsh6S)CgsLyzPjX0Y7qL7dSPs3fJI7pr5AOmDYnzs8cdL0S5U5ODoYQoAuhXHuahndM0GdsLTioZlDaOx88lpzwSRnuTzEP3FuW8lvyHxm6S1R7tBQ(jRGH0hqWdHhKlg1IU9VqDbgzaqfzwmI9jy89JJaFx3IvlV7SGIFv7PyjO(bHyL8n5cc2PPiwmr)o8I(cWzAml2Ny(5zGveqh55cPF5tme(JO7l5GQB5nl1GIlg8qQS7CEHpW6p(OHJLEEPjoHHfINYjZ6u4YTV9Pts7PuWXY(OYdnEOsiRACadWF4CQ64fKJJRwBgCDl44GWa4Rh2oadKU01AtkyfJT2G3708OPHXXZCHXo7UvOxGUz3zyR2DCgwsY1MKg8KggeUQG(zz0LjeySyCnpbuM9jRjpNZZJaWhPaUhwu6tbzPobznCoNlyjSWzEGWxwmvPv7jAz04cArBgYAOOW40mEHtWepV)iMkgJ2mKziZEcoyOxclAwCQ7YGW4m3AjqZuZz3u)cEiKGJZddzzKzYK8PYkC6TK1qnGbok9V)b8418HapHy6aB)3)uWNmpriPzl2SGflzjZz(zUEP(aRbGkVYnLLKV4PG(Ay2qI0w6HMMdaWWT)7JIFaA72NeJcgMfKOSzcnXlBUhS7Nf)PGO6OmPzVyOv7loQ2mdgXYtWW6xf5TmfrMEhg8ssRNpKeQld3awSTMw62MveORswzq1qGowOJ01zRIr4FiG0ZbSh)tvx0YIiKkX)V9W3jYXEXx16GODMDshLcoW6MDuwx)gDMmPYNoc6(BEUiP9DU4OmjdB2yD5mbaryj3dMJOzs9kdaSuIs030usAlUJdOrbXamcr1UMvMUMgRdcPKfy8c)REJ3R4SAOXQAqHrCQkamL3gbz2tox5v(2urri9caWR41iW4NB(vjaDysaq9CuaIIsTwe58ZYegRLqCJ4IE6Q6351YGCbm8qZ8IOyrm9ANG6waDKMGgjHtx7SOKOmPI)kh0NO7T5YK45b(bqObRmvUF6c6JlBPPlY)ffhsvBDe2LEvtb(A893aFNq5LZawvi8sZxuuzMQ5mVMEVpO86CG428BCR(W0WlYHoEG4TwhiDJVDM4G72TY8OlL0sZlMAMSnem8ENw6yPNAd8shQ2Pe2TaKXq6((A8q02Ul2gp6DZ36m9sE28jW3AYl3FV)eSN2snbwV0uSuiuNpdhOTSXxLAtQH6qu7G04u(QMUVlTvuUYqW0UT5T6AAhks2UCxy(l(2eQ)knOj7rgdEQyj93Ic)16L5xQks3QxPiQgtoFt5lgJC(BfdWguEi(oxQkBeFbUqyVusn2Yfc7L040PlewB3H(oNpPgUE8TQV31BhVndkTLiUgndu)o0)eD95l)RgXAlwJmyFk24vXH(CtaJRgJIzAWmGw8kqImwoMGvUGhLO7lb1P76vz1)yZbDJjDXMVhLGyQa7RmLVsVpc72YDI49aMt80YlEr6H17YdEjOmjevh9YtJBWwe76Z8NL(mub)pZHySaL10ym4aV8S4fE8Bypyu)wy)zZh(5ammGX077n8K8PMFwgyA5EwM1tGUuKviO(mUrMN11JU(zWmt0n3slzpYdcTaK4bbBYgftoMeotcIkjiLW)Kv0VOyArNhP07zZWopZlZBQxk71B(a9s(Zu6nenznbfI27yApWxtGVN2jqQF0ivchz34j0Z8bXJxGvsfeuewgtF33TzY)5YuKNTa2i(I8wACZhWz96YX9T44sfnYc0lj(Il81sVxeXo)JGSZRXZNP4LViUCXg(VVEvsW8)hIt9BSLGVyC5VGYPDcBoSrH(w4IiyK2qu2uDSs2zkD7Yn2x1qL1(JWH51LONP5Kxg)uP8hj2XpgzTbqCMWm9aZ7Ec7sw5lqXuCu8XkTyfMo(usybRUguokDvuC0QfG4kxocabaCjeXaJhWRqQJK3qPHntUfOryTUc5cCIpDqzDJ98lprVC4m3l5cHZCpkk3TJqMYLDRI1oIQmUlh5GP7RTcIZ80wCMAnoTD5rdmwXAMFYI4eqYgBV6GbU6Ytn)iL(8Q)mxCPJ0Md0x5IOw5Z1CdYjCWkQCN0QpsEF4vV8r8YP8YrinySYl7zF1yBO5hTLYqFW(ASllpVTMYrwA7eUHbVt0EhgD1cV1oz33u4g90RQ4E1QK4EgG92ZqfdFy3O02zWToouX32bEjzogdb6RRsDPsTLxGcCmAe7iyb7IHdC6vtTTNjmx6duv9BGlBEHQO3hEnTGtM5ZY(QrJxVgZdtp1II40X6JuNShwV6ko155od)ElfLY61MliL1R7BpOGlg5SEDdn740RLsp5IrdpK4zQRW)ow5inVlRUBvNb4meeEmkxDXOZ71xJBnCSO3wQweWWTZH963GG62cl)QXdBzfAOUrBMJyOIoA5j0l3IMughAuz0zyZtH16My)pvk1cX(F4vlVHTF8h1Izl1kwy7h)2OFJvYqlYhALSqZ92yPeS)xh2RiG9)Cvpb)7)5qjt)fUEHbR5NYs(3nc0w4kRww(xVURuk3n(wKe(DbyrTNP84GA45ie1aTjsKU(yuLo9ATuM(7w2sBtlUmx56nOMECIklFP3ZduwdZu0hJVhwyI(4I0eFZM8AcoWNNNkJys9J5hA5wnUtd5VgMrj808fl4Yp0yxVjX4xTk5Xx9Cm0TQKukbLwoP(9SuNjit5VK3g)gwg8untijkiKEc8lwsd7vN1RVTxi)94sm1oB6lh2ZAIoTPOEObQT4ClPyom8UNV32Sie9WsIEFQxkvghmUq2HzVxZliJB(LLwIzEnD(VLQh1E9GFPeYEFL3k(ggp5JsPwoCbOKgYBlPP0wAL2NVP6nZJKcPvI4vIhVwQNeWMRNrPloxa6UEtxEEVde7H2U3G8WK(Q8TnFBIqwzBDwSIN6sKb84F3XB0IE5uH0Reju)nk)vkX8w)njVHHxowpj(Hwg)TQ47yyiv00L8OlLk4lhtmSo(sEVr7ukBwISxsd(xL3nrdlf1aYXLu)dA4clwluACV(WE2pPd0PstxoXRoB96dkXju5DOAi1FtTF1l)EXBO9ozzIO3Qpw990EVdQPTz0oDD7(MEjh2YZzrkU1vHj1sJNf(IYVbQirWVrU1Zklp(zsxPIPC9e5NRAlyuwVUf3fLDW8vm)IlhDOD8eMjwfGSM6qhnkzKrygpsz7YqimOB2ti)R9MN7BdtuLlYVwTszMA7O1cXwWx67KCB0SbvUdmHtPbNYySCFzUaZw1zK9cOTISOd3QjvPNkntbfWtrGj1aO8)FF57TVzT9RBD9QlpTsdwHNFy9zxd0Bx8BtpNoA2UbBLE0T3brAMMZHVjSOtu93ewZjkTJwYB8X6S4tdO(4ILTAHsVoFOQ3YbJ)fSPwP7c9oHUghC0FtzOQCcBom2XuPOP(9BZi(tqfKdQcJ3qLvLL0taspOy2F8wSK1y4zqapVO(FyvxEcAmqR73g4FeDEeyG6458WI4hWx8)ldwD4Pu8alizwefegpr3yz(qywFwjOvKiNrf5dx8tuWzy)KM9FqudcWcmwuJqO1nEPRvDxr8OYlEUUJ4JukQF4VUgRjbHFyoZiR8BWbcR9Y4GI7IZpYylPV5Ce11CALB9bQhp7CLYLqX(xHCmEDb83PdGRN1VPqjA4)GJPx2UE13SfD02(oVCuVsxYvgII9pQZkfxudtHDwu)(7Q74dxVUiSdBHv0ZOtNd1nQitZ7KFg5byx8Ai)81neBkcIMnL2OD4gM7UyJSMNsRdGnBZQ7k1IGttgQjdWkBCTAjU4rl(mb9sfwTeFwUeSn(qLvrn(q1Q56RgB8HMlkbttnziAsPM1KiBUaF0wByoiS2iTrjZy4fo3Z7woJ6B8QFkDyJZRDTpV6ur5Z8nZL10aVro1o9lj1Y8cy6MBEyT0IoUL0(CXzTLxOxjXi)R6UwAG7yknDTE4qgJbOngWzhAA67GhND1FZt10rw40ULo1J0CpCXhBCbq9WWnH04ECD7vLnUtzpZGbit280UFJgJbXWG1XeAyYnBRU)lNK6UTlMg1ROiT1UVVsHwmt1IN4ICyzs7tsc8P(kcAG47egQs7kYxyW1RTSLDyNYrB6UC1)mRIuvB9pY8W(s75H9LQ5HTwky3fPcJQ8DbyyNukAelBJGvRZBnz3OvqGFNu2f33FZYQqqDiRjBH)g9rdEA7owS7mQfxoFz)gM9PybA2OBp7E3EQTgVDjGWQ1yJCkZ(HnLbmBQEwyKwyJMNM6k5nDWHvA7QFpcDHtJ2bkroyYD6Fb(P2USiU1UQmnt1sQOEce7vdV1JqsKNT6ivxLFH)sw1Qy)EZ36z29TEw39T2Te21f3MnOu1KovJEv3k9Swy5wm00QxxPNslxs7Ir(TWV5Ey2mK5QlgBlXvn6HTgDz2aUP8DTNnEBm1yBXCiNW2IH7VL(b6EIcFm(as1VIVM2Q2fFc7sc1m(yDX4MfPK)cmSLMz1OwhYQh9QL4M)V)]] )