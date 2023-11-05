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

-- # APL Variable Option: This variable specifies the number of targets at which Flamestrikes should be used to consume Fury of the Sun King.
-- actions.precombat+=/variable,name=skb_flamestrike,if=variable.skb_flamestrike=0,value=3
spec:RegisterVariable( "skb_flamestrike", function ()
    return 3
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


spec:RegisterPack( "Fire", 20230827, [[Hekili:T3tAZTTrw(BrtQWiAjttrzz7mlL2k3XE3KjvCYKVjqiWMIymiahCiBnLk(BF73RpqFdajkpj7KQMjLf7g9XRF3hDF5jx(lx(2LX1Kl)XztND60xn7Lto50N)QzZU8T13ULC5B3gN8U4RP)J84n0)73MwI)4TzfXlHpUQOPmH(tRRR3w9xF2ZUoTEDZvtsk28SQ0nnzX1Pf5jLXRQH)o5zx(2RAsZQFD(Lx5EMp5Y3g3uVUO8Y3(20nFfDKtxUKW6oPk5Y3cD)PtF1tN9Y)6Uf7w82BZt2TOz7Uf1f7wCY0jNm5SN9Yj7EZU3i65uwp)H08Is6hqhv4dGjVA3I4RJtZv6(lF6jZ81D9UDc2TFkUozTyID2XPSX7xRi7wSKCvZQvtQO9z5eyrVcMJFHSzBrzC2Uf)wC5wLp(m6YN9XILl2FyYoE3I08KSMLP5xVBXM48B3T4M4Y04RYG(vToDfDoOFqzXMDl2wMwuMwFldkLMxtkZH5lPyP6I90NoBkBZxSmD1TQFhoX)LxNxvhNx)0)wEg93(T1KCOV3qxd)f6CsQRP)l9XJb7)zYMIBO7)3MuucGRlOaUBllUklUQE3I1XLltW)vvcjNUjkugJNlaG)m5M0kVJbSVswtsE3UfFFb9VFBDjj(DtU8TzPv1vaQkfN8QMkaFmA764kc93(rKaGoLuG2Yl)sAFOBwcficOP0ZP2pzYYI3NtrntG)ag0Rxxxf9pAwE9gsE9L1u0475qDv81rfRIQlttExfmqN6DGGp5gsejNSjfoKPqGt2Ty0UfDTyHdOOROTdJ)ZngFGSQmDlRV)T61KsaVOidge6KuVogoywx0KrrNUIEa0ubiwVNsPVBXxjN02(uGihM9mM2d6kQbq7u)k2bFCoTJ5WbhV30tWgAR)p0v(NrxfFjfRUcr13wwKmPDZLeNLfX(Ji4OoeGVKSHsSZaCcALjvV7QOLnLXSvZD3rr1Hd3izNNVBXSPm8OigxqfmjjGcGSNzazfRX1uwPL1RPiKlJEFjDCEFz82k1v62sYnugiROSxJ4i0hbBv6VoZ5VEQ2VEX501iIjWMsLgNKqPUUgWwO9zQGpUNveDp8cp7HCcfgLfvDBoTJao4648esP6MqcsRt3qIQlIsuoMPG8xiNEFdgD(FPN5F76csE6hIwLrhHkdS2xtNGVIUplrmeYMRiL0nCAfhLcy0EfHYbJOI6DmW28D0FQQbAayGeVDlG6MwpPl6xeytz4rPQYBQO7ys5PtJMTnbB4a5bH(YEsAo9FbOxy34sds4R8i2cFIkM3Z3T4j7wCDYYjBI)GySXVADrDufJjh9)KG8GELhGNnrIc2mNRsDCgLtgId85Egg2MGYP6DeZdGv6e1aOhathJORCE7fBi1RXtiXHbo1X14V1xGo2WQMYBrUMRjrvn5rVdK7ahZb7Gk9pSMIae1o(gYh2MYyoeTKKfFBlFbGEc)ybpaNSAMBovwmXp3GzKkuMEyCY0bjy53FWifAyH4ACFnmzV7bi9Cbtskju6gQCKBilJQqTjMW6RcQoLb6vuQgCLomr7dBL2oLSvcoHMQaqLJg9(1PzKi47OGCqZfLLrlVGOQTKSSQifgns8uVl2GmUNl)(dLC14anYhijnmQ3rUBJOjgvopQcqbaHStG4xfryWjG7zXO1hW8irkDprMn)aMjfcBpBkRo8aMnkZwsrPHehpTnWzzmdJSy1QiQKjexukPr(ngsiCPOOIkIOLeuMkkYlaziXzBkG)9Q080Q1qpbZqy9(hWnbVFxv0WnciJQk5eKkYur3UOIoqzV3Qav0wkPS4G6Wamp0G(2uiqJCb(MFVkpxdb(JftRFUVmY4UWOh7KfaxCGuNcMAHKYnPXmTkcQYb2yqEphj(sckLpQzR4lFcURG9P6UFkUqbg1(rXApAmqX(nQLdiAW3sizCSPVSPeuc5F0ayrnG5JGlma7jOFFLcIhvTV3xK)z0ETPjhmVeWlQ4gMW6f8Lv1fLBA1VHHO5tVF)6l92TeyCvSufgWgM(RQKkGTxRPWYwtX10s6WqNmb10qH4wzzIGFav6qfKoX2wm0q7ErxgF)N6NIZzztoOD41eLjMdBztntrv9jx2HXa3j4mXNDmLXltJZPqRTXLVZ4u5NzTrpsGg9B0BS2jhDjtnJI7AfeflDZgcDKQjGXeXRQblQrSrgJnoZSQj7w8lRbmP3NMrXxZJRbRIGVHAybZQfZzIsHbRp0zm4ishlWG6Q6yWZhfu1W13eb1PMt9pdPg9Gh5Nc(OoO9bBsXJctt6SrFhikMpnknn)XyN7KiXgM4B0nTks36DGnf1c(kUZPg5fS5wX0ojogYsDMPjdIEHEfewoBlEpy7Ug2)VY8VYB59z3IFc6KB2saQo7itNJkNF5pXS6L2eSfahZX9brc4fiGC6k6MFvAsAC2XWgdzo3Wq(zUpcMLVO4B6d(7bbD7HMIRgMJl70CF9Gkeos2lfUp0)7hOhnXv)R4QiqSSglOrUpq1b)mvR1XfWtVommAFBxxqE1ggKUNme0We3zDyG1(Eh)W3a6KBMMRfRBrNoz2pqhVA6)F3IxZvdS1L2m9mqFwXvrLtcXGvvGR7vje1Oo8PvkJaOlvpT91KBj5DZRcbjM6ElbCHCJ3VHsxr5A)YPtrXGhBYmPYLyzGD0gjCT1tGFd3tGo1ScyuHdj4F5VLInW8TSXeGsC1GZE96hLDWnKmoA2CB(1syTFHdDjtv6cJdVpEpukvLb9z8T4QoWILGZEauAOsvZmv0TFUA3fXhm8rXjjKmsjvBfUlmD6(Lz(uLliUegUnluh8qxqTPtlXWIwtYO72RPO7u2aetn0BTdO1cIy4pqs24BItZGvjZk1CIa1eWJskYRiLukVjgMCgYjYDlS5JhAhEu4xvU(JaO8xGOgo2Pl)GnRdf66A68Gp5Z92QXjZ292GsOGU9vOrIK8IgWQm2(iJSQ2gFc1sp2bwigxzosiI0LIFDv6scthETGuGMuO48CswfjOArQCauJCGLGEkj)LGem6MDvCtwTRiIQbh(gMtPO4DKBiadt22h5ythDP3yeecQXPRObI6mIB5kCPI(HUG89XLBnM6FbMJkcLmIo7)coTqWYztOu3XRiC78xAyfgCESTbmZIzcNEi3b4RisNWzbfyINtRw16jx6EoUmJsIEm0ZuHYS4btk2DuCbsXKHEtOeTfCf4Pa8GdMdUPEa7cQ(ZuyodTjE5YuyFclO2n3HvJH5Qeq1y(3cacKCoSKA)4xi)USBpMT2fcVIZEF8TvQsjJBhHLm8mUjKinEj564YLqywnXbHXa3aC7CHTeIXACu3IrALMdJK8YQ5aE8mwJp2HWsbmQiUe2CXkovdtyHTfzW4fzhEwCYUkROyzgDfpPnAUJdhpD872wGenTF0fD4q8JSzXk(yfzt4O6kC7IECDgyOoLMPk6Q4Lqk2K07iPYgJOwuZNUBXz0zz1ksIiSEwJFGautptULE4MfvuUmhcfBVxmZvnwWAyykrRBpKNTu3dcBpY2C2l4aHUUADmfkrXCkkVc14VOetAdDhr0)TPIAVCNvZfNDeQDM7uii4W725SY4ZW86m5F2KUDlLGcSyHsPqN2Q0RtZyZOmGtgTgD6lE5SNFIUpMNIorHbk9bDcel(Rlt3ersYs3wnmmLxDpGoI1P2Kgiw3BkkYZsRPhnPvBg0Q7ShWQtFwded9RZUD7AaohxvLUjnJZ3iXzuiO)2MiQexWn4m(HsOHZHXv4ILWL4K4RkP26UMq14CttvAYWGoYTQJbYv8CT0GQH5GPyWDLKYIumvHEkZJP0n6XTYSWF7RbXnRqDT)7uPsGl9PcbDPKevqiM3sVpTICS0t5P)lICoDmw25VeZXtG0nJaiWe1jLvHgredJD81ezyda5SzyWQO2xlCpBRufDXTsx)sf8xXajBIbndUjoRHW0kK5XyjlEyaCTnqts4Ayi0ljlHN5LWYkjMdI56kLdmoPB5e20qrGAykXj0(HPJsREdBjLGCfHAuson7w8Jf1YVKbpDM0wh3o7BlO)Yvz8TyfM8M1CNGJF))ZxQEOuzRxIaLPMA077i1vte4LlfaNOBqyt)jQemzzEijFfMCKqqctIxsegiFUV2bxeY7dW(4a0wVLnP12DvlogUKNq)F4MJz(Nw0qe(OIkoNdwDgwKqDBSXe7ruCiTT(uitmp0HgihbPLkp(lsEowhjUYMc9aJrvED3IxFDEkg1eBx9GAltXwancyiEllimBYW19k0kngYurnMmJwymC2fT)cmiCTYP)01xtygUrfnwcZ5R)QVMH6Nc(JcuJhnsq4lB2cRKPgnpCpy(46E(LiSv09wukBRAOmIKgZDI6nrlG)DHCpwrjI(HA6grhuKx2QHB4h7srfZJFdnvmBo60N)5V6SxQPQYzA4tAqmxjkJ0AtqNWSiyLAWgOBaWiHzTZLQe8azmWS0iY8uNrIOzKRa5ZGmaS88wbw9R5ZdLpjBIutkcK)DCLmnkCNje6IMPOmvTetC6awaAQDNHVSWP3I77rUmZKtWczGXFAElQp94nPSPgwqr)ZM486Mnu18Vjv3YdjIKPTmAmSDPXCywCQkZZ44Yjzm4pA0glrOuqhdSl6mTaaD3UkUUoBa74(PAO5WhkA4Vp(DGRoRIwvsPl23ReJr3vSGvaL1Lnj40Se8dhj6kWtr75vKVPXv0JLmDAYrFlefdUG7w9umFFSOSNaxHBwUCsIPZb94Df4HAKHde3LvelpB4TNrpNxHa8537i6kwY9vPQ2vmqdbT7o6MsQIYciLKlUj2LN8)2su16FK2mx7ybRYVJkveyo(6K0ed3q1Q801yNIsz9rLvFiJU7srjlLG6u7kprpZYncIS)J9dJDgKuPSovpRQd6(oIWLFFDAvs62S08yWTTuw0BqRyGDpKPjGBMZz6yRUCb9YRkmIZyluDPYGcBtym1aUsr9O8pNDN7trXjHR(efxsLNtApAoiqNfUBSRJVJKr8hr8UQiREIAKj61IxVUr66K)mXjPFps()BGT6iW)7byRfdnaYc84WuVqXKOw6igKiI8HTuZ4tzEtXko2pEhvTUBYr8sDE0HWY9(j3J)5YydM(a6qhHxEFdS7MU4ra4(rcCYKH6kW5fBXSxOT)Ir3qSXprxLGJHe1vQraV1CJdgKtTmsbDHvGsJqWjWkxTa9pW2aBBoQB4zlxf9eRAYQMSSiQL7njSo(eLbsVRrSkrsByPMY(mLtkL1z7rZtXSLyU7UPLZyhPApXnGFvkYIA7Cv)Mmx26iBVZbym40MpvuSODHsP5Xh70WM(5ClzTZrEp5yF4mhOtppp1VBh6djs3kCPY1qzc6QOiuhevxpeOw7u)ASgKDLLdURtbBAwj5SBvY9ucdD6Nqxh5ifDfjgt0O6Ig90lZMIMtbYOcALMCQA(izW05lwY8QaQUQytiClrsrEDzrwLrYMY9ap6k5yyXyMC)PWq8w26E3IFbw484wZx9b8A9KoW1DLkjjEtkdv7k8Ybu4Jbn0AxNJQUBlu1O0vw)PNCokmuz9tNgrid0B6yowRBot36EZhwn8TAjTmerFtBs3dv2txsUNkX09MRSW1yaRsPmZy2dCNAdDbSKv3HVKiVO7AgB6eUpmDjKLx34bQNl)fBd6UXVNFZnKAKPQhBsk6oNn9LNDOTPqhiFOgtwfJaYHE180GbC8R5P8532c3TwuyQ7XwnSGOIEzfMx7egDYUfFhUAzzAdRIHugGqBhMRzb0XkTmacagVNUuKbvKXnYU8LyZMEAPckXIEEDNr6VIFOvemrePqsP6bRlp4WDs6Ojcuzqu1dcprnDXHB6ADXg3GbsojE7w55Tu(GKTkxsa9VZZjmAEJ6CWnkFlqXTMM6LXPlPEZ9PKADAY7Avsf3((9lqNG4wRzmo46PIjW16YsG)vzrTmxcofT(vYhMNn7Tlqm3bbTGOtzCB2dk(aUb1qy5YYiq69Q(PEZaqFHf7a3AHPhY0aXEskWKRbKk2S0asljVcuvnleCgbVA7unRvewNzGuGe8PhzQJ2b1M0YYIYO0n4f3Kgm3Vf2HLS1MCWA10OKKrp7)FH6QPTujmXC8XjWrwO2dgb)gNexknkLLYVSOJjVPGogvMKAigL9W3t439e)k)6JsVC7oOlEc9qTIUKVROkO7Yz)cJIKfqq5Fux157WZZ7Zf2iQgcAd(wCNNOOsHDXdqG8rNIeFfiRwvBKzgLyIl(adc(Uh2Oc2bAlARqe4FpzD80bKtYhYDM)RO2U3s74cBi59tloiTS0l3O48BX8m)y7YL2iWlQukDM8umGCRIomnzWYTIStEFWGF03bzBbvRVkgLlmKw1KOrQhJSt4CWe3JnbVDVS42f6M0AWo3tPqcgK78ScWSXn3LFkL(mUU8HIkgLwDKWZRKoDwGf3c(vlr72URCFDWPCPgeInDHK9USm(6IC6kNIOwBwmESko7lARVM2AbJP0U5LAeRqFqSNJH8XdgB0Pb4O7ZoN(kXrloB9Q4FcLee(L9yCRsOXAt4wnPtBo5S(5VHXUm1vT4JAXNGIaGuczxgRkBfhB12Pl)F0HhDSJ9HMIC0SvkFym16wfoD3mybxG9TeQKoOA0xpUegvhAyVMzpEU0M0bjV54e0NkQn2Y3XN(yStFF38a(rAdUqcQIcJVO76HPxKccTe9uY7(2lDuJNo3lU8mSNH3mMu9e9Dy1HEN1gEFRZBdex)bXiqXx3LpyN7qHEDNYEM1LayNB9dmDLReZYYG(A7APW4m)XfgRHE0Hd1FOyFwvhrp8CSFp32lJtcCNnX4cCyadbfJuFSuu1zVTIA9En50LHKAZA4BbTHmTbTpT9YhYBSMU3X8OnBD90bJ843JZ8o1uBbNoN3I8Z4IalOBboi0i7DyzFyqrkJV32jk8MoAGMqTKDle6LCSW(pttgR0VHTARvEEfLculaIbMfb)CXpXm5tZR7)QLvOKuwE1lCsFCRZEEMYncDc(FztVME3QX)RqzC4O2YGcQf2qwIu7l5fvCYL(L9bCpANswEmZ3Zxlmiq7sDcTdG5gBXnHn0p5wPsZSGqx2q9L7OetY3n7Hhh(v7O8n2xYaFUESHTfszLS)d30Gd6YBp3hxy1IeOFFuu7iX7BxYEV2h6Y3p2lHr(5NeCX5xtVHFsYzCoVBURopA9Rv4b9uB3U4OkrTfacBb1Ax5jbHC(1d8HVw7YVLtvqMh6MkqKGPyvbJum1U3jNTpPJo1LdmdaZ3t3T1bUg3mziI3pg(nqpuQXhwLuLB4K7P18M5QkEWSjopEYwankyFJG(1UyCM2R(InNw0FC4jn51IcGbvxPu4NuH0xZcpDHq083QAphKvHRsZYqV7MtLaIr3EvRO9j9g44mpmWTvNsq84MgnQ2UU7I0VBW0ImNq5DRqHPepZ2xuaZ4PYVtj0(wMVue9GvgjaXUrV6WtjAzvNYWrf8qkbdwU0mgJ4obMnJj6m1obfHhWfekjoZnDahbC4UoUSqaUlTzeSNonwvCL4MiPDTH(vgVNzCyxVOt23rhDEfByYMIx3rLPljnilv2dgICkSAXHrW8W)UTindRtNCswnfjVPsHLIJgDzVlBOQlyviwd8CUqBsCFqkboUB3LgW8bKcnbgJjRrUEXz4XVcO2SrxAsYgkqrykGyju3ySiEFnzt7G5UzxQhYgU1fL5Ww5g60QSd1)5Agv4n0bfAL)Ken9LqjSvMtx1v8lGOuavRMBVYN5ja2Fgu06)ZMuS2Hzv)yCdfKgJQ1ZSdOAYU38)MMtBcECB(kw8bGM)mxcw)mgBtNTjW4P95Wt(Wy8LZXXALFfpTxwBAuCgRnNuJTRn24IVDsQdSVQYvm4Dv1UDobHQJEXK0NATVZjYBeZmGt3)POylH5wTkw1W)zhiL8LAvfEJoKPnUZAx(C3Tjvv)U7oOla)D35pNCgDWH9bKE3DDcsgRmn2be8c)xybF6NEix1qHy1Joz64XIZI)eY5hY5gW1IvAYByVtcF6J8emZppcTYf1M9GZQj1A4nbqHRHj7zjuLoznzMaRpQtMRsSZGDNZYVZAGF(hZDXzFmNSx0bpCt1WbkUrmkWWvk1rhgG((i(ieS(OEsVZj)XFAO6m6PNmVJQH6i5m5QsOcp4hAbH4Te8Zg)PF6jJcaGMRXZtCg)hJdJN9yEyeEW9Eye8ZgpOZIwANx9iQILtDLLP08ErBzfRem1Jp1kdK7yL5YpbdBr(Ihjv6nhxp2NBZgTJr3jyG7(hUB9ggaWZP0EbBIndEepA5tyJjWRpJ754B47khhIo8SL5yBkbEFV29m(pW1UtKeRSNAy4jp2qItM6EcuJCUXy7kO6FSg2hBKAFtWdWpi8b2dhV93k)L)BAcEWGgFkY)yqnQi5cR85HrmEIFL1L5L4NzjAPnLf9bznh29dXYmp0G7nmctZj2JtWU38A8Cdg2xks3KDlWxrBAZq(huSkntgnRQjsTLo68NzwYx7EZN8j7wq)FFXp9)UBXFNR83Uf)nmQr0nbuac4RDfSmJHKdj)P)lszbeoNSgcR2hH9ABAylwsyHei1cAhVsXXumbESfOBtkSAjBKTEsQDMC3qasnkptw3xQL(lY31(jSTNlaHqp3JbVqFo1ur4puu294ITNtrojDdHy3tS3iBOAljbYPewQ1WYeMWpUIlTlf2EVYvDXTYQN7n5ZF6jhJNtNZrWSvs640vNRLNC2J28PpeGaEMK3azjb)w2Lf7XD4Lp47xNcziJw(2O)I649Ul0eq2ByM7KNrdq4UlNpLdnp9jc24ySg3gxNS(Op)Z)8NCG9V)4d7Wu96Rmdz7qaDQH3T)GrxHXvhk6QhsGifE94dB8JxPuB4UQM8EceueB6dk4Ul)(exshe5Tyzy3i1S6WrEXzlVKo6nWZiPX1GAgT1cUE0HbFbkJC3IVPn5n6nHuV36Mz1H2E3SX9kjdv9OekAfEXSaBhiBtGnqwX7dbcCi39EVzXmCrkJ65thIW2ECaAvnI4nb9(Kux33F(O2171apeP)flNMz(Bdx0Owv6joRkYOXfEn43A2dYt19zpI8T5o7tEwnDYPd5WQ)eI8fABkf1wtROAJQeAIKsEBS8(iIV(OBXnWTTzV3VUCTA7M1ER(6v2ALYvEeYH4QK1KLnSRfjcwzcWku7nNkgU8XvEYz5VUpKHCkz7BwoQLMhAp6KPt1qnT1YvUVq8n9hdHypx7s3lAhGBUy45R1LxLmHLTotoz6jVy6lpBYvu7oJyVWcIf2VjuHM9EoG4rqSGvfibo72(yrEBn031OcUplkV8fQ3Rq47Ut2K2ZlIYVBM9qkn5iJGuA1Dg(O2b7K2rPvT0Nrcm)EGfpTJxVtwr3UeMvlV19z0E1oUY9tIRjxxaY)BVDDrmNAJlUFnjg)399Sq7M9MFomBQpgT8RyK34ACB4xUXC8qLleey0oW)Wn6aV3vjJouQBwRbtkbY3TzuJ71c09DicUw9(ad5CCvVLrC3ddvV4oTNNZMx0LXqUhtzYvcEQ4tanig4lsNCypx9EtghRF)8eZ9Fb98pFI58E2rreK5VjGAzKLNJu8uPm0sJounCBmKX7UZFcWmhhs7xvUXQRcwk5clbS3gVLCxirXDenyFHqvD4L0UkPD65MIj04A5ihFeyxp9mNdnoMwVNADmOZBB0Z71wOi9ErxFCOLAaoyHI((CNC2vVcppA2D3PJbey4gpYzscCOxMO3DNm041bFH2U45th7F3R(kO15z0RgWgY)uQP7rNZ5z7L505ZBMUav7m2lWwW(jlR7nckt4pF3Y04H)NVBz4CVxE3Y8JUAQpyxi(pwPQ6difvdKAQ3)us9tpulzurc0)t4bdlGWqd7nKaOoE4WOh6bWNgtLJ5hNWn(uZwElkIeB2owvIOjATIiXoEkWU4m2H9JW7JLkSv5vdZe8ke)4dSmcWKNFMpOtVOezcCQ)49AC5hVk17lBfaf86XIr2jgiOvuiY9wHWA2KRWJq73ppKYrSiziF5RcVuVFAsO)Kw9ymdPUFIQEmMkRhEQhLjX3RlL0QPUENQCn2vDjtejMg2thL680(sAatKNu)3Jna9XySGYaN3PPkQxlvmwJ7TN6jngIkUirho4k53hjzNdZvGNEfgCRRNJOrh4TBGn(9jvRD8AdDrpwKcTFdFiDMgNixbC7pmGlv0PpoWUrcpCQvyiJTibHfW(cuYShvUBcawBF8FEiq1hd4MneYbtQ7pikm22EbSSFbgFcee27)RvKk0umvh30E7iD(j4FPDdHr)nzQrPFPFXdKGtPccQQF3u(i))8A5rxVE9RieR4XHzKANEeAQllCEycYBPkvgulpN55JrS)F)9S58Oqt56cvXbnL9L22fN(e(DmJUgJ2Z0iVESqDhzNAgUvc0l9oGgfyvawm7(6x6U7cFlADrR6HcwfgVIpCU2EUohhZB28wjAuV5PGiK)79HHrt8Oe42d0VUqocjrB6i2jKRyB6kffhDGDOO8b8z8knVkaLO(TdQ5nZ48Pto7U7SfYCX5ZyYn)ZxihhVqoDl2qn47Qz1JpobooQdIlX4QVNEvBcqo4GaWTggY7yYr2CxN7(t0FBB6gMAvQwDftZPon9wJpn7Ur8nYFJd8ffn45k3T(oYoHtEa2278()pSEcQU1YyHs3lSl5(7J(jcrdk3T)3D3bEf0nQ1)Xg3J)HcJ3aI4hJZZV3U19da61V13GJaFLsJhFF6MT(yEVnVQ5V7ouNLtoZVAaJ1LEWb6s7PnQoR)GT18TjA3gk6clR9NZz5Dr4or3XTxpAD3v5vFMlg7nB7CaGZiC(6SN63sASmydtfP4LllYzHRItcKMFtbCz5bA)WcXbSYGRzpz4szcc3MfFlpZKf0o80xkzDrrfXWrO0pAdgV0kwE(yKtJEw4SvtKyXOe3eM(HP5RAeUcdHG6)mNL9dAIemUa1zRA2SrrJC7M0Lr4BYqMwIel6qxzs0D35P61hpYirK6CYA6tc(0)rHfabJCcDGFUJ8gDGJG7ClDOdsQv(NoWrW5nf3ahdJ8C15xJop4CmP8QI(hnlVwKosbvrXAeaMoXi2kLSm5DEvOm4iCFuQbfjZJVTesi8GGTKv78pr0hRISe7je0Bg7hZQja0LfvQhzrX7T3ScNkWizsWnFNU5rU7CbBfQk1ATRsoLBQIZSPbxjgirodfpSgG7Y7jNOyU5r4VmZ6xov5xOgW53BINpKfwoPbyDvDBoD9aOjRbzrDPO5fVGzJYRbf143s1urs41uTI6AqX0ANf4hd2HbIWQAk5sHO24G5VuD4tx9ReyVMB56E1E0bC4LXBHI8IvEu4lD75px4djp68CpqlJ1uhtMRzwf)bDpDSmBf45c86u1uShhjUcUDbensjBNqWq(ikqJwEHkqF990GC(0GoeTDOnyS5TS(cJrjFti)DjOi8bzk7Me27s)(ahNpBKhnZdUwy98HTsqcGWLqS8HKqHCa9jD2gma)RsZtRwJjaJmDF(b0kwE)Us6kOmiitHjAB5y1lFhg4wB)C3oRiyOmOFJWdYMV0hJC97eBJVvL7f3wQD3DNISd9xAMrUB5Em2oEqzg5PP7XOB70t1fFapI27zG78Jw5dE(9EpYT(9aXbT9FjlionHF(u4zS7MMCiEmCVLYClk2lMNClk30k7OdXb7tpK7pUfEWK7mGgsXUsFk4IdkSndH5zNQ(uM3C54wV0C(CdFa6BwLCy6H(NCOY7c7fthpFglDv3IHTq3732(sNLRERtH7sFEAHF7GKSFO7THx5MkJOYin(U7oKd5t1E9)4EA0g(nEOtXtp0X91Jm7HvNaEc)(ZGXX5a4BBC578BHsSXTZqjRYIa2)izMwTBPwXSmjlCPjvYmENhvI46MsMNuWRTgqlxZzIIGaRpmxdQzPop6Rg(BKcKvM6BIWNSLS(sX7OD1T3Ogn7jopVDJAEuiHvZ6VktdeZG5QNFly62dFbzN4bJ4QYucuBBGErT67wRDzqOBKi)qgwcSrHsacCwKNWSlxcPUYlEnxjcwc2MKcNtakY7JtBpcrMP6lc4mEjom6KY1Im2fJAflPWHJD)EutaAHz84ksY5tNm9e5XChuWof8OgPr2zKTN(JqiLxTpzoR9PH)yK7p7jCEUUvZynCr3hNoU)ytU3U2469Fe3A(sznYj5WqbPUwsyUMM6kaCozUdyjmQgIrS9qP5)eZmvEGZvc4NSccArxbF)2uRuFQmVWaZYxu8nH5S0DUmaskJB1ku3xdsvuD)eJo3DRk5qKKnVvehgpY1PG(6DUH7T29MJAfW67UJH5hPQbjlDVzfOxrJgwTU)nx0MsBFSFUFlt6H0pidf)R5Q(rpI4pMDmvz1Fu61V2GsZDNdFHTn1TYPJomSoOZv0bDy8juI0jIc(lNof1z4yt6BVjbtBcl06MTVH7MnNQmIi(Wq2gpveB3mXii5d2xBoDRMsuLNBY5qexYbRbY8zYZKoDhhxzd2YKDHgIsBV4ehT0SnS0OqUuXhUpwWjMpfuTLEG1bnEejW0tZTLkSMKTTR0KXrk6WcYNOq5zEajNiVatimfFiL3q6WVh2N8h42JQEJv8JesrpPY7(GRnRSpx84ZT3WkKUXvQhlAWU8vrd6YImYQA7dFuvZyhOmWVlWyqmeSKuZDvHxhZnTrXjXKSks4tCJqg5zpox4aCdzyNWVho(nEQij5yZbBS1V8Pm94(Nvgh0UQ9KYv2oWyOUSWxo3POYJlhHDHIP99WZddbr)8tuYbhJSQc16wMsFT84C9eloFMuULePuxMAC(TioYX2UDYi7a0ou6QAZz8fAZxpMChMvcg2W9DqvYsy3kxLSH0s7zpxai9hLO1NwDHmCVoRe3tpQNbJcCSOH5e8GE0Ho58kDAMhHJx0EWpwnG1wPy35pSRNNrU9W0D3nqVcmoWs0TjIwJXGhbp5yR6pZoT8XhayKp8fU10ga3cc4S9TvJxHUXHme7HVsD(gshCq7lYv)T8jOTj9XSixlZonpOdRdS493Md(NjJzCW9KW8A(a3(w)oWZSpEWS7n(IsoNJ8)R(pY3r(oOBgAezCKE5DlLZBCugD4HEu(b(2U0lIvYbh4Y39bdn4HEARpdShDSGix4SMHgC11WU6g66vnNYV2o54pDSVY3WGQxjKyEuj9a3JJNHz0bbeTmMhiLFOyjCBPU8)Ah)5wGBTOwSmq9YzfJWAEj9a9tsEu1b(CVCiBFyF417lDD7b(yW2x6aIo28wgt7pdRpWLMK9wd)HTkCArFh(CzwVtbQ9jahPTM3fX3q3)(DEHpQpj2MXdTVIBGKEzAORMHUycNQjhoO1QZceBMNch7KjNDFWtpv1GKqGM(LOCHgb7sAqNRb4UI(HMoCnEDDbqym7(Vb2hTH)29hOp4TAUIxLFmFR93pk37S4hhG8c3vdIOkw9471Gl8uX7VpCxHF5p(ItXh(7l))o]] )