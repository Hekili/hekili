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
    firefall                 = { 62197, 384033, 1 }, -- Damaging an enemy with 15 Fireballs or Pyroblasts causes your next Fireball to call down a Meteor on your target.
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
        max_stack = 5,
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
-- actions.combustion_phase+=/variable,use_off_gcd=1,use_while_casting=1,name=use_shifting_power,value=firestarter.remains<variable.extended_combustion_remains&(talent.feel_the_burn&variable.expected_fire_blasts<variable.needed_fire_blasts)|active_enemies>=variable.combustion_shifting_power,if=talent.shifting_power
spec:RegisterVariable( "use_shifting_power", function ()
    if action.shifting_power.known then
        return firestarter.remains < variable.extended_combustion_remains and ( ( talent.feel_the_burn.enabled or conduit.infernal_cascade.enabled ) and variable.expected_fire_blasts < variable.needed_fire_blasts ) and active_enemies >= variable.combustion_shifting_power
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
    if talent.sun_kings_blessing.enabled and firestarter.active and buff.fury_of_the_sun_king.down then
        value = max( value, ( buff.sun_kings_blessing.max_stack - buff.sun_kings_blessing.stack ) * ( 3 * gcd.max ) )
    end

    -- # Delay Combustion for Gladiators Badge, unless it would be delayed longer than 20 seconds.
     -- actions.combustion_timing+=/variable,use_off_gcd=1,use_while_casting=1,name=time_to_combustion,op=max,value=cooldown.gladiators_badge_345228.remains,if=equipped.gladiators_badge&cooldown.gladiators_badge_345228.remains-20<variable.time_to_combustion
    if equipped.gladiators_badge and cooldown.gladiators_badge.remains - 20 < value then
        value = max( value, cooldown.gladiators_badge.remains )
    end

    -- # Delay Combustion until Combustion expires if it's up.
    -- actions.combustion_timing+=/variable,use_off_gcd=1,use_while_casting=1,name=time_to_combustion,op=max,value=buff.combustion.remains
    value = max( value, buff.combustion.remains )

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
        cast = function () return ( buff.hot_streak.up or buff.firestorm.up or buff.hyperthermia.up ) and 0 or ( ( 4 - talent.surging_blaze.rank - ( talent.surging_blaze.enabled and 0.5 or 0 ) ) * haste ) end,
        cooldown = 0,
        gcd = "spell",
        school = "fire",

        spend = 0.025,
        spendType = "mana",

        startsCombat = true,

        handler = function ()
            if not hardcast then
                if buff.expanded_potential.up then removeBuff( "expanded_potential" )
                else
                    if buff.hot_streak.up then
                        removeBuff( "hot_streak" )
                        if talent.firemind.enabled then applyBuff( "firemind" ) end
                    end
                    if legendary.sun_kings_blessing.enabled then
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
            if hardcast then
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
                        if talent.firemind.enabled then applyBuff( "firemind" ) end
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


spec:RegisterPack( "Fire", 20230712, [[Hekili:T3t)ZTTXX(3IAhttAjtlkzzN2kPzstQtD6RPzICE53ejejOiQbbyXhswD0W)2F7U3h4(gasuUo9Lz6KArCyV92BV97BXLtU8dxEXIOQ4l)HJo8OJp8TtoA8K3EYjV(1xEr1DBIV8InrZ)y01W)ilAn8FFxsb9J3LMhTaF5Y86I5WpTQQAt5F8vV66KQv1xnEE(6xvMSUonQkjpBEr0Yk8VN)QlV4Q6K0Q3ND5vUN5JU8IO6Qv5fxEXfjR)gaYjlweZgEC58lVah(lp8TVCYr)XTZ2o7VNKLxSDgo2TZQ3GGC82VF73lh2eAy)yu18vBNn5WXtgFIZbEidE)Cz82zlIVQE5YXLWywmUEZ2zlX54dXR3KxeLUD2VevSr5Lp5Lh(vSxMaBjF84KDW2zjzZtRxKKD92zRJYUB7SBIksIUkfhx5QKLWCaVqr(6TZ2uKKxKubJPkhFXQ4ImC(MNVqfzp(LhDiBXNViz5DQVhnX)U3NvwfLv9Y)rwk8B)YQ4mCS3a4WVdMZ4Qk4FPdV3sW7NIxNFdS(VyEEbsUohiC3vKFvAuz12zRIkwmN(xLZJZGfrUcmETGa(tX3Ku6fg46A(Q45FC7S)Ao83xuveh9XXxErAszvjYrTeyXaSVaw7tX)9u6nXh9de7kmZaTBXL)5lVOUmE6TRssJNIOfSMWHqSjfjBqgVlV4xWhdtj75BNHmWxfLc0uKqjrSdqAC2nXfak9xJJyJ9N3WW3inCDpGbDod4nO3LxatjGXjrxEXEn7WJBgX0n55PeyhSDgmeIbBvE10sgfa(pZROhoeMrAcO3gr2XXFkEEDv80I41rjzLer965lgl)77Vx(sBeRj(BrZ5icYS5KT8MwVrmN7dBTsezA5M400YPjztxMMC9k45NbSYcmBoSkwKFB2yIZfHZM8BJlqqT4ogEmh4tUoMHKty)enXlJJtNwTcOh1fznO(PBND02zVGTGwh9jazVScKkySx3l67oyHwfLgNvzG0C8Pzo8VMS2EAHYXM19OJNtVkpRUCCvsCXXho9OnZzqGlvcPVf47hV(Q4IYXQmfMusKyshtYxUCk8Z0bexSVAhAE)YTZYqoE5XgqUv1k4FbNtQXd34XOTZ(ZnNPRksU(64c9tkWHmsaucaV3bukyyRWxdOvWpwkiYibnkd(p3MxNc)FXFAdb(RIbPzX8x67(MVfEs2Is2jxeKxWjKW5yKsYaz0nrjPeVbWfrlSLr1PvUeFiOdZZRrjTe)GbL4VWo4HifiCaLlNSwGrWRNBpP6mQf1z4I464XlskNNSb4qJkUBkOEeufSqWp5IFxGC4eo9wqFJbM9befkJbPwaY9bcRqTsm8PUSgeBChscXniyldguY61Xlsa9t4dYHDGn1OCWBbn2M62aiJ7PRIGxob5dYxJhObMOg(yGKevKcSOhGJeN15rz4lUogX5sCYH)KoAHZ4T5fiNdUXTiN21W542eehiMnqSpSrHQ9ac6Ifj46erOMf3WYr4CvKxF9Q86k((qCgFdC82zFT89sV7agUxUIXvfLEB0DCSIrqIAGWcCXX)RLmHbfXxd67aT0LSN9n5RVQUebocdAbWp6IljCM8ZjWfMuXjY0(PMWKHoS5GeCMJt)aUTaBYtXNoLWWPQsBOx9Q088fPaooErDredtjzPh7vwk9EBYjfhnV05ksyj(VQCKLvU83NpHn)M8LByCzqfN(x7H1(60iKFe4lMEv0c0iZgel48FUqz30gMXxUD2jWSSCz88QPmJvTGpGlN4bxGDM7GTZ0P5flYIYM3DK50ZuOwwGz6I40iM492wsTde2AKT4Sryy19gpRUYvravc4CYlUcufatEXAGHuDnoSfeuBz28GPBkIrTetzcg3NubHCU28ObbVIbkQCv0wRu1y8)QozZg44bQXf0EbtBzY1jPgkynE60JFZBp61t00t(6djnJmsPpQdqqFRpw3IK1tJNNMSPSFCkF1dG6iWtTjfqUVYdYTohu7MawevKuUUxy3jpcStFwb07p49y)DBwH05OsWLWKuUCd3g4b)26PGky0(fea3iDf1nyG5DYH(OlrZJUcm5PCvmyJ166YK59J6ixQoaeoXMgyyzufmsYAkqRemP5jOANSxswuHl0dA0sr)23Ikyws2c9)c6HqdOa1ELjlInvjbQ((haBFXTGRxhi9hm5FhlNthWIP5xvVwlMRj1yrwRfHWo66yu1E2ZRyAwtZrdoaNil4VDJwfDfSag)bYQbqvFjJKSM8l7MO06yUrL4OBeXJaW1YGCVLBtHWsK058ypGO18iojMBDugk4ewYZ5(3vwwZSQtyVdZQKglf2exG6vegojL0SD2pKxjFtg98IAye)nazEEjAHmGKm7MfZ(gqLEYvP8Ly5DzZfyn)9)B)z1nLsBlreSmGn3zFmUQCSGVCHG4m9gI209dvcHSKa4KSLuChqVQNhTiEm4oo6W(z(Eo4RXu(yqXh7rotVOoPYEOswiCGU0Na)pAXX8sEOQj0L1zt)iqmb15CYQo44wzfAyJmMypQIdzT1ZWGCm0Hfi7Jr8r4ZLqMJ1wckNW0wFn5exaMRUD27Vod35AmFTHzKSpg4wqlcymElYJlPtGeEdu8ybZuokuWbhdxCrZVGaHBhU0vo8mj4RjoNVh9(cjojyOsqd3j3cIYurScMHZrljeNc1L75xYWwcRTPjSLQHXiYZyRUdo9bg9d0XP3c6wQUTiAtPUV1TXCpsXiIUXA6MrxAwUHDk4VpYLHkMB)gwQy(4Ph)6)WxDYB1mv5en(jnkgYlzABV0Pw0MW0PiMAigODcWaHFUNknj4rkyG5PXuZDD2ren3AfmFghdqFnVtWv)E(8aYjztelMamfbK87iuqlZY0XezY0heDvZaltzZHj(5GRIbbpi0u1qkoo(pRlRu599OxM5Kj6tmk4hoEkz9HT35f1vicn9FvhLvvVgmZ)MeDppKmsM(YOjW2LfZHfXPAmptIl)iJH8rJNbV2HASJbwfiv3N3wltbAaA72vrvvP9yf3ntdnbpIk(Cn62Opc7ZWKSSaoxSRXedOJiIpxkaszvr9CAAwKCtsw80ROasTBXiFtdIA(COa0OsXwykaHQv3PhU7Dbszpbi64Zbc4ipmhW27sW0sMahynLSm2kYgEh50xtNuKZVxiIrMZ0FIUAuvdgJNHWNxsWZxCibEeWN1S8BImKpr5K6DfKP1)a84T6HC97aTIOWX3ppzUrGNAmE6AAqttyJXkq2EC6UndLSmcQvRRoTJHrqKYd2pWsjGVyKgiaUFxSiiFFRsayjr0RjVyWvpMpqmY2zmBSvrx0U8sWZwpu1qr1LOHsv9K(pNdVjba0oHRXmnQa0Nh3S1SxGbtwJ0HTV9BYZeYADvEA1yL9GZ7eY34Exx25prSt6pIK)xdTvNb()meB2QH7xeszrzCS0o14suZ5igLyA8N2aUXNWIMYrMwo90Tv1eUjfktWToIwUZ35E63xgzi0hzhiITPbtpDe72px8eqC)mroz6qr6PPvF5BaL9XvnJxaDd1g)iGLyGHeLSHs(olz)EtyCOsUqjuCiqtRJ5MGm3HIvHKaz(xhZZzoA)b9m03M9BNE2ivXiPYlRttNcEUxpNnWxOai9HoLLLvnWcUY(kLDkf8SzR5LuUYp19Wq)(KLbW(Q(tCdgxL8u1k7OBtMlFDKpVvamcdAZZeP3VnwkTi(yN)C415EYAx(bEkkfKx00W)Ee55d9h2HUCePDdUuLAOmbotbGhGOg6bG5JBziwwpSI7HtYuF7vrSezCKPJhUlSh7ZSYJZUnj3t1HSZdQOlwescqzCevPgv51ZxnwenkNsa4NyzNAA0(CSAbDyiK6RxWIcbzERyrlcJX88SQI80sJA1GhXEk0ZriYOlz7ww5sDbdV3o7diIZZSnh7deL7XTC2a3QnDQZWJnxIlhgqIPiMeAhdCTVpstjMZcVQZsivtSQ6iPCTB6TOBE5EXW2Mo1dL8u3awVLfVoHk)k1G8G1UhHatPGJGE3(rPh6kLCNktABvPg7HwvzLc7DZuzxcBGiLdhFIwjJPP(dr)JEy1VeRGh)R8YvKOIVRbvoWKP3oe74XJRXa3eHz3rPKMk55(chq8NQOchXivzu8gpoyQa)2A2PR31q3TqQOcj2WsVjf)tCExWFBTS)9De2YQ6favUtdaHwoSGMISJLAvJdsmUfqLMIZIo3BSyLZMknSCdAEjftu2CJ74vryElOx0k3IeJui9hDqiHhE4wp6OPCYxTNI7OMbFOdfF6xFdLI35rB2i3VLsILcW4YCH)ollMDM3OY2CZY3quCBdOs5FI0hh6xo1N5JvjZ)yJ5J0Y3Vh7TsIB8ZWyJRJMmG1Y8cu(vrELml)ht(LkLdtfBSkcsf)hAFcmLrnL)NHRUycZstJNxP)QERgpFjSAp32hPNmZazfAGiZrIYovHBwZCenvfcwvnB3DMBTk7IaRrfwR1guGsVPd1qJ2g16KII8IPjRPlvGgn)e1XTemPyfDVbmg1BuhLSwNT25v2eeg2wAXeWlrnhB9IrWIk9Y6I7mgvlLuNMr6kGlUOmU4JCBH0im4(jnBHOkyo9aLyug2WqDAtzCIsnLZSNkqe5SAmj2ZGywqzuMIn4gD6Nku1Qa1nLvj)1Af7z6BapngfjlIRjlgUMXUkMcRNuzxksCE2n5jPuy)b5UGvZf1LkhlC8Wkhfxeduv5SeovJx8c4rC7bBioUFELJIgIdqGAEfAq1kY)HOuvRoD9Wkh1vaduOsiGqSatdf7y61XRv8MY5JRCKAzg4wLxKHlfWfNCLvO(ptNbzQHNYy9CEbo0vHPz8QWx9ht2jKU0MIj666PxbpUxrxYkFNkaYLAIoQumGl9Qz(hoOFdE9ciD18YCOdUJoq)IASoUkoVqzz3wPy27kauJcXMUqkCwahmZZamh4GRwzA6ozL5xNg)juox5)oc9V8D1ykBywQQMBD0TuYyvg3Zby5HHWM8jLGUpJ776L9XvvCh1GCLKQbtsVxww)ouns7D1VvjIO8iJjWKtuCNv1sb5(1avEfuCECbwitKpqQx6a)X2)lV1AlRgFSxKKiBli7NWinpPBUbrMUsp07AgxtYvmTJb2hP(q27Xk1P4I1jrkul1WB3mJHL)4bEUmDQDRzchaa1h2iVGnp2xHn2o7ipiIFgYGisWB1ftEMT3Hkr3lmBoFPSzvECwYNemEs)38Tw8Nlh)Rfxbm0d49BUxq23YpELfFlJTew2KL7WzrH6frED8pa6UArhPyxsHgDgNrox7HX1FSW)mGlAKrtZl3X7sMwE2HOb6pACTfNq)KgvRMgAgrvLZNjnHi33byNbWRrBJMmhvFhWHjoj56kQQnRMJ4HpTbV5RJKsM9gPEMB5jR3uKFdO1HfObnziCpImhstTr6zagvnTNa0CSPctNbCDVMi5WaUcHLtO8ZoVxhcLRnyzVyqjVJ2(qVbQIiKsbjuO9g8rLR((aXvvW8YOkdOPsmq5HZKGhEAbzmOC2(t5)iRWr1IK6pBD)wJtyvXSiWRrnxJ8xPC12zxnE20RzwPA2tYvGdN1wMsfTKUm2P3M2Yy0PBudbijEXbS4jETWExftA5M5YcnP4k9JJtUuk1S6Dtr8n4g34jCMaLduDv4OKtsvT0PTAuLt)JBWm33u6bTFrPnVY5k0vnD8oDQUz(9juyqBYeoTDzckbIGfAtxoKRP2OtMY0MCa5gIGqyREHOmmiRg(hhuUhP3fbX12Uh)hQi8UVlQa5KcyCcMZkWHLXNOa3U3Ydcri9vg1bJAo)4Mi6lvoQb6WHFjGlv2vXS6PYqghPWn73YllSr1awZIuJO2RJYIgVb5nco2P44Aqgx17M3QowvUKRyweNHxlD8CiWwuvQCJVa9fxZY(vUqlX7uTahlNOLjPPulmidegtjpBzJwMXDM44mnVKNI(lI5WowRDuKvy9rZNhdiBewtHbCQ8iTyTlSJufjmJupRGqc6AotWUV0irN)lN(pRxid9BlUi7fuxfDnzfDrY8pwg2hzxhEAKbeaz1ILyWBOc)2AjtLXwEvEyhDl7l1PymmlMmhjEfUamQMUnnkVfJpLY8lzafF0EQ8d822Kp)bMdx1yEQ5NQEOATJj5rh6R0IAY5JdhXf4O7BwMPTpGDpnMPsvZg9Rh58xpw7x5LWWGwRFfzS1DJro82xSgYIRXm1uExgmqKhCfMJOIohkAGK)g507dyoCy3J2kJ7vfgVwUryGasYkmLO2IAAf94LgwVdqP5OyXYAQ5VGgRUzdDVKRg3jZ)2ZxiBumr4HyLOJOf8a1e3FDmVFPDOVrg8dK3ZnERxzfrRfKvAQ5UIyq(CjCQLOi0Aeyupj7OgUFarTHE52knr9PkOcsJWF50jRFTrJ8O)nGNtExxpoknEIXHg)WEr94XLo5RuBbERBou4fz7s((gOgHlNbuX1ZIDNgovLDiHq7(qROUXrW9C)0hX84lEEEE8JyMSROqZfvlLCyVMnEQt1vB45z9CwceuSM3XqhGlJ6umNte3lfncK3hPRPlo4YKSKYv0DvwExP)70IGpURK1RxkElmC6cFBNI6qqQBpGQEpHeiARQsvTczAGqI3gxS7(sexiVmcfoYB3Ghtam23BezFbTQ0AUGSsSBKq8BVJ1k6(kT1BxBNS6lVLGSY7(lRRZWydI8cLChhyJ6DI8D2y1Y4GH1WVvqxSHQ4w9ky1UEy3s36(vjO74IwJQMTp(tuBB2pOCGwllAnzs4bNM3h6u)sJB0qZelDHxjvN(tuIZqej2tkWcZkdOwBIk(OXUYpXEgSLGp0VtPrgXHUGDj0qjoelMwdkK3friUrMWmUaSszNdIxTYrv1fSUDyzm3RcZzcoHH4hf1)kwliIIxhpESySw0xebTuMF6N5CGh(i)NG7qti9OwcX2dKfZNDIpKuGAtt8bD)x4JqzwWxQO8LabFho6dQAfJmXOmULhMxo)ehLSTBXsiRoBlZmhtK8YFK5Ukp8GkLiUSr7W6jjZtIspaxyvkT6tw4DWz5RZ)lDH)DVGHLqZyvFL(WP(gH2faSBfAXiD7Ov2qTVKn(BHcbDGoC0R2k6)Sc5waj(NaPQm5d8DvBzBuXqZAAAKOL4pLuYyeSEzMalr7TDHAoorrC2BA7ApmdQFPFvgslUKw5ODn8eV4EW4QhPb(d4B)t8NQZbh7YFvRRzVeNcfGnwMhigOpC8HKcWdmfJu6RgirmIDRCAIr3FHhJoN2urx2jeKn1KjEUP082)eN1Xa1PvGRNAlPws18RwOnTPNkIa7W(hWpf9PMjiK1flAPcV8eIBxCTTKxf1qPyDN27eNcvvdwmg0wQOr9tCcgkRwfNUPT7oMJ7TgROCfTczMhNzXcgpKlzEEwzCbCcXSJzhkQUTRe5ZhtfTv0szS1jgaL)cfhBvsckYiAXqT2Mop8t(cgTA(PS1LIgxgJE0ro)jt(jTosJxwzZprwFh5GlK((DWzcjMokXPzU6NAI(pVsOUJtlJdAUJ65B5jBxkdXCEx54g82lq3q)sMhlAefuIoVbe2Gpq8bpzc2EWkYGfrjVDUNG37gHFkpx9gE1yHw5Zrti)x1juFzK1z5IQRYxhrfXdRQFaFK(()Ne06d8BYX3Wk2D8Xp31N1GNZi7oFM4OfmMHt(0i6d(HdCL3L97hUnXa3c3Iteyz3Aekn4Bq6G2vDYGo48Aqzc3jMlcFDxrbWBR7l26eeQ1fytJ8FrrADI8EvtmOtp8PiFtmZSSsM0INVN0y0eRUP2GHmlRC2dkpZ9ZKLt193VxBe(7V3)n4CWEd7cj9(7BLKmszAStvW5(B8Sp7zdzcwK52E)jhoAKyV43OC(PCUjCnCLMYg25hHp(jEcoYVmcT2(NT4bNDfqlWBsGEsfuBsS(SozUAvAgI7C2g1Sa8R)CUko5Z5K9MwKHBAJeEIBG3anPu(K7pmW5795qiyFU6fnXYOLo4YONfQFr9YjN2sxTAF5m5QJwfg4dTOq8Ne81g9SNnzqac0PAY8e7X)6yZ4vpLBgHbU3nJGV2OETx0C25R(mzlN1eTlTLZPdaYoTXZ7Lla(CpPX1hdeu5jDeZumjrwvG9djFZtKVdMW1thyWMrOfO7KmW92LxeA9Ja4zxANWnXMbp6HTI0JXe4nsqDe(g18SJnrhveTjSnv1VRXDpW)rI7ozsSUN09Jp5PMs8hCdF1KDAaAxz7(ZduTm6FxtmM8utTPVXSFMy8uestxcG(X3nXVbWYuKBlf1QojSOWMGD3Wz4JUU7248OWAhmbB)(3t7BiyFRi5VBNrF8EHhJTnN45x(dV5ym7(5ltsLbDUCS0eH9p7vMTFRTFVRrjAB(hG1r9zQn0QdswE2EHI6G3ET1GH7zBkHsOfuJ6QIjQDcbD3dSiC17NUoNWvTlz5Een9hl3pxMktCp73VDwV)qMkb7zQDxFATe2XrA6(Y5Rt6FA7SF7RtQ9xNu52lWRqoWGMsI7UUmGDWqJU(193JFysh4pMBNsd3(ds6i15L1(1WjLgTXNH0Zd5aQpV2ubV8WPslg7mZomgo7HcROGF6LN4e0emT(uC2cqpT5HE(uFgY5YZB7LdHQberfYHFfmwvtTs3FE)JU)EDoGaGB0aNXLyOxPK3FV0B8QGFCpp)1hoY)Qx9dOzR7rFvpwq(NsTVkMToNNStMtNFzm11yANKGalb7V2LTVqiTa)2N8YF7tE5t0N8s)SRMg81gJ)tv2XEezflq2WE4zb7zd1Y)fDa9)p8TMmGYqdhkKeOw(MtcB6b4Ngb6X8Zt4MFISOYqLy9MrQAenzRvuj2YxrYZpHTz)e8PvuL2Q8bN0K8ku)4JSma5Kp9eFuNoDsKPWP6Z3hYr)8vjE)OiIubVFV8gyNlc0QOqh3BucNR(HAurgH2VFwiJJy1GyU4JMyyu9HzjH(xdXNIziX9x3WNIPQ08Bw4tYK47dtO0RP2(eh6c2LTPtKom1VV6GQZtZhHjCI8uTbE8bOloJfuh4PT6QIAROKjACN9vcutGOrCtch2KbsX54Cf4R2fJU12xYUb75DyGMLGKzr2DD8HQ78oGKcRFdVjDIMKiZgXZVQixQStFEODdeHWuRwugzDeerGDfPK5pQC1eGS28DJ7XqvFkOB2uihcPE4KOWCB7eYYULy87XBM0d)dDNk1umvhu3C9JpBc9xA3xC43ywBKyE5WpG8c(mNAfeNQ(IPIv(V8Yhs3UE9wBdB)BUIUvmHDTgrOdD5HZJtrEZPsfGAf5mpVmX9)L3xqTNKZuUAjFootz3bAp)4xWVwd6wmAptdEWb0qDfRFUtAJRP4GHELhGSzbWYrCrVMxP5bD(KpX28F2VVyAkXKlXoWK02wyi9ohoGX2iUUmkUE6SNdoyp1k1IZY5H4ZKOzEnSKmO(7OlNE44tU)EBvbNF2rmTB)2hAnhFO1Ax4UAoWv0l598OJT6G8smzV7OpoAboo44aGB7aKn8Lb2Yap19RO)jsRDAQvPv1wMhp0PdYAslz3zUVx(BCIVOi)ot5g8jw7kNGN8i8a35xuNWAZvd(KbIcRfw7u6HyfHikNk37Z7VFpV6Bg0eLxJVmoHs2wpYlhtYZxAFhBcq617UV4wGV6bYtekDlwFeF0MFGxaBbqllMCYiDDeCsR03wJcj7lYfGpuTbzvS(uw9XNXQ0HWdcwxnF85AFOYpSCUesxVPvaG7e0816i1)g0bm7IY9jAXI8mwcI4SZjz3KJnsc0sgwsfqmdBnYYeuYuQTjn6oQ)2cs55Nd4Li08v55LXgHEeEP1ugklz1sZygw0cIZWMPcKrjtfmB9sYwwlc(erb1)zU43h1ejecHXSPSE9AfBCTFKU8EFtgjasu8odDv9o3FVNkhF0aJY6P1jRUlLut3HclK9gFV(65R7470xpHG7VnF9fijwFs(6jeC(D4RNWq7JWNhXqK76Nz0PS9zANFiGcDuBr2pii8qmqHuV(RK(HDWfFRbwrU6CrBfM9045QsdZ20CLJomiMyWe5m53ioy1oS33QvyVVvBWgCgZF87oRpiMN2tDBgs)gM)g7(MrDquxVBSG4ORoBYG94KgFDQ6bHBAnNEKianpawnDdPKvS1JVnthexu8N3RdLm7UC3FOc8qXzcJSu0REc1zhgmSInG2qy1zAhev7Jwb5seLP9xMKIWBKjSMiJxu)Hqhp9OGZjZL3h3msm6FE7LUHpC2iTPtXWlqRj6m3bniyG)H3repvZoU7ax)ESTtWQ6SIA6YX3FVICF9(q9a3p5baBhDT3bEE0da6o730DjYKDEgm7J0d887DgYnXF4ZDt9TvPf7SivpCp3TGpjv1Kt((7d3y(o)yP3(UKqIlVqCC2f0oiCMhvbRoXQVWGh4Cn7(oygH8xmuPpqF(HJqzNyrD(iAsY9rZ9q3ldV6fvGOcKgD)9d5u(eTUzlpsF20Vr9DkE5qhx6pzkPuNaEzX(FJn04G7SAD3z3rqAWrVW5(TBwZ9dPKkSkEntI6jNbl8m)sWIsVs046iQ6vfjX4D(cT7PXEwIK6XXo(MmIcmOaharjkYDyS1gwVwAl8S3ZnEOP39YyrUnkPzlKeIQJe4E8ccm6hLRe11kL1iwPtJB7(JcMG0IZ4bLXZp7WXhorUn3YjyNkCuZ0hBpYos7tjkLxRlzHr9LHFzsQpRH5EQUNU0nDcwhhpQ7CtUxU286DhIwTW6bopo0xsQluIQiZKVaB10HnyV1m6JAkJASgup(asttD3bQp19tvQ0gPyERCbmAGRDbD8v6t8x6Do6(O3EN5rPx1WgEaV7D90(u9Uy9SZrZgVvDBU6GWgLE6XkPsS6lWM88UiaykPT9utrdIuc2Btmo9i5vwU1aNXTMqVdphwPsOiF4JTIUDfMD45M6S)lYwZCp3F3ZDeo9Mm2NOT(oEKS9nUMsq(SUeK1EXvi1Su9fvFuUpzRXZA8uoTYu9WKGWw0SK7aG5D0IFHxzqrCDMIpwUm6G8Jz(bDVij2Rbd9ubu2XXOVrUWxjWPybKR4HDUIN(Diqe95aZztukjgJICImcxwHDNpriR01N16gjQJKm3KWg5ouu2DeV2b2rFYib)ABkTDfTzYxAkFoMwkHTsAU09D4vlf8QIFybbPLX0E6tgDNLOj0wTXm8G2ReDVg19Gbb2w04CcUrpyOtj4YyN5rv65nB8JuZ5SvfVDMHHOETFuHcy7OP5zN7VVNbjyuau0ThJ2FmL6le8uYRQ)mB3YNCauHq)rCRPnaVfMZyZY40V3tYyS70VShpM6QK1dd0UYC1DNtc6(qxCjOBR9)to3DKURuk1KCubW3otwnRcX0TKxHgBq5DPiuwi5mmkq(NY)rMKzTsU(NTuweNuTsnWhrnQ)FLuZVimRSPxt3V6TXixbo8tBYROH2L4yCl8F9nbh2h3g0U2cVPNyWWHEmIaF32SVGvj975kK4bZ02qppRla2JTkycbCEHv8N0hpUrZ6BaEEOsl8WrnFlthKvK8eXQYodtEmTBp3WXdygSxar0J45N4VNVizzs8I)KOviY9EtlfbK9TSASFf)MQGJtE8OSf(5ofNZUi(WBWpDRMVfSQBrvORo)hEYEOXVH4RoTngV(Uq97iTpopjLwamDrjAr8OVytFrMWvTWWEHRoVZph55Uanz8jHmpw1RLquGUvcvHGGDzQRFWq1d5WCJ934ixxWEJzVXcjZbpyDuw04nZRcmMP4yucxPmqg4(rvPsZGc0vFnfqs6(lqAOvU8CBP7C8YK0uYxSmqOfDdNw2OHVn9WD0oqNxBTEis0DT)Zz)9fUVGiEI8JYv1Lx()b]] )