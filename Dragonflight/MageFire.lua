-- MageFire.lua
-- November 2022

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
    accumulative_shielding   = { 62093, 382800, 2 }, -- Your barrier's cooldown recharges 20% faster while the shield persists.
    alter_time               = { 62115, 342245, 1 }, -- Alters the fabric of time, returning you to your current location and health when cast a second time, or after 10 seconds. Effect negated by long distance or death.
    arcane_warding           = { 62114, 383092, 2 }, -- Reduces magic damage taken by 3%.
    blast_wave               = { 62103, 157981, 1 }, -- Causes an explosion around yourself, dealing 916 Fire damage to all enemies within 8 yards, knocking them back, and reducing movement speed by 70% for 6 sec.
    cryofreeze               = { 62107, 382292, 2 }, -- While inside Ice Block, you heal for 40% of your maximum health over the duration.
    displacement             = { 62092, 389713, 1 }, -- Teleports you back to where you last Blinked. Only usable within 8 sec of Blinking.
    diverted_energy          = { 62101, 382270, 2 }, -- Your Barriers heal you for 10% of the damage absorbed.
    dragons_breath           = { 62091, 31661 , 1 }, -- Enemies in a cone in front of you take 1,130 Fire damage and are disoriented for 4 sec. Damage will cancel the effect. Always deals a critical strike and contributes to Hot Streak.
    energized_barriers       = { 62100, 386828, 1 }, -- When your barrier receives melee attacks, you have a 10% chance to be granted 1 Fire Blast charge. Casting your barrier removes all snare effects.
    flow_of_time             = { 62096, 382268, 2 }, -- The cooldown of Blink is reduced by 2.0 sec.
    freezing_cold            = { 62087, 386763, 1 }, -- Enemies hit by Cone of Cold are frozen in place for 5 sec instead of snared. When your roots expire or are dispelled, your target is snared by 80%, decaying over 3 sec.
    frigid_winds             = { 62128, 235224, 2 }, -- All of your snare effects reduce the target's movement speed by an additional 10%.
    greater_invisibility     = { 62095, 110959, 1 }, -- Makes you invisible and untargetable for 20 sec, removing all threat. Any action taken cancels this effect. You take 60% reduced damage while invisible and for 3 sec after reappearing.
    ice_block                = { 62122, 45438 , 1 }, -- Encases you in a block of ice, protecting you from all attacks and damage for 10 sec, but during that time you cannot attack, move, or cast spells. While inside Ice Block, you heal for 40% of your maximum health over the duration. Causes Hypothermia, preventing you from recasting Ice Block for 30 sec.
    ice_floes                = { 62105, 108839, 1 }, -- Makes your next Mage spell with a cast time shorter than 10 sec castable while moving. Unaffected by the global cooldown and castable while casting.
    ice_nova                 = { 62126, 157997, 1 }, -- Causes a whirl of icy wind around the enemy, dealing 2,328 Frost damage to the target and reduced damage to all other enemies within 8 yards, and freezing them in place for 2 sec.
    ice_ward                 = { 62086, 205036, 1 }, -- Frost Nova now has 2 charges.
    improved_frost_nova      = { 62108, 343183, 1 }, -- Frost Nova duration is increased by 2 sec.
    incantation_of_swiftness = { 62112, 382293, 2 }, -- Invisibility increases your movement speed by 40% for 6 sec.
    incanters_flow           = { 62113, 1463  , 1 }, -- Magical energy flows through you while in combat, building up to 20% increased damage and then diminishing down to 4% increased damage, cycling every 10 sec.
    invisibility             = { 62118, 66    , 1 }, -- Turns you invisible over 3 sec, reducing threat each second. While invisible, you are untargetable by enemies. Lasts 20 sec. Taking any action cancels the effect.
    mass_polymorph           = { 62106, 383121, 1 }, -- Transforms all enemies within 10 yards into sheep, wandering around incapacitated for 1 min. While affected, the victims cannot take actions but will regenerate health very quickly. Damage will cancel the effect. Only works on Beasts, Humanoids and Critters.
    mass_slow                = { 62109, 391102, 1 }, -- Slow applies to all enemies within 5 yds of your target.
    master_of_time           = { 62102, 342249, 1 }, -- Reduces the cooldown of Alter Time by 10 sec. Alter Time resets the cooldown of Blink when you return to your original location.
    meteor                   = { 62090, 153561, 1 }, -- Calls down a meteor which lands at the target location after 3 sec, dealing 5,044 Fire damage, split evenly between all targets within 8 yards, and burns the ground, dealing 1,280 Fire damage over 8.5 sec to all enemies in the area.
    mirror_image             = { 62124, 55342 , 1 }, -- Creates 3 copies of you nearby for 40 sec, which cast spells and attack your enemies. While your images are active damage taken is reduced by 20%. Taking direct damage will cause one of your images to dissipate.
    overflowing_energy       = { 62120, 390218, 1 }, -- Your spell critical strike damage is increased by 10%. When your direct damage spells fail to critically strike a target, your spell critical strike chance is increased by 2%, up to 10% for 8 sec. When your spells critically strike Overflowing Energy is reset.
    quick_witted             = { 62104, 382297, 1 }, -- Successfully interrupting an enemy with Counterspell reduces its cooldown by 4 sec.
    reabsorption             = { 62125, 382820, 1 }, -- You are healed for 5% of your maximum health whenever a Mirror Image dissipates due to direct damage.
    reduplication            = { 62125, 382569, 1 }, -- Mirror Image's cooldown is reduced by 10 sec whenever a Mirror Image dissipates due to direct damage.
    remove_curse             = { 62116, 475   , 1 }, -- Removes all Curses from a friendly target.
    rigid_ice                = { 62110, 382481, 1 }, -- Frost Nova can withstand 80% more damage before breaking.
    ring_of_frost            = { 62088, 113724, 1 }, -- Summons a Ring of Frost for 10 sec at the target location. Enemies entering the ring are incapacitated for 10 sec. Limit 10 targets. When the incapacitate expires, enemies are slowed by 65% for 4 sec.
    rune_of_power            = { 62113, 116011, 1 }, -- Places a Rune of Power on the ground for 12 sec which increases your spell damage by 40% while you stand within 8 yds. Casting Combustion will also create a Rune of Power at your location.
    shifting_power           = { 62085, 382440, 1 }, -- Draw power from the Night Fae, dealing 4,113 Nature damage over 3.5 sec to enemies within 18 yds. While channeling, your Mage ability cooldowns are reduced by 12 sec over 3.5 sec.
    shimmer                  = { 62105, 212653, 1 }, -- Teleports you 20 yards forward, unless something is in the way. Unaffected by the global cooldown and castable while casting. Gain a shield that absorbs 3% of your maximum health for 15 sec after you Shimmer.
    slow                     = { 62097, 31589 , 1 }, -- Reduces the target's movement speed by 50% for 15 sec.
    spellsteal               = { 62084, 30449 , 1 }, -- Steals a beneficial magic effect from the target. This effect lasts a maximum of 2 min.
    tempest_barrier          = { 62111, 382289, 2 }, -- Gain a shield that absorbs 3% of your maximum health for 15 sec after you Blink.
    temporal_velocity        = { 62099, 382826, 2 }, -- Increases your movement speed by 5% for 2 sec after casting Blink and 20% for 5 sec after returning from Alter Time.
    temporal_warp            = { 62094, 386539, 1 }, -- While you have Temporal Displacement or other similar effects, you may use Time Warp to grant yourself 30% Haste for 40 sec.
    time_anomaly             = { 62094, 383243, 1 }, -- At any moment, you have a chance to gain Combustion for 5 sec, 1 Fire Blast charge, or Time Warp for 6 sec.
    time_manipulation        = { 62129, 387807, 2 }, -- Casting Fire Blast reduces the cooldown of your loss of control abilities by 1 sec.
    tome_of_antonidas        = { 62098, 382490, 1 }, -- Increases Haste by 2%.
    tome_of_rhonin           = { 62127, 382493, 1 }, -- Increases Critical Strike chance by 2%.
    volatile_detonation      = { 62089, 389627, 1 }, -- Greatly increases the effect of Blast Wave's knockback. Blast Wave's cooldown is reduced by 5 seconds.
    winters_protection       = { 62123, 382424, 2 }, -- The cooldown of Ice Block is reduced by 20 sec.

    -- Fire
    alexstraszas_fury        = { 62220, 235870, 1 }, -- Phoenix Flames and Dragon's Breath always critically strikes and Dragon's Breath deals 50% increased critical strike damage contributes to Hot Streak.
    blazing_barrier          = { 62119, 235313, 1 }, -- Shields you in flame, absorbing 8,622 damage for 1 min. Melee attacks against you cause the attacker to take 242 Fire damage.
    call_of_the_sun_king     = { 62210, 343222, 1 }, -- Phoenix Flames gains 1 additional charge.
    cauterize                = { 62206, 86949 , 1 }, -- Fatal damage instead brings you to 35% health and then burns you for 28% of your maximum health over 6 sec. While burning, movement slowing effects are suppressed and your movement speed is increased by 150%. This effect cannot occur more than once every 5 min.
    combustion               = { 62207, 190319, 1 }, -- Engulfs you in flames for 10 sec, increasing your spells' critical strike chance by 100% . Castable while casting other spells.
    conflagration            = { 62188, 205023, 1 }, -- Fireball applies Conflagration to the target, dealing an additional 145 Fire damage over 8 sec. Enemies affected by either Conflagration or Ignite have a 10% chance to flare up and deal 131 Fire damage to nearby enemies.
    controlled_destruction   = { 62204, 383669, 2 }, -- Pyroblast's initial damage is increased by 5% when the target is above 70% health or below 30% health.
    critical_mass            = { 62219, 117216, 2 }, -- Your spells have a 15% increased chance to deal a critical strike. You gain 10% more of the Critical Strike stat from all sources.
    feel_the_burn            = { 62195, 383391, 2 }, -- Fire Blast increases your Mastery by 3% for 5 sec. This effect stacks up to 3 times.
    fervent_flickering       = { 62216, 387044, 1 }, -- Ignite's damage has a 5% chance to reduce the cooldown of Fire Blast by 1 sec.
    fevered_incantation      = { 62187, 383810, 2 }, -- Each consecutive critical strike you deal increases critical strike damage you deal by 1%, up to 5% for 6 sec.
    fiery_rush               = { 62203, 383634, 1 }, -- While Combustion is active, your Fire Blast and Phoenix Flames recharge 50% faster.
    fire_blast               = { 62214, 108853, 1 }, -- Blasts the enemy for 2,047 Fire damage. Fire: Castable while casting other spells. Always deals a critical strike.
    firefall                 = { 62197, 384033, 1 }, -- Damaging an enemy with 30 Fireballs or Pyroblasts causes your next Fireball to call down a Meteor on your target. Hitting an enemy player counts as double.
    firemind                 = { 62208, 383499, 2 }, -- Consuming Hot Streak grants you 1% increased Intellect for 12 sec. This effect stacks up to 3 times.
    firestarter              = { 62083, 205026, 1 }, -- Your Fireball and Pyroblast spells always deal a critical strike when the target is above 90% health.
    flame_accelerant         = { 62200, 203275, 2 }, -- If you have not cast Fireball for 8 sec, your next Fireball will deal 70% increased damage with a 40% reduced cast time.
    flame_on                 = { 62190, 205029, 2 }, -- Reduces the cooldown of Fire Blast by 2 seconds and increases the maximum number of charges by 1.
    flame_patch              = { 62193, 205037, 1 }, -- Flamestrike leaves behind a patch of flames that burns enemies within it for 788 Fire damage over 8 sec.
    flamestrike              = { 62192, 2120  , 1 }, -- Calls down a pillar of fire, burning all enemies within the area for 1,240 Fire damage and reducing their movement speed by 20% for 8 sec.
    from_the_ashes           = { 62220, 342344, 1 }, -- Increases Mastery by 2% for each charge of Phoenix Flames off cooldown and your direct-damage critical strikes reduce its cooldown by 1 sec.
    hyperthermia             = { 62186, 383860, 1 }, -- When Hot Streak activates, you have a low chance to cause all Pyroblasts and Flamestrikes to have no cast time and be guaranteed critical strikes for 5 sec.
    improved_combustion      = { 62201, 383967, 1 }, -- Combustion grants Mastery equal to 50% of your Critical Strike stat and lasts 2 sec longer.
    improved_flamestrike     = { 62191, 343230, 1 }, -- Flamestrike's cast time is reduced by 1.0 sec and its radius is increased by 15%.
    improved_scorch          = { 62211, 383604, 2 }, -- Casting Scorch on targets below 30% health increase the target's damage taken from you by 4% for 8 sec, stacking up to 3 times. Additionally, Scorch critical strikes increase your movement speed by 30% for 3 sec.
    incendiary_eruptions     = { 62189, 383665, 1 }, -- Enemies damaged by Flame Patch have an 5% chance to erupt into a Living Bomb.
    kindling                 = { 62198, 155148, 1 }, -- Your Fireball, Pyroblast, Fire Blast, and Phoenix Flames critical strikes reduce the remaining cooldown on Combustion by 1.0 sec.
    living_bomb              = { 62194, 44457 , 1 }, -- The target becomes a Living Bomb, taking 581 Fire damage over 3.5 sec, and then exploding to deal an additional 340 Fire damage to the target and reduced damage to all other enemies within 10 yards. Other enemies hit by this explosion also become a Living Bomb, but this effect cannot spread further.
    master_of_flame          = { 62196, 384174, 1 }, -- Ignite deals 15% more damage while Combustion is not active. Fire Blast spreads Ignite to 4 additional nearby targets during Combustion.
    phoenix_flames           = { 62217, 257541, 1 }, -- Hurls a Phoenix that deals 1,641 Fire damage to the target and reduced damage to other nearby enemies. Always deals a critical strike.
    phoenix_reborn           = { 62199, 383476, 1 }, -- Targets affected by your Ignite have a chance to erupt in flame, taking 242 additional Fire damage and reducing the remaining cooldown of Phoenix Flames by 10 sec.
    pyroblast                = { 62215, 11366 , 1 }, -- Hurls an immense fiery boulder that causes 2,929 Fire damage. Pyroblast's initial damage is increased by 5% when the target is above 70% health or below 30% health.
    pyroclasm                = { 62209, 269650, 1 }, -- Consuming Hot Streak has a 15% chance to make your next non-instant Pyroblast cast within 15 sec deal 230% additional damage. Maximum 2 stacks.
    pyromaniac               = { 62197, 205020, 1 }, -- Casting Pyroblast or Flamestrike while Hot Streak is active has an 8% chance to instantly reactivate Hot Streak.
    pyrotechnics             = { 62218, 157642, 1 }, -- Each time your Fireball fails to critically strike a target, it gains a stacking 10% increased critical strike chance. Effect ends when Fireball critically strikes.
    scorch                   = { 62213, 2948  , 1 }, -- Scorches an enemy for 397 Fire damage. Castable while moving.
    searing_touch            = { 62212, 269644, 1 }, -- Scorch deals 150% increased damage and is a guaranteed Critical Strike when the target is below 30% health.
    sun_kings_blessing       = { 62205, 383886, 1 }, -- After consuming 8 Hot Streaks, your next non-instant Pyroblast or Flamestrike cast within 15 sec grants you Combustion for 6 sec.
    tempered_flames          = { 62201, 383659, 1 }, -- Pyroblast has a 30% reduced cast time and a 10% increased critical strike chance. The duration of Combustion is reduced by 50%.
    wildfire                 = { 62202, 383489, 2 }, -- Ignite deals 5% additional damage. When you activate Combustion, you gain 4% Critical Strike, and up to 4 nearby allies gain 1% Critical Strike for 10 sec.
} )


-- PvP Talents
spec:RegisterPvpTalents( {
    flamecannon       = 647 , -- (203284) After standing still in combat for 2 sec, your maximum health increases by 3%, damage done increases by 3%, and range of your Fire spells increase by 3 yards. This effect stacks up to 5 times and lasts for 3 sec.
    glass_cannon      = 5495, -- (390428) Increases damage of Fireball and Scorch by 40% but decreases your maximum health by 15%.
    greater_pyroblast = 648 , -- (203286) Hurls an immense fiery boulder that deals up to 35% of the target's total health in Fire damage.
    ice_wall          = 5489, -- (352278) Conjures an Ice Wall 30 yards long that obstructs line of sight. The wall has 40% of your maximum health and lasts up to 15 sec.
    netherwind_armor  = 53  , -- (198062) Reduces the chance you will suffer a critical strike by 10%.
    precognition      = 5493, -- (377360) If an interrupt is used on you while you are not casting, gain 15% haste and become immune to control and interrupt effects for 4 sec.
    prismatic_cloak   = 828 , -- (198064) After you Shimmer, you take 50% less magical damage for 2 sec.
    pyrokinesis       = 646 , -- (203283) Your Fireball reduces the cooldown of your Combustion by 2 sec.
    ring_of_fire      = 5389, -- (353082) Summons a Ring of Fire for 8 sec at the target location. Enemies entering the ring burn for 24% of their total health over 6 sec.
    world_in_flames   = 644 , -- (203280) Flamestrike reduces the cast time of Flamestrike by 50% and increases its damage by 30% for 3 sec.
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
            return ( talent.improved_combustion.enabled and 12 or 10 )
                * ( talent.tempered_flames.enabled and 0.5 or 1 )
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
    -- Talent: Deals $w1 Fire damage every $t1 sec.
    -- https://wowhead.com/beta/spell=226757
    conflagration = {
        id = 226757,
        duration = 8,
        tick_time = 2,
        type = "Magic",
        max_stack = 1
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
        max_stack = 5,
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
    firefall = {
        id = 384035,
        duration = 30,
        max_stack = 30
    },
    firefall_ready = {
        id = 384038,
        duration = 30,
        max_stack = 1
    },
    -- Talent: Increases Intellect by $w1%.
    -- https://wowhead.com/beta/spell=383501
    firemind = {
        id = 383501,
        duration = 12,
        max_stack = 3
    },
    -- Talent: Cast time of your Fireball reduced by $203275m1%, and damage increased by $203275m2%.
    -- https://wowhead.com/beta/spell=203278
    flame_accelerant = {
        id = 203278,
        duration = 8,
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
    -- Frozen in place.
    -- https://wowhead.com/beta/spell=122
    frost_nova = {
        id = 122,
        duration = function() return talent.improved_frost_nova.enabled and 8 or 6 end,
        type = "Magic",
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
        max_stack = 3
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
    -- Talent: Damage done by your next non-instant Pyroblast increased by $s1%.
    -- https://wowhead.com/beta/spell=269651
    pyroclasm = {
        id = 269651,
        duration = 15,
        max_stack = 2
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
    -- Talent: Spell damage increased by $w1%.$?$w2=0[][  Health restored by $w2% per second.]
    -- https://wowhead.com/beta/spell=116014
    rune_of_power = {
        id = 116014,
        duration = 12,
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
    sun_kings_blessing = {
        id = 383882,
        duration = 30,
        max_stack = 8,
        copy = 333314
    },
    -- Talent: Your next non-instant Pyroblast will grant you Combustion.
    -- https://wowhead.com/beta/spell=383883
    sun_kings_blessing_ready = {
        id = 383883,
        duration = 15,
        max_stack = 5,
        copy = 333315,
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
    -- https://wowhead.com/beta/spell=383493
    wildfire = {
        id = 383493,
        duration = 10,
        max_stack = 1
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


spec:RegisterStateTable( "firestarter", setmetatable( {}, {
    __index = setfenv( function( t, k )
        if k == "active" then return talent.firestarter.enabled and target.health.pct > 90
        elseif k == "remains" then
            if not talent.firestarter.enabled or target.health.pct <= 90 then return 0 end
            return target.time_to_pct_90
        end
    end, state )
} ) )

spec:RegisterStateTable( "searing_touch", setmetatable( {}, {
    __index = setfenv( function( t, k )
        if k == "active" then return talent.searing_touch.enabled and target.health.pct < 30
        elseif k == "remains" then
            if not talent.searing_touch.enabled or target.health.pct < 30 then return 0 end
            return target.time_to_die
        end
    end, state )
} ) )

spec:RegisterTotem( "rune_of_power", 609815 )


spec:RegisterGear( "tier30", 202554, 202552, 202551, 202550, 202549 )
spec:RegisterAuras( {
    charring_embers = {
        id = 408665,
        duration = 12,
        max_stack = 1
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


spec:RegisterHook( "reset_precast", function ()
    if pet.rune_of_power.up then applyBuff( "rune_of_power", pet.rune_of_power.remains )
    else removeBuff( "rune_of_power" ) end

    incanters_flow.reset()
end )

spec:RegisterHook( "runHandler", function( action )
    if buff.ice_floes.up then
        local ability = class.abilities[ action ]
        if ability and ability.cast > 0 and ability.cast < 10 then removeStack( "ice_floes" ) end
    end
end )

spec:RegisterHook( "advance", function ( time )
    if Hekili.ActiveDebug then Hekili:Debug( "\n*** Hot Streak (Advance) ***\n    Heating Up:  %.2f\n    Hot Streak:  %.2f\n", state.buff.heating_up.remains, state.buff.hot_streak.remains ) end
end )

spec:RegisterStateFunction( "hot_streak", function( willCrit )
    willCrit = willCrit or buff.combustion.up or stat.crit >= 100

    if Hekili.ActiveDebug then Hekili:Debug( "*** HOT STREAK (Cast/Impact) ***\n    Heating Up: %s, %.2f\n    Hot Streak: %s, %.2f\n    Crit: %s, %.2f", buff.heating_up.up and "Yes" or "No", buff.heating_up.remains, buff.hot_streak.up and "Yes" or "No", buff.hot_streak.remains, willCrit and "Yes" or "No", stat.crit ) end

    if willCrit then
        if buff.heating_up.up then removeBuff( "heating_up" ); applyBuff( "hot_streak" )
        elseif buff.hot_streak.down then applyBuff( "heating_up" ) end

        if talent.fevered_incantation.enabled then addStack( "fevered_incantation" ) end
        if talent.from_the_ashes.enabled then gainChargeTime( "phoenix_flames", 1 ) end

        if Hekili.ActiveDebug then Hekili:Debug( "*** HOT STREAK END ***\nHeating Up: %s, %.2f\nHot Streak: %s, %.2f", buff.heating_up.up and "Yes" or "No", buff.heating_up.remains, buff.hot_streak.up and "Yes" or "No", buff.hot_streak.remains ) end
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
    -- "scorch",
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

-- # APL Variable Option: If set to a non-zero value, the Combustion action and cooldowns that are constrained to only be used when Combustion is up will not be used during the simulation.
-- actions.precombat+=/variable,name=disable_combustion,op=reset
spec:RegisterVariable( "disable_combustion", function ()
    return false
end )

-- # APL Variable Option: This variable specifies whether Combustion should be used during Firestarter.
-- actions.precombat+=/variable,name=firestarter_combustion,default=-1,value=runeforge.sun_kings_blessing|talent.sun_kings_blessing,if=variable.firestarter_combustion<0
spec:RegisterVariable( "firestarter_combustion", function ()
    return talent.sun_kings_blessing.enabled or runeforge.sun_kings_blessing.enabled
end )

-- # APL Variable Option: This variable specifies the number of targets at which Hot Streak Flamestrikes outside of Combustion should be used.
-- actions.precombat+=/variable,name=hot_streak_flamestrike,if=variable.hot_streak_flamestrike=0,value=2*talent.flame_patch+999*!talent.flame_patch
spec:RegisterVariable( "hot_streak_flamestrike", function ()
    if talent.flame_patch.enabled then return 2 end
    return 999
end )

-- # APL Variable Option: This variable specifies the number of targets at which Hard Cast Flamestrikes outside of Combustion should be used as filler.
-- actions.precombat+=/variable,name=hard_cast_flamestrike,if=variable.hard_cast_flamestrike=0,value=3*talent.flame_patch+999*!talent.flame_patch
spec:RegisterVariable( "hard_cast_flamestrike", function ()
    if talent.flame_patch.enabled then return 3 end
    return 999
end )

-- # APL Variable Option: This variable specifies the number of targets at which Hot Streak Flamestrikes are used during Combustion.
-- actions.precombat+=/variable,name=combustion_flamestrike,if=variable.combustion_flamestrike=0,value=3*talent.flame_patch+999*!talent.flame_patch
spec:RegisterVariable( "combustion_flamestrike", function ()
    if talent.flame_patch.enabled then return 3 end
    return 999
end )

-- # APL Variable Option: This variable specifies the number of targets at which Arcane Explosion outside of Combustion should be used.
-- actions.precombat+=/variable,name=arcane_explosion,if=variable.arcane_explosion=0,value=999
spec:RegisterVariable( "arcane_explosion", function ()
    return 999
end )

-- # APL Variable Option: This variable specifies the percentage of mana below which Arcane Explosion will not be used.
-- actions.precombat+=/variable,name=arcane_explosion_mana,default=40,op=reset
spec:RegisterVariable( "arcane_explosion_mana", function ()
    return 40
end )

-- # APL Variable Option: The number of targets at which Shifting Power can used during Combustion.
-- actions.precombat+=/variable,name=combustion_shifting_power,if=variable.combustion_shifting_power=0,value=variable.combustion_flamestrike
spec:RegisterVariable( "combustion_shifting_power", function ()
    return variable.combustion_flamestrike
end )

-- # APL Variable Option: The time remaining on a cast when Combustion can be used in seconds.
-- actions.precombat+=/variable,name=combustion_cast_remains,default=0.7,op=reset
spec:RegisterVariable( "combustion_cast_remains", function ()
    return 0.7
end )

-- # APL Variable Option: This variable specifies the number of seconds of Fire Blast that should be pooled past the default amount.
-- actions.precombat+=/variable,name=overpool_fire_blasts,default=0,op=reset
spec:RegisterVariable( "overpool_fire_blasts", function ()
    return 0
end )

-- # APL Variable Option: How long before Combustion should Empyreal Ordnance be used?
-- actions.precombat+=/variable,name=empyreal_ordnance_delay,default=18,op=reset
spec:RegisterVariable( "empyreal_ordnance_delay", function ()
    return 18
end )

-- # APL Variable Option: How much delay should be inserted after consuming an SKB proc before spending a Hot Streak? The APL will always delay long enough to prevent the SKB stack from being wasted.
-- actions.precombat+=/variable,name=skb_delay,default=-1,value=0,if=variable.skb_delay<0
spec:RegisterVariable( "skb_delay", function ()
    return 0
end )

-- # The duration of a Sun King's Blessing Combustion.
-- actions.precombat+=/variable,name=skb_duration,op=set,value=5
spec:RegisterVariable( "skb_duration", function ()
    return 5
end )

-- # The number of seconds of Fire Blast recharged by Mirrors of Torment
-- actions.precombat+=/variable,name=mot_recharge_amount,value=dbc.effect.871274.base_value
spec:RegisterVariable( "mot_recharge_amount", function ()
    return 6
end )


-- # Whether a usable item used to buff Combustion is equipped.
-- actions.precombat+=/variable,name=combustion_on_use,value=equipped.gladiators_badge|equipped.macabre_sheet_music|equipped.inscrutable_quantum_device|equipped.sunblood_amethyst|equipped.empyreal_ordnance|equipped.flame_of_battle|equipped.wakeners_frond|equipped.instructors_divine_bell|equipped.shadowed_orb_of_torment|equipped.the_first_sigil|equipped.neural_synapse_enhancer|equipped.fleshrenders_meathook|equipped.enforcers_stun_grenade
spec:RegisterVariable( "combustion_on_use", function ()
    return equipped.gladiators_badge or equipped.macabre_sheet_music or equipped.inscrutable_quantum_device or equipped.sunblood_amethyst or equipped.empyreal_ordnance or equipped.flame_of_battle or equipped.wakeners_frond or equipped.instructors_divine_bell or equipped.shadowed_orb_of_torment or equipped.the_first_sigil or equipped.neural_synapse_enhancer or equipped.fleshrenders_meathook or equipped.enforcers_stun_grenade
end )

-- # How long before Combustion should trinkets that trigger a shared category cooldown on other trinkets not be used?
-- actions.precombat+=/variable,name=on_use_cutoff,op=set,value=20,if=variable.combustion_on_use
-- actions.precombat+=/variable,name=on_use_cutoff,op=set,value=25,if=equipped.macabre_sheet_music
-- actions.precombat+=/variable,name=on_use_cutoff,op=set,value=20+variable.empyreal_ordnance_delay,if=equipped.empyreal_ordnance
spec:RegisterVariable( "on_use_cutoff", function ()
    if equipped.empyreal_ordnance then return 20 + variable.empyreal_ordnance_delay end
    if equipped.macabre_sheet_music then return 25 end
    if variable.combustion_on_use then return 20 end
    return 0
end )

-- +# Variable that estimates whether Shifting Power will be used before the next Combustion. TODO: During Firestarter, it sims higher to always set this to 1 even when Shifting Power has already been used. This needs further investigation.
-- actions+=/variable,name=shifting_power_before_combustion,value=variable.time_to_combustion>cooldown.shifting_power.remains|firestarter.active
spec:RegisterVariable( "shifting_power_before_combustion", function ()
    if variable.time_to_combustion > cooldown.shifting_power.remains or firestarter.active then
        return 1
    end
    return 0
end )


-- actions+=/variable,name=item_cutoff_active,value=(variable.time_to_combustion<variable.on_use_cutoff|buff.combustion.remains>variable.skb_duration&!cooldown.item_cd_1141.remains)&((trinket.1.has_cooldown&trinket.1.cooldown.remains<variable.on_use_cutoff)+(trinket.2.has_cooldown&trinket.2.cooldown.remains<variable.on_use_cutoff)+(equipped.neural_synapse_enhancer&cooldown.enhance_synapses_300612.remains<variable.on_use_cutoff)>1)
spec:RegisterVariable( "item_cutoff_active", function ()
    return ( variable.time_to_combustion < variable.on_use_cutoff or buff.combustion.remains > variable.skb_duration and cooldown.hyperthread_wristwraps.remains ) and safenum( safenum( trinket.t1.has_use_buff and trinket.t1.cooldown.remains < variable.on_use_cutoff ) + safenum( trinket.t2.has_use_buff and trinket.t2.cooldown.remains < variable.on_use_cutoff ) + safenum( equipped.neural_synapse_enhancer and cooldown.neural_synapse_enhancer.remains < variable.on_use_cutoff ) > 1 )
end )

-- fire_blast_pooling relies on the flow of the APL for differing values before/after rop_phase.

-- # Variable that controls Phoenix Flames usage to ensure its charges are pooled for Combustion. Only use Phoenix Flames outside of Combustion when full charges can be obtained during the next Combustion.
-- actions+=/variable,name=phoenix_pooling,if=active_enemies<variable.combustion_flamestrike,value=(variable.time_to_combustion+buff.combustion.duration-5<action.phoenix_flames.full_recharge_time+cooldown.phoenix_flames.duration-action.shifting_power.full_reduction*variable.shifting_power_before_combustion&variable.time_to_combustion<fight_remains|(runeforge.sun_kings_blessing|talent.sun_kings_blessing)|time<5)&!talent.alexstraszas_fury
-- # When using Flamestrike in Combustion, save as many charges as possible for Combustion without capping.
-- actions+=/variable,name=phoenix_pooling,if=active_enemies>=variable.combustion_flamestrike,value=(variable.time_to_combustion<action.phoenix_flames.full_recharge_time-action.shifting_power.full_reduction*variable.shifting_power_before_combustion&variable.time_to_combustion<fight_remains|(runeforge.sun_kings_blessing|talent.sun_kings_blessing)|time<5)&!talent.alexstraszas_fury
spec:RegisterVariable( "phoenix_pooling", function ()
    if active_enemies < variable.combustion_flamestrike then
        return ( variable.time_to_combustion + buff.combustion.duration - 5 < action.phoenix_flames.full_recharge_time + cooldown.phoenix_flames.duration - action.shifting_power.full_reduction * variable.shifting_power_before_combustion and variable.time_to_combustion < fight_remains or ( runeforge.sun_kings_blessing.enabled or talent.sun_kings_blessing.enabled ) or time < 5 ) and not talent.alexstraszas_fury.enabled
    end
    return ( variable.time_to_combustion < action.phoenix_flames.full_recharge_time - action.shifting_power.full_reduction * variable.shifting_power_before_combustion and variable.time_to_combustion < fight_remains or ( runeforge.sun_kings_blessing.enabled or talent.sun_kings_blessing.enabled ) or time < 5 ) and not talent.alexstraszas_fury.enabled
end )

-- # Estimate how long Combustion will last thanks to Sun King's Blessing to determine how Fire Blasts should be used.
-- actions.combustion_phase+=/variable,use_off_gcd=1,use_while_casting=1,name=extended_combustion_remains,value=buff.combustion.remains+buff.combustion.duration*(cooldown.combustion.remains<buff.combustion.remains)
-- # Adds the duration of the Sun King's Blessing Combustion to the end of the current Combustion if the cast would start during this Combustion.
-- actions.combustion_phase+=/variable,use_off_gcd=1,use_while_casting=1,name=extended_combustion_remains,op=add,value=variable.skb_duration,if=(runeforge.sun_kings_blessing|talent.sun_kings_blessing)&(buff.sun_kings_blessing_ready.up|variable.extended_combustion_remains>gcd.remains+1.5*gcd.max*(buff.sun_kings_blessing.max_stack-buff.sun_kings_blessing.stack))
spec:RegisterVariable( "extended_combustion_remains", function ()
    local value = 0
    if cooldown.combustion.remains < buff.combustion.remains then
        value = buff.combustion.remains + buff.combustion.duration
    end
    if ( talent.sun_kings_blessing.enabled or runeforge.sun_kings_blessing.enabled ) and ( buff.sun_kings_blessing_ready.up or value > gcd.remains + 1.5 * gcd.max * ( buff.sun_kings_blessing.max_stack - buff.sun_kings_blessing.stack ) ) then
        value = value + variable.skb_duration
    end
    return value
end )

-- # With Feel the Burn, Fire Blast use should be additionally constrained so that it is not be used unless Feel the Burn is about to expire or there are more than enough Fire Blasts to extend Feel the Burn to the end of Combustion.
-- actions.combustion_phase+=/variable,use_off_gcd=1,use_while_casting=1,name=expected_fire_blasts,value=action.fire_blast.charges_fractional+(variable.extended_combustion_remains-buff.feel_the_burn.duration)%cooldown.fire_blast.duration,if=talent.feel_the_burn|conduit.infernal_cascade

spec:RegisterVariable( "expected_fire_blasts", function ()
    if talent.feel_the_burn.enabled or conduit.infernal_cascade.enabled then
        return action.fire_blast.charges_fractional + ( variable.extended_combustion_remains - buff.feel_the_burn.duration ) / cooldown.fire_blast.duration
    end
    return 0
end )

-- actions.combustion_phase+=/variable,use_off_gcd=1,use_while_casting=1,name=needed_fire_blasts,value=ceil(variable.extended_combustion_remains%(buff.feel_the_burn.duration-gcd.max)),if=talent.feel_the_burn|conduit.infernal_cascade
spec:RegisterVariable( "needed_fire_blasts", function ()
    if talent.feel_the_burn.enabled or conduit.infernal_cascade.enabled then
        return ceil( variable.extended_combustion_remains / ( buff.feel_the_burn.duration - gcd.max ) )
    end
    return 0
end )

-- # Use Shifting Power during Combustion when there are not enough Fire Blasts available to fully extend Feel the Burn and only when Rune of Power is on cooldown.
-- actions.combustion_phase+=/variable,use_off_gcd=1,use_while_casting=1,name=use_shifting_power,value=firestarter.remains<variable.extended_combustion_remains&((talent.feel_the_burn|conduit.infernal_cascade)&variable.expected_fire_blasts<variable.needed_fire_blasts)&(!talent.rune_of_power|cooldown.rune_of_power.remains>variable.extended_combustion_remains)|active_enemies>=variable.combustion_shifting_power,if=covenant.night_fae
spec:RegisterVariable( "use_shifting_power", function ()
    if action.shifting_power.known then
        return firestarter.remains < variable.extended_combustion_remains and ( ( talent.feel_the_burn.enabled or conduit.infernal_cascade.enabled ) and variable.expected_fire_blasts < variable.needed_fire_blasts ) and ( not talent.rune_of_power.enabled or cooldown.rune_of_power.remains > variable.extended_combustion_remains ) or active_enemies >= variable.combustion_shifting_power
    end
    return 0
end )

-- # Helper variable that contains the actual estimated time that the next Combustion will be ready.
-- actions.combustion_timing=variable,use_off_gcd=1,use_while_casting=1,name=combustion_ready_time,value=cooldown.combustion.remains*expected_kindling_reduction
spec:RegisterVariable( "combustion_ready_time", function ()
    return cooldown.combustion.remains_expected
end )

-- # The cast time of the spell that will be precast into Combustion.
-- actions.combustion_timing+=/variable,use_off_gcd=1,use_while_casting=1,name=combustion_precast_time,value=(action.fireball.cast_time*!conduit.flame_accretion+action.scorch.cast_time+conduit.flame_accretion)*(active_enemies<variable.combustion_flamestrike)+action.flamestrike.cast_time*(active_enemies>=variable.combustion_flamestrike)-variable.combustion_cast_remains
spec:RegisterVariable( "combustion_precast_time", function ()
    return ( ( not conduit.flame_accretion.enabled and action.fireball.cast_time or 0 ) + action.scorch.cast_time + ( conduit.flame_accretion.enabled and 1 or 0 ) ) * ( ( active_enemies < variable.combustion_flamestrike ) and 1 or 0 ) + ( ( active_enemies >= variable.combustion_flamestrike ) and action.flamestrike.cast_time or 0 ) - variable.combustion_cast_remains
end )

spec:RegisterVariable( "time_to_combustion", function ()
    -- # Delay Combustion for after Firestarter unless variable.firestarter_combustion is set.
    -- actions.combustion_timing+=/variable,use_off_gcd=1,use_while_casting=1,name=time_to_combustion,value=variable.combustion_ready_time
    local value = variable.combustion_ready_time

    -- # Use the next Combustion on cooldown if it would not be expected to delay the scheduled one or the scheduled one would happen less than 20 seconds before the fight ends.
    -- actions.combustion_timing+=/variable,use_off_gcd=1,use_while_casting=1,name=time_to_combustion,value=variable.combustion_ready_time,if=variable.combustion_ready_time+cooldown.combustion.duration*(1-(0.4+0.2*talent.firestarter)*talent.kindling)<=variable.time_to_combustion|variable.time_to_combustion>fight_remains-20
    if variable.combustion_ready_time + cooldown.combustion.duration * ( 1 - ( 0.6 + 0.2 * ( talent.firestarter.enabled and 1 or 0 ) ) * ( talent.kindling.enabled and 1 or 0 ) ) <= value or boss and value > fight_remains - 20 then
        return value
    end

    -- # Delay Combustion for after Firestarter unless variable.firestarter_combustion is set.
    -- actions.combustion_timing+=/variable,use_off_gcd=1,use_while_casting=1,name=time_to_combustion,op=max,value=firestarter.remains,if=talent.firestarter&!variable.firestarter_combustion
    if talent.firestarter.enabled and not variable.firestarter_combustion then
        value = max( value, firestarter.remains )
    end

    -- # Delay Combustion until SKB is ready during Firestarter
    -- actions.combustion_timing+=/variable,use_off_gcd=1,use_while_casting=1,name=time_to_combustion,op=max,value=(buff.sun_kings_blessing.max_stack-buff.sun_kings_blessing.stack)*(action.fireball.execute_time+gcd.max),if=(talent.sun_kings_blessing|runeforge.sun_kings_blessing)&firestarter.active&buff.sun_kings_blessing_ready.down
    if ( talent.sun_kings_blessing.enabled or runeforge.sun_kings_blessing.enabled ) and firestarter.active and buff.sun_kings_blessing_ready.down then
        value = ( buff.sun_kings_blessing.max_stack - buff.sun_kings_blessing.stack ) * ( action.fireball.execute_time + gcd.max )
    end

    -- # Delay Combustion for Radiant Spark if it will come off cooldown soon.
    -- actions.combustion_timing+=/variable,use_off_gcd=1,use_while_casting=1,name=time_to_combustion,op=max,value=cooldown.radiant_spark.remains,if=covenant.kyrian&cooldown.radiant_spark.remains-10<variable.time_to_combustion
    if action.radiant_spark.known then
        value = max( value, cooldown.radiant_spark.remains )
    end

    -- # Delay Combustion for Mirrors of Torment
    -- actions.combustion_timing+=/variable,use_off_gcd=1,use_while_casting=1,name=time_to_combustion,op=max,value=cooldown.mirrors_of_torment.remains,if=covenant.venthyr&cooldown.mirrors_of_torment.remains-25<variable.time_to_combustion
    if action.mirrors_of_torment.known and cooldown.mirrors_of_torment.remains - 25 < value then
        value = max( value, cooldown.mirrors_of_torment.remains )
    end

    -- # Delay Combustion for Deathborne.
    -- actions.combustion_timing+=/variable,use_off_gcd=1,use_while_casting=1,name=time_to_combustion,op=max,value=cooldown.deathborne.remains+(buff.deathborne.duration-buff.combustion.duration)*runeforge.deaths_fathom,if=covenant.necrolord&cooldown.deathborne.remains-10<variable.time_to_combustion
    if action.deathborne.known and cooldown.deathborne.remains - 10 < value then
        value = max( value, cooldown.deathborne.remains + ( buff.deathborne.duration - buff.combustion.duration ) * ( runeforge.deaths_fathom.enabled and 1 or 0 ) )
    end

    -- # Delay Combustion for Death's Fathom stacks if there are at least two targets.
    -- actions.combustion_timing+=/variable,use_off_gcd=1,use_while_casting=1,name=time_to_combustion,op=max,value=buff.deathborne.remains-buff.combustion.duration,if=runeforge.deaths_fathom&buff.deathborne.up&active_enemies>=2
    if runeforge.deaths_fathom.enabled and buff.deathborne.up and active_enemies > 1 then
        value = max( value, buff.deathborne.remains - buff.combustion.duration )
    end

    -- # Delay Combustion for the Empyreal Ordnance buff if the player is using that trinket.
    -- actions.combustion_timing+=/variable,use_off_gcd=1,use_while_casting=1,name=time_to_combustion,op=max,value=variable.empyreal_ordnance_delay-(cooldown.empyreal_ordnance.duration-cooldown.empyreal_ordnance.remains)*!cooldown.empyreal_ordnance.ready,if=equipped.empyreal_ordnance
    if equipped.empyreal_ordnance then
        value = max( value, variable.empyreal_ordnance_delay - ( cooldown.empyreal_ordnance.duration - cooldown.empyreal_ordnance.remains ) * ( cooldown.empyreal_ordnance.ready and 0 or 1 ) )
    end

    -- # Delay Combustion for Gladiators Badge, unless it would be delayed longer than 20 seconds.
    -- actions.combustion_timing+=/variable,use_off_gcd=1,use_while_casting=1,name=time_to_combustion,op=max,value=cooldown.gladiators_badge_345228.remains,if=equipped.gladiators_badge&cooldown.gladiators_badge_345228.remains-20<variable.time_to_combustion
    if equipped.gladiators_badge and cooldown.gladiators_badge.remains - 20 < value then
        value = max( value, cooldown.gladiators_badge.remains )
    end

    -- # Delay Combustion until Combustion expires if it's up.
    -- actions.combustion_timing+=/variable,use_off_gcd=1,use_while_casting=1,name=time_to_combustion,op=max,value=buff.combustion.remains
    value = max( value, buff.combustion.remains )

    -- # Delay Combustion until RoP expires if it's up.
    -- actions.combustion_timing+=/variable,use_off_gcd=1,use_while_casting=1,name=time_to_combustion,op=max,value=buff.rune_of_power.remains,if=talent.rune_of_power&buff.combustion.down
    if talent.rune_of_power.enabled and buff.combustion.down then
        value = max( value, buff.rune_of_power.remains )
    end

    -- # Delay Combustion for an extra Rune of Power if the Rune of Power would come off cooldown at least 5 seconds before Combustion would.
    -- actions.combustion_timing+=/variable,use_off_gcd=1,use_while_casting=1,name=time_to_combustion,op=max,value=cooldown.rune_of_power.remains+buff.rune_of_power.duration,if=talent.rune_of_power&buff.combustion.down&cooldown.rune_of_power.remains+5<variable.time_to_combustion
    if talent.rune_of_power.enabled and buff.combustion.down and cooldown.rune_of_power.remains + 5 < value then
        value = max( value, cooldown.rune_of_power.remains + buff.rune_of_power.duration )
    end

    -- # Delay Combustion if Disciplinary Command would not be ready for it yet.
    -- actions.combustion_timing+=/variable,use_off_gcd=1,use_while_casting=1,name=time_to_combustion,op=max,value=cooldown.buff_disciplinary_command.remains,if=runeforge.disciplinary_command&buff.disciplinary_command.down
    if runeforge.disciplinary_command.enabled and buff.disciplinary_command.down then
        value = max( value, cooldown.buff_disciplinary_command.remains )
    end

    -- # Raid Events: Delay Combustion for add spawns of 3 or more adds that will last longer than 15 seconds. These values aren't necessarily optimal in all cases.
    -- actions.combustion_timing+=/variable,use_off_gcd=1,use_while_casting=1,name=time_to_combustion,op=max,value=raid_event.adds.in,if=raid_event.adds.exists&raid_event.adds.count>=3&raid_event.adds.duration>15
    -- Unsupported, don't bother.

    -- # Raid Events: Always use Combustion with vulnerability raid events, override any delays listed above to make sure it gets used here.
    -- actions.combustion_timing+=/variable,use_off_gcd=1,use_while_casting=1,name=time_to_combustion,value=raid_event.vulnerable.in*!raid_event.vulnerable.up,if=raid_event.vulnerable.exists&variable.combustion_ready_time<raid_event.vulnerable.in
    -- Unsupported, don't bother.

    return value
end )

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

        usable = function () return target.distance < 8, "target must be in range" end,
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

            if talent.rune_of_power.enabled then applyBuff( "rune_of_power" ) end
            if talent.wildfire.enabled or azerite.wildfire.enabled then applyBuff( "wildfire" ) end
        end,
    },

    -- Talent: Teleports you back to where you last Blinked. Only usable within 8 sec of Blinking.
    displacement = {
        id = 389713,
        cast = 0,
        cooldown = 45,
        gcd = "spell",
        school = "arcane",

        talent = "displacement",
        startsCombat = false,
        buff = "displacement_beacon",

        handler = function ()
            removeBuff( "displacement_beacon" )
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

        usable = function () return target.within12, "target must be within 12 yds" end,
        handler = function ()
            hot_streak( talent.alexstraszas_fury.enabled )
            applyDebuff( "target", "dragons_breath" )
            if talent.alexstraszas_fury.enabled then applyBuff( "alexstraszas_fury" ) end
        end,
    },

    -- Talent: Blasts the enemy for 962 Fire damage. Fire: Castable while casting other spells. Always deals a critical strike.
    fire_blast = {
        id = 108853,
        cast = 0,
        charges = function () return 1 + talent.flame_on.rank end,
        cooldown = function ()
            return ( talent.flame_on.enabled and 10 or 12 )
            * ( talent.fiery_rush.enabled and buff.combustion.up and 0.5 or 1 )
            * ( buff.memory_of_lucid_dreams.up and 0.5 or 1 ) * haste
        end,
        recharge = function () return ( talent.flame_on.enabled and 10 or 12 ) * ( buff.memory_of_lucid_dreams.up and 0.5 or 1 ) * haste end,
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

            if talent.feel_the_burn.enabled then addStack( "feel_the_burn" ) end
            if talent.kindling.enabled then setCooldown( "combustion", max( 0, cooldown.combustion.remains - 1 ) ) end
            if talent.master_of_flame.enabled and buff.combustion.up then active_dot.ignite = min( active_enemies, active_dot.ignite + 4 ) end

            if set_bonus.tier30_4pc > 0 and debuff.charring_embers.up then
                if buff.calefaction.stack == 19 then
                    removeBuff( "calefaction" )
                    applyBuff( "flames_fury", nil, 2 )
                else
                    addStack( "calefaction" )
                end
            end

            if azerite.blaster_master.enabled then addStack( "blaster_master" ) end
            if conduit.infernal_cascade.enabled and buff.combustion.up then addStack( "infernal_cascade" ) end
            if legendary.sinful_delight.enabled then gainChargeTime( "mirrors_of_torment", 4 ) end
        end,
    },

    -- Throws a fiery ball that causes 749 Fire damage. Each time your Fireball fails to critically strike a target, it gains a stacking 10% increased critical strike chance. Effect ends when Fireball critically strikes.
    fireball = {
        id = 133,
        cast = function() return 2.25 * ( buff.flame_accelerant.up and 0.6 or 1 ) * haste end,
        cooldown = 0,
        gcd = "spell",
        school = "fire",

        spend = 0.02,
        spendType = "mana",

        startsCombat = false,
        velocity = 45,

        usable = function ()
            if moving and settings.prevent_hardcasts and action.fireball.cast_time > buff.ice_floes.remains then return false, "prevent_hardcasts during movement and ice_floes is down" end
            return true
        end,

        handler = function ()
            removeBuff( "molten_skyfall_ready" )
        end,

        impact = function ()
            if hot_streak( firestarter.active or stat.crit + buff.fireball.stack * 10 >= 100 ) then
                removeBuff( "fireball" )
                if talent.kindling.enabled then setCooldown( "combustion", max( 0, cooldown.combustion.remains - 1 ) ) end
            else
                addStack( "fireball" )
                if conduit.flame_accretion.enabled then addStack( "flame_accretion" ) end
            end

            if buff.firefall_ready.up then
                action.meteor.impact()
                removeBuff( "firefall_ready" )
            end
            removeBuff( "flame_accelerant" )

            if talent.conflagration.enabled then applyDebuff( "target", "conflagration" ) end
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
                buff.flame_accelerate.expires = query_time + 8 + 8
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
    },

    -- Talent: Calls down a pillar of fire, burning all enemies within the area for 526 Fire damage and reducing their movement speed by 20% for 8 sec.
    flamestrike = {
        id = 2120,
        cast = function () return ( buff.hot_streak.up or buff.firestorm.up or buff.hyperthermia.up ) and 0 or ( ( 4 - talent.improved_flamestrike.rank ) * haste ) end,
        cooldown = 0,
        gcd = "spell",
        school = "fire",

        spend = 0.025,
        spendType = "mana",

        talent = "flamestrike",
        startsCombat = true,

        handler = function ()
            if not hardcast then
                if buff.expanded_potential.up then removeBuff( "expanded_potential" )
                else
                    removeBuff( "hot_streak" )
                    if legendary.sun_kings_blessing.enabled then
                        addStack( "sun_kings_blessing" )
                        if buff.sun_kings_blessing.stack == 8 then
                            removeBuff( "sun_kings_blessing" )
                            applyBuff( "sun_kings_blessing_ready" )
                        end
                    end
                end
            end

            applyDebuff( "target", "ignite" )
            applyDebuff( "target", "flamestrike" )
            removeBuff( "alexstraszas_fury" )
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
            if set_bonus.tier30_4pc > 0 and debuff.charring_embers.up then
                if buff.calefaction.stack == 19 then
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

        toggle = "defensives",
        startsCombat = false,

        handler = function ()
            applyBuff( "preinvisibility" )
            applyBuff( "invisibility", 23 )
            if conduit.incantation_of_swiftness.enabled then applyBuff( "incantation_of_swiftness" ) end
        end,
    },

    -- Talent: The target becomes a Living Bomb, taking 245 Fire damage over 3.6 sec, and then exploding to deal an additional 143 Fire damage to the target and reduced damage to all other enemies within 10 yards. Other enemies hit by this explosion also become a Living Bomb, but this effect cannot spread further.
    living_bomb = {
        id = 44457,
        cast = 0,
        cooldown = 12,
        gcd = "spell",
        school = "fire",

        spend = 0.015,
        spendType = "mana",

        talent = "living_bomb",
        startsCombat = true,

        handler = function ()
            applyDebuff( "target", "living_bomb" )
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

        impact = function ()
            if buff.flames_fury.up then
                gainCharges( "phoenix_flames", 1 )
                removeStack( "flames_fury" )
            end

            if hot_streak( firestarter.active ) and talent.kindling.enabled then
                setCooldown( "combustion", max( 0, cooldown.combustion.remains - 1 ) )
            end

            applyDebuff( "target", "ignite" )
            if active_dot.ignite < active_enemies then active_dot.ignite = active_enemies end

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
        cast = function () return ( buff.hot_streak.up or buff.firestorm.up or buff.hyperthermia.up ) and 0 or ( 4.5 * ( talent.tempered_flames.enabled and 0.7 or 1 ) * haste ) end,
        cooldown = 0,
        gcd = "spell",
        school = "fire",

        spend = 0.02,
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
            if hardcast then
                removeStack( "pyroclasm" )
                if buff.sun_kings_blessing_ready.up then
                    applyBuff( "combustion", 6 )
                    -- removeBuff( "sun_kings_blessing_ready" )
                    applyBuff( "sun_kings_blessing_ready_expiration_delay" )
                    state:QueueAuraExpiration( "sun_kings_blessing_ready_expiration_delay", ExpireSKB, buff.sun_kings_blessing_ready_expiration_delay.expires )
                end
            else
                if buff.hot_streak.up then
                    if buff.expanded_potential.up then removeBuff( "expanded_potential" )
                    else
                        removeBuff( "hot_streak" )
                        if legendary.sun_kings_blessing.enabled then
                            addStack( "sun_kings_blessing" )
                            if buff.sun_kings_blessing.stack == 12 then
                                removeBuff( "sun_kings_blessing" )
                                applyBuff( "sun_kings_blessing_ready" )
                            end
                        end
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

            if set_bonus.tier30_4pc > 0 and debuff.charring_embers.up then
                if buff.calefaction.stack == 19 then
                    removeBuff( "calefaction" )
                    applyBuff( "flames_fury", nil, 2 )
                else
                    addStack( "calefaction" )
                end
            end
        end,

        velocity = 35,

        impact = function ()
            if hot_streak( firestarter.active or buff.firestorm.up or buff.hyperthermia.up ) then
                if talent.kindling.enabled then
                    setCooldown( "combustion", max( 0, cooldown.combustion.remains - 1 ) )
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
            removeBuff( "alexstraszas_fury" )
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

    -- Talent: Places a Rune of Power on the ground for 12 sec which increases your spell damage by 40% while you stand within 8 yds. Casting Combustion will also create a Rune of Power at your location.
    rune_of_power = {
        id = 116011,
        cast = 1.5,
        cooldown = 45,
        gcd = "spell",
        school = "arcane",

        talent = "rune_of_power",
        startsCombat = false,
        nobuff = "rune_of_power",

        handler = function ()
            applyBuff( "rune_of_power" )
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
            hot_streak( talent.searing_touch.enabled and target.health_pct < 30 )
            applyDebuff( "target", "ignite" )
            if talent.frenetic_speed.enabled then applyBuff( "frenetic_speed" ) end
            if talent.improved_scorch.enabled and target.health_pct < 30 then applyDebuff( "target", "improved_scorch", nil, debuff.scorch.stack + 1 ) end

            if set_bonus.tier30_4pc > 0 and debuff.charring_embers.up then
                if buff.calefaction.stack == 19 then
                    removeBuff( "calefaction" )
                    applyBuff( "flames_fury", nil, 2 )
                else
                    addStack( "calefaction" )
                end
            end
        end,
    },

    -- Talent: Draw power from the Night Fae, dealing 2,168 Nature damage over 3.6 sec to enemies within 18 yds. While channeling, your Mage ability cooldowns are reduced by 12 sec over 3.6 sec.
    shifting_power = {
        id = function() return talent.shifting_power.enabled and 382440 or 314791 end,
        cast = function() return 4 * haste end,
        channeled = true,
        cooldown = 60,
        gcd = "spell",
        school = "nature",

        spend = 0.05,
        spendType = "mana",

        startsCombat = true,

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

spec:RegisterOptions( {
    enabled = true,

    aoe = 3,
    gcdSync = false,
    -- can_dual_cast = true,

    nameplates = false,
    nameplateRange = 8,

    damage = true,
    damageExpiration = 6,

    potion = "spectral_intellect",

    package = "Fire",
} )


spec:RegisterSetting( "pyroblast_pull", false, {
    name = strformat( "%s: Non-Instant Opener", Hekili:GetSpellLinkWithTexture( spec.abilities.pyroblast.id ) ),
    desc = strformat( "If checked, a non-instant %s may be recommended as an opener against bosses.", Hekili:GetSpellLinkWithTexture( spec.abilities.pyroblast.id ) ),
    type = "toggle",
    width = "full"
} )


spec:RegisterSetting( "prevent_hardcasts", false, {
    name = strformat( "%s and %s: Instant-Only When Moving", Hekili:GetSpellLinkWithTexture( spec.abilities.pyroblast.id ),
        Hekili:GetSpellLinkWithTexture( spec.abilities.fireball.id ) ),
    desc = strformat( "If checked, non-instant %s and %s casts will not be recommended while you are moving.\n\nAn exception is made if %s is talented and active and your cast "
        .. "would be complete before |W%s|w expires.", Hekili:GetSpellLinkWithTexture( spec.abilities.pyroblast.id ), Hekili:GetSpellLinkWithTexture( spec.abilities.fireball.id ),
        Hekili:GetSpellLinkWithTexture( 108839 ), ( GetSpellInfo( 108839 ) ) ),
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


spec:RegisterPack( "Fire", 20230402, [[Hekili:S33EZTXXrI)zH3vgIqKcgeK0YjfjRYokYN89loUc1f)FeyXIfeB0IDr2hKIPyHp7)MU7zMDEVlij8zNtv5swcZSZJE6PF39CZj38XBUEruDYn)0KXtoD8zJNm6KZMC(4ZU566h2KCZ1BII)u0TS)sE0A2F((0s8hFiRiAb8XvfnLXSFAvD9MQ)4x)13MwVQz(O4I1FDv66MSO60I84YOL1W)o(RV565nPz1Fi)M5UM5Zo70BUoQPEvr5nxFD66)eBKtxSiH6Esv8nxdD)nJp9ntg)h3oB7S)sXI0LpSD2MY0IY0A2FBzr52z)hFiVQokV(n)18m2V9lRsYH(ExA(T)hBNvLuxZ(BJ2(JB)r549wC8(BjRlUlz7SRJlkJxTD2vBN9ZpuwmplQQE7SvrLlIX)wvCsEeBovgJZEZ4j8X4U0kVJrDX2zXRsI)02z)xfS)911LjrFA0nxNLwvxba1YInt3SkQkH9p(j8mInxZZswCZ3FZ1XSDzszAedofxNExY0K8K1PjvSP5YTZUJTMGUoAvr90kCKNUmJD2X(7PFITMgSD2HBNnVz5sLUmI9hXSLYJp226s2rDvDr5A1gPVJHzuwVkPCDAKOXHS)Jwrf53CTYmEtn7e27wahVfjr1RMxuMNmQzdUclBYtyhJ3MqTvnDj7plwpIpgyFK70601jtRlMYW5M3ublGTZUGVuvg6YK1rP5v436cYnrz5Z26ZJYYG1(PprWpdrzkGPyb9X1vvt(0pXWaRMY6Cvf7VnLbix8GaaeUtYTcdXcNdae0JVl5ZBslXBKtxKKf9Wu5aXw6J9E8Dw4JVFBVx2iU4b7KZ9UtEIy9EMNVjmeZ8INNr5TgJstvY07xLMLGiwmqbqCqzSpqb)d2htXrA6MIImwN7bmDrX95oVFCrVWSzZpb(IkzROr0GiO4CGamYUrcZyZgbqCGsJwuKOg3uMC30ILlNEB8cLTMySjONsdJIzRYBL3SLe2QJYsYRhX(ZpZMMOQ)veJ0st5dAewIzWlasmArz0Tf5mOujqfzecJqkDWOvLWaiS9rDrt8k5ELidchu8vlEePsxHwGeZSY0nud)pa3IIC2Famy3o77PDhBkaMxPSdL)wXpZ(ll3o7HIMTZwuK)kKBemNjPawjJzcbz3o7)HDVd4bQWDH9DjS)ru(cr)zmQomAOymwxatB9Qi2uvFpJbvugUDpM1R5YE9DTWTxXGTVNb5y0QjWcWvJTVpMM6dJzF01eiA7SpcWi2YVsGznA7S3rBHffW0cTGy2ehwIsa(PVVfhRIg67rw5x3W(J)BwxGfY3ZrJPPGWLHlqF7l)fi)4498Q1HI)tbPf41WiOLe3ulMhVDiPLqh7w54rNtOJhGFslFZw6ysuBOB8laA0YKDyOe5Mp1sQrExCM9yVV6g2cRTPKmuEr39TtvzF8qgIVVQqj3u328TrqYu(hzVdl9HkcRvTjjlRAAAoJ8A6TRQLB8NkzfDkkCAflAOBMru7a(1xRiIkjIlDttJSs7vy6YOyC4N(SVHnbM38X7I)bJ7IIfFmBQNs)JPGaWKyWtj1n48Hi8IkyyozSNXPLZPomGAVAKuM6JU8RPJHJtxEPl8KbC0W01BkzQcSyk19blsWZxJFwiaZfN(AG506OpBXUhwAXSL2AfecfrDeYQQ2TwrvD0r4EedrGrx6Egji1oFO9vnBksoVZfQBdvKcYXI8cBsvkl6J02cV2XWqxDXdx)66Gsaaa4t4xIcrhyqacarHeTXPotEKo7e)A1OYhzZQIK80pRXe5WUV0hKufCA0kHZ2zNyQ)LysPDbUA9RhJlqv7qrqBCi8RhGjq9kn1P0LJchk)cIBnuQAvfvghXW9zY(NvuHk6XGtRJYJgTbGlb77uOFTlkZMXLLPC7skSQydAKx(fKExsErZTRGltSZK6kMqqP1CILBNDBeiahQ1psw99QInhvbcuKLbeLz3MQzclWOSUSLS8OEdCCkyoUTmvKODa53(RtwZy5YOPrFPM4Wc(Aytmk1XjSfBe7JcP6YjOOxQmOq9Pvweq3yGYLrnz1UmZHK)qrtoBXI3qmG9)zIPdis7DjGOOenggho8AoWFcpcUlkndHqg3rvSYqAvC6g29ZOYha7iWqvwiac9WagTwEqxfkp6KCXL4vw6kUuBdpu15YDWpO07Kkf6U0IsIMuTkDjspbhJPZbqqIIXtuU6R1txgdr0ZYOfPmucgDSOYpzCkDnQ6WFJ6bt0aOlCJ09NKt6XWsN1AbiEY9OXZAG)aUgbxZLqPEb7pSdRdDL44zQyC3o7nBNDoNnKjDojDmPXKm2IVt2aJXZQIMSfGcu3h9a78BoTvwienQDpZucIOEGFoQqfALlo1dXa1oaC1bRqvMIQ5FiFEVNrerxBoMokXFQQvgnLzUxqrhYAiBRlJVjBV93NYyHRlxGqLb5pCOTv7yl(iAuFdVr1LQSXHOOfDy2qxwasC2UoTSSOSc2QGEjS7AUKL(Vq9IOq)rQFooyvbV7bi1ahqc2bJldp17T33LvvWVZ5Etc8WMNuFFcOtq7ETIyHLvGAtuP2KaNmVqAQcGjiGpJwSdqPxJggajgKw3F4MNlWNo2anGjh7YMmWaHGuvQ4b9Z2AAGO3dRY)odyS6HYJ5WQid9RiA8T35Cdlj5aaGr0DfPO5o2Sb7pNhXi3k3Plia7y3(y1q3s2UpJPsonSC0N3izo59Z1vJ)SEPMAagqUSfJy)DBgWzOgwgZJwaEA65HdCoBwwUmjwOcP14hqxuMuqpWwWztlkxKhLh3)fZfQcIznmKfQ7MW5v9zqO9iT5SxWHurUAvedmXKYROCUgLanZG3)9zikwCBUUeWn0qMco8d9sCtrVPK)zt6MnjlgXKvyk76bBARsVnnJRxKqsbJwNE6382jNDIM)goBmQ1ebl9bDCPxQe5TmD90K4S0nv7gUY3(eapIfQ2K6srujr)II8S0A2HtA16DA5D(Zy5PpRUu9S9Q)dBwbG6OQQ01PKVI9Phn73wpLrAcmawexhvXnCxdJlfwLaMO4iMYOtRwLKupDDtvA8UbEK7vhdKl1B14J8HLaZdH53yQ8vI8akYFdxK3eqeqH8J4V9oWiYlrgn)9KQQegUErtDv6IeIZIMqL)vHm0hl9kE6)kroNogltbyGfd64bqp0eOhOovFFtzoPsLuXd0HcrWyhbS9UNmQpWINPvni7(DGIT4x3kSgSIXFcXVyR4pIoaiAXcsH5Q1rGCd3fL1WLza7DlzEyaCTnq7vUOa3MKtfIJYI5bHaSSIJKAvaT2KdepzB5yo34QQgsdsq660AHemTIGZ0sg4Taahn1s2o7NkQLFj3iOUCrHIPb2uW(L5z8Ty1d5XsxHqF))93BiPvzYTmD8HrIGbcugMM(5FkPgeBGWlxiaotVdHn9)sLMLNyspLuMZyVWOThhTGjpfOsb6Hv3TVo6Zt59HR3ACr(IgMODwDvZiKUyPW(pCZnyFAtZUyhNc2EytbddcmoIo5WVcc1JdDifcJ93jJnnjN1rIl7nPR4mt)VTZ(WT5WjNl9bbrYzxxUhKkGq8wuKuH3aX1ndINiqMki7(BHXWjx0(lKl5qz2z)0T3cTb3jzsqcZ5h(tVJq9tRpMufnffOnxDHvssegTex4r5p4B(LiSvS920uARAipI8og3TqaCC69mMl13xgTPYYsjbrUhQihr)qnDJOdH2GSvfrvGFFOlzvmp(newXS5PNE2F4Bp)TAsRCUg(KgeZLr(KgqdKlmBkSsnid0nayGWMAxiLj4zsyGS3WuZtD6kIk2)hfiFgxd4gbHWQ)aFEy0jPjs1fXi9BqLuUWPJAnmPxwZmuMQ2lt87bZtyeEGrtLdP464)OPQwf33dFz21aWMofaWCdJdvlQp74nUSPgwqt)Nnr51nRzI6FxQU2hsejt9z0iy7sO5WK4uLNNO4YVYyqF0OnigB0qhdSlaOUpnUiJkZKDBEuDD2oSJ7NOHMdpykxFAhDF0NyNZSjzzj7EXl9kXy0HfIpLka3au2eJtZI07sZtMohn(9l7kY30alnFAuW4OopROyXu2iuV6bDBs8sSOSNay54tbc2vEY6flzIwseCaVESmXY(ME750ZiBNjMFVJiSo87aSU2DIvmChcAh9j3eFgJKHJaUaV4UiNo0VefT(NynZLowqQ8hyCfbIJFionot3DhTcpDl2PPPuFuj1)IAp9oLU6Pz7t0a9t8zMZaol6hG4Fc1J4Dko7bjrVg1Ib29mI4Bat7LtYyRUCb5YRkmmUB)8GecdLS6r(Fo7EjfjvItcx9zk52Y2JMdc0zray21X3rTERcqTMxKvR6b)R61IVv9U(CYlC1Ye)UM8FBGTwU54)fa2d6JteVjOZXNyk50(7OQ1EtoIiyNhDiS8f)KB)FUm0GOpGoGaBtbM2Fa7UVxShaU)kbojEOGJRnL6Ryde4lkHVGy0nyB8ZSvj5yR1OESkE7H76RwZ4y4t7rGjGMxxgbEGVa9UT0WxL00cAUW2fBkYr)cjBpVz9CuD5LMZOWatOJ1IQzaOSmmiCn98eooQ6FGb)MIrWKbKeBFvVc)BBi)sPofG(p3wIEUh0Xp5ZS9JHpVC6Fz04DkMsL9Hj5lswOCO1xdlJiucAMwHtXuvy5rDJ51s)vp8ggXDv2IMyQJVwzG6kMjeZmpebD4xnflJ9graBPodRlQB9tx0AqogSdXf3XWAzdWDKJhXFu1QioMRw46LD7Vf2)91kdNcawZ17NqKJD0nyNjdTLJuvz8oW0zfztB7Cv)MmxQZkBVZbyiyxUVseInDr1qZOE2Xyl7Z5gRWoGW941yGCJ)azm86H0R2NLL6dvWULPwLXGYe482ONbr16sbcFx1VgtNna08eILkSbprIYbTOlTrvEzFYDN(XO6s3tVeBRluSRCr7YLB578W9klhYPAPX9KbYjfy3LioubShmZWc0lXrKe47OlweuD7WYGND0NyNnhkIrO9Pi(RPXiCh5i2IviL4WTvd8KVjV4hRUiXHSQdgX0DJ(YWopfzojJcE94lAbzOuuSeXMwiRrCrEDzrwLHGfCNkIEhddFiDrH4jmK)SmkOJ4g1bTD4OUJeFuhTsnBhDreRR72J7jr12KdgwIMMqA)Ingwbs)uQ9I0TxPD5J0bNSXv7aXLH6Sn9eRUx03llVzhec9WDsou1vPXyRPxDh7KEVFneF6L8oFsEvd0skCzxkHze8try0kcyMWXnQ31FRbIcwqHPFgxK946TPveFbspWoVKlPOURmvhek3ddg53(ZJefI7Ttv4m5ZLwx8CS9PKHAuDz4)IxvfsnY4ZJnj5B7dCar5wWZkrq4xOKXRv8GtbXKqLpTILf0HGN2VibTflWZrq)o57bk0HQ5Hi0hhzhABhAtat9qX0ZjUqKUGdThujLVDhN1Gd7tbT5DCto8(2ZclCfKqbHKqHfg63yaDWHbl2o7hqKOSmiLNzyipOnaHWYiNnd4hvAwnbWrVNTuKHjfjmIboOC2urTR2us5bey0iyUHlI1uAebFOvmzHGweBUFP8SozAJyq2ran3kTf7FNNNqiRxZ5VWj56(Cl2mMLn4k1D8kFHpML1PXFQLzjU99B20(D)mKMMUKSRNYSbLIMfaD9YIAz4jEgAtsX3ZZZoLfpMHuGw3SPmQnhPeFa3g9qK(KLLazIL6NALYsY5XtK2CGBT(1JcRaHZIKYfx(mvYKAYVPr)J3dDJs5mOGQ9N9r9iUMpWFyd3J4)9mv4ozWTPPRXYIKgm)C1(TKjm5kSYhz0RVrTxkPTSXjVLXtcwlGcJCIuORM(pAwCRypTBMHPDOMhDlcDkzx(QCDQOFH3iRqpPh3KYGGr42PZzTlb(kJVgTlEWRjeuvAGCBbfSJXvrFOyD1SNG1UzROgm4Iu(kk3nqc6izEEV9wrk2uwepkezc)aE1G)QvfGpnFQPfmmn6XKX(mdNeqjrxDCFYDG2PUsHSXE0jAvILJOQ0YOjo)1t1(vUaJoTTGKHdvgFODGNvuT)eEkpbCnY0QhYzDeWbxbHbx5UWr4BKtVVbR2opI6f7a(fdLYAGVSJXFW7XuENDfjVPIT8tkN8TtpBtCydq0T6Wt6Ns(9qTqadeMVPYW6XywDet8EUajsJruCSvmC9JHlHaybfbAnC1DjMWJAxULjjjkMuGlNBBJE1QOLjaTaz6P1Kxd5vcpqw1tTT6vO4zmSXpr6D2wrQcwWl8Nl5FWiIbblzbW5JLHWifbHCV1j22i2eVgDyKeDEXf6Yba6UlWIqUNSaYmVZnD6ApwyDB34o7KkzthXpWlBfflqjRi8E0vrbXQbhBeFRJDJF(tajqjGHLLcGYe8JetRMcaIcOxGkpXZFLzj)CTJ0(Pln6dMwJxQPAWoBy3lKFpjDCFJEdP9l9gLfb7bpMn43x6pfDKMDOafzOZ9INykewICxIR3dZWKx6L78K4YISIYfMXhVJ64ylaqV(r6CGLUpxByd58C5Wiu(0vTBYvBjUdSbvPWa0xT9HICqoSjJ7wFgZJVc7LNMFgZKTHfn3uDy5XUNTagqQ9Bmy16spafnaqt6Gcoiz8IUvkBng6TltZtRwXuLej34tmADxhQp)gwRERzg0aM6rtuGLT5ngxKaSEzq5lMTMmlWIjykfprOr0ReLfc1HLiUtzLpphhyeowJIoLl)27BHpuRqBgzN22zqosvAl9rxfqIGbgKpfFq4(tW89cBtKWKPgmdWCWkWQecvyYfmRy6TDCDlMUcHrhKGiGu3ErVTFHUw7oNQ5CgEMrprq)oeKT6rB9zSyYLxGxKvrdO8P7cSUsTZMl(xecRBB8vYdvngfkVkfAapitR11n5GdM5M6LSPl2R3laDTxqjsd7QVf(3tCpJuHZTY80GDGcZz39B6PJhFYzteYJO4tkHbMcVb1KqqHk0MKykhpvIvnn9CYtswy2bjCYJCQ8yHWWWNHJfsV5qNUvFC3hUU8xiladU7M31OFFhlcty5UaWL17fneDEopyxpJdsb7WNhrS(bJq3F(BCsE1osUXUO30h(HFHwZ)(tRrhbWbHg9o4MkJEF(cjglsm(bq)EH(YUBtZR3GrEHUlZTDa)wm9ObR72(sEOPlXHHalr7U9jLNmh(mozFQt9Bmc5T2jwZ0jDwoSr)45lFMdvtgnRgJ(CxwKrrKNFBPwuQ4sxVobs1x0Q5CRKJsxt6mZ1tUswIxSYBLkiRmHRzMZed9gwFyODvt1kgmwJ4KEanN13ebT7n)I8K2cqSnEK)Rph1XfpWBw4rHFBb)erX8ySxR8Z2yN78sInmX3O73GT7Avy282Hh7548jsPxlvFv4jJsxQzwuN6i8vCtwcq1PJSeJiJb1)7NPcTmpQ1uepqAphYWkXPrzcB20u1qi)K5AGz57k(ZUl(HU4aguB(OwtfA6q1bQwZuVcrRuBA91dT08rH6uG3sdI(0tX8yGNWc7sDnRsbKSo2keqDrwdJ7dPHXaF2Lwr4awFmrRcDkuIrA1bu3SP38Y51kVzmSITsD4zRUJkzVF)tGngE42XdDZlhi5zVC7X81xhaAce8Nd7VWabF4fT6d9uWkC81(ULwhmnWFH3T7DF3ALK129YizGfUMLObv5ROC5sUwGKs7BuhzFDDUhvCEk0RgNn9LNQhJDYXO)3T6jpB9G)ZTbf6stilu8wPJ2zHYUGht61os(B)ck2baSRAGVQFVTYbuj2L(JZGJk8si8cBmmqeLvjzB6keLDeE0yeSjRp(uXZcS9WwzLAoUiVkP8oWxxoDLs4NslpYPW6)DacGi8E9Ek4x4Y(D8BHxwwSgX7Iq1s0qm7Pjt412p8eU)XCHF8kL)fWftM9CsjzLX1GvMhUJtNh0uFIqRggM2sNjDRi6ze57FbUpYswwBJMIQYf5a5g(DbUnIlJo6m3vvutu2TvIcQKSQKG6(50quUKHGDYIae)Vnj9yOBHFPXjIYprTvi)TBVRNHIBwbsExrZO0EykNR7ub2WQKVzeNU(Vm0NXnO1nVYGKb3UnTHXrsDsHAI9ErhBMbQef8voC0uZzNs5rozUUos4YFXx9IDdnT7yPxwCMqJfIg794OxuUpma2MFtuQvVtnE0FQDLge729aT0K7lVVTl3VVVTpraLhHT7ixQ9BYkTwSvP1mMOceJKDqy3xYtQy0lXSjUJs)RPIxfAOgzabAMqKccYPNQGoDJL6R9NNf)U)0u9XsUPAVfmYkgVoCTwemxXhvum5s4SHTQxqsHhfv5ON5ZrvpuLR1PlDfN5TkaBqD2unzvzS6A6LJo3fHDYKORRQp15Vtavh68wBNCc7OQ6F5iORE(Km7qhgqXjzOWVrFAdV)uGehExwrqb4CHFBkmqXtO7TY1GJ51bXELfCVFFjDdTSYrHUczIdcLe(DfReHXMufN)qvJ17jSG92H9(RWRtMy(wCHJM490Qtevk2xBWvxqw3d1IhGV8mdRi14uxMf9DQ(griJp7OKlK)XcpD1ruw2ArQ5j44PxFpazvSkWI)w6fo27ReKpZj)xkwKUmfDDfKw93kS7MMJWvELWe4Qq)KBLQr91bT9LVItniUOtvVqqW)79M4QRGwpEaCfDDhZuZD7vW9Kakeh6vWT3VjV(DaN1Qrv4899dPRV0I1V2k)U4H01VOB7ThsxuCovsWoFiDvmvDBkEBwXi2uq)F1VLSDHOhuT3hmgKrV6VPNvJvJ5jLvjLGSoslaOTtGzZyI0kHcqw(cMOcckxZnTLcXAgUq54Oa((7Jk3OlhrRGgE6KIiajFEvKJThQQb8rU01s0j733WoFEcnXY4VxdLmD2BWkVevehKtHvlo0cGNh2BksZWqunpjRMHN3uPqvXrJUKqMgQ6I1O2ynS7AqtI44qcCC3Ul(K8bKbnbAJXRqcFrzigGcO2Srx8BOHcyxUg8HddQsL1JBtw3oyUB2fpcE1hOOmh2k3XMwLDO(pxtxeVJnOqR)0KXtoD8PtEl80FuMdI7FZ1FeeqkfW2Q5s18kz187vqCg9pBsXxzj6DIjQHbeJq29K8bvJ2(J))sH4uzYFeeekNnByZVYJbfFfrU0xZcKDw3o8Kppuo6V1y09zXyXW3LfLnh)V17Qxk0V9k3sFGUgvhAkySGDPerxJ6VLxRNm27I1wPt7vTFD07CI8QLVXUyhMcpiHgCyngFp8FBh8T)OJlH8NH(D7k4j(Vc6i)PDCtmq(FBcmmVU7YIygqcNwlZCCpBVsg5B8JnQ9Um7at0572SfkY5gtGV0NtmbDLEDDob7T7tMt0E4(KXuuSjHSCzf5Q(xDGu(3uRhWObhIYb5oDZU0DBYAO6JpEqxa(hF0vigr1ESbhCyFaPp(yNGKHktJTzIVY)B94x9vhYvquiC9rNmE4qXzXxGC(HCUbCTyLM0iEXVcBYg5LEcM4NgHwnVWM8GZIMH1W7Ni6EGnJjW6x1j7LIP2e)ISTh2f)HFfNSth3bn8(edBxe4M8a62QJ0hqPG)E0HbgHJ4JqW6A9RLdqxf06JoShpPkV5KHTJOJhsLxBwfyE9H9OcWCXLb2Mdh(vHEesEZjx4QzLCO4i5G76zsj8GFOPnxeTe8Zg(vF1jdcSLUqJWTar9lyu)QHr917tmQWdUxmQGF2WDcHQLkMFJx8YkvT1e9Ylv9PN(R1EXCI2d7LFT02XAI(vyV88fUWPLdKLN5xTt2oWdIPsGfyS2ud5G(TYC5rGDBrAk5PlBQ)kBZVyzkDZZg)s06CO90CpbdCh9qRVDeaSVS6Y(AC9qIi65B2wNGwRO595bDvejEpy7Pxky8(sPf)Qr8Ys71CEE5j9gWi0phlM7ZKZ7ptM)BXvRh)gSpmkUcdKNGdQ8SqF23toXKSHNAs7RmmNJNswR1WhWI4V4QZBnzVyaj)7IxcBszz0oHqkQz1PX62zgH25a)sBSU9U1a9Db95dA8ZG4zrNYd)GNjDQjEWSFbefHpbEw3pB48PMU17LEL7Bc0tnvZLUZ8wvLa(hqA3Wa(wryGUDgeiBajzi2osIV5N(MtHieSyzAMmyYQgjvH5Ol)AZ3uMT)OREbbik4PJJHWJ4s1xPLJtxE5bHCiH3hqMbhEGyV2QQJIxhu(vvJM0RfO7h2fCT67rHX94Q(0V4UhTp6lUBxgBxWz2)52z)zkQszhBjmeciFDWWyhJKw23dmIXGFtKI2JKd7LXGHOskXWKe3lHzcj)q2Qq3gzWhBz)hM6I(nD3fxEYGddNAip(4bU4ynCWbodg1b92(Diy7A85a1SkwTup8Gf1BNcGy19PqKctfTQAQO7i3aQGgTQMLxiti7vELyCFZ5dXf77K5OxB9Iik7(OhQ2g49Pz02zuirIFouaCEpQWdpKiTl8ej0dCw7dFH68sfZMviyJkd0INvdxpgAkWJ2em0lWa)rDKa83dzAqx0iuFGPpsnbIoImpPsUoknCPp7wo81E0xeprWOg)Vq2PLcs0ps0eCDmOamSnTlauEX2NdCbEXf83HV3Ln(x2G3FMNuFFsIww3xrXfBwbgj8vQnP9w1rigahhS4HlE(twJpOU41kMmqplir7TIthRC2OhOh4E99W093tqZQlY3)iNVkDTiVUbkuucd7QiJN4ooDmTTulzUJTYbOlpb2EC6HomWVmtlgy)a29MU(mz(WCXzdoiqaW7H0P6EqY4tjgtV0met79j15ohACmzAu(aB2Zy8uxKdHPBxxeAB06tPuNle5IR66JdTudW(pezCLvSV7UtE8rnxCeYpydDE5Mj1JpjqE8rj)jJwME6382jNDIGt7vNnEO)DptHU1ttIZs3u19z03UdBi)t56II8SuiJQsRw35CE(lYCEB2dBwbNUrv0J9j0nDPrTJnNaBHO4O5LqP3ljPE66MQ04U3ii1lO2O0uLYZ8OkMaAiLhgRkUShjahCb7F83ENquyGSh9ykw0u7Q8NWKj4VkeM5yz5Kk9FLiNthJL9dFhLnwqnWZ6Hefe2KRDXwQQdfjFtM5vbFGdrg(mya(zK)1TLEJcrP1dpvLv(ZOflOK4OAnM)847)nrCg7DB1VagaxBdmvTwuKszAgmMXrzXnz85Do7IPu8oO1MCGqbBlhZ5buv1qYwdchLwlya2kbftVwGQPOOm2kF4SFQOw(LbEt5vsxfr(YtZD1d5XIvn)71F(mQaJRDBu5cyKiyGaLPMXI7tj16mR0rxnvMQle)9vqP9mcgTabH2tp4Z(Qd1c7ms1bMCZSRPK(Q(kGBrWt37dIt8ffjuzocNQL0BIcEkwq5AO9r1m(dtP4xGbHlRf7NU92eQwiX4nHMt9d)P3r4CP1htIWNIYVKRUWkPSGJxMDJYFW38hatXuz9d7OmzROoxa8PHm(y(XjCJp1SH3IclXMndv5iAIwRWs0SPPNE2F4Bp)TsEICvV(OawBCQZ1vIoe)aFPXUpsRnkXpjcoiDcqYzoNFnyRYRZOj4vW(XhyzaGjFX5(Go96MiXWHDAu1IPkZG2C658X1dDe9MN0Iy5HBZwS2fsw6FdJUBi8kgmpUSHs0N)zdtb6M1mjZUlLemuEIAkk6a7apPdnhVQLjmrxHJjQqJq73VmKWrKtbysnmpQUoRJL6ttsI7J(euu(GODIHjSpMbizhlBIXXzbusUyAXWnj0l9uXOntziyeu(1EOQEVmjXrKwslHsziI5dzG5Ywdq4ThtpJRYS9yx1fpXwdd8(su6MFQ4UiUakcQi)a6De2DoY9iAApcFewV3GjYJdv8OdqFuglipWDZmdePXFakkqOOxVtXAH49F0CHyMpc1MDqh8CsSefjXrHCQkmmqIPnjdBsYbsY5WCf4zhKGBoFNdjlwtaYd82ngNLGGzrmgINIZlYukfUx1JfPq63WhsNRrjYmTP)Df4sZ6C)Qa7g42CYwxbHfWlfOK0hvUBcawPxBZNluDFa3SHqois90brHX2EralVSaJ)tO(UxKrwdDnkeTrDXvt5TLwvCKRBMxdbUmk2KQ6UYOzgPtUPihTbPS98M1Zrz1xAoJc1knEAmegr0O2ZBvI2uu9vwpny7lE5rDdzdu1PaKp82s0XjGcgjFMTFmSVAhofqaKrdLYlvmxEItZMsYzLAwnKog1)xXOGFj6Yl3Vrx()MNVc6QLPxrxiKqfml8EtNg0BSlfuFEYH1suvzqTWZ98XAUPuLl4o7zUdOtK2OdbDKaF7AxuphgM(8LUMg(Hyqv5SV8A79KW2(rdfaSDWZWgtKAaIscJIEMolhmCGL9ijlHIE7bbu5GnhnRqNW024bG0qxnllDe)UVBbPWpY(qSRe8eIlYRllYQmyaWn5lA7s03GMLTRuyi0lcw61oRaMjD)WlXvjtYb)bBuSRo918I3TUoI2Z0GNm6v3KNKfce5Tz9ZzMusoVJh66X4xIZ)K8QgSuVdh8YxaiSyTfHULwVmT1KZnKe(m6SFoQFw3Z9DTdVYDvpUuoCq4qF5I(G09MEj3XH9wWJ21K1ZQixnMGR5o3tA0H68EIlD18XncXr)fQq8XlWDinfLQ71XM0FSTApGP675VanNbIkJszA52RqHbqy00UGdbVCoy344m4aBc8(IMkI)UzrYtsnu5zGYmeegp68hF0wg6RUCcpyM4Ag8(21I1PdsBGowiNXIgBhoaCPxXSFap2y68C8w1kbz3NRKf6H6(vLMYnawX9ruDsep7jEr2p(30SPImvTPKkCC4JRFbOIyAEnv35Gp0YHPiG(5G)44qnmwtyguhOq8rVKXoq0KJYo(aN4lKmrEgmNiEYVO3ZHNbIl5Iry74igGAfgbYaH8es)xZN2VNsy(yqhnui(CH7pPon(tTeZ7weaReQQRi1zSxj8DjQG6cGxCq)r5VXX9ejk3LkpUhcyIcPQtEgwY25dqsy1QuDIJXcLTxO38INI6CcVfQ84I84Jk6AR)SIe0qeUnpPusKo5eYeVRhQkz8uH8ucDgB4NEHjfGJ(IPDpURZ7v42jvrLwXIV6sQEugUtS1xBrPS7Ukl4KU0jUztNdasPdMVo7PETPKrUcC3mg22lwuKtbnaNFuA(Dfqjkfe)GC0mSYGIBQ0YDeNOnqCxwIo(NEzUIR5pvOXRkkQsmChf7JwJrTsfWIo7Hr0QOJfoTAMkwmkEVMeTeIitHdjqiO(plKz75mrsDLzO)vnRxRycd7M0PD5BYqmEiVGXOAGJaRLWWp(yRodAnWdnpTI8zNZxtFI0Y(pkKNCnQJN74N7O(DUJJG7A25UoiPwLQZDCeCwFo3XXqR4C6HseQU9LOWjvt)hnlUvexOb5EAncaDNieHLDZm(tvpPr4PWVfLrIhOrsiHqXEFpP3UciekGaTE8VZfuG0)kkSQrbRrQuYNk8apxVJcU570GTYDNlyRGlERUYFA(uvZIPYICY4GRedKiNXefSgG6So)9aIeM8i8xMy9lNQ8lmLO87WIl3LfwEc4LOPvpKZwpaAYkGDuxYaD13eEoCFmOlVGmix9CylsReufo4Dp9yKDwmxTP1aA2smbu0qeLjTcQAvW39zzuXvfTeF35LPRqtEDAMma50t1H6vOkDSdr(RhF7t3sx4MMX4LLXHqZauLuZU9M3uXa8jLt(2PNTj2TuYHna1e3gpPdZZmzS8GrDFNIbE495hlJFTTQVDIIJc8ioIuysnrpCbpumEGx)oeYlhT(cXGgNZ4Tx9PJk0QsQVzyFHeWC9D0bbrgJObWB)99Ya1X18EUpmEEBS)rJfB4tuU29pZJZd8KQ9bNBsp0N3mJy(UyRPWqt8mJOCpaDwr2AmwVwMMNwTkzrhKcK)u)mTtGC55YX7S18zAWo4WosYtUkUEcZIaTYdvd21GWuFGbiqSGmuBfQf7Bp(i3Z46LyakKFLo8opjUSGjX2c1y916nouSruFxf1ggUFZvge)(nN9HCMYMpBodC97j2ABRkOcGukxLkm7nmFM7wEcJTJNFPbEA6jm62wkwDXhWmYDndK99mCwKveVB(ecdPSIibl4S1Wm8LsScBPzzkINqFvT45kwK(RApG2PR5QwldBAiH7rrsYLF79TevOwH2msJJTZG0qOmmze3(U3Hr8KaXarhJBPEjFQie6X2W3KdbBc)EmXZ3N1n5GVD5MzNSNU89ehdFG2dKoeDyhnn(bUkCdd8hs9DyzCxsOjPk5G(aSH6Yn)uF8Fx0oT)yKy35WVWJxEcWF5i6lmm2(RpeC0TaZz8WlM8IEE97RdgLenXTEEyIoXzF4UhtpD84toBcX7t62SRoj0Ih5uPCZEtsmL4sYGPsrsy4T4xVrVgX(cEmmOyj9qbvNNClPvTz3TJ6OCXeFnBTw87vAiYrLRuaHsVhp(yhNod2LZgNxdpCxVh21UE8OZ)DZDv3Kw)Y90FBEpvV0fzCjvVr9BO6T9)jUE6ElV3VBcPw6gm6s0dsb7qEGYRoW2yYu4(HDYMlh6EBeTB2tHbVoChHW76u8gLW0sojsFIQob8KZ1SI(4Zi2rgpsMiwejcpkuB661jGNyq7dYThik)lP6pxD)kz2PBf89vq2rbpd2MZedbbwFySUvtP5o6rpkHmrDz03eDOlqxLBi2fHjV255TBuZJcz0HWSq0S90oIzqoe8xcMA8k6GXGQZlttwYnEBRLidz(x(HmSeOrHDbKPW)c5jmt(ZQM1PcRyo7dCvfjT6ItHZjaf5(O02Jqu1f9fbCgVahg9RY1ISRfdUOTubEGDS73VRcqlmJhxLeF54rJprEm3XnyNkrRgqyhgM1QptqYUacbGy4pgz9JJqYf6QyI1Bf2(40H9hBY921gxV)JO1dDRNWlAhbPUwsyEHM6kSICsChWsOBnjgrSeQ78ptVmT84BujmMK2(OfDvyFJMkEyaqM2aMLVR4phMYIDnEla7CNAPg1AJkDxvjnyM(RSRS6W5UvLKjrYcWkctgkDJry)jQzogGZWXoSMKn3JLqv0rAriWjqPv0bQ1htSeOBagPGfWe5PyINNV3hCM3LkMHZW7eHdp5S))T3v3RTnmq8)wcdkoJr2AFClTWG9WEzqzJ(ABtBuAn4UuwY2OqX)TpRp9jP7ojf7ucLrFPeBlRpoP7(DF8ZypxHA4lXSLrAoyN7R7Ni28sUu3JpQKfAKNk)ZzhPrZye2S3O)QNRcXL(ua0mbp0PXwJTLBQTMBBDTR)HXw3B(dT)(lCsQ0yYfDMBkb8KkVQqDykhSipPmR1Dfyr58t4ncGl0Ieti4FDS7zNbULS4fFPY47fnpMkjYrsGDDg4zjEvnNWiX5364jrP9MIF9NuHn0xpi0X2XjyjIEyqYPoNyoe32h(foG0Ih5cNPFjo(d8R80b2nED39FNDQXZeJNqLZEch6dvqnCFN5vH(PrSABSSJcGWcejo5VBf4ucyQys9tmo0XsGLGKUq0SrWlWeKlyeJrRxCcvdEmBBxFRWraajAyywZ5QoTtduQtQdgi8fJzjUUbkeV5uKUgMOHxiIpce8CiNWYg19WMXULlCGFcrpk3Pl0s(5as7l2G7q1sHK91cL2YOfrfR71APceThyqdfKjp057RpxJj5P1)wf0A5juAk5vuRtVZVkmPN1fpQp)XZPupjSOl13)hBVUAXuF(E2el7)kzcXg1uy3ztv34URp3Rlsr20Y0TpWVAVt)QRUDkxP)oR96VOhclxBDWIPeDKc5A4t1bv43giNRrG7t7Yh5Ap9M)scbcB0o4f(uHNNY6S8REVQjOkUP8t9eLtpmJlqN2HhpgQE35sDNTsAUrFo24vdiZuJYPp)mwnvBCv7fBIKOnYQwSYgsfrEE87p3X79gxWQxP9eRHvp(Aq7ySr1vs5EsEVeYcylDziFuvbxxcsaiIlfuiMtkWb6SPeufX1gW7BkUvNYWkGwk(e1KQ1ntHjFvxNHyxaE7q0mSmQ9uk7iYotOXE4EtFrNhmtM1p0HGTd7Wvg3xAIezWp7SjZXrb5QlkeoQtV68OlRnOj4gqDPWWyyd8x88WDcUospHy9wSHuoQLZ1nXKKhb6b8OM2s0BIb)5Ah716JWoh7VJV)benBkHzE5r8NjUMa9NmoJWCxmwTl4j7T5n8Mp6Hf)CXShLCJc59CL8ECP3gaiNCsy7gadm3P(5Uf1gFaOv6am4Ovr0xRQBAKQS6ed3ku199QELwuQwgIf9ziYcQDnWhTnZXEuEhbTJAghqCCrLy8HhEUOU4bdUoSE24aRizlJRkm(xXprf6LVb)sRaNPAFdAYhs(FxDVHdpKuxLmnSflXyMioIcWsDZgGh3jb3OYZwJlFTEArbBsjSBqpernEo37zj0VzjeZYDVWUbwpXNmjRx(9VOxCa69ug)lZ0IKFeMy2yu67yeGPNNG4)Nz3xZSrBX5TtiVgTy7ppWmTeW1nQG(Ah1Tx7yNdB84tKh99rt4gHQ98jml5PyrSm6Hh6Ak1YfHYgbi9q9cZRCu2DwsnbfCcJc3xnqZ72d(T1lRxvlw(PwZNyyt8388)j4t8LD2qEFUTfBsihNfKXCoKCNHmI2R2Zqhtz0DEobHRfsII8y(NpxKRyp7RuKOJUzRfSZyqit5G1D52U)U8F]] )