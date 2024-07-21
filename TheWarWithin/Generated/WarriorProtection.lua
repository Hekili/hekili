-- WarriorProtection.lua
-- July 2024

local addon, ns = ...
local Hekili = _G[ addon ]
local class, state = Hekili.Class, Hekili.State

local spec = Hekili:NewSpecialization( 73 )

-- Resources
spec:RegisterResource( Enum.PowerType.Rage )

spec:RegisterTalents( {
    -- Warrior Talents
    armored_to_the_teeth            = { 90366, 384124, 2 }, -- Gain Strength equal to $s2% of your Armor.
    avatar                          = { 92640, 107574, 1 }, -- Transform into a colossus for $d, causing you to deal $s1% increased damage$?s394314[, take $394314s2% reduced damage][] and removing all roots and snares.; Generates ${$s2/10} Rage.
    barbaric_training               = { 90340, 383082, 1 }, -- Slam, Cleave, and Whirlwind deal $s1% more damage and $s2% increased critical strike damage.; 
    berserker_shout                 = { 90348, 384100, 1 }, -- Go berserk, removing and granting immunity to Fear, Sap, and Incapacitate effects for $d.; Also remove fear effects from group members within $384102A1 yds.
    berserkers_torment              = { 90362, 390123, 1 }, -- Activating Avatar or Recklessness grants ${$s1/1000} sec of the other.
    bitter_immunity                 = { 90356, 383762, 1 }, -- Restores $s1% health instantly and removes all diseases, poisons and curses affecting you.; 
    blademasters_torment            = { 90363, 390138, 1 }, -- Activating Avatar grants ${$s1/1000} sec of Sweeping Strikes and while Avatar is active the cooldown of Cleave is reduced by ${$107574s8/-1000}.1 sec.
    bounding_stride                 = { 90355, 202163, 1 }, -- Reduces the cooldown of Heroic Leap by ${$m1/-1000} sec, and Heroic Leap now also increases your movement speed by $202164s1% for $202164d.
    cacophonous_roar                = { 90383, 382954, 1 }, -- Intimidating Shout can withstand $s1% more damage before breaking.
    champions_might                 = { 90323, 386284, 1 }, -- The duration of Champion's Spear is increased by ${$s1/1000} sec. You deal $376080s5% increased critical strike damage to targets chained to your Spear.
    champions_spear                 = { 90380, 376079, 1 }, -- Throw a spear at the target location, dealing $376080s1 Physical damage instantly and an additional $376080o4 damage over $376081d. Deals reduced damage beyond $<cap> targets.; Enemies hit are chained to the spear's location for the duration.; Generates $/10;376080s3 Rage.
    concussive_blows                = { 90354, 383115, 1 }, -- Cooldown of Pummel reduced by ${$s1/-1000}.1 sec. ; Successfully interrupting an enemy increases the damage you deal to them by $383116s2% for $383116d.
    crackling_thunder               = { 95959, 203201, 1 }, -- Thunder Clap's radius is increased by $s1%, and it reduces movement speed by an additional $s2%.
    cruel_strikes                   = { 90381, 392777, 2 }, -- Critical strike chance increased by $s1% and critical strike damage of Execute increased by $s2%. 
    crushing_force                  = { 90349, 382764, 2 }, -- $?c1[Mortal Strike deals an additional $s1% damage and deals $s2% increased critical strike damage.][Bloodthirst deals an additional $s4% damage and has a $s5% increased critical strike chance.]
    double_time                     = { 90382, 103827, 1 }, -- Increases the maximum number of charges on Charge by 1, and reduces its cooldown by ${$s2/-1000} sec.
    dual_wield_specialization       = { 90373, 382900, 1 }, -- Increases your damage while dual wielding by $s1%.
    endurance_training              = { 90339, 382940, 2 }, -- Stamina increased by $s1% and the duration of Fear, Sap and Incapacitate effects on you is reduced by ${$s6/10}.1%.
    fast_footwork                   = { 90344, 382260, 1 }, -- Movement speed increased by $s1%.
    frothing_berserker              = { 90370, 392790, 1 }, -- Revenge has a $h% chance to immediately refund $s1% of the Rage spent.
    heroic_leap                     = { 90346, 6544  , 1 }, -- Leap through the air toward a target location, slamming down with destructive force to deal $52174s1 Physical damage to all enemies within $52174a1 yards$?c3[, and resetting the remaining cooldown on Taunt][].
    honed_reflexes                  = { 95956, 391271, 1 }, -- Cooldown of $?c1[Die By the Sword]?c2[Enraged Regeneration][Shield Wall], Pummel, Intervene, Spell Reflection, and Storm Bolt reduced by $s1%.
    immovable_object                = { 90364, 394307, 1 }, -- Activating Avatar or Shield Wall grants ${$s1/1000} sec of the other.
    impending_victory               = { 90326, 202168, 1 }, -- Instantly attack the target, causing $s1 damage and healing you for $202166s1% of your maximum health.; Killing an enemy that yields experience or honor resets the cooldown of Impending Victory and makes it cost no Rage.
    intervene                       = { 90329, 3411  , 1 }, -- Run at high speed toward an ally, intercepting all melee and ranged attacks against them for $147833d while they remain within $147833A1 yds.
    intimidating_shout              = { 90384, 5246  , 1 }, -- $?s275338[Causes the targeted enemy and up to $s1 additional enemies within $5246A3 yards to cower in fear.][Causes the targeted enemy to cower in fear, and up to $s1 additional enemies within $5246A3 yards to flee.] Targets are disoriented for $d.
    leeching_strikes                = { 90371, 382258, 1 }, -- Leech increased by $s1%.
    menace                          = { 90383, 275338, 1 }, -- Intimidating Shout will knock back all nearby enemies except your primary target, and cause them all to cower in fear for $316595d instead of fleeing.
    onehanded_weapon_specialization = { 90324, 382895, 1 }, -- Damage with one-handed weapons and Leech increased by $s1%.
    overwhelming_rage               = { 90378, 382767, 2 }, -- Maximum Rage increased by ${$s1/10}.
    pain_and_gain                   = { 90353, 382549, 1 }, -- When you take any damage, heal for ${$m1/10}.2% of your maximum health. ; This can only occur once every $357946d.
    piercing_challenge              = { 90379, 382948, 1 }, -- Champion's Spear's damage increased by $s1% and its Rage generation is increased by $s2%.
    piercing_howl                   = { 90348, 12323 , 1 }, -- Snares all enemies within $A1 yards, reducing their movement speed by $s1% for $d.
    rallying_cry                    = { 90331, 97462 , 1 }, -- Lets loose a rallying cry, granting all party or raid members within $a1 yards $s1% temporary and maximum health for $97463d.
    reinforced_plates               = { 90368, 382939, 1 }, -- Armor increased by $s1%.
    rumbling_earth                  = { 90374, 275339, 1 }, -- Shockwave's range increased by $s3 yards and when Shockwave strikes at least $s1 targets, its cooldown is reduced by $s2 sec.
    second_wind                     = { 90332, 29838 , 1 }, -- Restores $202147s1% health every $202147t1 sec when you have not taken damage for $202149d.; While you are below $458245s3% health, restores ${$458245s4}.1% health every $458245t1 sec. The amount restored increases the closer you are to death.
    seismic_reverberation           = { 90354, 382956, 1 }, -- If Whirlwind $?c1[or Cleave ][]$?s436707[or Thunder Clap ][]$?a137048[or Revenge ][]hits $s1 or more enemies, it hits them $s2 additional time for $s5% damage.
    shattering_throw                = { 90351, 64382 , 1 }, -- Hurl your weapon at the enemy, causing $<damage> Physical damage, ignoring armor, and removing any magical immunities. Deals up to $?s329033[${($329033s3/100+1)*500}][500]% increased damage to absorb shields.
    shockwave                       = { 90375, 46968 , 1 }, -- Sends a wave of force in a frontal cone, causing $s2 damage and stunning all enemies within $a1 yards for $132168d.
    sidearm                         = { 95955, 384404, 1 }, -- Your auto-attacks have a $s2% chance to hurl weapons at your target and 3 other enemies in front of you, dealing an additional $384391s1 Physical damage.
    spell_reflection                = { 90385, 23920 , 1 }, -- Raise your $?c3[shield][weapon], reflecting $?a213915[the next $213915s3 spells cast][the first spell cast] on you, and reduce magic damage you take by $385391s1% for $d.
    storm_bolt                      = { 90337, 107570, 1 }, -- Hurls your weapon at an enemy, causing $s1 Physical damage and stunning for $132169d.$?s436162[ Also hits 2 additional nearby targets, stunning for 2 sec.][]
    thunder_clap                    = { 90343, 6343  , 1 }, -- Blasts all enemies within $A1 yards for $s1 Physical damage$?s199045[, roots them for $199042d,][] and reduces their movement speed by $435203s1% for $435203d. Deals reduced damage beyond $s5 targets.$?a137048|(a137050&a436707)[; Generates ${$s4/10} Rage.][]$?c1|c3[; If you have Rend, Thunder Clap affects $s5 nearby targets with Rend.; ][]
    thunderous_roar                 = { 90359, 384318, 1 }, -- Roar explosively, dealing $s1 Physical damage to enemies within $A1 yds and cause them to bleed for $397364o1 physical damage over $397364d.
    thunderous_words                = { 90358, 384969, 1 }, -- Increases the duration of Thunderous Roar's Bleed effect by ${$s1/1000}.1 sec and Thunderous Roar's Bleed effect causes enemies to take $397364s3% increased damage from all your bleeds.
    titans_torment                  = { 90362, 390135, 1 }, -- Activating Avatar casts Odyn's Fury and activating Odyn's Fury grants ${$s1/1000} sec of Avatar.
    twohanded_weapon_specialization = { 90322, 382896, 1 }, -- Increases your damage while using two-handed weapons by $s1%.; 
    unstoppable_force               = { 90364, 275336, 1 }, -- Avatar increases the damage of Thunder Clap and Shockwave by $s1% and reduces the cooldown of Thunder Clap by $s2%.
    uproar                          = { 90357, 391572, 1 }, -- Thunderous Roar's cooldown reduced by ${$s1/-1000} sec.
    war_machine                     = { 90386, 346002, 1 }, -- Your auto attacks generate $s2% more Rage.; Killing an enemy instantly generates ${$262232s1/10} Rage, and increases your movement speed by $262232s2% for $262232d.
    warlords_torment                = { 90363, 390140, 1 }, -- Activating Avatar grants ${$s1/1000} sec of Recklessness.; The additional Rage generation of this Recklessness is reduced to $s2%.
    wild_strikes                    = { 90360, 382946, 2 }, -- Haste increased by $s1% and your auto-attack critical strikes increase your auto-attack speed by $s2% for $392778d.
    wrecking_throw                  = { 90351, 384110, 1 }, -- Hurl your weapon at the enemy, causing $<damage> Physical damage, ignoring armor. Deals up to $?s329033[${($329033s3/100+1)*500}][500]% increased damage to absorb shields.

    -- Protection Talents
    anger_management                = { 90311, 152278, 1 }, -- Every $?c1[$s1]?c2[$s3][$s2] Rage you spend$?c1[ on attacks][] reduces the remaining cooldown on $?c1&s262161[Warbreaker, Bladestorm, and Ravager]?c1[Colossus Smash, Bladestorm, and Ravager]?c2[Recklessness, Bladestorm, and Ravager][Avatar and Shield Wall] by 1 sec.
    arterial_bleed                  = { 94799, 440995, 1 }, -- Colossal Might increases the damage of your Rend and Deep Wounds by $440989s2% per stack.; 
    avatar_of_the_storm             = { 94805, 437134, 1 }, -- Casting Avatar grants you $s1 charges of Thunder Blast and resets the cooldown of Thunder Clap.; While Avatar is not active, Lightning Strikes have a $s2% chance to grant you Avatar for $s3 secs.; $@spellicon435222$@spellname435222; Your next Thunder Clap becomes a Thunder Blast that deals Stormstrike damage.
    battering_ram                   = { 90262, 394312, 1 }, -- Shield Charge critical strike chance and critical strike damage increased by $s2%, and Shield Charge increases your auto-attack damage and speed by $394313s1% for $394313d.
    battle_stance                   = { 90261, 386164, 1 }, -- A balanced combat state that increases the critical strike chance of your abilities by $s1% and reduces the duration of movement impairing effects by $s2%. ; Lasts until canceled.
    battlescarred_veteran           = { 90435, 386394, 1 }, -- When your health is brought below $s1%, you take $386397s1% less damage for $386397d and healing you receive is increased by $386397s2%.; Cannot occur more than once every $456447d.
    best_served_cold                = { 90304, 202560, 1 }, -- Revenge deals $s1% more damage, or ${$s1+$5302s2}% more damage when your successful dodges or parries have made it cost no Rage.
    bloodborne                      = { 90448, 385704, 2 }, -- Deep Wounds, Rend and Thunderous Roar's Bleed effects deal $s1% increased damage.; 
    bloodsurge                      = { 90300, 384361, 1 }, -- Damage from your Bleed effects have a $H% chance to grant you ${$384362s1/10} Rage.
    bolster                         = { 90264, 280001, 1 }, -- Last Stand's cooldown is reduced by ${$s1/-1000} sec, and it grants you the Shield Block effect for its duration.
    boneshaker                      = { 94789, 429639, 1 }, -- Shockwave's stun duration is increased by ${$s1/1000} sec and reduces the movement speed of affected enemies by $458480s1% for $458480d after the stun ends.
    booming_voice                   = { 90314, 202743, 1 }, -- Demoralizing Shout also generates ${$m1/10} Rage, and increases damage you deal to affected targets by $s2%.
    brace_for_impact                = { 90296, 386030, 1 }, -- Using Shield Slam increases the damage of Shield Slam by $386029s1% for $386029d, and it increases the block value of your shield by $386029s2%. Stacking up to $s2 times.
    brutal_vitality                 = { 90451, 384036, 1 }, -- $s1% of damage you deal adds to your active Ignore Pain.
    burst_of_power                  = { 94807, 437118, 1 }, -- Lightning Strikes have a $h% chance to make your next $s1 $?a137048[Shield Slams][Bloodthirsts] have no cooldown$?a137050[, deal $437121s2% increased damage, and generate ${$437121s3/10} additional Rage][].
    challenging_shout               = { 90309, 1161  , 1 }, -- Taunts all enemies within $A1 yds to attack you for $d.
    champions_bulwark               = { 90316, 386328, 1 }, -- Shield Charge deals $s3% increased damage, grants you Shield Block, makes your next Revenge cost no Rage, and generates an additional ${$s2/10} Rage.
    colossal_might                  = { 94819, 429634, 1 }, -- Colossal Might increases damage dealt by your next Demolish by $440989s1%, stacking up to $440989u times.; $?c1[Mortal Strike and Execute][Shield Slam and Execute] grant a stack of Colossal Might and $?c1[Cleave][Revenge] grants a stack of Colossal Might when it strikes $s1 or more targets.
    crashing_thunder                = { 94816, 436707, 1 }, -- Stormstrike or Nature damage your abilities deal is increased by $s1%. Stormstrike damage ignores Armor.; Thunder Clap damage increased by $s3%$?a137050[, and it generates ${$s4/10} Rage][]. ; Seismic Reverberations$?a137048[ now affects][, Improved Whirlwind, Meat Cleaver, and Barbaric Training now affect] Thunder Clap in addition to Whirlwind.
    dance_of_death                  = { 90260, 390713, 1 }, -- $?c1[When an enemy dies while affected by your Bladestorm, all damage you deal is increased by $459572s1% for the remainder of the Bladestorm and for $459572d afterwards.; ][]When an enemy dies while affected by your Ravager, its duration is extended by ${$s1/1000} sec.; $?c1[These effects][This effect] can trigger a maximum of $s2 times per use of $?c1[Bladestorm or ][]Ravager.
    defenders_aegis                 = { 90310, 397103, 1 }, -- Shield Wall gains $s2 additional charge, and its cooldown is reduced by ${$s1/-1000} sec.
    defensive_stance                = { 90330, 386208, 1 }, -- A defensive combat state that reduces all damage you take by $s1%$?a452494[ and all magic damage you take by an additional $s3%][]$?a137048[][, and all damage you deal by $s2%]. ; Lasts until canceled.
    demolish                        = { 94818, 436358, 1 }, -- Unleash a series of precise and powerful strikes against your target, dealing ${$440884s1+$440886s1+$440888s1} damage to it, and $440888s1 damage to enemies within 8 yds of it. Deals reduced damage beyond $s1 targets.; While channeling Demolish, you take $s4% less damage and are immune to stuns, knockbacks, and forced movement effects.; You can block, parry, dodge, and use certain defensive abilities while channeling Demolish.
    demoralizing_shout              = { 90305, 1160  , 1 }, -- $?s199023[Demoralizes all enemies within $A2 yards, reducing the damage they do by $s2% for $d.][Demoralizes all enemies within $A2 yards, reducing the damage they deal to you by $s1% for $d.]$?s202743[; Generates ${$m5/10} Rage.][]
    devastator                      = { 90299, 236279, 1 }, -- Your auto attacks deal an additional $236282s1 Physical damage and have a $s2% chance to reset the remaining cooldown on Shield Slam.
    disrupting_shout                = { 90307, 386071, 1 }, -- Taunts all enemies within $A1 yds to attack you for $d, interrupts all spellcasting within $A1 yds and prevents any spell in that school from being cast for $d.; 
    dominance_of_the_colossus       = { 94793, 429636, 1 }, -- Colossal Might now stacks up to 10 times. If you would gain a stack of Colossal Might and are at max stacks, the cooldown of Demolish is reduced by $s2 sec.; Enemies affected by Demolish take up to ${$447513s2*$447513u*0.1}% more damage from you and deal up to ${$447513s1*$447513u*-0.1}% less damage to you for $447513d based on the number of stacks of Colossal Might consumed by Demolish.
    earthquaker                     = { 94789, 440992, 1 }, -- Shockwave also knocks enemies into the air, and its cooldown is reduced by ${$s1/-1000} sec.
    enduring_alacrity               = { 90433, 384063, 1 }, -- Increases Stamina and Armor by $s1% and your Haste by $s2%.
    enduring_defenses               = { 90313, 386027, 1 }, -- Shield Block lasts ${$s1/1000} sec longer.
    fight_through_the_flames        = { 90306, 452494, 1 }, -- Defensive Stance additionally reduces magic damage you take by $s1%.
    flashing_skies                  = { 94797, 437079, 1 }, -- Thunder Blast calls down a Lightning Strike on an enemy it hits.
    focused_vigor                   = { 90318, 384067, 1 }, -- Increases Strength and Armor by $s1% and your critical strike chance by $s2%.; 
    fueled_by_violence              = { 90451, 383103, 1 }, -- You are healed for $s1% of the damage dealt by Deep Wounds.
    gathering_clouds                = { 94792, 436201, 1 }, -- Your attacks trigger Lightning Strikes $s1% more often.
    ground_current                  = { 94800, 436148, 1 }, -- Lightning Strikes also deal $460670s1 to enemies near their target. Damage reduced beyond $460670s2 targets.
    heavy_repercussions             = { 90319, 203177, 1 }, -- Shield Slam generates ${$s2/10} more Rage and extends the duration of Shield Block by ${$m1/100}.1 sec.
    ignore_pain                     = { 90295, 190456, 1 }, -- Fight through the pain, ignoring $s2% of damage taken, up to ${$mhp*$s4/100} total damage prevented.
    impenetrable_wall               = { 90310, 384072, 1 }, -- Shield Slam generates an additional ${$s2/10} Rage and reduces the remaining cooldown of Shield Wall by $s1 sec.
    indomitable                     = { 90434, 202095, 1 }, -- Your maximum health is increased by $s3%, and every ${$s2/10} Rage you spend heals you for ${$s1/10}% of your maximum health.
    instigate                       = { 90301, 394311, 1 }, -- Devastate deals $s1% increased damage and generates ${$s2/10} Rage.; Devastator deals $s3% increased damage and generates ${$s4/10} Rage.
    into_the_fray                   = { 90319, 202603, 1 }, -- You gain $202602s1% Haste for each enemy or ally within $s1 yards, up to ${$202602s1*$202602u}% Haste.
    juggernaut                      = { 90449, 393967, 1 }, -- Execute increases Execute's damage dealt by $393968s1% for $393968d, stacking up to $393968u times.
    keep_your_feet_on_the_ground    = { 94798, 438590, 1 }, -- Physical damage taken reduced by $s2%.; Thunder Blast reduces damage you take by $438591s1% for $438591d.
    last_stand                      = { 90297, 12975 , 1 }, -- Increases maximum health by $s1% for $d, and instantly heals you for that amount.
    lightning_strikes               = { 94803, 434969, 1 }, -- Damaging enemies with Thunder Clap, $?a137048[Revenge, ][Raging Blow, ]or Execute has a $s1% chance to also strike one with a lightning bolt, dealing $435791s1 Nature damage$?s436152[ and generating ${$436152s3/10} Rage][].; Lightning Strikes occur $s2% more often during Avatar.
    martial_expert                  = { 94812, 429638, 1 }, -- Critical strike damage of your abilities is increased by $s1% and the amount of damage blocked by your critical blocks is increased by $s2%.
    massacre                        = { 90313, 281001, 1 }, -- $?a317320[Condemn][Execute] is now usable on targets below $s2% health.; 
    mountain_of_muscle_and_scars    = { 94806, 429642, 1 }, -- You deal $s1% more damage and take ${$s4/-10}.1% less damage.; Size increased by $s5%.
    no_stranger_to_pain             = { 94815, 429644, 1 }, -- Total damage prevented by Ignore Pain increased by $s1%.
    one_against_many                = { 94799, 429637, 1 }, -- Shockwave, $?c1[Cleave][Revenge], and Whirlwind deal $s1% more damage per target affected up to $s2.
    practiced_strikes               = { 94796, 429647, 1 }, -- $?c1[Mortal Strike and Cleave][Shield Slam and Revenge] damage increased by $s1%.
    precise_might                   = { 94794, 431548, 1 }, -- $?c1[Mortal Strike][Shield Slam] critical strikes grant an additional stack of Colossal Might.
    punish                          = { 90449, 275334, 1 }, -- Shield Slam deals $s1% increased damage, and reduces enemies' damage against you by $275335s1% for $275335d. Multiple punishments may overlap.
    ravager                         = { 90432, 228920, 1 }, -- Throws a whirling weapon at the target location that chases nearby enemies, inflicting $<damage> Physical damage to all enemies over $d. Deals reduced damage beyond $156287s2 targets.; Generates ${$334934s1/10} Rage each time it deals damage.
    rend                            = { 90302, 394062, 1 }, -- Wounds the target, causing $s1 Physical damage instantly and an additional $394063o1 Bleed damage over $394063d.$?s6343[; Thunder Clap affects $6343s5 nearby targets with Rend.; ][]
    revenge                         = { 90298, 6572  , 1 }, -- Swing in a wide arc, dealing $s1 Physical damage to all enemies in front of you. Deals reduced damage beyond $<cap> targets.; Your successful dodges and parries have a chance to make your next Revenge cost no Rage.
    shield_charge                   = { 90317, 385952, 1 }, -- Charge to an enemy with your shield, dealing $385954s1 Physical damage to it and $385954s2 Physical damage to all enemies within 10 yards.; Also stuns the primary target for $385954d.; Generates ${$385954s4/10} Rage.
    shield_specialization           = { 90315, 386011, 2 }, -- Increases Block chance by $s1% and your Block value by $s2%.
    shield_wall                     = { 90312, 871   , 1 }, -- Reduces all damage you take by $s1% for $d.
    show_of_force                   = { 90320, 385843, 1 }, -- Revenge damage increased by $s2% and Revenge increases the damage of your next Thunder Clap by $s1%.
    snap_induction                  = { 94797, 456270, 1 }, -- Activating $?a137048[Demoralizing Shout][Recklessness] grants a charge of Thunder Blast.
    spell_block                     = { 90450, 392966, 1 }, -- You are able to block spells for $392966d.
    steadfast_as_the_peaks          = { 94798, 434970, 1 }, -- Stamina increased by $s1%.; $?s202168[Impending Victory][Victory Rush] increases your maximum health by $437152s3% for $437152d. When this health increase expires, you heal for any amount of the original $?s202168[Impending Victory][Victory Rush] that healed you in excess of your full health.
    storm_bolts                     = { 94817, 436162, 1 }, -- Storm Bolt also hits $s1 additional nearby $Ltarget:targets;, stunning them for $s2 sec, but its cooldown is increased by ${$s3/1000} sec.
    storm_of_steel                  = { 90260, 382953, 1 }, -- $?c3[Ravager's damage is reduced by $s1% but it now has $s4 charges and generates ${$s5/10} additional Rage each time it deals damage.][Bladestorm and Ravager's damage are reduced by $s1% but they now have $s4 charges and generate ${$s5/10} additional Rage each time they deal damage.]
    storm_shield                    = { 94817, 438597, 1 }, -- Intervening a target grants them a shield for $438598d that absorbs magic damage equal to $s1 times your Armor.
    strategist                      = { 90303, 384041, 1 }, -- Devastate, Thunder Clap, Revenge, and Execute have a $s1% chance to reset the remaining cooldown on Shield Slam.
    strength_of_the_mountain        = { 94808, 437068, 1 }, -- Shield Slam damage increased by $s1%.$?a137048[; Demoralizing Shout reduces damage enemies deal to you by an additional ${-$s2}%.][; `s`; Bloodthirst and Rampage damage increased by $s4%.]
    sudden_death                    = { 90320, 29725 , 1 }, -- Your attacks have a chance to make your next $?a317320[Condemn][Execute] cost no Rage, be usable on any target regardless of their health, and deal damage as if you spent $s1 Rage.
    thorims_might                   = { 94792, 436152, 1 }, -- Lightning Strikes generate ${$s1/10} Rage.; $?a137048[Revenge][Raging Blow] and Execute damage increased by $s2%.
    thunder_blast                   = { 94785, 435607, 1 }, -- Shield Slam and Bloodthirst have a $s1% chance to grant you Thunder Blast, stacking up to 2 charges.; $@spellicon435222$@spellname435222; Your next Thunder Clap becomes a Thunder Blast that deals $?a137048[$s2% increased damage as Stormstrike][Stormstrike damage] and generates ${$435222s4/10} Rage.
    thunderlord                     = { 90308, 385840, 1 }, -- Increases the radius of Demoralizing Shout by $s3 yards.; Each enemy hit by Thunder Clap reduces the remaining cooldown on Demoralizing Shout by ${$s1/1000}.1 sec, up to ${$s1*$s2/1000}.1 sec.
    tide_of_battle                  = { 94811, 429641, 1 }, -- Colossal Might increases the damage of your $?c1[Overpower][Revenge] by $440989s3% per stack.
    tough_as_nails                  = { 90450, 385888, 1 }, -- Blocking an attack deals $385890s1 Physical damage to the attacker, ignoring armor. ; Generates high threat.
    unnerving_focus                 = { 90452, 384042, 1 }, -- Last Stand increases your Rage generation by $s1%.
    veteran_vitality                = { 94815, 440993, 1 }, -- When your health is brought below 35%, you gain a Second Wind, healing you for ${$441387s1*$441387t1*$441387d}% of your max health over $441387d.; This effect cannot occur more than once every $proccooldown sec.
    violent_outburst                = { 90265, 386477, 1 }, -- Consuming $s1 rage grants a stack of Seeing Red, which transforms at $386486u stacks into Violent Outburst, causing your next Shield Slam or Thunder Clap to deal $386478s1% increased damage, generate $386478s3% more Rage and grant Ignore Pain.
} )

-- PvP Talents
spec:RegisterPvpTalents( {
    battlefield_commander = 5629, -- (424742) Your Shout abilities have additional effects.; $@spellicon6673 $@spellname6673:; Increases Stamina by $s1%.; $@spellicon12323 $@spellname12323:; Radius increased by $s6%; $@spellicon384100 $@spellname384100:; Range increased by $s2 yds.; $@spellicon5246 $@spellname5246:; Cooldown reduced by ${$s3/-1000} sec.; $@spellicon97462 $@spellname97462:; Removes movement impairing effects and grants $s4% movement speed to allies.; $@spellicon384318 $@spellname384318:; Targets receive $s5% more damage from all sources while bleeding.
    bodyguard             = 168 , -- (213871) Protect an ally, causing $m1% of all Physical damage they take to be transfered to you. When the target takes Physical damage, your Shield Slam cooldown has a $231834s1% chance to be reset. Bodyguard is cancelled if the target is further than $m2 yards from you. Lasts $d.; Only one target can be Bodyguarded at a time.
    demolition            = 5374, -- (329033) Reduces the cooldown of your Shattering Throw or Wrecking Throw by $s1% and increases its damage to absorb shields by an additional ${$s3*5}%.
    disarm                = 24  , -- (236077) Disarm the enemy's weapons and shield for $d. Disarmed creatures deal significantly reduced damage.
    dragon_charge         = 831 , -- (206572) Run at high speed at a distance in front of you. All enemies in your path will take $206579s1 Physical damage and be knocked back.
    morale_killer         = 171 , -- (199023) Reduces the cooldown of Demoralizing Shout by ${($m2/1000)*-1} sec, and Demoralizing Shout now reduces the damage enemies deal to all targets, not just you.
    oppressor             = 845 , -- (205800) [206891] You focus the assault on this target, increasing their damage taken by $s1% for $d. Each unique player that attacks the target increases the damage taken by an additional $s1%, stacking up to $u times.; Your melee attacks refresh the duration of Focused Assault.
    rebound               = 833 , -- (213915) Spell Reflection reflects the next $s3 incoming spells cast on you and reflected spells deal $s1% extra damage to the attacker.; Spell Reflection's cooldown is increased by ${$s2/1000} sec.
    safeguard             = 5626, -- (424654) Intervene now has ${$s1+1} charges and reduces the ally's damage taken by $424655s1% for $424655d.; Intervene's cooldown is increased by ${$s2/1000} sec.
    shield_bash           = 173 , -- (198912) When Shield Slam is used on targets that are casting, it reduces their damage done by $23922s4% for $23922d and the cooldown is instantly reset.
    storm_of_destruction  = 5627, -- (236308) Bladestorm and Ravager now snare all targets you hit by $424597s1% for $424597d and decrease their healing taken by $115804s1% for $115804d.
    thunderstruck         = 175 , -- (199045) Thunder Clap roots all targets it damages for $199042d.
    warbringer            = 5432, -- (356353) Charge roots enemies for ${1+$s1/1000} sec and emanates a shockwave past the target, rooting enemies and dealing $356356s2 Physical damage in a $356356a1 yd cone.
    warpath               = 178 , -- (199086) When landing with Heroic Leap, all targets are stunned for $199085d.
} )

-- Auras
spec:RegisterAuras( {
    -- Damage done increased by $s1%.
    avatar = {
        id = 401150,
        duration = 20.0,
        max_stack = 1,

        -- Affected by:
        -- unstoppable_force[275336] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 50.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_3_VALUE, }
        -- unstoppable_force[275336] #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -50.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_4_VALUE, }
        -- unnerving_focus[384043] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 60.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_2_VALUE, }
    },
    -- Auto-attack damage and speed increased by $s1%.
    battering_ram = {
        id = 394313,
        duration = 20.0,
        max_stack = 1,
    },
    -- Attack power increased by $w1%.$?$w3>0[; Stamina increased by $w3%.][]
    battle_shout = {
        id = 6673,
        duration = 3600.0,
        max_stack = 1,

        -- Affected by:
        -- warrior[137047] #1: { 'type': APPLY_AURA, 'subtype': MOD_GLOBAL_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'value': 11, 'schools': ['physical', 'holy', 'nature'], 'target': TARGET_UNIT_CASTER, }
        -- battlefield_commander[424742] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_3_VALUE, }
    },
    -- Critical strike chance increased by $s1% and reduces the duration of movement impairing effects by $s2%.
    battle_stance = {
        id = 386164,
        duration = 3600,
        max_stack = 1,
    },
    -- Damage taken reduced by $s1%. Healing received increased by $s2%.
    battlescarred_veteran = {
        id = 386397,
        duration = 8.0,
        max_stack = 1,
    },
    -- Immune to Fear, Sap, and Incapacitate effects.
    berserker_rage = {
        id = 18499,
        duration = 6.0,
        max_stack = 1,
    },
    -- Immune to Fear, Sap, and Incapacitate effects.
    berserker_shout = {
        id = 384100,
        duration = 6.0,
        max_stack = 1,
    },
    -- Bleeding for $w1 every $t1 sec.
    bloodbath = {
        id = 113344,
        duration = 6.0,
        tick_time = 1.0,
        pandemic = true,
        max_stack = 1,
    },
    -- $w1% of Physical damage taken is transferred to the Warrior.; When you take Physical attacks, you have a $231834s1% chance to reset the cooldown of the Warrior's Shield Slam.
    bodyguard = {
        id = 213871,
        duration = 60.0,
        tick_time = 1.0,
        max_stack = 1,
    },
    -- Movement slowed by $s1%.
    boneshaker = {
        id = 458480,
        duration = 3.0,
        max_stack = 1,
    },
    -- Movement speed increased by $s1%.
    bounding_stride = {
        id = 202164,
        duration = 3.0,
        max_stack = 1,
    },
    -- Shield Slam deals $w1% increased damage and the amount of damage you block is increased by $w2%.
    brace_for_impact = {
        id = 386029,
        duration = 16.0,
        max_stack = 1,
    },
    -- Your next $U $?a137048[Shield Slams][Bloodthirsts] have no cooldown$?a137050[, deal $s2% increased damage, and generate ${$s3/10} additional Rage][].
    burst_of_power = {
        id = 437121,
        duration = 15.0,
        max_stack = 1,
    },
    -- Taunted.
    challenging_shout = {
        id = 1161,
        duration = 6.0,
        max_stack = 1,
    },
    -- Tethered by chains and taking $w4 Physical damage every $t4 sec.$?e4[; Taking $w5% additional critical strike damage from $@auracaster.][]
    champions_spear = {
        id = 376080,
        duration = 4.0,
        tick_time = 1.0,
        max_stack = 1,

        -- Affected by:
        -- champions_might[386284] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER_BY_LABEL, 'points': 2000.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
        -- piercing_challenge[382948] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 50.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- piercing_challenge[382948] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 100.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_3_VALUE, }
        -- piercing_challenge[382948] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 50.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- unnerving_focus[384043] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 60.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_3_VALUE, }
    },
    -- Rooted.
    charge = {
        id = 105771,
        duration = 1.0,
        max_stack = 1,

        -- Affected by:
        -- warbringer[356353] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'trigger_spell': 105771, 'points': 1000.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
    },
    -- Damage dealt by Demolish increased by $w1%.; $?(a429641&c1)[Damage dealt by Overpower increased by $w3%.]?$?(a429641&c3)[Damage dealt by Revenge increased by $w3%.][]; $?a440995[Damage dealt by Rend and Deep Wounds increased by $w2%.][]
    colossal_might = {
        id = 440989,
        duration = 24.0,
        max_stack = 1,

        -- Affected by:
        -- dominance_of_the_colossus[429636] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER_BY_LABEL, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': MAX_STACKS, }
    },
    -- Taking $s2% more damage from $@auracaster.
    concussive_blows = {
        id = 383116,
        duration = 10.0,
        max_stack = 1,
    },
    -- Ability damage dealt increased by $w1%.
    dance_of_death = {
        id = 459572,
        duration = 2.0,
        max_stack = 1,
    },
    -- Bleeding for $w1 every $t1 sec.
    deep_wounds = {
        id = 115767,
        duration = 15.0,
        tick_time = 3.0,
        pandemic = true,
        max_stack = 1,

        -- Affected by:
        -- bloodborne[385704] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- thunderous_roar[397364] #2: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'points': 30.0, 'radius': 12.0, 'target': TARGET_DEST_CASTER, 'target2': TARGET_UNIT_DEST_AREA_ENEMY, }
        -- colossal_might[440989] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
    },
    -- Damage taken reduced by $s1%.; $?a452494[Magic damage taken reduced by an additional $s3%.][]; $?a137048[][Damage done reduced by $s2%.]
    defensive_stance = {
        id = 386208,
        duration = 3600,
        max_stack = 1,

        -- Affected by:
        -- protection_warrior[137048] #16: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER_BY_LABEL, 'points': -1.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_1_VALUE, }
        -- protection_warrior[137048] #17: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER_BY_LABEL, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_2_VALUE, }
        -- fight_through_the_flames[452494] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER_BY_LABEL, 'points': -6.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_3_VALUE, }
    },
    -- $?s199023[Demoralized, dealing $w2% less damage.][Demoralized, dealing $w1% less damage to $@auracaster.]$?s202743[; Taking $w3% increased damage from $@auracaster.][]
    demoralizing_shout = {
        id = 1160,
        duration = 8.0,
        max_stack = 1,

        -- Affected by:
        -- warrior[137047] #1: { 'type': APPLY_AURA, 'subtype': MOD_GLOBAL_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'value': 11, 'schools': ['physical', 'holy', 'nature'], 'target': TARGET_UNIT_CASTER, }
        -- neltharions_fury[203524] #3: { 'type': APPLY_AURA, 'subtype': ALLOW_ONLY_ABILITY, 'target': TARGET_UNIT_CASTER, }
        -- booming_voice[202743] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 300.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_5_VALUE, }
        -- booming_voice[202743] #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_3_VALUE, }
        -- booming_voice[202743] #2: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_4_VALUE, }
        -- strength_of_the_mountain[437068] #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -5.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_1_VALUE, }
        -- strength_of_the_mountain[437068] #2: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -5.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_2_VALUE, }
        -- thunderlord[385840] #2: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 5.0, 'modifies': RADIUS, }
        -- morale_killer[199023] #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -15000.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
        -- unnerving_focus[384043] #5: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 60.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_5_VALUE, }
    },
    -- Disarmed!
    disarm = {
        id = 236077,
        duration = 5.0,
        max_stack = 1,
    },
    -- Taunted.
    disrupting_shout = {
        id = 386071,
        duration = 6.0,
        max_stack = 1,
    },
    -- Damage taken increased by $m1%.
    focused_assault = {
        id = 206891,
        duration = 6.0,
        max_stack = 1,
    },
    -- Movement slowed by $s1%.
    hamstring = {
        id = 1715,
        duration = 15.0,
        max_stack = 1,

        -- Affected by:
        -- protection_warrior[137048] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- protection_warrior[137048] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- warrior[137047] #1: { 'type': APPLY_AURA, 'subtype': MOD_GLOBAL_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'value': 11, 'schools': ['physical', 'holy', 'nature'], 'target': TARGET_UNIT_CASTER, }
        -- avatar[107574] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.75, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- avatar[107574] #3: { 'type': APPLY_AURA_ON_PET, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.75, 'points': 20.0, 'value': 22, 'schools': ['holy', 'fire', 'frost'], 'target': TARGET_UNIT_CASTER, }
        -- avatar[401150] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.75, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- avatar[401150] #8: { 'type': APPLY_AURA_ON_PET, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.75, 'points': 20.0, 'value': 22, 'schools': ['holy', 'fire', 'frost'], 'target': TARGET_UNIT_CASTER, }
        -- dual_wield_specialization[382900] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- dual_wield_specialization[382900] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- onehanded_weapon_specialization[382895] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- onehanded_weapon_specialization[382895] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- twohanded_weapon_specialization[382896] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- twohanded_weapon_specialization[382896] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- demoralizing_shout[1160] #2: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'pvp_multiplier': 0.5, 'radius': 10.0, 'target': TARGET_SRC_CASTER, 'target2': TARGET_UNIT_SRC_AREA_ENEMY, }
        -- martial_expert[429638] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_15, }
        -- mountain_of_muscle_and_scars[429642] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- mountain_of_muscle_and_scars[429642] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- champions_spear[376080] #4: { 'type': APPLY_AURA, 'subtype': MOD_CRITICAL_DAMAGE_TAKEN_FROM_CASTER, 'points': 25.0, 'radius': 5.0, 'target': TARGET_UNIT_DEST_AREA_ENEMY, }
        -- whirlwind[85739] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'attributes': ['Suppress Points Stacking'], 'points': 4.0, 'target': TARGET_UNIT_CASTER, 'modifies': CHAINED_TARGETS, }
        -- fury_warrior[137050] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 50.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- fury_warrior[137050] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 50.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- dance_of_death[459572] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
    },
    -- Ignoring $s2% of damage taken, preventing $w1 total damage.
    ignore_pain = {
        id = 190456,
        duration = 12.0,
        max_stack = 1,

        -- Affected by:
        -- neltharions_fury[203524] #3: { 'type': APPLY_AURA, 'subtype': ALLOW_ONLY_ABILITY, 'target': TARGET_UNIT_CASTER, }
        -- demolish[436358] #2: { 'type': APPLY_AURA, 'subtype': ALLOW_ONLY_ABILITY, 'target': TARGET_UNIT_CASTER, }
    },
    -- Melee and ranged attacks made against you will be made against $@auracaster instead.
    intervene = {
        id = 147833,
        duration = 6.0,
        max_stack = 1,

        -- Affected by:
        -- honed_reflexes[391271] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -5.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
        -- demolish[436358] #2: { 'type': APPLY_AURA, 'subtype': ALLOW_ONLY_ABILITY, 'target': TARGET_UNIT_CASTER, }
    },
    -- Disoriented.
    intimidating_shout = {
        id = 316595,
        duration = 15.0,
        max_stack = 1,

        -- Affected by:
        -- battlefield_commander[424742] #2: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -15000.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
    },
    -- Haste increased by $s1%.
    into_the_fray = {
        id = 202602,
        duration = 3600,
        max_stack = 1,
    },
    -- Execute damage increased by $s1%.
    juggernaut = {
        id = 393968,
        duration = 20.0,
        max_stack = 1,
    },
    -- Damage taken reduced by $w1%.
    keep_your_feet_on_the_ground = {
        id = 438591,
        duration = 5.0,
        max_stack = 1,
    },
    -- Maximum health increased by $s1%.
    last_stand = {
        id = 12975,
        duration = 15.0,
        max_stack = 1,

        -- Affected by:
        -- neltharions_fury[203524] #3: { 'type': APPLY_AURA, 'subtype': ALLOW_ONLY_ABILITY, 'target': TARGET_UNIT_CASTER, }
        -- bolster[280001] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -60000.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
        -- demolish[436358] #2: { 'type': APPLY_AURA, 'subtype': ALLOW_ONLY_ABILITY, 'target': TARGET_UNIT_CASTER, }
    },
    -- Healing effects received reduced by $w1%.
    mortal_wounds = {
        id = 115804,
        duration = 10.0,
        max_stack = 1,
    },
    -- Critically blocking all incoming attacks, and dealing $203526s1 Shadowflame damage to all enemies in a $203526A1 yard cone every $t2 sec.
    neltharions_fury = {
        id = 203524,
        duration = 3.0,
        max_stack = 1,
    },
    -- Suffering $o3 Fire damage over $d.
    odyns_fury = {
        id = 205546,
        duration = 4.0,
        tick_time = 1.0,
        max_stack = 1,
    },
    -- Movement slowed by $s1%.
    piercing_howl = {
        id = 12323,
        duration = 8.0,
        max_stack = 1,

        -- Affected by:
        -- warrior[137047] #1: { 'type': APPLY_AURA, 'subtype': MOD_GLOBAL_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'value': 11, 'schools': ['physical', 'holy', 'nature'], 'target': TARGET_UNIT_CASTER, }
        -- battlefield_commander[424742] #5: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 50.0, 'target': TARGET_UNIT_CASTER, 'modifies': RADIUS, }
    },
    -- Punished, dealing $w1% less damage to $@auracaster.
    punish = {
        id = 275335,
        duration = 9.0,
        max_stack = 1,
    },
    -- Health increased by $97462s1% of maximum.$?a424742[; Movement speed increased by $424742s4%.][]
    rallying_cry = {
        id = 97463,
        duration = 10.0,
        max_stack = 1,

        -- Affected by:
        -- battlefield_commander[424742] #3: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 30.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_3_VALUE, }
    },
    -- Ravager is currently active.
    ravager = {
        id = 228920,
        duration = 12.0,
        tick_time = 2.0,
        pandemic = true,
        max_stack = 1,

        -- Affected by:
        -- storm_of_steel[382953] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -30.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- storm_of_steel[382953] #1: { 'type': APPLY_AURA, 'subtype': MOD_MAX_CHARGES, 'points': 1.0, 'target': TARGET_UNIT_CASTER, }
        -- storm_of_steel[382953] #2: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -90000.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
    },
    -- Bleeding for $w1 damage every $t1 sec.
    rend = {
        id = 394063,
        duration = 15.0,
        tick_time = 3.0,
        pandemic = true,
        max_stack = 1,

        -- Affected by:
        -- colossal_might[440989] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- whirlwind[85739] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'attributes': ['Suppress Points Stacking'], 'points': 4.0, 'target': TARGET_UNIT_CASTER, 'modifies': CHAINED_TARGETS, }
    },
    -- Your next Revenge is free.
    revenge = {
        id = 5302,
        duration = 6.0,
        max_stack = 1,
    },
    -- Damage taken reduced by $w1%.
    safeguard = {
        id = 424655,
        duration = 5.0,
        max_stack = 1,
    },
    -- Healing $202147s1% health every $202147t1 sec.
    second_wind = {
        id = 351077,
        duration = 3600,
        max_stack = 1,
    },
    -- At $u stacks transforms into Violent Outburst, causing your next Shield Slam or Thunderclap to to deal $386478s1%~ increased damage, generate $386478s3%~ more Rage and grant Ignore Pain.
    seeing_red = {
        id = 386486,
        duration = 30.0,
        max_stack = 1,
    },
    -- Block chance increased by $s1%.
    shield_block = {
        id = 132404,
        duration = 6.0,
        max_stack = 1,

        -- Affected by:
        -- enduring_defenses[386027] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 2000.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
    },
    -- Stunned.
    shield_charge = {
        id = 385954,
        duration = 4.0,
        max_stack = 1,

        -- Affected by:
        -- battering_ram[394312] #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': CRIT_CHANCE, }
        -- battering_ram[394312] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_15, }
        -- champions_bulwark[386328] #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 200.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_4_VALUE, }
        -- champions_bulwark[386328] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- unnerving_focus[384043] #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 60.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_4_VALUE, }
    },
    -- All damage taken reduced by $w1%.
    shield_wall = {
        id = 871,
        duration = 8.0,
        max_stack = 1,

        -- Affected by:
        -- neltharions_fury[203524] #3: { 'type': APPLY_AURA, 'subtype': ALLOW_ONLY_ABILITY, 'target': TARGET_UNIT_CASTER, }
        -- honed_reflexes[391271] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -5.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
        -- defenders_aegis[397103] #1: { 'type': APPLY_AURA, 'subtype': MOD_MAX_CHARGES, 'points': 1.0, 'target': TARGET_UNIT_CASTER, }
        -- demolish[436358] #2: { 'type': APPLY_AURA, 'subtype': ALLOW_ONLY_ABILITY, 'target': TARGET_UNIT_CASTER, }
    },
    -- Stunned.
    shockwave = {
        id = 132168,
        duration = 2.0,
        max_stack = 1,

        -- Affected by:
        -- protection_warrior[137048] #14: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 50.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- avatar[401150] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- rumbling_earth[275339] #2: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 6.0, 'target': TARGET_UNIT_CASTER, 'modifies': RADIUS, }
        -- boneshaker[429639] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 1000.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
        -- earthquaker[440992] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -5000.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
        -- unnerving_focus[384043] #5: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 60.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_5_VALUE, }
    },
    -- Your next Thunder Clap deals $w1% increased damage.
    show_of_force = {
        id = 385842,
        duration = 12.0,
        max_stack = 1,
    },
    -- You are able to block spells cast against you.
    spell_block = {
        id = 392966,
        duration = 30.0,
        max_stack = 1,
    },
    -- Magical damage taken reduced by $s1%.
    spell_reflection = {
        id = 385391,
        duration = 5.0,
        max_stack = 1,

        -- Affected by:
        -- protection_warrior[137048] #18: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -5.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_1_VALUE, }
        -- neltharions_fury[203524] #3: { 'type': APPLY_AURA, 'subtype': ALLOW_ONLY_ABILITY, 'target': TARGET_UNIT_CASTER, }
        -- honed_reflexes[391271] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -5.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
        -- demolish[436358] #2: { 'type': APPLY_AURA, 'subtype': ALLOW_ONLY_ABILITY, 'target': TARGET_UNIT_CASTER, }
        -- rebound[213915] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'amplitude': 1.0, 'points': 50.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_TAKEN_BY_PCT, }
    },
    -- Maximum health increased by $s3%.
    steadfast_as_the_peaks = {
        id = 437152,
        duration = 5.0,
        max_stack = 1,
    },
    -- Stunned.
    storm_bolt = {
        id = 132169,
        duration = 4.0,
        max_stack = 1,
    },
    -- Movement slowed by $s1%.
    storm_of_destruction = {
        id = 424597,
        duration = 6.0,
        max_stack = 1,
    },
    -- Absorbs $w1 magic damage.
    storm_shield = {
        id = 438598,
        duration = 5.0,
        max_stack = 1,
    },
    -- Taunted.
    taunt = {
        id = 355,
        duration = 3.0,
        max_stack = 1,

        -- Affected by:
        -- neltharions_fury[203524] #3: { 'type': APPLY_AURA, 'subtype': ALLOW_ONLY_ABILITY, 'target': TARGET_UNIT_CASTER, }
        -- demolish[436358] #2: { 'type': APPLY_AURA, 'subtype': ALLOW_ONLY_ABILITY, 'target': TARGET_UNIT_CASTER, }
    },
    -- Your next Thunder Clap becomes a Thunder Blast that deals Stormstrike damage and generates ${$435222s4/10} Rage.
    thunder_blast = {
        id = 435615,
        duration = 15.0,
        max_stack = 1,
    },
    -- Bleeding for $w1 damage every $t1 sec.$?a424742[; Damage taken increased by $w2%.][]
    thunderous_roar = {
        id = 397364,
        duration = 8.0,
        tick_time = 2.0,
        pandemic = true,
        max_stack = 1,

        -- Affected by:
        -- thunderous_words[384969] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 2000.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
        -- uproar[391572] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -45000.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
        -- bloodborne[385704] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- battlefield_commander[424742] #4: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER_BY_LABEL, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_2_VALUE, }
        -- thunderous_roar[397364] #2: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'points': 30.0, 'radius': 12.0, 'target': TARGET_DEST_CASTER, 'target2': TARGET_UNIT_DEST_AREA_ENEMY, }
        -- unnerving_focus[384043] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 60.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_3_VALUE, }
    },
    -- Rooted.
    thunderstruck = {
        id = 199042,
        duration = 4.0,
        max_stack = 1,
    },
    -- Bleeding for $w1 every $t1 sec.
    trauma = {
        id = 215537,
        duration = 6.0,
        tick_time = 2.0,
        pandemic = true,
        max_stack = 1,
    },
    -- Rage generation increased by $w1%.
    unnerving_focus = {
        id = 384043,
        duration = 15.0,
        max_stack = 1,
    },
    -- Your next Thunder Clap and Shield Slam are more effective and grant Ignore Pain.
    violent_outburst = {
        id = 386478,
        duration = 30.0,
        max_stack = 1,
    },
    -- Movement speed increased by $s2%.
    war_machine = {
        id = 262232,
        duration = 8.0,
        max_stack = 1,

        -- Affected by:
        -- unnerving_focus[384043] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 60.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_1_VALUE, }
    },
    -- Rooted.
    warbringer = {
        id = 356356,
        duration = 2.0,
        max_stack = 1,
    },
    -- Stunned.
    warpath = {
        id = 199085,
        duration = 3.0,
        max_stack = 1,
    },
    -- Your next single-target attack strikes up to $w1 additional targets for $w3% damage.
    whirlwind = {
        id = 85739,
        duration = 20.0,
        max_stack = 1,
    },
    -- Auto attack speed increased.
    wild_strikes = {
        id = 392778,
        duration = 10.0,
        max_stack = 1,
    },
    -- Taking $w2% increased damage from $@auracaster.; Dealing ${$W1*-1.0}.1% less damage to $@auracaster.
    wrecked = {
        id = 447513,
        duration = 10.0,
        max_stack = 1,
    },
} )

-- Abilities
spec:RegisterAbilities( {
    -- Transform into a colossus for $d, causing you to deal $s1% increased damage$?s394314[, take $394314s2% reduced damage][] and removing all roots and snares.; Generates ${$s2/10} Rage.
    avatar = {
        id = 107574,
        cast = 0.0,
        cooldown = 90.0,
        gcd = "none",

        talent = "avatar",
        startsCombat = false,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.75, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- #1: { 'type': ENERGIZE, 'subtype': NONE, 'points': 100.0, 'target': TARGET_UNIT_CASTER, 'resource': rage, }
        -- #2: { 'type': APPLY_AURA, 'subtype': MOD_AUTOATTACK_DAMAGE, 'pvp_multiplier': 0.75, 'points': 20.0, 'target': TARGET_UNIT_CASTER, }
        -- #3: { 'type': APPLY_AURA_ON_PET, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.75, 'points': 20.0, 'value': 22, 'schools': ['holy', 'fire', 'frost'], 'target': TARGET_UNIT_CASTER, }
        -- #4: { 'type': APPLY_AURA, 'subtype': MOD_RESISTANCE_PCT, 'value': 127, 'schools': ['physical', 'holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], 'target': TARGET_UNIT_CASTER, }
        -- #5: { 'type': SCRIPT_EFFECT, 'subtype': NONE, 'target': TARGET_UNIT_CASTER, }
        -- #6: { 'type': APPLY_AURA, 'subtype': MOD_SCALE, 'points': 30.0, 'target': TARGET_UNIT_CASTER, }
        -- #7: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -1500.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }

        -- Affected by:
        -- unstoppable_force[275336] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 50.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_3_VALUE, }
        -- unstoppable_force[275336] #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -50.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_4_VALUE, }
        -- unnerving_focus[384043] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 60.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_2_VALUE, }
    },

    -- Transform into a colossus for $d, causing you to deal $s1% increased damage$?s394314[, take $394314s2% reduced damage][] and removing all roots and snares.; Generates ${$s2/10} Rage.
    avatar_401150 = {
        id = 401150,
        cast = 0.0,
        cooldown = 90.0,
        gcd = "none",

        talent = "avatar_401150",
        startsCombat = false,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.75, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- #1: { 'type': ENERGIZE, 'subtype': NONE, 'points': 100.0, 'target': TARGET_UNIT_CASTER, 'resource': rage, }
        -- #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
        -- #4: { 'type': APPLY_AURA, 'subtype': MOD_RESISTANCE_PCT, 'value': 127, 'schools': ['physical', 'holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], 'target': TARGET_UNIT_CASTER, }
        -- #5: { 'type': APPLY_AURA, 'subtype': MOD_AUTOATTACK_DAMAGE, 'pvp_multiplier': 0.75, 'points': 20.0, 'target': TARGET_UNIT_CASTER, }
        -- #6: { 'type': SCRIPT_EFFECT, 'subtype': NONE, 'target': TARGET_UNIT_CASTER, }
        -- #7: { 'type': APPLY_AURA, 'subtype': MOD_SCALE, 'points': 30.0, 'target': TARGET_UNIT_CASTER, }
        -- #8: { 'type': APPLY_AURA_ON_PET, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.75, 'points': 20.0, 'value': 22, 'schools': ['holy', 'fire', 'frost'], 'target': TARGET_UNIT_CASTER, }

        -- Affected by:
        -- unstoppable_force[275336] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 50.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_3_VALUE, }
        -- unstoppable_force[275336] #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -50.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_4_VALUE, }
        -- unnerving_focus[384043] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 60.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_2_VALUE, }
        from = "spec_talent",
    },

    -- Increases the attack power of all raid and party members within $a1 yards by $s1% for $d.
    battle_shout = {
        id = 6673,
        cast = 0.0,
        cooldown = 15.0,
        gcd = "global",

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': MOD_ATTACK_POWER_PCT, 'points': 5.0, 'radius': 100.0, 'target': TARGET_UNIT_CASTER_AREA_RAID, }
        -- #1: { 'type': APPLY_AURA, 'subtype': MOD_RANGED_ATTACK_POWER_PCT, 'points': 5.0, 'radius': 100.0, 'target': TARGET_UNIT_CASTER_AREA_RAID, }
        -- #2: { 'type': APPLY_AURA, 'subtype': MOD_TOTAL_STAT_PERCENTAGE, 'radius': 100.0, 'target': TARGET_UNIT_CASTER_AREA_RAID, 'modifies': unknown, }

        -- Affected by:
        -- warrior[137047] #1: { 'type': APPLY_AURA, 'subtype': MOD_GLOBAL_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'value': 11, 'schools': ['physical', 'holy', 'nature'], 'target': TARGET_UNIT_CASTER, }
        -- battlefield_commander[424742] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_3_VALUE, }
    },

    -- A balanced combat state that increases the critical strike chance of your abilities by $s1% and reduces the duration of movement impairing effects by $s2%. ; Lasts until canceled.
    battle_stance = {
        id = 386164,
        cast = 0.0,
        cooldown = 3.0,
        gcd = "none",

        talent = "battle_stance",
        startsCombat = false,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': MOD_CRIT_PCT, 'points': 3.0, 'target': TARGET_UNIT_CASTER, }
        -- #1: { 'type': APPLY_AURA, 'subtype': MECHANIC_DURATION_MOD, 'points': -10.0, 'value': 11, 'schools': ['physical', 'holy', 'nature'], 'target': TARGET_UNIT_CASTER, }
        -- #2: { 'type': APPLY_AURA, 'subtype': MECHANIC_DURATION_MOD, 'points': -10.0, 'value': 7, 'schools': ['physical', 'holy', 'fire'], 'target': TARGET_UNIT_CASTER, }
    },

    -- Go berserk, removing and granting immunity to Fear, Sap, and Incapacitate effects for $d.
    berserker_rage = {
        id = 18499,
        cast = 0.0,
        cooldown = 60.0,
        gcd = "none",

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': MECHANIC_IMMUNITY, 'points': 100.0, 'target': TARGET_UNIT_CASTER, 'mechanic': 5, }
        -- #1: { 'type': APPLY_AURA, 'subtype': MECHANIC_IMMUNITY, 'target': TARGET_UNIT_CASTER, 'mechanic': 14, }
        -- #2: { 'type': APPLY_AURA, 'subtype': MECHANIC_IMMUNITY, 'target': TARGET_UNIT_CASTER, 'mechanic': 30, }
        -- #3: { 'type': APPLY_AURA, 'subtype': MECHANIC_IMMUNITY, 'target': TARGET_UNIT_CASTER, 'mechanic': 23, }
    },

    -- Go berserk, removing and granting immunity to Fear, Sap, and Incapacitate effects for $d.; Also remove fear effects from group members within $384102A1 yds.
    berserker_shout = {
        id = 384100,
        cast = 0.0,
        cooldown = 60.0,
        gcd = "none",

        talent = "berserker_shout",
        startsCombat = false,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': MECHANIC_IMMUNITY, 'points': 100.0, 'target': TARGET_UNIT_CASTER, 'mechanic': 5, }
        -- #1: { 'type': APPLY_AURA, 'subtype': MECHANIC_IMMUNITY, 'target': TARGET_UNIT_CASTER, 'mechanic': 14, }
        -- #2: { 'type': APPLY_AURA, 'subtype': MECHANIC_IMMUNITY, 'target': TARGET_UNIT_CASTER, 'mechanic': 30, }
        -- #3: { 'type': APPLY_AURA, 'subtype': MECHANIC_IMMUNITY, 'target': TARGET_UNIT_CASTER, 'mechanic': 23, }
        -- #4: { 'type': TRIGGER_SPELL, 'subtype': NONE, 'trigger_spell': 384102, 'target': TARGET_UNIT_CASTER, }
    },

    -- Protect an ally, causing $m1% of all Physical damage they take to be transfered to you. When the target takes Physical damage, your Shield Slam cooldown has a $231834s1% chance to be reset. Bodyguard is cancelled if the target is further than $m2 yards from you. Lasts $d.; Only one target can be Bodyguarded at a time.
    bodyguard = {
        id = 213871,
        color = 'pvp_talent',
        cast = 0.0,
        cooldown = 15.0,
        gcd = "global",

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': SPLIT_DAMAGE_PCT, 'amplitude': 1.0, 'points': 40.0, 'value': 1, 'schools': ['physical'], 'target': TARGET_UNIT_TARGET_ALLY, }
        -- #1: { 'type': APPLY_AURA, 'subtype': PERIODIC_DUMMY, 'tick_time': 1.0, 'points': 20.0, 'target': TARGET_UNIT_TARGET_ALLY, }
    },

    -- Taunts all enemies within $A1 yds to attack you for $d.
    challenging_shout = {
        id = 1161,
        cast = 0.0,
        cooldown = 120.0,
        gcd = "none",

        talent = "challenging_shout",
        startsCombat = true,

        -- Effects:
        -- #0: { 'type': ATTACK_ME, 'subtype': NONE, 'radius': 10.0, 'target': TARGET_SRC_CASTER, 'target2': TARGET_UNIT_SRC_AREA_ENEMY, }
        -- #1: { 'type': APPLY_AURA, 'subtype': MOD_TAUNT, 'points': 400.0, 'radius': 10.0, 'target': TARGET_SRC_CASTER, 'target2': TARGET_UNIT_SRC_AREA_ENEMY, }
    },

    -- Throw a spear at the target location, dealing $376080s1 Physical damage instantly and an additional $376080o4 damage over $376081d. Deals reduced damage beyond $<cap> targets.; Enemies hit are chained to the spear's location for the duration.; Generates $/10;376080s3 Rage.
    champions_spear = {
        id = 376079,
        cast = 0.0,
        cooldown = 90.0,
        gcd = "global",

        talent = "champions_spear",
        startsCombat = false,

        -- Effects:
        -- #0: { 'type': TRIGGER_MISSILE, 'subtype': NONE, 'trigger_spell': 376080, 'radius': 5.0, 'target': TARGET_DEST_DEST, }
        -- #1: { 'type': TRIGGER_MISSILE, 'subtype': NONE, 'trigger_spell': 376081, 'radius': 5.0, 'target': TARGET_DEST_DEST, }
    },

    -- Charge to an enemy, dealing $126664s2 Physical damage, rooting it for $105771d$?s103828[, and stunning it for $7922d][].; Generates $/10;s2 Rage.
    charge = {
        id = 100,
        cast = 0.0,
        cooldown = 1.0,
        gcd = "none",

        startsCombat = true,

        -- Effects:
        -- #0: { 'type': DUMMY, 'subtype': NONE, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #1: { 'type': ENERGIZE, 'subtype': NONE, 'points': 200.0, 'target': TARGET_UNIT_CASTER, 'resource': rage, }

        -- Affected by:
        -- warrior[137047] #1: { 'type': APPLY_AURA, 'subtype': MOD_GLOBAL_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'value': 11, 'schools': ['physical', 'holy', 'nature'], 'target': TARGET_UNIT_CASTER, }
        -- double_time[103827] #0: { 'type': APPLY_AURA, 'subtype': MOD_MAX_CHARGES, 'points': 1.0, 'target': TARGET_UNIT_CASTER, }
        -- demolish[436358] #2: { 'type': APPLY_AURA, 'subtype': ALLOW_ONLY_ABILITY, 'target': TARGET_UNIT_CASTER, }
        -- unnerving_focus[384043] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 60.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_2_VALUE, }
    },

    -- A defensive combat state that reduces all damage you take by $s1%$?a452494[ and all magic damage you take by an additional $s3%][]$?a137048[][, and all damage you deal by $s2%]. ; Lasts until canceled.
    defensive_stance = {
        id = 386208,
        cast = 0.0,
        cooldown = 3.0,
        gcd = "none",

        talent = "defensive_stance",
        startsCombat = false,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': MOD_DAMAGE_PERCENT_TAKEN, 'pvp_multiplier': 0.66666, 'points': -15.0, 'schools': ['physical', 'holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], 'target': TARGET_UNIT_CASTER, }
        -- #1: { 'type': APPLY_AURA, 'subtype': MOD_DAMAGE_PERCENT_DONE, 'pvp_multiplier': 1.5, 'points': -10.0, 'value': 127, 'schools': ['physical', 'holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], 'target': TARGET_UNIT_CASTER, }
        -- #2: { 'type': APPLY_AURA, 'subtype': MOD_DAMAGE_PERCENT_TAKEN, 'schools': ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], 'target': TARGET_UNIT_CASTER, }

        -- Affected by:
        -- protection_warrior[137048] #16: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER_BY_LABEL, 'points': -1.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_1_VALUE, }
        -- protection_warrior[137048] #17: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER_BY_LABEL, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_2_VALUE, }
        -- fight_through_the_flames[452494] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER_BY_LABEL, 'points': -6.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_3_VALUE, }
    },

    -- Unleash a series of precise and powerful strikes against your target, dealing ${$440884s1+$440886s1+$440888s1} damage to it, and $440888s1 damage to enemies within 8 yds of it. Deals reduced damage beyond $s1 targets.; While channeling Demolish, you take $s4% less damage and are immune to stuns, knockbacks, and forced movement effects.; You can block, parry, dodge, and use certain defensive abilities while channeling Demolish.
    demolish = {
        id = 436358,
        cast = 2.0,
        channeled = true,
        cooldown = 45.0,
        gcd = "global",

        talent = "demolish",
        startsCombat = true,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': PERIODIC_DUMMY, 'tick_time': 0.2, 'points': 8.0, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #1: { 'type': APPLY_AURA, 'subtype': MOD_DECREASE_SPEED, 'points': -200.0, 'target': TARGET_UNIT_CASTER, }
        -- #2: { 'type': APPLY_AURA, 'subtype': ALLOW_ONLY_ABILITY, 'target': TARGET_UNIT_CASTER, }
        -- #3: { 'type': APPLY_AURA, 'subtype': MOD_DAMAGE_PERCENT_TAKEN, 'points': -10.0, 'schools': ['physical', 'holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], 'target': TARGET_UNIT_CASTER, }
        -- #4: { 'type': APPLY_AURA, 'subtype': MECHANIC_IMMUNITY, 'target': TARGET_UNIT_CASTER, 'mechanic': 12, }
        -- #5: { 'type': APPLY_AURA, 'subtype': EFFECT_IMMUNITY, 'value': 98, 'schools': ['holy', 'shadow', 'arcane'], 'target': TARGET_UNIT_CASTER, }
        -- #6: { 'type': APPLY_AURA, 'subtype': EFFECT_IMMUNITY, 'value': 138, 'schools': ['holy', 'nature'], 'target': TARGET_UNIT_CASTER, }
        -- #7: { 'type': APPLY_AURA, 'subtype': EFFECT_IMMUNITY, 'value': 144, 'schools': ['frost'], 'target': TARGET_UNIT_CASTER, }
        -- #8: { 'type': APPLY_AURA, 'subtype': MECHANIC_IMMUNITY_MASK, 'value': 2142, 'schools': ['holy', 'fire', 'nature', 'frost', 'arcane'], 'target': TARGET_UNIT_CASTER, }

        -- Affected by:
        -- colossal_might[440989] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
    },

    -- $?s199023[Demoralizes all enemies within $A2 yards, reducing the damage they do by $s2% for $d.][Demoralizes all enemies within $A2 yards, reducing the damage they deal to you by $s1% for $d.]$?s202743[; Generates ${$m5/10} Rage.][]
    demoralizing_shout = {
        id = 1160,
        cast = 0.0,
        cooldown = 45.0,
        gcd = "global",

        talent = "demoralizing_shout",
        startsCombat = true,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': MOD_IGNORE_TARGET_RESIST, 'points': -20.0, 'value': 127, 'schools': ['physical', 'holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], 'radius': 10.0, 'target': TARGET_SRC_CASTER, 'target2': TARGET_UNIT_SRC_AREA_ENEMY, }
        -- #1: { 'type': APPLY_AURA, 'subtype': MOD_DAMAGE_PERCENT_DONE, 'points': -25.0, 'value': 127, 'schools': ['physical', 'holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], 'radius': 10.0, 'target': TARGET_SRC_CASTER, 'target2': TARGET_UNIT_SRC_AREA_ENEMY, }
        -- #2: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'pvp_multiplier': 0.5, 'radius': 10.0, 'target': TARGET_SRC_CASTER, 'target2': TARGET_UNIT_SRC_AREA_ENEMY, }
        -- #3: { 'type': APPLY_AURA, 'subtype': MOD_MELEE_DAMAGE_FROM_CASTER, 'radius': 10.0, 'target': TARGET_SRC_CASTER, 'target2': TARGET_UNIT_SRC_AREA_ENEMY, }
        -- #4: { 'type': ENERGIZE, 'subtype': NONE, 'target': TARGET_UNIT_CASTER, 'resource': rage, }

        -- Affected by:
        -- warrior[137047] #1: { 'type': APPLY_AURA, 'subtype': MOD_GLOBAL_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'value': 11, 'schools': ['physical', 'holy', 'nature'], 'target': TARGET_UNIT_CASTER, }
        -- neltharions_fury[203524] #3: { 'type': APPLY_AURA, 'subtype': ALLOW_ONLY_ABILITY, 'target': TARGET_UNIT_CASTER, }
        -- booming_voice[202743] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 300.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_5_VALUE, }
        -- booming_voice[202743] #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_3_VALUE, }
        -- booming_voice[202743] #2: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_4_VALUE, }
        -- strength_of_the_mountain[437068] #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -5.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_1_VALUE, }
        -- strength_of_the_mountain[437068] #2: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -5.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_2_VALUE, }
        -- thunderlord[385840] #2: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 5.0, 'modifies': RADIUS, }
        -- morale_killer[199023] #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -15000.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
        -- unnerving_focus[384043] #5: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 60.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_5_VALUE, }
    },

    -- A direct strike, dealing $s1 Physical damage.
    devastate = {
        id = 20243,
        cast = 0.0,
        cooldown = 0.0,
        gcd = "global",

        startsCombat = true,

        -- Effects:
        -- #0: { 'type': SCHOOL_DAMAGE, 'subtype': NONE, 'ap_bonus': 0.6405, 'variance': 0.05, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #1: { 'type': DUMMY, 'subtype': NONE, 'target': TARGET_UNIT_CASTER, }
        -- #2: { 'type': ENERGIZE, 'subtype': NONE, 'target': TARGET_UNIT_CASTER, 'resource': rage, }

        -- Affected by:
        -- protection_warrior[137048] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- protection_warrior[137048] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- warrior[137047] #1: { 'type': APPLY_AURA, 'subtype': MOD_GLOBAL_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'value': 11, 'schools': ['physical', 'holy', 'nature'], 'target': TARGET_UNIT_CASTER, }
        -- avatar[107574] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.75, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- avatar[107574] #3: { 'type': APPLY_AURA_ON_PET, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.75, 'points': 20.0, 'value': 22, 'schools': ['holy', 'fire', 'frost'], 'target': TARGET_UNIT_CASTER, }
        -- avatar[401150] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.75, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- avatar[401150] #8: { 'type': APPLY_AURA_ON_PET, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.75, 'points': 20.0, 'value': 22, 'schools': ['holy', 'fire', 'frost'], 'target': TARGET_UNIT_CASTER, }
        -- dual_wield_specialization[382900] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- dual_wield_specialization[382900] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- onehanded_weapon_specialization[382895] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- onehanded_weapon_specialization[382895] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- twohanded_weapon_specialization[382896] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- twohanded_weapon_specialization[382896] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- demoralizing_shout[1160] #2: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'pvp_multiplier': 0.5, 'radius': 10.0, 'target': TARGET_SRC_CASTER, 'target2': TARGET_UNIT_SRC_AREA_ENEMY, }
        -- instigate[394311] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- instigate[394311] #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER_BY_LABEL, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_3_VALUE, }
        -- martial_expert[429638] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_15, }
        -- mountain_of_muscle_and_scars[429642] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- mountain_of_muscle_and_scars[429642] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- champions_spear[376080] #4: { 'type': APPLY_AURA, 'subtype': MOD_CRITICAL_DAMAGE_TAKEN_FROM_CASTER, 'points': 25.0, 'radius': 5.0, 'target': TARGET_UNIT_DEST_AREA_ENEMY, }
        -- unnerving_focus[384043] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 60.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_3_VALUE, }
        -- shield_block[132404] #3: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': CRIT_CHANCE, }
        -- fury_warrior[137050] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 50.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- fury_warrior[137050] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 50.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- dance_of_death[459572] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
    },

    -- Disarm the enemy's weapons and shield for $d. Disarmed creatures deal significantly reduced damage.
    disarm = {
        id = 236077,
        color = 'pvp_talent',
        cast = 0.0,
        cooldown = 45.0,
        gcd = "global",

        startsCombat = true,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': MOD_DISARM, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #1: { 'type': APPLY_AURA, 'subtype': MOD_DAMAGE_PERCENT_TAKEN, 'schools': ['physical', 'holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #2: { 'type': APPLY_AURA, 'subtype': MOD_DISARM_RANGED, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #3: { 'type': APPLY_AURA, 'subtype': MOD_DISARM_OFFHAND, 'target': TARGET_UNIT_TARGET_ENEMY, }
    },

    -- Taunts all enemies within $A1 yds to attack you for $d, interrupts all spellcasting within $A1 yds and prevents any spell in that school from being cast for $d.; 
    disrupting_shout = {
        id = 386071,
        cast = 0.0,
        cooldown = 90.0,
        gcd = "none",

        talent = "disrupting_shout",
        startsCombat = true,

        -- Effects:
        -- #0: { 'type': ATTACK_ME, 'subtype': NONE, 'radius': 14.0, 'target': TARGET_SRC_CASTER, 'target2': TARGET_UNIT_SRC_AREA_ENEMY, }
        -- #1: { 'type': APPLY_AURA, 'subtype': MOD_TAUNT, 'points': 400.0, 'radius': 14.0, 'target': TARGET_SRC_CASTER, 'target2': TARGET_UNIT_SRC_AREA_ENEMY, }
        -- #2: { 'type': INTERRUPT_CAST, 'subtype': NONE, 'mechanic': interrupted, 'radius': 14.0, 'target': TARGET_SRC_CASTER, 'target2': TARGET_UNIT_SRC_AREA_ENEMY, }
    },

    -- Run at high speed at a distance in front of you. All enemies in your path will take $206579s1 Physical damage and be knocked back.
    dragon_charge = {
        id = 206572,
        color = 'pvp_talent',
        cast = 0.0,
        cooldown = 20.0,
        gcd = "none",

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': MOD_SPEED_NO_CONTROL, 'attributes': ['Uncontrolled No Backwards'], 'points': 400.0, 'target': TARGET_UNIT_CASTER, }
        -- #1: { 'type': APPLY_AURA, 'subtype': ALLOW_ONLY_ABILITY, 'target': TARGET_UNIT_CASTER, }
        -- #2: { 'type': APPLY_AURA, 'subtype': MOD_MINIMUM_SPEED, 'points': 500.0, 'target': TARGET_UNIT_CASTER, }
        -- #3: { 'type': APPLY_AURA, 'subtype': USE_NORMAL_MOVEMENT_SPEED, 'points': 35.0, 'target': TARGET_UNIT_CASTER, }
        -- #4: { 'type': APPLY_AURA, 'subtype': AREA_TRIGGER, 'value': 6242, 'schools': ['holy', 'shadow', 'arcane'], 'target': TARGET_UNIT_CASTER, }
    },

    -- Attempts to finish off a foe, causing up to $<damage> Physical damage based on Rage spent. Only usable on enemies that have less than 20% health.$?s316405[; If your foe survives, $s2% of the Rage spent is refunded.][]
    execute = {
        id = 163201,
        cast = 0.0,
        cooldown = 6.0,
        gcd = "global",

        spend = 200,
        spendType = 'rage',

        startsCombat = true,

        -- Effects:
        -- #0: { 'type': TRIGGER_SPELL, 'subtype': NONE, 'trigger_spell': 260798, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #1: { 'type': DUMMY, 'subtype': NONE, 'target': TARGET_UNIT_TARGET_ENEMY, }

        -- Affected by:
        -- protection_warrior[137048] #13: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- improved_execute[397708] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
        -- warrior[137047] #0: { 'type': APPLY_AURA, 'subtype': MOD_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'value': 11, 'schools': ['physical', 'holy', 'nature'], 'target': TARGET_UNIT_CASTER, }
        -- cruel_strikes[392777] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_15, }
        -- juggernaut[393968] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- unnerving_focus[384043] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 60.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_3_VALUE, }
    },

    -- Maims the enemy for $s2 Physical damage, reducing movement speed by $s1% for $d.
    hamstring = {
        id = 1715,
        cast = 0.0,
        cooldown = 0.0,
        gcd = "global",

        spend = 100,
        spendType = 'rage',

        startsCombat = true,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': MOD_DECREASE_SPEED, 'chain_targets': 1, 'mechanic': snared, 'points': -50.0, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #1: { 'type': SCHOOL_DAMAGE, 'subtype': NONE, 'chain_targets': 1, 'ap_bonus': 0.15, 'variance': 0.05, 'target': TARGET_UNIT_TARGET_ENEMY, }

        -- Affected by:
        -- protection_warrior[137048] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- protection_warrior[137048] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- warrior[137047] #1: { 'type': APPLY_AURA, 'subtype': MOD_GLOBAL_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'value': 11, 'schools': ['physical', 'holy', 'nature'], 'target': TARGET_UNIT_CASTER, }
        -- avatar[107574] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.75, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- avatar[107574] #3: { 'type': APPLY_AURA_ON_PET, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.75, 'points': 20.0, 'value': 22, 'schools': ['holy', 'fire', 'frost'], 'target': TARGET_UNIT_CASTER, }
        -- avatar[401150] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.75, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- avatar[401150] #8: { 'type': APPLY_AURA_ON_PET, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.75, 'points': 20.0, 'value': 22, 'schools': ['holy', 'fire', 'frost'], 'target': TARGET_UNIT_CASTER, }
        -- dual_wield_specialization[382900] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- dual_wield_specialization[382900] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- onehanded_weapon_specialization[382895] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- onehanded_weapon_specialization[382895] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- twohanded_weapon_specialization[382896] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- twohanded_weapon_specialization[382896] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- demoralizing_shout[1160] #2: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'pvp_multiplier': 0.5, 'radius': 10.0, 'target': TARGET_SRC_CASTER, 'target2': TARGET_UNIT_SRC_AREA_ENEMY, }
        -- martial_expert[429638] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_15, }
        -- mountain_of_muscle_and_scars[429642] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- mountain_of_muscle_and_scars[429642] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- champions_spear[376080] #4: { 'type': APPLY_AURA, 'subtype': MOD_CRITICAL_DAMAGE_TAKEN_FROM_CASTER, 'points': 25.0, 'radius': 5.0, 'target': TARGET_UNIT_DEST_AREA_ENEMY, }
        -- whirlwind[85739] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'attributes': ['Suppress Points Stacking'], 'points': 4.0, 'target': TARGET_UNIT_CASTER, 'modifies': CHAINED_TARGETS, }
        -- fury_warrior[137050] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 50.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- fury_warrior[137050] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 50.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- dance_of_death[459572] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
    },

    -- Leap through the air toward a target location, slamming down with destructive force to deal $52174s1 Physical damage to all enemies within $52174a1 yards$?c3[, and resetting the remaining cooldown on Taunt][].
    heroic_leap = {
        id = 6544,
        cast = 0.0,
        cooldown = 1.0,
        gcd = "none",

        talent = "heroic_leap",
        startsCombat = false,

        -- Effects:
        -- #0: { 'type': DUMMY, 'subtype': NONE, 'variance': 1.0, 'radius': 3.0, 'target': TARGET_DEST_DEST, }
        -- #1: { 'type': UNKNOWN, 'subtype': NONE, 'points': 5.0, 'value': 17, 'schools': ['physical', 'frost'], 'target': TARGET_DEST_DEST, }

        -- Affected by:
        -- demolish[436358] #2: { 'type': APPLY_AURA, 'subtype': ALLOW_ONLY_ABILITY, 'target': TARGET_UNIT_CASTER, }
    },

    -- Throws your weapon at the enemy, causing $s1 Physical damage. Generates high threat.
    heroic_throw = {
        id = 57755,
        cast = 0.0,
        cooldown = 6.0,
        gcd = "global",

        startsCombat = true,

        -- Effects:
        -- #0: { 'type': SCHOOL_DAMAGE, 'subtype': NONE, 'ap_bonus': 0.35, 'variance': 0.05, 'target': TARGET_UNIT_TARGET_ENEMY, }

        -- Affected by:
        -- protection_warrior[137048] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- protection_warrior[137048] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- protection_warrior[137048] #2: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -5000.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
        -- avatar[107574] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.75, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- avatar[107574] #3: { 'type': APPLY_AURA_ON_PET, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.75, 'points': 20.0, 'value': 22, 'schools': ['holy', 'fire', 'frost'], 'target': TARGET_UNIT_CASTER, }
        -- avatar[401150] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.75, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- avatar[401150] #8: { 'type': APPLY_AURA_ON_PET, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.75, 'points': 20.0, 'value': 22, 'schools': ['holy', 'fire', 'frost'], 'target': TARGET_UNIT_CASTER, }
        -- dual_wield_specialization[382900] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- dual_wield_specialization[382900] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- onehanded_weapon_specialization[382895] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- onehanded_weapon_specialization[382895] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- twohanded_weapon_specialization[382896] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- twohanded_weapon_specialization[382896] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- demoralizing_shout[1160] #2: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'pvp_multiplier': 0.5, 'radius': 10.0, 'target': TARGET_SRC_CASTER, 'target2': TARGET_UNIT_SRC_AREA_ENEMY, }
        -- martial_expert[429638] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_15, }
        -- mountain_of_muscle_and_scars[429642] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- mountain_of_muscle_and_scars[429642] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- champions_spear[376080] #4: { 'type': APPLY_AURA, 'subtype': MOD_CRITICAL_DAMAGE_TAKEN_FROM_CASTER, 'points': 25.0, 'radius': 5.0, 'target': TARGET_UNIT_DEST_AREA_ENEMY, }
        -- fury_warrior[137050] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 50.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- fury_warrior[137050] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 50.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- dance_of_death[459572] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
    },

    -- Fight through the pain, ignoring $s2% of damage taken, up to ${$mhp*$s4/100} total damage prevented.
    ignore_pain = {
        id = 190456,
        cast = 0.0,
        cooldown = 1.0,
        gcd = "none",

        spend = 350,
        spendType = 'rage',

        -- 0. [137049] arms_warrior
        -- spend = 200,
        -- spendType = 'rage',

        -- 1. [137050] fury_warrior
        -- spend = 600,
        -- spendType = 'rage',

        -- 2. [137048] protection_warrior
        -- spend = 350,
        -- spendType = 'rage',

        talent = "ignore_pain",
        startsCombat = false,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': SCHOOL_ABSORB, 'attributes': ['Aura Points Stack'], 'ap_bonus': 4.375, 'value': 127, 'schools': ['physical', 'holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], 'target': TARGET_UNIT_CASTER, }
        -- #1: { 'type': APPLY_AURA, 'subtype': DUMMY, 'points': 50.0, 'target': TARGET_UNIT_CASTER, }
        -- #2: { 'type': APPLY_AURA, 'subtype': MOD_BASE_RESISTANCE_PCT, 'value': 1, 'schools': ['physical'], 'target': TARGET_UNIT_CASTER, }
        -- #3: { 'type': APPLY_AURA, 'subtype': DUMMY, 'points': 30.0, 'target': TARGET_UNIT_CASTER, }

        -- Affected by:
        -- neltharions_fury[203524] #3: { 'type': APPLY_AURA, 'subtype': ALLOW_ONLY_ABILITY, 'target': TARGET_UNIT_CASTER, }
        -- demolish[436358] #2: { 'type': APPLY_AURA, 'subtype': ALLOW_ONLY_ABILITY, 'target': TARGET_UNIT_CASTER, }
    },

    -- Instantly attack the target, causing $s1 damage and healing you for $202166s1% of your maximum health.; Killing an enemy that yields experience or honor resets the cooldown of Impending Victory and makes it cost no Rage.
    impending_victory = {
        id = 202168,
        cast = 0.0,
        cooldown = 25.0,
        gcd = "global",

        spend = 100,
        spendType = 'rage',

        talent = "impending_victory",
        startsCombat = true,

        -- Effects:
        -- #0: { 'type': SCHOOL_DAMAGE, 'subtype': NONE, 'chain_targets': 1, 'ap_bonus': 0.59, 'variance': 0.05, 'target': TARGET_UNIT_TARGET_ENEMY, }

        -- Affected by:
        -- whirlwind[85739] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'attributes': ['Suppress Points Stacking'], 'points': 4.0, 'target': TARGET_UNIT_CASTER, 'modifies': CHAINED_TARGETS, }
    },

    -- Run at high speed toward an ally, intercepting all melee and ranged attacks against them for $147833d while they remain within $147833A1 yds.
    intervene = {
        id = 3411,
        cast = 0.0,
        cooldown = 1.5,
        gcd = "none",

        talent = "intervene",
        startsCombat = false,

        -- Effects:
        -- #0: { 'type': DUMMY, 'subtype': NONE, 'target': TARGET_UNIT_TARGET_ALLY, }

        -- Affected by:
        -- honed_reflexes[391271] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -5.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
        -- demolish[436358] #2: { 'type': APPLY_AURA, 'subtype': ALLOW_ONLY_ABILITY, 'target': TARGET_UNIT_CASTER, }
        -- safeguard[424654] #0: { 'type': APPLY_AURA, 'subtype': MOD_MAX_CHARGES, 'points': 1.0, 'target': TARGET_UNIT_CASTER, }
    },

    -- $?s275338[Causes the targeted enemy and up to $s1 additional enemies within $5246A3 yards to cower in fear.][Causes the targeted enemy to cower in fear, and up to $s1 additional enemies within $5246A3 yards to flee.] Targets are disoriented for $d.
    intimidating_shout = {
        id = 5246,
        cast = 0.0,
        cooldown = 90.0,
        gcd = "global",

        talent = "intimidating_shout",
        startsCombat = true,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': MOD_FEAR, 'points': 5.0, 'value': 1, 'schools': ['physical'], 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #1: { 'type': APPLY_AURA, 'subtype': MOD_ROOT_2, 'points': 5.0, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #2: { 'type': APPLY_AURA, 'subtype': MOD_FEAR, 'value': 1, 'schools': ['physical'], 'radius': 8.0, 'target': TARGET_SRC_CASTER, 'target2': TARGET_UNIT_SRC_AREA_ENEMY, }
        -- #3: { 'type': APPLY_AURA, 'subtype': MOD_ROOT_2, 'radius': 8.0, 'target': TARGET_SRC_CASTER, 'target2': TARGET_UNIT_SRC_AREA_ENEMY, }
        -- #4: { 'type': APPLY_AURA, 'subtype': USE_NORMAL_MOVEMENT_SPEED, 'points': 7.0, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #5: { 'type': APPLY_AURA, 'subtype': USE_NORMAL_MOVEMENT_SPEED, 'points': 7.0, 'radius': 8.0, 'target': TARGET_SRC_CASTER, 'target2': TARGET_UNIT_SRC_AREA_ENEMY, }

        -- Affected by:
        -- warrior[137047] #1: { 'type': APPLY_AURA, 'subtype': MOD_GLOBAL_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'value': 11, 'schools': ['physical', 'holy', 'nature'], 'target': TARGET_UNIT_CASTER, }
        -- battlefield_commander[424742] #2: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -15000.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
    },

    -- Increases maximum health by $s1% for $d, and instantly heals you for that amount.
    last_stand = {
        id = 12975,
        cast = 0.0,
        cooldown = 20.0,
        gcd = "none",

        talent = "last_stand",
        startsCombat = false,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': MOD_INCREASE_HEALTH_PERCENT, 'points': 30.0, 'target': TARGET_UNIT_CASTER, }
        -- #1: { 'type': HEAL_PCT, 'subtype': NONE, 'points': 30.0, 'target': TARGET_UNIT_CASTER, }
        -- #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }

        -- Affected by:
        -- neltharions_fury[203524] #3: { 'type': APPLY_AURA, 'subtype': ALLOW_ONLY_ABILITY, 'target': TARGET_UNIT_CASTER, }
        -- bolster[280001] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -60000.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
        -- demolish[436358] #2: { 'type': APPLY_AURA, 'subtype': ALLOW_ONLY_ABILITY, 'target': TARGET_UNIT_CASTER, }
    },

    -- Enter a defensive posture, critically blocking all attacks while a stream of shadowflame erupts from Scale of the Earth-Warder, dealing ${6*$203526s1} Shadowflame over $d to all enemies in front of you. You can use defensive abilities while this is active.
    neltharions_fury = {
        id = 203524,
        color = 'artifact',
        cast = 0.0,
        cooldown = 45.0,
        gcd = "global",

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': MOD_BLOCK_PERCENT, 'points': 300.0, 'target': TARGET_UNIT_CASTER, }
        -- #1: { 'type': APPLY_AURA, 'subtype': PERIODIC_TRIGGER_SPELL, 'tick_time': 0.5, 'trigger_spell': 203526, 'points': 50.0, 'target': TARGET_UNIT_CASTER, }
        -- #2: { 'type': APPLY_AURA, 'subtype': MOD_BLOCK_CRIT_CHANCE, 'points': 100.0, 'target': TARGET_UNIT_CASTER, }
        -- #3: { 'type': APPLY_AURA, 'subtype': ALLOW_ONLY_ABILITY, 'target': TARGET_UNIT_CASTER, }
    },

    -- Unleashes the fiery power Odyn bestowed the Warswords, dealing ${$205546sw2+$205547sw2} Fire damage and an additional $205546o3 Fire damage over $205546d to all enemies within $205546A2 yards.
    odyns_fury = {
        id = 205545,
        color = 'artifact',
        cast = 0.0,
        cooldown = 45.0,
        gcd = "global",

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': TRIGGER_SPELL, 'subtype': NONE, 'trigger_spell': 205546, 'value': 200, 'schools': ['nature', 'arcane'], 'target': TARGET_UNIT_CASTER, }
        -- #1: { 'type': TRIGGER_SPELL, 'subtype': NONE, 'trigger_spell': 205547, 'value': 200, 'schools': ['nature', 'arcane'], 'target': TARGET_UNIT_CASTER, }
    },

    -- [206891] You focus the assault on this target, increasing their damage taken by $s1% for $d. Each unique player that attacks the target increases the damage taken by an additional $s1%, stacking up to $u times.; Your melee attacks refresh the duration of Focused Assault.
    oppressor = {
        id = 205800,
        color = 'pvp_talent',
        cast = 0.0,
        cooldown = 20.0,
        gcd = "global",

        startsCombat = true,

        -- Effects:
        -- #0: { 'type': TRIGGER_SPELL, 'subtype': NONE, 'trigger_spell': 206891, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #1: { 'type': APPLY_AURA, 'subtype': DUMMY, 'target': TARGET_UNIT_CASTER, }
    },

    -- Snares all enemies within $A1 yards, reducing their movement speed by $s1% for $d.
    piercing_howl = {
        id = 12323,
        cast = 0.0,
        cooldown = 30.0,
        gcd = "global",

        talent = "piercing_howl",
        startsCombat = true,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': MOD_DECREASE_SPEED, 'mechanic': snared, 'points': -70.0, 'radius': 12.0, 'target': TARGET_SRC_CASTER, 'target2': TARGET_UNIT_SRC_AREA_ENEMY, }

        -- Affected by:
        -- warrior[137047] #1: { 'type': APPLY_AURA, 'subtype': MOD_GLOBAL_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'value': 11, 'schools': ['physical', 'holy', 'nature'], 'target': TARGET_UNIT_CASTER, }
        -- battlefield_commander[424742] #5: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 50.0, 'target': TARGET_UNIT_CASTER, 'modifies': RADIUS, }
    },

    -- Pummels the target, interrupting spellcasting and preventing any spell in that school from being cast for $d.
    pummel = {
        id = 6552,
        cast = 0.0,
        cooldown = 15.0,
        gcd = "none",

        startsCombat = true,
        interrupt = true,

        -- Effects:
        -- #0: { 'type': INTERRUPT_CAST, 'subtype': NONE, 'mechanic': interrupted, 'target': TARGET_UNIT_TARGET_ENEMY, }

        -- Affected by:
        -- concussive_blows[383115] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -1000.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
        -- honed_reflexes[391271] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -5.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
    },

    -- Lets loose a rallying cry, granting all party or raid members within $a1 yards $s1% temporary and maximum health for $97463d.
    rallying_cry = {
        id = 97462,
        cast = 0.0,
        cooldown = 180.0,
        gcd = "global",

        talent = "rallying_cry",
        startsCombat = false,

        -- Effects:
        -- #0: { 'type': DUMMY, 'subtype': NONE, 'radius': 40.0, 'target': TARGET_UNIT_CASTER_AREA_RAID, }

        -- Affected by:
        -- battlefield_commander[424742] #3: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 30.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_3_VALUE, }
    },

    -- Throws a whirling weapon at the target location that chases nearby enemies, inflicting $<damage> Physical damage to all enemies over $d. Deals reduced damage beyond $156287s2 targets.; Generates ${$334934s1/10} Rage each time it deals damage.
    ravager = {
        id = 228920,
        cast = 0.0,
        cooldown = 90.0,
        gcd = "global",

        talent = "ravager",
        startsCombat = true,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': DUMMY, 'points': 30.0, 'target': TARGET_UNIT_CASTER, }
        -- #1: { 'type': DUMMY, 'subtype': NONE, 'radius': 8.0, 'target': TARGET_UNIT_DEST_AREA_ENEMY, }
        -- #2: { 'type': APPLY_AURA, 'subtype': PERIODIC_DUMMY, 'tick_time': 2.0, 'target': TARGET_UNIT_CASTER, }

        -- Affected by:
        -- storm_of_steel[382953] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -30.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- storm_of_steel[382953] #1: { 'type': APPLY_AURA, 'subtype': MOD_MAX_CHARGES, 'points': 1.0, 'target': TARGET_UNIT_CASTER, }
        -- storm_of_steel[382953] #2: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -90000.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
    },

    -- Wounds the target, causing $s1 Physical damage instantly and an additional $394063o1 Bleed damage over $394063d.$?s6343[; Thunder Clap affects $6343s5 nearby targets with Rend.; ][]
    rend = {
        id = 394062,
        cast = 0.0,
        cooldown = 0.0,
        gcd = "global",

        spend = 200,
        spendType = 'rage',

        talent = "rend",
        startsCombat = true,

        -- Effects:
        -- #0: { 'type': SCHOOL_DAMAGE, 'subtype': NONE, 'chain_targets': 1, 'ap_bonus': 0.39162, 'variance': 0.05, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #1: { 'type': TRIGGER_SPELL, 'subtype': NONE, 'trigger_spell': 388539, 'target': TARGET_UNIT_TARGET_ENEMY, }

        -- Affected by:
        -- colossal_might[440989] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- whirlwind[85739] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'attributes': ['Suppress Points Stacking'], 'points': 4.0, 'target': TARGET_UNIT_CASTER, 'modifies': CHAINED_TARGETS, }
    },

    -- Swing in a wide arc, dealing $s1 Physical damage to all enemies in front of you. Deals reduced damage beyond $<cap> targets.; Your successful dodges and parries have a chance to make your next Revenge cost no Rage.
    revenge = {
        id = 6572,
        cast = 0.0,
        cooldown = 0.0,
        gcd = "global",

        spend = 200,
        spendType = 'rage',

        talent = "revenge",
        startsCombat = true,

        -- Effects:
        -- #0: { 'type': SCHOOL_DAMAGE, 'subtype': NONE, 'attributes': ['Add Target (Dest) Combat Reach to AOE', 'Area Effects Use Target Radius'], 'ap_bonus': 0.52155, 'variance': 0.05, 'radius': 8.0, 'target': TARGET_UNIT_CONE_CASTER_TO_DEST_ENEMY, }

        -- Affected by:
        -- protection_warrior[137048] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- protection_warrior[137048] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- warrior[137047] #0: { 'type': APPLY_AURA, 'subtype': MOD_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'value': 11, 'schools': ['physical', 'holy', 'nature'], 'target': TARGET_UNIT_CASTER, }
        -- warrior[137047] #1: { 'type': APPLY_AURA, 'subtype': MOD_GLOBAL_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'value': 11, 'schools': ['physical', 'holy', 'nature'], 'target': TARGET_UNIT_CASTER, }
        -- avatar[107574] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.75, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- avatar[107574] #3: { 'type': APPLY_AURA_ON_PET, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.75, 'points': 20.0, 'value': 22, 'schools': ['holy', 'fire', 'frost'], 'target': TARGET_UNIT_CASTER, }
        -- avatar[401150] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.75, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- avatar[401150] #8: { 'type': APPLY_AURA_ON_PET, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.75, 'points': 20.0, 'value': 22, 'schools': ['holy', 'fire', 'frost'], 'target': TARGET_UNIT_CASTER, }
        -- barbaric_training[390675] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 25.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- barbaric_training[390675] #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 100.0, 'modifies': POWER_COST, }
        -- dual_wield_specialization[382900] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- dual_wield_specialization[382900] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- onehanded_weapon_specialization[382895] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- onehanded_weapon_specialization[382895] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- twohanded_weapon_specialization[382896] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- twohanded_weapon_specialization[382896] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- best_served_cold[202560] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- demoralizing_shout[1160] #2: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'pvp_multiplier': 0.5, 'radius': 10.0, 'target': TARGET_SRC_CASTER, 'target2': TARGET_UNIT_SRC_AREA_ENEMY, }
        -- martial_expert[429638] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_15, }
        -- mountain_of_muscle_and_scars[429642] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- mountain_of_muscle_and_scars[429642] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- practiced_strikes[429647] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- show_of_force[385843] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- thorims_might[436152] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- revenge[5302] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- champions_spear[376080] #4: { 'type': APPLY_AURA, 'subtype': MOD_CRITICAL_DAMAGE_TAKEN_FROM_CASTER, 'points': 25.0, 'radius': 5.0, 'target': TARGET_UNIT_DEST_AREA_ENEMY, }
        -- colossal_might[440989] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- fury_warrior[137050] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 50.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- fury_warrior[137050] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 50.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- dance_of_death[459572] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
    },

    -- Hurl your weapon at the enemy, causing $<damage> Physical damage, ignoring armor, and removing any magical immunities. Deals up to $?s329033[${($329033s3/100+1)*500}][500]% increased damage to absorb shields.
    shattering_throw = {
        id = 64382,
        cast = 1.5,
        cooldown = 180.0,
        gcd = "global",

        talent = "shattering_throw",
        startsCombat = true,

        -- Effects:
        -- #0: { 'type': TRIGGER_MISSILE, 'subtype': NONE, 'trigger_spell': 64380, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #1: { 'type': TRIGGER_MISSILE, 'subtype': NONE, 'attributes': ['No Immunity'], 'trigger_spell': 394352, 'target': TARGET_UNIT_TARGET_ENEMY, }

        -- Affected by:
        -- protection_warrior[137048] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- protection_warrior[137048] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- avatar[107574] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.75, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- avatar[107574] #3: { 'type': APPLY_AURA_ON_PET, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.75, 'points': 20.0, 'value': 22, 'schools': ['holy', 'fire', 'frost'], 'target': TARGET_UNIT_CASTER, }
        -- avatar[401150] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.75, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- avatar[401150] #8: { 'type': APPLY_AURA_ON_PET, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.75, 'points': 20.0, 'value': 22, 'schools': ['holy', 'fire', 'frost'], 'target': TARGET_UNIT_CASTER, }
        -- dual_wield_specialization[382900] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- dual_wield_specialization[382900] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- onehanded_weapon_specialization[382895] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- onehanded_weapon_specialization[382895] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- twohanded_weapon_specialization[382896] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- twohanded_weapon_specialization[382896] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- demoralizing_shout[1160] #2: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'pvp_multiplier': 0.5, 'radius': 10.0, 'target': TARGET_SRC_CASTER, 'target2': TARGET_UNIT_SRC_AREA_ENEMY, }
        -- martial_expert[429638] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_15, }
        -- mountain_of_muscle_and_scars[429642] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- mountain_of_muscle_and_scars[429642] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- demolition[329033] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -50.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
        -- champions_spear[376080] #4: { 'type': APPLY_AURA, 'subtype': MOD_CRITICAL_DAMAGE_TAKEN_FROM_CASTER, 'points': 25.0, 'radius': 5.0, 'target': TARGET_UNIT_DEST_AREA_ENEMY, }
        -- fury_warrior[137050] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 50.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- fury_warrior[137050] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 50.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- dance_of_death[459572] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
    },

    -- Raise your shield, blocking all melee attacks against you for $132404d.$?s76857[ These blocks can be critical blocks.][]$?c3[ Increases Shield Slam damage by $132404s2% while active.][]
    shield_block = {
        id = 2565,
        cast = 0.0,
        cooldown = 1.0,
        gcd = "none",

        spend = 300,
        spendType = 'rage',

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': DUMMY, 'subtype': NONE, 'target': TARGET_UNIT_CASTER, }

        -- Affected by:
        -- shield_block[231847] #0: { 'type': APPLY_AURA, 'subtype': MOD_MAX_CHARGES, 'points': 1.0, 'target': TARGET_UNIT_CASTER, }
        -- neltharions_fury[203524] #3: { 'type': APPLY_AURA, 'subtype': ALLOW_ONLY_ABILITY, 'target': TARGET_UNIT_CASTER, }
        -- demolish[436358] #2: { 'type': APPLY_AURA, 'subtype': ALLOW_ONLY_ABILITY, 'target': TARGET_UNIT_CASTER, }
        -- enduring_defenses[386027] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 2000.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
    },

    -- Charge to an enemy with your shield, dealing $385954s1 Physical damage to it and $385954s2 Physical damage to all enemies within 10 yards.; Also stuns the primary target for $385954d.; Generates ${$385954s4/10} Rage.
    shield_charge = {
        id = 385952,
        cast = 0.0,
        cooldown = 45.0,
        gcd = "global",

        talent = "shield_charge",
        startsCombat = true,

        -- Effects:
        -- #0: { 'type': DUMMY, 'subtype': NONE, 'target': TARGET_UNIT_TARGET_ENEMY, }

        -- Affected by:
        -- demolish[436358] #2: { 'type': APPLY_AURA, 'subtype': ALLOW_ONLY_ABILITY, 'target': TARGET_UNIT_CASTER, }
    },

    -- Slams the target with your shield, causing $s1 Physical damage.$?s231834[; Devastate, Thunder Clap, Revenge, and Execute have a $231834s1% chance to reset the cooldown of Shield Slam.][]; Generates $/10;s3 Rage.
    shield_slam = {
        id = 23922,
        cast = 0.0,
        cooldown = 9.0,
        gcd = "global",

        startsCombat = true,

        -- Effects:
        -- #0: { 'type': SCHOOL_DAMAGE, 'subtype': NONE, 'chain_targets': 1, 'ap_bonus': 0.97722, 'variance': 0.05, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #1: { 'type': ENERGIZE, 'subtype': NONE, 'target': TARGET_UNIT_CASTER, 'resource': rage, }
        -- #2: { 'type': ENERGIZE, 'subtype': NONE, 'points': 150.0, 'target': TARGET_UNIT_CASTER, 'resource': rage, }
        -- #3: { 'type': APPLY_AURA, 'subtype': DUMMY, 'points': 15.0, 'target': TARGET_UNIT_CASTER, }

        -- Affected by:
        -- protection_warrior[137048] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- protection_warrior[137048] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- warrior[137047] #0: { 'type': APPLY_AURA, 'subtype': MOD_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'value': 11, 'schools': ['physical', 'holy', 'nature'], 'target': TARGET_UNIT_CASTER, }
        -- warrior[137047] #1: { 'type': APPLY_AURA, 'subtype': MOD_GLOBAL_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'value': 11, 'schools': ['physical', 'holy', 'nature'], 'target': TARGET_UNIT_CASTER, }
        -- avatar[107574] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.75, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- avatar[107574] #3: { 'type': APPLY_AURA_ON_PET, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.75, 'points': 20.0, 'value': 22, 'schools': ['holy', 'fire', 'frost'], 'target': TARGET_UNIT_CASTER, }
        -- avatar[401150] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.75, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- avatar[401150] #8: { 'type': APPLY_AURA_ON_PET, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.75, 'points': 20.0, 'value': 22, 'schools': ['holy', 'fire', 'frost'], 'target': TARGET_UNIT_CASTER, }
        -- crushing_force[390642] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- crushing_force[390642] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_15, }
        -- dual_wield_specialization[382900] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- dual_wield_specialization[382900] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- onehanded_weapon_specialization[382895] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- onehanded_weapon_specialization[382895] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- twohanded_weapon_specialization[382896] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- twohanded_weapon_specialization[382896] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- demoralizing_shout[1160] #2: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'pvp_multiplier': 0.5, 'radius': 10.0, 'target': TARGET_SRC_CASTER, 'target2': TARGET_UNIT_SRC_AREA_ENEMY, }
        -- heavy_repercussions[203177] #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_3_VALUE, }
        -- impenetrable_wall[384072] #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 40.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_3_VALUE, }
        -- last_stand[12975] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- martial_expert[429638] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_15, }
        -- mountain_of_muscle_and_scars[429642] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- mountain_of_muscle_and_scars[429642] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- practiced_strikes[429647] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- punish[275334] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- strength_of_the_mountain[437068] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- champions_spear[376080] #4: { 'type': APPLY_AURA, 'subtype': MOD_CRITICAL_DAMAGE_TAKEN_FROM_CASTER, 'points': 25.0, 'radius': 5.0, 'target': TARGET_UNIT_DEST_AREA_ENEMY, }
        -- brace_for_impact[386029] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- unnerving_focus[384043] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 60.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_3_VALUE, }
        -- shield_block[132404] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 30.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- shield_block[132404] #3: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': CRIT_CHANCE, }
        -- whirlwind[85739] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'attributes': ['Suppress Points Stacking'], 'points': 4.0, 'target': TARGET_UNIT_CASTER, 'modifies': CHAINED_TARGETS, }
        -- fury_warrior[137050] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 50.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- fury_warrior[137050] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 50.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- dance_of_death[459572] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- violent_outburst[386478] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.5, 'points': 200.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- violent_outburst[386478] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 100.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_3_VALUE, }
    },

    -- Reduces all damage you take by $s1% for $d.
    shield_wall = {
        id = 871,
        cast = 0.0,
        cooldown = 8.0,
        gcd = "none",

        talent = "shield_wall",
        startsCombat = false,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': MOD_DAMAGE_PERCENT_TAKEN, 'points': -40.0, 'schools': ['physical', 'holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], 'target': TARGET_UNIT_CASTER, }

        -- Affected by:
        -- neltharions_fury[203524] #3: { 'type': APPLY_AURA, 'subtype': ALLOW_ONLY_ABILITY, 'target': TARGET_UNIT_CASTER, }
        -- honed_reflexes[391271] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -5.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
        -- defenders_aegis[397103] #1: { 'type': APPLY_AURA, 'subtype': MOD_MAX_CHARGES, 'points': 1.0, 'target': TARGET_UNIT_CASTER, }
        -- demolish[436358] #2: { 'type': APPLY_AURA, 'subtype': ALLOW_ONLY_ABILITY, 'target': TARGET_UNIT_CASTER, }
    },

    -- Sends a wave of force in a frontal cone, causing $s2 damage and stunning all enemies within $a1 yards for $132168d.
    shockwave = {
        id = 46968,
        cast = 0.0,
        cooldown = 40.0,
        gcd = "global",

        talent = "shockwave",
        startsCombat = true,

        -- Effects:
        -- #0: { 'type': DUMMY, 'subtype': NONE, 'radius': 10.0, 'target': TARGET_UNIT_CONE_CASTER_TO_DEST_ENEMY, }
        -- #1: { 'type': SCHOOL_DAMAGE, 'subtype': NONE, 'ap_bonus': 0.2, 'variance': 0.05, 'radius': 10.0, 'target': TARGET_UNIT_CONE_CASTER_TO_DEST_ENEMY, }
        -- #2: { 'type': DUMMY, 'subtype': NONE, }
        -- #3: { 'type': SCRIPT_EFFECT, 'subtype': NONE, 'points': 40.0, 'target': TARGET_UNIT_CASTER, }

        -- Affected by:
        -- protection_warrior[137048] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- protection_warrior[137048] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- protection_warrior[137048] #14: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 50.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- avatar[107574] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.75, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- avatar[107574] #3: { 'type': APPLY_AURA_ON_PET, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.75, 'points': 20.0, 'value': 22, 'schools': ['holy', 'fire', 'frost'], 'target': TARGET_UNIT_CASTER, }
        -- avatar[401150] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.75, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- avatar[401150] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- avatar[401150] #8: { 'type': APPLY_AURA_ON_PET, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.75, 'points': 20.0, 'value': 22, 'schools': ['holy', 'fire', 'frost'], 'target': TARGET_UNIT_CASTER, }
        -- dual_wield_specialization[382900] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- dual_wield_specialization[382900] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- onehanded_weapon_specialization[382895] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- onehanded_weapon_specialization[382895] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- rumbling_earth[275339] #2: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 6.0, 'target': TARGET_UNIT_CASTER, 'modifies': RADIUS, }
        -- twohanded_weapon_specialization[382896] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- twohanded_weapon_specialization[382896] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- boneshaker[429639] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 1000.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
        -- demoralizing_shout[1160] #2: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'pvp_multiplier': 0.5, 'radius': 10.0, 'target': TARGET_SRC_CASTER, 'target2': TARGET_UNIT_SRC_AREA_ENEMY, }
        -- earthquaker[440992] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -5000.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
        -- martial_expert[429638] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_15, }
        -- mountain_of_muscle_and_scars[429642] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- mountain_of_muscle_and_scars[429642] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- champions_spear[376080] #4: { 'type': APPLY_AURA, 'subtype': MOD_CRITICAL_DAMAGE_TAKEN_FROM_CASTER, 'points': 25.0, 'radius': 5.0, 'target': TARGET_UNIT_DEST_AREA_ENEMY, }
        -- unnerving_focus[384043] #5: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 60.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_5_VALUE, }
        -- fury_warrior[137050] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 50.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- fury_warrior[137050] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 50.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- dance_of_death[459572] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
    },

    -- Slams an opponent, causing $s1 Physical damage.$?s388903[; Generates ${$388903s6/10} Rage.][]
    slam = {
        id = 1464,
        cast = 0.0,
        cooldown = 0.0,
        gcd = "global",

        spend = 200,
        spendType = 'rage',

        startsCombat = true,

        -- Effects:
        -- #0: { 'type': SCHOOL_DAMAGE, 'subtype': NONE, 'chain_targets': 1, 'ap_bonus': 0.805, 'pvp_multiplier': 1.85, 'variance': 0.05, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #1: { 'type': ENERGIZE, 'subtype': NONE, 'target': TARGET_UNIT_CASTER, 'resource': rage, }

        -- Affected by:
        -- protection_warrior[137048] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- protection_warrior[137048] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- warrior[137047] #0: { 'type': APPLY_AURA, 'subtype': MOD_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'value': 11, 'schools': ['physical', 'holy', 'nature'], 'target': TARGET_UNIT_CASTER, }
        -- warrior[137047] #1: { 'type': APPLY_AURA, 'subtype': MOD_GLOBAL_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'value': 11, 'schools': ['physical', 'holy', 'nature'], 'target': TARGET_UNIT_CASTER, }
        -- avatar[107574] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.75, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- avatar[107574] #3: { 'type': APPLY_AURA_ON_PET, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.75, 'points': 20.0, 'value': 22, 'schools': ['holy', 'fire', 'frost'], 'target': TARGET_UNIT_CASTER, }
        -- avatar[401150] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.75, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- avatar[401150] #8: { 'type': APPLY_AURA_ON_PET, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.75, 'points': 20.0, 'value': 22, 'schools': ['holy', 'fire', 'frost'], 'target': TARGET_UNIT_CASTER, }
        -- barbaric_training[390674] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- barbaric_training[390674] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_15, }
        -- barbaric_training[383082] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- barbaric_training[383082] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_15, }
        -- dual_wield_specialization[382900] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- dual_wield_specialization[382900] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- onehanded_weapon_specialization[382895] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- onehanded_weapon_specialization[382895] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- twohanded_weapon_specialization[382896] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- twohanded_weapon_specialization[382896] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- demoralizing_shout[1160] #2: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'pvp_multiplier': 0.5, 'radius': 10.0, 'target': TARGET_SRC_CASTER, 'target2': TARGET_UNIT_SRC_AREA_ENEMY, }
        -- martial_expert[429638] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_15, }
        -- mountain_of_muscle_and_scars[429642] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- mountain_of_muscle_and_scars[429642] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- champions_spear[376080] #4: { 'type': APPLY_AURA, 'subtype': MOD_CRITICAL_DAMAGE_TAKEN_FROM_CASTER, 'points': 25.0, 'radius': 5.0, 'target': TARGET_UNIT_DEST_AREA_ENEMY, }
        -- storm_of_swords[388903] #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 9000.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
        -- storm_of_swords[388903] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 100.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- storm_of_swords[388903] #4: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -200.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- storm_of_swords[388903] #5: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 100.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_2_VALUE, }
        -- whirlwind[85739] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'attributes': ['Suppress Points Stacking'], 'points': 4.0, 'target': TARGET_UNIT_CASTER, 'modifies': CHAINED_TARGETS, }
        -- fury_warrior[137050] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 50.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- fury_warrior[137050] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 50.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- fury_warrior[137050] #11: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- dance_of_death[459572] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
    },

    -- You are able to block spells for $392966d.
    spell_block = {
        id = 392966,
        cast = 0.0,
        cooldown = 90.0,
        gcd = "none",

        talent = "spell_block",
        startsCombat = false,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': UNKNOWN, 'target': TARGET_UNIT_CASTER, }
    },

    -- Raise your $?c3[shield][weapon], reflecting $?a213915[the next $213915s3 spells cast][the first spell cast] on you, and reduce magic damage you take by $385391s1% for $d.
    spell_reflection = {
        id = 23920,
        cast = 0.0,
        cooldown = 1.0,
        gcd = "none",

        talent = "spell_reflection",
        startsCombat = false,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': REFLECT_SPELLS, 'amplitude': 1.0, 'points': 100.0, 'target': TARGET_UNIT_CASTER, }
        -- #1: { 'type': TRIGGER_SPELL, 'subtype': NONE, 'trigger_spell': 385391, }

        -- Affected by:
        -- protection_warrior[137048] #18: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -5.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_1_VALUE, }
        -- neltharions_fury[203524] #3: { 'type': APPLY_AURA, 'subtype': ALLOW_ONLY_ABILITY, 'target': TARGET_UNIT_CASTER, }
        -- honed_reflexes[391271] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -5.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
        -- demolish[436358] #2: { 'type': APPLY_AURA, 'subtype': ALLOW_ONLY_ABILITY, 'target': TARGET_UNIT_CASTER, }
        -- rebound[213915] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'amplitude': 1.0, 'points': 50.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_TAKEN_BY_PCT, }
        -- rebound[213915] #2: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER_BY_LABEL, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': MAX_STACKS, }
    },

    -- Hurls your weapon at an enemy, causing $s1 Physical damage and stunning for $132169d.$?s436162[ Also hits 2 additional nearby targets, stunning for 2 sec.][]
    storm_bolt = {
        id = 107570,
        cast = 0.0,
        cooldown = 30.0,
        gcd = "global",

        talent = "storm_bolt",
        startsCombat = true,

        -- Effects:
        -- #0: { 'type': SCHOOL_DAMAGE, 'subtype': NONE, 'ap_bonus': 0.285, 'variance': 0.05, 'radius': 10.0, 'target': TARGET_DEST_TARGET_ENEMY, 'target2': TARGET_UNIT_DEST_AREA_ENEMY, }
        -- #1: { 'type': DUMMY, 'subtype': NONE, 'target': TARGET_UNIT_TARGET_ENEMY, }

        -- Affected by:
        -- honed_reflexes[391271] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -5.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
        -- storm_bolts[436162] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_2_VALUE, }
        -- storm_bolts[436162] #2: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 10000.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
    },

    -- Taunts the target to attack you.
    taunt = {
        id = 355,
        cast = 0.0,
        cooldown = 8.0,
        gcd = "none",

        startsCombat = true,

        -- Effects:
        -- #0: { 'type': ATTACK_ME, 'subtype': NONE, 'sp_bonus': 0.25, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #1: { 'type': APPLY_AURA, 'subtype': MOD_TAUNT, 'points': 400.0, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #2: { 'type': APPLY_AURA, 'subtype': MOD_INCREASE_SPEED, 'target': TARGET_UNIT_TARGET_ENEMY, }

        -- Affected by:
        -- neltharions_fury[203524] #3: { 'type': APPLY_AURA, 'subtype': ALLOW_ONLY_ABILITY, 'target': TARGET_UNIT_CASTER, }
        -- demolish[436358] #2: { 'type': APPLY_AURA, 'subtype': ALLOW_ONLY_ABILITY, 'target': TARGET_UNIT_CASTER, }
    },

    -- Blasts all enemies within $A1 yards for $s1 Stormstrike damage$?s199045[, roots them for $199042d,][] and reduces their movement speed by $435203s1% for $435203d. Deals reduced damage beyond $s5 targets.$?a137048|(a137050&a436707)[; Generates ${$s4/10} Rage.][]
    thunder_blast = {
        id = 435222,
        cast = 0.0,
        cooldown = 6.0,
        gcd = "global",

        spend = 300,
        spendType = 'rage',

        startsCombat = true,

        -- Effects:
        -- #0: { 'type': SCHOOL_DAMAGE, 'subtype': NONE, 'ap_bonus': 0.491, 'variance': 0.05, 'radius': 8.0, 'target': TARGET_SRC_CASTER, 'target2': TARGET_UNIT_SRC_AREA_ENEMY, }
        -- #1: { 'type': DUMMY, 'subtype': NONE, 'target': TARGET_UNIT_CASTER, }
        -- #2: { 'type': DUMMY, 'subtype': NONE, 'target': TARGET_UNIT_CASTER, }
        -- #3: { 'type': ENERGIZE, 'subtype': NONE, 'points': 50.0, 'target': TARGET_UNIT_CASTER, 'resource': rage, }
        -- #4: { 'type': DUMMY, 'subtype': NONE, 'target': TARGET_UNIT_CASTER, }

        -- Affected by:
        -- protection_warrior[137048] #19: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 50.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_4_VALUE, }
        -- protection_warrior[137048] #20: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- warrior[137047] #0: { 'type': APPLY_AURA, 'subtype': MOD_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'value': 11, 'schools': ['physical', 'holy', 'nature'], 'target': TARGET_UNIT_CASTER, }
        -- avatar[401150] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- avatar[401150] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
        -- barbaric_training[390674] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- barbaric_training[390674] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_15, }
        -- crackling_thunder[203201] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 50.0, 'target': TARGET_UNIT_CASTER, 'modifies': RADIUS, }
        -- crashing_thunder[436707] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- crashing_thunder[436707] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 40.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- crashing_thunder[436707] #3: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 50.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_4_VALUE, }
        -- crashing_thunder[436707] #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- thunder_blast[435607] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'points': 40.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- show_of_force[385842] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- thunder_blast[435615] #0: { 'type': APPLY_AURA, 'subtype': OVERRIDE_ACTIONBAR_SPELLS, 'attributes': ['Suppress Points Stacking'], 'spell': 435222, 'target': TARGET_UNIT_CASTER, }
        -- unnerving_focus[384043] #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 60.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_4_VALUE, }
        -- fury_warrior[137050] #9: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 45.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- violent_outburst[386478] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.5, 'points': 200.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- violent_outburst[386478] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 100.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_4_VALUE, }
    },

    -- Blasts all enemies within $A1 yards for $s1 Physical damage$?s199045[, roots them for $199042d,][] and reduces their movement speed by $435203s1% for $435203d. Deals reduced damage beyond $s5 targets.$?a137048|(a137050&a436707)[; Generates ${$s4/10} Rage.][]$?c1|c3[; If you have Rend, Thunder Clap affects $s5 nearby targets with Rend.; ][]
    thunder_clap = {
        id = 6343,
        cast = 0.0,
        cooldown = 6.0,
        gcd = "global",

        spend = 200,
        spendType = 'rage',

        talent = "thunder_clap",
        startsCombat = true,

        -- Effects:
        -- #0: { 'type': SCHOOL_DAMAGE, 'subtype': NONE, 'ap_bonus': 0.491, 'variance': 0.05, 'radius': 8.0, 'target': TARGET_SRC_CASTER, 'target2': TARGET_UNIT_SRC_AREA_ENEMY, }
        -- #1: { 'type': DUMMY, 'subtype': NONE, 'target': TARGET_UNIT_CASTER, }
        -- #2: { 'type': DUMMY, 'subtype': NONE, 'target': TARGET_UNIT_CASTER, }
        -- #3: { 'type': ENERGIZE, 'subtype': NONE, 'target': TARGET_UNIT_CASTER, 'resource': rage, }
        -- #4: { 'type': DUMMY, 'subtype': NONE, 'target': TARGET_UNIT_CASTER, }

        -- Affected by:
        -- protection_warrior[137048] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- protection_warrior[137048] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- protection_warrior[137048] #19: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 50.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_4_VALUE, }
        -- protection_warrior[137048] #20: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- warrior[137047] #0: { 'type': APPLY_AURA, 'subtype': MOD_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'value': 11, 'schools': ['physical', 'holy', 'nature'], 'target': TARGET_UNIT_CASTER, }
        -- warrior[137047] #1: { 'type': APPLY_AURA, 'subtype': MOD_GLOBAL_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'value': 11, 'schools': ['physical', 'holy', 'nature'], 'target': TARGET_UNIT_CASTER, }
        -- avatar[107574] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.75, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- avatar[107574] #3: { 'type': APPLY_AURA_ON_PET, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.75, 'points': 20.0, 'value': 22, 'schools': ['holy', 'fire', 'frost'], 'target': TARGET_UNIT_CASTER, }
        -- avatar[401150] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.75, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- avatar[401150] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- avatar[401150] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
        -- avatar[401150] #8: { 'type': APPLY_AURA_ON_PET, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.75, 'points': 20.0, 'value': 22, 'schools': ['holy', 'fire', 'frost'], 'target': TARGET_UNIT_CASTER, }
        -- barbaric_training[390674] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- barbaric_training[390674] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_15, }
        -- crackling_thunder[203201] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 50.0, 'target': TARGET_UNIT_CASTER, 'modifies': RADIUS, }
        -- dual_wield_specialization[382900] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- dual_wield_specialization[382900] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- onehanded_weapon_specialization[382895] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- onehanded_weapon_specialization[382895] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- twohanded_weapon_specialization[382896] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- twohanded_weapon_specialization[382896] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- crashing_thunder[436707] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 40.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- crashing_thunder[436707] #3: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 50.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_4_VALUE, }
        -- crashing_thunder[436707] #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- demoralizing_shout[1160] #2: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'pvp_multiplier': 0.5, 'radius': 10.0, 'target': TARGET_SRC_CASTER, 'target2': TARGET_UNIT_SRC_AREA_ENEMY, }
        -- martial_expert[429638] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_15, }
        -- mountain_of_muscle_and_scars[429642] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- mountain_of_muscle_and_scars[429642] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- champions_spear[376080] #4: { 'type': APPLY_AURA, 'subtype': MOD_CRITICAL_DAMAGE_TAKEN_FROM_CASTER, 'points': 25.0, 'radius': 5.0, 'target': TARGET_UNIT_DEST_AREA_ENEMY, }
        -- show_of_force[385842] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- thunder_blast[435615] #0: { 'type': APPLY_AURA, 'subtype': OVERRIDE_ACTIONBAR_SPELLS, 'attributes': ['Suppress Points Stacking'], 'spell': 435222, 'target': TARGET_UNIT_CASTER, }
        -- unnerving_focus[384043] #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 60.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_4_VALUE, }
        -- fury_warrior[137050] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 50.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- fury_warrior[137050] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 50.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- fury_warrior[137050] #9: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 45.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- dance_of_death[459572] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- violent_outburst[386478] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.5, 'points': 200.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- violent_outburst[386478] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 100.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_4_VALUE, }
    },

    -- Roar explosively, dealing $s1 Physical damage to enemies within $A1 yds and cause them to bleed for $397364o1 physical damage over $397364d.
    thunderous_roar = {
        id = 384318,
        cast = 0.0,
        cooldown = 90.0,
        gcd = "global",

        talent = "thunderous_roar",
        startsCombat = true,

        -- Effects:
        -- #0: { 'type': SCHOOL_DAMAGE, 'subtype': NONE, 'ap_bonus': 1.728, 'variance': 0.05, 'radius': 12.0, 'target': TARGET_DEST_CASTER, 'target2': TARGET_UNIT_DEST_AREA_ENEMY, }
        -- #1: { 'type': TRIGGER_SPELL, 'subtype': NONE, 'trigger_spell': 397364, 'target': TARGET_UNIT_CASTER, }

        -- Affected by:
        -- thunderous_words[384969] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 2000.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
        -- uproar[391572] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -45000.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
        -- unnerving_focus[384043] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 60.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_3_VALUE, }
    },

    -- Strikes the target, causing $s1 damage and healing you for $118779s1% of your maximum health.; Only usable within $32216d after you kill an enemy that yields experience or honor.
    victory_rush = {
        id = 34428,
        cast = 0.0,
        cooldown = 0.0,
        gcd = "global",

        startsCombat = true,

        -- Effects:
        -- #0: { 'type': SCHOOL_DAMAGE, 'subtype': NONE, 'chain_targets': 1, 'ap_bonus': 0.472, 'variance': 0.05, 'target': TARGET_UNIT_TARGET_ENEMY, }

        -- Affected by:
        -- protection_warrior[137048] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- protection_warrior[137048] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- warrior[137047] #1: { 'type': APPLY_AURA, 'subtype': MOD_GLOBAL_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'value': 11, 'schools': ['physical', 'holy', 'nature'], 'target': TARGET_UNIT_CASTER, }
        -- avatar[107574] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.75, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- avatar[107574] #3: { 'type': APPLY_AURA_ON_PET, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.75, 'points': 20.0, 'value': 22, 'schools': ['holy', 'fire', 'frost'], 'target': TARGET_UNIT_CASTER, }
        -- avatar[401150] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.75, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- avatar[401150] #8: { 'type': APPLY_AURA_ON_PET, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.75, 'points': 20.0, 'value': 22, 'schools': ['holy', 'fire', 'frost'], 'target': TARGET_UNIT_CASTER, }
        -- dual_wield_specialization[382900] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- dual_wield_specialization[382900] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- onehanded_weapon_specialization[382895] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- onehanded_weapon_specialization[382895] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- twohanded_weapon_specialization[382896] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- twohanded_weapon_specialization[382896] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- demoralizing_shout[1160] #2: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'pvp_multiplier': 0.5, 'radius': 10.0, 'target': TARGET_SRC_CASTER, 'target2': TARGET_UNIT_SRC_AREA_ENEMY, }
        -- martial_expert[429638] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_15, }
        -- mountain_of_muscle_and_scars[429642] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- mountain_of_muscle_and_scars[429642] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- champions_spear[376080] #4: { 'type': APPLY_AURA, 'subtype': MOD_CRITICAL_DAMAGE_TAKEN_FROM_CASTER, 'points': 25.0, 'radius': 5.0, 'target': TARGET_UNIT_DEST_AREA_ENEMY, }
        -- whirlwind[85739] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'attributes': ['Suppress Points Stacking'], 'points': 4.0, 'target': TARGET_UNIT_CASTER, 'modifies': CHAINED_TARGETS, }
        -- fury_warrior[137050] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 50.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- fury_warrior[137050] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 50.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- dance_of_death[459572] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
    },

    -- [34428] Strikes the target, causing $s1 damage and healing you for $118779s1% of your maximum health.; Only usable within $32216d after you kill an enemy that yields experience or honor.
    victory_rush_118779 = {
        id = 118779,
        cast = 0.0,
        cooldown = 30.0,
        gcd = "global",

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': HEAL_PCT, 'subtype': NONE, 'points': 10.0, 'target': TARGET_UNIT_CASTER, }
        -- #1: { 'type': APPLY_AURA, 'subtype': MOD_SCALE, 'target': TARGET_UNIT_CASTER, }

        -- Affected by:
        -- protection_warrior[137048] #7: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': THREAT, }
        -- victory_rush[319158] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_1_VALUE, }
        from = "class",
    },

    -- Stomp the ground, causing a ring of corrupted spikes to erupt upwards, dealing $sw1 Shadow damage and applying the Colossus Smash effect to all nearby enemies.
    warbreaker = {
        id = 209577,
        color = 'artifact',
        cast = 0.0,
        cooldown = 60.0,
        gcd = "global",

        startsCombat = true,

        -- Effects:
        -- #0: { 'type': WEAPON_PERCENT_DAMAGE, 'subtype': NONE, 'points': 119.0, 'radius': 8.0, 'target': TARGET_SRC_CASTER, 'target2': TARGET_UNIT_SRC_AREA_ENEMY, }
        -- #1: { 'type': NORMALIZED_WEAPON_DMG, 'subtype': NONE, 'radius': 8.0, 'target': TARGET_SRC_CASTER, 'target2': TARGET_UNIT_SRC_AREA_ENEMY, }
    },

    -- Unleashes a whirlwind of steel, $?s202316[hitting your primary target with Slam and ][]striking all nearby targets for $<baseDmg> Physical damage. Deals reduced damage beyond $s1 targets.
    whirlwind = {
        id = 1680,
        cast = 0.0,
        cooldown = 0.0,
        gcd = "global",

        spend = 200,
        spendType = 'rage',

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': TRIGGER_SPELL, 'subtype': NONE, 'attributes': ['Is Harmful'], 'trigger_spell': 199658, 'points': 5.0, 'target': TARGET_UNIT_CASTER, }
        -- #1: { 'type': TRIGGER_SPELL, 'subtype': NONE, 'attributes': ['Is Harmful'], 'trigger_spell': 199850, 'value': 200, 'schools': ['nature', 'arcane'], 'target': TARGET_UNIT_CASTER, }
        -- #2: { 'type': TRIGGER_SPELL, 'subtype': NONE, 'attributes': ['Is Harmful'], 'trigger_spell': 411547, 'value': 400, 'schools': ['frost'], 'target': TARGET_UNIT_CASTER, }

        -- Affected by:
        -- warrior[137047] #0: { 'type': APPLY_AURA, 'subtype': MOD_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'value': 11, 'schools': ['physical', 'holy', 'nature'], 'target': TARGET_UNIT_CASTER, }
        -- warrior[137047] #1: { 'type': APPLY_AURA, 'subtype': MOD_GLOBAL_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'value': 11, 'schools': ['physical', 'holy', 'nature'], 'target': TARGET_UNIT_CASTER, }
        -- barbaric_training[390674] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- barbaric_training[390674] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_15, }
        -- barbaric_training[383082] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- barbaric_training[383082] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_15, }
        -- storm_of_swords[388903] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 7000.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
        -- storm_of_swords[388903] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 80.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
    },

    -- Hurl your weapon at the enemy, causing $<damage> Physical damage, ignoring armor. Deals up to $?s329033[${($329033s3/100+1)*500}][500]% increased damage to absorb shields.
    wrecking_throw = {
        id = 384110,
        cast = 0.0,
        cooldown = 45.0,
        gcd = "global",

        talent = "wrecking_throw",
        startsCombat = true,

        -- Effects:
        -- #0: { 'type': TRIGGER_MISSILE, 'subtype': NONE, 'trigger_spell': 394354, 'variance': 0.05, 'target': TARGET_UNIT_TARGET_ENEMY, }

        -- Affected by:
        -- demolition[329033] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -50.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
    },

} )