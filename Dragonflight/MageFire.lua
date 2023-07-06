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
-- actions.precombat+=/variable,name=combustion_cast_remains,default=0.3,op=reset
spec:RegisterVariable( "combustion_cast_remains", function ()
    return 0.3
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

-- # Variable that estimates whether Shifting Power will be used before the next Combustion.
-- actions+=/variable,name=shifting_power_before_combustion,value=variable.time_to_combustion>cooldown.shifting_power.remains
spec:RegisterVariable( "shifting_power_before_combustion", function ()
    if variable.time_to_combustion > cooldown.shifting_power.remains then
        return 1
    end
    return 0
end )


-- actions+=/variable,name=item_cutoff_active,value=(variable.time_to_combustion<variable.on_use_cutoff|buff.combustion.remains>variable.skb_duration&!cooldown.item_cd_1141.remains)&((trinket.1.has_cooldown&trinket.1.cooldown.remains<variable.on_use_cutoff)+(trinket.2.has_cooldown&trinket.2.cooldown.remains<variable.on_use_cutoff)+(equipped.neural_synapse_enhancer&cooldown.enhance_synapses_300612.remains<variable.on_use_cutoff)>1)
spec:RegisterVariable( "item_cutoff_active", function ()
    return ( variable.time_to_combustion < variable.on_use_cutoff or buff.combustion.remains > variable.skb_duration and cooldown.hyperthread_wristwraps.remains ) and safenum( safenum( trinket.t1.has_use_buff and trinket.t1.cooldown.remains < variable.on_use_cutoff ) + safenum( trinket.t2.has_use_buff and trinket.t2.cooldown.remains < variable.on_use_cutoff ) + safenum( equipped.neural_synapse_enhancer and cooldown.neural_synapse_enhancer.remains < variable.on_use_cutoff ) > 1 )
end )

-- fire_blast_pooling relies on the flow of the APL for differing values before/after rop_phase.

-- # Variable that controls Phoenix Flames usage to ensure its charges are pooled for Combustion when needed. Only use Phoenix Flames outside of Combustion when full charges can be obtained during the next Combustion.
-- actions+=/variable,name=phoenix_pooling,if=active_enemies<variable.combustion_flamestrike,value=(variable.time_to_combustion+buff.combustion.duration-5<action.phoenix_flames.full_recharge_time+cooldown.phoenix_flames.duration-action.shifting_power.full_reduction*variable.shifting_power_before_combustion&variable.time_to_combustion<fight_remains|talent.sun_kings_blessing)&!talent.alexstraszas_fury
-- # When using Flamestrike in Combustion, save as many charges as possible for Combustion without capping.
-- actions+=/variable,name=phoenix_pooling,if=active_enemies>=variable.combustion_flamestrike,value=(variable.time_to_combustion<action.phoenix_flames.full_recharge_time-action.shifting_power.full_reduction*variable.shifting_power_before_combustion&variable.time_to_combustion<fight_remains|talent.sun_kings_blessing)&!talent.alexstraszas_fury
spec:RegisterVariable( "phoenix_pooling", function ()
    local val = 0
    if active_enemies < variable.combustion_flamestrike then
        val = ( variable.time_to_combustion + buff.combustion.duration - 5 <  action.phoenix_flames.full_recharge_time + cooldown.phoenix_flames.duration - action.shifting_power.full_reduction * variable.shifting_power_before_combustion and variable.time_to_combustion < fight_remains or talent.sun_kings_blessing.enabled ) and not talent.alexstraszas_fury.enabled
    end

    if active_enemies>=variable.combustion_flamestrike then
        val = ( variable.time_to_combustion < action.phoenix_flames.full_recharge_time - action.shifting_power.full_reduction * variable.shifting_power_before_combustion and variable.time_to_combustion < fight_remains or ( runeforge.sun_kings_blessing.enabled or talent.sun_kings_blessing.enabled ) or time < 5 ) and not talent.alexstraszas_fury.enabled
    end

    return val
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
    -- actions.combustion_timing+=/variable,use_off_gcd=1,use_while_casting=1,name=time_to_combustion,op=max,value=(buff.sun_kings_blessing.max_stack-buff.sun_kings_blessing.stack)*(3*gcd.max),if=talent.sun_kings_blessing&firestarter.active&buff.sun_kings_blessing_ready.down
    if talent.sun_kings_blessing.enabled and firestarter.active and buff.sun_kings_blessing_ready.down then
        value = max( value, ( buff.sun_kings_blessing.max_stack - buff.sun_kings_blessing.stack ) * ( 3 * gcd.max ) )
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


spec:RegisterPack( "Fire", 20230702, [[Hekili:S3xAZnUX1I(Br3uww0sdTwgnZK8K0RC8e7m(EFoUIM71FtKqGGIidiadwKSsPI)2FNLUB0DJUBakr6RDQPQutSia6LtF236Bo5MpEZ1ZIQtU5hp94tp743E8PJp9KZp)1V7MRRFCvYnxVkk(tr3b)h5rlH)97slPF8XSIOz4hxv0ugd)0I66vv)PV(RVlTErZTJJlw(1vPlBYIQtlYJlJMxJ)D8xFZ132KMv)H8BU19m)2BUoQPErr5nxFD6YVfg50zZs4xpPk(MRXx)vh)2xD8P)P1txp9)Ukz90zj32mF(4ky8MnUz16PZlkxp9JjlxvugLTE6phvUA86Fy9pWF85V643XF8kCjujE)toE8jhTEAAECwZS087wpDzu(JRNEFuzA0Tz47vTiDomhWhuwSC90vLPfLP1W7uxGFyDszooFXfZs0MVZE1PhtZ3)VIzPZFu)7Oj()4d5v1r51V6VLNb)2pVijhF37H1W)bmNj11W)L549wA8(7jllUh2)xhxugVy90Rwp9NESS42SOQ61txevolM(VQItYHnrH2y8Aja8VNCFAL3Xa3xXlsI)06P)1c4VVUUmj6tJV56S0Q6kedOSy1KvlIQsG)4hjekyUaO1SB(Z3CDmSltaOhCOgxNEFYKK8KLPiK8QlBbSJxuupPIg5jZZaen4)o9tWAA)1tpy9u6ST9vgd)tmSuE6P2NohWlRQlkxQ)q(7a04Y6fjLltJKpCe8)4vur(nxRnJ3udOJE3c04nljQEXTfL5jeIgSclBYtGJX7s4Nvnzo8Vflhlgd6Du7060LjtQlMaei32uHlG1tVqSu1g6YKLrP5v036cYDQ2Yh263gLLHR9ZEMGFarzcIP0b6ZKvn5t(eGbwnbjcQG)RjaGC2Jsaq4xsTvaelAoqqWa(UKFzvAjX(yYSKSOhNOgiyPFS3JVxh(47327LvscpCNCU3DYZeR3Z88MWqmBcppJYBTgLMQKjpSinlHqSaqbYCqBS3td)d3htOrAYQIImI1BVW0zfpK7K(4IbHzdZpd(IkHv0yEqKCC2tcgbksCgBwjbI7R9WoCK4hUQm5(jfZNp5U4zABn5yZqpThmogwL3POSvm2QJYsYRhd)7Vattu1)kcyT0u(ObJLyaEHqIXZkJURihGsLixKXemI40HJwvcaqG9rDrt8c1ELzdIhuIvlDePZxHxGSK3Y0v8dijUf5W)GAdSE6FM3DWuGcVsHdL)EXpb)hZxp9XIgq4Cr(xssJW5mjfXkbHjmKffbddwPH0f47sG)ikFM89bbvhensogllWPTEremv1pacOIYOTli7(GBvV130c3(sa2(DaKd4vZGfuQgSVpIN6dIHp6AgebAnGWiy5xjXSgVE675TWScCAXNqy2SewMta9PFxlowfp0pqIYVUb(N)t4vWfYFwGgZtbJlJeqVB7ta5hhFGKwhi)FAiTOSgGHwsCtTCE8(cjTm6aQYJhFoJoUh9jTYnB5JPqTXxtqayWlt9cJui3IPwXnY7IZ(n25RUrTW6UCsgPi0DtDQR7Jh2qI9vfP5M(2wSncYMY)i7Dy5putzTQvjzzvtsZb2RP3TOwTXFUSvm5Oi4vmRHPmJ4NJ4xFTMkQSkUmLMbBLwsyMyuooItF4BGjWMYNOf)Jw0IYfFmm1t4)ycQamRg8e22iHCigVOchMto2Z40k50egWpVASsN6dV8R5JHJsNFPl8K9fOHPlxvcMcmBc)67lSiY6NLkWCXzFfkCAz0V0rCpU0IHL2snecnvDK6QQ)ATQQ64fr6iara4l9aWcs)LpOlPwxosoP5c9AJ00cYXI8IUSQ0w0hASf(khddt6shU(T1H0aabWNiiIcXhy)amaIcPAJtBM8OD2j(TQzVbQPbFCPM(vlksYt)Lw5nSEg1tUTiVPcSZjP8SJNC6Qy6JfOJOMo0onz5TjLvghlNsaCbAPK35bpNpvD(ZWfERG63RRbSy5ZVcbI8B80VfHp(3KdIpTHaetGXyZxB7EeGpOvF31tpPVtf)2Z5IQPDOycpAi8BiLn91vgwwBQsnnu(TvQZqPBGDuzCeWgemdmROIS5FFY5srJxHSac(UtW3RDrz)yAzzB8LsyRoJbdjn)mj6ljVO5Ufida4aPUcD(vTqUjCygH6YtoaIKW(D6wqfvH6wMLHYNbCGAqVrqi78wj0JhmWXPnA02YwL4ouK1jlbTVaXBcmxD6X90XabH2XjWInc(OqwXEcj5xxxfY1kAlc81UwtR6jTk0u5YdyUvJ38SGnMO1mcX0YATO005i0AV87bTnT0ZbpIImSGAp36BTPgp4x)XHOX)vm)a1F3NU6b1w(WE4NDjXkHxzkBIjV1IJJu5dY4phSGAzxLKKnb06CYTnL5bfpf2vHda(Uf2OcQaZfTonqp7Pohp9a5us5ClhdhH(evCLlb9phZf(aWRjVOwJSjk)rW4887oIST3YwcKgbySC3DjM(Ayp0vgKFlqExaKcTWh)mawXCczGmcqjhs8qrtg6xc0JEW7DlQ5AI4J((V99ip1zcJ)XH8AbGeOJriPG569rPzeUbZozwY8OMSAxSpKWH4Igm6ce(GfK4VWeE4IcyoGE3G0ELwrWNx0Dsnru18FDAvC6kadnQ8r0d1GKNzs8jx47Yfh5u7hIkxzTY(iUeQsaUwWI7J0QcJedVEAQAa2gpIGq8acoYGxkD5YKzPr1j4dq5KRAq(GSHAMXZbgzYDmr1Suly9sEDz(8w8y2Ruak6rsh3eJonQcEvCnxHto8NePfoJpuuIyo4b3Sc6udNJhsX1aHSbS9Hdk2lxrZMLI7tCb1U5oOAeoxLOG1IMAX5qsU4aC86PFJ67YEuiXTAbJvfL9q0JIvfdqIAhbHaw6VMZmdktUdeEI2aXp7B1IQWTj0gqq6IBjLSDNycAIurGmDEARGBN4SHK8uyVwvKH)4eAHz4xf6lUnROywgS0gdgHhXlWrHJybB6vbjVO9JUQNyPCOycB)n1hRjYNgvxrlq(g3LfHOHa6WKBJMHX)SDHfC(VskJBslo4Rwp9CywMppjw6RGoJVd)9lxlWbYJWPy2KIYz5r5XdFXCHUAwDggoue0rBFBP(heEpYBUUlyhrzqPN(IiakbyofL3I(jaD0gGhAfUJHVnBFWeWmCtB7f(wVloAWHxtVeDSknFKcmrt(NnPRwbufOGwqOfmTvP3LMzjx16Pto7nV90xFIH4XxFmjqKbL(Gooc4Ic1TmD5KK4S0vvBgMY7Egqh560ysD4mB5IBzbiTnfueQmTA5gT6o)fS6mN1a(37UShxTaHZrvvPltZe8nCRxh8BlNasEr1wKwFkPUDnmHCi4YO4iWmZjvlsavRw2uLgVzqh1w1Xa5YzvD0LQHJjbyhbymxzrkkTj)vKIu4g9OwHt0V9EuUYCsfO)hq8dQ3eiTRkDwITKiqI3Fd9J7dPuaxeP(q6)krnNoglwGVU4SE0stjOIuslch7O7sqj6uKBqbQG9YW)vX9Owy0x3kvXuUkSI)iPSaiHNnfUAjzo29rznjcDjX3ULfpoaU2gKtPfQsivajlwKwm4YkosaIfkfLJmoHTCSWSUQQgwzoPAoSYiTkia2)IYvK6lP40SE6pwuR(sHNUDfhknJ(xva)YTzITy1J5XQ4DXF))5Fw)qPQRcisugqv78pLuxnwIxotcCMCpbBgorLKjl7p785uk2GgthhnlzmyfoMBkx675GjgteVJiOiO2OnP1DFvdpn7sEc8)On3(7shx3NO4qAB9fy(8CGdnqoetUj78EPZrIl)eBWN4Aql11t)WD54jxRwRTiJKAXa2cQraJ4nRiPIOaP1naXtKitfCWD6GXiyx0(lCCxj1VvwWH0KGjM4C(b0Ole4KIEib1xNSgikxFHvY6lhnNw4uwD5E(viSvWEBskVvTugrrJjI9hchN8aiBP(HYOvvMMu3hY9inLiggQPBeDP2426P06sylfvSp(T0uX(Xto71)X3D(Bnuv5Cd8jdiMlhQRSLf1jmBcUsTyd0payFP5TxOuj4fYyGT0yI9PotIyynRe5ZImqK4dmw9heZdWNKNi98aG4FJEovOz6yNE42u0mGYu1smjOdUnby8GJMUesj54)OPQwh33JCz22s0uyKXpqEQq9HJ34YMACbn5F2eLx3SeuZ)(utlpuis22YyWW2LgZHzXPRmpZXvqYyXF06zyIuzGogyx4kOagUmh1D72O66SnyhpmvdThExbvqUuEi6tW5mmjZlb6IT9kXA0dfgb0b)LnX00ml9(08Kj3s(HA7UI8nnUcfGIPtto5BHjWiuV4rtVCVnwuDNavycCTCIJG5aoENdQwYmCW4zmpPJNn8(MtEnrPOMFVJi6qoB7jgQsvTRyKgcFofTTt95(rahbZZHI7JCM1gLKQ1)i841MEA97bPIiZXpeNgB5VPwLNUJEPjP870X)1Em6UpfL6OeuVAxDXaDJGmsh8pWrcWNRrd432Vpr6BV3R53vIf9sYkgC3dmXxHo0oN1XwF5I6Lxbw26bQgYzUemujQNK)581B97pDs46DMWbKS9OzVaVSmlB7747W2WlHOw3wKvRNMgxnOfFR5Dd5K)C5jPFps(VnWwte4)3byZ7gHDrMjjuRjrHd79P(ZnGT9rvR7MCK23op6iy5w)KB3FUmYIPpIoqaB)zrX2gy3pDXoa4(Re4KLHIWtBT(kwHP0IwIjihDlXg)eSk58VGRojTWCwX)ERBCOQlsZvC4GM1KO5qXKFPojFwYmTL(q9UkbwLCosTZMDuFf6zOTqh2p8VLlKvSNN3KLblPznX8l(vAdK5RoHdgR9W2g3QLPLLfS2uchPR7FOxXzJK5mSSa9VcVNavarP50lexCpC2bda8)bQfws)OUVbCmxTW1l7pKdW)7R1gonaCloiVIVW9RH7mvAoCOUHt3JoqQitpZvg2K5YOo1Z7DagHEN6lKPVqF0ogU2QB(baFUWK9UPxHNKUbj6STWzdCX(X(9VYq4f0VML6Sh1MaNuJEgeDFSeitL1)AQY9qqJ)KTYRw40dmLDRZtwIU0Ma9LdPmLgg76lDp9kST(qXUYfVlbVgb5oFS07H7vDIkLU)22rUjMnJBtYOonWEWIGlWBjpIuaFhVshgQUJAxWZo(t6w4kActn(uc)12KC3jExxHRk5UUTD2t2BT1pwDXIJevhm5W7h9fWoptpHRS0M4BMXUlKSdvUPL(BmUiVUSiRYkxQeHwJIrevQvMQGiQnk)fuvWWrnUhE7yoJ43RhHCyGxvvKop0Gs315UIUwXN2t1niC8Fpw3yO7QZ0SCWk6ONpf6VjbUcg7xUyZfrI1ifFXG50Q74rYd7wnpvGVGkDYN2uQqfhTAfFe7xmL1zPjStViDDDk3hF6Jned2w56iuY2do7w(hHrn8lB1lBIDQ0gFm7fm6VAdehmYurhpeqxmu2BVAdmB4GnGGYCv2jDy18hqp7KbVFTu4DBYLojVQbFskYEULQf)POmmIPiMjECtKU)9gS2EXGfrPS6qyiB7ZSTqTR2lPSsg4MQgeZ01L(f9XowQqBOQMuBQcxMPUStwua4pN8HM5J)xfT8dBU5hzlKUBS7reL7WicfHPnIwksxjsQgctICxqNCWHcK5zbdK57ffF531c37SOimsE1W5nffyvCELLUPrAf990QLZIwyP8OXaeA7WrJfrhRmYUxey8aSuu5reRNI1MvnB6WWQvLCjWqP8BbkImnVMRGg8d7K0seI0gii0L4op4W9s6yifuBqmQLf8e12NFdOyw(M7PChtiQ3INKI3Jqhr4VZZtyAERmL3nkFlqXnxFZIv2LaJl8jWOon(tTcmOTV)Q9QxqCV2h76qDGMVJ9kOziVTYIAvQfEg5AdLwGC1VPT4Pcna9vamLrTLAG8de(xhZsNSSeS(O0)uVz(VVSKzp3(QWmdQcKkkkZNLL4IgMUHomgIrKOXgUsZzc9u3nZZBvGU3esoq((oGe3916WD2nHtsxsnzldy(56V3CqHQfuF0Y6TEJ(BPvx5wN8AhcsDrQ6GeiYlEhh9Y3GdfownNwVvp5XVHdZ0gUKYQKYpjuJWaWGNN0SfcQGjsewrUyA9yxMEb6RnhOWR8uTdiMvRE0EEjT8cp5xwe5y7rmhO6IPoq(A3Pud6TsbSDvNi9jktNL0qkuChJXkNIopPUBkqlqBxvKMroTgyldQxw2uPrz44H1osQzEOQl4eDPb7TzWJegK2cCC)8AhjRSyabOjwkUXyrEHTzHICtqT9dRDKpJ8qHYOwIX9aGQmL6Djl1mUZ5JRDKsB8WTOOmh3kGPyfA7qZFMidzP0QEeXM1X0KUopKto6tWKYqKmmbBUBYTWJ3OOA1jpR0gixskgOmZaEyxpJdbA97XQzu5zwJqUKuNuO7hXbe)QH4LgnBL3i71fEROVJeH6iIvVz(QSHL7GsQcnwHKYzvB7UkoCNnqjw1zDV7G(1J0EMXxpcteECSjN6rJUpRngA1m7Qm16Txm4LiXVfEJm(wZYMv6zCLtvp5Cnp4PREI6WYa7YtLQRe75KI53E71E2n(qViEFDvBDZy)970ggz3XZL(A9RcvypsO)qN(qZOg9B5FoiumXWy1Mq0RHEtrcgBREAiJ(2wA9qh5YVnWq4Fnr2EtXiGEVOeT9f5iziZk079a6TTkpl(GzjSZgRXhlFu68HArfZSQSiUc9NoNg2u3XJ87CfNC46CtL)oZNv6u9xyZ0OvavFT)YbeBJ2e1WsyODsLzMRsHN(NtKtckx95o)9cO6PvEg0UJpFemK5)LEe4Ms2FMF4Nnu4omKXW3t2t8I6QA7(q7S7AuAUHwdlw9goCXV)67lscHrM0nE6a74e)5ED5gT6yevVjSqqj3JmCOYNBxMsfn8fVhz8uOqkivTgokf6wFKSIPBSAfokDl0IyIi4h04zgkquvfRCiv0Y9)nsN6CJBXMul4pnz2rC0hUtAmQr)hMSbLdKHexfFp1wPYqHSqT7XHkwrHjTHT7rxUlZGV5GuWVVOEQZLDx3ydvwMU5FQsE2M14h9Ba3V7aE(HadIDKbFYFl3vi9xAXBwd61VXP20I4QkG)nc1LjhCJQ8ZDxYp3DjnJv3aUyvyIqFbsMOyRM8pAMPI8tp(RY7qDB0DuKmltJ)uvyhw5I4PvOyGfRrOecMpjIMeHkyMRfzdvxxn3TxYiFhwdj73e7CeWkQHkIFTVIXtP8cHuys82EBV)OBFEMz4HEipAtzTpD7e7CK2o6aNESVe9VnQVbCRL7gAHTUocxYnrOv3HSZ6gFQZF9mJFvKGt7VUVSXvfAn3RihUzrUhYtAWy1w9yo8Iio4cmkXLdosuai)nQP33G5WHcptrq(kSD)mx)W8UbGbpzps1xjeD4WfeAOSdvstTqN706X9r3ZUOON6rXS6vcYhwdv0IrSTZagW6AqosBGUB6k7TXoW5tDSszO7rx(nYNhB03i(whBMyKNboWERvnXfLOXYe6JKtBxbGHvc)LVYCQS1MMZQ91vEp2Rao6bdj63k7fgAf1QuO2BLVg8ne1rRGEP3qCpG6JTmrETd5yV4PppGlrHTeMVHDRlsvZL5jXLfzfLIpwTUCDbQ1camV42CoWQI50yydvkNQHripZPxGC9Se3r1xxInI(ASp0Kz6WZKUF6lyE85Lrpp(fmtDtAA7nvpzvD)ZwaFSPNbfgsADPZOM2Is3OPj3LmUjBj1ouMNMNwTizM7U8KCYnlKnZ53kt8xB3vZsTtfdTM8RqJGB5wqm1Rq6O17m6w8kLB(HubcujVDT0hwM5oAQMQVtXx)LIRGl(BFOf(WpfFMvhdC9uSV1v2v5dpjjR6ynyzQ7tjzNML3hBETCo1BBvxtixWov2acoH0L56Ea603n51w9tDhSGAtsOWkS0(EHiRh5u6LqYWEVG8My)ECqwqXQYU5Cx)UZLZJrdSxKgcSDqpdpQ)ZYYuRB((ZvFtpUsx0Qrx2KJEagXOQeMlYV13jbDTeOJD62N(qr)3tCpE1OYRA3g(PIvJs4S73BYzhF8jV(uP(io8Vy4nOHgcACHwLeZ9DtToNGHzo5jjZSFbfCYJEQg(hDyS8UWBFn00dbUFhrb5DHQJy7(18Ug9xxCYw3IAxG4YMVfpe9EoV)MEghKd2bVmMyddgrrv934S8C5p3(43me5HFMxZ)(ZRXebWbJgZxWnxMW3gnFMftaa0Vx4VS5U086vuvLAwLMDR5Z1ulRDrkguj5vOVHTehecSeT5UNupTtE2NSp3P(vBPCZPnYtUm)eRUOCaATkQ8t2MFYpdosWh6p0krwzpHGArCjlV28s9r0cUjTRzBMf2jxPA7(IkYnQUPKVHGQWuPfjZSNja9gxFuUQuZ9VFQoQfSEqlNn3ebD7TGq(02eARlEKFYNbCXDDkf(n)(c(zII5XzVDAMRXdiLh7ct8n6(Dy7ME9NAtD4XFootO5bTu9xQNg9kf7oBBQJYs2nBjevNpYsSYmkY(VFItGbrqU1upq5ph2XkXPrzsF2OUESy31GZY3u8xg7mmwUKag0A(OwxfAh8T9nYIqpz8)f(EdJMoNg3Pazqd31vFoUhddew4WVA4vkKL1rDAVfUyRnhRNxLJXW0qlTIXb68XmVk5Tb3m9KYd5U1LFZ2lQvE7IRA(k1rKT6VJR497FgIXOdx)PgZwgK8IxUdy(gAaaTbcVWYcy4abF4fT2d9CWkC81(OsRd2Of3Y72DESB70yevVLzAP5kdOi(aF8SJjvyoYwqqLVcJexuCVd5Bfjx36P)fk768Ovm1swWHSTqnffDKzpkbzfFJrMP5jZdnQZ2l6kkrb48lyVp9HUqMjiB3ujKfN4tDxFzf8pjdNUtaN7OTiTfbfdiTgrgtKoh00r01Caa7qn8CJYVtP8dNF4a1ZInSnStG6Z61oSLA1O9zI4W3EKEZ(7q0M2TOMohwknyC22H(4F79)T)06PFOsf6RienPMSRHV6JkyITz0BuL8)Dq0CoBiuWED85YJHbtvUbAE1P7a63(OEWb7lvi1t3JoDBVbDWrfEqisRUeP4rXIKSv91mOC0iQ4IAxExPYfMa6YnzOqPGawLuEpgIxZii69mEVHCU8Rp)xn67YILe9BezsUbb(aDxO4UgJoMhEBHXpYL2FHAWP6JPkR4u50tNoq2goDEWv9LTK6PRAxltuHuNIkOkxOP9rwY86U4QKBmICGHJ)UebNqOPG8N76wDsE5xRLaGjzvjb97HtNW6s)zmf4Rd2xSgWq3c)sJtKTdFkVNVhK5Jp4hp94tp74Zp(D4LuuzoQjN4UKofBepsh(8LAyFuEs)LOr4)ZMu6AHJVyRIAQlwgrfVdxTpvJx)d)xPOrCNCYFcbCulOaF(x6jV1(sgM77Xsse41o4KFzu7WFM1WhoNUKZYWY8RENmx5YLCkcLNx9oWEYMRUlFNj7vNH)C3RBdTiSw3o1aP3b2xmZTpD9ft9otWB21tWB3vGM359iv53XUhNDC(CVdRd)sBTCD5YA7H9upy2DeFAn2EfV2zc(J7i48zhVJx5ND6)lnbM6iydBCQar7qV(hCWjx1jM3mw42RpnMNyYEc7o4FlCGnB8yFBFpeGBnW7UHoC3qg(7P16j2eEHABcDx1(7zc9orIfP)zX7l4Dk2104(0Cy7nbEoKTkUoRH3tP31dBKzjZJAYQ3mMi2QbUl1tZZPPrdM0bKOtZNSdq2NUSBnTr8dL2Y0u2t0oGMYAkkwLWofUInj7l3tzOBANloZ9pGmXXDk1DP7NP6b(p90E9b4F6jxUKJ7BU7V3bdbK(0t9csgPnnDRhLR8FhJ)fFXbS1BQ6j8WtoE0i5zXNHC(HCUbC(50V1jHT50VTNGt9ZJyByR4Pb02B7ZO(xtR39zJZl269tF9VM7cBtU3Pt2B6Hh(q8v5fbOK3pYxksO5F(dpiWiCOyecEVK8vTfUspxijhEWaUedF1jJAhrhxDHFLDLU9vhmGQC7IldSnhn6lcDT)9QtUW1J1YtKdvdURlMWWd(b2(Bu(KGF2OV4loz)aBPlmyClru)mg1VAyuF9UeJk8G7fJk4NnAJqOA5I53S6TRw1DMOTVw1D8J2oBV4XHDBX9Ipx39Ifi3XJA7kGKpx3TnbsEMIxaqYPr9Q7SKVCJmR3NVltvTrsR1M2tg4kt7l0zWSDwNpF3p7CTkILhpcBNL4l4GE3oU7AxA5z8FHE0IhBBn232RDpJ)lCT7eLRt)EFZW621NIEc94lg7ZoWGBRX9xlDf29Qk4xtHxsWe8OwWlmyc)EAT6Z3PBnsMDF0i(vmybAwVP6nABghkpu6VyV5BpUTiwohApp2fy4deeah03jtS71tX2tgUPWl4PK4B(X3CgwcpfZtZujev1yLwyhE5xBFxXT(hC9wyrPGEb(iSZNDP(TV2rPZVCVqoR17fd3(hSNaqQP7LMhz11itZGYbTaDFHTrRvFx2BUhx9R0n3Vr7L5M7NRYsz8m7pSE6FHtDw4ylbqkWemL7ilisn89i6m14zK5Q4y1WEzmAKEsjL(F0EjS)2OPJiwQsq))c)bnv)mGqXtIQUKUnr0tmMzvHF01yrdwwmC5b(rbwPCuWlCwUxnIPXgmXukUnFEB14c7ZOYS0KY)pRf9UgQqPOCAlLEDkD2PezmJ68gLuDgoh7QgPyoVHZH2f7jGv0KjY4UOzZszNTOV5oOAeoxLyw6X3HNuH)KlGFJxp9BuFhDHJIRDzoIhL9q0Jv65kEu7imJtrVAU8ePuVSm5oqViukPD67Tw2gUf1qPEh9XXXlGRqEBaP3XtxxCz2x6MNkKl24Mvp9K)OuCb9M09UxwJUdo0Ns(AceNpoj1lmCuYvH8GLpVROp8k6sT7bVlTVg8WzpuGyKOsV6CNdnnMau6raoNbK8ZYX(6ypdQMxR68PCbLeYjqx13hhAPgG7uipgQTI1yZk6wvukVE4Pp9KjgqipZTFNZpaedmL9XG8PNuEnZ6jto7nV90xFI0HGx96Jh5F3Fxz6YjjXzPRQ6)m6DBWgY)uUSOiplfVHcsRw27CE(wzoVl7XvlWt3Ok(6pwsMfkSQb2crXr3wIvgAss9KLnvPX9Vribay6l3ur8HIWIPoPKkyII8xX1ZnofTC9OF79sj1RN()KW3HRaBuxzOmWkL6DVpKwLCKQYzs)xjQ50Xy1Th(YLflYFSZvRmYSuO8JO6aIuxh6IM0eYPoJ6sBOlIfFDBhTWKHTQW0brhvmizjDDurx9(Swy0B3k)chaxBdQwdeYOKs2YIBYeZ7TaHPaelK2MJmkGTCmpnaMrdl6xk)KLY1k5b0eg5AkfeRO)wp9hlQvFP4(uWvLZQ1MULx)u8Cx9yESCvl(EZU7wvxjBsuM6Y08pLqQz6dD1wxV(q83v5tWlipccK)ap)8g4loWiJbic0Rb9oaYuwDAF1QwKSAKOt8zfjCLiqt1CUL9rNIf1ujS19OAQOhBl)fCqekub)0D3LWLRaiBISx6dF77zCUuSuhrnWi97mBzHLSgqIUaru(J(M)ayk22sCqpDXfPqg4qpa(0iqoMFCc34tOYu2IeBwnsxIOnATMir7hn5Sx)hF35Vvjt8C(W(JsyT1PEcF94ZhIFqS0a6rETXvncZWH4tG9uFHKFdyBmQbs2eCBydELIF8bw2hXKV4CFqNbrjYcCGtJQwmv1nsto3TjD1ho5wYxlILhPnSQ4SP8Ra(UHWRayECzdFze)pBIYRBwcAMDFkRyO6e1wv097gZquROqK7TcHz(kcmrnEeg)(LHuoIRhfqRbW2X6SEwQppnjEi6tyXZHbQgWe2fZaa6RlBIPXzgwwvjtUvyX62EQaEZ8TyEewHupwvVtMK4ioW3ZXsoKW8XkQDEIYQjVVXKxZTYmhJDvFYejIj(6zQK0U5hlUpsOGIKlY3tjBfqZXzBL(8qTdAQKSWjQvsNr(z5XgGHymwqzGx0RPk6vqmZA87tK2z)EnNzq0)K3mOAJeBDqyzXLZQLOPjoPKtvbQtQodrlxMe2Jj7p0UInd3C2gUzhQXaY98(AGKLGGzz6HqNI3wKP1PgUAalsP2VHpKo3GtK91fZVRax6Ot)6a72Fpxb8zuhsqCbSTaLS9OQDtaWk3m4FPq1DbCRleYbtQNpikm22wbSSDbg)bS9dvKTMUNKwskrBv)6ggVn3(g8tdAkNQJAA7TFxEc9xgTeu43yTnsTBVNhrwbR5ASpNEC740J7FZt4stJtmVmDyKqnmlQQb71Twh7YmTxM2iTSw0g0o45E(y9TOHSaL6HXw6xr)OzEcWSK4tK2iotD)bX2TB3cCuyUux6AAehIbnOPlXRGStqnGFsypGyGcGwq)c80cRmSSXfOzTLZldobWQ7iPAjvEFdgOkaBoESgFcBpehasJVQ9LDmZ1)BMXM9sQ8k3vs7MbR0RllYQS6aHchFsEWlcVOrT7G9P4qyE1QU24gznGZc3nYsCDHj6q(qxuSRo7ReDzctlL6ot7)SrV03XMYq8s8EGxzBiNPaRsGoqXMXexP1LwovPuOQIDl(C)bl9Jq3(zY7rcVYBCbnA26sosIA1QpIQfkfuveg3II3QOBmnUFU)QIfxbVnbnGQyopfcX954Tb5vsEvd1Yxq6Qwaa1HOYq)HAE3k3KNO1kj3nusVi2O(4QrC0UAa88gTFyS3lgcn9RgKADhmym721uNwlUWwPGR5E3tgS57LnKlQxFc71Oj)RIBLABkZJSzV7Ubd6Rxyr(mHqLjL47eBntVfP2ndanTp4qqIZ93mb67Vxx5N(yiYQpz39SucB0AfQwx7uxC84ZF6PUMOC1LNYYQLxq7Fx7APZPdXBGpw4i(sE0hpaC255(E6yJZ)K62RV9(px5WaiUsA0YlgeR4Hi(YnNo7zr9DVaC4zZSzsIAhr(DNNBeQWnTs6d7evwcq3p3D9u4sZSeVYwDCupag9wDaqdo6ko3cvJW0(lpjl1v3G2p5Gdca3mYuxof73L33fU)K604p1Y7RFyANmXUVSN5yV2B46mWqJiUnL9dcEvmauXOkL7QACSPu3M(hrcxX0DeWBzkX1t)VxjI4TbU8EQ5ASheLbDseKvKpofAcRCD)6DL2nNaBcsHZ7Gers0yZY5WanRVlprtpqxxigkgrxDIqSTZ(W5fNkvpEKkppi(aQtiq3nQRXDu3B7kRWiyCO0x2yWs5A5YWSrKDnB5nul9rFpgfzq2tfJKGdzNwWUNSHB4OeTYQ6dz4zDwjZrv9ZG9dCSyG5e8GgSl2vVL8PNc3bDVQ9GFesBkbyc5Q86T6sTgAOKFLMu3tEbr(zS2qpqhDQh0tRfkCGUmPoPO8544hjirRfB(0tAELJgy1AmOllDB7LsP6EvQdSuzaovrSIAdI2gKQzitysK(30Mc(T9iAwTa77sAUVNsa8JWSyk6UICYM)sSRz5tLYHYbFCGd1z0Cb2sqZeE46Rac8eZD3SUhjEBtIp0ToKpdo58rMAmkGSQJ3AZ6l43KBaFl12fRMRiLOsvxY5UB4xc2xCaZX1D)VkW2jPeTj0LkBnR6Dai5R4817BIjUccuXSkbuQ4h(dYCxpA2SICoLNeOZP53xG(TaTRHttgCLvDKwk3XQ4Ukl6rXnTQKoqKV7XlkkQsSKccF0skN7Q4edFmVk6zHZRMjYfJwU3W2SMMpVrgovccA(ZsJbFjtK0CDKzuvZYLAEVQ7Jm1YZ3Kr8FKzI(bUsf9NEYtTQi0jk5xwenCeLMHKN4dFu48qPmDwsdzp3Dyez2WpVAvrAgfrhWGHAqwCt1goc1fCY80KxXjI0kd7mg4GaNeilOyuvoK90aiXnhb0(OLyy8a4iN753bi6B2ySOOmh3k3dZFPhorKF8UKuCQAY)Oz2DYSApODgDgbKVteHWcuMXFYR1IbhHNJ2pKewrAsQGespg67(YYv6S1EPmR)MyUtYCGm)Q4i1DleXLsDpCf4UWzCWnFVbAtT7CbBL6u16eoTRHzBfwo94GRelKiNz0jUgWBzQXNOPZ(H0VCANF5mTF5Qlp1FGMVCtwy5j4Tt2KQhZH1dIMSafh1NgPx9MWZH7Jbt9muMUzR4gE8CK2LrUwpaxAIfnsc9ZsRdJsO58lVEFjuqqBdvQfPKZIsr)wNi0QszrD4qLgiAE98csCzRuMX7777sLPhSPbUpSUAq6(Jwl2WNOcxx8cpo3ZtRqp4CZog6LnZeM)w6s5pmzO6NgMRTd5pGJ34OrbMTc25hoZMe216jxKc8ur(mbKboTsvDoGdqGeMAKXk0ibrvoJWST(X5fVkFyYtIllafdMPNq8Ovt3cQnK06oeEJ0(aRHrKwnAdI)0QzKYhEmYOMRxD97jDnXwxEiIuA7UplFdQnY(8A4WhBhUsCFpp6zm6DJ0H(Ipqyq6Bgypn25EZZQSqSVkm0R7vHyTB5QYnTYLstG9EjRLxyF81UX6PljrEg3gmPlfwWPQTaSFLtkSLR(wT7mq(P4ZSQ1P1tXA1PmmBe3P2JdVQRaIbsEo3kxPCXdfhMUbUHdOTTVCR0yu(OQO4w2KJP(HimrSNAvxoou2f1EG0JQd(C3Qp)X70JP(R7KWz2XEUUMXvCL8CfJ3xwaXVJFAXU1glWIDJZolpXEiG8fUKQT9q9xDGMpLV64rxC6w9863xhmAvJLBZjOQbui(yaxe4grBj096UE2256(Cxtt4U3L7E9C9fcx5R5(8q5CRNcWQ16m3pNsHJlo13J7Swch2c1kfrOmFJNEQNtN93KZgNKHhSP0H9TRpE85)UHw1nR1ptN(Bt6utx8BrKA(qtku)rw0l55))27Qz324gi8ZIUiSkWrvYb9sRCkkAYHEOiffPO3I92OvXlGSuG21jiag6zVCgYH)oKlPKSHIrrUeyTlx(ZWHZ8nFZWV33EYpKF03Bc5FT8YD0LKnS3mR9Y7iuZneAryUuXpmQldpfX8vvHZWL(jEPfnd1FeDGqT)aQmy39A5powP(34)OuK0eE0OwNkpKkRY7PBFBT7(D6s4GI8t193VtgwNoifcHlow)VeEB5Q4QzVSwqGbosM1YOVmUdIb8fq(Sc5oXJYhASXx(c21BErZKKqi9rioypvOKHmUt)tY6hHLpyWvJ6U2gOYmbGJ5r2JiWvRwKHUGSveBafo8VuVcdx8M3FxlHI5n)UYvrZ1OVue5R1TMLq01f3obEjTInJ7w5Ekf0rYXTxwfuel7XdVhn1cFXl6A(4vZMoBUEzEGDWSorBtOXQ0hTgdcsz8HFz6xgp6xsfNfUUyIfLiX44vtYxAIF4gkRNFlcy4dw4mDUcEgEo5u6ukxxctE6woE(XQChKsK7AA8ykf67S714PfVc1yFyexj8n0vxnj0gWx5x3(20AwctcHehNZ6LATbJk3iIObmZ9A5L(5f8)QvUMPpciGaeggOLoSvoWXaNmCbdAsHNESck1uAeHGa)32jxqdEz5rcez0OfA9HihcephF0hytozly48IorA61Z(EfEcFjMTCIMdo4(6JteBEkxQn(hvYcnZBLVE2t0O5ue2mTbg4MW3)QzOzAxWCZiZZfnOHKur)3u8HC)nVfjezeR0XuDaAsd34aDpD(uEVzZaQdC1ectRC01CSf3dx4RqwnpuoZtxCPUupgHgOg()sEqHDtzj5v4gSmZYPGlYohWdxp5MdOoLC0Havp191(atMbINLgn0Gt7gs1YGMnuXcvDkhsD2Ft2vx0Y6e2CwiyEvBFbBUJ8(39M39tIdC70MNdMM30J2tlRtyBvgeJprxZVCkK0zsqMlN(JJRYyhqsBhsDyuIOChrcrhi7M1n7QXigwd11yQA6KsgoC3amrEBZ6ppu(4WKlqsohsuBxsbEaYjkOvsxFA29LHIGD4YdlXX1CCnKGQzScDy6O07GCUPGZeLS5ZsV4hNMbHl96)3RVIU27pzYvARB1(cJHyRzduGHParUUzvFO4d6UAnJqh83jzougdJq6gUYEgL)gwuaQzDxtAzgpcWfzmsyk6Bu28KTnDx)NrdBtvqDU(ELNjMrTi0s4l0dAFhtF4Hcr)yctxJt0WHWcJTOYH9fpDsoG43m0wo)b(Lr6r5oDXMaLNr2cYn4oxTBDW(AHsBz0ISI1MdUqAr4anHQQrckD(RT)P0d5VT9EKcfGgQBXe5VPThnMZjzo2UZdI0V1qyDiFEH9fv1tO24ofoFiZk(kKiiRXPqHUPQ)v)uSjMYohuEVq(PR(4Ku1PcHnoVroewULG7tLbNGqUDAiAK07SltMrqHqcajS2hFZFjbKB48nlzm0IAXA(5cD1i2dUJf1KrieCQXLvNorDTqOxsOBnQTfggF5KWmtXr5KhEGRaGOcCWFhKwIKSkz2BTjrt)bDoMsbeqUs7iwBxQt2A1ok7211)ehjVNczbULUmKpQQIKQQqBouwSktR9rfeoNKeuRkYVDeFVi5pleKl26gtKm8Na90NkGIotKDb8TtKMz8OewbpjMDezt)BUx2y6l78GAYS9oHx9c3hUwbMUcXaV)S2MmDb1j3ZI8DrxFU6IGFwAqJ3dWcW1XvoO4)Wl83jO7iMAy4l4gs5CSCUbTiALoIvbpRPTr6nH()fpvenAHOxtPcc0eZ40yUOmn54bKkVX2t)qJV)MCxVwLJx4smpWXnBzr3LitCP1qW)oHP0QR45RJ4acxPH17nnEH4)WJVREt90pdLwTOpZ1WZyHvS21AyoOVZ6AmqyqWNq0GX8ugndWPywbLOQvTRxJLwGnD9nyDnzLXmIyh2Fm(yLHse(C6vDqumiRy7OQXHTN1b1eKZppSd6I8o)e0gf3crkkq2)z(JmCH2nQwi(990U1zLpKd6WwN3qDozvee(FxFRQArb1GsiHjAwYvIbzmKZyXYE5nrGYPSpbo(HmIxfIacfk0LsuSt5zLnWw0FxAdovu4MME0NTu5HbKXa1xpkECU)Ote7mOiM(JPr1osf7lbyqL(nobqyKNG4)pZ(ynZgSfp9j251OfBB(zMz3wvvnmYW0OE)n6cBfXCMbY4ftWwu33EULMrqlMFrZ(me5bw9LLIabdidhlcvpZrGqytZiwh3sCG7Zgyle7b)JTlBx12S8N3RUsCvHN0bBySY)idznnBapNEBr3aYXz5oDokjpy3Pz7vf4wDS6i3JLlPNqVTZBOF2mY)UXzCU518W8lvlmOl6Zt)(5cla37(m1n)tUNifOS7OC7pMjbW47d9I)9H)7]] )