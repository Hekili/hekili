-- MageFire.lua
-- November 2022

if UnitClassBase( "player" ) ~= "MAGE" then return end

local addon, ns = ...
local Hekili = _G[ addon ]
local class, state = Hekili.Class, Hekili.State

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
        duration = 8,
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


spec:RegisterGear( "tier29", 200318, 200320, 200315, 200317, 200319 )


spec:RegisterHook( "reset_precast", function ()
    if pet.rune_of_power.up then applyBuff( "rune_of_power", pet.rune_of_power.remains )
    else removeBuff( "rune_of_power" ) end

    incanters_flow.reset()
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


do
    -- Builds Disciplinary Command; written so that it can be ported to the other two Mage specs.
    function Hekili:EmbedDisciplinaryCommand( x )
        local file_id = x.id

        x:RegisterAuras( {
            disciplinary_command = {
                id = 327371,
                duration = 20,
            },

            disciplinary_command_arcane = {
                duration = 10,
                max_stack = 1,
            },

            disciplinary_command_frost = {
                duration = 10,
                max_stack = 1,
            },

            disciplinary_command_fire = {
                duration = 10,
                max_stack = 1,
            }
        } )

        local __last_arcane, __last_fire, __last_frost, __last_disciplinary_command = 0, 0, 0, 0
        local __last_arcSpell, __last_firSpell, __last_froSpell

        x:RegisterHook( "reset_precast", function ()
            if not legendary.disciplinary_command.enabled then return end

            if now - __last_arcane < 10 then applyBuff( "disciplinary_command_arcane", 10 - ( now - __last_arcane ) ) end
            if now - __last_fire   < 10 then applyBuff( "disciplinary_command_fire",   10 - ( now - __last_fire ) ) end
            if now - __last_frost  < 10 then applyBuff( "disciplinary_command_frost",  10 - ( now - __last_frost ) ) end

            if now - __last_disciplinary_command < 30 then
                setCooldown( "buff_disciplinary_command", 30 - ( now - __last_disciplinary_command ) )
            end

            Hekili:Debug( "Disciplinary Command:\n - Arcane: %.2f, %s\n - Fire  : %.2f, %s\n - Frost : %.2f, %s\n - ICD   : %.2f", buff.disciplinary_command_arcane.remains, __last_arcSpell or "None", buff.disciplinary_command_fire.remains, __last_firSpell or "None", buff.disciplinary_command_frost.remains, __last_froSpell or "None", cooldown.buff_disciplinary_command.remains )
        end )

        x:RegisterStateFunction( "update_disciplinary_command", function( action )
            local ability = class.abilities[ action ]

            if not ability then return end
            if ability.item or ability.from == 0 then return end

            if     ability.school == "arcane" then applyBuff( "disciplinary_command_arcane" )
            elseif ability.school == "fire"   then applyBuff( "disciplinary_command_fire"   )
            elseif ability.school == "frost"  then applyBuff( "disciplinary_command_frost"  )
            else
                local sAction = x.abilities[ action ]
                local sDiscipline = sAction and sAction.school

                if sDiscipline then
                    if     sDiscipline == "arcane" then applyBuff( "disciplinary_command_arcane" )
                    elseif sDiscipline == "fire"   then applyBuff( "disciplinary_command_fire"   )
                    elseif sDiscipline == "frost"  then applyBuff( "disciplinary_command_frost"  ) end
                else applyBuff( "disciplinary_command_" .. state.spec.key ) end
            end

            if buff.disciplinary_command_arcane.up and buff.disciplinary_command_fire.up and buff.disciplinary_command_frost.up then
                applyBuff( "disciplinary_command" )
                setCooldown( "buff_disciplinary_command", 30 )
                removeBuff( "disciplinary_command_arcane" )
                removeBuff( "disciplinary_command_fire" )
                removeBuff( "disciplinary_command_frost" )
            end
        end )

        x:RegisterHook( "runHandler", function( action )
            if not legendary.disciplinary_command.enabled or cooldown.buff_disciplinary_command.remains > 0 then return end
            update_disciplinary_command( action )
        end )

        local triggerEvents = {
            SPELL_CAST_SUCCESS = true,
            SPELL_HEAL = true,
            SPELL_SUMMON= true
        }

        local spellChanges = {
            [108853] = 319836,
            [212653] = 1953,
            [342130] = 116011,
            [337137] = 1,
        }

        local spellSchools = {
            [4] = "fire",
            [16] = "frost",
            [64] = "arcane"
        }

        x:RegisterHook( "COMBAT_LOG_EVENT_UNFILTERED", function( _, subtype, _, sourceGUID, _, _, _, _, _, _, _, spellID, spellName, spellSchool )
            if sourceGUID == GUID then
                if triggerEvents[ subtype ] then
                    spellID = spellChanges[ spellID ] or spellID
                    if not IsSpellKnown( spellID, false ) then return end

                    local school = spellSchools[ spellSchool ]
                    if not school then return end

                    if     school == "arcane" then __last_arcane = GetTime(); __last_arcSpell = spellName
                    elseif school == "fire"   then __last_fire   = GetTime(); __last_firSpell = spellName
                    elseif school == "frost"  then __last_frost  = GetTime(); __last_froSpell = spellName end
                    return
                elseif subtype == "SPELL_AURA_APPLIED" and spellID == class.auras.disciplinary_command.id then
                    __last_disciplinary_command = GetTime()
                    __last_arcane = 0
                    __last_fire = 0
                    __last_frost = 0
                end
            end
        end, false )

        x:RegisterAbility( "buff_disciplinary_command", {
            cooldown_special = function ()
                local remains = ( now + offset ) - __last_disciplinary_command

                if remains < 30 then
                    return __last_disciplinary_command, 30
                end

                return 0, 0
            end,
            unlisted = true,

            cast = 0,
            cooldown = 30,
            gcd = "off",

            handler = function()
                applyBuff( "disciplinary_command" )
            end,
        } )
    end

    Hekili:EmbedDisciplinaryCommand( spec )
end

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
        charges = function () return 2 + talent.flame_on.rank end,
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
            if moving and settings.prevent_hardcasts then return false, "prevent_hardcasts is checked and player is moving" end
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
            if hot_streak( firestarter.active ) and talent.kindling.enabled then
                setCooldown( "combustion", max( 0, cooldown.combustion.remains - 1 ) )
            end

            applyDebuff( "target", "ignite" )
            if active_dot.ignite < active_enemies then active_dot.ignite = active_enemies end
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
                if moving and settings.prevent_hardcasts then return false, "prevent_hardcasts is checked and player is moving" end
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
            if talent.improved_scorch.enbled and target.health_pct < 30 then applyDebuff( "target", "improved_scorch", nil, debuff.scorch.stack + 1 ) end
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


--[[ spec:RegisterSetting( "fire_at_will", false, {
    name = "Accept Fire Disclaimer",
    desc = "The Fire Mage module is disabled by default, as it tends to require *much* more CPU usage than any other specialization module.  If you wish to use the Fire module, " ..
        "can check this box and reload your UI (|cFFFFD100/reload|r) and the module will be available again.",
    type = "toggle",
    width = "full"
} ) ]]

spec:RegisterSetting( "pyroblast_pull", false, {
    name = "Allow |T135808:0|t Pyroblast Hardcast Pre-Pull",
    desc = "If checked, the addon will recommend an opener |T135808:0|t Pyroblast against bosses, if included in the current priority.",
    type = "toggle",
    width = "full"
} )

spec:RegisterSetting( "prevent_hardcasts", false, {
    name = "Prevent |T135808:0|t Pyroblast and |T135812:0|t Fireball Hardcasts While Moving",
    desc = "If checked, the addon will not recommend |T135808:0|t Pyroblast or |T135812:0|t Fireball if they have a cast time and you are moving.\n\n" ..
        "Instant |T135808:0|t Pyroblasts will not be affected.",
    type = "toggle",
    width = "full"
} )


spec:RegisterPack( "Fire", 20230127, [[Hekili:S3xAZTXXrd)BHvkdrisrXdrz7uKSkBRi)k)8ghxH6j(BeCXIfeB0IDH3dsXuSWV9NU75yN7DXLISkvLIIfMzNJE6PV7EU5KBE)nxpjQo5MF90Jp9SJp50V9OtE9zNF6j3CD9JlsU56frXFi6o4)ipAo83VnTK(XhZkIMGFCvrtzm8tZQRxu9xF5lVlTEwZ4JIlM)YQ05nzr1Pf5XLrtRX)D8lV56XnPz1Vl)MXUM5tp)8BUoQPEwr5nxFD68Fcg50jtsyDpPk(MRV56S0Q6kCYllwmAXSOQe4F8R0EjjpACwYKB(XBUoUmToPmncgV4607tgLKNmpnPA5TxD5YBVpcAc66rZkQhvvxMe9HrtZG9i8FN(HKL3oy5T7V82XntNQ0LJG)kUE5Tp9uBRtbqsvDr5C1gzFhablRNLuopns04q4pSvur(nxRmJ3udqcVBbA8MKevpBCrzEYrnlOvyztEY0IY7syTvnAk83fZpIpguFK70605jJQlgbNnJBQWfWYBVGVuvg6YK5rP5v036cYDQYYh26JJYYW1(zRj4pQCYO4OQAlOpTUQAYh9H087QgbDUQc(VgbaYjpkaaH7KCRC1YBP5abb947s(4I0scZD0KKSOhhjhiyPFS3JVxf(47Z79YIhllgNbdmUto37oznX69mpVomeZ8INNr5BngLMQKrpmlnlHqSaqbsCqzS3tb)d3hJOrA0IIImOZ9aMoP4HCN3pUOxy2W8ZaFrLWk6i2GiO4SNamc3iXzSzHaioqPrlksSgxuMC)OIPthDx8eLTMySzqpLgokgwL3jVzljSvhLLKxFe83FeMMOQ)teqAPP8rnclXa8cHehnPm6UICakvIuroIGreLoC0QsaacSpQlAINj3RmYG4bfF1shrib(Y0fSJ4)3kOFf5WFHmDwE7pY2jWWLbJEkCa8pl(n4)y6YBFSOz5TtkYFg0(SiC8tsrmWL3()JbfxE7)lChRa)HcOpxtGo47sG)ru(er))RWMpAOymMxGtB9SiyQQFOa6zgT1oe61yzV(Hwy0Za44BbOeqxMbcQHpc2JhYM69JHp6Ag4y5TVhHhWYVsGfD0YBFdBlmPaNwSfclgNPYjSB90N(2w8Pk2q)WSeyrEDd8x)pqxWfYpYrzztbdVvNY9i5fOVB7FbYpoEpVATV4pkiTiVgGGwsCtTyE82HKwcDWTYJp6Cg64E0N0Y3SLoMe1g7g)cGgTmzhgkrU5tTKAK3fNzp25RUHTWABkjdLx0DF7uv2hpKH47RQ4Is4dv228TrqYu(hzVdl7dvewRArsww1O0CG8A6DZQLB8(qwrNIcNwXKg2nZiw7iU0l)nX5g76N4MMgzL2RWSlJIXHFsdFdmbM389Ex87nUlk6vmSCgX(hJqbGzIbpIjwoNpedVOchMtoomRveHmgMZ5kaFfXkeYfQ2TwXcD0reNfa6anGhGR7QDEFB0A7B)oXVd1THksC4yrEHnzbLf9bABHN7yy8l1Io2eR9QJKAICWLVKH8Ey60lDD7AaFZLoFrzX9jtgX6(Gjj0IW4Nf7Olo75il95rFKoC9RRdjba21t4xIcrhyqacarHeTXPotEKo7e)A1OYhzXSIK80pQXez)UV0hKufIH0kHZYBpXu)lXKY2f0Q1VEmUavTdfdAtdHF9ambQxPPoLUCu0q5xqCRHsvRQOY4i4(ii7FwrfPOhaNMhLhD0ceUeSVJW(1UOmBMww(LBp4YYPiXUvNs)A2VtuqtYlAUBgsEaorRRaXQsR5KFxE7DrOiHOexmc1VvvO7OkuCKSmKmpCBQge1aOvpTLq)r02YurI2Tf)sBDYCGLlC7KTu1ehwWxJAcOuhNatxe8rHuD5es0lvobK(0klcSBaWyAutwDyZCSNM9asRItxa3KIkFe14houNiwUkmvkAYHVMUwzaY)BmUxOSX3NGY0YiwcSkjAdiJocYFFuAgD42ddy0A5bDvO8OtYfxsxzzxXLAB4HtdxUd(bLENu5A0LwusK1QzPtj6j0ymAmcytumEIYvFTEg2yiEHd73HLAUsaQgjGelV9flV9Cn6zLrtsbuoGozu5hmoqVMux5FY6bioc2f4wbEq(tY55qe0aTwGIe9qkkRud(x4fnCvipf6H9oCTlDiRGSTUmuLS92FFeWUtNVUq8A5pSVTfUab0IyJ6l4nQUuLnoKenOdtSPq9wobga(3iBay3oROjBcQk5drpcyTJza4jcHeBpja1bzu9OpNuTKMyovpXa1oaCfJRiLhJQ5FiFEFai(PRxlOzw8hQALwvzMdBbODWX0ahhdawrlSDEAzzrzfI0GAdb3WDjv)FN1lgL93Z6NdaBydpToxcp7ydufqw1PnzOb3qPuSXv6C)8dzvf8REU3viZUXj1pKGQJ0U5Qy86YkifzQuBsGeKxiTscYTerGiddI4qZjBsq0esRpQ)2wlYwvg99ZBXH8FbR8zpwEiFJfzOhgJUFlgP7noJ7oUYJUViLmlYIfu)58noYuCe4i3gEBOBjCALbQKZgcow5lKmN8(56QX)QEPMAagqUSfZMHzEE7zZDziP)ACFmoAc6sNKPttIfQqA1SdDrz9eKb6ry5MnQOCsEuESIeCoAQNR)luLt0AyyMUUBUex1NbHalUurMT9QMfbGpqgVIYXAxqBz37PdAwjV)72q0j5MKDkI6OHRfC4h6LKQIAvj)rt6Ifjtocy1pcU4ctBv6DPzC1Mem6nAD0zV(Bp9vNO5oIxDmkeIl9s5OwLPZhLeNLUOsbxr)xxb0KVBnGjoveLT6MxuKNLwdW(0Q5kKO1)5vy9D(6U(mLAuCX8XfZq8SOQQ05PmpQQET2zZUvYg(T5Ja6wO1XyAQ5uHvoGjkocufDu1SKK6rZBQsJvapUACvasovVLnXtqtbtSsUpPQkXuZK3nfzGimvhOmxjXhOi)fCrvtqHKesyr)2BeJiYechsO7n1vPtsyCx0e76FiK99q0HkPfWMk9)KiNthJLPig4IHCsbQHzc2dsTPFSPmNP1KuHeY5dr4yhHS(EG5aaKNmOTnkZ99OkR0x3kykUIPFIqXGv87jNfenzctv4Q5riJ(7JYA4m5PE3YyahaxBdY2MtkOTjZbeXrzXCN4JlR4iP2ayRn5ibwylhZ5ixv1WuseL)mTwiYrRqQG2Ziphe4OPoXYB)1IA5xYnyQl3zOO0)Ic4xgNX3IvpMhlDBc77)F(rdrJktUlQCcosmyGaLPge44dj16Ioe(EJMLNaP9skZbwnaX74OjG8FOW1KhwD3(8OpoI3hUERXf5tAazUS6QMHrDXZa(dTjgSlTZAxCDtrZiSOaWuqJJOt57BwERIRquKpb4VDYXMMKZ6YVl7nX5udQank9UC8eZuzxOPL3(owBU0wcLFgUQ8akqadPBsrsfD7J2lWPqIarQG5FalSfoPI2FH56osaB4NU7oSn8(iivjoNV7NEddTpT(qMIAPKaT5QlSsMuIrtPfEu(J(M)Jme4qExI7wieoo6bG7v9dLrlQSSusqK7Hkck0put3i6yOniBvrwe83h6syeZJFdPrmBE0zV67)UZ)wnXr0njIgsI0iF46zKjwKnJZU36degg7cjJ)nKKGgIUgs97f4ugy3Cn)ziRVJpWaPp2iR6HyIKmQwixqtfVqfJIiNncxCTgM06khaJJlBQXFD0F0eLx3mheR((0ytJE8oaPQQ9Qf)wX4eG0eUiu5vkUC(VBQQvVj4HdnCPaT)rbc0xa8Q0ViirKm1NrJGTlPIdtItvGDgfx(vgd6JgTHXyJg6yaaic1DRXfZKYGmEJJQRZmTyUAd9fq0TqHN6w7OhI(aCgcJ10s4Ur7kX833Ile3kvGMXVSjMgUjP3NMNmAmzfBfiT7oSfxAU1Oa4NooROyYi4Fvp7XkvDhTBAlUCCRabqfGz7IPGaKmIoOFrMQ58kVDXWOUE75OxXSzhUo8By4o2eYfeEhcBN8j3P(ngzRSoG6KvzpoknonotN(8w1K7Dkm06zbu1ycTSa9RFX9roJCHssVGFfAMlAVGPWptaaGbadcqao)M5SFEkIatsMVettNDVKfVtcGTR(mI5iXwO)Eb6SiKi76e6Gw)hHWLXfz1Q(5)QET4BvSQphU6sxeWbA)mgCzKIxVrzwjozZj1(WveWRBbAp0CMsjQZfQitvb3E1N631KFXCsA56M)lC0oOpor8MGoh)u)wWDBFu1AAjhreSZJocwU1p529NlM0hr0bcyBkW0Udy399IDaW9te4KXUbDCTPuFU93JgHUFdwGmNnnNuxvXPoC3r1APgd3nFeALNX1LrOZ3lihplTTvjBfIAYaBGff5K7FKTN3mFmPv8uZzuydjYzxr1aSjlJIjxthmrJJQIfueCPyNlzSib7R6z0)1cM7NuNcuXM7kjNQJQYN8ry)y4Alxoz96IfymfvJglnRjrXMPWiKKpjzIYbxFTJmHujOBAfsfJubQh0n2xlny9qC4iU7YM0eZ64ZvgOUIBcXmZd4nh(wtX6yVqe0wQZW8I6wF1fnhzbtDiU4EaZfgG7zoAK(rvlJ4yUAHRx2TtvG)8sLHtbaRfsbNWij7OB4otgElhOQ249O5ZkYg125Q(nzUuPv2ENdWq02CFJimB6IYHMH9iewUnuSdcC7OWvqWrmje5gtD7ATgHz0UUc(w4y)2CQp0h7w8DvwgktGZ7OEgeTW3vTpu6SHGM1iwQOg8eDn71IQ0gv5L9j3D6hJQlDp9smTUqVUYfDlxULVZJWRS89MQLg3rgiNPa7Qe3JkG9GzgwGEjoIKaFhDXIyQBFtg8SJ9j2zZHAKNP(Pe(RPXi6HKe)WeMnajgZcONGBBCrEDzrwLbRvUNZixarb1IUWa8mOXFA3e0BtQCPDBedpP)YwhltkLqWa2U7BpWLJZi(IIWj3MU8QrxhpQnT3tFOI7aHtnpiDrERRB9hRruTn5GXLOPjK29yJj5vnylPiAOKPFe(tru0DHqu8SLKj(F2GHPhkm7VrWI1fXlSQR(5riXV2Puj9rKItG6QvGm2qD2WEIk4l679IxScI6U)kjTR6Q0yS10GVJDsV3VgcPTfUEBAfXTq6b25vzjjTvLP6Gq5EyWi)2FEKOqDTDQcNjFU04INJTDLHA)olfZGThh8QLmdhAYHZ232i1N7qVXeHHuHsgVwXd4eI8ePKPv8P4nV0oRFrcAlwGNJG(DY3duO9vZdrSpoYo02o0MaM6HIPNtCHiDbhApOskF7koRbh2UqBEd3gdVTfUBHRqCFyijSGfJCCmIo4WcflV9NjKOSmmLNbmKh1gGqyzmVnJ4cvAMjbXrFawkYqFIj7LboOC2urTRwuYYAh0kr4CJx6Qzj9d(HwXzfbg9In3VuE2XhBiJGrmi7iGMBfcf(355jme4R5Cc487VXoMLn4v0D8kFHpwy1PXFOLfgT97FwM2t9UL3CdPdQlj70KzdWBZNG01llQJel2xr2KuSc55zNYINYqku3AyGJAZrkXhWTrpgvpzzjyMyP(PwPSKRqlso3A)QBgEk6YRhzwbcXfj1mUKuQKo1K0sJMiVh6gPIoDDVL2cX18E(dBy6KsfUZm22O05u5dsdMFUA)McI4nJQqqg961Q9sjbCno5va4cPJQSqcwuW()Tp6f9G5wESixy0R(NlxnlugUKYQKsuiwladXqbNTqqfmACWYkbgGqMjeyGSxzFjoeMQIf43)qu5cDSOwj790jL4hp5JZICS9isa4hHlhtjdeDAnY4aprDuz6KKgsyQ70XzTAP2xwluTOinJm9lqcg0HRSrr4yxnw7ndbQlybDttEflqEyg9Of44U9AVbipcnXK(ng9XaMf)egGcO2SXAVrZoYpAo69aaQYUqFxIsuT7U5AVbF(SIYCCRakhwOSd1)z6AyuSwjiy1kixcdq7v1)on)OIQrzyW(C3OXqZRKNXSIvlLbYfNIEYzmGfPvJAr4U(9jzk24uZXfj1jfQwKRhEbQB)yRP9(kzXaULA66iHlocF1RhenRw6r0YvHgRW0L7v1lkuOaguiCXkXkB9RDj)YQDp4RfMo5Tg(sDxwy6wtaLlHsQ7mBODAYb7w8x)sudpgplb)XjxqREOuZqeZMFB(3L2TREPEl8TGnR(aUF3MmR1j3gKandhj9OCj80VoLLGG3hw35VtavFRpG(lohVV8rH1aQ5zDZIYI4kQuBqbWnvO2iBXxXIgDRGUqAZarOI4m5JnWN)6H)NQdFTBY(JVn)uzcx7C0gE)r0fn8BuHRA37CJpP1IkxQO0LzzdAC8US5AySjvP1z)XnpS0wl46JjNtBQBE01Y321j2xRDFFXv7(EJAG7jK1gG5CHTpuK3Tng14pj3ffJyZThnnE6EIfzwzfMIFUx2a)AjHRFLeUvU(Vj66Qw)fxPIa3jbuRmurGR3LKU1u67DDDKZVaEbxwFUxh58lH0oRoY993yAHzx1roRanmO5jOLHL7AetcDBRA0)UzI0YRRwil2ouJJUJC4qzA8hQcRZURlpT0ZcSy1mLN5LtnKeEsDlDMGiKFSD0UDDFq0hgFiZEIHhoSIAOSZv5RyyAKdrj2s8E7TIoJQxDuist(b8QMCSniw(W4rMr7NP15o9yFHSARxxCyccUzKDMs6T7aFTRZeJBFIrCoRhWSCXrN68xpt7x5HEXGL(doEUopomvbBpKNGzsWOQhZHLgIbod9rJIrX92HEAOy4e51h7sT31Kferfcp)hjtlvd52ny8wLud3qYBQGLxs5PF3OxTi27DRq6dOepxmGEN2yUl905iG(UYILegp3ve15osOVzaA9H49nmx3jXbNJ3sNsvepT7XYQOhjRzG7HlBlGdvrttWR9YYPwtEnwpL41Yb9sXw9mksgaK9pWyH0QlU)SYVdDJDDe1vGQRhw7bz7QCNFf57(oJm4h51IlQdLvIawg9ZtYgXjcTA4ImZRhDDvxRxbSuDJf1ttQCLjeBhyGLaYYhEp6Y2i(SkH6gz1ftFlHUT3szj2qkUtzc9rIP1wOgxsPVnxzofG2uIHUmZsqnuUulyzCTy7JhfLAd13mDuAKkVzKyWEWZVr(9L(tsNybfkPkh6CV4jH(XLip1X07HzjLrMny5jXLfzfL8pwUUC5APwaGUlTCoWY0mtBydLKzYHHlfItBL4QTe3Ekvvkme9vBFOiPJdJV5U1nyE8zinpnVbZKDq4AUP6ikD7E26YsuUK5xrAFHXMuyVrQxMnNQEdttZtRMLmrLrVCa7qLFc70t81j3xbZGuFs(3Uy0tMh9DUrIkS0S(vHApRXQFAR61Cw(ufMMvP2S1xAc9K)KYsZxk)jQeLSy1HLXcHvaB51uiG80CsQTC53(q7jdRvSnJ6c3YBXQww5roTtsxK5vIzVem6nMbkvGrrTHc99Qos1d7VZia5woDfcJoib1g4fHfyPTFHUwp0j3loNH92GqqyqhgGoiB1d8A1pwsBG2av9waR2ZDbf5aHJiFH062bQmlfH6WGZ8Y648MC04Ri2tfxDFwVERam1EnXVHEx14W)ltCV91JPw3gqq6rdjZz39B0zhF8jV6uH8ie7C9NnKWBqnjeuicVijMvpevYPBnnQYtsMy2bjCYJCQ8e3J1X(rX)cVvDoDR(4UpCL5VqwnID3nVRr)z)KOKAi3fiUSEVydrNNZdw1Z4GuW2FZiI1pye54WpNi55HEt)YucltChKF4xP18LpTgDeaheA07GBQm695RKySiX4ha9Nf6l(TP5(Hw2rRULkvdEI1gYVUt9l2sHhsFm361lOu7upN8SZWVLuLufTjUSqN)iRAZ1FJSYrNpTn0LSpT8JeDqhOF6r1BOx3iZ31iFoRlY4jGLFxTw8ARKoFEcMvkKH85gUNK3NPfpxZ9kzrx3QmtvHbbjcvmNjy3HRpkgtQzvVDkRG5e(qnQ13eSJc)2cEnrH9ySxRAzACpcRpBSbFJUFd2UQHNI5Tpp2ZXz4c3RLQ)i3iitKGkeh1ATntVooqlwZ0cifLNcnF9qRIsPqajqYpOwCS1F5YmR3OPoYuv3esW7pmSWeJWKIuZ93ylAE0uOiXJ04rmR4eNgLjmqutvd7gfZ2q4S8df)n2LIomp22ZxpERjLkwy0H)G6UAu497xdMl9ZWDOp4chsbA2ldjAEOvDjXfH1PysGknzhcZsRyimwFmJAj5uSeJ6Whcf6QO1ULpC3yaFpMV(6aqZeUzdd99(de8HH3Qp06GF74R9HLwhSKPUL3T7CF3gOGKsZ266IwN8x6pYCpzsY0kjSg8DP6HfovR4iRS8Fxikyk2WAJAqQa6jZ9e3p5hUe(fjmje)v4)aDgwvC2yxZCjhfHA9xe5oop7ko)u97Tv9s0LNicN3JEKrrl9tViaQMFzZ63HPfwwzXCclkIKRwdnRNwCG)mYOGLOhwVokJ6HoFTXuqPBMLKTORcEIJITcfpFYhjxwKEJwIzP8XxmUiVkP8E0BG1RuzF0pELY)c5IzvQ3AJRbRQ03koDEqt7)ldRtt64IBSwqsRgoN2s5iDCi51fz0(sWJSKP12hWKszroqlWFxGvqybKRmZD9UKiEwlvIJPKSkwISzv(5wjas7(onoruQMP459(KskwQbn2p9SJpb0Y66hIkZrUz3C97rXQsXc8GqTZNjRjEpdfx)pAsP3Li2BPsutDX8iQ08GfQg8L0C5V8)pfLG70)kUrZHzJA(zEYU3NXGr(AwC3g62(N8XHYr)BngDFKXedFxK5mh)VZ7QxQ5S9k3Y8mDnQomCJXc2LnD6Au)CETEYXExS2YuzVQ9NrDDorEZjpJDXkmfEqcncuFJX3ty83o4l)fhxc5pM7R2vWt8Ff0rKv54MyGidZeyyED3vOEzajCggyMJ7R2PKrETFSrTxJzhyIoFTMTqro3yc85yDXe0LJ37Cc2z3NmNODW9jJPOyrctvQkgZ3NTNu2UuRNbOb7tmfD7i6lD3MS(G(0t71fG)PNCPleRADnyV97di9PN6eKmuzASJIZR8)Ij(nFZ(m(9YmR4GtoE4qXzXxHC(HCUbCTyLM0i26xHnzJSTNGt9tJqlAyTjp4mCATgE)er3bSzmbwFsNSTftTt9lY2oyx89FcNSZoUdA49r98lcCtEGxVIOu2Cpy)aJWb8riynB(5Tr7AhfR5d2VhpkjV4KHTJOJNIKNBgF4pF)EeB4xCzGT5WHFtONXJxCYfUAwX1qhihCxp0iHh89n1qv0sWpB438nNmiWw6cnc3ce1VIr9jdJ6L7smQWdUxmQGF2WvcHQLkMFJxSDLQ2AI2(svF2zFQ2lMt0oyV8PsBhRj6tWEzZfUWPLdKf54NTs2oWdIjZSruzaYyTP0spxzkKPLPd(QTinL8uXelYku7ZSn)Iv1R18SXVeTohApn3tWa3Q1S13kca2vwDzxnUEireT5MT1jO1Q0AUzqxfrI3b2EABbJ3vkT4xnITlTxZ5z7t6nGrO3elM7ZKZ7otM)54Q1JFd2fgfxHbYA4Gkpl0n(EYjMKn8KT6pZWCoEsMDRHpGfX36QZBnzBnGK)DX2WMuwgTtiKIA4NySUDg6kDoWBBJ1TZTgOVlOBoOXpdInIoLh(bBiDQt9GzVfefHpbEw3BmC(mt36TTx5(Ma9OUXCP7mKCujG)oI2noGFRiK)wElwmIqsY4ZPqs8n)6RpddU7IPPzYWeP6iPkmhC5lnFzww(lU6fgR1ONooeRIrxQ(eSCy60l3lKdj8(KRmy)9e71wvDu86GYVQA0KETaD)kQqRvFVDkUhx1hqf39O9PtXD7YOLdpZ(llV9VXIlp4ylbqiWGDJLf9i7y47rgXuzkqeUshjh2lJrdrLusr1fTxcZes(HWQq3gz4hBz)hqDr)MU7IlpzW(Hlqup90EU4ynCWESyvZi3fg0B73rGTRP3vuZmmzQEncve26fiXQhsXibILqj1SyxxUbubnAz0Ixiti7vELyCFX5dPf7BKfUK2yGmk7HOhRStggTkCkR2isFogA4VLu4HxBeTdMYe2thwBDYsDEzH59mcSXkDdIQWLRNzmf4rBvxXlWWr8ht)Eitd6IgH6JX8bQbS6bmZtQuayKgU0NDlh(Cp6lsNiuah(3z2PLf0yVNrtW1XGcWW20UiqzRTph4c8sl4FGEEsB8VStPK2O(HKeT4OdjDa)VScQC4wP2K2RahdXa54qf8dr1sBo9Y8sxRazG2iir7TIZow5SrpqpO96BXP7FLqMvxebFMVE)m6qTiVUbkSeed3vrgpkCC6yABPwYChALq1xEcU940dDyGFzckpW(zG7fD9zYkHZfVAWEbIxxpKov3dsgFkpRtxA(Qo17tQZDo00ycAu(im7zap1j5yfXRRlcTnA9PSy5pe5IR66JdTudW(pezCLvSV7UN(0tAU4iKFWg68Yni1JpjqE6jj)jJwgD2R)2tF1jcoTx9QJh6F3dk0nFusCw6IQUpJ(Uvyd5FkNxuKNLwdWQ0Q5DoNNVvMZ7YECXm80nQI9mAIDtxAu7yZjWwikoACjMrHjj1JM3uLg39gHOEHr7CtvkV8JxbcOruEawvCzpsqo4c2)0V9gHOWizp2ZpyrtTRaAgKj4FieM5qzksK(FsKZPJXYUK4YsFpm7WSEIorHn5AxWJa)i5tOnVM5GCiYOIMf6Nr(x3wmbkejDgDQkZk3OjtQyGK50Jzd92wZioZs2moYoBaCTnO45Fsrkl)0WXmoklUjJpVJHlMsX7WwBYrcfWwoMZdOQQHjBnkCuATGbyReuGETivtrUn2kF4T)ArT8ld840Ru3QfVAkS5U6X8yXQM)96L8Qk04A3fvobhjgmqGYudS4(qsToZkD0vtLP6cXFxfuABqWOfii0w)Gp7B2xlSZyQoaYndxtz6R6lPKIWhf3hfN4tksyjUanvtz1Xm6uKuTW1r1T8swT4xWbHlRf8t3Dxcl7gaEtK5uF3p9ggoxA9Hmr4tRxAwh3kzjTdpf4JYF038hatXuz997OaAOOoxa8PHaFm)4eUXNAwWBrHLyZIHQCenrRvyjA20OZE13)DN)TsEICvVEVawBCQZ1vIDi(o(sdUpYwBSKmHrWHOtGsoZ58RbBvQfWMGxb7hFGLbiM8fN7d60RBImgoWPrvlMQ8z0iNvc(CvwezviTwelpCBws5JhZs)la6UHWRayECzd7T18pAafOBMdsMDFktWq5jQPOOdSd8Ko0C8QwMWm6kCmrfAeA)(LHeoI5uaqQHXr11zDSuxpjjEi6dycQHr7eGjSlMba0xx2etJZemlSaTy4MeABpvaTz2JYBeMqvpwvVtMK4iMwstX06JW8X8HDARbi82JrVIRYS9yx1fpXwdd82ss6MFT4(iUakcQi)m5De4ohZ9iAApIFeLjy4e5XHkE0bOpkJfKh4QzMbgPXFgRkkKOxVrXAH09FYCHuoLI1nfuh8CMyjksItc5uvyyGetBsg2KKdKKZX5kqbjMb3CwbKzwSMbi3ZB3aolbbZIymKofhxKPKK8x1JfPq63WhsNRrjY81x5pvGlnRZ9jb2nWT5KTUcIlGTfOKPpQC3eaSYQd3BkuDxa3SHqoisT(GOWyBBfWY2fy8xWkFsrgZAOZjHOnYrCnL3MA9SJDDZ4AmWLjXMuv3vgnZeDYff5KniLTN3mFmjR(uZzuOwPrzRsyerJQYI1d1PIQVYc2iSV4j88cMnqvNcu(W7kjhNGkyK8ry)yyF1oCkGaitgkLxq5U8eNMnLjNvQznL8qs)FfJc(1OlVC3gD5FHNVc6QLP)Q8WqcvWSO7nDAqVJDPG6MjhwlrvLb1cp3ZhR5MsvUGRSN52JDI0gDiKJe4Bx7su3WW0NV010WpedQkN9LxBVNe22pAOaOTd2aBmXudquFlu0Z05BBhhyzpsY6GK3EWaQCWMJMvOtyAB8aqASRMpISm(D)WeMc)e7dXUsWtiUiVUSiRYGba3KVKTljFdAwk1tXHq)LWCP2dOzaZKUB4L46Lx0b)bBuSRo758Y6HUoI2Z0G1g9QBYtYcbI82S(5miLKZ74HUEC8248pjVQHkEl4bVSmbsLsNiYT06VvRn5CdjrfyUDZr9gDp331o6k3v94s5WbHd9Ll6ds3l6LCh73BbpAxtwfCzUAmbxZDUN0Od159ex6Q5JBeHJ(7SxJxGslhhq7z(8qt6p2wThXu9vkOiZzqOYKuMwU9kuyaegnTl4qWlNdwnood2ZMaVVOPIXF3SGGjPg6)X45IJp68NEYwg6RU8uEWmX1m4TTRfRthI2a7yH5mwYy74bGl9kU9NPJnqNNdxYFDougGqNRml0ZF8ouuUbXkEawksFyY4fz)uHWMnvKPQfi7BUUD4CJqL6i6bOf)qlhMsa6nb)XXHAySMWmO2tH4J(Bm1artTvcY2qlXj(ctMipdMtep5x075WZaXLCXiSDCedqTcJGzGqEct)xZkK76eMpg0rdfIpx4(tQtJ)qlX8UfbWkHQ6ksDo2Re(UevqDbWRRZ)I8344EIeL7sL65MaMOqQ6KnWs2hPm090WnQoXXyHc7L5j1jfLRJ6CcVfQuQfF6jfDTPbwUgdAic3MNukjsNCcbX76HQs8vuRtbw9qNXg(P)(MJWrFX0Uh3159kC7KQOsRyXxD5Ic9vMRobRpMlNW5V7UMuwLuIIU5sN4MfDoaeLoC(6SNORFrGd6xwGZZV8xq3ntHT9Kjf5SGgGZpkn)(cSCUIIFWC0mUYWx5CPL7yCIwGXDzj54FwvQKEzQrMNXZkkQsmChvn9y5cARxHSOZE8i2QOJfoB1msSyu8Ent0smImfoKGGG6)SqMTnzIK6kdO)vnZNRycd7M0PD5BYimEmVGPOAGJaRLWWp9uRodAnWdnVKpolQ)ikn9jsl7)OW8KBz6KKgsSl6bCFf)8QffPzKLbb2GG2DLnvR4iuxWChEtEfZv(l04E2ZbbojqsjXObOrYm94kU(iGC9NJMdgGJSO38oarF1gJzfL54wbuyeul1nLisD7lnE189zmn)Jas3r95YFTgH1HFljJ0FsEB8dU570GTYDNlyRGlERUYkpHMMSip94GRedKiNXefUgSE87pW6HV)aRh9Eqjk)oS4YvzH55HTVl5fFD45W9XGU8cYGC9lOh39oakMX4LLXHiZa46PrZTuYHna1PUnEshMN50JLhmB(R6Eq4HIXd863HqE5O1xig04CgV9QLd)qRkP(MH9fsaZ13rheezmIgaV933tvqhxZ75(W4nlW(hnwSHpr5A3VHhN75jv7do3m9q3SzMW83sp)ZHjfi)P(zANa5YZLhVYwZh0GDW(DKKNCvC9eMfbAv(sY3b1hCacelid1wHAX(2tp55nINf8WMVm8QX6R1RcVyJO(IWRnmC)MRmi(9Bo8HCMYMV97dC97j2ABRkOcIukxLkm7nmFM7wwJX2XJK5apnTgJUZ319(yg5UMbM99(I9Llpize3(U3Hr8KaXarhJBPEz(u5)cVr2DYOzvmn(EUkCdd8hs9DyzCxsOjPk55HRTl38Z6J)7I2P9hqIDLd)cpE5ja)LdyFHHX2F((kVoOxD8WloDREE9NRdgLenXTEEuIoXzF0JNxwPBZU6KqlEItLYnB7xjyfjHTFHG9Ae7l4XWGIL0dfuDEYTKw1MD3oPJYfN6RzR1IFVsJroQCLIiu694PN640zWQC248A4(R69WU21hF05)P5UQBsRF9E6NN3tD)YDZNdhVA3YBOoFr4(Y(6P7T8o)UjMAPBWJ88QyZL9DVnIwn7PaWR9xri8QofVqjmTKtI0NOQtap5C)s8nJoSUaDvUHGlcN(CNN3UrnpiKrhcZcrZ2tRiMbZHG)EWuJxrhmaQoUmnzk34TTwImK5F5hY4sGnkWfqqH)jYty8D7RzEQWkM3(oUQITVKXmuKhIsBpcjvx0xe4z8eAy0VkxlYUwk4IwYkWdWXUF)UkaT4mEyvs8LhF0XNipM74gStLOvdiS9dZA1NjiHlGyaig(Jjw)SNf4l0vXKQ3kW(4SH9hBY921gxV)JO1BuUNWlAfbPUwsuEHM6kSI(V8dVDylRAvJ3cWo3PwQrT2Os3vvsdM5(Tr)c3TQKmjswawryYqPBm(C)HXEnmXZM79bN5DPIz4m8or4Wt253TIC4xfXw2sWG1ETUB8yZw9O()R9U(ATTHbI)zjVuShJSL(4iTWG9WESmOV2M0T0IH0LcjJrHs(SxlPtsNKU7K0SBN3O0xkX2Y6pNV7(DNUFkZsnXz4Dbl0uNB4fRNDKgnJrAZuLU5R5HkDLts1MtUeDU5eWZA8QHmGPsWIcKYSE3vHhLlpv2jaPulYmHqF4B7zNHj55eTSOsGDqCGTt3GLe2HrBo1LmZH0((iVWHKwcix4cJlXIpkVYZNy301D3)D(z2dC6rtOY5pXHj1rqDn7fmMXOnkoXMbxi222ZR6cAy8UMZvDANfzuN1gms4lfZsADdujEZwIUgLOrqkIpbL8CmNWkM194MX(jx8a)uMEuPtxKL8ZeY6l1GBQ6Pq2(ALsBf0IKI1ERw6erhageOGmLsNVT7cdMKh39lDsRvAOmuY7MoZ278RBGTN1Lpy0)eeuQh3yrxAU)pDCvZ62q(EgYL9VvmH4w9uyVUPMBC31N92I0KnTA72hfxT3BE1nFVvQ0FNFC1xmdHFSZgGfOeDuc5g4tDrv43EmNRXG7ZeYh1Ap)h)1KceXSDil8PtppN3zLx9EnZinCZfN6z6GEaJluN2HhpfQEVEPEDRSUB43Jnb1aYC9OS9PNOQPAiuTxUprIgKvTyLbsfrPp(dx449EieSMv6aXAC1JVd1oGpQUskpqY71qwGAPRa5JMg86s0gaI5srfI5SkcGU4wcQH5Ad491s71PkTcKLIptnPAdZu8MVQVZW8vaD7W0mImQDlNFefVtOPEyVRVKZdWKz399iy7XoCne(sitKr)SZNmhhfuQTOy4Oo7QltUSXHMOBGmKcdJHnOFXlJ)sW1r8eI17OgsLywU0WeZsEeKk4jDTLP3Kc(Z1o2R5ZWUe7Vt)9dkB2CcZYYJ0ptAnbgozCoJ7UuSAx0t695n(Mp5(1)C98huCJc79CT6ECBVneqo1KWH9igyU38ZDR7Gyaym6GC44OMOVUTB7wLjREXWdB0199TEJwCMwgIh9fiYIQDn0H2gO2Jl6iKDuyCGXXLuIXtp8CjDXjdUoQE24aRiBltBkm9xP1OIJY3GFPniDQ23af5djXfaw2zgWwCNc)IER0cr11gmfnYiT8maqiH97CrWZYzFZZijvQ4(FgE8mNks2a5hEXGq97dgM8ldAr2Zzjbz)AFhJas8YK1EBM9LAMn5RyzxbkRrR2fZjM3Ji6SrNxx7O(4khbCyt5EMTkVpHb3Sr3EHCILslwcrIo9aqZz5TkG0eyLhAGwEdi9)uaPZQ84VcOmYE1lm4SCZkLfMbPwiloTfYpFPydPE2)tX6n6EnwXxgdc7NeWPRo0)3vp)d]] )