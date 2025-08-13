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
                    -- BrainFreeze() currently nerfed to 50% chance, cannot predict
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

spec:RegisterPack( "Frost Mage", 20250812, [[Hekili:T31EZTnos(plUMQuSNelljhLyN12BLjZK9sQ5Mn765U5pU6mfffKflZhkeK2rPCPp7x3aGKaGaGuYY5XntT1ooX4vJg9JFn6gmxn8QF)QlN5NtU63gny04bNmCu)bNmA44tV6Y8vljxD5s)GB8Vg(dj(XW)9TzP081t(pz)QL(RIs9NHZbnTila(vlYZxsF1rhDDy(IIP9dsJpIggxe5NhMMeK5pph)7bhnnkD6r5li35NDh01WKJEDa2LpKfMMfMV6xdP50JMrM7xeLFumSCEZXLUpo6RUCAryu(7sUAQrQ)5dV6s)I8fPzxD5LHXVbiRWzZi8UtOW4p8W1t(9fK1t(d)m4)WOG1tUK4ttHFE863JZ3Hdo5WHJE16jV(d)k04QKG1tGXroz2PJcgx3NbJH(82WmKXGD99RFV75Fu5yFoFSinkwardhF4GHqd)(F8hYJAsXsC3Y60Zbs7Wri1D5YvX(0CsgD9KW4LzP3sIjj5L9AimBpB9e4NdFj)NJgH)C0HdEr1ARoXdGMWUm4Wrdf)8uZDDWPho65qtVjnMa7(lZtZIRBAaoA8NNW)jNCnmlNi30sHiGENEjNk0zRxDzekRGcHZN75NsG)0VXKRjj(tJiZU6NaPbMW1vxgKMq8sN7fKgnJllKfUK30V8jGfM4hrHEblpjl0h0b8JawzFS7eAUhnXFzFX0UEspKwj36DDWS(drrDc0dKdCvoiqAHcMNriFMOT2V(A)Weu8H1koM1tY9ZUMKtR4hHFg(LFa5YVLnfRN4NaeX7cG)0VLERpmI01tOl8ZbAF9K)rKFqOFekEeEtzNLpM6lVpLwxyxXP1(YmR(5HXepAycUCxSEYjSoUVch4A(s6r5Ri0Egjg2yHjx7DxyckH6fSimciQZb5bwpMrMwmFEFLM7pl9oqE)(7TXFxp5aKfFSglUE7SNyKPGebo65cowpfo83j70krNWaIxcCsJ79NVn79her2Zohqs6oQilBfsGJrcSwOp9ZKeV0SPYen0RxyDBWOdYNciuQ38WmsFAo4jIrQJyetqkCybuMm7QFXsv2vKpCmIl0lTUqcvCS3b(rrKSAfC8Cr0mJlICUmGdw2J61AAu4N)SF2mCPoXQMp4)c3kEttJY1Sa8ZfzWSJQZGDV)Bcyna0L574FM4NV4jWF)n8dlunFiWdUd(RW56neYs2q)jbni01FlJNVEY)mB66jO)JkgMHD)mCnkpVLnWXogcdw5Dlsta)TuBG1GYWeK7zRNCkN1zTlNZ6cmp7vPbQYC6hM4npk86f5cv9tTWtRpJ1yNPjpbgBCrsWI1t(fMyeZhnWWMsMNI)eKMPugNlhDPms3aj4nnr02Ba7datCo(NIGUrjFSGaRAFG9MeTc1SIi36NGwWtZehz1NyiALz0nNVVXI)ze)zmTVHdS6aS2lLkl7)GTZuzaSndEMxkZrjGPYzurlQSfL9Ne5jzALBaIYSRIthkLyRNL7eDx5n4H0LrmZvCTZvkSrxw8gvZvGHHRmtiKTO6EV1SlfgegerOshkJRNmvtJ4SP7OsZAP65WB8rGaVL1KWN(sckBwjfZWbB1wjRvWoiUW6Ejkxy6IW55ixzz6DKmncaHvbazZ8)mA05FhMxGWiEBkahba)(XIWLlrUBktWpGrTxkMpaGcoHqJf50WzcHdzBA4(jaoCbyDtIzQHaC1SiFqg7o26slMY1UYLhOY2DFMHJskPVpqPuVmgD6nNtMvMFQnDX9IDGQYtDZYIMvU8TOKP0tCP2RYpHChRee1w0sNfkZ0lwp5hxpbDUg7)j2H3y3YG1wmjXSJre0FPb69mybr23OMViC5AXv8C44f1FkvtS7QDODFTwuhTnrNOHHqX9PcoIH2CqGU094)fpmobE0cE8GzJfHkDf()Ue4tGsT)TodGOuLnyf0xpbgDS7s7s7WKu0ZQuXxW0tMFiF2axIZnIGhvDI9X)uyUeqF01(0uu1rqn9nf(rn15gIx7qeL2DSJe(PrtaGBKrpUnNAZixUa0pOLAvOouGIzrUTc0he(NaRnm6I3hjtMcN3rC4qOjf2EFxYokDcvArLYO8M(YrVAOMtsUhZ3MWeTnl02a28BPLWAy8P3Y1k52zf3ntiT00AiyyilNbljFHFI8aFNWdwx0ZLqDi2TkI1vOH3vO(1Tz76CO1taZqFCgrqBoxKTLZLM7hSa19Om0VJ6OlgPOlAL21Cy7ikdxwC4ql0TRecIoRslqvSej7kOrgGxNI3ZcYYLIaPuVdmvHibJIsVdLs4kNnfPmGwQ0bBj6F(izkgCgJ1dCJHd0W1OCWAcxIwJZZCuCnqq3UEIn3yw9LuB(u5y6DjQyM4iTi3INkCtCSl95x9zxrb)GWKHGIK8WiXz7cWVgWUHFl4IdBC4GgHPWoF2IWu20WdpP9WdpXu4HgJmSbuDdwq7aaKg(ZnHBVEEAZ(Gn7ypC7gUSjWX7Bq8sfRKoWYTaR085GHugqm6s)4UaysrcNDhU)Ky0GYEkl9aCxxfuu26UfKeUeVpZIZC97b5zko2H)gqSOWdt1GDbisc7S4uxMgIEc5tfzjdKHWuNesJ(DqC5HFHzUUGytmS)vbPGib)PI7G2d4ibkHhZzSL2fg9uZ(61rXvbSww8vXS9fWE(yta7ALDz1fS9lXClIYULWLCPm6i6UhOgPDKoD8Mj64LyAh6M(PjUtSm9DpCRDt0wq7gmCS7GMVjxx9Jx8s7BwD6mgki1lpWiS6YRpyJI7Qvi4TQ69Lac(MRY6IDpSED0Vpp7QHFxG1xxV)pvy91d0PDHKDwmaTfMr3dbWEWeT6Z0DSeFZdjDuNGKA7YI2ahkmiPUDO0UX6TeoxhCO4eE3BmC5whxJCJFNwxxaNSaDrQuCdRsELUEom2pSklDAeBInQA3hlLce5RFefVzrIpEE(reOjhqPewZncNPa(nEV(b(l55Me1gJwTtXwBXVkdMAxDS(LcoBhb7P72Qv)JBc(4x0jCb2C18xzmQnx892PzmQdE(6U7h7(XAve3GBSofHG1l9AdSOx93CAuxCOr8MhLAm(g2V3ng)YvQ)mGw8lR8hjTj)KvEaYGKBAIWwypVj66w11SRERLzBfHdRMFuuWRQvidQ3npBv6uo72bGjFQFnRVIra20tiEizb4Nc0p2v82hhMLLM5fgZkwuL(PB0nfeDPeP4zU1hyeqR4FkQa(baKWeyNCWYqWcswAb1lhCpsJdrpJSjqiuzPlEvBsp0KKjd4ohFnTARdgoI5ZiQ4MeIDp2pX3BkZz(kPdgZT7mqgCS3s8ijK4q0hm)6AmcR1(1iOpjNP6FQg(wjIRh3eM2OY40VQk7foN(vQpxCjGP8aGYKQVYzG5b03b)kYBeauXYNv25dP3HUDyWB(i)g58RbkjsBBfsjvmzpZa0jEn0ixsM6Qqk7iNAqpiSbpu7vBuKyMfk1LS)lGhF9aES53ZOfad2ssPCUzCyxOMwTMaQwqw3qAHvQanQOsXD))SYGHAMLnEiuamGsBbvb(uM3mUaKEqwMGFzdaLAjHhDN)kAvDpOB6Wpxe5Nk1W(vrGGnoOKI4Pmj8M0LCY(mL5lRLpy3rVfmJ2f)ckB6lxcOkOrm5lwMGOQQKctSSDjCQNZmVwA)TQAnV83p6nm)sWwFj4llRr8Zt5H4gYQkwecGOGgFDX1f4u96PPfj6vSzymHDPid6ZVweJolvUouJW30nXxPx3Ib(Y(VmL)tfg3he)sRMKLTemuCXZttXYjeO35y(u9Q6cShpESj8qTb4rA5nmLJyxlXObScDRYKiT61R4DhzQKl9Y6xVApWBBF3MepZqHLAUBJ0UClvhnQZ4awD47goObhKkhrCMhTpOx80ZpAwQNnCP5(0BEw48ZvyHNn8K7VFF2HAq2kykdam408ScXSw2T)oRlWmhfEnZSyc5tW8hKMa(UUgRzzVzHL)rTrrYq9dgMtMVjpqWMsHPVSFhC2(8DHoZI8jsqroyfb0rEQq6x(YmG)sYnvCq1JC3snO4IbpKkNoNw6dS5WhoyS04Lw4mcwAukxA0OsxU7BF5K0EQeCSCoQmOXduEjhACaD4ptl5unXlyY9SGRch4G)CGLdgb9ypAiPqkm2Qdp00IKPrPPZ8G5oFXk0sF3STmOvBlJgurYnweDVLtFmw2OWOvLCcso7rFbhdyCmUC9nVibqpqbGlKe6JbzPUaUUdLysgjAMpi9KNYkELDeTmCCjTOTc5oQZgonJ1TpMoRDhXuZy0wHCd5lqWbJ8ZijZsPEldJsZ9y1jKmKdtnNFvZ6KxiEMwefrYz25YkMkRnP3sUJYQb80fCZDW)hO)KzqqzGX7BEm4tMxiK0SfCvy8ss2CsqUNpnaynaw3vEuswr8Jb95y1qI02vppTaqqHh)3KKEh021KhdIZWQGeLn7Jz(5Z9Ht)80pfM0eMiB1lNA1(IZQTicsifzyC5Rs8xsrOLlWOpYA9kACDti82CT1TTQisvLB8fvdb6iwhQ6OncK))uGjNJ4o9xQFVALH4ubGFZXFZih7x0BRtI21MjDxi4eRB2rzF9VzxQcv(6nqFBZlejeSZLCHjzyZgRRwjajbj7gWCeBLuRcBGLYOe9dnL7lgpXb4KGyagINAx5vRJLxwDG(LwB9TsVV(v5j4SAWPQBqHrCSkckLhYDU90TwFp4gs4Q0BN2V8fyp(PMFf2SBdcqAxGcqSWmBesnpFLWCTec8d30tx18PdwfLkachAMNG24u2l2N1Tq2DscAKmG2AxMKeLjvsjfG(e75VTmlDEyqiGTFLE5dzsqFCvlUEd0NvEltT1r4u6LUIC14tFNFsO8U2RRUrrPQyQsw8D9K5vEj8mUn)HlQpnoEd8oFW3Dk7YDJJDI4o32UKh3LeLVjvTG9R4DhsfolFnBqv6qDtKrUgaigXEKKgVZRn7LbXd228Z2rjpAwVWC7jWDN)OZTNIxnHuFkf)KQOUEgU)zztTkPz0rTm1HhKRTmfyr8sgWL2t0TvhrBrH21LhtWx5NJL(7aVTxKL1sR6pffpO1xaTT3EtBFhgunMC66QVMaf8pLaGnOIi8JttDYd(c8IAEHKASLxuZlyZtNErnT9WJ7C6FC8MIBvFVRpPyBguAlVzond0Ss4FKEZXIpWvxPxMfbPfmUcMpeDC7BZQgWV3e7jnUYJJCkPAGLXqKsqqdHb5Se3vzQUiXkHi(en5eWZEsoaFKjhrCnor(S50cp3JBiPuxnfgqb9azoBfbv)E4Z7W3phhuZ(DaPCPpB8rC5b6(MASglMPwTArTQDYspHtl58D3jEH27DRly7mZq24tbEzn7eHxBIeB8AYFBoctuqGyyoGk)e7nyCFywUZpdnEtfpLpoYgXv68eWyZtqpHFSaOeGhttXyM9lYtJ95VLFa9Z1GFX1V)xdXOJhZ(cYHzOI18taQn5gsU1mRuzBxyr)jCVXpPRPK5jvRm(fW7)ccQFjs)4AxEfxL(jxp5)b(JnsdZ)7FB9eGHJrDmlKY4YvZ5PDAoTMecZtnJnZrqXWz4xK5dk2Gdls5tMS6Mfkxf8efbfKx2VKu2zurIsVNnd78m)C)P(uYRw)E2x5qtzzu0K18ekAVJzFe)oj(U4sM0WHQeokDGjkJeawdFowJyPZdX6b8h(H1t(I8vMC97XL6YQ59n48YkyRyeYl(5A8vsFniXo)ZG89RWRwT8JhjUh57kA)Q6n8PNFKEzuAUxYfqP5EuwMKpdvCpVBv64Zyvu55dhHjzUTcP08Ywkr7Cz7YqdnwPJMhzz4UizR6G7IZp28qQGU1CmNDU8Hd0xzixk)EnCvCchSXj3jnRP8(WX68mUX3ZhI0Gr709SVBSn1CClkt9E7Q5UciYgt5ilTDc3WK3jAVdZUQBA7K9(MWJ0thdsVg4o6zaRrpd4loOBuA7m4wNhMR6oWlrzD0A23yfyvTAlVSy4X3ZyhHXKZg0FuVgQT90UMjEwU0MO6Qgc328YJsVp8kPcxmZjG5IHJV)Em5H9ulfNJhRptDYEyZA654rpD0GF0sPqD)9MldQ7VFF7X2E2Wr3FVJMhnQxlf80zdhCaJNPUd)Zy9k5(uw90Qjdy0aq4XOC1zdpT3(ACRbJf92snkbgUhDqV9DiOUPGMVy8Gw2HgQwz3Ced1yulJqVaGCPmoWOY4ObUxcR4S39lLsb8S7NE1AYzZN)HTy2sTmB285Vn63y530I8HwD24U3gR)LD)(WEzSS7xRMvLYUFnukpLsxVWK5EuwkAeJaTfUYAuAk3FFxPuUB8nOYr2gGfngtvE9CmogIAG2ev)H(CuxdinAPQMnA5iTnT4Qc8qVb1A6GrLvFK75XRQHzk520BGnMOpEinXpSzEnbh4ZlOYiMu)187EFJM3Pr8pbZOeoTioMl)WM7MnjM)6Djp(QNIHUvNFDjO0YvIsplfhfYu(Q8133W2GxFemKeLespb(flvqWfN0BFBP3VhxIPrkwoFqpRzQ3MI6bgO2YkRHfZXYMFX5799WMO2SGXTWwS69Sw1iMoWRQbkZ8xwcWQujA85a)Cj08bkFf8nmFYxFIqbPU8da4JLrnkvYbmTJ2Yi6U8ltVzEKuySseVsm4nYAQaQCZKHE2PcG2nB68t7TNquv7I0Rsrkp0OVj)6Y3MiKv2wNfR4zDhzap8Vv8gTIxTui9krcn)cYFHsCUn)YXBy6LJVtIFOvSkwv5hzykv0VL8IlvfdNpMXW64h1DNwOuoSejENn5Ft(kynSvudch3s7VNJNgBJWNXZ6d6z)2nqhjUEgSxCY93Vxf2GA)c1tP(xM9lEXpk(IS3jltm6T(xR(DzV3En02mANUPDFtFx)AzCwKIBDxysT049Fhx9VYumrWVtEF9kBp(9qxRIP8qy53LQnF5kqmu5G2qFyEPBTdD0eJXTLz0fvTldiWGMwpH0S2NrTVpm4uTj)w1MJzQTJ6(IJGV0VL92Ozdkq7zc1HdxSy0yFzE47w1zKTPRTJSOd3QbsPrrZv8PVBdWObqJ))7xsUDntD)M2vV48JR1Dv40h0C11aV2f)VSXPJkTBWpzdDZDnqZ1Cl8DHTCgv)DHDCgL2rB4ohwNfFCGEJlw2QTPFq8VOMFJ(1yxBlvLB)hScVtRO7Kp36DI0TIJSNrdsoMZTYcK8eSn2tKhFtvutOkDRK5ud1XA3fTNg2qTob20Avpt4xhT9ZyxQMkhCTQJwo0YFNGEzFydL4ZYFcenoOQVIH4GA8np8IXghexw1CtgIWqQznjs3LTH2EdVzzRnYoOKzm8YH6PDlta7B8vOkDDsZB8cuV4yrrr8DZ7g1aVr(c73VIuRU5xtpI0dAKSRXTCz(NDsB32)lLyKFTE2Ng4oMs(I10sybxyBB9toW0c)i5g7XBHMxwvLgI4yh8gmDs6SEy4rzA8eTP1PQg3QSHyWCJjlCAp1sJyrnmzD8cQn5uTvN9vlstN0LlJ6RLKD0URFDJwmk1IF3YCsysJtsc8X(1kAG47eIPEL1GM8Bx8(7TCKDqNY5gDBEfIMvrQRp6hyE1EH98Q9c18Q1iLABJuHrv(UadStkforU6eAAtERj7gTc57hKYw0U(FFqviOhWTG7CEGXz3zIDhqwDZ8L9FHqFm2AMn02ZUhThBlWB21oB1cSroLzFVMY7Hn1nlmslSrZlttfBxxAuTgU6)uOC2iN6(vOfm5c9RGVPnl3rBS7jtRuJujPN2OEnWy9aKe5zCmr194x4)rY0Qy)oZF6j29NEs39N2T000fxLouQCPt50t6gPN1cl3IHMw90knkT8iSng57KVYDW6yiFfNn2w6kS4vTbfz2OTP8BSJnyBmviBWAiNAUYP7pL2(7EIHEi29P6phtthvBJFGTjbkghwxmOzrk5RGXmAUvdzDiloSNP)v)Fp]] )