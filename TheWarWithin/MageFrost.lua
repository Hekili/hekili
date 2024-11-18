-- MageFrost.lua
-- October 2024

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
    blast_wave                = {  62103, 157981, 1 }, -- Causes an explosion around yourself, dealing 5,888 Fire damage to all enemies within 8 yds, knocking them back, and reducing movement speed by 80% for 6 sec.
    cryofreeze                = {  62107, 382292, 2 }, -- While inside Ice Block, you heal for 40% of your maximum health over the duration.
    displacement              = {  62095, 389713, 1 }, -- Teleports you back to where you last Blinked and heals you for 110,004 health. Only usable within 8 sec of Blinking.
    diverted_energy           = {  62101, 382270, 2 }, -- Your Barriers heal you for 10% of the damage absorbed.
    dragons_breath            = { 101883,  31661, 1 }, -- Enemies in a cone in front of you take 7,259 Fire damage and are disoriented for 4 sec. Damage will cancel the effect.
    energized_barriers        = {  62100, 386828, 1 }, -- When your barrier receives melee attacks, you have a 10% chance to be granted Fingers of Frost. Casting your barrier removes all snare effects.
    flow_of_time              = {  62096, 382268, 2 }, -- The cooldowns of Blink and Shimmer are reduced by 2 sec.
    freezing_cold             = {  62087, 386763, 1 }, -- Enemies hit by Cone of Cold are frozen in place for 5 sec instead of snared. When your roots expire or are dispelled, your target is snared by 90%, decaying over 3 sec.
    frigid_winds              = {  62128, 235224, 2 }, -- All of your snare effects reduce the target's movement speed by an additional 10%.
    greater_invisibility      = {  93524, 110959, 1 }, -- Makes you invisible and untargetable for 20 sec, removing all threat. Any action taken cancels this effect. You take 60% reduced damage while invisible and for 3 sec after reappearing.
    ice_barrier               = {  62117,  11426, 1 }, -- Shields you with ice, absorbing 134,116 damage for 1 min. Melee attacks against you reduce the attacker's movement speed by 60%.
    ice_block                 = {  62122,  45438, 1 }, -- Encases you in a block of ice, protecting you from all attacks and damage for 10 sec, but during that time you cannot attack, move, or cast spells. While inside Ice Block, you heal for 40% of your maximum health over the duration. Causes Hypothermia, preventing you from recasting Ice Block for 30 sec.
    ice_cold                  = {  62085, 414659, 1 }, -- Ice Block now reduces all damage taken by 70% for 6 sec but no longer grants Immunity, prevents movement, attacks, or casting spells. Does not incur the Global Cooldown.
    ice_floes                 = {  62105, 108839, 1 }, -- Makes your next Mage spell with a cast time shorter than 10 sec castable while moving. Unaffected by the global cooldown and castable while casting.
    ice_nova                  = {  62088, 157997, 1 }, -- Causes a whirl of icy wind around the enemy, dealing 14,954 Frost damage to the target and all other enemies within 8 yds, freezing them in place for 2 sec. Damage reduced beyond 8 targets.
    ice_ward                  = {  62086, 205036, 1 }, -- Frost Nova now has 2 charges.
    improved_frost_nova       = {  62108, 343183, 1 }, -- Frost Nova duration is increased by 2 sec.
    incantation_of_swiftness  = {  62112, 382293, 2 }, -- Greater Invisibility increases your movement speed by 40% for 6 sec.
    incanters_flow            = {  62118,   1463, 1 }, -- Magical energy flows through you while in combat, building up to 10% increased damage and then diminishing down to 2% increased damage, cycling every 10 sec.
    inspired_intellect        = {  62094, 458437, 1 }, -- Arcane Intellect grants you an additional 3% Intellect.
    mass_barrier              = {  62092, 414660, 1 }, -- Cast Ice Barrier on yourself and 4 allies within 40 yds.
    mass_invisibility         = {  62092, 414664, 1 }, -- You and your allies within 40 yards instantly become invisible for 12 sec. Taking any action will cancel the effect. Does not affect allies in combat.
    mass_polymorph            = {  62106, 383121, 1 }, -- Transforms all enemies within 10 yards into sheep, wandering around incapacitated for 15 sec. While affected, the victims cannot take actions but will regenerate health very quickly. Damage will cancel the effect. Only works on Beasts, Humanoids and Critters.
    master_of_time            = {  62102, 342249, 1 }, -- Reduces the cooldown of Alter Time by 10 sec. Alter Time resets the cooldown of Blink and Shimmer when you return to your original location.
    mirror_image              = {  62124,  55342, 1 }, -- Creates 3 copies of you nearby for 40 sec, which cast spells and attack your enemies. While your images are active damage taken is reduced by 20%. Taking direct damage will cause one of your images to dissipate.
    overflowing_energy        = {  62120, 390218, 1 }, -- Your spell critical strike damage is increased by 10%. When your direct damage spells fail to critically strike a target, your spell critical strike chance is increased by 2%, up to 10% for 8 sec. When your spells critically strike Overflowing Energy is reset.
    quick_witted              = {  62104, 382297, 1 }, -- Successfully interrupting an enemy with Counterspell reduces its cooldown by 4 sec.
    reabsorption              = {  62125, 382820, 1 }, -- You are healed for 3% of your maximum health whenever a Mirror Image dissipates due to direct damage.
    reduplication             = {  62125, 382569, 1 }, -- Mirror Image's cooldown is reduced by 10 sec whenever a Mirror Image dissipates due to direct damage.
    remove_curse              = {  62116,    475, 1 }, -- Removes all Curses from a friendly target.
    rigid_ice                 = {  62110, 382481, 1 }, -- Frost Nova can withstand 80% more damage before breaking.
    ring_of_frost             = {  62088, 113724, 1 }, -- Summons a Ring of Frost for 10 sec at the target location. Enemies entering the ring are incapacitated for 10 sec. Limit 10 targets. When the incapacitate expires, enemies are slowed by 75% for 4 sec.
    shifting_power            = {  62113, 382440, 1 }, -- Draw power from within, dealing 26,431 Arcane damage over 3.2 sec to enemies within 18 yds. While channeling, your Mage ability cooldowns are reduced by 12 sec over 3.2 sec.
    shimmer                   = {  62105, 212653, 1 }, -- Teleports you 20 yds forward, unless something is in the way. Unaffected by the global cooldown and castable while casting.
    slow                      = {  62097,  31589, 1 }, -- Reduces the target's movement speed by 60% for 15 sec.
    spellsteal                = {  62084,  30449, 1 }, -- Steals a beneficial magic effect from the target. This effect lasts a maximum of 2 min.
    supernova                 = { 101883, 157980, 1 }, -- Pulses arcane energy around the target enemy or ally, dealing 3,739 Arcane damage to all enemies within 8 yds, and knocking them upward. A primary enemy target will take 100% increased damage.
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
    brain_freeze              = {  62179, 190447, 1 }, -- Frostbolt has a 25% chance to reset the remaining cooldown on Flurry and cause your next Flurry to deal 50% increased damage.
    chain_reaction            = {  62161, 278309, 1 }, -- Your Ice Lances against frozen targets increase the damage of your Ice Lances by 2% for 10 sec, stacking up to 5 times.
    cold_front                = {  62155, 382110, 1 }, -- Casting 30 Frostbolts or Flurries calls down a Frozen Orb toward your target. Hitting an enemy player counts as double.
    coldest_snap              = {  62185, 417493, 1 }, -- Cone of Cold's cooldown is increased to 45 sec and if Cone of Cold hits 3 or more enemies it resets the cooldown of Frozen Orb and Comet Storm. In addition, Cone of Cold applies Winter's Chill to all enemies hit. Cone of Cold's cooldown can no longer be reduced by your cooldown reduction effects.
    comet_storm               = {  62182, 153595, 1 }, -- Calls down a series of 7 icy comets on and around the target, that deals up to 54,277 Frost damage to all enemies within 6 yds of its impacts.
    cryopathy                 = {  62152, 417491, 1 }, -- Each time you consume Fingers of Frost the damage of your next Ray of Frost is increased by 5%, stacking up to 50%. Icy Veins grants 10 stacks instantly.
    deaths_chill              = { 101302, 450331, 1 }, -- While Icy Veins is active, damaging an enemy with Frostbolt increases spell damage by 1%. Stacks up to 15 times.
    deep_shatter              = {  62159, 378749, 2 }, -- Your Frostbolt deals 40% additional damage to Frozen targets.
    everlasting_frost         = {  81468, 385167, 1 }, -- Frozen Orb deals an additional 30% damage and its duration is increased by 2 sec.
    fingers_of_frost          = {  62164, 112965, 1 }, -- Frostbolt has a 15% chance and Frozen Orb damage has a 10% to grant a charge of Fingers of Frost. Fingers of Frost causes your next Ice Lance to deal damage as if the target were frozen. Maximum 2 charges.
    flash_freeze              = {  62168, 379993, 1 }, -- Each of your Icicles deals 10% additional damage, and when an Icicle deals damage you have a 5% chance to gain the Fingers of Frost effect.
    flurry                    = {  62178,  44614, 1 }, -- Unleash a flurry of ice, striking the target 3 times for a total of 22,244 Frost damage. Each hit reduces the target's movement speed by 80% for 1 sec, has a 25% chance to activate Glacial Assault, and applies Winter's Chill to the target. Winter's Chill causes the target to take damage from your spells as if it were frozen.
    fractured_frost           = {  62151, 378448, 1 }, -- While Icy Veins is active, your Frostbolts hit up to 2 additional targets and their damage is increased by 15%.
    freezing_rain             = {  62150, 270233, 1 }, -- Frozen Orb makes Blizzard instant cast and increases its damage done by 60% for 12 sec.
    freezing_winds            = {  62184, 382103, 1 }, -- While Frozen Orb is active, you gain Fingers of Frost every 3 sec.
    frostbite                 = {  81467, 378756, 1 }, -- Gives your Chill effects a 10% chance to freeze the target for 4 sec.
    frozen_orb                = {  62177,  84714, 1 }, -- Launches an orb of swirling ice up to 40 yds forward which deals up to 48,384 Frost damage to all enemies it passes through over 15 sec. Deals reduced damage beyond 8 targets. Grants 1 charge of Fingers of Frost when it first damages an enemy. While Frozen Orb is active, you gain Fingers of Frost every 3 sec. Enemies damaged by the Frozen Orb are slowed by 40% for 3 sec.
    frozen_touch              = {  62180, 205030, 1 }, -- Frostbolt grants you Fingers of Frost 25% more often and Brain Freeze 20% more often.
    glacial_assault           = {  62183, 378947, 1 }, -- Your Comet Storm now increases the damage enemies take from you by 6% for 6 sec and Flurry has a 25% chance each hit to call down an icy comet, crashing into your target and nearby enemies for 3,611 Frost damage.
    glacial_spike             = {  62157, 199786, 1 }, -- Conjures a massive spike of ice, and merges your current Icicles into it. It impales your target, dealing 85,092 damage plus all of the damage stored in your Icicles, and freezes the target in place for 4 sec. Damage may interrupt the freeze effect. Requires 5 Icicles to cast. Passive: Ice Lance no longer launches Icicles.
    hailstones                = {  62158, 381244, 1 }, -- Casting Ice Lance on Frozen targets has a 100% chance to generate an Icicle.
    ice_caller                = {  62170, 236662, 1 }, -- Each time Blizzard deals damage, the cooldown of Frozen Orb is reduced by 0.5 sec.
    ice_lance                 = {  62176,  30455, 1 }, -- Quickly fling a shard of ice at the target, dealing 9,505 Frost damage, and 8,554 Frost damage to a second nearby target. Ice Lance damage is tripled against frozen targets.
    icy_veins                 = {  62171,  12472, 1 }, -- Accelerates your spellcasting for 30 sec, granting 20% haste and preventing damage from delaying your spellcasts. Activating Icy Veins summons a water elemental to your side for its duration. The water elemental's abilities grant you Frigid Empowerment, increasing the Frost damage you deal by 3%, up to 15%.
    lonely_winter             = {  62173, 205024, 1 }, -- Frostbolt, Ice Lance, and Flurry deal 15% increased damage.
    permafrost_lances         = {  62169, 460590, 1 }, -- Frozen Orb increases Ice Lance's damage by 15% for 15 sec.
    perpetual_winter          = {  62181, 378198, 1 }, -- Flurry now has 2 charges.
    piercing_cold             = {  62166, 378919, 1 }, -- Frostbolt and Icicle critical strike damage increased by 20%.
    ray_of_frost              = {  62153, 205021, 1 }, -- Channel an icy beam at the enemy for 4.0 sec, dealing 35,012 Frost damage every 0.8 sec and slowing movement by 70%. Each time Ray of Frost deals damage, its damage and snare increases by 10%. Generates 2 charges of Fingers of Frost over its duration.
    shatter                   = {  62165,  12982, 1 }, -- Multiplies the critical strike chance of your spells against frozen targets by 1.5, and adds an additional 50% critical strike chance.
    slick_ice                 = {  62156, 382144, 1 }, -- While Icy Veins is active, each Frostbolt you cast reduces the cast time of Frostbolt by 4% and increases its damage by 4%, stacking up to 5 times.
    splintering_cold          = {  62162, 379049, 2 }, -- Frostbolt and Flurry have a 30% chance to generate 2 Icicles.
    splintering_ray           = { 103771, 418733, 1 }, -- Ray of Frost deals 30% of its damage to 5 nearby enemies.
    splitting_ice             = {  62163,  56377, 1 }, -- Your Ice Lance and Icicles now deal 5% increased damage, and hit a second nearby target for 90% of their damage. Your Glacial Spike also hits a second nearby target for 100% of its damage.
    subzero                   = {  62160, 380154, 2 }, -- Your Frost spells deal 20% more damage to targets that are rooted and frozen.
    thermal_void              = {  62154, 155149, 1 }, -- Icy Veins' duration is increased by 5 sec. Your Ice Lances against frozen targets extend your Icy Veins by an additional 0.5 sec.
    winters_blessing          = {  62174, 417489, 1 }, -- Your Haste is increased by 8%. You gain 10% more of the Haste stat from all sources.
    wintertide                = {  62172, 378406, 2 }, -- Increases Frostbolt damage by 5%. Fingers of Frost empowered Ice Lances deal 10% increased damage to Frozen targets.

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
    spellfrost_teachings      = {  94655, 444986, 1 }, -- Direct damage from Frost Splinters has a small chance to reset the cooldown of Frozen Orb and increase all damage dealt by Frozen Orb by 30% for 10 sec.
    splintering_orbs          = {  94661, 444256, 1 }, -- Enemies damaged by your Frozen Orb conjure 1 Frost Splinter, up to 6. Frozen Orb damage is increased by 10%.
    splintering_sorcery       = {  94664, 443739, 1, "spellslinger" }, -- When you consume Winter's Chill, conjure a Frost Splinter that fires at your target. Frost Splinter: Conjure raw Frost magic into a sharp projectile that deals 3,747 Frost damage. Frost Splinters embed themselves into their target, dealing 3,747 Frost damage over 18 sec. This effect stacks.
    splinterstorm             = {  94654, 443742, 1 }, -- Whenever you have 8 or more active Embedded Frost Splinters, you automatically cast a Splinterstorm at your target. Splinterstorm: Shatter all Embedded Frost Splinters, dealing their remaining periodic damage instantly. Conjure a Frost Splinter for each Splinter shattered, then unleash them all in a devastating barrage, dealing 3,747 Frost damage to your target for each Splinter in the Splinterstorm. Splinterstorm has a 5% chance to grant Brain Freeze.
    unerring_proficiency      = {  94658, 444974, 1 }, -- Each time you conjure a Frost Splinter, increase the damage of your next Ice Nova by 5%. Stacks up to 60 times.
    volatile_magic            = {  94658, 444968, 1 }, -- Whenever an Embedded Frost Splinter is removed, it explodes, dealing 1,083 Frost damage to nearby enemies. Deals reduced damage beyond 5 targets.

    -- Frostfire
    elemental_affinity        = {  94633, 431067, 1 }, -- The cooldown of Fire spells is reduced by 30%.
    excess_fire               = {  94637, 438595, 1 }, -- Reaching maximum stacks of Fire Mastery causes your next Ice Lance to explode in a Frostfire Burst, dealing 13,546 Frostfire damage to nearby enemies. Damage reduced beyond 8 targets. Frostfire Burst, grants Brain Freeze.
    excess_frost              = {  94639, 438600, 1 }, -- Reaching maximum stacks of Frost Mastery causes your next Flurry to also cast Ice Nova at 125% effectiveness. When you consume Excess Frost, the cooldown of Comet Storm is reduced by 5 sec.
    flame_and_frost           = {  94633, 431112, 1 }, -- Cold Snap additionally resets the cooldowns of your Fire spells.
    flash_freezeburn          = {  94635, 431178, 1 }, -- Frostfire Empowerment grants you maximum benefit of Frostfire Mastery and refreshes its duration. Activating Combustion or Icy Veins grants you Frostfire Empowerment.
    frostfire_bolt            = {  94641, 431044, 1 }, -- Launches a bolt of frostfire at the enemy, causing 15,079 Frostfire damage, slowing movement speed by 60%, and causing an additional 5,466 Frostfire damage over until canceled. Frostfire Bolt generates stacks for both Fire Mastery and Frost Mastery.
    frostfire_empowerment     = {  94632, 431176, 1 }, -- Your Frost and Fire spells have a chance to activate Frostfire Empowerment, causing your next Frostfire Bolt to be instant cast, deal 60% increased damage, explode for 80% of its damage to nearby enemies, and grant you maximum benefit of Frostfire Mastery and refresh its duration.
    frostfire_infusion        = {  94634, 431166, 1 }, -- Your Frost and Fire spells have a chance to trigger an additional bolt of Frostfire, dealing 4,876 damage. This effect generates Frostfire Mastery when activated.
    frostfire_mastery         = {  94636, 431038, 1, "frostfire" }, -- Your damaging Fire spells generate 1 stack of Fire Mastery and Frost spells generate 1 stack of Frost Mastery. Fire Mastery increases your haste by 1%, and Frost Mastery increases your Mastery by 2% for 14 sec, stacking up to 6 times each. Adding stacks does not refresh duration.
    imbued_warding            = {  94642, 431066, 1 }, -- Ice Barrier also casts a Blazing Barrier at 25% effectiveness.
    isothermic_core           = {  94638, 431095, 1 }, -- Comet Storm now also calls down a Meteor at 100% effectiveness onto your target's location. Meteor now also calls down a Comet Storm at 150% effectiveness onto your target location.
    meltdown                  = {  94642, 431131, 1 }, -- You melt slightly out of your Ice Block and Ice Cold, allowing you to move slowly during Ice Block and increasing your movement speed over time. Ice Block and Ice Cold trigger a Blazing Barrier when they end.
    severe_temperatures       = {  94640, 431189, 1 }, -- Casting damaging Frost or Fire spells has a high chance to increase the damage of your next Frostfire Bolt by 10%, stacking up to 5 times.
    thermal_conditioning      = {  94640, 431117, 1 }, -- Frostfire Bolt's cast time is reduced by 10%.
} )


-- PvP Talents
spec:RegisterPvpTalents( {
    concentrated_coolness      =  632, -- (198148)
    ethereal_blink             = 5600, -- (410939) Blink and Shimmer apply Slow at 100% effectiveness to all enemies you Blink through. For each enemy you Blink through, the cooldown of Blink and Shimmer are reduced by 1 sec, up to 5 sec.
    frost_bomb                 = 5496, -- (390612) Places a Frost Bomb on the target. After 5 sec, the bomb explodes, dealing 72,063 Frost damage to the target and 36,047 Frost damage to all other enemies within 10 yards. All affected targets are slowed by 80% for 4 sec. If Frost Bomb is dispelled before it explodes, gain a charge of Brain Freeze.
    ice_form                   =  634, -- (198144) Your body turns into Ice, increasing your Frostbolt damage done by 30% and granting immunity to stun and knockback effects. Lasts 17 sec.
    ice_wall                   = 5390, -- (352278) Conjures an Ice Wall 30 yards long that obstructs line of sight. The wall has 40% of your maximum health and lasts up to 15 sec.
    icy_feet                   =   66, -- (407581)
    improved_mass_invisibility = 5622, -- (415945) The cooldown of Mass Invisibility is reduced by 4 min and can affect allies in combat.
    master_shepherd            = 5581, -- (410248) While an enemy player is affected by your Polymorph or Mass Polymorph, your movement speed is increased by 25% and your Versatility is increased by 12%. Additionally, Polymorph and Mass Polymorph no longer heal enemies.
    ring_of_fire               = 5490, -- (353082) Summons a Ring of Fire for 8 sec at the target location. Enemies entering the ring burn for 18% of their total health over 6 sec.
    snowdrift                  = 5497, -- (389794) Summon a strong Blizzard that surrounds you for 6 sec that slows enemies by 80% and deals 2,167 Frost damage every 1 sec. Enemies that are caught in Snowdrift for 2 sec consecutively become Frozen in ice, stunned for 4 sec.
} )


-- Auras
spec:RegisterAuras( {
    active_blizzard = {
        duration = function () return 8 * haste end,
        max_stack = 1,
        generate = function( t )
            if query_time - action.blizzard.lastCast < 8 * haste then
                t.count = 1
                t.applied = action.blizzard.lastCast
                t.expires = t.applied + ( 8 * haste )
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
    fingers_of_frost = {
        id = 44544,
        duration = 15,
        max_stack = 2,
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
    freezing_winds = {
        id = 382106,
        duration = function() return spec.auras.frozen_orb.duration end,
        max_stack = 1,
        copy = 327478
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
        duration = 6,
        type = "Magic",
        max_stack = 2,
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

spec:RegisterStateExpr( "remaining_winters_chill", function ()
    local wc = debuff.winters_chill.stack

    if wc == 0 then return 0 end

    local projectiles = 0

    if prev_gcd[1].ice_lance and state:IsInFlight( "ice_lance" ) then projectiles = projectiles + 1 end
    if prev_gcd[1].frostbolt and state:IsInFlight( "frostbolt" ) then projectiles = projectiles + 1 end
    if prev_gcd[1].glacial_spike and state:IsInFlight( "glacial_spike" ) then projectiles = projectiles + 1 end

    return max( 0, wc - projectiles )
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


local brain_freeze_removed = 0

local lastCometCast = 0
local lastAutoComet = 0

spec:RegisterHook( "COMBAT_LOG_EVENT_UNFILTERED", function( _, subtype, _, sourceGUID, sourceName, _, _, destGUID, destName, destFlags, _, spellID, spellName )
    if sourceGUID == GUID then
        if subtype == "SPELL_CAST_SUCCESS" then
            if spellID == 116 then
                frost_info.last_target_actual = destGUID
            end

            --[[ if spellID == 44614 then
                frost_info.real_brain_freeze = FindUnitBuffByID( "player", 190446 ) ~= nil
            end ]]
        elseif subtype == "SPELL_AURA_REMOVED" and spellID == 190446 then
            brain_freeze_removed = GetTime()
        end

        if state.talent.glacial_spike.enabled and ( spellID == 205473 or spellID == 199844 ) and ( subtype == "SPELL_AURA_APPLIED" or subtype == "SPELL_AURA_REMOVED" or subtype == "SPELL_AURA_REFRESH" or subtype == "SPELL_AURA_APPLIED_DOSE" or subtype == "SPELL_AURA_REMOVED_DOSE" ) then
            Hekili:ForceUpdate( "ICICLES_CHANGED", true )
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



spec:RegisterGear( "tier31", 207288, 207289, 207290, 207291, 207293, 217232, 217234, 217235, 217231, 217233 )

spec:RegisterGear( "tier30", 202554, 202552, 202551, 202550, 202549 )

spec:RegisterGear( "tier29", 200318, 200320, 200315, 200317, 200319 )
spec:RegisterAura( "touch_of_ice", {
    id = 394994,
    duration = 6,
    max_stack = 1
} )


local FreezingWinds = setfenv( function()
    addStack( "fingers_of_frost" )
end, state )


spec:RegisterHook( "reset_precast", function ()
    --[[ if pet.rune_of_power.up then applyBuff( "rune_of_power", pet.rune_of_power.remains )
    else removeBuff( "rune_of_power" ) end --]]

    frost_info.last_target_virtual = frost_info.last_target_actual
    -- frost_info.virtual_brain_freeze = frost_info.real_brain_freeze

    if now - action.flurry.lastCast < gcd.execute and debuff.winters_chill.stack < 2 then applyDebuff( "target", "winters_chill", nil, 2 ) end

    -- Icicles take a second to get used.
    if not state.talent.glacial_spike.enabled and now - action.ice_lance.lastCast < gcd.max then removeBuff( "icicles" ) end

    incanters_flow.reset()

    if Hekili.ActiveDebug then
        Hekili:Debug( "Ice Lance in-flight?  %s\nWinter's Chill Actual Stacks?  %d\nremaining_winters_chill:  %d", state:IsInFlight( "ice_lance" ) and "Yes" or "No", state.debuff.winters_chill.stack, state.remaining_winters_chill )
    end

    local remaining_pet = class.auras.icy_veins.duration - action.icy_veins.time_since
    if remaining_pet > 0 then
        summonPet( "water_elemental", remaining_pet )
    end

    if buff.freezing_winds.up then
        local tick, expires = buff.freezing_winds.applied, buff.freezing_winds.expires

        for i = 1, ( talent.everlasting_frost.enabled and 4 or 3 ) do
            tick = tick + 3
            if tick > query_time and tick < expires then
                state:QueueAuraEvent( "freezing_winds", FreezingWinds, tick, "AURA_TICK" )
            end
        end
    end

    if  active_dot.glacial_spike > 0 and debuff.glacial_spike.down or
        active_dot.winters_chill > 0 and debuff.winters_chill.down or
        active_dot.freeze > 0 and debuff.freeze.down or
        active_dot.frostbite > 0 and debuff.frostbite.down or
        active_dot.frost_nova > 0 and debuff.frost_nova.down then
        active_dot.frozen = active_dot.frozen + 1
    end

end )

spec:RegisterHook( "runHandler", function( action )
    if buff.ice_floes.up then
        local ability = class.abilities[ action ]
        if ability and ability.cast > 0 and ability.cast < 10 then removeStack( "ice_floes" ) end
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

        handler = function ()
            applyBuff( "active_comet_storm" )
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

        usable = function () return talent.coldest_snap.enabled or target.maxR <= 12, "target must be nearby" end,
        handler = function ()
            applyDebuff( "target", talent.freezing_cold.enabled and "freezing_cold" or "cone_of_cold" )
            active_dot.cone_of_cold = max( active_enemies, active_dot.cone_of_cold )
            removeDebuffStack( "target", "winters_chill" )

            if talent.coldest_snap.enabled then
                setCooldown( "frozen_orb", 0 )
                setCooldown( "comet_storm", 0 )
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
        flightTime = 1,


        handler = function ()
            removeBuff( "brain_freeze" )
            applyDebuff( "target", "winters_chill", nil, 2 )
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

            if talent.frostfire_mastery.enabled then
                if buff.excess_frost.up then
                    removeBuff( "excess_frost" )
                    spec.abilities.ice_nova.handler()
                    reduceCooldown( "comet_storm", 5 )
                end

                if buff.frost_mastery.up and buff.frost_mastery.stacks == 5 then applyBuff( "excess_frost" ) end
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
            Hekili:Debug( "Winter's Chill applied by Flurry." )
            applyDebuff( "target", "winters_chill", nil, 2 )
            applyDebuff( "target", "flurry" )
            applyBuff( "bone_chilling", nil, 3 )
            if talent.frostfire_mastery.enabled then 
                if buff.frost_mastery.up then applyBuff( "frost_mastery", buff.frost_mastery.expires, min( buff.frost_mastery.stacks + 3, 6) )
                else applyBuff( "frost_mastery", nil, 3 ) end
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
        id = function() return talent.frostfire_bolt.enabled and 431044 or 116 end,
        cast = function ()
            if buff.frostfire_empowerment.up then return 0 end
            return 2 * ( 1 - 0.04 * buff.slick_ice.stack ) * haste
        end,
        cooldown = 0,
        gcd = "spell",
        school = function() return talent.frostfire_bolt.enabled and "frostfire" or "frost" end,

        spend = 0.02,
        spendType = "mana",

        startsCombat = true,
        velocity = 35,

        usable = function ()
            if moving and settings.prevent_hardcasts and action.frostbolt.cast_time > buff.ice_floes.remains then return false, "prevent_hardcasts during movement and ice_floes is down" end
            return true
        end,

        handler = function ()
            addStack( "icicles" )

            if action.frostbolt.cast_time > 0 then removeStack( "ice_floes" ) end

            if buff.frostfire_empowerment.up then
                applyBuff( "frost_mastery", nil, 6 )
                if talent.excess_frost.enabled then applyBuff( "excess_frost" ) end
                applyBuff( "fire_mastery", nil, 6 )
                if talent.excess_fire.enabled then applyBuff( "excess_fire" ) end
                removeBuff( "frostfire_empowerment" )
            end

            if talent.glacial_spike.enabled and buff.icicles.stack == buff.icicles.max_stack then
                applyBuff( "glacial_spike_usable" )
            end

            if talent.deaths_chill.enabled and buff.icy_veins.up then
                addStack( "deaths_chill", buff.icy_veins.remains, 1 )
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
            removeDebuffStack( "target", "winters_chill" )

            if talent.frostfire_bolt.enabled then
                applyDebuff( "target", "frostfire_bolt" )
            end
        end,

        copy = { 116, 228597, "frostfire_bolt", 431044 }
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
        velocity = 20,

        handler = function ()
            applyBuff( "frozen_orb" )
            if talent.freezing_rain.enabled then applyBuff( "freezing_rain" ) end
            if talent.freezing_winds.enabled then
                applyBuff( "freezing_winds" )
                state:QueueAuraEvent( "freezing_winds", FreezingWinds, query_time + 3, "AURA_TICK" )
                state:QueueAuraEvent( "freezing_winds", FreezingWinds, query_time + 6, "AURA_TICK" )
                state:QueueAuraEvent( "freezing_winds", FreezingWinds, query_time + 9, "AURA_TICK" )
                if talent.everlasting_frost.enabled then
                    state:QueueAuraEvent( "freezing_winds", FreezingWinds, query_time + 12, "AURA_TICK" )
                end
            end
            if talent.permafrost_lances.enabled then applyBuff( "permafrost_lances" ) end
        end,

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

            if buff.fingers_of_frost.up or debuff.frozen.up then
                if talent.chain_reaction.enabled then addStack( "chain_reaction" ) end
                if talent.thermal_void.enabled and buff.icy_veins.up then
                    buff.icy_veins.expires = buff.icy_veins.expires + 0.5
                    pet.water_elemental.expires = buff.icy_veins.expires
                end
            end

            if not talent.glacial_spike.enabled then removeStack( "icicles" ) end
            if talent.bone_chilling.enabled then addStack( "bone_chilling" ) end

            if azerite.whiteout.enabled then
                cooldown.frozen_orb.expires = max( 0, cooldown.frozen_orb.expires - 0.5 )
            end

            if buff.fingers_of_frost.up then
                removeStack( "fingers_of_frost" )
                if talent.cryopathy.enabled then addStack( "cryopathy" ) end
                if set_bonus.tier29_4pc > 0 then applyBuff( "touch_of_ice" ) end
            end
        end,



        impact = function ()
            if ( buff.fingers_of_frost.up or debuff.frozen.up ) and talent.hailstones.enabled then
                addStack( "icicles" )
                if talent.glacial_spike.enabled and buff.icicles.stack == buff.icicles.max_stack then
                    applyBuff( "glacial_spike_usable" )
                end
            end

            if talent.frostfire_mastery.enabled then
                if buff.excess_fire.up then
                    removeBuff( "excess_fire" )
                    applyBuff( "brain_freeze" )
                    if talent.perpetual_winter.enabled then gainCharges( "flurry", 1 ) else setCooldown( "flurry", 0 ) end
                    if buff.frost_mastery.up and buff.frost_mastery.stacks == 5 then applyBuff( "excess_frost" ) end
                end
            end

            removeDebuffStack( "target", "winters_chill" )
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
            removeDebuffStack( "target", "winters_chill" )
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

        tick  = function ()
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

        usable = function () return pet.water_elemental.alive, "requires water elemental" end,
        handler = function ()
            applyDebuff( "target", "freeze" )
        end
    },

    water_jet = {
        id = 135029,
        known = true,
        cast = 0,
        cooldown = 45,
        gcd = "off",
        school = "frost",

        startsCombat = true,
        usable = function ()
            if not settings.manual_water_jet then return false, "requires manual water jet setting" end
            return pet.water_elemental.alive, "requires a living water elemental"
        end,
        handler = function()
            addStack( "brain_freeze" )
            gainCharges( "flurry", 1 )
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


local ice_floes = GetSpellInfo( 108839 )

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

--[[ spec:RegisterSetting( "check_explosion_range", true, {
    name = strformat( "%s: Range Check", Hekili:GetSpellLinkWithTexture( 1449 ) ),
    desc = strformat( "If checked, %s will not be recommended when you are more than 10 yards from your target.", Hekili:GetSpellLinkWithTexture( 1449 ) ),
    type = "toggle",
    width = "full"
} ) ]]

spec:RegisterPack( "Frost Mage", 20241117, [[Hekili:T31EVnoos(plblGg7jD72soopwe7d4gGfyBC78pzb2)ZkkY0j6ABjFsYP7mWWF2psQx8rvuusoDpZGbdWKosufjRx)QQ4JSYD1)E1dRdYjR(vVPEx566EZe3PU3EL7QhYFBpz1d7dc)sWZ0)rCWo6))FKMKLF6X)f)r7dEBBsWAgnYsoKgsF0l557Z(7F6tphL)YHNMeMS7tzr7oSnipkjomnyto73d)0QhE6q028)z8QNKhatNT6HGd5VKKU6HhI29lusgTEnPODKSWvpWA3hDD)40zF40J0F6EZF)0JSME6Xd7zK60Np95Ign9JtVM1OPF0ZT8N3H14P39rVROV8xs2rOZWhYts3j(YPmkW(5Tf)0ZdLs3k(Y9PrjPr5VP3SBkgn)7xiNE8)eKs)FuMwu8Qh2gLLNX4QHBjbVs83SH(l)kxwrIdEAlz9Q)B6lPuLKgfqLdPKx9FoC9e3jB2EinL2xhpY656hhMet8t24hMSDnL)gYKgukWMQ(zSz6QCQaaTdE6WMntIcFZ)vsuC2Kd7p9OZPhhD6r(lwtcYFjZp8LOTBNKLtvyo949NE82IrbAtwWBcLoxC6XIr0KnmTRNs2Mpjk2FZ2ONFHkjgZBKYqiLSlG(ZtpUSIk5bBjX5Y9u1KPEgx3bS57m057i(KtKTw9DACw(B2eLs8lET0OnIkaZkMVSHkDgpJ3cfA882GWOGT(z7J(cP4TJmtdSUGY2NZFB4lbPptY83Kwm1d2Yz4E0UxGBWvwySIRqzffm6O4N9)Aum9zLSwo1CBivAWBm9lo3GrW5M1L2qjiJwvFI4eWRs56IAHQi1ReQf8PWeQgDYxJLBsT2Xyjr)VrI9tsFIn(UgD8v2Lmlfsg16ioyFtx6i0JcwpsQJUtLBxthd1mt83IwWMauNaKyYUisLkGOrSGPnDMDtBwXYAmlQ0ygjoK5kgC7CgtgDmQBxY(Cj2UKUnB8Dl64dIJLNEG4dW2KupeLeWAhITaKKJhUshgDL(IgoLCZz69tB4AzVeTjNXW3N8vskJTDx3fRgecUtBX(S2RgzhFiSJXrk97JOoG4L1fh3c2vqzVCrBUi7OwzZWlkK4VnioSGtWr90h5cJywRuXkQT(c2U1V4x8zW2fG3(fblTl5vcJXTI9FpqFCqcHf2Z6odN7iIiiBRXyfLASYyrn6SJ7bKpiaufaJqFMTFBb3x26R2EQD)BRj8os61LZnN(JdBgIDSqSjKVfsYYeu(aringSGzErjEUnEwGTiQzgTG2bgvqLmBSb0qC4)rw47ccZRaarUDfsZnSO6AE4LfF8sl6NX2PSx1rwjuqnPUWyeLvDZFsHSmRizcMQL4(oRrFykkd847mbB0IQLXrJ54HBjQSZniicy3T2G1PgPrpG6O4C(zzMr5SooBO4N1ageSwGGgkjGfbWdyvb7aO2DnqsPwK9llkExpfSz5i5XbN3Ksi)g75IaOftZgWcmfhrnakziMr3Ah)2I(XI8mXGMWDOyu6OhdOEfdAP(f31E9lURYi1y9lqcm(ArJrX4YKnhVrSzpTn63(TG01kTXICQmcEFUs84D0HERzSO7bflIFCFsgv2H0NDTYgLnPHYI)w5ryCYRbnjB0MBAxvBPE4NM(4FVuBrK6y1U7NrgZGO2c(P0aMnj3JxTM4zj()2aYWqPC6CPDW9E(9n4kCFYMcUspABr8s3Reejz7FBxqg)7)k5jvHIASvxRyUuHEa4hfCq)xPbasxtGc4aosMu0qOBPOrvvLUTqRTPubDeh4oR8YQc70dVSSOHBZnBBorARAYxnSyI7RgPKsZCfsHMHEFc5DuLoocYJQ5Auws(lK0DrH0xtvdvSy1OfqUv0giaIBQ(j4GdDQtaIZZgV(DBz5oBH1Axq2DFz5WrxmYm1DTczkPOj3O)qh6bRFZkBnVP1LpcJuAUOXlblELkSklpP5SelrEsBOwOqjeIJwkpQQejjB2WPEbfaCgH3PIH(IJRCE62Ip1MGE4QK1Jl8KGSeO(ktOPTMBJPvJ5cSWybExbEmIDxBluJHm9uY1PxXB2s6F4idMeOcUd1saqcRsI7jz4aZCT3KQjxrCuc8AaY6hzlFr1Q80GxjB9ZJ21RYbQLcPnmvWPgUpBOuCUQtEU0GHTiidKeRX912gUHdCYA3GhkJ7nwfFPQhVEeFz9VzmcZQwnznLomnaTA)qd6i(lwLSonE2TjeO1vL)86qI0ecYtEJQF9rC4HloW1q3fehmzFyoNFmdFpxiq8G0Wak5jFB)2Km2t0YcLRqUnitvEFJkBPWyuUr4OGDqi2AD7Sqiwam1Iu0aUX5xmAah4mjhvQ(gMGSW3zlsYCE9ZOrg8uqJ1PsNZ8TUDljuTdK2xc7Istts9J2X33LsTtfvjHIVNrYB(2xdOSNNyzx8AW2dK6Cnrwy0cVRJKKCmaP4CP2urKTrHFXNo9HEjAP5B8DZIVop5q4lsjOXC73ssKoY1MHS3p7LGC60PbcGoXl9xkU1la87ynlddSrQNOP6d4VP9(GLPWp368(sQc8mXgckgfhsSOdO8yQju4kJ5BaASikVyA5mCPgMSgymLghsjRHcKcmsajhx1P8IN9HkrUxUIPIb0MZ2WWBcoSv30lm5aNLTNWINr3StORTcpoCDgKPOw5DmOmJWDYYtJczUBAgjPhIrhiLLAYsS1ooCM1RHtwMz43(nw8aFZ99Au2SlRnAE0l(wbEt)gqfCoCBbRgq)XXx(iJUZh4aDmOqWOrTcObEqzTao0J(TqvepcU2K89Qt5QB5v)ZUUOGoTSPlTE9ah6QamYYnmOnPSJ7qVQ(g(PKawiNoYv9aUIOEEcLuqUUT9yR5z3s7ZhAQvJrzF0mGTKxZW(pB7fmJAZDC7DzQa5MQv)TWr2yWx0qwMnafLF8lEgl0kJ(ImWGDRwRJKScDDffD2MUFE1jBlA3Es6gAEy(bzHK410z6B(zK0d7eyb4TXOpnY)3HO97jRvwy7kTDdJV5tvwZcKvp3RgRLIn0)UB2ub)KvfxVUl5MzLjvW879cjn5qMFEAqC2UigADdRcRbg9QAy)b452bz5thOPdXmq)sCYxP9YZIlTM(7m6M1uhc7pxsWCNfCD3PZfiKGqlLSpjnxCldoZtyfmnP6xsXAvbe5bKRor6CNGmxwBsWZV8Zn753GU3CZCtPTqHYNZQ4t1u2KPYLfMkl1iGa(X(e(pbaoyN)00O9fn7FfeFGDQ6cFji(zcRg1j7OHLrt2EX0pC6XV(su4l0FND4oZI2r7Idze2KlV8HbRxNqJyjmioojxkCsE18PmKPtWZYXdkCLUJcr7fMf(UGVXlPGNO3(YgxJ3u9g68WNs3DzkE7LGeEABscnvJd0bgeMqDZOknK0VqbJuBMu(68LCoZ))9W6N5idkTv(i8qdgM37QTsQUEmCmAmY0WeyyrYnnxmdSEehm2(jQphdN)yen85zla)JC9UX9ybUWZCEPDl5mYkDp0nTwRHM3TtLdMFzBsc4JNE86EVFXAB9bAFBh9J94226YSC(2E0SxkRnkmP5lRD5EyPN7J6Zw2qgwrO2QM0i5YjtNvSXdBP7LA2aYQIkcCNPuwQE0nEE6BxK6DsrllGApoTpiPH9DBRItF1R0Hm7ReUOo(AqktFHgja)sSGMEenCvQsAcnUYFQUSQ)etNMghAkJRMLWIUj4qEYUGC2dkIFkBYPp))eftFLh)o4iM2B8x)taAmucMNa)QkXhTjJC)24AQohMQIAUkufAt0Qs1RHPQOZmfQc5NtLQ3Ir1AhGAevBpBAjn798)0NbK4cvmTBYCx4rNCXnvgFWv(uDEJOnjTOzkegCb1uP7SVV0T3YPcQE17g)fHYdMpGq3b6faHQdYYcHMduIH4zzqsmqB2ILO7SyUoq3EiuDGICeh)9MQyo(6kmhIH(a5H3CMNTgP6GmBqOzVnBqvU7QG57QY9GyHF3rnvotfkKg5exyP)YbQIIyMpqPgIxyPiZvilyjj0KCimyXTzScDH2GYAKfHlm8XlcHpdQAUN7yObDeuUrG6MNaex0NHj97x8yVFcQ3Jismcf8(r5MTbdGML8(JXskwVJuuiO2ovXs6nqVH4C069OJo)uB77ypvFNKtI7dinUG(weYsQ(7mzfsM5NbU6DVdug07A9EC(S4FDW5oAi06EA1Jns7RMec9gOMeoE1qS6F)qbr5cdYQ)pIyRiuEWwciy2n7JBfIQVbVTKIkB8BnMqa02cVfVkv1FUBovqlXtpdNSmk1ZDwHGZ46vD(SmLhCu)O1HUNZzZSYb68dJSslUJMEjWc)8DGWN(8)Kl3zKZ1T6y2F6r(9(n99SfupztuZfcq2KAi2lx8j1do0Ppd1kXJmeClQobkFGTEplekE)h4NiLfqEACUyKGSUa10PQHvWEoaYnNghI1qoJpEe0nPZfa(7TCoSzJ8OxMY2qeHZltjPCN(ZGu7sVz)metcUxQoGlFiAZc5fzE5cphnpW1mbfVNhpQ(Xxb3F8wZgM6D49lMX0cl)kABfpqmspxzbcl4qHRZeBKYrzOOnfLE7df7d9fUSXaSSgF2yI0zzsK(c7O9SwPD9Iw2JrUNdax2U(RptNfETlPenQTOd((yCpcW62QUzSvtyBKDwriRekc2rtk055MtnBseHXGi8OJHnSYYRCgTh8E854X9q3Hp1(kKAQPToZs35oWtOXaZNMEInBgn6I9WxcphpwrtLIbp2r6BKc)G(r17QLXq9UOJtROc8mOXzO25VWzeY(f5(7oEe5vlUZ5IIUzsnXBUFCg7aV3rwElKInOkuTmZ48MYyb0UKe(QxYngv98ME84iJxRnlDNckMk2dsSbBTGWrFt81mEveFytqOUQAJ0j3zxaCLWizi1kD5cYbtzNlq2jvqDP8ELJ1TTEJYS09kR0WBSRLV2yCUG)AL70eLNgvC1TP3pstvbRjH952I5oJQzEIQt170TJhXyrGIf(NXndq(SsdyL74LApCIt1sdALzF31)47bRgET(w664rWlULLcxAlOSHEXeAXqrnCLRqnff8hJasybMhKBjTqMUXKImuNaIvxvPavS4SSHJf3vKytGUJB44IE)l1i1WkU)wuWNLlC9gdmzT0hm6UvgGI1QDiADlM2jYjfjbCdACJbfQjkU65hdhuBQ5ovu)TvrQa8kd(5H3x1uywaYyP33U4XfOxSY)w)uwq6nnmx90CV1K2cKOYAFf08zPTV6CTu0o8J6hqeK1ImMQwswMJ0UO)EV5M7lKZMfRJqokFuLD9Uz(uHW(09Mq9yqDT3fcoBAPxoTtcivP5V93QkCv1KADIpYmXppi7lFGnPlPurgvY9Ml1DxHnCy6B7ZPzoqFk1IOSpQA2)fVj0(HAJYvWIjFJ2BH8k09mHQ06VoQ6FQ8vKu6yk3NDtbTjH2cAGrrzSn1CTh67hv6pq2ELgUaj8qoHJAFPBvvFe3ssJnlJ1p2H46r3752l9izrkN(aeXdfVX9oq1a3PZl)eKJM4YfZ8gx6)fWOG(1TDmeX8QFNgxT405Hm3MnhBUr9MsJjvSXlNXgy42lx66Tu6dy68S)YxEgp2FQtUg)NmcE)0j6LuYt9BQh4g0NkpJF)S2hxFw(GSNJIFn5lSBhlQakMI5WiEHIg3MGAEU5qwLWG1XYpU4mB1j6s97tnhPgDu7KSd72v4dSi0ETxvsFzA3CUd1EdP6OgQ(gLtxOMqjQ8afQ(c5ZqOeGsvveVulr(9QhzqPajLUrJbjxFlKbESKlU99OqgsJ5A16rJ2dCAevJLwSAuo6b4WkK7y8e2Qqr0(gisD)Ch9)uzUqm2AXjIO)Etr54Ik7ec(foUQYHLxtQcIDQGdlO)eGHmS7ukqGflCQXAgrFnEYbQHXndEmArGTzDmYwvnx2NHWHmeD(g4R0FoGI9LDv5th3nXR6xdIBj2O79Moe2Sbxp1wMnQWyLzcrSatCRs5WXq5F7GsqlEwrmISpDIQ10XcV)ArnbRKAB2voONgCN298Iv2l4Xq7j9l9D2vyIbuCyXEZq9HRp52wvzy5Pq9FYeaFFFYW3X0zZgky8LTqZpEnYO)35yaVtf344XgXp4HLgHBzjqVvoxSRSwJAk0QWEhbp4lS48w4otyHxTGuEab7yFrGW9i3cFarl1ANSvpJhh(B(8R9y2av7gswQoAcFv9fDSGIgr4krg9JyowaFzVQaUh8us5IjMpZkVFJxot3GcMkfy1SlVy0jdxalYxf2Xa9f(czH)hJ1jcPhOBWF)8AYjThBOrq9(GckpOna9aVqs4Zs51qhAorZCboQqyRp(eYy(aaz8C)8XOdrDeSrdgctc96s3PTbGHTTrOYBewgOgi06Smgea73nb1dlSWKvwGv218Lq7lBrdbfCODNywYY93arESyvv1mnvbLuCd(xWs)4HLoxvtRIunWoW1fchEzek(sPRAL9HGnifwxOg4LJ2ui2vu)D3LrxQrg2YfCV7v6l2qXFeib6mOCYQEhaA2FwGk0NS6UmL3ipOAZE4(NnfhfMxzqreGZ1owsf(UX0cZFZjKvrLFufsPU)LcfSsK7ZVkPDGc5QjxnT13s1S48vkI(hcN(a6D31Z5lRDbHe6cT0EA43Qtqjt0UBoQjFum2WsVU20XOXg7wCLeU6xV(k(L91Q)))]] )