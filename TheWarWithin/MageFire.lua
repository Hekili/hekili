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
    accumulative_shielding   = { 62093, 382800, 1 }, -- Your barrier's cooldown recharges 30% faster while the shield persists.
    alter_time               = { 62115, 342245, 1 }, -- Alters the fabric of time, returning you to your current location and health when cast a second time, or after 10 sec. Effect negated by long distance or death.
    arcane_warding           = { 62114, 383092, 2 }, -- Reduces magic damage taken by 3%.
    blast_wave               = { 62103, 157981, 1 }, -- Causes an explosion around yourself, dealing 1,107 Fire damage to all enemies within 8 yds, knocking them back, and reducing movement speed by 70% for 6 sec.
    cryofreeze               = { 62107, 382292, 2 }, -- While inside Ice Block, you heal for 40% of your maximum health over the duration.
    displacement             = { 62095, 389713, 1 }, -- Teleports you back to where you last Blinked and heals you for 11,036 health. Only usable within 8 sec of Blinking.
    diverted_energy          = { 62101, 382270, 2 }, -- Your Barriers heal you for 10% of the damage absorbed.
    dragons_breath           = { 62091, 31661 , 1 }, -- Enemies in a cone in front of you take 1,364 Fire damage and are disoriented for 4 sec. Damage will cancel the effect. Always deals a critical strike and contributes to Hot Streak.
    energized_barriers       = { 62100, 386828, 1 }, -- When your barrier receives melee attacks, you have a 10% chance to be granted 1 Fire Blast charge. Casting your barrier removes all snare effects.
    flow_of_time             = { 62096, 382268, 2 }, -- The cooldowns of Blink and Shimmer are reduced by 2 sec.
    freezing_cold            = { 62087, 386763, 1 }, -- Enemies hit by Cone of Cold are frozen in place for 5 sec instead of snared. When your roots expire or are dispelled, your target is snared by 80%, decaying over 3 sec.
    frigid_winds             = { 62128, 235224, 2 }, -- All of your snare effects reduce the target's movement speed by an additional 10%.
    greater_invisibility     = { 93524, 110959, 1 }, -- Makes you invisible and untargetable for 20 sec, removing all threat. Any action taken cancels this effect. You take 60% reduced damage while invisible and for 3 sec after reappearing.
    ice_block                = { 62122, 45438 , 1 }, -- Encases you in a block of ice, protecting you from all attacks and damage for 10 sec, but during that time you cannot attack, move, or cast spells. While inside Ice Block, you heal for 40% of your maximum health over the duration. Causes Hypothermia, preventing you from recasting Ice Block for 30 sec.
    ice_cold                 = { 62085, 414659, 1 }, -- Ice Block now reduces all damage taken by 70% for 6 sec but no longer grants Immunity, prevents movement, attacks, or casting spells. Does not incur the Global Cooldown.
    ice_floes                = { 62105, 108839, 1 }, -- Makes your next Mage spell with a cast time shorter than 10 sec castable while moving. Unaffected by the global cooldown and castable while casting.
    ice_nova                 = { 62126, 157997, 1 }, -- Causes a whirl of icy wind around the enemy, dealing 2,811 Frost damage to the target and reduced damage to all other enemies within 8 yds, and freezing them in place for 2 sec.
    ice_ward                 = { 62086, 205036, 1 }, -- Frost Nova now has 2 charges.
    improved_frost_nova      = { 62108, 343183, 1 }, -- Frost Nova duration is increased by 2 sec.
    incantation_of_swiftness = { 62112, 382293, 2 }, -- Invisibility increases your movement speed by 40% for 6 sec.
    incanters_flow           = { 62118, 1463  , 1 }, -- Magical energy flows through you while in combat, building up to 10% increased damage and then diminishing down to 2% increased damage, cycling every 10 sec.
    mass_barrier             = { 62092, 414660, 1 }, -- Cast Blazing Barrier on yourself and 4 nearby allies.
    mass_invisibility        = { 62092, 414664, 1 }, -- You and your allies within 40 yards instantly become invisible for 12 sec. Taking any action will cancel the effect. Does not affect allies in combat.
    mass_polymorph           = { 62106, 383121, 1 }, -- Transforms all enemies within 10 yards into sheep, wandering around incapacitated for 1 min. While affected, the victims cannot take actions but will regenerate health very quickly. Damage will cancel the effect. Only works on Beasts, Humanoids and Critters.
    mass_slow                = { 62109, 391102, 1 }, -- Slow applies to all enemies within 5 yds of your target.
    master_of_time           = { 62102, 342249, 1 }, -- Reduces the cooldown of Alter Time by 10 sec. Alter Time resets the cooldown of Blink and Shimmer when you return to your original location.
    mirror_image             = { 62124, 55342 , 1 }, -- Creates 3 copies of you nearby for 40 sec, which cast spells and attack your enemies. While your images are active damage taken is reduced by 20%. Taking direct damage will cause one of your images to dissipate.
    overflowing_energy       = { 62120, 390218, 1 }, -- Your spell critical strike damage is increased by 10%. When your direct damage spells fail to critically strike a target, your spell critical strike chance is increased by 2%, up to 10% for 8 sec. When your spells critically strike Overflowing Energy is reset.
    quick_witted             = { 62104, 382297, 1 }, -- Successfully interrupting an enemy with Counterspell reduces its cooldown by 4 sec.
    reabsorption             = { 62125, 382820, 1 }, -- You are healed for 5% of your maximum health whenever a Mirror Image dissipates due to direct damage.
    reduplication            = { 62125, 382569, 1 }, -- Mirror Image's cooldown is reduced by 10 sec whenever a Mirror Image dissipates due to direct damage.
    remove_curse             = { 62116, 475   , 1 }, -- Removes all Curses from a friendly target.
    rigid_ice                = { 62110, 382481, 1 }, -- Frost Nova can withstand 80% more damage before breaking.
    ring_of_frost            = { 62088, 113724, 1 }, -- Summons a Ring of Frost for 10 sec at the target location. Enemies entering the ring are incapacitated for 10 sec. Limit 10 targets. When the incapacitate expires, enemies are slowed by 65% for 4 sec.
    shifting_power           = { 62113, 382440, 1 }, -- Draw power from the Night Fae, dealing 4,967 Nature damage over 3.5 sec to enemies within 18 yds. While channeling, your Mage ability cooldowns are reduced by 12 sec over 3.5 sec.
    shimmer                  = { 62105, 212653, 1 }, -- Teleports you 20 yds forward, unless something is in the way. Unaffected by the global cooldown and castable while casting. Gain a shield that absorbs 3% of your maximum health for 15 sec after you Shimmer.
    slow                     = { 62097, 31589 , 1 }, -- Reduces the target's movement speed by 50% for 15 sec.
    spellsteal               = { 62084, 30449 , 1 }, -- Steals a beneficial magic effect from the target. This effect lasts a maximum of 2 min.
    tempest_barrier          = { 62111, 382289, 2 }, -- Gain a shield that absorbs 3% of your maximum health for 15 sec after you Blink.
    temporal_velocity        = { 62099, 382826, 2 }, -- Increases your movement speed by 5% for 3 sec after casting Blink and 20% for 6 sec after returning from Alter Time.
    temporal_warp            = { 62094, 386539, 1 }, -- While you have Temporal Displacement or other similar effects, you may use Time Warp to grant yourself 30% Haste for 40 sec.
    time_anomaly             = { 62094, 383243, 1 }, -- At any moment, you have a chance to gain Combustion for 5 sec, 1 Fire Blast charge, or Time Warp for 6 sec.
    time_manipulation        = { 62129, 387807, 1 }, -- Casting Fire Blast reduces the cooldown of your loss of control abilities by 2 sec.
    tome_of_antonidas        = { 62098, 382490, 1 }, -- Increases Haste by 2%.
    tome_of_rhonin           = { 62127, 382493, 1 }, -- Increases Critical Strike chance by 2%.
    volatile_detonation      = { 62089, 389627, 1 }, -- Greatly increases the effect of Blast Wave's knockback. Blast Wave's cooldown is reduced by 5 sec.
    winters_protection       = { 62123, 382424, 2 }, -- The cooldown of Ice Block is reduced by 30 sec.

    -- Fire
    alexstraszas_fury        = { 62220, 235870, 1 }, -- Phoenix Flames and Dragon's Breath always critically strikes and Dragon's Breath deals 50% increased critical strike damage contributes to Hot Streak.
    blazing_barrier          = { 62119, 235313, 1 }, -- Shields you in flame, absorbing 11,888 damage for 1 min. Melee attacks against you cause the attacker to take 293 Fire damage.
    call_of_the_sun_king     = { 62210, 343222, 1 }, -- Phoenix Flames deals 15% increased damage and gains 1 additional charge.
    combustion               = { 62207, 190319, 1 }, -- Engulfs you in flames for 10 sec, increasing your spells' critical strike chance by 100% . Castable while casting other spells.
    conflagration            = { 62196, 205023, 1 }, -- Fireball and Pyroblast apply Conflagration to the target, dealing an additional 197 Fire damage over 8 sec. Enemies affected by either Conflagration or Ignite have a 15% chance to flare up and deal 158 Fire damage to nearby enemies.
    controlled_destruction   = { 62204, 383669, 2 }, -- Pyroblast's damage is increased by 5% when the target is above 70% health or below 30% health.
    convection               = { 62188, 416715, 1 }, -- Each time Living Bomb explodes it has a 30% chance to reduce its cooldown by 2.0 sec.
    critical_mass            = { 62219, 117216, 2 }, -- Your spells have a 15% increased chance to deal a critical strike. You gain 10% more of the Critical Strike stat from all sources.
    deep_impact              = { 62186, 416719, 1 }, -- Meteor's damage is increased by 20% but is now split evenly between all enemies hit. Additionally, its cooldown is reduced by 15 sec.
    feel_the_burn            = { 62195, 383391, 1 }, -- Fire Blast and Phoenix Flames increase your mastery by 2% for 5 sec. This effect stacks up to 3 times.
    fervent_flickering       = { 62218, 387044, 1 }, -- Ignite's damage has a 5% chance to reduce the cooldown of Fire Blast by 1 sec.
    fevered_incantation      = { 62209, 383810, 1 }, -- Each consecutive critical strike you deal increases critical strike damage you deal by 2%, up to 8% for 6 sec.
    fiery_rush               = { 62203, 383634, 1 }, -- While Combustion is active, your Fire Blast and Phoenix Flames recharge 50% faster.
    fire_blast               = { 62214, 108853, 1 }, -- Blasts the enemy for 2,392 Fire damage. Fire: Castable while casting other spells. Always deals a critical strike.
    firefall                 = { 62197, 384033, 1 }, -- Damaging an enemy with $s1 Fireballs or Pyroblasts causes your next Fireball or Pyroblast to call down a Meteor on your target$?a134735[ at $s2% effectiveness][].
    firemind                 = { 62208, 383499, 1 }, -- Consuming Hot Streak grants you 1% increased Intellect for 12 sec. This effect stacks up to 3 times.
    firestarter              = { 62083, 205026, 1 }, -- Your Fireball and Pyroblast spells always deal a critical strike when the target is above 90% health.
    flame_accelerant         = { 62200, 203275, 2 }, -- If you have not cast Fireball for 8 sec, your next Fireball will deal 70% increased damage with a 40% reduced cast time.
    flame_on                 = { 62190, 205029, 2 }, -- Reduces the cooldown of Fire Blast by 2 sec and increases the maximum number of charges by 1.
    flame_patch              = { 62193, 205037, 1 }, -- Flamestrike leaves behind a patch of flames that burns enemies within it for 753 Fire damage over 8 sec.
    from_the_ashes           = { 62220, 342344, 1 }, -- Increases Mastery by 2% for each charge of Phoenix Flames on cooldown and your direct-damage critical strikes reduce its cooldown by 1 sec.
    fuel_the_fire            = { 62191, 416094, 1 }, -- Flamestrike has a chance equal to 100% of your spell critical strike chance to build up to a Hot Streak.
    hyperthermia             = { 93682, 383860, 1 }, -- While Combustion is not active, consuming Hot Streak has a low chance to cause all Pyroblasts and Flamestrikes to have no cast time and be guaranteed critical strikes for 6 sec.
    improved_combustion      = { 62201, 383967, 1 }, -- Combustion grants mastery equal to 75% of your Critical Strike stat and lasts 2 sec longer.
    improved_scorch          = { 62211, 383604, 1 }, -- Casting Scorch on targets below 30% health increase the target's damage taken from you by 4% for 12 sec, stacking up to 3 times. Additionally, Scorch critical strikes increase your movement speed by 30% for 3 sec.
    incendiary_eruptions     = { 62189, 383665, 1 }, -- Enemies damaged by Flame Patch have a 5% chance to erupt into a Living Bomb.
    inflame                  = { 93680, 417467, 1 }, -- Hot Streak increases the amount of Ignite damage from Pyroblast or Flamestrike by an additional 10%.
    intensifying_flame       = { 62206, 416714, 1 }, -- While Ignite is on 3 or fewer enemies it flares up dealing an additional 15% of its damage to affected targets.
    kindling                 = { 62198, 155148, 1 }, -- Your Fireball, Pyroblast, Fire Blast, Scorch and Phoenix Flames critical strikes reduce the remaining cooldown on Combustion by 1.0 sec.
    living_bomb              = { 62194, 44457 , 1 }, -- The target becomes a Living Bomb, taking 1,329 Fire damage over 3.5 sec, and then exploding to deal an additional 732 Fire damage to the target and reduced damage to all other enemies within 10 yds. Other enemies hit by this explosion also become a Living Bomb, but this effect cannot spread further.
    master_of_flame          = { 93681, 384174, 1 }, -- Ignite deals 15% more damage while Combustion is not active. Fire Blast spreads Ignite to 2 additional nearby targets during Combustion.
    meteor                   = { 62187, 153561, 1 }, -- Calls down a meteor which lands at the target location after 3 sec, dealing 6,700 Fire damage to all enemies hit reduced beyond 8 targets, and burns the ground, dealing 1,546 Fire damage over 8.5 sec to all enemies in the area.
    phoenix_flames           = { 62217, 257541, 1 }, -- Hurls a Phoenix that deals 1,744 Fire damage to the target and reduced damage to other nearby enemies. Always deals a critical strike.
    phoenix_reborn           = { 62199, 383476, 1 }, -- Targets affected by your Ignite have a chance to erupt in flame, taking 242 additional Fire damage and reducing the remaining cooldown of Phoenix Flames by 10 sec.
    pyroblast                = { 62215, 11366 , 1 }, -- Hurls an immense fiery boulder that causes 3,846 Fire damage.
    pyromaniac               = { 93680, 205020, 1 }, -- Casting Pyroblast or Flamestrike while Hot Streak is active has an 8% chance to instantly reactivate Hot Streak.
    pyrotechnics             = { 62216, 157642, 1 }, -- Each time your Fireball fails to critically strike a target, it gains a stacking 10% increased critical strike chance. Effect ends when Fireball critically strikes.
    scorch                   = { 62213, 2948  , 1 }, -- Scorches an enemy for 497 Fire damage. Castable while moving.
    searing_touch            = { 62212, 269644, 1 }, -- Scorch deals 175% increased damage and is a guaranteed Critical Strike when the target is below 30% health.
    sun_kings_blessing       = { 62205, 383886, 1 }, -- After consuming 8 Hot Streaks, your next non-instant Pyroblast or Flamestrike cast within 30 sec grants you Combustion for 6 sec and deals 275% additional damage.
    surging_blaze            = { 62192, 343230, 1 }, -- Flamestrike and Pyroblast cast times are reduced by 0.5 sec and damage dealt increased by 10%.
    tempered_flames          = { 62201, 383659, 1 }, -- Pyroblast has a 15% reduced cast time and a 10% increased critical strike chance. The duration of Combustion is reduced by 50%.
    unleashed_inferno        = { 62205, 416506, 1 }, -- While Combustion is active your Fireball, Pyroblast, Fire Blast, Scorch, and Phoenix Flames deal 50% increased damage and reduce the cooldown of Combustion by 1.25 sec.
    wildfire                 = { 62202, 383489, 2 }, -- Your critical strike damage is increased by 3%. When you activate Combustion, you gain 2% additional critical strike damage, and up to 4 nearby allies gain 1% critical strike for 10 sec.
} )


-- PvP Talents
spec:RegisterPvpTalents( {
    ethereal_blink             = 5602, -- (410939) Blink and Shimmer apply Slow at 100% effectiveness to all enemies you Blink through. For each enemy you Blink through, the cooldown of Blink and Shimmer are reduced by 1 sec, up to 5 sec.
    flamecannon                = 647 , -- (203284) Every 2 sec in combat with no enemy players or creatures closer than 15 yds, your maximum health increases by 2%, damage done increases by 3%, and range of your Fire spells increase by 3 yards. This effect stacks up to 5 times and lasts for 3 sec.
    glass_cannon               = 5495, -- (390428) Increases damage of Fireball, Scorch, and Ignite by 100% but decreases your maximum health by 20%.
    greater_pyroblast          = 648 , -- (203286) Hurls an immense fiery boulder that deals up to 35% of the target's total health in Fire damage.
    ice_wall                   = 5489, -- (352278) Conjures an Ice Wall 30 yards long that obstructs line of sight. The wall has 40% of your maximum health and lasts up to 15 sec.
    improved_mass_invisibility = 5621, -- (415945) The cooldown of Mass Invisibility is reduced by 4 min and can affect allies in combat.
    master_shepherd            = 5588, -- (410248) While an enemy player is affected by your Polymorph or Mass Polymorph, your movement speed is increased by 25% and your Versatility is increased by 6%. Additionally, Polymorph and Mass Polymorph no longer heal enemies.
    ring_of_fire               = 5389, -- (353082) Summons a Ring of Fire for 8 sec at the target location. Enemies entering the ring burn for 24% of their total health over 6 sec.
    world_in_flames            = 644 , -- (203280) Empower Flamestrike, dealing up to 200% more damage based on enemies' distance to the center of Flamestrike.
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
        max_stack = 15
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
    -- https://wowhead.com/beta/spell=203277
    flame_accelerant = {
        id = 203277,
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
        duration = 6,
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

spec:RegisterStateTable( "improved_scorch", setmetatable( {}, {
    __index = setfenv( function( t, k )
        if k == "active" then return talent.improved_scorch.enabled and target.health.pct < 30
        elseif k == "remains" then
            if not talent.improved_scorch.enabled or target.health.pct < 30 then return 0 end
            return target.time_to_die
        end
    end, state )
} ) )


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


-- APL Variables from August 2023.

-- # defining a group of trinkets as Steroids
-- actions.precombat+=/variable,name=steroid_trinket_equipped,op=set,value=equipped.gladiators_badge|equipped.irideus_fragment|equipped.erupting_spear_fragment|equipped.spoils_of_neltharus|equipped.tome_of_unstable_power|equipped.timebreaching_talon|equipped.horn_of_valor|equipped.mirror_of_fractured_tomorrows|equipped.ashes_of_the_embersoul|equipped.balefire_branch|equipped.time_theifs_gambit|equipped.sea_star|equipped.nymues_unraveling_spindle



-- # APL Variable Option: If set to a non-zero value, the Combustion action and cooldowns that are constrained to only be used when Combustion is up will not be used during the simulation.
-- actions.precombat+=/variable,name=disable_combustion,op=reset
spec:RegisterVariable( "disable_combustion", function ()
    return action.combustion.disabled -- ???
end )

-- # APL Variable Option: This variable specifies whether Combustion should be used during Firestarter.
-- actions.precombat+=/variable,name=firestarter_combustion,default=-1,value=talent.sun_kings_blessing,if=variable.firestarter_combustion<0
spec:RegisterVariable( "firestarter_combustion", function ()
    return talent.sun_kings_blessing.enabled
end )

-- # APL Variable Option: This variable specifies the number of targets at which Hot Streak Flamestrikes outside of Combustion should be used.
-- actions.precombat+=/variable,name=hot_streak_flamestrike,if=variable.hot_streak_flamestrike=0,value=4*talent.flame_patch+999*!talent.flame_patch
spec:RegisterVariable( "hot_streak_flamestrike", function ()
    if talent.flame_patch.enabled then return 4 end
    return 999
end )

-- # APL Variable Option: This variable specifies the number of targets at which Hard Cast Flamestrikes outside of Combustion should be used as filler.
-- actions.precombat+=/variable,name=hard_cast_flamestrike,if=variable.hard_cast_flamestrike=0,value=999
spec:RegisterVariable( "hard_cast_flamestrike", function ()
    return 999
end )

-- # APL Variable Option: This variable specifies the number of targets at which Hot Streak Flamestrikes are used during Combustion.
-- actions.precombat+=/variable,name=combustion_flamestrike,if=variable.combustion_flamestrike=0,value=4*talent.flame_patch+999*!talent.flame_patch
spec:RegisterVariable( "combustion_flamestrike", function ()
    if talent.flame_patch.enabled then return 4 end
    return 999
end )

-- # APL Variable Option: This variable specifies the number of targets at which Flamestrikes should be used to consume Fury of the Sun King.  Restricting this variable to be true only if Fuel the Fire is talented.
-- actions.precombat+=/variable,name=skb_flamestrike,if=variable.skb_flamestrike=0,value=3*talent.fuel_the_fire+999*!talent.fuel_the_fire
spec:RegisterVariable( "skb_flamestrike", function ()
    return 3 * talent.fuel_the_fire.rank + ( not talent.fuel_the_fire.enabled and 999 or 0 )
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
-- actions.precombat+=/variable,name=combustion_shifting_power,if=variable.combustion_shifting_power=0,value=999
spec:RegisterVariable( "combustion_shifting_power", function ()
    return 999
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

-- # The duration of a Sun King's Blessing Combustion.
-- actions.precombat+=/variable,name=skb_duration,value=dbc.effect.1016075.base_value
spec:RegisterVariable( "skb_duration", function ()
    return 6
end )

-- # Whether a usable item used to buff Combustion is equipped.
-- actions.precombat+=/variable,name=combustion_on_use,value=equipped.gladiators_badge|equipped.moonlit_prism|equipped.irideus_fragment|equipped.spoils_of_neltharus|equipped.timebreaching_talon|equipped.horn_of_valor

spec:RegisterVariable( "combustion_on_use", function ()
    return equipped.gladiators_badge or equipped.moonlit_prism or equipped.irideus_fragment or equipped.spoils_of_neltharus or equipped.timebreaching_talon or equipped.horn_of_valor
end )

-- # How long before Combustion should trinkets that trigger a shared category cooldown on other trinkets not be used?
-- actions.precombat+=/variable,name=on_use_cutoff,value=20,if=variable.combustion_on_use
spec:RegisterVariable( "on_use_cutoff", function ()
    if variable.combustion_on_use then return 20 end
    return 0
end )

-- # Variable that estimates whether Shifting Power will be used before the next Combustion.
-- actions+=/variable,name=shifting_power_before_combustion,value=variable.time_to_combustion>cooldown.shifting_power.remains
spec:RegisterVariable( "shifting_power_before_combustion", function ()
    return variable.time_to_combustion > cooldown.shifting_power.remains
end )

-- actions+=/variable,name=item_cutoff_active,value=(variable.time_to_combustion<variable.on_use_cutoff|buff.combustion.remains>variable.skb_duration&!cooldown.item_cd_1141.remains)&((trinket.1.has_cooldown&trinket.1.cooldown.remains<variable.on_use_cutoff)+(trinket.2.has_cooldown&trinket.2.cooldown.remains<variable.on_use_cutoff)>1)
spec:RegisterVariable( "item_cutoff_active", function ()
    return ( variable.time_to_combustion < variable.on_use_cutoff or buff.combustion.remains > variable.skb_duration and cooldown.item_cd_1141.remains == 0 ) and ( ( trinket.t1.has_use_buff and trinket.t1.cooldown.remains < variable.on_use_cutoff ) and ( trinket.t2.has_use_buff and trinket.t2.cooldown.remains < variable.on_use_cutoff ) )
end )

--[[ These are still handled in the APL because the value changes before/after calling the combustion_phase list. 
-- # Pool as many Fire Blasts as possible for Combustion.
-- actions+=/variable,use_off_gcd=1,use_while_casting=1,name=fire_blast_pooling,value=buff.combustion.down&action.fire_blast.charges_fractional+(variable.time_to_combustion+action.shifting_power.full_reduction*variable.shifting_power_before_combustion)%cooldown.fire_blast.duration-1<cooldown.fire_blast.max_charges+variable.overpool_fire_blasts%cooldown.fire_blast.duration-(buff.combustion.duration%cooldown.fire_blast.duration)%%1&variable.time_to_combustion<fight_remains

-- # Adjust the variable that controls Fire Blast usage to save Fire Blasts while Searing Touch is active with Sun King's Blessing.
-- actions+=/variable,use_off_gcd=1,use_while_casting=1,name=fire_blast_pooling,value=searing_touch.active&action.fire_blast.full_recharge_time>3*gcd.max,if=!variable.fire_blast_pooling&talent.sun_kings_blessing
spec:RegisterVariable( "fire_blast_pooling", function ()
    local val = buff.combustion.down and action.fire_blast.charges_fractional + ( variable.time_to_combustion + action.shifting_power.full_reduction * safenum( variable.shifting_power_before_combustion ) ) / cooldown.fire_blast.duration - 1 < cooldown.fire_blast.max_charges + safenum( variable.overpool_fire_blasts ) / cooldown.fire_blast.duration - ( buff.combustion.duration % cooldown.fire_blast.duration ) % 1 and variable.time_to_combustion < fight_remains

    if not val and talent.sun_kings_blessing.enabled then
        return searing_touch.active and action.fire_blast.full_recharge_time > 3 * gcd.max
    end

    return val
end ) ]]

-- # Variable that controls Phoenix Flames usage to ensure its charges are pooled for Combustion when needed. Only use Phoenix Flames outside of Combustion when full charges can be obtained during the next Combustion.
-- actions+=/variable,name=phoenix_pooling,if=active_enemies<variable.combustion_flamestrike,value=(variable.time_to_combustion+buff.combustion.duration-5<action.phoenix_flames.full_recharge_time+cooldown.phoenix_flames.duration-action.shifting_power.full_reduction*variable.shifting_power_before_combustion&variable.time_to_combustion<fight_remains|talent.sun_kings_blessing)&!talent.alexstraszas_fury

-- # When using Flamestrike in Combustion, save as many charges as possible for Combustion without capping.
-- actions+=/variable,name=phoenix_pooling,if=active_enemies>=variable.combustion_flamestrike,value=(variable.time_to_combustion<action.phoenix_flames.full_recharge_time-action.shifting_power.full_reduction*variable.shifting_power_before_combustion&variable.time_to_combustion<fight_remains|talent.sun_kings_blessing)&!talent.alexstraszas_fury

spec:RegisterVariable( "phoenix_pooling", function ()
        if active_enemies < variable.combustion_flamestrike then
        return ( variable.time_to_combustion + buff.combustion.duration - 5 < action.phoenix_flames.full_recharge_time + cooldown.phoenix_flames.duration - action.shifting_power.full_reduction * safenum( variable.shifting_power_before_combustion ) and variable.time_to_combustion < fight_remains or talent.sun_kings_blessing.enabled ) and not talent.alexstraszas_fury.enabled
    end

    return ( variable.time_to_combustion < action.phoenix_flames.full_recharge_time - action.shifting_power.full_reduction * safenum( variable.shifting_power_before_combustion ) and variable.time_to_combustion < fight_remains or talent.sun_kings_blessing.enabled ) and not talent.alexstraszas_fury.enabled
end )

-- # Helper variable that contains the actual estimated time that the next Combustion will be ready.
-- actions.combustion_timing+=/variable,use_off_gcd=1,use_while_casting=1,name=combustion_ready_time,value=cooldown.combustion.remains*expected_kindling_reduction

spec:RegisterVariable( "combustion_ready_time", function ()
    -- return cooldown.combustion.remains * expected_kindling_reduction
    return cooldown.combustion.remains_expected
end )

-- # The cast time of the spell that will be precast into Combustion.
-- actions.combustion_timing+=/variable,use_off_gcd=1,use_while_casting=1,name=combustion_precast_time,value=action.fireball.cast_time*(active_enemies<variable.combustion_flamestrike)+action.flamestrike.cast_time*(active_enemies>=variable.combustion_flamestrike)-variable.combustion_cast_remains

spec:RegisterVariable( "combustion_precast_time", function ()
    return action.fireball.cast_time * safenum( active_enemies < variable.combustion_flamestrike ) + action.flamestrike.cast_time * safenum( active_enemies >= variable.combustion_flamestrike ) - variable.combustion_cast_remains
end )


-- # If Combustion is disabled, schedule the first Combustion far after the fight ends.
-- actions.precombat+=/variable,name=time_to_combustion,value=fight_remains+100,if=variable.disable_combustion
-- spec:RegisterVariable( "time_to_combustion", function ()
--    if action.combustion.disabled then return fight_remains + 100 end
-- end )

-- actions.combustion_timing+=/variable,use_off_gcd=1,use_while_casting=1,name=time_to_combustion,value=variable.combustion_ready_time

-- # Delay Combustion for after Firestarter unless variable.firestarter_combustion is set.
-- actions.combustion_timing+=/variable,use_off_gcd=1,use_while_casting=1,name=time_to_combustion,op=max,value=firestarter.remains,if=talent.firestarter&!variable.firestarter_combustion

-- # Delay Combustion until SKB is ready during Firestarter
-- actions.combustion_timing+=/variable,use_off_gcd=1,use_while_casting=1,name=time_to_combustion,op=max,value=(buff.sun_kings_blessing.max_stack-buff.sun_kings_blessing.stack)*(3*gcd.max),if=talent.sun_kings_blessing&firestarter.active&buff.fury_of_the_sun_king.down

-- # Delay Combustion for Gladiators Badge, unless it would be delayed longer than 20 seconds.
-- actions.combustion_timing+=/variable,use_off_gcd=1,use_while_casting=1,name=time_to_combustion,op=max,value=cooldown.gladiators_badge_345228.remains,if=equipped.gladiators_badge&cooldown.gladiators_badge_345228.remains-20<variable.time_to_combustion

-- # Delay Combustion until Combustion expires if it's up.
-- actions.combustion_timing+=/variable,use_off_gcd=1,use_while_casting=1,name=time_to_combustion,op=max,value=buff.combustion.remains

-- # Raid Events: Delay Combustion for add spawns of 3 or more adds that will last longer than 15 seconds. These values aren't necessarily optimal in all cases.
-- actions.combustion_timing+=/variable,use_off_gcd=1,use_while_casting=1,name=time_to_combustion,op=max,value=raid_event.adds.in,if=raid_event.adds.exists&raid_event.adds.count>=3&raid_event.adds.duration>15

-- # Raid Events: Always use Combustion with vulnerability raid events, override any delays listed above to make sure it gets used here.
-- actions.combustion_timing+=/variable,use_off_gcd=1,use_while_casting=1,name=time_to_combustion,value=raid_event.vulnerable.in*!raid_event.vulnerable.up,if=raid_event.vulnerable.exists&variable.combustion_ready_time<raid_event.vulnerable.in

-- # Use the next Combustion on cooldown if it would not be expected to delay the scheduled one or the scheduled one would happen less than 20 seconds before the fight ends.
-- actions.combustion_timing+=/variable,use_off_gcd=1,use_while_casting=1,name=time_to_combustion,value=variable.combustion_ready_time,if=variable.combustion_ready_time+cooldown.combustion.duration*(1-(0.4+0.2*talent.firestarter)*talent.kindling)<=variable.time_to_combustion|variable.time_to_combustion>fight_remains-20

spec:RegisterVariable( "time_to_combustion", function ()
    if action.combustion.disabled then return fight_remains + 100 end

    local crt = variable.combustion_ready_time
    local val = crt

    if talent.firestarter.enabled and not variable.firestarter_combustion then
        val = max( val, firestarter.remains )
    end

    if talent.sun_kings_blessing.enabled and firestarter.active and buff.fury_of_the_sun_king.down then
        val = max( val, ( buff.sun_kings_blessing.max_stack - buff.sun_kings_blessing.stack ) * ( 3 * gcd.max ) )
    end

    if equipped.gladiators_badge and cooldown.gladiators_badge.remains - 20 < val then
        val = max( val, cooldown.gladiators_badge.remains )
    end    

    if buff.combustion.up then
        val = max( val, buff.combustion.remains )
    end
    
    -- Raid Events are fake.
    -- if raid_event.adds.exists and raid_event.adds.count >= 3 and raid_event.adds.duration > 15 then
    --     val = max( val, raid_event.adds.in )
    -- end
    --
    -- if raid_event.vulnerable.exists and variable.combustion_ready_time < raid_event.vulnerable.in then
    --     val = raid_event.vulnerable.in * not raid_event.vulnerable.up
    -- end

    if crt + cooldown.combustion.duration * ( 1 - ( 0.4 + 0.2 * safenum( talent.firestarter.enabled ) ) * safenum( talent.kindling.enabled ) ) <= val or boss and val > fight_remains - 20 then
        return crt
    end

    return val
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

            if talent.rune_of_power.enabled then applyBuff( "rune_of_power" ) end
            if talent.wildfire.enabled or azerite.wildfire.enabled then applyBuff( "wildfire" ) end
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
        cast = function() 
            local flame_accelerant_reduction = 1 - (talent.flame_accelerant.rank * 0.2)
            return 2.25 * ( buff.flame_accelerant.up and flame_accelerant_reduction or 1 ) * haste 
        end,
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
            removeBuff( "flame_accelerant" )
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
                class.abilities.meteor.impact()
                removeBuff( "firefall_ready" )
            end

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
                buff.flame_accelerant.expires = query_time + 8 + 3600
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
        cast = function () return ( buff.hot_streak.up or buff.firestorm.up or buff.hyperthermia.up ) and 0 or ( ( 4 - talent.surging_blaze.rank - ( talent.surging_blaze.enabled and 0.5 or 0 ) ) * haste ) end,
        cooldown = 0,
        gcd = "spell",
        school = "fire",

        spend = 0.025,
        spendType = "mana",

        startsCombat = true,

        handler = function ()
            if hardcast or cast_time > 0 then
                if buff.sun_kings_blessing_ready.up then
                    applyBuff( "combustion", 6 )
                    if Hekili.ActiveDebug then Hekili:Debug( "Applied Combustion." ) end
                    buff.sun_kings_blessing_ready.expires = query_time + 0.03
                    applyBuff( "sun_kings_blessing_ready_expiration_delay" )
                    state:QueueAuraExpiration( "sun_kings_blessing_ready_expiration_delay", ExpireSKB, buff.sun_kings_blessing_ready_expiration_delay.expires )
                end
            else
                if buff.expanded_potential.up then removeBuff( "expanded_potential" )
                else
                    if buff.hot_streak.up then
                        removeBuff( "hot_streak" )
                        if talent.firemind.enabled then applyBuff( "firemind" ) end
                    end
                    if talent.sun_kings_blessing.enabled then
                        addStack( "sun_kings_blessing" )
                        if buff.sun_kings_blessing.stack == 8 then
                            removeBuff( "sun_kings_blessing" )
                            applyBuff( "sun_kings_blessing_ready" )
                        end
                    end
                end
            end
            if buff.hyperthermia.up then applyBuff( "hot_streak" ) end
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

    -- Talent: Calls down a meteor which lands at the target location after 3 sec, dealing 2,657 Fire damage, split evenly between all targets within 8 yards, and burns the ground, dealing 675 Fire damage over 8.5 sec to all enemies in the area.
    meteor = {
        id = 153561,
        cast = 0,
        cooldown = 45,
        gcd = "spell",
        school = "fire",

        spend = 0.01,
        spendType = "mana",

        talent = "meteor",
        startsCombat = false,

        flightTime = 1,

        impact = function ()
            applyDebuff( "target", "meteor_burn" )
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

            if talent.feel_the_burn.enabled then
                addStack( "feel_the_burn" )
            end

            if talent.from_the_ashes.enabled then
                applyBuff( "from_the_ashes", nil, ( talent.call_of_the_sun_king.enabled and 3 or 2 ) - cooldown.phoenix_flames.charges - 1 )
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
        cast = function () return ( buff.hot_streak.up or buff.firestorm.up or buff.hyperthermia.up ) and 0 or ( ( 4.5 - ( talent.surging_blaze.enabled and 0.5 or 0 ) ) * ( talent.tempered_flames.enabled and 0.7 or 1 ) * haste ) end,
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
            if hardcast or cast_time > 0 then
                if buff.sun_kings_blessing_ready.up then
                    applyBuff( "combustion", 6 )
                    buff.sun_kings_blessing_ready.expires = query_time + 0.03
                    applyBuff( "sun_kings_blessing_ready_expiration_delay" )
                    state:QueueAuraExpiration( "sun_kings_blessing_ready_expiration_delay", ExpireSKB, buff.sun_kings_blessing_ready_expiration_delay.expires )
                end
            else
                if buff.hot_streak.up then
                    if buff.expanded_potential.up then removeBuff( "expanded_potential" )
                    else
                        removeBuff( "hot_streak" )
                        if talent.firemind.enabled then applyBuff( "firemind" ) end
                        if talent.sun_kings_blessing.enabled then
                            addStack( "sun_kings_blessing" )
                            if buff.sun_kings_blessing.stack == 8 then
                                removeBuff( "sun_kings_blessing" )
                                applyBuff( "sun_kings_blessing_ready" )
                            end
                        end
                    end
                end

            end
            if buff.hyperthermia.up then applyBuff( "hot_streak" ) end
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
                if set_bonus.tier31_2pc > 0 then addStack( "searing_rage" ) end
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

        flightTime = 0.03,

        impact = function ()
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


spec:RegisterPack( "Fire", 20240508, [[Hekili:T3ZAZnYTr(Brxktl6vlxsQDxBFrsP87SoXoUSCI)MOgneuCYoCgM5HKLlv83(1DJhdEpd1dF2xDvCTzxcmnaA0OFJgxm7IF6IZxM0WU47NpD(RN(MPFYKzZpE6Sp9IZBUBl7IZ3MK((KRH)srYg4p)6Sk6hVlVmzj(X1LTvPWpTUPzB9)9RE11znRBVAsA5MxvNTPnpPjRSiTkzvd(VtF1fNFvBwEZ7kU4k)J8NCX5jTnRlRU48ZZ28faKZwUKX7oRo9IZXU)YPV5Lt)K)7DxIDz3LTBrinz33U7B5TE8lNnhA97YkkR2DjmWE6ZSxo91qF2D5pYAGv1Ultk2Dzz(YDx2uLv8EwJSVaWMb)3UlhT7Y5VTdS(g7JHP1lN)XeCp)UIuSDaGL7UC20jZM8Mx9Xg9CkVNEaynmFUojRqR7FmFr134dDBg1TFiPjDTCG92XPC49pRHv)s2vTRwnPg6ZYj4KEfog)eBZ2YQK8Dx(ZjvB1(yb(h(y50L6poyhT7YSI082LzfxV7Ynjf3T7YBsQYsUkh7x96SvWyaFqvjSVSTkRSkR5oowkROHvvGJxA5s9j7XVC(u(IVCz2Q70)oAG)VExrDtsrZl)hf5WV9ZRzfyFVbMd)xWyYAAG)Mj8(yXU)MYBG1)5PLvi66maXDxv5v5j1n7UCDs1Yu6VvNYkGfrPgmETeb(JSBYQdcdCDLUML((Dx(xlH)95nvSK3p5IZZZQBQXdrWPLRARXtklslbsWYBlWF)7PJNjPydWHUs()pmnae5Yl(8lAGZo694Q8YYLlw1wDNvVog7v3VCEkG4yWgcEye2Z7gEyJxdCSQAw17b8gcJxRpsRGdm0OznqVrVtjfPS6gG4zrAsEUvpFBWP0HagljNv0mPrq8T4wK2t05DxE)97USQTGb77xZc1PX0XvlI6U5wt2gg9f4C5JTMlYoDDEYYSKMYQ6fxLSezcYwTIL2SGZl0PzauFIfO49mRkBjRTEXQQKR3aRSUHWPfagFQxyuVTmlVEr5QffS8gGUSTUdm(AeG0SPEbvtjS4H(2IhzGMwST8wwLgYXF7iaN5hGa28kGOoDnqSSa29OTFnuTDJiOM7fu3uMTeqelbAVf1RtGJcxZ20bm)nJGZMgNdoqosbUuUbgwTvO5pJF(RdUWAwNXwvV46KnxL1yUSmBcbZB8cMRa6z8iZIRQGdfR1oIz1acc7tgCqKuVMrBWnRzlyBWZMLT5Ah283ocqBYBoa3KvvvwHFbq7L20wXwUa24lHF9wnkR4Ddx0Gy5vjT5nkgwAdfkXUkBlhuF1VWsBjo)SByvidFafc)5Au2BAdYfpdf7DtswocHjDZI0YwuWq9wwEUITNNtSDhRnh6FchJAwAzbm6)enSO8m(a2w3c8NG5ZvmKDDBnofZ2SHHNUzydLGSKTT5GuPBb1BSLkcqUexgjWhN1GsU2GY5kxTc)7C25WAoPkpJvDe2tCutr1nQHUIZ5ACWH)zE21RBWr8wGRc8dzaiwwsYrXX42mCouGcrQy1aohfycySLlZW1joH6wChwpghRQY2Rxx22iq0ScbUCYUl)m13LF3r85En0vufOK8BtUtmR4iKKoiSexCI)1kCgJtNRbjLG89AEBFHsKccdAbaSawEhFjHJK9wDNaahnrg1NebOdhItfaP0KuHloKGaLQJYkiDk2wMJWBbnFxuX2a6wbZGtGPhoyKWSCygpzzBvcFEpEaIo5cL1(OZ601zcrn2uUivdz8cXaQjZv(XoI6LsDhKOPUjw0X)m6SwMMMg7U8L7U8ndq2MnVn5Cb2tUd2CZxuwTSaf6p4jZjNQHTCaZILS8K7OD3(ws9de(AKV4CNWEuirjALKYauoLvxr8xlR4IWn0yz4ltnD92wXqDlxW5dcugZ5eSU0OrbpxvhhQkARLFY4a4u7)PnB7w4afkFaoPadBD21z58rusly36IJF7hp)1ZMOMlaU(1tXJgsTscGDIPvvv2MfS08ST17hLYN8aWoY5PXG6rpndPfFp7wLrGOzHahMBzjBX5rEwbYSgycZqgpGaP0mKTl(7clr((720Y0((BxNH2eClNXQGCuFT1IQZa)eRQjbzNJsPi(Y1)LbkSoM(8Ejo03pbD6gS0EhDtdRnupgzes)kFATgsBP98i4XDOc0gjPYs1TflqJCiC1yon2HUOSbHj1oz4t1oB1J6r5TFxV(IOWziTZkWtg1Gzfvj3WYrRbQ3MvaAnSxSb(u5mim4cBpWsGVpqNHN4waI83ixaxd)EZI07sXjJC(oKoh22b00oqgdHEaLswxVydWShTZQoVeoFG41fRbUlxCoOHfa7vlUoDjQdTH1H(brh(c(gTnja)mDYB3D5hT7sSHnj)IfVT3rGuO(jXAtQYxNQEahRCgxRxshVV5l(sVg3OoxYaROQG)OwsWHg8Bon5sHuBU4QamLBHGl5cP4PiIY6iDhguKEXRz2K1j1AQ7y2Ms0NoL(8PphtK5rMiZFitefVMqBa(SNStfY72UgjPtQRZ2KLl0bTBltF)c(TnlaR3qQuUU1kjREbJp7ovczsstUcymcmqau1M26S09IbGspoFach4Oc3F3kKmNSijbi(5BCiX(lBjlUGf6rD2)q)2xIMUSI8r8)cSWHbhFadQQZwYSn2bmQ6Fa7av3MvZos5JYSFLPgtpWIBtPUftLKpmrlL(Ag2d6u4N3wvWnBsz3dD(nbHDY1mufJIpSHFqgifG)w5nOIf0x3zHIPPBWm(Ni7rbJiR5OKnjOvM3KKtQXuk6DhzlcaFldYLRcRvL24MNkcbaoTsteOyHD3fOs4WsoLpmabul3HaslP5272XyAlRcTrrAsU6edO0vzJ6l54ZZBHE83GjZhcd1NJwMc)9J6g9TLWVCvUyjwt(QNpRfF)F7Z13uQDTXvsYiodxprxidHCwCdHBg(HkPc7059SIvKVWxagjKMSe5YKGor(0qTdC7xi6dYG6aUQKTznUDvrcHD0NTjW)rlUreCou3JRsfkatdfOvtWjSvpw3gBnWbmRlML7FaQf(HESM9fyuiOHySPOCJTeKpHTYSM8jGnNAjj1YsHBxUIbybKes)4Quc6)UTUrNCnatcUVuqx)GuHWAur4alS0QwUpx)pTjfnTBa7xVjZ0KALPC2gPBq94ZuW44BDRu5B)cItRnlR2qvomW1rwfOR7cPD)Q8eUBNVkPPjFpwXdtoLn4XPsi9XVn59W(Cf6w(su)SN2zIf0XjsinMbuztvBknmlZUbmYCXvOlqFINrHggCQzRhTYViTf84nLGMWDxDZt9KYDaWPtihIbS1QQfgU2W51bRPSvmhdrd2ZfVMoPOg)GqeNh26cpuo8DZy8me2ozx98qAPb0i1nlkkVjXI)ef02VUIKZ)9qZcr1vzxFnk0)BQYQr5KVlnl1Y)QDCYVM60ImEF0DNAmVj1hxBhoY9YQ)Kb6FmgpccIFG8p78qAzAeYatu33WK(Y(lZQtZ2c2oMGXJayrVHuPcx9yaZpcvsHlWxF6Ikjuxcyf)y1LAafxMimnqUk9wWXzH3UlCwUCNWxFwKubgXX62AoisNLM33323lKBFticVRkZBMOThC2GM8D6AoKD(3i3jTvB))dIBnjG)FhKnF1iusdXSipokcVA6NP5BkctSG9lBbBkY4M2n3wZPNVTQoV8QHzIU1r4YN8DUN)9LXwm9rYbkcu2km98HS7)CXZaY93i0jxgkIpT16RCliSNPfAFj0TeB8dWSeTsvMttFnz(7NJj5tn)37SPKIeGMFbqGc2t76lCfQuYjGCzmcZjPRtGT2AUR4Z4H39f9Jp74QqzAf6xu(P7vT55G9tlBt5D8J0DGLrxbT)GfaZaSG9uVsBNsBE2T18sW0l(zvpDdTovSKOjzN9e3Gg5vMVORZ1dBW8zRJQ9EbWy0cYpGMY9zB0jwHDY1LTWNlcDA3yTaxvy6tr9M8QkAaoINXVbPfTv8FpCd2u(rbF(XFihr6xHlDUgAdG3iVfaiAQJLaeFcndX8EJN9BcuM(xVoHhHUJTn8Wlo0Zzw1Xz)QK7U9WDeBFoTW3woDIUMbGgZSPY201t08JJ7jAXjq(PGoPjhhXF9F2sUxfi1vLlcPBjsllAQkZRn4fPChi5xReCYyYPs4E)Z5Z7Dx(t4exKqgIzFexOnPhADCRZ2iTWHcu3UIGCaL(yWGS23(4yjOoatGNTvaNLLlQPKY0iJqezyIDx0D8UPHhsgQ8(zEg5GbeZnTUTUSbTJeZaumP4Amz(0hFy98sqVNeA32Mu)Ny2RJf9j5EQIs)gqhXc2MmwTLRKWuOLMalixWG2q)EfMZxo70hYsY1FnlHqaTB1Ause1nutKkDRZ4AkMr0uMp4rilo9NtAqekWCDylRJR88o(VkYAycl(1DtLJSpk6g7n8q71O7HsqhARLVW1c39JDG9lnuwyzfDGjevGTNemMFFzl)m)x3H3DMujvQzdpIov5ISZEP4Rnc4X3qZwEkKbtL7maqSLdpGbi5yTrQTHiJBHPIkchCUrwlw1OPJdR3IkXsEELp24oopRkOp0jCkeHumPudG1vaA4Ep6yicudi66br7O2U4W)5AtXg3qr1knz7w1(Ts(GITQqsa8Vlky8Z8NlyRS7YFWmPG1j57qk(10KFItYdXNuVtcPKAtw677usLw(H9lqVO4oRzS24gOIj4vkyjY)QQSrfyZJjRFv8Hjzc6tqkPyrTGGHmPlTyLFGWGAm2g55S0gZp1j1wJyDIqbKioBf5WPA2oxZTAMv1UL2iQ3cAgeQxEY0CREG7fw57TvpmY(AR2IMbsw91FkOy1jR8WXZKf)8mvgiz1Hi5SIXbULWGuKjIQ81vLOGFksRIGdYnq8CE4MR11HkuUdqKAH82nSoxKDDbEqiKeDnLQndMNATzhumnTNeQdRZAt5nbh1WK8Tmmxu5gD9PAt4mADa5zzK0yCa5JOXDtrqMLTHUBBghadFZuIRMJsvfD9CScVL4hBezhPSTTYllKdBehlJ8KK9Xfr1nkuYLxV4F3UuDvtcB(zCqDvY1e2Tc4wx7JqncstAWDFtw8QBT4kODFungN9OuUOZyvvuB9KztoPAHSp8uUWUNussbCHqTc1)k(vcJuoHuzr07aMmHjcsz6dundDJs6mt49xTW0JyUzf78PHSXU7oM1eoRUxF3wwvZAKfXIBRa4CBvYwJCnfeXDZKzAwoqMkr)6CV)6Xg)Qql7yU(IB4N6U84Fg55iRCnuWAXllq9DfqhrAW1y2ExTpQq8w1WhcynHt15TRlzfz)IGHGDcgadWxaRtUk1CXxCRWjskuac38pDsVJqvArZNQBXgO0Mz7wkBHAM035xczd6saNQkARHvmR64PlMVnvkzqSryoTNKva)n(18yKY25uXmxi31WRqVw3FgrTNdrE2Q3nifZeCv4IPIMzYgmJDYem9d1iQhrtuIBXe36ZskbLXDi5Mbn0jCTBhkspUdcI2HaoLi63W(LTzCMd8R)qhFHtLkf3NN9mhQOs(qMrws3CsH7)OHJ8jBUXtgCpG11JdtFIKjzqxAzAI2vj5(tc7NYzQJ1pnEs46(8(KMctuq6RxOXO50ygV1V51NO((dTDENPTP(AJ5)YLOlafreQoHIF1eHH7a(hfRwFeJJIO0)az38JyKCDKM9IQhpTTxJgWSLvwzjXjqB75OeXBE6Ux1qcHpff1ttEM0Vsk5fKt0Z3qzLdAqiyHkQCzLS3FhTie97kLBQYXqCsNISv0TVtrdWhU97p8GNqgOZYTe4RCdFyUV8JX9rr7)MTjehO0PGRwiRAtwIMJGJ6c5O8EErq)l)r0QY8gxWZ(roJ6hIdJblhiYax3BYd8dz4UDaCeeE3PY57nTKVneotL71uQxCh9cwb3PFdNqlKE)H1x68TKtNnDIRRlH3rP36Aax2vKom0s6Wy7mr10q7WTrSe6UrgkIo5YwcAvOs9rUm(Hp0V0k5O7gyd)Li8NIXGR6Wyrgqf8QAuH(1RaWwBtQEV1UYpYBd2sWgdB0BIXoN66yJCF4zLV(fEpzvJ6MdWzSjyMvRUVach2N00wXV981mHvl2JeCcdNFukriU4buywePQo6LmZfruDQfN(NtNgdqhf(e8l65SpAtkTvyBsNl57EsIfsJYWE3o8HexCsiOhorTqlYr2uGf81IYwZOGOn)kM27HJ9zQgmVWTc0PDwWM5jQf(zlHK68TmMvari(L)a3Qxra70IscDv5WJt8K)hVWVhHlSgTshb39r4O8zLF1qOFpiQBpmuC1YCCvNojupmY0gnUpWF(lyb5P(xtQPYeKD5YX3gQj6NRATjTaT71JHrp121fLxTLbPprgcAzIRto7)mVIF8laZJBbdTGiEwghZ(ovyuFNqnWUIDfxpdYNv(I5DnVgLyKlCDOQqALYpa0NQNU(AYVK8(5vrOKqHMiQB8(zs6kjx7NoEkjg8iBMj1HI0Fx4P78e4xj8eOxnROO(JGe9V8x3wDh33Y12HbNvy6zQGE9RHIRvxuzTzxPW1Hfo0NmvLlmo8H49qLuvo2NZ3sO6apwcE7bL4n0UA4BQrW1AGdF0nikjnLLZQsWKNMCHPx3Ve8(CeLwIUthoKo0MU80M5zjov0Aw(2(sZcpP4bDKvvcE4wPYlRfiqr6O0YIAwfCYZw)9dgImL9H6AFKs9iidPTMWQ2nCcc90b)uTC3ZIlAt0R1WGgUa0xHC3TECZCD3nQukQRFnz0iRaRnu7e1HRC2Qgx6lsR9epuLufOuquseH0fRTW3fE8iHjgAotNLxZIQMKohb9ij4i4hybWdvQOfzibIgOuFqXR6Q65NyFHks5(uT9G9kV1DUjLwbb9PpzH1P4moRIDU7qESRYlh3Ow7cV01TSpPNvT)Gxg9t0Wq8HZxeOL9yzvY1aBSfykP0yRxdx49N1XXPtSkNTPD8H48mjQNJWBbpcBkuVe0djMh4JEdyriWzMjcC0)uuvytSRjOD7P9ZoCu8B7BypGz5GogJxJrUcZHqz(JRYo5zVzyjwRknx1tAeD1h6ONWY4gdZShHblYTnpb6)p64JEwXHitjoAUzF2(XuR)0tXyD7IxeovJJv2p3DyEbCSu0UhxE4aVa2W0tT5lEYdR3yhFNKoBYnIudF3pKtC6jF3dnrIQUcNVO)kA4GokKe37bHwl9OUS31IVRaraW)aZUQ9ZK(EnZEOMm7lPT8o5Jyh7amIvUvPIbI5Tp4no5trVl9dSdQJIYYNoQ9OI6Zlo2G8iS)kFsO(CYlHbeETWxrH(c8wyCJUALhAF5x8ea5GDiWTA4G(J4qFXEZyuJhq59zyJAcxxCCcEPQ6pyMboV1v8Cc0bRQNtGSw)yBTf86SCNJFwXunAWjpigKdcw(hgvKYyPC59okLYRnc5MlPAj7UuQxYrshG3tWk7C7GOMaJNwqcdYkZFS8h4MvAC9s(NwGeSDmRzTUp(t4TJNkELwz3Nh3k(WBO3T(fDRudocsB1TFZ4(XXdAAOcgJwc8A63u8XkiJT8i(LS4APbbgXhJSdGFFnKp3ay)ulL6jdnUndL7OIskKtsdKmZXZROhNmWxBEjiDfs5KGr7VPbAj2UHo(QU15krJ21NNZTC4Cqx75lBogGdzhGhsNp88Rm2KlSME7)oPGX5j9ZD17wByTchQNg7JJQI0wIiCfuB494OyUW6b(4NR9fE6PAeZ77IItG79kpcuvrVsKGDVtEZt55OJDcCt8JsprPjSteXLWjQFICD0d3zqyHwSGQ3s4T(HcKJY35K4hz5ds6IPFfVfq43YNsiU6WoFUlELy4fmQJOBbj6xoSomIoGA20MXdYlM9rfEHV4TRZBkMc1AU2(b6lc7skdnN3KuKmzlEiiAFxG9RBY4T60eQAQfo1M4(bu5pCK(VPwRyrAS7Y3z)ADRrX9PvzyjxL8bEd)sOUQtXKjdg5496sFHVi26W1jGtMm450xqSmdsS7J(JZl5tt47UQhVvnGRU6plUuQQyjlgwUYAkTIoA4Uv9a)A4AiKPpB5IYZEiMNDMvId2N9xpQyDDQKtGUR5TUPTv8eatJJVBavhUwqrDR3aWVpbl04IKg17AYz7PhmNswOFD50SfnOYCN5IjFygOHb3ZmfmskUJI12rUwLTZSubQFsP3ApCNClEsMYd3b5Rh2o1DKPru2WPxlMA(jxeKo5PL1RatdNHcCQMyMZFAapgS548BtQWRxBT4T8jdFhyAego(Hbya9Hy(E9FAHFyPSERMaIw3KqZFUbz1t29T)D6XBaFk3(cohfS5p0h50hYrDEBtsQb95Wz)Yy6DIZZCv8Aj9Km3mEoCSMBEFQC6MBC4o7n2awupYnRz6kq7VKQVhq1UiN7bYE6YZj07hUZJJlCAEyZw3c(Uhi)GXfpmO3b3pXcUHkK0sO2xHM2zIBpaXkV0YbziLG6EhOGH0268ZdFik3Y4(9UMNofF4bkHFzo1d2rhYnx2BT((u)TPSL((7pOpe)937lZ34feGrhC4qqP3FFVOKXAdJBe7plCD8(d(Gdf2UjjgFXSPJhl3l()XCHXC(rCDImEBWtygL9x3dxERkW2e90RNQFW7R(n6okXQyLodwyUf)gmyI9qJsLQfZcVLrvha)P)gUkoE6VLd2SE4aY1c2mNmgPzYKz(VR55PxCyKthVqaHO15YpQlgY9uB1g)bXQxKVC2j9uvlFHAK8vrlJd8dDWqIwI(zJ)Gpy2OiiOtm4yi3J)JXMXREo3mId8GBgr)SX71Er3zNJFgvqXRfiQst1hUx2GeyEQz7L1eupW5dBMPjNvvJs2VjPTqVNkdLclm1lO755PUh0GPxR3peqalfFsOMIsh44SzRbiOZOhi8TCUPNnrpU(0g2V(zEUha(pY5UxIeNKdC)OtEUXeZS1)qaa9edXc2(YzKFRa7ZnrDOb4r4DjbGdWX7PBMBRO)VvdWJh1yRV9t9mF(ZdRQ(ensfcU970UJFI8CH1)qhzxQMcIHDC)0tYPX5boK)0TX9CFO5zCa29TVJimqW(XYqiHpaXyIcT7BV4C8nj(IV)ThJPku5QSUh006jkn)EXPVYUmKU7B)ty8k2NQy5UV1hGL6aFegc(tdvDlpQC7P4vLKQHPNgSeME)9blFPAnfO0LQ1dpLTuTwrT1TkzPATAuUs1(9OLQuT(5VmLQ1bRsuQ1ed)SUYtQwJblnPWwjSxc)3N9d)9Dx(Ve7h7U8FqblcOmXOfrLRbK2lbJCuXl)vyFcdthSDWlTYibC3LFrsNrr9XPslsj2hEBbbAx4aWsoKDQPIEVsninMv1FM39LgjDy2gXlj5e(YRFsVLz14)qZgmKOdyPXA6fdXRXf3OAGEOVxLXlAYmE(hgV6aT0TsBp4zUE8S0M9IqhD6lNjo2i4A4Q7(rzRo1iIRUq7KPpgKaTNu0IeZcoe8CMyhv8xep55gz5O5vcp4tJOnICW4m)PSObIWFxoDQaB(6psQDbLJeBtAsx)Ip9t)0p6a3F)5h3rjy7xyNQj7dQtpTugoA0x6NyIf91dfseWxp)4MW0vALEEFfR(bIe0u2kewWFx(9jTKjkk4vuK)67YV9JQhjyvbTDc(A58JeysBe8LnNwiyqGktynvEe0QYJaEsiONhbdEpX6gazSzy1MAx4y1UqRWEbKxO5(GElp77eFgP01Ul)QUuFBWhNhmMYoN4mqv2n(KEWfuTpfqQ0RpdUCWC1dxa5L3gdf4r6)dEXs5hOss5RNUpI8hWgOtcSqfhONsgoMogpephZETNBI4zu6(SWDgnnPjD7mV0eMf86cDogyqDQzyeuRFiRr9kZOAVA6KJ3NnRHFqumr7siZU0GYPmHlVqkBtup6sI5hSe3GpPOdE96lUdDlw3LQ3Yrmxfw8(JuNUMTSL)2pXOBLgodnkvdjyEiRv52wXZro2(Sl5g4cbPLr4lEXSPtninD11wTUi6nZNF(Wfk9hWzh9AHUyUU8Q0jSv4tf)KztN92PF8BaBSQzl4VP9Yj2plvKN)c6t0ryAgOlweJeK72IYeSHoh1O95jqWEy37MsquAwZITvz1BgM9Wpzw7QWv)vKdoMR778uuY7oc15Na(rlvogMG9jHCwvAsd76sujdPzKCUpL8nJoqyiq4VmuuDP(RtUanpFAi(O8E73rgTIhOzbzM27ybcTdcdUrhe8j2y0Hkfp6Sktlfq8BR24bnb9)0xqZ1qpBg(HR(JJH)EyPiMiGvIeA)S(S4Ypmvzbn6JR)eQGaLb1afdd4KENuMfXzlbFRYTZEufypv)TFMGfXdIlha(heC(5KkXDbuve)UIjk4QOeo9YHjsEUTfvsHF1a)jrq9KqPUusWJxyayfr2PHCo6iXzjv5zSQ)SuVzsIkvrCYOUt1TlkRMZPY6AfvuoxHLSvIZiogAkkbKjKqjusCYYLz4chNqDlUdRhJJvfENg4fAyejWkeihqF(pt9D0J3vMMSWK8BtUR2WwYoiSuZ(aHmMk21GzH876ITISI76PiRPXLK6Av4U3becKiimCPiPLidQRr)ApPD7inNORcR6Od1d1mNy8(7dN6uNqGKEC5ZB1JGV(SyBjjqbMcuV5)tvxptrI7jticL(a6GxD2LlNIUVsNAlfWGRLNSdtsD9Y34f0embe1DaQphylSSaFXk6bON01OZNYVi)XYYHZ67JJnvJWblwMNCIxo7B1EgsFX87V3Kcic4gpYBcYCyqMO3FVkTqSAzXXV9JN)6zY8R9SxpDC4v)1vzBwWsZZ2w3)E0NShliId43ZUvjBDNi39zjB5HoOazajl(BKQ0iRKCkugu4N(E0vZAFVWAir2)tBS7mEI8BlwswhXQ4L3qKZlXRP(Vegde1H6QtIABma)a7FsIQNnl84GOiGjmt5uD)WomaSCyF)eOhZNNbkKgJV)ENuok6slcvK)Gn87PzyWWw0lr)NggOOEwWojs1Ta4RVrUgUgVUMlsVlLIkcyKfO0msBtsFPtb(QR)0fqdjJBK3JLGdCgbqo2gK)SUEXMemMxh12DfEoD2r15LnNIiNfRHrfxPA32OZaBFF7hjVcqHP6yGg5vWFul3EW7(kxB0d7uhnue38Ywd3y7)lB8ERq0(z7BsWzZN(emCZ9pCUxCHGdxeUT53TDnsLKuZFKtXUzQxVBkNhH1vsAcyt1c40hSs20wNL2l58B4uKRq6ozmxf4eK67LT1cdspQtFm63(sPrf7U8FjE4(c4frqjp6Xr72SA2rQYXF2VYuJPhy5(iP1ZDcteJAXbkU10OlafVnb4jRC6fXaDjI0RkgoeOtvsv9LhuQTMJs2qx(tUT7Kr5uV1mECL)Lb5elH2ZsDUZtfrreNwPjcuSWoGcuFfyjNYhgGYOLBXHuZEU(3DCk2YQqL3KMiOilbbMLnQVmYJPT2vmEBj8lxj9JE9DfPYzT47)BFU(MsTRo3ssgPf0tIZUu3S0(i8FUURfpI7yrK7wXd)ov8bhACBk4hqbSHYHgllv(LaRf8n(Ddc)L7OJojOp(j3psjVZwGoTjYogm7sRABW10I)tBsrt7gqH6BY46Zh0psJCZLzKvAm0thtldxPOHtn(9tJPtlpkxaxwWe)M8EMQpmoV3M8ESWhJ(bRKlz9PEeYW0AOnLGZsSISc69XYZFogkGwMmlDrcQH6D1npldsAsvTql7g(Xr0VmRyk1Gd2JfVMx6Y8a76(4HqhM4vZPksAW3xEtIGHU0nHFdD1JGZC87EK(4Sc)OffW3GduGBRuat3gIn0r5zCsVwyQxOi58n(gM0JjFP2vPHo)VHeuY9TC72J6kti6MqHS(RljhH3Hf09SLjEW391zKsIeowl8ELEi3YWXB(AFbpaBCe5bb7gAnWqUDi0U4vL5AL4WZgWKuQTq8nP3yWjYxyq)dd6sNC63gC3iPJPnUlBJDocItGNkuj31fQvte0kn0pAS6ZbEZfd5Hj1dhffNA7jbT80Im(tyOXlZ3rjFe8T3582dyOS7k7c(Ng2uouw2s3AxdzGFJRTrMDPfre)hVsfKNQY(9YnE7)JF9dneJzv0UCIskLJ79Ab907V31Rupob5DNk1aQJtwd8Xe1)NTKR(pj6x(fs7hadHAQkZRTsebHbZKLFjyL2ZUgAsEKYSIuUZOqwgXiZNNZu(ksyEot5wgvp7yPRUm1y0DKgf0cp9vKBcZ4xjWGN3rYOiZIXJo8a)feX7VpEDT8So1dLSk4T3rTX5AhYRRIMTR5uJgmpfIG8N5LavrPfLiG0YiWJSj28NFGHEDzinzXoW(LgkYGwEiYuhEfYDaKF9rCetI20r8DiFHK2x6Ro6a3iigc5Z5vAxQQuK(Da1UgGDY0jV5(7DfYC2PZ5Yn)s3ug3z3rlbx5(TSkx8ko6l9ZaJqWTnE8DB6QbV9VVY9EgwcVQDsqVBt4vOwEuKigpUVEP8rZ8vPQIxx8KV6TiwHhEi6dD8TiHO7xSHEotONRvH4e4zRokTeNRoVa9MMSDRApsX(wv)0emQXRFvbfBd3mgm8Xbpha8RHHQkXnYL76j()KMS033Pus)4uNBxAFHI2Vd4n4tZRwXFR63eiF59C(uTx7g5Ax7e8ShHT9EFrEIRNGUBTSMOWAH)SZ8q0prkAq7125(7piOGUrkhsA)Y6elIV7rWH5CE(927GteuVzDAf3ccD35c47t)S1hl6T9J)Y93t6Sm7nHvdySP0dbsxzpDJ5998pylTqlIULHMUWQ7f2P80LjENGvm3zN4kQ)UYQQzv4PJEIwFiaG7r041BpXSvbr3yykOeitMbzjlxwsXuIjpcKvCtjwayrTFQOeWcNzyPJvfEjUGWT5j3jYxC5zhrwNLUUSSMz5iu4J2qXxQMNEwwzAAGjoF2SqozwGZfo)CU(HzfRALUcJWGM)SGL9JAGKmUq1zRB3SrtJC3MmLreAWiMwY8b7qFja293hOGBmEKv(J17G1oK8YA4qrLJa6zQ7E(5EYM39ecnL8OW0wuZJG0wdvrgiqYCsB49ecOkuW6FjgTgEUEDnqLVFWWk9K3RVfxbg59ZE(9wP9ZE(1(ZmN9eirtrQaCLjFPCkLAP1l(3TlVwMuDr1yZbcip4e6WlEfWEFq9RJcHhIoEKgkuAm45Mhh65U3xyzDUpY8hg)cj3y7R8I6PbN4yREg9dC1fW3H3jrx8961l1QZhUvQ5yNX)Ax8bBn(Mpn6mX6mfVMmGwNT42kyIDBvYwAoGp2itMPz99lOFzUZVCS2Va2Zg25QNUptScwlYjV(Ucy(GKjRrrZ9P39zVLBY27q9wvpRYmXZQSs7v8EN7ExgocnlfLOx3wjekdM8rP)st8DxZ3SGGwF6Ryrp6ab(Y6XAtvORhfVqsFYRLUulGkGpaYsXrtH2PQuvY5gkbRjkZIy8ZlAVXRsKlbjH((9HeTUybEXGXCzwKgDCkxK(g6Tl70Pr9pChOTySf8QQgNIsvR7)DjQi(gzgVq4hCQ)qWJNmFuadvIox498XntOdaXVT9Qx6kTJdKl6Z3q57awAvaDaqbrvYE)DKr9I(DLYZy5ym3IFOTJJ1GCLAKQO)P(9Dt0i7aFJ0H62pfzJ897mxFrOl3lP7(GE)9AYomFk8g5VLhaS98IlmkqtpaO76dy9jFehep4rq4lOo5db(9bd5o3ar0GUUZLhtR24VVBIe(CtlQDS05XCVeREe6PckvNSJEeh8ugWGWHXjaLCVX3rj2v5IfFCqXLzmkp3lCcW8wih35PWnuujIC(MFFKSdyXhDOEgOpD8jZjsGZ3srXXmyaUHwGN6IRZWNlhrwfF3Ejz)q)lJGYn1GOgKW8jxG5ZmEEIfoE1f)nEFhIxEONcIMk5t1har(I(JOVckq032KQ3h2cLeRczsf)(XHS)PJzg3ar9R1nxYIqAsTkHPfbPjPPTI7yjQcpHA5Apsabco)OuVqK51KRRepIBysQAUiIVZwX7lq3bD1VZ5gn)J8UF7N08fXewnF4QmTNugCpF9ZrZwB8ly7KVjuxvLXwPU)tgp(jbmsuSjJtbouGdGiNf1omVoSO0v(Y3juIGNVX8lMfsICBsw3wiXm1CsG7XljWyEuUrMaZuq84jypUTh2bJsuloIhvZspD6KPZuBZ9Cc2RGh9aVY3JCd8Xcctfu7tUVRFz8pM4(ZFAAoX0Qz6MicRJJhpCQj)lxxA9HdXT2pLNJ8ECyFrP(MsuQ3M5lEKEzUJuj8tnmRqDssZ)bUzQI8iql(NQYesh5k6k82gTBzn3lm4O8zLFvCol9NAhOKYKoTcn91Gsfv)Vb6N4VvTuQsXM3jamJh5BxWC(EIL7T29TVOtaBOYSe3ps17LS0NmRadkA0YQ1NEZfDpP9uSEEyttyt67uzMW7eQ(bBrIxBxUQSMp2wMvyRSc)P0yCBt9RC6OdJRd6jA6GUF8j0c8lrc(thpL0z4i7Z3bZjOU83OZnBFLWnBEvzKi8rq2fEzIA3opryf7TV286wnTGSFInNdzyA3BnqozUApPx3Xju2Gpn5f0vsA7zZ80s724sJI5sLq0(09VX(1ES7My4SrtBrsk9ScxPcRz5B7lRH8KXs8yEkl3dCpG09UNsVxQWQMvDdRh)E4UZRQOkUrjFa7)XyX)aing4z9(3(6sv9tTVyWpAAdLZCvAZsMTRE(tXUCzoBvJljaPWzIhch83L0neDcDVgl8DT3KViHAUkMLxZIVVBf4OaRXtKUb3ss2mrnL5z4TfTBwhip0CDJX(64IqjIOMIp(Ch2zAg4pa)pSpe6NotlXK896yQYZXooD(E3npzUs6LIO8p(pJLpasIopB1hXWdAVswZP03dgfzBXGYj6g9OdpWNOxLRZciI8SUn(X6HT2jVdp9XvQPg53ptYYzXG9nW4itr)gk6aJ9gcbs8y9FMVBfIpaYiF)N4odBeAlmSZUvEPGYJtIzo2JFM67kjehOdL4A42)e1cLHyCKVPzVgj0Jnco8(7UycVrf54ORjPr2ca39cmVN7z)2HZEW0lAjIpX)xc8DxQYfAP4LEchsNMVIsGMS6IsAr9JL)axIIrc7)pDeYXYAwR7NMKo1wELsJLDgvUvdDw0VLqLAWrWLqD1HmUCrt65CZ(gxgx2eJ6xkxWOPm6WddO8d(T9Pxe)EyCGpp4hnaHhgOTHa4a6yHXVW7fPAVVYr8kXrGg1kfhEUXahpo0DAX6uVwGXcOs6b(HtaWm6GiIwglcNY3vUelSVl)Z7eVQncBgnIObPxo)gASwCpNW(PoEu3d98GCl7qyFe0hm9vjmFoy7)ANAkL)fVJj1Ht78d8Pj5G1WF)MfEDPtpEEz(GteQNseoD26K(o8TVR)W(1i0Ppf1MeyMStn810(oB23jt8eo5W9AU69wZnpWTPB2K38qOtpw3GKyOMbNUCU3kgEUhYlKYIQI81K)tvobJeIlRgiY7JZVIxzEtRwpSZ5zPRzyuB51ALJOa7Tt9gmGVyEn9SGCV2jMmXoB2OqB(d940(RzUVQ3H10k8JAWi8rayY20Mi9HEOa08bUY7x8Q(VwL5YyxIVdP5V)DAVYkKhVA4xYXvDQP1NYud0ieV3C19qUM)RYJ8kihWtXrN4I13fnW)7I)Np]] )
