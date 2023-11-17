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
-- actions.precombat+=/variable,name=hot_streak_flamestrike,if=variable.hot_streak_flamestrike=0,value=3*talent.flame_patch+999*!talent.flame_patch
spec:RegisterVariable( "hot_streak_flamestrike", function ()
    if talent.flame_patch.enabled then return 3 end
    return 999
end )

-- # APL Variable Option: This variable specifies the number of targets at which Hard Cast Flamestrikes outside of Combustion should be used as filler.
-- actions.precombat+=/variable,name=hard_cast_flamestrike,if=variable.hard_cast_flamestrike=0,value=999
spec:RegisterVariable( "hard_cast_flamestrike", function ()
    return 999
end )

-- # APL Variable Option: This variable specifies the number of targets at which Hot Streak Flamestrikes are used during Combustion.
-- actions.precombat+=/variable,name=combustion_flamestrike,if=variable.combustion_flamestrike=0,value=3*talent.flame_patch+999*!talent.flame_patch
spec:RegisterVariable( "combustion_flamestrike", function ()
    if talent.flame_patch.enabled then return 3 end
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
-- actions.precombat+=/variable,name=combustion_on_use,value=equipped.gladiators_badge|equipped.moonlit_prism|equipped.irideus_fragment|equipped.spoils_of_neltharus|equipped.tome_of_unstable_power|equipped.timebreaching_talon|equipped.horn_of_valor

spec:RegisterVariable( "combustion_on_use", function ()
    return equipped.gladiators_badge or equipped.moonlit_prism or equipped.irideus_fragment or equipped.spoils_of_neltharus or equipped.tome_of_unstable_power or equipped.timebreaching_talon or equipped.horn_of_valor
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
                buff.flame_accelerant.expires = query_time + 8 + 8
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

            if buff.firefall_ready.up then
                action.meteor.impact()
                removeBuff( "firefall_ready" )
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


spec:RegisterPack( "Fire", 20231111, [[Hekili:T33EZTXnsI)zr3vHrmwMMKYko5ojTvEVo7LSPI8U5)e1OHGIZ6HZWDEifLsf)S)dD3ayW7zOSu(LC1DxkV2eyWJgn63DJlND57U8ILjnSl)X5tNF8m()3KPV545N8zxErZ9BzxEX2K03NCd)VuKSH)NFBwf(J3NxMSe(46Y2Qu(pTUPzB9)1RE1nznRBVEsA5MxvNTPnpPjRSiTkzvd8VtF1LxCDBwEZBlU8A)Z8BU8IK2M1LvxEXfzB(k(iNTCjJ6oRo9YlGU)YzZ4)3)1UR(HSIYQDxb9C3vTBHbCYUVF33JDA6N9Y5VH3jE73xKcTV7QMYDxnB6Kzto5vVXONtPE6zaR3DvYnjzfAD)nVC28qD3SBZWU9tjnPRLtS3ooLgV)rnB3vlzx3UA1KAEFwobw0RG54DSnBlRsY3D1VKuTv7JpHV8PpwUCX(dt2r7UkRinVDzwXn7UAtsX97U62KQSKRZH(vVoBfFo4Fqv5MDxTTkRSkR5EckLv0WQkG5lTCP(I94xoFkT5lxMT6E9VdN4)J3wu3Ku08Y)Ero)3(L1ScOV3Yxd)h85K10W)BMJhb7)z2MYB57)lslRaW15Ca39vLxNNu3S7Q1jvltX)wDkRGVjk1gJxlbG)m72S6GJbSVsxZsF)UR(RL8)9fnvSK3p5YlYZQBQb8zoI71T1as7I0YY8LL3va)(pI3ussHg44)L0)lFzWbKlV8lVSHJgR3JRZllxUyvB19w96yOxD)YfPCahJFGa3l4N5Dtp)GxB4yv1SQ3ZHBWy8A9zAf)gjoBwt0j6DkPiLv3WrEwKMKNB1Zpn4s6qoeljNv0mPrG8T4oa3t05Dx9Wd7UQQTGXp3VHfQtJ3D1ihK6U1wt2gg(fWA5nwRfzNUjpzzwstzv9IRtwc0JyRwXsBwqKLCAMpuFM1qr9mRkBjRTEXQQKB2W3zDtHtl8X4Z9og1BlZYRxuUArblVHJx2w3nm(AKpsZM6DOAk5BEEFBHRm8MwST8owLgWXF7WaoZ)aYHMxZrQtxZrwwWp9WJFnqTDJWqn37qDBz2soGyjh3Br96e(vHByB6gm)nddNnoonCCs6fWw5w(0QTdn)z4ZFDWnwZ6m2Q6f3KS56SgZTLztWWCI3H5Ao(mCLzX1v8lfR1UIz1ame23mOHiPEndpGBwZwW2a3nlBZ1US5VDyaTrVPbCtwvvzf8fCCV0M2k2Yf8d(s(VENgMv8UbBAohYvjT5nkcwAtfW8SkBlnuFZVYsBrk)SBzvabFoiK)NR5)bFObQ4zaBVBtYYHrys3QiTSfymuVLLNRi755gB31AZP(DWCuZsll4Z(7WPf4NrtyBDlN(eF9Cndix3wdlXSnByWTBg0qjNxY22CoxP74sAyZvKpYLW2iH)XznaNRnaFUYvRG)oroNVNtQYZyvhb9eM10Kc4d5irzy3VgwH5z3SUbMX74uv4)qgFiwwI8rH54UmynuamrQy1CyoWWKdXwUmd2NWcQBZDy9yyUQkBVzDzBJaqZkeWYj7U6luFx(9hrR9AExZ5B)K87sUxSQiass3iSe2CI)1kyfdlNB4Ck583RP2(kflfymWnaNeWY7PTemt2h1DmaCKezuFCe4D4qyPWbknjvWMdqiaU6aVcuMITL5W4TaxVlQyB4YwXxbNYxEWKHmZY5R4jlBRsO194bW6KykR9rN3jRZeeBSPCrQgW4fIjuJNR8JDy1l56oiwtDlSOZ)54DTmnjn2D1l3D1jdG3MnTn5AHFMCp)WnFrz1YcGP)GxmNEMg0YzywSKLNCpE623wQ)bH2J0MZDb7rGefRvKldhZPS6AK(AzfXc3qILHVn1K1BBfdKTCbrhKJzmNqyDXrJo8KOooyv4rlDZ4a(T2)DB22T8lua)b(nf(0wNDtwonJsCb7wxC8N(M5VE2e1AHdRF9u4QHuQKaqNysvvLTzblnpBB9(HP8zpcOJCDAmPEKtZGBXpYUJtXPkR49moHQeGE3DSKTW6ipRaiwZjcZacpCgsPzazx43fAI8J3VPLP993Tod0j4oIWQaDuFV1cIZW)jwvtcqoh4sH0LR)ldKzDm559ICOFEYLPBWC7DKnnS0q9OKri5R8j1AiPL2ZRGh3bkaDKKclv3wSauYbHvJjCSdDbzdcsQDZWNOD2Ih1JWB)HE)frGZqsNva3mQ5QvuLCllh0gOEBwbxQH9ImWNlxbHhUW6dSKt3NJNb34wWz5VrUbUH)7nlsVpfwmY17q6SpDhu4RmU2fv8)OwEqakcdAAzCWEG2zBn)N5Q4Sqq9yHKSDes8DhPdBue)4KMztwNuRjgGzBkwc6yaZN(CSqMhzHm)XSqu3bdDa4tvTorRUF7A4OoPUoBtwUq2SUJm9Zl(VTzbxRgUW(lizovCC8om(uWtr8njnHROmxVwghuTPTolDVUyOKVX3a5trqdMEVDfiPpkPEcNXgDWbQ(8Ywute(g9Oo9cWF7Rbr6bAC7U6FYL8NX5dYv0OoBjZwjaUYg)D(jq1Dz1SJu2Ul73yQ50Zyr6APRjrjABpqdIVLb9a1a5lBRki1ju6dGSStGXo5ggW6T4JBiDz4Oc8)w5Tadx8R7KC3uLg(k(DOEACLRQjqYMeq7RBtYr27LIE3H2cdGVTbAksHwCsD)YtfwPgwwPjcqSqF0cq4u(woLMgoculPOSudtspWoDZ2YQaz3LQQQUXWfgPSr9Le88IwEp(B8fZhZNQVe0yJ)3pQB23wY)foyKM7A0g20Qw89)TVu)qP2v3pjkJ4oC9eDIViWzXTiSz4xQKcYI33ZkwH2iEbx450KLavMeW4QNfQ9nj)6crFacuhqIy1M142vdJm6tMD()HBUr44COULiLmA5QmjaRMdNqh2yDBS1ehqDNyA0(rG0Ph6rlVxawNhNIXMS4mosa6erfo(cox(Dx92BkGtUodg0HmIwKGJTaI5siEllz14nqCDZH4mjYujquWdgJGCr3VadIWYh8F6MBG2G7KRtQG58TF1xtO(znhrMkbnetsH(cRImvrYkCHJULW)8RqybjAwKrBvlM2Q7yRVNF7RznahxCxvwDZDvjBR7ywjW4IICpwtrTHHA6hrhKHt1QLSDJ9PmO9XVL2G2nV44x)5F2jVXGt8jg4tgqmaxkKcdPGE35lGvQfzG(baG8bOkZNItFy4XGjmq6OSW(uNUIyyirjYN11aW6E3lXQFRyE40jPjIJHvjzeG0VtacTK2)tq7zARYJjRzoktD3LjX9GRzCcpWOPZHuED8F1w3OJ7hGVmzwpWkKaHF(1tfQp)4nTQLm)))UnPOPDZILSBZmTUJcrY2ErgeS9zvI4K40nycrXvCLXI(OvB8pBQb6yKDba1dPp2Q8eYdixN00KVh74HjAO9WdlLq6mDxY75NZvGhI43lEQxjwJoSqS1Bsdu2u1MItZYSBZk4A2cwJ)jEffAAGLwi9S4CujxFMawt4(6MN6fL7ealNqkqWVYxvlSHsdrWHVNYwXCSjsWEU414nf18hCeH1ryxP23UtUIH7qq7OjEMhYWDCCK6MffL3MyrFcJFGVTcfT(h5nlKowsQ874CfbIJVnnl1Yu)DcpDd2PfzuF0j1hZWM9jOKJqq9kD1Pd0uTmYzwIFaDvWCB5Mu8609ELjO77ys3Q81z1PzBZZksaxJXjrVb1Ib29qSBCeOxajJT(YfKlVUKdv8dvxQnOW2egtdGRIvpY)ZB3f(TrEs4RplsQ48ZzDhnhePZsln13X3lKhFtqeVRlZBMODgC(Gw8DQ3nKt(tKNK2sT8)cHTMiW))hGnTBe6fbqwGghgSbAQePzMuesSG9RB5QXNrwt5yBjNE(oQ6C4GgKj6rhclFYp5E(pxgBr0hqhqGTTatpFa7(Vx8maC)DcCs8qb4PTuFLB5m7zArzIC0TyB8t8vjyyiz419TOfN(siEZQPFVZmoOtP0mfhmO5Tmx3YOaLskbO3lGXCskxp7By1KxHYOin4f9dp7OQGb9hyIE629Q288fCn3BtPo(j62m2ORCP)4BaMXWYvL9vANuARZUJMxU7Qz0DvpDd07tSLWfzN(e3c2vPmFrxNRh2K5txhv79oaJbJ28r4sUpDJo1YdOK0BGuD3KUeIahaNrOjB3CTa2vqK8H9(U1zCfIa6iWpX)gaxmCKo0RLNNg2Sdd5ks)cCPt1qBc86e4adIUPh4iFcjdHqWKcetbit)RxNqol(yBfp8cd9CNvDD2Vi5UhpKTn6ZoH(oYXB01m(qdbzxzB6AvmW49gT4giDlOJBYX4Dr(Wc3rSi68fljRkGIRk3esZsKww0uvMxBqlszbE0uYjWIXKsfce3D1f06E3vVdw4IydsS6Jy16j9GRdhD2kPf2R066veKcO0gdgO1(oh1n3w2MTvCkllxuJXhSrWjjc2j7UOBHntfpKeuP(zEh5Gb4(xTUTUSb0Jecgzi(mBmj(0hDy9qKrVNiy3wNu)3y2RRf9X5EQct)wUmIfSnzWXLHPKGO5gxalqtWa6q)EfKZx4J1hWss1FnlbbaTB1AuIe1nvtKcDRt4A6eHnm9XKfw(ZrjiSVYRKOqbTSUUsHa)Fvea7iu8B7wkhzFv01q(WL2BaZdLa(qsl01RfEyd6a7xBWac0YHCOvnpoQdh)6w6o)32b3DwujvQvd5ev0kRW8Uu81g(y87WvlfnJ8LY9gdqSTdzAwaDS2iklbGXD8LIYPIe1iRnRA20HH1BbHyrlVsZnCItb4d(HoEWerKIXLAaKUcGd37vhdwGAdIUCq4jQTjo8FV2KTXTOJKtt2UvDER4pOiRk4eW)3ffm6o)fcYk7U6NmJpDDu(oGIFjnPBCsAi(46DAiHuBYsFFNqQ42pSDb6fe3PnJ1b3afmbYULLa9RQYgvSe8Au7xfDyKNG(ceJpBqki(uM0fH2YpqOqn4wU8CwAJ5N6eL1r0oriaseJTcu4unBN2dwnZQA3Ihe1B5sgeQxEs6bRE4prgS7uMt(jy1dJSfWQTOrmNvF9hYuwDYkUX8SyHpptfXC2afwc4sl7LzKqVY4Y6s(CxKjccKBQkbHgWaJq5hwq5YlAWOdPwx(RqH6dEVjKLYd4F1d8loVPV3J4etLKxcrP1jlQSeHJiCsAEgQA61vWnHdm7beUWrIg3bewTgPyLa7lBdMTKgxEd7vG4IiPeZrxgjlxJj(Xgrq(kBBRmN3Cib5OvLNCfjo7TUzbZrI6f)R2LQmMYMq1qhQRtUbHUvCk91(quJa0KkR33IfYaXfxZB3hwJXDpripOYaqPQvUsM5gzuY(qriLDpH4GaioHUKw7ROmBefSbf3r07aQBbUSUm9rkIIUcnDQy8(RxyAnn3G7E(0q6N3LQKnHtob)HNH(kLZE82jZ006avZc)15E)1Jn(vHe6XmBgP0OkL08VI8CLvUhkyTqoVuFFbVJao4Ai4jQ2hXp(u10hAWAchX(BxxYkY(vbbb7GtGpbFfFFsIJtC1in4rukGbcP6OoQ3rG4WGQx1TqdyuUTDlgCFnt67(lcS5YHWVvv0wZ3XSQJNUy(2ujNbXbH5YEswb)VrHa0iLE3PIvUGDSHfLETUTqIQlia8c68Vyc1jOQqSPIgG9geJDcCt9l1aOhathPcXerEMTgpHKhg4uNqsgpuGECJleTdbmOr0VH9RBZiIduw80rx4mPa19zvqZPkkNpGyKf3nNmr4pBWiF8MB8KicdyF9HbPpvsKmO5WmvV76KC)5sWt5k1rZPgp5nqFwUstGj0b)1l0i0Cwmf)6x18tvF)H2g(ZuVwFTX8NJu6mqbaHrGkQXcdob8plwT(bmpkKs)tKDZFaZKRr4S3u9yLU9A24eBzLvwCCc02EolrSeOUPzn4q4tqrnrerBFHgIsXVanaF(gmIEafc5kUUupig)bCti631ktCLdUhfVfnmpMSx2)TFBPh8gYan0UfdFLj8dt9LUg3hgT)e0uWoqjtbjwiRAtwIMrKJA(5O0EErqBt)j4Uc2N67Ek2Wbc1pgJnZ1CardCnnk50iuXDBN)iq8UxLIgBArtEimelzXvSxKrI5Ab3jFdHOfsU)WYlDXw0G1Mga21CY7WqJDnhw2vRzmKs6WyNmrL0q7YTHFi6sGkfsNCBlhALBw9HUm(Xp1V0kxg6Myd7LiSNIXKR6Wyr0tfmbNQaBcwWHwBtQEV1PYptTXpsGgdR0BIXjNQQcauFOKOrVUnic1FkpDs0iMvRsVhHX(tAAROIarntO1I9mXVHbRpmCke5je6IgrqMdwjZCtevMAXT)54TXa4rHVb)IEU7d6KIhf2Q05I(UNOyHKO0w9hRDU3ljUWKqJEy7UdAKdKP4AWxlQ(sJcc28lyAVxo2NLQtK8l7LLtsTJG2mpE8WpzjavNoYywotbPx(tKwVcN9P5Hfv2WqjoaK36hbBSgTkGcz(iyw(IYVzi4Vhe1ShgcUAPoUQtNgQhgrPJg1h(F(RqDLQ(3sQXQDLDvFY3bQj4NeT2exap96rXONA96IsR2sH0NifbTuX1jXdEM3XF4BaZRBbDTGWxygxZ(bLlyFRqmWUA2gjNbAZkF(lVMsSnJ4ORdufsQu6cqFIE6ARj)CY7Nwfcsc5AIOMX7xqURiFT3D8uKn4r2etQdfLaDU2UZsGFJWsGELScJyayib7l)TTqeVd2wU22f6Sctltf0QFnOFT68ORn5kfSomZH(4PQmHXHpgRhQ4QsqFIULq0bYxcE7bg0o4P6WdKP(U8HzFusAklNvLabEnActVMFXj3sgeUeMpioOo4HU82M5DjclAnlFBFHOHNWdbVYQQKuKwQu1zbguapkTSOMvXV5nXsLZygrUFMn)(H2HhfHfLB4ia6Ho(zAX5NfvZgpjZYEoDbWNczEBD)K5AEBqiuq2EklIzfqjnBNihqZzRACXNqP0t8GfIfovbsiI0H59EHVKJ8iHkfAgpNLxZIkwKofaDph4WONFLNCnQOfPlaI6yuFJIxXt1JLX(CnKYCPANb7vmU7K1Lwo9mSegdzCvKfdGXzCfe6C3D3yzApbBu7DHv5622N2ZU2VZkJ(jAqiA685XzzpwwLCdNS1ciYuASLJHyw)fDKM6yJsKjT9herJeXEocksfWyJU2fh9qS150nVLRbiNsmt4OO)HOygNyxkB7otheDZyzgCylEzzqogCSZLG8AiEdLXAUksMNDYWccxviXQhKi60T7WNGQpidcWhHckYJnpo2)p7WJE2XHqtrkAUrQ2(ruR)WrXyF7cxegrJGk7N5nmtwhlbR7XehoJxaDw6PKsgpqJ1BSJUtsNo4gEMHo9dz0MWiTrxirfxHOl6VqCoORcjXTwqO9spIh7DV4lDjcm8pYOPA)uHVx1QhQkY(cslVl(i6ToaLwLhvkFEyMPcN4e)e9U1pW2jokmlFYO2JiQpVWyd0JW2N8jb7ZjoegG70cNod95OTWWgDXkp0orz84W4GDiqgqCq)EyOpFTzmRXDG8(mTAUWZvfUo)2embS635LbUV1vcBc0bRIBvGiC)yBPf8ACCNRFw(qnQZipi2ihCyPpmklLXs(Y7TxjLPycAwlPyj7UskxYrsdE3JZj7mZGOuwd3waedulZFU8Ni1knsfL)H1qY1DmRzTUn9tO2HBfVs71IG8tfn9gYDRNuCLAJJa1wLPCg5sh5K0q15gTa210oPWBSrgB5ruczCJuHad)HH6bq52H8vYa6NARupzO(PzOuhvysHmkAGGxoECe9HXd81MjmPltkNakA)vnqlq2nKXx1TothA0U(6CULbMdAkpFrVXama7aSi68HhpLXwCHL0B)pjfeopTFQREpAJw5Dg0PBFuuvO2saHlJAdRfhfYfwoWp81AFUJEQgY8(UPieCVPhjhRkA6tY17DYjpL3Jo2XrnXVk9efwWbRJErTtKRHEiJbb1b1cznu8g0XnkBLJSFKLAiPjM(niRFGVLwsaS6WoBSlECJOIl1rIYBxtfuMubdqnBAZ4bzfZ(WcV0N)11PnftGAntB)iTfHD5NbxZBsksMSfUeeTVlG(1Ty8vjBcwc4chktKDav2dhW)BQ1QLRgNU0j73QRnkCoTkdQiYOnWBOewDvNGjtgmWXBQvFPpp06q1jGrMmO50NtRmDkS7BvLZdqvt48C1J1QgqAU(lIeyv57yX0scRPKk6OHBw1d8lHRbtM(0Llkn7HOE25wbkyF6FfvrP(811zskb6MM3kRCROa(sJIVRduhUuqrnR3aGVpbB04SKg17EY54PhiNIxOFz500fnOWCN7cjFCkObo3ZmKlskUh912rUALTZSScQFtP3sdEhFlkOsj3DG26HTtLtm4h9DqTeMvav9BmeNx5jUSSE8IAick8B1iXC8XLC6Nn)nqb2ScsN2AXtqvg88f1iuC8Jdqa6JH476F3MHv2yQ2SMWzTUjbx)Kcz1t299)p4Boc8ce(veffO5p2h60htGoVTjr1495Wz)6y85n0ZAv8iF9KS2mEfNSwBEFHN6wB04o712dSOWnB(KgOg6kVV4b7XOA)ge4zK90LNZrV)XDECyHtZdB16(Em4zKF0WIh3O3nUVXACdvlPLJAF1AANfU9eeR6VlNKHuH47DIc6sBR7pp(POClJS7DnfofF8bkMFzo1o2rhsQl7TIBFM)2u6s)Wdh0hG)Hh8fPBubay0bhoeq6dp0lizS2046X(ZdxM9)Op6qHUBsKXxmB64XYZI)pixyiNFaxhw5N9CFf(ZFMNG5HPryuKJDjp4Tgi7m82aO4vEt3zjw950zYSbw)UozcSqJcdRf5oVfnw7b(4P)oUloE2VNt28EOHtYXBgvjJ0u6ZmI91SD2lomY97xigHOv1ZpPZl49uj5g)rXQoMVC2P9udpFHAM8v)oJp4h6aHeTe9Zg)rF0SrraqNAqZtEg)NJdJx9CEyeFWdEye9ZgVxNfD3DCec9juelV6qPkexF8EPf1Xb0WRt7rRfOUR)h2kttsbvvvz)wKF6ZKQE2JBGh(DxYO9m6EbdM2DF)aab019jbBkkEGJ5YTMGGMtFGJVL5z9Ci6X4T2JDG7ApzR9aJ)h4A3lsIt4nUF4jp3qIz2c7iga9qBXAS9f1l)EnSp3i1HMGpa7Jjg4au8E6w5bmbWZ(e8HdAcii)t2kF(ZdPQ(ynILUU972(StcY)sfzYFSdVlvtbHW2d7tZTX5bUK)0DW98DPz33)w8Cdg23i9rf8WCdrI0UVhIaPYvzDpVV1tuIJ9IZELDLqD33)FcUbzFkgM7(EFdSuW0Jap7FwOIK5rLBpdY4sSmQEwWQO6dpeScQQ1uGQNQwp8u5u1A1FvtvVdzovmvTwnQwQA)E0kLQw)8xLu16Gvfs1AHbFwx1rvFtlQmQA)uWQIk)4NF(Z)VV4N(F2D1)uCgU7Q)o63koom44kSsrayPjGtSkE5VXpBbpgYpcPkcnGQ3Lhosms0buof5rmgdHevKJLZVQSKgzNY5O3S7bWlTkA1u3xAe)JzBeV5StOTx)ORlZQreGoAGaIkN2eRPxievEnUv1a(u5VkJQ1ZmkuiJxyIw6wGWh8kx31AAREHxSo7LZex1e0xCfc)OSvNz48x3r70PFiab8mPOfWVfuvOW3yhw3zUBDgeIKgbCPz2Oh8fD0gqoyyM)ON0aq4VlNnvanp(tKIjGHRX2KM01V4Z)8p)toW93F(HDyS((v2r9Y(a60JqMHdg9fjmMqrF9qbe5WRNFyty8kTkMVVAS)abcAsnfck4Vl)XexYeefmBjP3PBkrmvpN4QAP7e4r(5NXHjTrqx2CzbddmOYyNtfsdTQqAGIhc9qAyWNjwjJKXHHvBEofAfc(d0cnph0B5z)K4lqb12D130ffEd(68GHu2HNNbOYUXN0lUCz0t5av8rZb2oqydcBG8Y7Ibc8W9)rVzXqvuXP81t3hw(d4a0jwAW6s0tjbhtlChIMJzV2Zdr4okMAnKvLXfnkBNz(BywRTl2z9kPxZaFlw)y2Ji3dHjTvNvtNC8(Cyn8lIIfAxSH2frwovOCzUXSnr9wrjwF8T4g4LqDW7xFoqOBZ6Uv9wjKjryHuzPoDnBzl9KvXWeKdwHgvnc4DtqVOXTIcxp2(Ck56bcbQLHFiEXSPtnqnDL1wTVq8TUstaCieUgT)iU7Oxg2fR1LxNoHTAfxt4jZMo7tN(Mt4QDvZwGTQwy)Iuq(e8L(cXJGiEqNTi4sh3JfLkydDnQH7tXYWEOR8MsoR0SMfBRYQ3mmDO)9tdzfW8VcK4H4YFNNcME3DSoJpq39uXdzc0Ne0SuPjnSBkbPqK6zsKNkPtRUHWGJXFzONfL6V66IZH5tdrOL6TFRJ0kE4Pf4HAVXgWODq4HB0bbF(pgDOsYKo120cxf)kZnEqlq)plh4An0t6H)Xv)H7WFpSKut4AkrW3FEFQK5FmvrSnyUS)tqccmAV5ymmoP27Lm1qsFjWBWUDKUQg2Z0FtRXXcjsrmk4)dCC(LKkrElQkWGxZefdwGfOEP6eqp32csXqPX47eUVtok1LseEi5g47iuroG0shkolPkpJv9FlfSgz5IvVNmS7ynfdJa7CSKZwHfm0vq5KfjDcZHMKuC0eKRfWQoz5YmyJdlOUn3H1JH5QcY)cQiidabwHa4Wf4)luFh(OKLPXSmj)UK7Rnu2SBewQPaHGjuf7gUEJuE5ylPRiVufr4nSLuPaI7zhhra5rbogfqTer7Dnyb7jTBhPzUCLduhDOUtLjKXhEiCyEDkoK4JMFERUV61xfBlroo8La2B6FQ665kuCpX8qOafqF4v3DjgzyUvDMnBcdQwEIKnj21lpX7qJJjhqDph0NZjlSSaEnn6zqpTRrNpLk6aXINHZ77JJTuJqblwmMCQxk7B1EEvFX8hEWediYWnEK3qH5WGerF4bvaGy1YIJ)03m)1ZKXc85VE64W7(BQY2SGLMNTTU)ZOpBp2qifWFKDNI36orEgWs2sEHOaiajlmDOS2aPKC0RiOJM(rWw0AFVqDjrMkGhS7mE6)BlwIQpXQOsViq5fP1u)xcdbIAeE1nrTdgo9a7FscQNnl88aGioryMYq8(h7WdGLr(7hb9yADgOOFm(HhCcUOOBTiyr(DqXFKwHb9RrVi9FE4bfKZIFscyDl4013i3d3aPw6I07tZzroozCrDR4)rTCFdjaljM3HDY5fY)yEPxaqS()YgVPgI2pBNobNpF6tW0n3)05M9cbNUiKXYVF7Aa8NutVkQq3mfy2nUZJqtijnHRSYcoAnFNSPTolTx8KtqkEGc3T1spKkGjGSCVSTwOk4rDc6G)2xlLwF3v)tXR1xa73XLEcFr0UlRMDKQg8N9Bm1C6zSCFz06jXWe(rwqVM0Jfm(M4bjaeolhFgmaJriTNHHQ4DYOPkQ8CPfRjqYgmdqjTMr1HXERPv2k)Bd08rcXsLcZMNk8FhSSsteGyHa2fGGa8TCknnCmJwsuEPiZKGTDcBULvbsfjL9wHwY5ev2O(YiV(2A5z82s(VCT0c213xKkx1IV)V9L6hk1UcZkrzKQMojoDiD996dX)5kHl(as0IijyXJpXk(OdnsPc8c6f47l6BjvQ954ImYOL3bcxqN4llzuzwfNQvyHxLoffwpW9O6Q)UTDfwwk0HYN1jElKGLOHGGSHgu6cvPZ0(OvKspcJXLuCFO5pcMIT9euaOj(Fd(KKK5h6rWNgZLtnmoHF8P2TIwmyUpwxIxB0AnrETBAXXV(Z)StEJIdYj0H97KWARtDg9QzthIVvS0qpJcRTDApRpiDcWLNcj7nGTPGgg5lGTHn4vY(jeyzeGjF6jHGod6MiXWHFAu3HPQmGf8Gg043Ez0ZpthIvqVfHgYgJNRTC6UXWR4W80QwYYF)72KIM2nCnVUnJu8lOfjh5gE7GObXUU3Xe2WMBA0im(9ZIP8d5VuUudxN00K3Zs9XjjXDjVhQE3Gfv5ycphZqgeGmTP44SekZWCfey55phtfN2mA)IfjGQm3x38SmjPjv1c1XAimFWaERyk9Lc2JfVMQhFEg76(4jIxMOsuwfkDZpwEBIqafjvKVdZgn(DokD00NNvWhTOG)nWefib2cOJ)qm2suEGN2RPi0R(PePXVJjnT2xRLDv49)nOGFKxkA3EuxTVrxxBquM6s0LkAee1mbQjCWxkCnsrohMRfEZYl0(DeCZx7lix1saYdc2nqTXHKWq4P41L5A1TZZhWIuk9B8dPtmOe5ZH6)PbCPJo97dSBK0dggP34yNRGWc4Pcus24sTBIawXP(dgQ(Ca3CHqEis94brXX2EsalpTaJ)tiilkZ3HHX2guiARhqddL3wzxfl1GMYP6O2UA8YzZW)LrHrI)BK0gz21lhHJc9YvqERk7pkjb5)lpJunLR3Ss054VDmTh61Iqt9PHZhgJ8UBLAdQJ14d8Xi2)xSKe)hz9l)cP(dCTvAQkZRTcPfHbGqlzKaLps7cdlwNVmlZQ7mQoRrmAYZZDkFv(op3PCRnWNF8NikHtMsm6otJcAXc9DKBOx5xiWG33b0OiRcqJz)v5ZhEiEXA98oXdLKkO27W2iQ2HmpVOz7cP2Obttbri)fQU(kQxUicKwSLEKnYM)inn0tKekjl0b2V2GUq2YINMYWRaUda9RpKJyC0MoIoH8f7c(ce6rh46Q5qaFIwPD9xtH63nO2f2UtNo5KhEWLjZ5NnN4B(1UjFGZPJwOst2HhTZcCa4lqg5kHahBuGa00vyP7)CLmodux6QDc1Z7sOYUm5UrKWJ7tWlnBMpTAvuXEu(0ndqfYpI4h6yRCeq3pBd9GRrpQ9crjWZrDuCjIQov1Ptt2UvDgPiFRkkGcc1qg5vGobZn2tdFDWZfa)syOk9HJCPUEQ)pPjl99DcL0pm1jHJ7Hx85(DOKbDAQeC)9QFta8LP((zApHtY9U2n4zFa6279zMkUCc6M1YAHY3l0BP0Jr(ejRbTNqQhE4GGm6g1z)yRNlQyHgWEefbeLN)O94ofb0Bw8HHJGq5RzaBF6NS(yrVTFrJE4buMLzNewmGXMCpeaDL(0nMPa8FY2AH2eDBdnzHvzy4zuCvfVt8DmzStyh1Fxzv1Sk42Hpc7AH1rObaoJW5R3EcoDaa3GhbWinugQHjlxwwqURsCfiR42sOQgds)qU4awzq9qw5UuIr428K7fzEG8UJi8etxxwwZSmek)J2G(lTMIJpRywoWcNwnlKlgn)MqYhMvSQvAkmecA(Zcs2FqtKKWfioBD7MnAsK72KjpIqtgs0sg4Gh6lsbF4Ha1GLXJSc0WENS2HeaFdFuihiyfZ375N7jUW3ZrWFSJVVdsMt8LVNJaicfF)Ve8wdfuG3WXY3VXWko23RVf2bgbi2E(9wXh2E(1(dHR9CqIglDbOkJ2s5mmgKRx8VAxEJm6lJkXMZia0GtWlVqYe((GYxhDeEmY4HsOiC3VcYinOIRGgUHJJSpoz2o2tigaiQX2jpL69ThPyl6DWKGbEmPNeDZ3RvVu7oFWwPKJDk)RLcn2s8nFA0vI1DkVrMaSgGxqNjZ00((f4Vm35xow7x46Zg24QNTplScwlqjV((c(6bqtwdSM7tU7Z)usLT3cYTQEBWzI3gCL0RqfmWnPxoculf4Ox3wjykZv5ddNRM4NUMpehb1(0xfqF0bc4L1lqOQ6TpkE1r)0xlnPwaraFeOLIRMcPtvHENtUUX3thPcEJD6pCXsGlosc597diALbkEHGXmzwKgDmkxK(g6b57SPrTpC3qBrylysphhJs9ao8hsqr8dYm61Di4s)XahpD(OakQeDTq98dBLGxaIx3gupFBAxhqt0NVbJ3bOW(WLbyPE0p9dOs9I(DTYYy5Gp3IFPTJI1GmLAKNgIZ8B7MOE2H)nsdQB)(6nY3VZCTfHoFVKUml(Hh04Dy((ooYFlpIX2ZZiYOan9igDxBaRV4JyG4bpdcBb1XFiWVp4rUZmqioOR5CjFA1g)rlueaZBAbPJLgpMSsm2lYW2LvB64D0d7GNshge2nobWK71)ok2UktS4JckSnJH55MzsCI3c(4oVVZH8krK73uIRz7WIp5qThXLZNo(05u07Uf9IJPZaCDTaf6IRZG3akruYF)EXz)q)BJG8n1grTrcYpcbKpZ4n3wy4vx4349DkE5HEQrEQGPwFceX)8pd2kOaaFBtQEFynusSkjovuIucK)XRzgPQQEbcG4Si4MuRsaaHtAsAARidlH1kmqkx7zIJGaRpm0lAOmjanDL4LjecsvZnr8t2kQVC8oEx9BCUrZ)eVN3(rnFrmMvZhUit7jMbz5RFjA2haFbBN8Ho76Qm2kvIYz8I(eqjrXHmSeOrHFbeOSOoHPk6Jsw5RERqickEJPm4dqrUljR7iejMAUiGZ4L4WyEvUrgaZOt8OyKho2dBGrjOfMXJQzPNnDY0zQJ5EUb7LXJUJxPZixhFSaHubL(KSD9lJ)Xi1F69w6utTMXuwLVpoE8WXM8VDDX1h(iU1(9PDK3Rd7li13scd92mF(J0lXDalHU1WSC1jYn)Ni1ufXrGM)pvjurh6kyk82gT0XNScdmlFr53eNYs)H2bWPmPtQqtBnOer1)d7)P(BvlKQuK5DCaZ4r(ofmxVNAzERDF)l6yWgQGDr2rQEV4L(KPfyqwJwAT(0RUO7nTNI9ZJBzYpK(bvKj8wHOF8JiXtinjkR5liNzTAlRWFingx3u)cNo6W4YGEQMmO7hDcnh)IOGV74POmdhzF)oymb1f)gDMz7BeMzZRiJiIpmKDUxgX2TJtewXEBRnVMvtZj7NAt5q6M29wcKtNRot61CCcHnOLjveHrUTNpZtlTBJZnkMjvcH7J5FJ9tyAxMy4CqJhrsm9ScxUcRz5B7lQH8eXsKppL1feYciDpMV4JamFxZQUL1JDpCp5pWVfvd668NjKIbElV)dUUGu)m5tD5tgwHYmUk5yrf2vVMVqxUkNTQX9Whf1mXdkd87smgedbZq3cFj8M8b2uZiXS8Aw8tClxgfypEQ0a4w8WMjk7qpdpvUDR6arGMRbm2xtwekee1e5XNHWoxt1(by5H9br)SzAHKKVh7vveo2rJZ3Zi7PZv8TuiL)5)vz9rGs0ztR(qgEuNvYYsM(zWOihlgyorpOhDOxkVkJMfG545Dh8J1DyTtehE2hw1iBKFlmjR4jd2QaJJSe9RIOZyS3JqGqow)NPtRq0bac57)c3zAJGBboC2T4CfKPBsmfX(WxP(sgH4d6qrUgUMpr1nziQf5Bz2R6b9ODGdT)Uus4eLpJJUNKQxlg4Uhu898m73py2JgFrle8r6)YbF3vQOGwYEPhhH0jZROk5jRqTOuu)C5prCumcv))HdtowwZADl0K0j2YRusSSZO6)AiZIE(bvQnocQeQKgYiTIM0Z9M91JmUKjg1pxUG(rz0Hhgq4h4B7tUikdmoWNT7J6AWdd02qg4aYybEUWBkuT3jBevjlc0OwrLXtUcC84qzZI1TEnxIfqK0d8pobgMrheH1YyHJu(HYLqXHE5)9oXtCKqBrdFzGYLt5MXArgob9tD9OUh85bzq2Hq(iO1x6RyP(Cq2xzaIE28okthoGZpWNKKdwc)9Bv4vJ(ES5Y8bhcupLaC8U1P9D5BF3)HnErOBFkSn5Gzso1Wkt77QzFxmXd1Kd3R1Q38LBEG8OB2KtEm4PhRRqsmqZGduo38HHI6qQwBlknv3Gwovz(lKjUSoGiZeNFdswEtTwpSZSzPRzG)APQSYrIYOK8D8aE(eB6zd5MWjMeXoF2Oqh(d960(lzUV62H1Yk8dJXi4HKyY20Mi9bFSj0S(TY6x0lhHwnMZ4uIoH0S0)oTxQh0Ixnu6nUQtmT(eMAGkH4nNv3d(A(tIhzYhhWgXrx4I93LxaLv2l)Xp94lB4))x()7]] )