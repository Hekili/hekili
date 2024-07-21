-- WarriorArms.lua
-- July 2024

local addon, ns = ...
local Hekili = _G[ addon ]
local class, state = Hekili.Class, Hekili.State

local spec = Hekili:NewSpecialization( 71 )

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

    -- Arms Talents
    anger_management                = { 90289, 152278, 1 }, -- Every $?c1[$s1]?c2[$s3][$s2] Rage you spend$?c1[ on attacks][] reduces the remaining cooldown on $?c1&s262161[Warbreaker, Bladestorm, and Ravager]?c1[Colossus Smash, Bladestorm, and Ravager]?c2[Recklessness, Bladestorm, and Ravager][Avatar and Shield Wall] by 1 sec.
    arterial_bleed                  = { 94799, 440995, 1 }, -- Colossal Might increases the damage of your Rend and Deep Wounds by $440989s2% per stack.; 
    battle_stance                   = { 90327, 386164, 1 }, -- A balanced combat state that increases the critical strike chance of your abilities by $s1% and reduces the duration of movement impairing effects by $s2%. ; Lasts until canceled.
    battlelord                      = { 92615, 386630, 1 }, -- Overpower has a $h% chance to reset the cooldown of Mortal Strike and generate ${$386631s1/10} Rage.
    bladestorm                      = { 90441, 227847, 1 }, -- Become an unstoppable storm of destructive force, striking all nearby enemies for $<dmg> Physical damage over $d. Deals reduced damage beyond $s1 targets.; You are immune to movement impairing and loss of control effects, but can use defensive abilities and can avoid attacks.; $?c2[; Generates ${$50622s3/10} Rage each time you deal damage.][]
    bloodborne                      = { 90283, 383287, 2 }, -- Deep Wounds, Rend and Thunderous Roar's Bleed effects deal ${$s2/10}.2% increased damage.
    bloodletting                    = { 90438, 383154, 1 }, -- Deep Wounds, Rend and Thunderous Roar's Bleed effects last ${$s1/1000}.1 sec longer and have a $s2% increased critical strike chance.; If you have Rend, Mortal Strike inflicts Rend on targets below $s4% health.; 
    bloodsurge                      = { 90277, 384361, 1 }, -- Damage from your Bleed effects have a $H% chance to grant you ${$384362s1/10} Rage.
    blunt_instruments               = { 90287, 383442, 1 }, -- Colossus Smash damage increased by $s1% and its effect duration is increased by ${$s2/1000}.1 sec.
    boneshaker                      = { 94789, 429639, 1 }, -- Shockwave's stun duration is increased by ${$s1/1000} sec and reduces the movement speed of affected enemies by $458480s1% for $458480d after the stun ends.
    brutal_finish                   = { 94786, 446085, 1 }, -- Your next $?c1[Mortal Strike][Rampage] after Bladestorm ends deals $446918s1% additional damage.
    cleave                          = { 90293, 845   , 1 }, -- Strikes all enemies in front of you for $s1 Physical damage, inflicting Deep Wounds. Cleave will consume your Overpower effect to deal increased damage. Deals reduced damage beyond $s2 targets.
    collateral_damage               = { 92536, 334779, 1 }, -- When Sweeping Strikes ends, your next Cleave or Whirlwind deals $334783s1% increased damage for each ability used during Sweeping Strikes that damaged a second target.
    colossal_might                  = { 94819, 429634, 1 }, -- Colossal Might increases damage dealt by your next Demolish by $440989s1%, stacking up to $440989u times.; $?c1[Mortal Strike and Execute][Shield Slam and Execute] grant a stack of Colossal Might and $?c1[Cleave][Revenge] grants a stack of Colossal Might when it strikes $s1 or more targets.
    colossus_smash                  = { 90290, 167105, 1 }, -- Smashes the enemy's armor, dealing $s1 Physical damage, and increasing damage you deal to them by $208086s1% for $208086d.
    critical_thinking               = { 90444, 389306, 2 }, -- Critical Strike chance increased by $s1% and Execute immediately refunds $s2% of the Rage spent.
    culling_cyclone                 = { 94786, 444778, 1 }, -- Each strike of Bladestorm deals an additional $s1% damage evenly split across all targets.
    dance_of_death                  = { 92535, 390713, 1 }, -- $?c1[When an enemy dies while affected by your Bladestorm, all damage you deal is increased by $459572s1% for the remainder of the Bladestorm and for $459572d afterwards.; ][]When an enemy dies while affected by your Ravager, its duration is extended by ${$s1/1000} sec.; $?c1[These effects][This effect] can trigger a maximum of $s2 times per use of $?c1[Bladestorm or ][]Ravager.
    death_drive                     = { 94813, 444770, 1 }, -- You heal for $s1% of damage dealt by Sudden Death.
    defensive_stance                = { 92537, 386208, 1 }, -- A defensive combat state that reduces all damage you take by $s1%$?a452494[ and all magic damage you take by an additional $s3%][]$?a137048[][, and all damage you deal by $s2%]. ; Lasts until canceled.
    deft_experience                 = { 90437, 389308, 2 }, -- Mastery increased by $s1% and Tactician's chance to trigger is increased by an additional ${$s2/100}.1%.
    demolish                        = { 94818, 436358, 1 }, -- Unleash a series of precise and powerful strikes against your target, dealing ${$440884s1+$440886s1+$440888s1} damage to it, and $440888s1 damage to enemies within 8 yds of it. Deals reduced damage beyond $s1 targets.; While channeling Demolish, you take $s4% less damage and are immune to stuns, knockbacks, and forced movement effects.; You can block, parry, dodge, and use certain defensive abilities while channeling Demolish.
    die_by_the_sword                = { 90276, 118038, 1 }, -- Increases your parry chance by $s1% and reduces all damage you take by $s2% for $d.
    dominance_of_the_colossus       = { 94793, 429636, 1 }, -- Colossal Might now stacks up to 10 times. If you would gain a stack of Colossal Might and are at max stacks, the cooldown of Demolish is reduced by $s2 sec.; Enemies affected by Demolish take up to ${$447513s2*$447513u*0.1}% more damage from you and deal up to ${$447513s1*$447513u*-0.1}% less damage to you for $447513d based on the number of stacks of Colossal Might consumed by Demolish.
    dreadnaught                     = { 90285, 262150, 1 }, -- Overpower causes a seismic wave, dealing $315961s1 damage to all enemies in a $315961A1 yd line. Deals reduced damage beyond $315961s2 targets.
    earthquaker                     = { 94789, 440992, 1 }, -- Shockwave also knocks enemies into the air, and its cooldown is reduced by ${$s1/-1000} sec.
    executioners_precision          = { 90445, 386634, 1 }, -- $?a317320[Condemn][Execute] causes the target to take $s1% more damage from your next Mortal Strike, stacking up to $386633u times.
    exhilarating_blows              = { 90286, 383219, 1 }, -- Mortal Strike and Cleave have a $h% chance to instantly reset their own cooldowns.
    fatality                        = { 90439, 383703, 1 }, -- Your Mortal Strikes and Cleaves against enemies above $383704s1% health have a high chance to apply Fatal Mark. When an enemy falls below $383704s1% health, Your next Execute inflicts an additional $383706s1 Physical damage per stack.
    fervor_of_battle                = { 90272, 202316, 1 }, -- If Cleave or Whirlwind hit $s1 or more targets you also Slam your primary target.
    fierce_followthrough            = { 94787, 444773, 1 }, -- $?c1[Mortal Strike][Bloodthirst] critical strikes increase the damage of your next $?c1[Mortal Strike][Bloodthirst] by $458689s1%.; 
    finishing_blows                 = { 92614, 400205, 1 }, -- Overpower generates ${$400806s1/10} Rage when used on enemies below $s2% health.; 
    fueled_by_violence              = { 90275, 383103, 1 }, -- You are healed for $s1% of the damage dealt by Deep Wounds.
    ignore_pain                     = { 90269, 190456, 1 }, -- Fight through the pain, ignoring $s2% of damage taken, up to ${$mhp*$s4/100} total damage prevented.
    imminent_demise                 = { 94788, 444769, 1 }, -- Every $s1 Slayer's Strikes you gain Sudden Death.; Using Sudden Death accelerates your next Bladestorm, striking 1 additional time (max $445606u). Bladestorm's total duration is unchanged.
    impale                          = { 90292, 383430, 1 }, -- Critical strike damage of your abilities is increased by $s1%.
    improved_execute                = { 90273, 316405, 1 }, -- Execute no longer has a cooldown and if your foe survives, $163201s2% of the Rage spent is refunded.
    improved_overpower              = { 90279, 385571, 1 }, -- Overpower has ${1+$s2} charges and deals $s1% more damage.
    improved_sweeping_strikes       = { 92536, 383155, 1 }, -- Sweeping Strikes lasts ${$s1/1000} sec longer.
    in_for_the_kill                 = { 90288, 248621, 1 }, -- $?s262161[Warbreaker][Colossus Smash] increases your Haste by $s1%, or by $s2% if $?s262161[any][the] target is below $s3% health. Lasts for the duration of $?s262161[Warbreaker][Colossus Smash].
    juggernaut                      = { 90446, 383292, 1 }, -- Execute increases Execute's damage dealt by $383290s1% for $383290d, stacking up to $383290u times.
    martial_expert                  = { 94812, 429638, 1 }, -- Critical strike damage of your abilities is increased by $s1% and the amount of damage blocked by your critical blocks is increased by $s2%.
    martial_prowess                 = { 90278, 316440, 1 }, -- Overpower increases the damage of your next Mortal Strike or Cleave by $7384s2%, stacking up to ${$s2+1} times.
    massacre                        = { 90291, 281001, 1 }, -- $?a317320[Condemn][Execute] is now usable on targets below $s2% health.; 
    merciless_bonegrinder           = { 90266, 383317, 1 }, -- Whirlwind and Cleave deal $383316s1% increased damage during Ravager or for $<bstorm> sec after Bladestorm ends.
    mortal_strike                   = { 90270, 12294 , 1 }, -- A vicious strike that deals $s1 Physical damage and reduces the effectiveness of healing on the target by $115804s1% for $115804d.
    mountain_of_muscle_and_scars    = { 94806, 429642, 1 }, -- You deal $s1% more damage and take ${$s4/-10}.1% less damage.; Size increased by $s5%.
    no_stranger_to_pain             = { 94815, 429644, 1 }, -- Total damage prevented by Ignore Pain increased by $s1%.
    one_against_many                = { 94799, 429637, 1 }, -- Shockwave, $?c1[Cleave][Revenge], and Whirlwind deal $s1% more damage per target affected up to $s2.
    opportunist                     = { 94787, 444774, 1 }, -- $?c1[When Overpower has its cooldown reset by Tactician, your next Overpower deals $456120s3% additional damage and $456120s4% additional critical damage.][When Raging Blow resets its own cooldown, your next Raging Blow deals $456120s1% additional damage and $456120s2% additional critical damage.]
    overpower                       = { 90271, 7384  , 1 }, -- Overpower the enemy, dealing $s1 Physical damage. Cannot be blocked, dodged, or parried.$?s316440&s845[; Increases the damage of your next Mortal Strike or Cleave by $s2%, stacking up to $u times]?s316440[; Increases the damage of your next Mortal Strike by $s2%, stacking up to $u times.][]$?s400801[; Generates ${$7384s3/10} Rage.][]; 
    overwhelming_blades             = { 94810, 444772, 1 }, -- Each strike of Bladestorm applies Overwhelmed to all enemies affected, increasing damage you deal to them by $445836s1% for $445836d, max $445836u stacks.
    practiced_strikes               = { 94796, 429647, 1 }, -- $?c1[Mortal Strike and Cleave][Shield Slam and Revenge] damage increased by $s1%.
    precise_might                   = { 94794, 431548, 1 }, -- $?c1[Mortal Strike][Shield Slam] critical strikes grant an additional stack of Colossal Might.
    ravager                         = { 90441, 228920, 1 }, -- Throws a whirling weapon at the target location that chases nearby enemies, inflicting $<damage> Physical damage to all enemies over $d. Deals reduced damage beyond $156287s2 targets.; Generates ${$334934s1/10} Rage each time it deals damage.
    reap_the_storm                  = { 94809, 444775, 1 }, -- $?c1[Mortal Strike and Cleave have][Bloodthirst has] a $h% chance to cause you to unleash a flurry of steel, striking all nearby enemies for $446005s1 damage and applying Overwhelmed. Deals reduced damage beyond $s1 targets.; 
    relentless_pursuit              = { 94795, 444776, 1 }, -- Charge grants you $446044s1% movement speed for $446044d.; Charge removes all movement impairing effects, this effect cannot occur more than once every $458386d.; 
    rend                            = { 90284, 772   , 1 }, -- Wounds the target, causing $s1 Physical damage instantly and an additional $388539o1 Bleed damage over $388539d.$?s6343[; Thunder Clap affects $6343s5 nearby targets with Rend.; ][]
    sharpened_blades                = { 90447, 383341, 1 }, -- Your Mortal Strike, Cleave and Execute critical strike damage is increased by $s1% and your Execute has a $s2% increased critical hit chance.
    show_no_mercy                   = { 94784, 444771, 1 }, -- Marked for Execution increases the critical strike chance and critical strike damage of your next Execute on the target by $445584s2%.
    skullsplitter                   = { 90281, 260643, 1 }, -- Bash an enemy's skull, dealing $s1 Physical damage.; Skullsplitter causes your Rend and Deep Wounds on the target to bleed out $427040s1% faster for $427040d.; Generates ${$s2/10} Rage.
    slayers_dominance               = { 94814, 444767, 1 }, -- Your attacks against your primary target have a high chance to overwhelm their defenses and trigger a Slayer's Strike, dealing $445579s1 damage and applying Marked for Execution, increasing the damage they take from your next Execute by $445584s1%. Stacks $445584u times.
    slayers_malice                  = { 94801, 444779, 1 }, -- $?c1[Overpower][Raging Blow] damage increased by $s1%.
    spiteful_serenity               = { 90289, 400314, 1 }, -- Colossus Smash and Avatar's durations are increased by $s10% but their damage bonuses are reduced by $s9%.
    storm_of_swords                 = { 90267, 385512, 1 }, -- Cleave and Whirlwind have a $H% chance to make your next Cleave or Whirlwind cost $439601s1% less Rage.
    storm_wall                      = { 90269, 388807, 1 }, -- Whenever you Parry, you heal for ${$m1}.2% of your maximum health. Can only occur once per second.
    strength_of_arms                = { 90285, 400803, 1 }, -- Overpower deals $s3% additional damage, has $s1% increased critical strike chance, and deals $s2% increased critical strike damage.; 
    sudden_death                    = { 90274, 29725 , 1 }, -- Your attacks have a chance to make your next $?a317320[Condemn][Execute] cost no Rage, be usable on any target regardless of their health, and deal damage as if you spent $s1 Rage.
    tactician                       = { 90282, 184783, 1 }, -- You have a ${$s1/100}.2% chance per Rage spent on attacks to reset the remaining cooldown on Overpower.
    test_of_might                   = { 90288, 385008, 1 }, -- When $?s262161[Warbreaker][Colossus Smash] expires, your Strength is increased by $s1% for every $s3 Rage you spent on attacks during $?s262161[Warbreaker][Colossus Smash]. Lasts $385013d.
    tide_of_battle                  = { 94811, 429641, 1 }, -- Colossal Might increases the damage of your $?c1[Overpower][Revenge] by $440989s3% per stack.
    unhinged                        = { 90440, 386628, 1 }, -- Every other time Bladestorm or Ravager deal damage, you automatically cast a $?c1[Mortal Strike][Bloodthirst] at your target or random nearby enemy$?a134735[, dealing $s3% of normal damage.][.]; 
    unrelenting_onslaught           = { 94820, 444780, 1 }, -- When you Execute a target that you've Marked for Execution, you both reduce the cooldown of Bladestorm by $s1 sec and apply $s2 stacks of Overwhelmed to the target per stack of Marked for Execution consumed.; You can now use Pummel and Storm Bolt while Bladestorming.
    valor_in_victory                = { 90442, 383338, 1 }, -- Increases Versatility by $s1% and reduces the cooldown of Die by the Sword by ${$s2/-1000}.1 sec.
    veteran_vitality                = { 94815, 440993, 1 }, -- When your health is brought below 35%, you gain a Second Wind, healing you for ${$441387s1*$441387t1*$441387d}% of your max health over $441387d.; This effect cannot occur more than once every $proccooldown sec.
    vicious_agility                 = { 94795, 444777, 1 }, -- Heroic Leap reduces the cooldown of Charge by $s1 sec and Charge reduces the cooldown of Heroic Leap by $s2 sec.
    warbreaker                      = { 90287, 262161, 1 }, -- Smash the ground and shatter the armor of all enemies within $A1 yds, dealing $s1 Physical damage and increasing damage you deal to them by $208086s1% for $208086d.
} )

-- PvP Talents
spec:RegisterPvpTalents( {
    battlefield_commander  = 5630, -- (424742) Your Shout abilities have additional effects.; $@spellicon6673 $@spellname6673:; Increases Stamina by $s1%.; $@spellicon12323 $@spellname12323:; Radius increased by $s6%; $@spellicon384100 $@spellname384100:; Range increased by $s2 yds.; $@spellicon5246 $@spellname5246:; Cooldown reduced by ${$s3/-1000} sec.; $@spellicon97462 $@spellname97462:; Removes movement impairing effects and grants $s4% movement speed to allies.; $@spellicon384318 $@spellname384318:; Targets receive $s5% more damage from all sources while bleeding.
    demolition             = 5372, -- (329033) Reduces the cooldown of your Shattering Throw or Wrecking Throw by $s1% and increases its damage to absorb shields by an additional ${$s3*5}%.
    disarm                 = 3534, -- (236077) Disarm the enemy's weapons and shield for $d. Disarmed creatures deal significantly reduced damage.
    duel                   = 34  , -- (236273) You challenge the target to a duel. While challenged, all damage you and the target deal to all targets other than each other is reduced by $m1%. Lasts $d.
    master_and_commander   = 28  , -- (235941) Cooldown of Rallying Cry reduced by ${$s1/1000} sec, and grants $m3% additional health.
    rebound                = 5547, -- (213915) Spell Reflection reflects the next $s3 incoming spells cast on you and reflected spells deal $s1% extra damage to the attacker.; Spell Reflection's cooldown is increased by ${$s2/1000} sec.
    safeguard              = 5625, -- (424654) Intervene now has ${$s1+1} charges and reduces the ally's damage taken by $424655s1% for $424655d.; Intervene's cooldown is increased by ${$s2/1000} sec.
    shadow_of_the_colossus = 29  , -- (198807) Charge resets the cooldown of your Overpower and Rage gained from $?s198758|s198304[Intercept][Charge] increased by ${$m2/10}.
    sharpen_blade          = 33  , -- (198817) When activated, your next Mortal Strike will deal $m1% increased damage and reduce healing taken by $198819m1% for $198819d.
    storm_of_destruction   = 31  , -- (236308) Bladestorm and Ravager now snare all targets you hit by $424597s1% for $424597d and decrease their healing taken by $115804s1% for $115804d.
    war_banner             = 32  , -- (236320) You throw down a war banner at your feet, rallying your allies. ; Increases movement speed by $236321m1% and reduces the duration of all incoming crowd control effects by $236321m2% to all allies within $A2 yards of the war banner. Lasts $d.
    warbringer             = 5376, -- (356353) Charge roots enemies for ${1+$s1/1000} sec and emanates a shockwave past the target, rooting enemies and dealing $356356s2 Physical damage in a $356356a1 yd cone.
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
        -- spiteful_serenity[400314] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -40.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_1_VALUE, }
        -- spiteful_serenity[400314] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -40.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_3_VALUE, }
        -- spiteful_serenity[400314] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -40.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_4_VALUE, }
        -- spiteful_serenity[400314] #3: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 20000.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
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

        -- Affected by:
        -- bladestorm[227847] #2: { 'type': APPLY_AURA, 'subtype': ALLOW_ONLY_ABILITY, 'target': TARGET_UNIT_CASTER, }
    },
    -- Your next Mortal Strike or Cleave costs ${$w1/10} less Rage.
    battlelord = {
        id = 386631,
        duration = 0.0,
        max_stack = 1,
    },
    -- Immune to Fear, Sap, and Incapacitate effects.
    berserker_rage = {
        id = 18499,
        duration = 6.0,
        max_stack = 1,

        -- Affected by:
        -- bladestorm[227847] #2: { 'type': APPLY_AURA, 'subtype': ALLOW_ONLY_ABILITY, 'target': TARGET_UNIT_CASTER, }
    },
    -- Immune to Fear, Sap, and Incapacitate effects.
    berserker_shout = {
        id = 384100,
        duration = 6.0,
        max_stack = 1,

        -- Affected by:
        -- bladestorm[227847] #2: { 'type': APPLY_AURA, 'subtype': ALLOW_ONLY_ABILITY, 'target': TARGET_UNIT_CASTER, }
    },
    -- Dealing damage to all nearby enemies every $t1 sec.; Immune to crowd control.
    bladestorm = {
        id = 227847,
        duration = 6.0,
        pandemic = true,
        max_stack = 1,

        -- Affected by:
        -- arms_warrior[137049] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
    },
    -- Bleeding for $w1 every $t1 sec.
    bloodbath = {
        id = 113344,
        duration = 6.0,
        tick_time = 1.0,
        pandemic = true,
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
    -- $?c1[Mortal Strike][Rampage] damage increased by $w1%.
    brutal_finish = {
        id = 446918,
        duration = 10.0,
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
    },
    -- Rooted.
    charge = {
        id = 105771,
        duration = 1.0,
        max_stack = 1,

        -- Affected by:
        -- warbringer[356353] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'trigger_spell': 105771, 'points': 1000.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
    },
    -- The damage of your next Cleave or Whirlwind is increased by $w1%.
    collateral_damage = {
        id = 334783,
        duration = 30.0,
        max_stack = 1,
    },
    -- Damage dealt by Demolish increased by $w1%.; $?(a429641&c1)[Damage dealt by Overpower increased by $w3%.]?$?(a429641&c3)[Damage dealt by Revenge increased by $w3%.][]; $?a440995[Damage dealt by Rend and Deep Wounds increased by $w2%.][]
    colossal_might = {
        id = 440989,
        duration = 24.0,
        max_stack = 1,

        -- Affected by:
        -- dominance_of_the_colossus[429636] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER_BY_LABEL, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': MAX_STACKS, }
    },
    -- Taking $w1% additional damage from $@auracaster.
    colossus_smash = {
        id = 208086,
        duration = 10.0,
        max_stack = 1,

        -- Affected by:
        -- blunt_instruments[383442] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 30.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- blunt_instruments[383442] #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 3000.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
        -- spiteful_serenity[400314] #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'points': -40.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_1_VALUE, }
        -- spiteful_serenity[400314] #5: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'points': -40.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_2_VALUE, }
        -- spiteful_serenity[400314] #6: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER_BY_LABEL, 'points': 10000.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
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
    -- Bleeding for $w1 every $t1 sec. Suffering $w2% increased damage from $@auracaster.
    deep_wounds = {
        id = 262115,
        duration = 12.0,
        tick_time = 3.0,
        pandemic = true,
        max_stack = 1,

        -- Affected by:
        -- mastery_deep_wounds[262111] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'sp_bonus': 1.1, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_2_VALUE, }
        -- mastery_deep_wounds[262111] #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'sp_bonus': 1.1, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_3_VALUE, }
        -- bloodborne[383287] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 7.5, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- bloodletting[383154] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 6000.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
        -- bloodletting[383154] #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': CRIT_CHANCE, }
        -- thunderous_roar[397364] #2: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'points': 30.0, 'radius': 12.0, 'target': TARGET_DEST_CASTER, 'target2': TARGET_UNIT_DEST_AREA_ENEMY, }
        -- colossal_might[440989] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
    },
    -- Damage taken reduced by $s1%.; $?a452494[Magic damage taken reduced by an additional $s3%.][]; $?a137048[][Damage done reduced by $s2%.]
    defensive_stance = {
        id = 386208,
        duration = 3600,
        max_stack = 1,

        -- Affected by:
        -- bladestorm[227847] #2: { 'type': APPLY_AURA, 'subtype': ALLOW_ONLY_ABILITY, 'target': TARGET_UNIT_CASTER, }
        -- protection_warrior[137048] #16: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER_BY_LABEL, 'points': -1.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_1_VALUE, }
        -- protection_warrior[137048] #17: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER_BY_LABEL, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_2_VALUE, }
        -- fight_through_the_flames[452494] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER_BY_LABEL, 'points': -6.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_3_VALUE, }
    },
    -- Parry chance increased by $s1%.; Damage taken reduced by $w2%.
    die_by_the_sword = {
        id = 118038,
        duration = 8.0,
        max_stack = 1,

        -- Affected by:
        -- honed_reflexes[391271] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -5.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
        -- bladestorm[227847] #2: { 'type': APPLY_AURA, 'subtype': ALLOW_ONLY_ABILITY, 'target': TARGET_UNIT_CASTER, }
        -- demolish[436358] #2: { 'type': APPLY_AURA, 'subtype': ALLOW_ONLY_ABILITY, 'target': TARGET_UNIT_CASTER, }
        -- valor_in_victory[383338] #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -30000.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
    },
    -- Disarmed!
    disarm = {
        id = 236077,
        duration = 5.0,
        max_stack = 1,
    },
    -- You are challenged by the Warrior.; All damage done to targets other than the Warrior is reduced by $m1%.
    duel = {
        id = 236273,
        duration = 12.0,
        max_stack = 1,
    },
    -- Damage from $@auracaster's next Mortal Strike increased by $w1%.
    executioners_precision = {
        id = 386633,
        duration = 30.0,
        max_stack = 1,
    },
    -- Falling below $s1% health will cause Fatal Mark to inflict $383706s1 Physical damage.
    fatal_mark = {
        id = 383704,
        duration = 180.0,
        max_stack = 1,
    },
    -- $?c1[Mortal Strike][Bloodthirst] damage increased by $w1%.
    fierce_followthrough = {
        id = 458689,
        duration = 12.0,
        max_stack = 1,
    },
    -- Movement slowed by $s1%.
    hamstring = {
        id = 1715,
        duration = 15.0,
        max_stack = 1,

        -- Affected by:
        -- arms_warrior[137049] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 30.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- arms_warrior[137049] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 30.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- sweeping_strikes[260708] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 1.0, 'target': TARGET_UNIT_CASTER, 'modifies': CHAINED_TARGETS, }
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
        -- impale[383430] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_15, }
        -- martial_expert[429638] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_15, }
        -- mountain_of_muscle_and_scars[429642] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- mountain_of_muscle_and_scars[429642] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- deep_wounds[262115] #1: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- deep_wounds[262115] #4: { 'type': APPLY_AURA, 'subtype': MOD_CRITICAL_DAMAGE_TAKEN_FROM_CASTER, 'pvp_multiplier': 0.5, 'points': 5.0, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- champions_spear[376080] #4: { 'type': APPLY_AURA, 'subtype': MOD_CRITICAL_DAMAGE_TAKEN_FROM_CASTER, 'points': 25.0, 'radius': 5.0, 'target': TARGET_UNIT_DEST_AREA_ENEMY, }
        -- whirlwind[85739] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'attributes': ['Suppress Points Stacking'], 'points': 4.0, 'target': TARGET_UNIT_CASTER, 'modifies': CHAINED_TARGETS, }
        -- protection_warrior[137048] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- protection_warrior[137048] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- colossus_smash[208086] #0: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'pvp_multiplier': 0.666667, 'points': 30.0, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- dance_of_death[459572] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
    },
    -- Ignoring $s2% of damage taken, preventing $w1 total damage.
    ignore_pain = {
        id = 190456,
        duration = 12.0,
        max_stack = 1,

        -- Affected by:
        -- arms_warrior[137049] #8: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 10000.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
        -- neltharions_fury[203524] #3: { 'type': APPLY_AURA, 'subtype': ALLOW_ONLY_ABILITY, 'target': TARGET_UNIT_CASTER, }
        -- bladestorm[227847] #2: { 'type': APPLY_AURA, 'subtype': ALLOW_ONLY_ABILITY, 'target': TARGET_UNIT_CASTER, }
        -- demolish[436358] #2: { 'type': APPLY_AURA, 'subtype': ALLOW_ONLY_ABILITY, 'target': TARGET_UNIT_CASTER, }
    },
    -- Your next Bladestorm will strike $s1 additional $Ltime:times;.
    imminent_demise = {
        id = 445606,
        duration = 60.0,
        max_stack = 1,
    },
    -- Melee and ranged attacks made against you will be made against $@auracaster instead.
    intervene = {
        id = 147833,
        duration = 6.0,
        max_stack = 1,

        -- Affected by:
        -- honed_reflexes[391271] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -5.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
        -- demolish[436358] #2: { 'type': APPLY_AURA, 'subtype': ALLOW_ONLY_ABILITY, 'target': TARGET_UNIT_CASTER, }
        -- shadow_of_the_colossus[198807] #2: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 150.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_2_VALUE, }
    },
    -- Disoriented.
    intimidating_shout = {
        id = 316595,
        duration = 15.0,
        max_stack = 1,

        -- Affected by:
        -- battlefield_commander[424742] #2: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -15000.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
    },
    -- Execute damage increased by $s1%.
    juggernaut = {
        id = 383290,
        duration = 12.0,
        max_stack = 1,
    },
    -- Execute damage$?e1[, critical strike chance, and critical strike damage][] from $@auracaster increased by $w1%.
    marked_for_execution = {
        id = 445584,
        duration = 30.0,
        max_stack = 1,
    },
    -- Whirlwind and Cleave deal $s1% increased damage.
    merciless_bonegrinder = {
        id = 383316,
        duration = 9.0,
        max_stack = 1,
    },
    -- Healing effects received reduced by $w1%.
    mortal_strike = {
        id = 198819,
        duration = 4.0,
        max_stack = 1,
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
    -- $?c1[Overpower damage increased by $w3% and critical strike damage increased by $w4%.][Raging Blow damage increased by $w1% and critical strike damage increased by $w2%.; ]
    opportunist = {
        id = 456120,
        duration = 8.0,
        max_stack = 1,
    },
    -- Your next Mortal Strike $?s845[or Cleave ][]will deal $w2% increased damage.
    overpower = {
        id = 7384,
        duration = 15.0,
        max_stack = 1,

        -- Affected by:
        -- arms_warrior[137049] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 30.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- arms_warrior[137049] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 30.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- sweeping_strikes[260708] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 1.0, 'target': TARGET_UNIT_CASTER, 'modifies': CHAINED_TARGETS, }
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
        -- impale[383430] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_15, }
        -- improved_overpower[385571] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- improved_overpower[385571] #1: { 'type': APPLY_AURA, 'subtype': MOD_MAX_CHARGES, 'points': 1.0, 'target': TARGET_UNIT_CASTER, }
        -- martial_expert[429638] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_15, }
        -- martial_prowess[316440] #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 1.0, 'target': TARGET_UNIT_CASTER, 'modifies': MAX_STACKS, }
        -- mountain_of_muscle_and_scars[429642] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- mountain_of_muscle_and_scars[429642] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- slayers_malice[444779] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- strength_of_arms[400803] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': CRIT_CHANCE, }
        -- strength_of_arms[400803] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_15, }
        -- strength_of_arms[400803] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- deep_wounds[262115] #1: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- deep_wounds[262115] #4: { 'type': APPLY_AURA, 'subtype': MOD_CRITICAL_DAMAGE_TAKEN_FROM_CASTER, 'pvp_multiplier': 0.5, 'points': 5.0, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- champions_spear[376080] #4: { 'type': APPLY_AURA, 'subtype': MOD_CRITICAL_DAMAGE_TAKEN_FROM_CASTER, 'points': 25.0, 'radius': 5.0, 'target': TARGET_UNIT_DEST_AREA_ENEMY, }
        -- colossal_might[440989] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- protection_warrior[137048] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- protection_warrior[137048] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- colossus_smash[208086] #0: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'pvp_multiplier': 0.666667, 'points': 30.0, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- dance_of_death[459572] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- opportunist[456120] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- opportunist[456120] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_15, }
    },
    -- Taking $w1% more damage from $@auracaster.
    overwhelmed = {
        id = 445836,
        duration = 20.0,
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
    -- Reduces healing received from critical heals by $w1%.$?$w2>0[; Damage taken increased by $w2.][]
    pvp_rules_enabled_hardcoded = {
        id = 134735,
        duration = 20.0,
        max_stack = 1,
    },
    -- Health increased by $97462s1% of maximum.$?a424742[; Movement speed increased by $424742s4%.][]
    rallying_cry = {
        id = 97463,
        duration = 10.0,
        max_stack = 1,

        -- Affected by:
        -- bladestorm[227847] #2: { 'type': APPLY_AURA, 'subtype': ALLOW_ONLY_ABILITY, 'target': TARGET_UNIT_CASTER, }
        -- battlefield_commander[424742] #3: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 30.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_3_VALUE, }
        -- master_and_commander[235941] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -90000.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
    },
    -- Ravager is currently active.
    ravager = {
        id = 228920,
        duration = 12.0,
        tick_time = 2.0,
        pandemic = true,
        max_stack = 1,
    },
    -- Movement speed increased by $s1%.
    relentless_pursuit = {
        id = 446044,
        duration = 3.0,
        max_stack = 1,
    },
    -- Bleeding for $w1 damage every $t1 sec.
    rend = {
        id = 388539,
        duration = 15.0,
        tick_time = 3.0,
        pandemic = true,
        max_stack = 1,

        -- Affected by:
        -- sweeping_strikes[260708] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 1.0, 'target': TARGET_UNIT_CASTER, 'modifies': CHAINED_TARGETS, }
        -- bloodborne[383287] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 7.5, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- bloodletting[383154] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 6000.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
        -- bloodletting[383154] #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': CRIT_CHANCE, }
        -- thunderous_roar[397364] #2: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'points': 30.0, 'radius': 12.0, 'target': TARGET_DEST_CASTER, 'target2': TARGET_UNIT_DEST_AREA_ENEMY, }
        -- colossal_might[440989] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- whirlwind[85739] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'attributes': ['Suppress Points Stacking'], 'points': 4.0, 'target': TARGET_UNIT_CASTER, 'modifies': CHAINED_TARGETS, }
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
    -- Damage done by your next Mortal Strike increased by $m1%, and causes the target to take $198819m1% reduced healing for $198819d.
    sharpen_blade = {
        id = 198817,
        duration = 3600,
        max_stack = 1,
    },
    -- Block chance increased by $s1%.
    shield_block = {
        id = 132404,
        duration = 6.0,
        max_stack = 1,
    },
    -- Stunned.
    shockwave = {
        id = 132168,
        duration = 2.0,
        max_stack = 1,

        -- Affected by:
        -- avatar[401150] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- rumbling_earth[275339] #2: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 6.0, 'target': TARGET_UNIT_CASTER, 'modifies': RADIUS, }
        -- boneshaker[429639] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 1000.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
        -- earthquaker[440992] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -5000.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
        -- protection_warrior[137048] #14: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 50.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
    },
    -- Bleeding out from Rend and Deep Wounds $s1% faster.
    skullsplitter = {
        id = 427040,
        duration = 10.0,
        max_stack = 1,
    },
    -- Magical damage taken reduced by $s1%.
    spell_reflection = {
        id = 385391,
        duration = 5.0,
        max_stack = 1,

        -- Affected by:
        -- neltharions_fury[203524] #3: { 'type': APPLY_AURA, 'subtype': ALLOW_ONLY_ABILITY, 'target': TARGET_UNIT_CASTER, }
        -- honed_reflexes[391271] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -5.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
        -- bladestorm[227847] #2: { 'type': APPLY_AURA, 'subtype': ALLOW_ONLY_ABILITY, 'target': TARGET_UNIT_CASTER, }
        -- demolish[436358] #2: { 'type': APPLY_AURA, 'subtype': ALLOW_ONLY_ABILITY, 'target': TARGET_UNIT_CASTER, }
        -- rebound[213915] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'amplitude': 1.0, 'points': 50.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_TAKEN_BY_PCT, }
        -- protection_warrior[137048] #18: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -5.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_1_VALUE, }
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
    -- Rage cost of Cleave and Whirlwind reduced by $s1%
    storm_of_swords = {
        id = 439601,
        duration = 8.0,
        max_stack = 1,
    },
    -- Your single-target damaging abilities hit $s1 additional $Ltarget:targets; within 8 yds for $s2% damage.
    sweeping_strikes = {
        id = 260708,
        duration = 15.0,
        max_stack = 1,

        -- Affected by:
        -- improved_sweeping_strikes[383155] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 6000.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
    },
    -- Taunted.
    taunt = {
        id = 355,
        duration = 3.0,
        max_stack = 1,

        -- Affected by:
        -- neltharions_fury[203524] #3: { 'type': APPLY_AURA, 'subtype': ALLOW_ONLY_ABILITY, 'target': TARGET_UNIT_CASTER, }
        -- bladestorm[227847] #2: { 'type': APPLY_AURA, 'subtype': ALLOW_ONLY_ABILITY, 'target': TARGET_UNIT_CASTER, }
        -- demolish[436358] #2: { 'type': APPLY_AURA, 'subtype': ALLOW_ONLY_ABILITY, 'target': TARGET_UNIT_CASTER, }
    },
    -- Strength increased by $w1%.
    test_of_might = {
        id = 385013,
        duration = 12.0,
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
        -- bloodborne[383287] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 7.5, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- bloodletting[383154] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 6000.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
        -- bloodletting[383154] #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': CRIT_CHANCE, }
        -- battlefield_commander[424742] #4: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER_BY_LABEL, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_2_VALUE, }
        -- thunderous_roar[397364] #2: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'points': 30.0, 'radius': 12.0, 'target': TARGET_DEST_CASTER, 'target2': TARGET_UNIT_DEST_AREA_ENEMY, }
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
    -- Incoming crowd control duration reduced by $w3%.; Movement speed increased by $w1%.
    war_banner = {
        id = 236321,
        duration = 15.0,
        max_stack = 1,
    },
    -- Movement speed increased by $s2%.
    war_machine = {
        id = 262232,
        duration = 8.0,
        max_stack = 1,
    },
    -- Rooted.
    warbringer = {
        id = 356356,
        duration = 2.0,
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
        -- spiteful_serenity[400314] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -40.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_1_VALUE, }
        -- spiteful_serenity[400314] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -40.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_3_VALUE, }
        -- spiteful_serenity[400314] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -40.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_4_VALUE, }
        -- spiteful_serenity[400314] #3: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 20000.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
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
        -- spiteful_serenity[400314] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -40.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_1_VALUE, }
        -- spiteful_serenity[400314] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -40.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_3_VALUE, }
        -- spiteful_serenity[400314] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -40.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_4_VALUE, }
        -- spiteful_serenity[400314] #3: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 20000.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
        from = "class_talent",
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

        -- Affected by:
        -- bladestorm[227847] #2: { 'type': APPLY_AURA, 'subtype': ALLOW_ONLY_ABILITY, 'target': TARGET_UNIT_CASTER, }
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

        -- Affected by:
        -- bladestorm[227847] #2: { 'type': APPLY_AURA, 'subtype': ALLOW_ONLY_ABILITY, 'target': TARGET_UNIT_CASTER, }
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

        -- Affected by:
        -- bladestorm[227847] #2: { 'type': APPLY_AURA, 'subtype': ALLOW_ONLY_ABILITY, 'target': TARGET_UNIT_CASTER, }
    },

    -- Become an unstoppable storm of destructive force, striking all nearby enemies for $<dmg> Physical damage over $d. Deals reduced damage beyond $s1 targets.; You are immune to movement impairing and loss of control effects, but can use defensive abilities and can avoid attacks.; $?c2[; Generates ${$50622s3/10} Rage each time you deal damage.][]
    bladestorm = {
        id = 227847,
        cast = 0.0,
        cooldown = 90.0,
        gcd = "global",

        talent = "bladestorm",
        startsCombat = false,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': PERIODIC_TRIGGER_SPELL, 'tick_time': 1.0, 'trigger_spell': 50622, 'triggers': bladestorm, 'points': 8.0, 'target': TARGET_UNIT_CASTER, }
        -- #1: { 'type': APPLY_AURA, 'subtype': MECHANIC_IMMUNITY_MASK, 'value': 1733, 'schools': ['physical', 'fire', 'arcane'], 'target': TARGET_UNIT_CASTER, }
        -- #2: { 'type': APPLY_AURA, 'subtype': ALLOW_ONLY_ABILITY, 'target': TARGET_UNIT_CASTER, }

        -- Affected by:
        -- arms_warrior[137049] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
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
        -- shadow_of_the_colossus[198807] #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 150.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_2_VALUE, }
    },

    -- Strikes all enemies in front of you for $s1 Physical damage, inflicting Deep Wounds. Cleave will consume your Overpower effect to deal increased damage. Deals reduced damage beyond $s2 targets.
    cleave = {
        id = 845,
        cast = 0.0,
        cooldown = 4.5,
        gcd = "global",

        spend = 200,
        spendType = 'rage',

        talent = "cleave",
        startsCombat = true,

        -- Effects:
        -- #0: { 'type': SCHOOL_DAMAGE, 'subtype': NONE, 'attributes': ['Add Target (Dest) Combat Reach to AOE', 'Area Effects Use Target Radius'], 'ap_bonus': 1.00309, 'variance': 0.05, 'radius': 8.0, 'target': TARGET_UNIT_CONE_CASTER_TO_DEST_ENEMY, }
        -- #1: { 'type': DUMMY, 'subtype': NONE, }

        -- Affected by:
        -- arms_warrior[137049] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 30.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- arms_warrior[137049] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 30.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- warrior[137047] #0: { 'type': APPLY_AURA, 'subtype': MOD_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'value': 11, 'schools': ['physical', 'holy', 'nature'], 'target': TARGET_UNIT_CASTER, }
        -- warrior[137047] #1: { 'type': APPLY_AURA, 'subtype': MOD_GLOBAL_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'value': 11, 'schools': ['physical', 'holy', 'nature'], 'target': TARGET_UNIT_CASTER, }
        -- avatar[107574] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.75, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- avatar[107574] #3: { 'type': APPLY_AURA_ON_PET, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.75, 'points': 20.0, 'value': 22, 'schools': ['holy', 'fire', 'frost'], 'target': TARGET_UNIT_CASTER, }
        -- avatar[107574] #7: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -1500.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
        -- avatar[401150] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.75, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- avatar[401150] #8: { 'type': APPLY_AURA_ON_PET, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.75, 'points': 20.0, 'value': 22, 'schools': ['holy', 'fire', 'frost'], 'target': TARGET_UNIT_CASTER, }
        -- barbaric_training[383082] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- barbaric_training[383082] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_15, }
        -- dual_wield_specialization[382900] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- dual_wield_specialization[382900] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- onehanded_weapon_specialization[382895] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- onehanded_weapon_specialization[382895] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- twohanded_weapon_specialization[382896] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- twohanded_weapon_specialization[382896] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- impale[383430] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_15, }
        -- martial_expert[429638] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_15, }
        -- mountain_of_muscle_and_scars[429642] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- mountain_of_muscle_and_scars[429642] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- overpower[7384] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.33, 'points': 30.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- practiced_strikes[429647] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- sharpened_blades[383341] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.5, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_15, }
        -- deep_wounds[262115] #1: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- deep_wounds[262115] #4: { 'type': APPLY_AURA, 'subtype': MOD_CRITICAL_DAMAGE_TAKEN_FROM_CASTER, 'pvp_multiplier': 0.5, 'points': 5.0, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- champions_spear[376080] #4: { 'type': APPLY_AURA, 'subtype': MOD_CRITICAL_DAMAGE_TAKEN_FROM_CASTER, 'points': 25.0, 'radius': 5.0, 'target': TARGET_UNIT_DEST_AREA_ENEMY, }
        -- storm_of_swords[439601] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- protection_warrior[137048] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- protection_warrior[137048] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- collateral_damage[334783] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 25.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- colossus_smash[208086] #0: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'pvp_multiplier': 0.666667, 'points': 30.0, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- dance_of_death[459572] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- merciless_bonegrinder[383316] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 50.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
    },

    -- Smashes the enemy's armor, dealing $s1 Physical damage, and increasing damage you deal to them by $208086s1% for $208086d.
    colossus_smash = {
        id = 167105,
        cast = 0.0,
        cooldown = 45.0,
        gcd = "global",

        talent = "colossus_smash",
        startsCombat = true,

        -- Effects:
        -- #0: { 'type': SCHOOL_DAMAGE, 'subtype': NONE, 'chain_targets': 1, 'ap_bonus': 2.1417, 'variance': 0.05, 'target': TARGET_UNIT_TARGET_ENEMY, }

        -- Affected by:
        -- sweeping_strikes[260708] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 1.0, 'target': TARGET_UNIT_CASTER, 'modifies': CHAINED_TARGETS, }
        -- blunt_instruments[383442] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 30.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- blunt_instruments[383442] #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 3000.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
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
        -- bladestorm[227847] #2: { 'type': APPLY_AURA, 'subtype': ALLOW_ONLY_ABILITY, 'target': TARGET_UNIT_CASTER, }
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

    -- Increases your parry chance by $s1% and reduces all damage you take by $s2% for $d.
    die_by_the_sword = {
        id = 118038,
        cast = 0.0,
        cooldown = 120.0,
        gcd = "none",

        talent = "die_by_the_sword",
        startsCombat = false,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': MOD_PARRY_PERCENT, 'points': 100.0, 'target': TARGET_UNIT_CASTER, }
        -- #1: { 'type': APPLY_AURA, 'subtype': MOD_DAMAGE_PERCENT_TAKEN, 'sp_bonus': 0.25, 'points': -30.0, 'schools': ['physical', 'holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], 'target': TARGET_UNIT_CASTER, }
        -- #2: { 'type': APPLY_AURA, 'subtype': MOD_ATTACKER_SPELL_AND_WEAPON_CRIT_CHANCE, 'sp_bonus': 0.25, 'target': TARGET_UNIT_CASTER, }

        -- Affected by:
        -- honed_reflexes[391271] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -5.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
        -- bladestorm[227847] #2: { 'type': APPLY_AURA, 'subtype': ALLOW_ONLY_ABILITY, 'target': TARGET_UNIT_CASTER, }
        -- demolish[436358] #2: { 'type': APPLY_AURA, 'subtype': ALLOW_ONLY_ABILITY, 'target': TARGET_UNIT_CASTER, }
        -- valor_in_victory[383338] #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -30000.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
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

    -- You challenge the target to a duel. While challenged, all damage you and the target deal to all targets other than each other is reduced by $m1%. Lasts $d.
    duel = {
        id = 236273,
        color = 'pvp_talent',
        cast = 0.0,
        cooldown = 60.0,
        gcd = "global",

        startsCombat = true,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': AREA_TRIGGER, 'points': 50.0, 'value': 9761, 'schools': ['physical', 'shadow'], 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #1: { 'type': APPLY_AURA, 'subtype': AREA_TRIGGER, 'value': 9864, 'schools': ['nature'], 'target': TARGET_UNIT_CASTER, }
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
        -- warrior[137047] #0: { 'type': APPLY_AURA, 'subtype': MOD_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'value': 11, 'schools': ['physical', 'holy', 'nature'], 'target': TARGET_UNIT_CASTER, }
        -- cruel_strikes[392777] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_15, }
        -- improved_execute[316405] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
        -- sharpened_blades[383341] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.5, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_15, }
        -- sharpened_blades[383341] #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': CRIT_CHANCE, }
        -- juggernaut[383290] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- protection_warrior[137048] #13: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- marked_for_execution[445584] #0: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'points': 10.0, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- marked_for_execution[445584] #1: { 'type': APPLY_AURA, 'subtype': MOD_CRIT_CHANCE_FOR_CASTER_WITH_ABILITIES, 'points': 10.0, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- marked_for_execution[445584] #2: { 'type': APPLY_AURA, 'subtype': MOD_CRITICAL_DAMAGE_TAKEN_FROM_CASTER, 'points': 10.0, 'target': TARGET_UNIT_TARGET_ENEMY, }
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
        -- arms_warrior[137049] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 30.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- arms_warrior[137049] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 30.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- sweeping_strikes[260708] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 1.0, 'target': TARGET_UNIT_CASTER, 'modifies': CHAINED_TARGETS, }
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
        -- impale[383430] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_15, }
        -- martial_expert[429638] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_15, }
        -- mountain_of_muscle_and_scars[429642] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- mountain_of_muscle_and_scars[429642] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- deep_wounds[262115] #1: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- deep_wounds[262115] #4: { 'type': APPLY_AURA, 'subtype': MOD_CRITICAL_DAMAGE_TAKEN_FROM_CASTER, 'pvp_multiplier': 0.5, 'points': 5.0, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- champions_spear[376080] #4: { 'type': APPLY_AURA, 'subtype': MOD_CRITICAL_DAMAGE_TAKEN_FROM_CASTER, 'points': 25.0, 'radius': 5.0, 'target': TARGET_UNIT_DEST_AREA_ENEMY, }
        -- whirlwind[85739] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'attributes': ['Suppress Points Stacking'], 'points': 4.0, 'target': TARGET_UNIT_CASTER, 'modifies': CHAINED_TARGETS, }
        -- protection_warrior[137048] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- protection_warrior[137048] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- colossus_smash[208086] #0: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'pvp_multiplier': 0.666667, 'points': 30.0, 'target': TARGET_UNIT_TARGET_ENEMY, }
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
        -- arms_warrior[137049] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 30.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- arms_warrior[137049] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 30.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
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
        -- impale[383430] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_15, }
        -- martial_expert[429638] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_15, }
        -- mountain_of_muscle_and_scars[429642] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- mountain_of_muscle_and_scars[429642] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- deep_wounds[262115] #1: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- deep_wounds[262115] #4: { 'type': APPLY_AURA, 'subtype': MOD_CRITICAL_DAMAGE_TAKEN_FROM_CASTER, 'pvp_multiplier': 0.5, 'points': 5.0, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- champions_spear[376080] #4: { 'type': APPLY_AURA, 'subtype': MOD_CRITICAL_DAMAGE_TAKEN_FROM_CASTER, 'points': 25.0, 'radius': 5.0, 'target': TARGET_UNIT_DEST_AREA_ENEMY, }
        -- protection_warrior[137048] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- protection_warrior[137048] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- protection_warrior[137048] #2: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -5000.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
        -- colossus_smash[208086] #0: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'pvp_multiplier': 0.666667, 'points': 30.0, 'target': TARGET_UNIT_TARGET_ENEMY, }
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
        -- arms_warrior[137049] #8: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 10000.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
        -- neltharions_fury[203524] #3: { 'type': APPLY_AURA, 'subtype': ALLOW_ONLY_ABILITY, 'target': TARGET_UNIT_CASTER, }
        -- bladestorm[227847] #2: { 'type': APPLY_AURA, 'subtype': ALLOW_ONLY_ABILITY, 'target': TARGET_UNIT_CASTER, }
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
        -- sweeping_strikes[260708] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 1.0, 'target': TARGET_UNIT_CASTER, 'modifies': CHAINED_TARGETS, }
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
        -- shadow_of_the_colossus[198807] #2: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 150.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_2_VALUE, }
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

    -- A vicious strike that deals $s1 Physical damage and reduces the effectiveness of healing on the target by $115804s1% for $115804d.
    mortal_strike = {
        id = 12294,
        cast = 0.0,
        cooldown = 6.0,
        gcd = "global",

        spend = 300,
        spendType = 'rage',

        talent = "mortal_strike",
        startsCombat = true,

        -- Effects:
        -- #0: { 'type': SCHOOL_DAMAGE, 'subtype': NONE, 'chain_targets': 1, 'ap_bonus': 2.50774, 'pvp_multiplier': 1.35, 'variance': 0.05, 'target': TARGET_UNIT_TARGET_ENEMY, }

        -- Affected by:
        -- arms_warrior[137049] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 30.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- arms_warrior[137049] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 30.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- sweeping_strikes[260708] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 1.0, 'target': TARGET_UNIT_CASTER, 'modifies': CHAINED_TARGETS, }
        -- warrior[137047] #0: { 'type': APPLY_AURA, 'subtype': MOD_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'value': 11, 'schools': ['physical', 'holy', 'nature'], 'target': TARGET_UNIT_CASTER, }
        -- warrior[137047] #1: { 'type': APPLY_AURA, 'subtype': MOD_GLOBAL_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'value': 11, 'schools': ['physical', 'holy', 'nature'], 'target': TARGET_UNIT_CASTER, }
        -- avatar[107574] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.75, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- avatar[107574] #3: { 'type': APPLY_AURA_ON_PET, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.75, 'points': 20.0, 'value': 22, 'schools': ['holy', 'fire', 'frost'], 'target': TARGET_UNIT_CASTER, }
        -- avatar[401150] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.75, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- avatar[401150] #8: { 'type': APPLY_AURA_ON_PET, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.75, 'points': 20.0, 'value': 22, 'schools': ['holy', 'fire', 'frost'], 'target': TARGET_UNIT_CASTER, }
        -- crushing_force[382764] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- crushing_force[382764] #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_15, }
        -- dual_wield_specialization[382900] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- dual_wield_specialization[382900] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- onehanded_weapon_specialization[382895] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- onehanded_weapon_specialization[382895] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- twohanded_weapon_specialization[382896] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- twohanded_weapon_specialization[382896] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- impale[383430] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_15, }
        -- martial_expert[429638] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_15, }
        -- mountain_of_muscle_and_scars[429642] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- mountain_of_muscle_and_scars[429642] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- overpower[7384] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.33, 'points': 30.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- practiced_strikes[429647] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- sharpened_blades[383341] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.5, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_15, }
        -- sharpen_blade[198817] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- deep_wounds[262115] #1: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- deep_wounds[262115] #4: { 'type': APPLY_AURA, 'subtype': MOD_CRITICAL_DAMAGE_TAKEN_FROM_CASTER, 'pvp_multiplier': 0.5, 'points': 5.0, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- champions_spear[376080] #4: { 'type': APPLY_AURA, 'subtype': MOD_CRITICAL_DAMAGE_TAKEN_FROM_CASTER, 'points': 25.0, 'radius': 5.0, 'target': TARGET_UNIT_DEST_AREA_ENEMY, }
        -- executioners_precision[386633] #0: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- fierce_followthrough[458689] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- protection_warrior[137048] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- protection_warrior[137048] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- brutal_finish[446918] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 50.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- colossus_smash[208086] #0: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'pvp_multiplier': 0.666667, 'points': 30.0, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- dance_of_death[459572] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
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

    -- Overpower the enemy, dealing $s1 Physical damage. Cannot be blocked, dodged, or parried.$?s316440&s845[; Increases the damage of your next Mortal Strike or Cleave by $s2%, stacking up to $u times]?s316440[; Increases the damage of your next Mortal Strike by $s2%, stacking up to $u times.][]$?s400801[; Generates ${$7384s3/10} Rage.][]; 
    overpower = {
        id = 7384,
        cast = 0.0,
        cooldown = 0.0,
        gcd = "global",

        talent = "overpower",
        startsCombat = true,

        -- Effects:
        -- #0: { 'type': SCHOOL_DAMAGE, 'subtype': NONE, 'chain_targets': 1, 'ap_bonus': 1.40184, 'variance': 0.05, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.33, 'points': 30.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }

        -- Affected by:
        -- arms_warrior[137049] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 30.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- arms_warrior[137049] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 30.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- sweeping_strikes[260708] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 1.0, 'target': TARGET_UNIT_CASTER, 'modifies': CHAINED_TARGETS, }
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
        -- impale[383430] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_15, }
        -- improved_overpower[385571] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- improved_overpower[385571] #1: { 'type': APPLY_AURA, 'subtype': MOD_MAX_CHARGES, 'points': 1.0, 'target': TARGET_UNIT_CASTER, }
        -- martial_expert[429638] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_15, }
        -- martial_prowess[316440] #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 1.0, 'target': TARGET_UNIT_CASTER, 'modifies': MAX_STACKS, }
        -- mountain_of_muscle_and_scars[429642] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- mountain_of_muscle_and_scars[429642] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- slayers_malice[444779] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- strength_of_arms[400803] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': CRIT_CHANCE, }
        -- strength_of_arms[400803] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_15, }
        -- strength_of_arms[400803] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- deep_wounds[262115] #1: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- deep_wounds[262115] #4: { 'type': APPLY_AURA, 'subtype': MOD_CRITICAL_DAMAGE_TAKEN_FROM_CASTER, 'pvp_multiplier': 0.5, 'points': 5.0, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- champions_spear[376080] #4: { 'type': APPLY_AURA, 'subtype': MOD_CRITICAL_DAMAGE_TAKEN_FROM_CASTER, 'points': 25.0, 'radius': 5.0, 'target': TARGET_UNIT_DEST_AREA_ENEMY, }
        -- colossal_might[440989] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- protection_warrior[137048] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- protection_warrior[137048] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- colossus_smash[208086] #0: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'pvp_multiplier': 0.666667, 'points': 30.0, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- dance_of_death[459572] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- opportunist[456120] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- opportunist[456120] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_15, }
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
        -- bladestorm[227847] #2: { 'type': APPLY_AURA, 'subtype': ALLOW_ONLY_ABILITY, 'target': TARGET_UNIT_CASTER, }
        -- battlefield_commander[424742] #3: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 30.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_3_VALUE, }
        -- master_and_commander[235941] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -90000.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
        -- master_and_commander[235941] #2: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_1_VALUE, }
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
    },

    -- Wounds the target, causing $s1 Physical damage instantly and an additional $388539o1 Bleed damage over $388539d.$?s6343[; Thunder Clap affects $6343s5 nearby targets with Rend.; ][]
    rend = {
        id = 772,
        cast = 0.0,
        cooldown = 0.0,
        gcd = "global",

        spend = 200,
        spendType = 'rage',

        talent = "rend",
        startsCombat = true,

        -- Effects:
        -- #0: { 'type': SCHOOL_DAMAGE, 'subtype': NONE, 'chain_targets': 1, 'ap_bonus': 0.871194, 'variance': 0.05, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #1: { 'type': TRIGGER_SPELL, 'subtype': NONE, 'trigger_spell': 388539, 'target': TARGET_UNIT_TARGET_ENEMY, }

        -- Affected by:
        -- arms_warrior[137049] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 30.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- arms_warrior[137049] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 30.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- sweeping_strikes[260708] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 1.0, 'target': TARGET_UNIT_CASTER, 'modifies': CHAINED_TARGETS, }
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
        -- impale[383430] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_15, }
        -- martial_expert[429638] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_15, }
        -- mountain_of_muscle_and_scars[429642] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- mountain_of_muscle_and_scars[429642] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- deep_wounds[262115] #1: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- deep_wounds[262115] #4: { 'type': APPLY_AURA, 'subtype': MOD_CRITICAL_DAMAGE_TAKEN_FROM_CASTER, 'pvp_multiplier': 0.5, 'points': 5.0, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- champions_spear[376080] #4: { 'type': APPLY_AURA, 'subtype': MOD_CRITICAL_DAMAGE_TAKEN_FROM_CASTER, 'points': 25.0, 'radius': 5.0, 'target': TARGET_UNIT_DEST_AREA_ENEMY, }
        -- colossal_might[440989] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- whirlwind[85739] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'attributes': ['Suppress Points Stacking'], 'points': 4.0, 'target': TARGET_UNIT_CASTER, 'modifies': CHAINED_TARGETS, }
        -- protection_warrior[137048] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- protection_warrior[137048] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- colossus_smash[208086] #0: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'pvp_multiplier': 0.666667, 'points': 30.0, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- dance_of_death[459572] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
    },

    -- When activated, your next Mortal Strike will deal $m1% increased damage and reduce healing taken by $198819m1% for $198819d.
    sharpen_blade = {
        id = 198817,
        color = 'pvp_talent',
        cast = 0.0,
        cooldown = 30.0,
        gcd = "none",

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
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
        -- arms_warrior[137049] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 30.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- arms_warrior[137049] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 30.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
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
        -- impale[383430] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_15, }
        -- martial_expert[429638] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_15, }
        -- mountain_of_muscle_and_scars[429642] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- mountain_of_muscle_and_scars[429642] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- demolition[329033] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -50.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
        -- deep_wounds[262115] #1: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- deep_wounds[262115] #4: { 'type': APPLY_AURA, 'subtype': MOD_CRITICAL_DAMAGE_TAKEN_FROM_CASTER, 'pvp_multiplier': 0.5, 'points': 5.0, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- champions_spear[376080] #4: { 'type': APPLY_AURA, 'subtype': MOD_CRITICAL_DAMAGE_TAKEN_FROM_CASTER, 'points': 25.0, 'radius': 5.0, 'target': TARGET_UNIT_DEST_AREA_ENEMY, }
        -- protection_warrior[137048] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- protection_warrior[137048] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- colossus_smash[208086] #0: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'pvp_multiplier': 0.666667, 'points': 30.0, 'target': TARGET_UNIT_TARGET_ENEMY, }
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
        -- neltharions_fury[203524] #3: { 'type': APPLY_AURA, 'subtype': ALLOW_ONLY_ABILITY, 'target': TARGET_UNIT_CASTER, }
        -- bladestorm[227847] #2: { 'type': APPLY_AURA, 'subtype': ALLOW_ONLY_ABILITY, 'target': TARGET_UNIT_CASTER, }
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
        -- arms_warrior[137049] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 30.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- arms_warrior[137049] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 30.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- sweeping_strikes[260708] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 1.0, 'target': TARGET_UNIT_CASTER, 'modifies': CHAINED_TARGETS, }
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
        -- impale[383430] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_15, }
        -- martial_expert[429638] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_15, }
        -- mountain_of_muscle_and_scars[429642] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- mountain_of_muscle_and_scars[429642] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- practiced_strikes[429647] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- deep_wounds[262115] #1: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- deep_wounds[262115] #4: { 'type': APPLY_AURA, 'subtype': MOD_CRITICAL_DAMAGE_TAKEN_FROM_CASTER, 'pvp_multiplier': 0.5, 'points': 5.0, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- champions_spear[376080] #4: { 'type': APPLY_AURA, 'subtype': MOD_CRITICAL_DAMAGE_TAKEN_FROM_CASTER, 'points': 25.0, 'radius': 5.0, 'target': TARGET_UNIT_DEST_AREA_ENEMY, }
        -- shield_block[132404] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 30.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- shield_block[132404] #3: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': CRIT_CHANCE, }
        -- whirlwind[85739] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'attributes': ['Suppress Points Stacking'], 'points': 4.0, 'target': TARGET_UNIT_CASTER, 'modifies': CHAINED_TARGETS, }
        -- protection_warrior[137048] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- protection_warrior[137048] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- colossus_smash[208086] #0: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'pvp_multiplier': 0.666667, 'points': 30.0, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- dance_of_death[459572] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
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
        -- arms_warrior[137049] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 30.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- arms_warrior[137049] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 30.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
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
        -- earthquaker[440992] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -5000.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
        -- impale[383430] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_15, }
        -- martial_expert[429638] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_15, }
        -- mountain_of_muscle_and_scars[429642] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- mountain_of_muscle_and_scars[429642] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- deep_wounds[262115] #1: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- deep_wounds[262115] #4: { 'type': APPLY_AURA, 'subtype': MOD_CRITICAL_DAMAGE_TAKEN_FROM_CASTER, 'pvp_multiplier': 0.5, 'points': 5.0, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- champions_spear[376080] #4: { 'type': APPLY_AURA, 'subtype': MOD_CRITICAL_DAMAGE_TAKEN_FROM_CASTER, 'points': 25.0, 'radius': 5.0, 'target': TARGET_UNIT_DEST_AREA_ENEMY, }
        -- protection_warrior[137048] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- protection_warrior[137048] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- protection_warrior[137048] #14: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 50.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- colossus_smash[208086] #0: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'pvp_multiplier': 0.666667, 'points': 30.0, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- dance_of_death[459572] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
    },

    -- Bash an enemy's skull, dealing $s1 Physical damage.; Skullsplitter causes your Rend and Deep Wounds on the target to bleed out $427040s1% faster for $427040d.; Generates ${$s2/10} Rage.
    skullsplitter = {
        id = 260643,
        cast = 0.0,
        cooldown = 21.0,
        gcd = "global",

        talent = "skullsplitter",
        startsCombat = true,

        -- Effects:
        -- #0: { 'type': SCHOOL_DAMAGE, 'subtype': NONE, 'chain_targets': 1, 'ap_bonus': 1.416, 'variance': 0.05, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #1: { 'type': ENERGIZE, 'subtype': NONE, 'points': 150.0, 'target': TARGET_UNIT_CASTER, 'resource': rage, }

        -- Affected by:
        -- sweeping_strikes[260708] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 1.0, 'target': TARGET_UNIT_CASTER, 'modifies': CHAINED_TARGETS, }
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
        -- arms_warrior[137049] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 30.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- arms_warrior[137049] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 30.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- arms_warrior[137049] #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 50.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- sweeping_strikes[260708] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 1.0, 'target': TARGET_UNIT_CASTER, 'modifies': CHAINED_TARGETS, }
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
        -- impale[383430] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_15, }
        -- martial_expert[429638] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_15, }
        -- mountain_of_muscle_and_scars[429642] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- mountain_of_muscle_and_scars[429642] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- deep_wounds[262115] #1: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- deep_wounds[262115] #4: { 'type': APPLY_AURA, 'subtype': MOD_CRITICAL_DAMAGE_TAKEN_FROM_CASTER, 'pvp_multiplier': 0.5, 'points': 5.0, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- champions_spear[376080] #4: { 'type': APPLY_AURA, 'subtype': MOD_CRITICAL_DAMAGE_TAKEN_FROM_CASTER, 'points': 25.0, 'radius': 5.0, 'target': TARGET_UNIT_DEST_AREA_ENEMY, }
        -- storm_of_swords[388903] #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 9000.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
        -- storm_of_swords[388903] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 100.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- storm_of_swords[388903] #4: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -200.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- storm_of_swords[388903] #5: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 100.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_2_VALUE, }
        -- whirlwind[85739] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'attributes': ['Suppress Points Stacking'], 'points': 4.0, 'target': TARGET_UNIT_CASTER, 'modifies': CHAINED_TARGETS, }
        -- protection_warrior[137048] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- protection_warrior[137048] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- colossus_smash[208086] #0: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'pvp_multiplier': 0.666667, 'points': 30.0, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- dance_of_death[459572] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
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
        -- neltharions_fury[203524] #3: { 'type': APPLY_AURA, 'subtype': ALLOW_ONLY_ABILITY, 'target': TARGET_UNIT_CASTER, }
        -- honed_reflexes[391271] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -5.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
        -- bladestorm[227847] #2: { 'type': APPLY_AURA, 'subtype': ALLOW_ONLY_ABILITY, 'target': TARGET_UNIT_CASTER, }
        -- demolish[436358] #2: { 'type': APPLY_AURA, 'subtype': ALLOW_ONLY_ABILITY, 'target': TARGET_UNIT_CASTER, }
        -- rebound[213915] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'amplitude': 1.0, 'points': 50.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_TAKEN_BY_PCT, }
        -- rebound[213915] #2: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER_BY_LABEL, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': MAX_STACKS, }
        -- protection_warrior[137048] #18: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -5.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_1_VALUE, }
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
    },

    -- For $d your single-target damaging abilities hit $s1 additional $Ltarget:targets; within 8 yds for $s2% damage.
    sweeping_strikes = {
        id = 260708,
        cast = 0.0,
        cooldown = 30.0,
        gcd = "global",

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 1.0, 'target': TARGET_UNIT_CASTER, 'modifies': CHAINED_TARGETS, }
        -- #1: { 'type': APPLY_AURA, 'subtype': DUMMY, 'points': 75.0, 'target': TARGET_UNIT_CASTER, }
        -- #2: { 'type': APPLY_AURA, 'subtype': DUMMY, 'target': TARGET_UNIT_CASTER, }

        -- Affected by:
        -- improved_sweeping_strikes[383155] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 6000.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
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
        -- bladestorm[227847] #2: { 'type': APPLY_AURA, 'subtype': ALLOW_ONLY_ABILITY, 'target': TARGET_UNIT_CASTER, }
        -- demolish[436358] #2: { 'type': APPLY_AURA, 'subtype': ALLOW_ONLY_ABILITY, 'target': TARGET_UNIT_CASTER, }
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
        -- arms_warrior[137049] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 30.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- arms_warrior[137049] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 30.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- arms_warrior[137049] #13: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 45.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
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
        -- impale[383430] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_15, }
        -- martial_expert[429638] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_15, }
        -- mountain_of_muscle_and_scars[429642] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- mountain_of_muscle_and_scars[429642] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- deep_wounds[262115] #1: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- deep_wounds[262115] #4: { 'type': APPLY_AURA, 'subtype': MOD_CRITICAL_DAMAGE_TAKEN_FROM_CASTER, 'pvp_multiplier': 0.5, 'points': 5.0, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- champions_spear[376080] #4: { 'type': APPLY_AURA, 'subtype': MOD_CRITICAL_DAMAGE_TAKEN_FROM_CASTER, 'points': 25.0, 'radius': 5.0, 'target': TARGET_UNIT_DEST_AREA_ENEMY, }
        -- protection_warrior[137048] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- protection_warrior[137048] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- protection_warrior[137048] #19: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 50.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_4_VALUE, }
        -- protection_warrior[137048] #20: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- colossus_smash[208086] #0: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'pvp_multiplier': 0.666667, 'points': 30.0, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- dance_of_death[459572] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
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
        -- arms_warrior[137049] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 30.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- arms_warrior[137049] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 30.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- sweeping_strikes[260708] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 1.0, 'target': TARGET_UNIT_CASTER, 'modifies': CHAINED_TARGETS, }
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
        -- impale[383430] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_15, }
        -- martial_expert[429638] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_15, }
        -- mountain_of_muscle_and_scars[429642] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- mountain_of_muscle_and_scars[429642] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- deep_wounds[262115] #1: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- deep_wounds[262115] #4: { 'type': APPLY_AURA, 'subtype': MOD_CRITICAL_DAMAGE_TAKEN_FROM_CASTER, 'pvp_multiplier': 0.5, 'points': 5.0, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- champions_spear[376080] #4: { 'type': APPLY_AURA, 'subtype': MOD_CRITICAL_DAMAGE_TAKEN_FROM_CASTER, 'points': 25.0, 'radius': 5.0, 'target': TARGET_UNIT_DEST_AREA_ENEMY, }
        -- whirlwind[85739] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'attributes': ['Suppress Points Stacking'], 'points': 4.0, 'target': TARGET_UNIT_CASTER, 'modifies': CHAINED_TARGETS, }
        -- protection_warrior[137048] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- protection_warrior[137048] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- colossus_smash[208086] #0: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'pvp_multiplier': 0.666667, 'points': 30.0, 'target': TARGET_UNIT_TARGET_ENEMY, }
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
        -- victory_rush[319158] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_1_VALUE, }
        -- protection_warrior[137048] #7: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': THREAT, }
        from = "class",
    },

    -- You throw down a war banner at your feet, rallying your allies. ; Increases movement speed by $236321m1% and reduces the duration of all incoming crowd control effects by $236321m2% to all allies within $A2 yards of the war banner. Lasts $d.
    war_banner = {
        id = 236320,
        color = 'pvp_talent',
        cast = 0.0,
        cooldown = 1.0,
        gcd = "none",

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': SUMMON, 'subtype': NONE, 'points': 10.0, 'value': 119052, 'schools': ['fire', 'nature'], 'value1': 4024, 'target': TARGET_DEST_CASTER, }
        -- #1: { 'type': DUMMY, 'subtype': NONE, 'radius': 30.0, }
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

    -- Smash the ground and shatter the armor of all enemies within $A1 yds, dealing $s1 Physical damage and increasing damage you deal to them by $208086s1% for $208086d.
    warbreaker_262161 = {
        id = 262161,
        cast = 0.0,
        cooldown = 45.0,
        gcd = "global",

        talent = "warbreaker_262161",
        startsCombat = true,

        -- Effects:
        -- #0: { 'type': SCHOOL_DAMAGE, 'subtype': NONE, 'ap_bonus': 2.1417, 'variance': 0.05, 'radius': 8.0, 'target': TARGET_SRC_CASTER, 'target2': TARGET_UNIT_SRC_AREA_ENEMY, }

        -- Affected by:
        -- blunt_instruments[383442] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 30.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        from = "spec_talent",
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
        -- storm_of_swords[439601] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- storm_of_swords[388903] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 7000.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
        -- storm_of_swords[388903] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 80.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- collateral_damage[334783] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 25.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- merciless_bonegrinder[383316] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 50.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
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