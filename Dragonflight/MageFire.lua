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

spec:RegisterTalents( {
    -- Mage Talents
    accumulative_shielding   = { 62093, 382800, 1 }, -- Your barrier's cooldown recharges $s1% faster while the shield persists.
    alter_time               = { 62115, 342245, 1 }, -- Alters the fabric of time, returning you to your current location and health when cast a second time, or after ${$110909d+$s3} sec.  Effect negated by long distance or death.
    arcane_warding           = { 62114, 383092, 2 }, -- Reduces magic damage taken by $s1%.
    blast_wave               = { 62103, 157981, 1 }, -- Causes an explosion around yourself, dealing $s1 Fire damage to all enemies within $A1 yds, knocking them back, and reducing movement speed by $s2% for $d.
    cryofreeze               = { 62107, 382292, 2 }, -- While inside Ice Block, you heal for ${$s1*10}% of your maximum health over the duration.
    displacement             = { 62095, 389713, 1 }, -- Teleports you back to where you last Blinked and heals you for ${$414462s1/100*$mhp} health. Only usable within $389714d of Blinking.
    diverted_energy          = { 62101, 382270, 2 }, -- Your Barriers heal you for $s1% of the damage absorbed.
    dragons_breath           = { 62091, 31661 , 1 }, -- Enemies in a cone in front of you take $s2 Fire damage and are disoriented for $d. Damage will cancel the effect.$?a235870[; Always deals a critical strike and contributes to Hot Streak.][]
    energized_barriers       = { 62100, 386828, 1 }, -- When your barrier receives melee attacks, you have a $s1% chance to be granted $?c1[Clearcasting]?c2[1 Fire Blast charge]$?c3[Fingers of Frost]. ; Casting your barrier removes all snare effects.
    flow_of_time             = { 62096, 382268, 2 }, -- The cooldowns of Blink and Shimmer are reduced by ${$s1/-1000} sec.
    freezing_cold            = { 62087, 386763, 1 }, -- Enemies hit by Cone of Cold are frozen in place for $386770d instead of snared.; When your roots expire or are dispelled, your target is snared by $394255s1%, decaying over $394255d.
    frigid_winds             = { 62128, 235224, 2 }, -- All of your snare effects reduce the target's movement speed by an additional $s1%.
    greater_invisibility     = { 93524, 110959, 1 }, -- Makes you invisible and untargetable for $110960d, removing all threat. Any action taken cancels this effect.; You take $113862s1% reduced damage while invisible and for 3 sec after reappearing.$?a382293[; Increases your movement speed by ${$382293s1*0.40}% for $337278d.][]
    ice_block                = { 62122, 45438 , 1 }, -- Encases you in a block of ice, protecting you from all attacks and damage for $d, but during that time you cannot attack, move, or cast spells.$?a382292[; While inside Ice Block, you heal for ${$382292s1*10}% of your maximum health over the duration.][]; Causes Hypothermia, preventing you from recasting Ice Block for $41425d.
    ice_cold                 = { 62085, 414659, 1 }, -- Ice Block now reduces all damage taken by $414658s8% for $414658d but no longer grants Immunity, prevents movement, attacks, or casting spells. Does not incur the Global Cooldown.
    ice_floes                = { 62105, 108839, 1 }, -- Makes your next Mage spell with a cast time shorter than $s2 sec castable while moving. Unaffected by the global cooldown and castable while casting.
    ice_nova                 = { 62126, 157997, 1 }, -- Causes a whirl of icy wind around the enemy, dealing $s1 Frost damage to the target and reduced damage to all other enemies within $a2 yds, and freezing them in place for $d.
    ice_ward                 = { 62086, 205036, 1 }, -- Frost Nova now has ${1+$m1} charges.
    improved_frost_nova      = { 62108, 343183, 1 }, -- Frost Nova duration is increased by ${$s1/1000} sec.
    incantation_of_swiftness = { 62112, 382293, 2 }, -- $?s110959[Greater ][]Invisibility increases your movement speed by $s1% for $337278d.
    incanters_flow           = { 62118, 1463  , 1 }, -- Magical energy flows through you while in combat, building up to ${$116267m1*5}% increased damage and then diminishing down to $116267s1% increased damage, cycling every 10 sec.
    mass_barrier             = { 62092, 414660, 1 }, -- Cast $?c1[Prismatic]?c2[Blazing]?c3[Ice][] Barrier on yourself and $414661i nearby allies.
    mass_invisibility        = { 62092, 414664, 1 }, -- You and your allies within $A1 yards instantly become invisible for $d. Taking any action will cancel the effect.; $?a415945[]; [Does not affect allies in combat.]
    mass_polymorph           = { 62106, 383121, 1 }, -- Transforms all enemies within $a yards into sheep, wandering around incapacitated for 1 min. While affected, the victims cannot take actions but will regenerate health very quickly. Damage will cancel the effect.; Only works on Beasts, Humanoids and Critters.
    mass_slow                = { 62109, 391102, 1 }, -- Slow applies to all enemies within $391104A1 yds of your target.
    master_of_time           = { 62102, 342249, 1 }, -- Reduces the cooldown of Alter Time by ${$s1/-1000} sec. ; Alter Time resets the cooldown of Blink and Shimmer when you return to your original location.
    mirror_image             = { 62124, 55342 , 1 }, -- Creates $s2 copies of you nearby for $55342d, which cast spells and attack your enemies.; While your images are active damage taken is reduced by $s3%. Taking direct damage will cause one of your images to dissipate.$?a382820[; You are healed for $382998s1% of your maximum health whenever a Mirror Image dissipates due to direct damage.]?a382569[; Mirror Image's cooldown is reduced by ${$382569s1/1000} sec whenever a Mirror Image dissipates due to direct damage.][]
    overflowing_energy       = { 62120, 390218, 1 }, -- Your spell critical strike damage is increased by $s1%. When your direct damage spells fail to critically strike a target, your spell critical strike chance is increased by $394195s1%, up to ${$394195u*$394195s1}% for $394195d. ; When your spells critically strike Overflowing Energy is reset.
    quick_witted             = { 62104, 382297, 1 }, -- Successfully interrupting an enemy with Counterspell reduces its cooldown by ${$s1/1000} sec.
    reabsorption             = { 62125, 382820, 1 }, -- You are healed for $382998s1% of your maximum health whenever a Mirror Image dissipates due to direct damage.
    reduplication            = { 62125, 382569, 1 }, -- Mirror Image's cooldown is reduced by ${$s1/1000} sec whenever a Mirror Image dissipates due to direct damage.
    remove_curse             = { 62116, 475   , 1 }, -- Removes all Curses from a friendly target. $?s115700[If any Curses are successfully removed, you deal $115701s1% additional damage for $115701d.][]
    rigid_ice                = { 62110, 382481, 1 }, -- Frost Nova can withstand $s1% more damage before breaking.
    ring_of_frost            = { 62088, 113724, 1 }, -- Summons a Ring of Frost for $d at the target location. Enemies entering the ring are incapacitated for $82691d. Limit 10 targets.; When the incapacitate expires, enemies are slowed by $321329s1% for $321329d.
    shifting_power           = { 62113, 382440, 1 }, -- Draw power from the Night Fae, dealing ${$382445s1*$d/$t} Nature damage over $d to enemies within $382445A1 yds. ; While channeling, your Mage ability cooldowns are reduced by ${-$s2/1000*$d/$t} sec over $d.
    shimmer                  = { 62105, 212653, 1 }, -- Teleports you $A1 yds forward, unless something is in the way. Unaffected by the global cooldown and castable while casting.$?a382289[; Gain a shield that absorbs $382289s1% of your maximum health for $382290d after you Shimmer.][]
    slow                     = { 62097, 31589 , 1 }, -- Reduces the target's movement speed by $s1% for $d.$?a391102[; Applies to enemies within $391104A1 yds of the target.][]
    spellsteal               = { 62084, 30449 , 1 }, -- Steals $?s198100[all beneficial magic effects from the target. These effects lasts a maximum of 2 min.][a beneficial magic effect from the target. This effect lasts a maximum of 2 min.] $?s115713[If you successfully steal a spell, you are also healed for $115714s1% of your maximum health.][]
    tempest_barrier          = { 62111, 382289, 2 }, -- Gain a shield that absorbs $s1% of your maximum health for $382290d after you Blink.
    temporal_velocity        = { 62099, 382826, 2 }, -- Increases your movement speed by $s2% for $384360d after casting Blink and $s1% for $382824d after returning from Alter Time.
    temporal_warp            = { 62094, 386539, 1 }, -- While you have Temporal Displacement or other similar effects, you may use Time Warp to grant yourself $386540s1% Haste for $386540d.
    time_anomaly             = { 62094, 383243, 1 }, -- At any moment, you have a chance to gain $?c1[Arcane Surge for $s1 sec, Clearcasting]?c2[Combustion for $s4 sec, 1 Fire Blast charge]?c3[Icy Veins for $s5 sec, Fingers of Frost][], or Time Warp for 6 sec.
    time_manipulation        = { 62129, 387807, 1 }, -- Casting $?c1[Clearcasting Arcane Missiles]?c2[Fire Blast]?c3[Ice Lance on Frozen targets][] reduces the cooldown of your loss of control abilities by ${-$s1/1000} sec.
    tome_of_antonidas        = { 62098, 382490, 1 }, -- Increases Haste by $s1%.
    tome_of_rhonin           = { 62127, 382493, 1 }, -- Increases Critical Strike chance by $s1%.
    volatile_detonation      = { 62089, 389627, 1 }, -- Greatly increases the effect of Blast Wave's knockback. Blast Wave's cooldown is reduced by ${$s1/-1000} sec.
    winters_protection       = { 62123, 382424, 2 }, -- The cooldown of Ice Block is reduced by ${$s1/-1000} sec.

    -- Fire Talents
    alexstraszas_fury        = { 62220, 235870, 1 }, -- Phoenix Flames and Dragon's Breath always critically strikes and Dragon's Breath deals $s2% increased critical strike damage contributes to Hot Streak. ;
    blazing_barrier          = { 62119, 235313, 1 }, -- Shields you in flame, absorbing $<shield> damage$?s194315[ and reducing Physical damage taken by $s3%][] for $d.; Melee attacks against you cause the attacker to take $235314s1 Fire damage.
    call_of_the_sun_king     = { 62210, 343222, 1 }, -- Phoenix Flames deals $s2% increased damage and gains $s1 additional charge.
    combustion               = { 62207, 190319, 1 }, -- Engulfs you in flames for $d, increasing your spells' critical strike chance by $s1% $?a383967[and granting you Mastery equal to $s3% of your Critical Strike stat][]. Castable while casting other spells.$?a383489[; When you activate Combustion, you gain $383489s3% Critical Strike, and up to $383493I nearby allies gain $383489s4% Critical Strike for $383493d.][]
    conflagration            = { 62196, 205023, 1 }, -- Fireball and Pyroblast apply Conflagration to the target, dealing an additional $226757o1 Fire damage over $226757d.; Enemies affected by either Conflagration or Ignite have a $s1% chance to flare up and deal $205345s1 Fire damage to nearby enemies.
    controlled_destruction   = { 62204, 383669, 2 }, -- Pyroblast's damage is increased by $s1% when the target is above $s3% health or below $s2% health.
    convection               = { 62188, 416715, 1 }, -- Each time Living Bomb explodes it has a $s1% chance to reduce its cooldown by ${$s2/1000}.1 sec.
    critical_mass            = { 62219, 117216, 2 }, -- Your spells have a $s1% increased chance to deal a critical strike.; You gain $s2% more of the Critical Strike stat from all sources.
    deep_impact              = { 62186, 416719, 1 }, -- Meteor's damage is increased by $s1% but is now split evenly between all enemies hit. Additionally, its cooldown is reduced by ${$s2/-1000} sec.
    feel_the_burn            = { 62195, 383391, 1 }, -- Fire Blast and Phoenix Flames increase your mastery by ${$s1*$mas}% for $383395d. This effect stacks up to $383395u times.
    fervent_flickering       = { 62218, 387044, 1 }, -- Ignite's damage has a $h% chance to reduce the cooldown of Fire Blast by $s1 sec.
    fevered_incantation      = { 62209, 383810, 1 }, -- Each consecutive critical strike you deal increases critical strike damage you deal by $s1%, up to ${ $s1*$383811u}% for $383811d.
    fiery_rush               = { 62203, 383634, 1 }, -- While Combustion is active, your Fire Blast and Phoenix Flames recharge $383637s2% faster.
    fire_blast               = { 62214, 108853, 1 }, -- Blasts the enemy for $s1 Fire damage. ; Fire: Castable while casting other spells. Always deals a critical strike.
    firefall                 = { 62197, 384033, 1 }, -- Damaging an enemy with $s1 Fireballs or Pyroblasts causes your next Fireball to call down a Meteor on your target$?a134735[ at $s2% effectiveness][].
    firemind                 = { 62208, 383499, 1 }, -- Consuming Hot Streak grants you $s3% increased Intellect for $383501d. This effect stacks up to $s2 times.
    firestarter              = { 62083, 205026, 1 }, -- Your Fireball and Pyroblast spells always deal a critical strike when the target is above $s1% health.
    flame_accelerant         = { 62200, 203275, 2 }, -- If you have not cast Fireball for $203278d, your next Fireball will deal $m1% increased damage with a $m2% reduced cast time.
    flame_on                 = { 62190, 205029, 2 }, -- Reduces the cooldown of Fire Blast by $s3 sec and increases the maximum number of charges by $s1.
    flame_patch              = { 62193, 205037, 1 }, -- Flamestrike leaves behind a patch of flames that burns enemies within it for ${8*$205472s1} Fire damage over $205470d.
    from_the_ashes           = { 62220, 342344, 1 }, -- Increases Mastery by $s3% for each charge of Phoenix Flames on cooldown and your direct-damage critical strikes reduce its cooldown by ${$s2/-1000} sec.
    fuel_the_fire            = { 62191, 416094, 1 }, -- Flamestrike has a chance equal to $s1% of your spell critical strike chance to build up to a Hot Streak.
    hyperthermia             = { 93682, 383860, 1 }, -- While Combustion is not active, consuming Hot Streak has a low chance to cause all Pyroblasts and Flamestrikes to have no cast time and be guaranteed critical strikes for $383874d.
    improved_combustion      = { 62201, 383967, 1 }, -- Combustion grants mastery equal to $s2% of your Critical Strike stat and lasts ${$s1/1000} sec longer.
    improved_scorch          = { 62211, 383604, 1 }, -- Casting Scorch on targets below $s2% health increase the target's damage taken from you by $s3% for $383608d, stacking up to $383608u times. ; Additionally, Scorch critical strikes increase your movement speed by $236060s1% for $236060d.
    incendiary_eruptions     = { 62189, 383665, 1 }, -- Enemies damaged by Flame Patch have a $h% chance to erupt into a Living Bomb.
    inflame                  = { 93680, 417467, 1 }, -- Hot Streak increases the amount of Ignite damage from Pyroblast or Flamestrike by an additional $s1%.
    intensifying_flame       = { 62206, 416714, 1 }, -- While Ignite is on $s1 or fewer enemies it flares up dealing an additional $s2% of its damage to affected targets.
    kindling                 = { 62198, 155148, 1 }, -- Your Fireball, Pyroblast, Fire Blast, Scorch and Phoenix Flames critical strikes reduce the remaining cooldown on Combustion by $<cdr> sec.
    living_bomb              = { 62194, 44457 , 1 }, -- The target becomes a Living Bomb, taking $217694o1 Fire damage over $217694d, and then exploding to deal an additional $44461s2 Fire damage to the target and reduced damage to all other enemies within $44461A2 yds.; Other enemies hit by this explosion also become a Living Bomb, but this effect cannot spread further.
    master_of_flame          = { 93681, 384174, 1 }, -- Ignite deals $s1% more damage while Combustion is not active. Fire Blast spreads Ignite to $s2 additional nearby targets during Combustion.
    meteor                   = { 62187, 153561, 1 }, -- Calls down a meteor which lands at the target location after $177345d, dealing $351140s1 Fire damage$?a416719[, split evenly between all targets within 8 yds][ to all enemies hit reduced beyond 8 targets], and burns the ground, dealing ${8*$155158s1} Fire damage over $175396d to all enemies in the area.
    phoenix_flames           = { 62217, 257541, 1 }, -- Hurls a Phoenix that deals $257542s2 Fire damage to the target and reduced damage to other nearby enemies.$?a235870[; Always deals a critical strike.][]
    phoenix_reborn           = { 62199, 383476, 1 }, -- Targets affected by your Ignite have a chance to erupt in flame, taking $383479s1 additional Fire damage and reducing the remaining cooldown of Phoenix Flames by $s1 sec.
    pyroblast                = { 62215, 11366 , 1 }, -- Hurls an immense fiery boulder that causes $s1 Fire damage$?a321711[ and an additional $321712o2 Fire damage over $321712d][].$?a383669[; Pyroblast's initial damage is increased by $383669s1% when the target is above $383669s3% health or below $383669s2% health.][]
    pyromaniac               = { 93680, 205020, 1 }, -- Casting Pyroblast or Flamestrike while Hot Streak is active has an $s1% chance to instantly reactivate Hot Streak.
    pyrotechnics             = { 62216, 157642, 1 }, -- Each time your Fireball fails to critically strike a target, it gains a stacking $157644s1% increased critical strike chance. Effect ends when Fireball critically strikes.
    scorch                   = { 62213, 2948  , 1 }, -- Scorches an enemy for $s1 Fire damage. Castable while moving.$?a383604[; Scorch critical strikes increase your movement speed by $236060s1% for $236060d.][]
    searing_touch            = { 62212, 269644, 1 }, -- Scorch deals $s2% increased damage and is a guaranteed Critical Strike when the target is below $s1% health.
    sun_kings_blessing       = { 62205, 383886, 1 }, -- After consuming $s1 Hot Streaks, your next non-instant Pyroblast or Flamestrike cast within $383883d grants you Combustion for $s2 sec and deals $383883s2% additional damage.
    surging_blaze            = { 62192, 343230, 1 }, -- Flamestrike and Pyroblast cast times are reduced by ${$s1/-1000}.1 sec and damage dealt increased by $s2%.
    tempered_flames          = { 62201, 383659, 1 }, -- Pyroblast has a $s1% reduced cast time and a $s2% increased critical strike chance. The duration of Combustion is reduced by $s3%.
    unleashed_inferno        = { 62205, 416506, 1 }, -- While Combustion is active your Fireball, Pyroblast, Fire Blast, Scorch, and Phoenix Flames deal $s1% increased damage and reduce the cooldown of Combustion by ${$s2/1000}.2 sec.
    wildfire                 = { 62202, 383489, 2 }, -- Your critical strike damage is increased by $s2%. When you activate Combustion, you gain $s3% additional critical strike damage, and up to $383493I nearby allies gain $s4% critical strike for $383493d.
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

        talent = "flamestrike",
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


spec:RegisterPack( "Fire", 20230711, [[Hekili:T3tAZnUXX(BrVulxslTCfLwT2jrsv57Sop74YY(5VjqqWHIiliadoKwLsf)T)MUNdm3aqIAJtIRkX1kIbZrp99fUE21)81xTmUMC9pCYXNC6XF6SztN9238zN9MRVQ((TKRVABCY7JVH(pYJ3q)VFtAj(J3NveVeE5QIMYe6pTUUEB1F61V(M061nlMMuS51vPBAYIRtlYtkJxvd)DYRV(QfnPz1Vl)6fox53C61xf3uVUO86RUkDZxsN50LljSHtQsU(ky4V64p9vZM9N2nF38FmUoz9U5ZoE6SPNTBEZwysNU7729DIbE8j4a)LkYU5ljlAwTAAfDmlN2SD38vfL7M)ZKnBlkJZ2n)xJl3Q8YN9QJ)m2lJtBfF8WID0U5P5jznltZVz38nX53VB(TXLPXlYGXvToDfDnOVqzXMDZ3wMwuMwthtDb8I1KYCy9skwQUzp9vNCmUEFFXY0v3R(E4c))8U8Q6486x93YZO)2VUMKdJ9w6E4)HUMK6A6)sF((uC((jYMIBPN)RskkbW1Lua39LflYIRQ3nFDC5Ye8FvLqYPhIcL54nca4prUnTY7CaNRK1KK3VB(FPG(3xvxsIF)0RVklTQUcqvO4elAQa8HOTRJRi0F7hqeq6ssbAlV(lOJHEyjuGiGMqVNAFLPllUlNIAKa)bmP3SUUk6V3S8MnK86RRPOrpYPAr8nrfRIQlttEFfmrN6DIGx5wsejNSjfUKPqGz7MpA38U2SWfu0c6ZH5)ngZpGwxMULn2)w9AsjGxuKbtcDrQxhdxmRlAYOOtlOxanvaI1DukTDZ)s5I2oMce5WCKX0rq3rnaAN6BXU4JZPdmhU44JMEd2qF6FLUZFjDx8fuS6kevFBzrY02dxsCwwe7pIGR6qa(sYM40CgGtqRmT69lIw2ugZ2np8afvhUCJKd(8DZp5ygEueJlKcMKeqbq2ZmGSI94AkRSY61ueYLr3vsNN7kJ3wPUt3wsULYazfL9wehH(q4Os)1tC(RNQ9RxEbDpIycSLu5HttOux3ayl0XCSGpQNDe9m8wpNHCcfgLfvDFoDGao4648esP6HqcsRt3qIQlIsuUMPG83kxEFtgD9)upRV99SYfcNWOooJsmIhJpZZ0SkJ(cvuIT3tmW8F3kD8YukidUzpcH4C2tfBi1Rr0WfekhrcdGFBCn(BP1t7IUhVKeinoXnpNrsebar5vQgv)fkyVkOIQhnke4poi(rTSrw1uEpYqAnjQQjp69alDquvWbOsAPV99)oKpSnLr3fTKKfFFljhdvvCNTvWLhowZoE4NRHbVpaEH8Ln0BteKsX6skj4ljw2w0jkD2ckMjUZgMWKHTZAxYku8hUGMICOSBJUBDAgjcEpkigeWPSnwxuhvHYfJQ2sYYQIsb0gGDhdM7vyc(GG03NlF)XsUqSTk9EMK0WOqg5(zenUTUqUraHCqaxAfoDWnG7vX4PpH1rIe6EHmF8tyLuOJ9COSgWty1Om0ifLtvqeg59zdCvMWWilwTk6MKLiUOKBU8Dm4c7sFcfnjqfoPmru4jd8PJZ2ua)7vP5PvRHrcARYg93Jhc(4wu0W1vmJQXXuKkYuFRUOIoq5S3kNnAlLuwCrng5IKUHQRYTKLrCCDgJCnOVnfc8qUvcMVVkp2tPGxXs5NdlJ0TlS4joj75S8pG)eUgdKYnPX0DcD(0FSK1IYddYV5qXBsqPNrnBfV5NGNkkkJ2j(yCJckJ5hTQ96WaT6xPkvIx9FdHKXXG(IMsq4(FVbWCAallaRlbvnPVFLcYgvz27kYFjDuBAYblpaCHkUoRSrbVzvDr5Mw9gyixMkB3TEixTLaZRIrmWe2uIxvQKhGA5RPWYwR000(yCOBMhHofi4hqLgRG0jo2IPgEUx0Ljp(L(v4Aw2KdADDdrzH5Ww2sZuauFXLdycWrcUt8PMEz8YuQXTuC14Y3BCR8tSNrVsGh63EOyTBo6wMQHn3QBeflDZgcDMQjGjsXut0l5yJmMzCgyvt3n)Nxdys3LMrXxZJRbfMH3HAKn4Lb7vIsHb7p0oDCgPZfyRf1GDWO4cQ6T6hIG6QYP(pbPg9Gh5Nc(WoO9bZvWRctRnSrFhikMpTgnnRW4K7KiXgM4B2nT2q3WoGnf14UkUFlg5fS5G6WJGwnIJbTvnnlqmk0HrW2zBXDGzDAy))cZ07R4Jz38FegKB2saQo7ktNJkNF5pUUGKN(b6JGJa4ZgU5PjGdcaYPf0d)Q0K04SJGdgYCUHH8Z8SaSkFEXx3h83dcArSMYQBzBmoOTDqN7BeBI)qKCukCFO)3pqVAIR(NXvrGyznwqJCFHAa(b)jzAOt3Ioatyd74eqsMgFlki(NOCvz8h43Q282OapuvRvCwlKpKwXqeSEzgdl00oslcIKfN9L2(2EZGYxaN94K25XyGkCj1HnF77d3JEV6MBWj(DAPpLxh1T6PukMtDzV6jMAAl3tAewouDJJa9ZNEmka8it2ivUqAbgrWoQM()PSOOuQmCXVEZcsPpDQawu4uc0oFdfqZOBmwauwRgQmDxfTOiVPIACmP80JJozBccSOmcULKXVbp3MtTeQ5xSqxstpx48VXY7Me(PnIGhwT7gMmDqMeLdMI8ug0NXXcqrrLLoXub2(5DvxyTcFPqYiLuTqyNo3Us5eFQOfetbJWIfIbELkIzaIjyiSAnjJEAVHYWGs)qm18Uv)(wldIH)aDwD8TXPzWUKzXzorG4byjjf5vKskfYudZh9ISCqFeI8XdPcVk8RIw)rau(lGDmh3ZjpIouuRRLZd(Kp3bRgAeBzPGYLeWIo04psErdyTf7CKrwvBJpHAFh7ale(DbsiI0LIVDv6sU4Z2z5iUPckoBMKvrcQUJk9TKY2LWWDZNHaK(7DyhtDl8lnHeLxCB81G4ekaCvCtwTRaRflD8tde8reFZaI)1mxzrXWj3sagVmanY5N(6sF4ii5mPQAToCzAvs62mQ9pubL0JYgWxpInJJq1j2COFnVlUCRXo7NHTqfb8kmvieURGa1Y2psLtxq4osyPHzEaIX2gqTiMnI6H7fUOfrzdqkO7xeHz1Qw3dtbjXLzuEfhbJmvOTmIHKIdhLkHKUzO7kkrJnxbUIaXGG1GBljW3IQGo9IIH)gVCzkCoHnu7HBC1eyTkbCEMtZqf)Y5xGudu)C57LD)rS9UqgzC2DX3xPkmoUDgwYq452OImBkj3exUe0u1KyaMd8aWnKgosiPJxmbod0AoqgVp1yEo2ry4rHGfvmoMy4X3wKbpnYoyG4RUiROyzgDpoTn2Htch9w892wGevTV0LD4x9dT5UlEzfXI4S6k4UIrCtgy7pLiQkAr8siHks6DC7yZrulY4R2n)m6QSAfjreboR5pq4qP3m3tVoZIkkxMdb(R3BMZv1L3AAyk(QBILNJu3tc7mYoC2B4abkTADmfkrXCkkxGAPxuIPiGUVn6)XuXirUpV5sspevLZDaRdo9U93RmmpmNxt(hnPB3sjpaRmq7)IQsVjnJTIY4wz80OtF7NEYBMPjB(nhJ(LHbk9bDce53Bkt3ersYs3wnmmLp7raDe7tTfnq8K3uuKNLwtVAsR2mOD3zpHDN(Q6iyVTK93VDnaNJRQs3KMX5BK4myg0FBtevem4zDMIdsOHZPXv0yLWL4K4fLu7txtOk7UPPknzyqh5r1Xe5kyRwkV1W86rm4buszrkMykVI5ew6b9OwPu4V9vGaMvOA()Fu5qqucOI9CPFgv0hMLm3Lwros6890)jrUMoMl7SLH5llqEMrmjyc3KsSq7xIH5o(gImseGK1mmMxutWfE8TvQIUawP3KPI6RyGKnXGUa3gN1qykKY8qJKfpmbUogO1qCDkeAIKLWZZoyBLeZbXCTJYbgN0JCcBzOiqnmT6e67W0kPvtHTKsqUIqXjjNMDZ)HIA5BYGNo901rTR(wQi90fz8Jy195jIDn)9)RFH6LsLTMicuMAQ10VNuxnvGxUuaCIUfHn9NOsWKL5eL8vyQ4bXAmjEjzk3D9x475Gxh5JbyFOKScwdvIcbd0L8e6)dpCmlp1cWIWVsuX5CWQZiTeAytmwypIIdPT1lG8(BSdnqoescsEiDK8CSUsCLJe6XAJQU6U5V7M80A3o(e1pMITaAeWq8wwqyMdI77vObImKPIAm15SWy4SlA)fys46Ht)PBUHWSzKkASewZ39LFfd1pfC0fO4oAwGW94SnwjtXzEeKWS)096lryRONTOu2r1qzejnM70cBQwEd0fY9efLi6hQPBeDPA5o8S)exkQyE9BOPI5JJo9n)Xp7SpvtvLZ0WN0GyUYuaPrTGoHzrWo1Gnq3aGrc7CpxQsWtKXaZsJiZBDgjIMzTcKpdYaWwZ7fy1VJVou(KSfsn3kq(3XvYSXWDmV1fntrzQAjM40bSy(u7oFszrOVf33JCzMrMGnXaJ)08wuF61BsztnSHI(hnX51nBOQ5FBQULhsejtBz0yy7sJ5WS4uvMNXXLtYyWF04zS8PsbDmWPiuuTz(DLQ72I466SbCI7NQHMtVRO6k2k3f)EWlRvrRkP0f77DIXS7kQVkGY6YMeCzwcUaKeTaDi1(Dh5BzCfYyjtNMC03crXG3)UxpHM3hBk7fiyyHtIPRb96Df4CCKHde6SvelpB4DKrVHNp68137m6kON9vPQ2DmqdbpVYz85KufLfq2ddUU0rqe(Msu16FG(yU2XcwLFlvQiWC8DjPjgoEQv5PBWbfLYgJkR(qgD3LIswkb1P2vEsEal3iisIq2pmXzKbJ72bUFlr4KVVsXbSil6nOvmWPhsEfWd35mDSv3UGE5vulB9avd5vxwugeI6r5Foho3lIIBcxJjkUKkpN0E1CqGblILBxxFh2MhcaQ1IIS6PQbfPxBE9QuORB(Ze3K(9i5)XaB1rG)xdWwl8DaKf4XHzZHIjrT0rmire5dBPMXNY8MsGGTUVVQAD3KJq168QdHL79BUN)7Ljgm9b0bNXy(5dy3nDXZaW9Je4ue(p7afxSftlI2XlMDdXg)iDxcogsufJgXAxZnoy8vvCfhmPznKavyHGtGv6Fb6FGpdST5WUHNTCv0ZvRPRAYYIOwU3KWg4NOmr6dnIv0qAtl1u2xRCtPSpBVAEfwNFN7EyAPH2HQ2tCl4xLISO2bx1VfZLToYN35embCAZleLMyxOuAE8XoZUPVo3sw7uT3tQ6holc60ZZh73Td9HePBfUu5AOSaDvBfQtIQRhcuwCQVnwXRUsfc3L7GnnRKC2Tk5(ReI9RtfDHIGCaQiXygpvx0ONUA2Ca4uSmQMwPpNQMyugmP(8LmVqGQ3ko0c3yKuKxxwKvzKVRCp2JUEog2mM1xqkmfxX237M)ZWgNhzB(UpGxUN2bTXWsYdv7q8YXu4tcnYax37t0eI5m3Q7nhs1aRAMISNAAT4EO0D6sM6XsCkVjzkuo7SsHYmvtpatLw6Vexs3rQiPbbwYs5WxgJx0DrHD8uU3fDj(Jx)Wbkyl)vwd6iW)cVc(rO430UvoYeP3DAA6l57qRgHbq(qnM4igHkd934Pbdf4xXZYZVPfUBTPW85JTByH3e9)jSU25i60DZ)wC3YY6LAS8GuMGqhhMttb0XkTSXbag3r3kYW9XO7TRvj2QPNjQG6LOpr3zKXR4lAfBrerkK8JEWKWdoCNKoAcNuMevnuWB0(vyR6mOVfdXBs82TY7BjNyjdmopx6FNNty08gf1GBu(wGIBDa1RttxYxo3N6J1PjVVv9r8473I9obXT2zyCX1tvgG27XsG)vzrTmk)NI2Lk5dZswtLniM8FG(j0LmUn9)mm1fcywwgbY5x1x1B245lGvh4w)i9GzgiQqJeroIRUHk2SM6iAIkeOQA6U7m2A12jbwRiSoZnOaPEtpYHgTlQnPLLfLrPBWgOJgm)m1XTIQsXASh5ymQ3QoQ2chW8M3hLSJ0aTheY)kNevknjLLhVS4oj74lhHQDrnXHsE)xi8gWWVSLXeuV24oOlA6EOwqxYNvuAYD9MFPrfTciy8xQRIYD4jV9fcRVudURbFhUBjuujyhVHY0wraeijZPiHlazTbQHGjUOJhe8DpCqfKZABAlNV7)mzD90bKtYhXD68dZqxvJXL2qYhNwyqcpHQsijBIZVhtE8JSRTzJqAOsP0zAjXaYTkQW0eruUxIMIc(sFlKhduT2QyuUWuAvaHgPXlYoHRBTOzUeSlnzPhEOoI0GDBMs1bmihLzf6wJoWKFkL(mVU8oHkgLwXHWZyJEyzTb3cEVFO9y3vwLo4KzudcXwUqYoxwgFtroDNtruRx7SiX(82IMPT8TykDB2zFyvVdI9CeKPBWCJMxJZUp7u6RehxjKE4k6ju6f4x2JrlGqJ1MWHvs3Bm7mflZvv6rTAHAXvGeONuc5KfRCxfxj12jz(VLpRDCA8HEHCISvgEymJ0CkqRymtVcm27zgotYtC6GkeEDp1R3AO6Ov1zpFU0c0bPQ58e0xgQpSLFHp9Oy3S(kV)oksrFBKGQwW4NzBORIJkdJMl0UZtDL77S4pSu(plU89PNP3F58fe9DyfoDNv4CFRwzde3okoWN39Igy0FhFyVClz652E4yt)owSx6EhO)bXiwghWoN0wV97Ja2PViBL24TLT0LDsARA4UW1qw2GMF12iC8g0bMLbH6auEQI(2080ZamsaCp(AYQ)q503Xh06ukNnIQGw9Eqp8kTZoa3bDW5DYJ2mOVsTDtiKEVBUq89rcZBmTiQsVBp1wF38IpeOwaedm8Z)uXpYSOrZPW)ILrwKuwczl8HCCRVmETsJRnb)VSLxtTs1abvOmpCuBz0H0IFeldC9vvok(WrdUHT73uSBGaUg9gH(UAnyiunxMxwfnSxyCYJsLMwVHA8n9L5OetYxhXXTsviiWVAAER((USw30VhkWv92sqTJ6oOD9hEN1GtUFE38eS8sBTJ0wxtSrVuLPl(aYlebGWw8IwZLiiK7jADrW9Axot6yfM3d9qfi8AueNGHFJAWY0ZuM3(73TqasFze(aBLUbAsxM0My7fWVjvHAdxHvosbB2VMxw7gvfynZ3oeAVjopE6wa3i4yJGX1UzCL6EEtGA)DRjMplKDvcaTOUsP41OYlUHfiVcHuIVrvdCiZOwLMLH(rlNYmgJd4QwPmt7nWXzeRrlf9Np2HnSwJuSRw)IEpjsl2rc9iTc6GsKFA7b3MrEIxx86r14e1rWsfEGc2yuDyBRwMbPmDubgKsq35RnJgdEsGvZyH0cfduiraRnOSEmp0bmDBSMFoC02daopT5HJNbnrvgKO3i0U3qp4HDhdhwIjgKDFgOZ2eGjbnV2jktxsAq(KSwSVCjSEId7L4bkBBrAgwRb5KSAksEtLclfhp0LUtSPQUGvLlnWhab6JeTjpjWX9ZDPjcFcPqtGXyYAKRxCgE9RaQnFOlLkytfOtgfqSeQ9fwSbVHSPDYC)yxkgWMU1fL5Wr5w6YQCc1)5Agv4T0jfEQ8JObugoL50DDfVTPKcOA1CvNFPNqf(sOWB)hnPy9pYQGR4gking1WKPsA10DF3)Bk0T5GpheFjZtSWJFPRa)8sgBtNptGXthZ4zFyc(TMWXEL3nBg2EBMXElCQel2L9lHJB3VbHdAu3gWbNu(MZ7mZdHVQyum5DvLJDUaHsrqByK)Oy05c5noigWPh)suSLWCMufR6HF5bsPSPwvT0OXm15DwRNx4(zsD9F4Hd6cW)Wd(ZuIrhmUpG0hEOtqYeLLXompx6VaVFXlgZvdvic)WzhpzI4U43HC(HCUbCTyLM8g27KWN(mVaN4NhHw51zZEWz13zn9MaONvg1MaRpQlMRssYGDNZYvYAIFZhZtXzFmxS32bpCtv(bkUrmkWWvwYHJdqFFiFgcwpjFsVZu6jViuDz8QzN3r1JCOCLCv5iHN8Xwqi(tc(AtEXlMnkaa6CnEEI74)94Y41pNxgHNCVxgbFTjd6UOL25Z(iPlN1cTp1LZPbaYmA9LdYeaFMN0A6JXgunYD9BN5Y5hdBt(2NjBhmNxpoDWgrOJz3jyG7tlUVkhgaWZT0EbBITcEKdB59AJfWR3T758B4qohxIoCxN5CBkQFFV39m)pX9UtKeRK4zy4jp3qI)O75xnW0gtTRyw)XzwTu6FFdmM9CdTXpVPFKq8uysJvF5WW7MzUt98nP7Lg2xz84EdPB5elt0mBM0T5GwFN29eINh859hEHP5g7Vfy339oeTaM2pvKye7MJFwAPpgIuEXQ0mzWUQMk174WlETzTZS77CnkrpV5iWdUxOwnkhLU6Idc5kdVfkZOXhyRFII)kuDLRIEV9Ad6UawW9Q3(oRZ5vTexCpI2IBX9ZLXEcUP(d7Mp4UqUCAVqT14GNLWwJIl3VDAT4)5D)ERf3rRfxE9sXvKradUDDPv8OXgrp7HhGUk(i)oY7CC42Dt8jQRllmMWIIJ2OhIFziRA9zkO60ljovcv3fMrQdw9q(QuGp9QZCo14CA1hT7yspV9HE6t3HSy9YUE5qB1aSOc5fbLDSQ4FLw3WHN8Wd6yabMUjJC6SJXE5s(Wdst8Rd2zUV8nhpX)PxT7x35D0NnGdK)LuRLw35AE2EznD2wR1LyAh5Hahb7wvD3heukWV3VQ)9(v9Zu)Q2p6QPcFDH4)CfYTNqO2ceIThFO1EXyTGQHeO)3qJIoGWqddkKaOoAy00l9a4ttOYX8Jt4gFc1OYk)RMOkr0eTwrKyhTa6lpJDz)m0xKvHTkDlAtWRq8JpWYiat(8Z8bD6fLitGt9hVUWSF8QuVD0yak4Tz3oYoahGwrHi3BfcR1LLv4rO97xes5iJoEC4T6Jttc9wz8ZXkK6U1e)CSuwnC4NLfXxxfwA1ux9NyxZDvxYerIPH1YGvxN2oOiSqEsHbp2a0hJXckd88onvrT4lzSg3BT4xngIg(njSBtg1JUAjArpdU1vBOD0bEhgvYsqWSiKXo6YSx2JnPq73WxsNPXjYm1Z)3kWLk60hhy3iHlm1sWLjwKGWgyFbkz2JkpnbaRTn91Ncu95aUzdHCWK6XdIcJTTxal7xGXFaAyjp(UuRk0uSuh10wCJxmd)lTc8L(BmTnsnRz3JqRGVWPubbv1VzsdM)dpNK01RxVSQy3FjkYwHOa2PhHo2Lfopnb5TuLktQLNZ88Yi2)V9A)Ppl0uUkcnh0u21C9LN(j8IYtxJr7vA0J2HgQNyD6oPoUMSdg7LFaGMfyxoHZ61Sikh1BkFeT5FTnhunHyYJypqs66kmKCNJhXqBevANIPNoRYUrhOM(xCuopaFghnZ6TxIG6VdWE(Xtp7HhSffC5fNWKU97DjvhDj1UzURgdCf5sEPhDCvhexIX7Dp1ztdqo4GaWTEaYg5WiBEGN7(v07VPDdtTYxRUI84XonqwJBjRbe8DYFJd8fzo4fk9NnXzxHcE2tWcCN9qUWsZvD(KXgLEwynkThJwecVCQ0F4E4Hd8kVzuRxEn6fCHc22aIlhJZZV16CBba961ZoCf4llG84Hs3S1NWhTzlnJQlaOzXSZMOlJGdAL22AKDA)M8a4BR2Uzv0(uMsZxWY0HWdIEUAlI7UhQSaTDXKUzBNtaCtGRxNJuVwUPi7I09jE5YICwaI4OZP53waL0pOjdlOcWodAgaYauYeQTnl(EWNIjuU8C6aEkcLSUOOIy46r6lTbJqzflxAMY2fDSXz7MiXMrjsfmD9sZx1iC(ecb1)zo73N0cjycb(SPQzZgfDCTFKo)EFlgYasK8oJDL9op8GN0rFYiJ06PZfRPpPut)NfMl7nQ79b(6oQ39bodURX9HojPwL2(aNbN1Z(aNdTIz3dBi0C9lWeFRk6V3S8grcafuDdRzay6eJyRuYYK37v5WGZWJrbfu8kpIYsiHWMDBPK2z8HymSm)WCKqyMzSF0FReuVuubDKffF0ESJhcrArY0Gh(oDSI805c2ku7P1Y13ViQvtmD1vo54G7edKiNb)g2dqZVA6mfthpe)LtS(Ltv(fQXy(9F3fdzJLtAawxv3Nt3paAYAqwuxknE5BdVgUVg0vYqMntMATbxphjJhop)sxJiaIMgnotCLZsRdJsOyRRxJTc50RwxJzqk5m)9uB8LH2vYCj27EIPNK72uzGhkWHnIQWGANLDGbH61eZca3taCEGN6qi4AZSp7PTYiMNlUxk8TeT4pf8q0DJzBWy3UknpTAnMBdYm547rtF4JBH0)bzq8dctTi)P(5WPaDMSlCBHBqVutFhHZ)m7bJJC97eBl2uzWcqzzs9OWKsVhGoY9tEeZTJw95ipp6rm72EktDZhWnA9Ef4wmlVch55379m3ASmIdA70lM)5Bc3yl5jJ5MMCWv7CxSX8LgokM7)kk30Y0Ud(W7t3Qo(a3Tgrju1et(Hh80pef8lpvAAQVUBBimo7SVMYKMBcSvlY2NpBdqxZsoFt35(jJv(quC5Xto)ewgiUf9XTURsTD8kl9RwNcTuoEM(E)GeLo29XyGIjN8WdJ5q(uT2wo3Tu2WVjdDjE1yh1LMm(jQlapho)jW6RCa8TnU89(vbo2OVNwYkpeGTpsEPvao88QKLnYXksrQKjXm3f2X1nLmt1RGKOb6xKMRefbb2Fy4J5zdn6maE))es0o9dr4B2s2yP4D0H62DhJo5tCEF7g18WqcPoP)QgnqmdMVe(1Gzqn8gKDI(M4IYucuGsG(p70)QK4Xke(LmSfyZcLae4OiVHP61u1SrQC683XvEGLZKjPW9eGICxCA7viYevFta3XlXPrNuUwKeMyioy55lCT73LncqlSIhvrsU44PhptEn3bfStboQHLIDhz7w4ies5vltMp)Ev4xg56Z(MXCUUzzyz5qphNoP)ytUpU2469FgT6DXJCsomuqQRTeM(GPUIwJtM7awcJQHyeiiuk(pYAcS8OSQeDizsH3IUcoxSPwPidzM5dRYNx81H5S0D4NbjLXTAdQBmRu1u3FBeo39tvslejBElhxpzKRBb99R0i1WoLyN4RBKqabfI9tnq1cdmI5xs2crwb1CfRqzqgoKpKwXUxTEzMKbXhpPLQnVC9SgVhYT3Bww6vmSXNaI9VjO2u17JZZEFB2ATQB1vhfwP0ZpvjUx4D9pF6XOsbhzsa7nLiAdF9xYBw57M)1y3k3JoHy6ratzB01au8kZWKtY7aRtNMeacUAN6JuIX45MSgeXVAWQyC(jY6R1tpA)8tePHdxBc22u0HUdlujKhq8HwjCYHwJnUnPWTUoXlIR49d)0CBM7RjzB7k1iCKwgSGbjkAzMdmYjc0f4Uf0FHusrhh697boVGpWBKdFMU67jjz3xCT5l7fI(O(EdRqkzrQokAVTShFddzEgzvT9LpQXySdug43fymigcwSG5UQ9gX36pfNRsYQiHVXncTGNZ45CyLP4HzbN70eImXH7yI5TFHNHV(NT7qpPRJTFmgQNl8LVwkAa5YFyxQyPFpCeXqiyUyMs(B467xPmDWUCMGxPRV6aTCuNirU)3)p0KpcuIwxB1fYWJ6Us0QvuVdgf4ArdZj4f9OXo5Gl9DMhrPx2EXprnaPwPN1fgkI6v)r3FSwg52Htp8WaDsWKaBr3wmA)vZBOZGN8Z06lB35(4daceg(g3AzdGBbb40mNd9B9K0h7oTl7PVtD(r(j4K2xKR(BCsqZh6Jjb97S)VY1UNWDL8(f5Jw9FLFWS6a)BOb4WMCBu3sl8gEIrJh7rjc4D7s)cwAFFGlxIhmsBJ98S(mXE0vbciGZQRWFqFc9XW6IU(qyr57zNGYYWbz5jpHVQSJWKhv7oW984zAgDqaw0t4XNq8ry7pV7j9ryBaml85NZ(W(WRZpDlMVJDv)8QqFn(p8I9y9FdIxDExiEd9G63qAFyEsiTX3Lmfxs0(njBG7MHUzcN1cJh0E1zbQCINcxz20ZcPESQvlHGa9lNMcnd25uToHHQfYHXghUYrUQgCJvVvdjZbpAd)JFwGXGF4ZuCx5Z5hRS9JEGoRXQbWs0DIQZr)95UVGB8uXhWmkbsY1)WBpf)YjD9))]] )