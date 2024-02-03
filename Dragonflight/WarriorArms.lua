-- WarriorArms.lua
-- November 2022

if UnitClassBase( "player" ) ~= "WARRIOR" then return end

local addon, ns = ...
local Hekili = _G[ addon ]
local class, state = Hekili.Class, Hekili.State

local FindPlayerAuraByID = ns.FindPlayerAuraByID

local strformat = string.format


local spec = Hekili:NewSpecialization( 71 )

local base_rage_gen, arms_rage_mult = 1.75, 4.000

spec:RegisterResource( Enum.PowerType.Rage, {
    mainhand = {
        swing = "mainhand",

        last = function ()
            local swing = state.swings.mainhand
            local t = state.query_time
            if state.mainhand_speed == 0 then
                return 0
            else
                return swing + floor( ( t - swing ) / state.mainhand_speed ) * state.mainhand_speed
            end
        end,

        interval = "mainhand_speed",

        stop = function () return state.swings.mainhand == 0 end,
        value = function ()
            return ( state.talent.war_machine.enabled and 1.1 or 1 ) * base_rage_gen * arms_rage_mult * state.mainhand_speed / state.haste
        end,
    },

    conquerors_banner = {
        aura = "conquerors_banner",

        last = function ()
            local app = state.buff.conquerors_banner.applied
            local t = state.query_time

            return app + floor( t - app )
        end,

        interval = 1,
        value = 4,
    },
} )

-- Talents
spec:RegisterTalents( {
    -- Warrior Talents
    armored_to_the_teeth            = { 90366, 384124, 2 }, -- Gain Strength equal to $s2% of your Armor.
    avatar                          = { 90365, 107574, 1 }, -- Transform into a colossus for $d, causing you to deal $s1% increased damage$?s394314[, take $394314s2% reduced damage][] and removing all roots and snares.; Generates ${$s2/10} Rage.
    barbaric_training               = { 92221, 383082, 1 }, -- Slam and Whirlwind deal $s1% increased damage but now cost ${$s2/10} more rage.
    berserker_rage                  = { 90372, 18499 , 1 }, -- Go berserk, removing and granting immunity to Fear, Sap, and Incapacitate effects for $d.
    berserker_shout                 = { 90348, 384100, 1 }, -- Go berserk, removing and granting immunity to Fear, Sap, and Incapacitate effects for $d.; Also remove fear effects from group members within $384102A1 yds.
    berserkers_torment              = { 90362, 390123, 1 }, -- Activating Avatar or Recklessness casts the other at reduced effectiveness.
    bitter_immunity                 = { 90356, 383762, 1 }, -- Restores $s1% health instantly and removes all diseases, poisons and curses affecting you.;
    blademasters_torment            = { 90363, 390138, 1 }, -- Activating Avatar or Bladestorm casts the other at reduced effectiveness.
    blood_and_thunder               = { 90342, 384277, 1 }, -- Thunder Clap $?!a137048[costs ${$s2/10} more Rage and ][]deals $s1% increased damage.$?!a137050[ If you have Rend, Thunder Clap affects $s3 nearby targets with Rend.][]
    bounding_stride                 = { 90355, 202163, 1 }, -- Reduces the cooldown of Heroic Leap by ${$m1/-1000} sec, and Heroic Leap now also increases your movement speed by $202164s1% for $202164d.
    cacophonous_roar                = { 90383, 382954, 1 }, -- Intimidating Shout can withstand $s1% more damage before breaking.
    champions_might                 = { 90323, 386285, 1 }, -- [386284] The duration of Champion's Spear is increased by ${$s1/1000} sec. While you remain within the area of your Champion's Spear your critical strike damage is increased by $386286s1%.
    champions_spear                 = { 90380, 376079, 1 }, -- Throw a spear at the target location, dealing $376080s1 Physical damage instantly and an additional $376080o4 damage over $376081d. Deals reduced damage beyond $<cap> targets.; Enemies hit are chained to the spear's location for the duration.; Generates $/10;376080s3 Rage.
    concussive_blows                = { 90333, 383115, 1 }, -- Cooldown of Pummel reduced by ${$s1/-1000}.1 sec. ; Successfully interrupting an enemy increases the damage you deal to them by $383116s2% for $383116d.
    crackling_thunder               = { 90342, 203201, 1 }, -- Thunder Clap's radius is increased by $s1%, and it reduces movement speed by an additional $s2%.
    cruel_strikes                   = { 90381, 392777, 2 }, -- Critical strike chance increased by $s1% and critical strike damage of Execute increased by $s2%.
    crushing_force                  = { 90347, 382764, 2 }, -- Slam deals an additional $s1% damage and has a ${$s3/10}.2% increased critical strike chance.
    defensive_stance                = { 92537, 386208, 1 }, -- A defensive combat state that reduces all damage you take by $s1%, and all damage you deal by $s2%. ; Lasts until canceled.
    double_time                     = { 90382, 103827, 1 }, -- Increases the maximum number of charges on Charge by 1, and reduces its cooldown by ${$s2/-1000} sec.
    dual_wield_specialization       = { 90373, 382900, 1 }, -- Increases your damage while dual wielding by $s1%.
    endurance_training              = { 90338, 382940, 1 }, -- Stamina increased by $s1% and the duration of Fear, Sap and Incapacitate effects on you is reduced by ${$s6/10}.1%.
    fast_footwork                   = { 90371, 382260, 1 }, -- Movement speed increased by $s1%.
    frothing_berserker              = { 90352, 392792, 1 }, -- Mortal Strike and Cleave have a $h% chance to immediately refund $s1% of the Rage spent.
    furious_blows                   = { 90336, 390354, 1 }, -- Auto-attack speed increased by $s1%.
    heroic_leap                     = { 90346, 6544  , 1 }, -- Leap through the air toward a target location, slamming down with destructive force to deal $52174s1 Physical damage to all enemies within $52174a1 yards$?c3[, and resetting the remaining cooldown on Taunt][].
    honed_reflexes                  = { 90354, 382461, 1 }, -- Cooldown of Overpower and Pummel reduced by ${$s2/-1000}.1 sec.
    immovable_object                = { 90364, 394307, 1 }, -- Activating Avatar or Shield Wall casts the other at reduced effectiveness.
    impending_victory               = { 90326, 202168, 1 }, -- Instantly attack the target, causing $s1 damage and healing you for $202166s1% of your maximum health.; Killing an enemy that yields experience or honor resets the cooldown of Impending Victory and makes it cost no Rage.
    intervene                       = { 90329, 3411  , 1 }, -- Run at high speed toward an ally, intercepting all melee and ranged attacks against them for $147833d while they remain within $147833A1 yds.
    intimidating_shout              = { 90384, 5246  , 1 }, -- $?s275338[Causes the targeted enemy and up to $s1 additional enemies within $5246A3 yards to cower in fear.][Causes the targeted enemy to cower in fear, and up to $s1 additional enemies within $5246A3 yards to flee.] Targets are disoriented for $d.
    leeching_strikes                = { 90344, 382258, 1 }, -- Leech increased by $s1%.
    menace                          = { 90383, 275338, 1 }, -- Intimidating Shout will knock back all nearby enemies except your primary target, and cause them all to cower in fear for $316595d instead of fleeing.
    onehanded_weapon_specialization = { 90324, 382895, 1 }, -- Damage with one-handed weapons and Leech increased by $s1%.
    overwhelming_rage               = { 90378, 382767, 2 }, -- Maximum Rage increased by ${$s1/10}.
    pain_and_gain                   = { 90353, 382549, 1 }, -- When you take any damage, heal for ${$m1/10}.2% of your maximum health. ; This can only occur once every $357946d.
    piercing_challenge              = { 90379, 382948, 1 }, -- Instant damage of Champion's Spear increased by $s1% and its Rage generation is increased by $s2%.
    piercing_howl                   = { 90348, 12323 , 1 }, -- Snares all enemies within $A1 yards, reducing their movement speed by $s1% for $d.
    rallying_cry                    = { 90331, 97462 , 1 }, -- Lets loose a rallying cry, granting all party or raid members within $a1 yards $s1% temporary and maximum health for $97463d.
    reinforced_plates               = { 90368, 382939, 1 }, -- Armor increased by $s1%.
    rumbling_earth                  = { 90374, 275339, 1 }, -- Shockwave's range increased by $s3 yards and when Shockwave strikes at least $s1 targets, its cooldown is reduced by $s2 sec.
    second_wind                     = { 90332, 29838 , 1 }, -- Restores $202147s1% health every $202147t1 sec when you have not taken damage for $202149d.
    seismic_reverberation           = { 90340, 382956, 1 }, -- If Whirlwind $?a137048[or Revenge hits $s1 or more enemies, it hits them $s2 additional time for $s5% damage.][hits $s1 or more enemies, it hits them $s2 additional time for $s5% damage.]
    shattering_throw                = { 90351, 64382 , 1 }, -- Hurl your weapon at the enemy, causing $<damage> Physical damage, ignoring armor, and removing any magical immunities. Deals up to $?s329033[${($329033s3/100+1)*500}][500]% increased damage to absorb shields.
    shockwave                       = { 90375, 46968 , 1 }, -- Sends a wave of force in a frontal cone, causing $s2 damage and stunning all enemies within $a1 yards for $132168d.; Generates ${$m5/10} Rage.
    sidearm                         = { 90333, 384404, 1 }, -- Your auto-attacks have a $s2% chance to hurl weapons at your target and 3 other enemies in front of you, dealing an additional $384391s1 Physical damage.
    sonic_boom                      = { 90321, 390725, 1 }, -- Shockwave deals $s1% increased damage and will always critical strike.
    spell_reflection                = { 90385, 23920 , 1 }, -- Raise your $?c3[shield][weapon], reflecting $?a213915[the next $213915s3 spells cast][the first spell cast] on you, and reduce magic damage you take by $385391s1% for $d.
    storm_bolt                      = { 90337, 107570, 1 }, -- Hurls your weapon at an enemy, causing $s1 Physical damage and stunning for $132169d.
    thunder_clap                    = { 92224, 396719, 1 }, -- Blasts all enemies within $6343A1 yards for $s1 Physical damage$?(s199045)[, rooting them for $199042d]?s199045[ and roots them for $199042d.][.] and reduces their movement speed by $s2% for $d. Deals reduced damage beyond $s5 targets.$?s386229[; Generates ${$s4/10} Rage.][]
    thunderous_roar                 = { 90359, 384318, 1 }, -- Roar explosively, dealing $s1 Physical damage to enemies within $A1 yds and cause them to bleed for $397364o1 physical damage over $397364d.; Generates ${$m3/10} Rage.
    thunderous_words                = { 90358, 384969, 1 }, -- Increases the duration of Thunderous Roar's Bleed effect by ${$s2/1000}.1 sec and increases the damage of your bleed effects by $s1% at all times.
    titanic_throw                   = { 90341, 384090, 1 }, -- Throws your weapon at the enemy, causing $s1 Physical damage to it and $s2 nearby enemies. ; Generates high threat.
    titans_torment                  = { 90362, 390135, 1 }, -- Activating Avatar casts Odyn's Fury, activating Odyn's Fury casts Avatar at reduced effectiveness.
    twohanded_weapon_specialization = { 90322, 382896, 1 }, -- Increases your damage while using two-handed weapons by $s1%.;
    unstoppable_force               = { 90364, 275336, 1 }, -- Avatar increases the damage of Thunder Clap and Shockwave by $s1%, and reduces the cooldown of Thunder Clap by $s2%.
    uproar                          = { 90357, 391572, 1 }, -- Thunderous Roar's cooldown reduced by ${$s1/-1000} sec.
    war_machine                     = { 90328, 262231, 1 }, -- Your auto attacks generate $s2% more Rage.; Killing an enemy instantly generates ${$262232s1/10} Rage, and increases your movement speed by $262232s2% for $262232d.
    warlords_torment                = { 90363, 390140, 1 }, -- Activating Avatar or Colossus Smash casts Recklessness at reduced effectiveness.
    wild_strikes                    = { 90360, 382946, 2 }, -- Haste increased by $s1% and your auto-attack critical strikes increase your auto-attack speed by $s2% for $392778d.
    wrecking_throw                  = { 90351, 384110, 1 }, -- Hurl your weapon at the enemy, causing $<damage> Physical damage, ignoring armor. Deals up to $?s329033[${($329033s3/100+1)*500}][500]% increased damage to absorb shields.

    -- Arms Talents
    anger_management                = { 90289, 152278, 1 }, -- Every $?c1[$s1]?c2[$s3][$s2] Rage you spend$?c1[ on attacks][] reduces the remaining cooldown on $?c1&s262161[Warbreaker and Bladestorm]?c1[Colossus Smash and Bladestorm]?c2[Recklessness and Ravager][Avatar and Shield Wall] by 1 sec.
    battle_stance                   = { 90327, 386164, 1 }, -- A balanced combat state that increases the critical strike chance of your abilities by $s1% and reduces the duration of movement impairing effects by $s2%. ; Lasts until canceled.
    battlelord                      = { 92615, 386630, 1 }, -- Overpower deals $s1% increased damage and has a $h% chance to reset the cooldown of Mortal Strike and Cleave and generate ${$386631s1/10} Rage.
    bladestorm                      = { 90441, 227847, 1 }, -- Become an unstoppable storm of destructive force, striking all nearby enemies for ${(1+$d)*$50622s1} Physical damage over $d. Deals reduced damage beyond $s1 targets.; You are immune to movement impairing and loss of control effects, but can use defensive abilities and can avoid attacks.; Generates ${$s4/10} Rage.
    bloodborne                      = { 90283, 383287, 2 }, -- Deep Wounds, Rend and Thunderous Roar's Bleed effects deal ${$s2/10}.2% increased damage.
    bloodletting                    = { 90438, 383154, 1 }, -- Deep Wounds, Rend and Thunderous Roar's Bleed effects last ${$s1/1000}.1 sec longer and have a $s2% increased critical strike chance.; If you have Rend, Mortal Strike inflicts Rend on targets below $s4% health.;
    bloodsurge                      = { 90277, 384361, 1 }, -- Your Bleed effects have a chance to grant you ${$384362s1/10} Rage.
    blunt_instruments               = { 90287, 383442, 1 }, -- Colossus Smash damage increased by $s1% and its effect duration is increased by ${$s2/1000}.1 sec.
    cleave                          = { 90293, 845   , 1 }, -- Strikes all enemies in front of you for $s1 Physical damage, inflicting Deep Wounds. Cleave will consume your Overpower effect to deal increased damage. Deals reduced damage beyond $s2 targets.
    collateral_damage               = { 90267, 334779, 1 }, -- When Sweeping Strikes ends, your next Whirlwind deals $334783s1% increased damage for each ability used during Sweeping Strikes that damaged a second target.
    colossus_smash                  = { 90290, 167105, 1 }, -- Smashes the enemy's armor, dealing $s1 Physical damage, and increasing damage you deal to them by $208086s1% for $208086d.
    critical_thinking               = { 90444, 389306, 2 }, -- Critical Strike chance increased by $s1% and Execute immediately refunds $s2% of the Rage spent.
    dance_of_death                  = { 92535, 390713, 1 }, -- If your Bladestorm helps kill an enemy your next Bladestorm lasts ${$s1/1000}.1 sec longer.;
    deft_experience                 = { 90437, 389308, 2 }, -- Mastery increased by $s1% and Tactician's chance to trigger is increased by an additional ${$s2/100}.1%.
    die_by_the_sword                = { 90276, 118038, 1 }, -- Increases your parry chance by $s1% and reduces all damage you take by $s2% for $d.
    dreadnaught                     = { 90285, 262150, 1 }, -- Overpower has ${1+$s1} charges and causes a seismic wave, dealing $315961s1 damage to all enemies in a $315961A1 yd line. Deals reduced damage beyond $315961s2 targets.
    executioners_precision          = { 90445, 386634, 1 }, -- $?a317320[Condemn][Execute] causes the target to take $s1% more damage from your next Mortal Strike, stacking up to $386633u times.
    exhilarating_blows              = { 90286, 383219, 1 }, -- Mortal Strike and Cleave have a $h% chance to instantly reset their own cooldowns.
    fatality                        = { 90439, 383703, 1 }, -- Your Mortal Strikes and Cleaves against enemies above $383704s1% health have a high chance to apply Fatal Mark. When an enemy falls below $383704s1% health, Your next Execute inflicts an additional $383706s1 Physical damage per stack.
    fervor_of_battle                = { 90272, 202316, 1 }, -- If Whirlwind hits $s1 or more targets it also Slams your primary target.
    fueled_by_violence              = { 90275, 383103, 1 }, -- You are healed for $s1% of the damage dealt by Deep Wounds.
    hurricane                       = { 90440, 390563, 1 }, -- While $?s137050[Ravager is active][Bladestorming], every $?c2[$390719t1][$390577t1] sec you gain $s2% movement speed and $s1% Strength, stacking up to $s3 times. Lasts $390581d. ; Bladestorm cannot be canceled while using Hurricane.
    ignore_pain                     = { 90269, 190456, 1 }, -- Fight through the pain, ignoring $s2% of damage taken, up to ${$mhp*$s4/100} total damage prevented.
    impale                          = { 90292, 383430, 1 }, -- The damaging critical strikes of your abilities deal an additional ${$s2/10}.2% damage.
    improved_execute                = { 90273, 316405, 1 }, -- Execute no longer has a cooldown and if your foe survives, $163201s2% of the Rage spent is refunded.
    improved_overpower              = { 90279, 385571, 1 }, -- Damage of Overpower increased by $s1%.
    improved_slam                   = { 92614, 400205, 1 }, -- Slam has $s2% increased critical strike chance and deals $s1% increased critical strike damage.
    improved_sweeping_strikes       = { 92536, 383155, 1 }, -- Sweeping Strikes lasts ${$s1/1000} sec longer.
    in_for_the_kill                 = { 90288, 248621, 1 }, -- $?s262161[Warbreaker][Colossus Smash] increases your Haste by $s1%, or by $s2% if $?s262161[any][the] target is below $s3% health. Lasts $248622d.
    juggernaut                      = { 90446, 383292, 1 }, -- Execute increases Execute's damage dealt by $383290s1% for $383290d, stacking up to $383290u times.
    martial_prowess                 = { 90278, 316440, 1 }, -- Overpower increases the damage of your next Mortal Strike or Cleave by $7384s2%. Stacking up to ${$s2+1} times.
    massacre                        = { 90291, 281001, 1 }, -- $?a317320[Condemn][Execute] is now usable on targets below $s2% health.;
    merciless_bonegrinder           = { 90266, 383317, 1 }, -- When $?s152277[Ravager][Bladestorm] ends, Whirlwind and Cleave deal $383316s1% increased damage for $?s152277[$<rav>][$<bstorm>] sec.
    mortal_strike                   = { 90270, 12294 , 1 }, -- A vicious strike that deals $s1 Physical damage and reduces the effectiveness of healing on the target by $115804s1% for $115804d.
    overpower                       = { 90271, 7384  , 1 }, -- Overpower the enemy, dealing $s1 Physical damage. Cannot be blocked, dodged, or parried.$?s316440&s845[; Increases the damage of your next Mortal Strike or Cleave by $s2%. Stacking up to $u times]?s316440[; Increases the damage of your next Mortal Strike by $s2%. Stacking up to $u times.][]$?s400801[; Generates ${$7384s3/10} Rage.][];
    reaping_swings                  = { 90294, 383293, 1 }, -- Cooldown of Cleave reduced by ${$s1/-1000} sec.
    rend                            = { 90284, 772   , 1 }, -- Wounds the target, causing $s1 Physical damage instantly and an additional $388539o1 Bleed damage over $388539d.
    sharpened_blades                = { 90447, 383341, 1 }, -- Your Mortal Strike, Cleave and Execute critical strike damage is increased by $s1% and your Execute has a $s2% increased critical hit chance.
    skullsplitter                   = { 90281, 260643, 1 }, -- Bash an enemy's skull, dealing $s1 Physical damage.; Skullsplitter causes your Deep Wounds $?s386357[and Rend ][]on the target to bleed out $427040s1% faster for $427040d.; Generates ${$s2/10} Rage.
    spiteful_serenity               = { 90289, 400314, 1 }, -- Colossus Smash and Avatar's durations are increased by $s10% but their damage bonuses are reduced by $s9%.
    storm_of_swords                 = { 90267, 385512, 1 }, -- Whirlwind costs ${$s3/10} more Rage and has a ${$s1/1000}.1 sec cooldown. It now deals $s2% more damage.
    storm_wall                      = { 90269, 388807, 1 }, -- Whenever you Parry, you heal for ${$m1}.2% of your maximum health. Can only occur once per second.
    strength_of_arms                = { 92536, 400803, 1 }, -- Overpower has $s3% increased critical strike chance, deals $s4% increased critical strike damage and on enemies below 35% health Overpower generates ${$400806s1/10} Rage.;
    sudden_death                    = { 90274, 29725 , 1 }, -- Your attacks have a chance to make your next $?a317320[Condemn][Execute] cost no Rage, be usable on any target regardless of their health, and deal damage as if you spent $s1 Rage.
    tactician                       = { 90282, 184783, 1 }, -- You have a ${$s1/100}.2% chance per Rage spent on attacks to reset the remaining cooldown on Overpower.
    test_of_might                   = { 90288, 385008, 1 }, -- When $?s262161[Warbreaker][Colossus Smash] expires, your Strength is increased by $s1% for every $s3 Rage you spent on attacks during $?s262161[Warbreaker][Colossus Smash]. Lasts $385013d.
    tide_of_blood                   = { 90280, 386357, 1 }, -- Skullsplitter deals $s2% increased damage and also causes your Rend on the target to bleed out $427040s1% faster for $427040d.
    unhinged                        = { 90440, 386628, 1 }, -- While $?s152277[Ravager][Bladestorm] is active, you automatically cast a total of $?s152277[$s2 Mortal Strike][$s1 Mortal Strikes] at random nearby enemies$?a134735[, dealing $s3% of normal damage][.];
    valor_in_victory                = { 90442, 383338, 1 }, -- Increases Versatility by $s1% and reduces the cooldown of Die by the Sword by ${$s2/-1000}.1 sec.
    warbreaker                      = { 90287, 262161, 1 }, -- Smash the ground and shatter the armor of all enemies within $A1 yds, dealing $s1 Physical damage and increasing damage you deal to them by $208086s1% for $208086d.
} )


-- PvP Talents
spec:RegisterPvpTalents( {
    battlefield_commander  = 5630, -- (424742) Your Shout abilities have additional effects.; $@spellicon6673 $@spellname6673:; Increases Stamina by $s1%.; $@spellicon12323 $@spellname12323:; Roots targets hit for $424752d.; $@spellicon384100 $@spellname384100:; Range increased by $s2 yds.; $@spellicon5246 $@spellname5246:; Cooldown reduced by ${$s3/-1000} sec.; $@spellicon97462 $@spellname97462:; Removes movement impairing effects and grants $s4% movement speed to allies.; $@spellicon384318 $@spellname384318:; Targets receive $s5% more damage from all sources while bleeding.
    death_sentence         = 3522, -- (198500) Execute charges you to targets up to 15 yards away. This effect has a 6 sec cooldown.
    demolition             = 5372, -- (329033) Reduces the cooldown of your Shattering Throw or Wrecking Throw by 50% and increases its damage to absorb shields by an additional 250%.
    disarm                 = 3534, -- (236077) Disarm the enemy's weapons and shield for 5 sec. Disarmed creatures deal significantly reduced damage.
    duel                   = 34  , -- (236273) You challenge the target to a duel. While challenged, all damage you and the target deal to all targets other than each other is reduced by 50%. Lasts 8 sec.
    master_and_commander   = 28  , -- (235941) Cooldown of Rallying Cry reduced by 1 min, and grants 15% additional health.
    rebound                = 5547, -- (213915) Spell Reflection reflects the next 2 incoming spells cast on you and reflected spells deal 50% extra damage to the attacker. Spell Reflection's cooldown is increased by 10 sec.
    safeguard              = 5625, -- (424654) Intervene now has ${$s1+1} charges and reduces the ally's damage taken by $424655s1% for $424655d.; Intervene's cooldown is increased by ${$s2/1000} sec.
    shadow_of_the_colossus = 29  , -- (198807) Charge resets the cooldown of your Overpower and Rage gained from Charge increased by 15.
    sharpen_blade          = 33  , -- (198817) When activated, your next Mortal Strike will deal 15% increased damage and reduce healing taken by 50% for 4 sec.
    storm_of_destruction   = 31  , -- (236308) Reduces the cooldown of $?c2[Ravager][Bladestorm] by $m1%, and $?c2[Ravager][Bladestorm] now also snares all targets you hit by $424597s1% for $424597d.
    war_banner             = 32  , -- (236320) You throw down a war banner at your feet, rallying your allies. Increases movement speed by 30% and reduces the duration of all incoming crowd control effects by 50% to all allies within 30 yards of the war banner. Lasts 15 sec.
    warbringer             = 5376, -- (356353) Charge roots enemies for 2 sec and emanates a shockwave past the target, rooting enemies and dealing 900 Physical damage in a 20 yd cone.
} )


-- Auras
spec:RegisterAuras( {
    avatar = {
        id = 107574,
        duration = function() return ( talent.spiteful_serenity.enabled and 40 or 20 ) end, -- 100% buff from spiteful_serenity
        max_stack = 1
    },
    battle_stance = {
        id = 386164,
        duration = 3600,
        max_stack = 1
    },
    battlelord =  {
        id = 386631,
        duration = 3600,
        max_stack = 1
    },
    berserker_rage = {
        id = 18499,
        duration = 6,
        max_stack = 1
    },
    berserker_shout = {
        id = 384100,
        duration = 6,
        max_stack = 1
    },
    bladestorm = {
        id = 227847,
        duration = function () return ( buff.dance_of_death.up and 9 or 6 ) * haste end,
        max_stack = 1,
        onCancel = function()
            setCooldown( "global_cooldown", 0 )
        end,
        copy = 389774
    },
    bounding_stride = {
        id = 202164,
        duration = 3,
        max_stack = 1
    },
    champions_might = {
        id = 386286,
        duration = 8,
        max_stack = 1,
        copy = "elysian_might"
    },
    champions_spear = {
        id = 376080,
        duration = function () return ( legendary.elysian_might.enabled and 8 or 4 ) + ( talent.elysian_might.enabled and 2 or 0 ) end,
        tick_time = 1,
        max_stack = 1,
        copy = { "spear_of_bastion", 307871 } -- Covenant version.
    },
    charge = {
        id = 105771,
        duration = 1,
        max_stack = 1
    },
    collateral_damage = {
        id = 334783,
        duration = 30,
        max_stack = 20
    },
    colossus_smash = {
        id = 208086,
        duration = function () return ( 10 + ( talent.blunt_instruments.enabled and 3 or 0 ) ) * ( talent.spiteful_serenity.enabled and 2 or 1 ) end, -- 100% buff from spiteful_serenity
        max_stack = 1,
    },
    crushing_force = {
        id = 382764
    },
    dance_of_death = {
        id = 390714,
        duration = 180,
        max_stack = 1,
    },
    deep_wounds = {
        id = 262115,
        duration = function() return 12 + ( talent.bloodletting.enabled and 6 or 0 ) end,
        tick_time = function() return debuff.skullsplitter.up and 1.5 or 3 end,
        max_stack = 1
    },
    defensive_stance = {
        id = 386208,
        duration = 3600,
        max_stack = 1
    },
    die_by_the_sword = {
        id = 118038,
        duration = 8,
        max_stack = 1
    },
    disarm = {
        id = 236077,
        duration = 6,
        max_stack = 1
    },
    duel = {
        id = 236273,
        duration = 8,
        max_stack = 1
    },
    executioners_precision = {
        id = 386633,
        duration = 30,
        max_stack = 2
    },
    exploiter = { -- Shadowlands Legendary
        id = 335452,
        duration = 30,
        max_stack = 1
    },
    fatal_mark = {
        id = 383704,
        duration = 180,
        max_stack = 999
    },
    hamstring = {
        id = 1715,
        duration = 15,
        max_stack = 1
    },
    hurricane = {
        id = 390581,
        duration = 6,
        max_stack = 6,
    },
    fatality = {
        id = 383703
    },
    honed_reflexes = {
        id = 382461
    },
    improved_overpower = {
        id = 385571,
    },
    ignore_pain = {
        id = 190456,
        duration = 12,
        max_stack = 1
    },
    in_for_the_kill = {
        id = 248622,
        duration = 10,
        max_stack = 1,
    },
    indelible_victory = {
        id = 336642,
        duration = 8,
        max_stack = 1
    },
    intimidating_shout = {
        id = function () return talent.menace.enabled and 316593 or 5246 end,
        duration = function () return talent.menace.enabled and 15 or 8 end,
        max_stack = 1
    },
    merciless_bonegrinder = {
        id = 383316,
        duration = 9,
        max_stack = 1,
    },
    mortal_wounds = {
        id = 115804,
        duration = 10,
        max_stack = 1
    },
    juggernaut = {
        id = 383290,
        duration = 12,
        max_stack = 15
    },
    overpower = {
        id = 7384,
        duration = 15,
        max_stack = function() return talent.martial_prowess.enabled and 2 or 1 end,
        copy = "martial_prowess"
    },
    piercing_howl = {
        id = 12323,
        duration = 8,
        max_stack = 1
    },
    piercing_howl_root = {
        id = 424752,
        duration = 2,
        max_stack = 1
    },
    rallying_cry = {
        id = 97463,
        duration = 10,
        max_stack = 1,
    },
    recklessness = {
        id = 1719,
        duration = 12,
        max_stack = 1
    },
    rend = {
        id = 388539,
        duration = function() return 15 + ( talent.bloodletting.enabled and 6 or 0 ) end,
        tick_time = function() return talent.tide_of_blood.enabled and debuff.skullsplitter.up and 1.5 or 3 end,
        max_stack = 1,
        copy = 772
    },
    -- Damage taken reduced by $w1%.
    safeguard = {
        id = 424655,
        duration = 5.0,
        max_stack = 1,
    },
    sharpen_blade = {
        id = 198817,
        duration = 3600,
        max_stack = 1
    },
    -- Bleeding out from Deep Wounds $s1% faster.`
    skullsplitter = {
        id = 427040,
        duration = 10.0,
        max_stack = 1,
         -- Affected by:
        -- tide_of_blood[386357] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 30.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
    },
    spell_reflection = {
        id = 23920,
        duration = function () return legendary.misshapen_mirror.enabled and 8 or 5 end,
        max_stack = 1
    },
    spell_reflection_defense = {
        id = 385391,
        duration = 5,
        max_stack = 1
    },
    stance = {
        alias = { "battle_stance", "berserker_stance", "defensive_stance" },
        aliasMode = "first",
        aliasType = "buff",
        duration = 3600,
    },
    storm_bolt = {
        id = 107570,
        duration = 4,
        max_stack = 1
    },
    -- Movement slowed by $s1%.
    storm_of_destruction = {
        id = 424597,
        duration = 6.0,
        max_stack = 1,
    },
    sweeping_strikes = {
        id = 260708,
        duration = function() return 15 + ( talent.improved_sweeping_strikes.enabled and 6 or 0 ) end,
        max_stack = 1
    },
    sudden_death = {
        id = 52437,
        duration = 10,
        max_stack = 1
    },
    taunt = {
        id = 355,
        duration = 3,
        max_stack = 1
    },
    test_of_might = {
        id = 385013,
        duration = 12,
        max_stack = 1, -- TODO: Possibly implement fake stacks to track the Strength % increase gained from the buff
    },
    thunder_clap = {
        id = 6343,
        duration = 10,
        max_stack = 1
    },
    thunderous_roar = {
        id = 397364,
        duration = function () return 8 + ( talent.thunderous_words.enabled and 2 or 0 ) + ( talent.bloodletting.enabled and 6 or 0 ) end,
        tick_time = 2,
        max_stack = 1
    },
    vicious_warbanner = {
        id = 320707,
        duration = 15,
        max_stack = 1
    },
    victorious = {
        id = 32216,
        duration = 20,
        max_stack = 1
    },
    war_machine = {
        id = 262232,
        duration = 8,
        max_stack = 1
    },
    wild_strikes = {
        id = 392778,
        duration = 10,
        max_stack = 1
    },
} )

local rageSpent = 0
local gloryRage = 0

spec:RegisterStateExpr( "rage_spent", function ()
    return rageSpent
end )

spec:RegisterStateExpr( "glory_rage", function ()
    return gloryRage
end )

spec:RegisterHook( "spend", function( amt, resource )
    if resource == "rage" then
        if talent.anger_management.enabled and this_action ~= "ignore_pain" then
            rage_spent = rage_spent + amt
            local reduction = floor( rage_spent / 20 )
            rage_spent = rage_spent % 20

            if reduction > 0 then
                cooldown.colossus_smash.expires = cooldown.colossus_smash.expires - reduction
                cooldown.bladestorm.expires = cooldown.bladestorm.expires - reduction
                cooldown.warbreaker.expires = cooldown.warbreaker.expires - reduction
            end
        end

        if legendary.glory.enabled and buff.conquerors_banner.up then
            glory_rage = glory_rage + amt
            local reduction = floor( glory_rage / 20 ) * 0.5
            glory_rage = glory_rage % 20

            buff.conquerors_banner.expires = buff.conquerors_banner.expires + reduction
        end
    end
end )

local last_cs_target = nil
local collateralDmgStacks = 0

local TriggerCollateralDamage = setfenv( function()
    addStack( "collateral_damage", nil, collateralDmgStacks )
    collateralDmgStacks = 0
end, state )

spec:RegisterCombatLogEvent( function( _, subtype, _,  sourceGUID, sourceName, _, _, destGUID, destName, destFlags, _, spellID, spellName, _, _, _, _, critical_swing, _, _, critical_spell )
    if sourceGUID == state.GUID then
        if subtype == "SPELL_CAST_SUCCESS" then
            if ( spellName == class.abilities.colossus_smash.name or spellName == class.abilities.warbreaker.name ) then
                last_cs_target = destGUID
            end
        end
    end
end )


local RAGE = Enum.PowerType.Rage
local lastRage = -1

spec:RegisterUnitEvent( "UNIT_POWER_FREQUENT", "player", nil, function( event, unit, powerType )
    if powerType == "RAGE" then
        local current = UnitPower( "player", RAGE )

        if current < lastRage - 3 then -- Spent Rage, -3 is used as a Hack to avoid Rage decaying

            if state.talent.anger_management.enabled then
                rageSpent = ( rageSpent + lastRage - current ) % 20
            end

            if state.legendary.glory.enabled and FindPlayerAuraByID( 324143 ) then
                gloryRage = ( gloryRage + lastRage - current ) % 20
            end
        end
        lastRage = current
    end
end )


spec:RegisterHook( "TimeToReady", function( wait, action )
    local id = class.abilities[ action ].id
    if buff.bladestorm.up and ( id < -99 or id > 0 ) then
        wait = max( wait, buff.bladestorm.remains )
    end
    return wait
end )

local cs_actual

local ExpireBladestorm = setfenv( function()
    applyBuff( "merciless_bonegrinder" )
end, state )

local TriggerHurricane = setfenv( function()
    addStack( "hurricane" )
end, state )

local TriggerTestOfMight = setfenv( function()
    addStack( "test_of_might" )
end, state )


spec:RegisterHook( "reset_precast", function ()
    rage_spent = nil
    glory_rage = nil

    if not cs_actual then cs_actual = cooldown.colossus_smash end

    if talent.warbreaker.enabled and cs_actual then
        cooldown.colossus_smash = cooldown.warbreaker
    else
        cooldown.colossus_smash = cs_actual
    end

    if buff.bladestorm.up and talent.merciless_bonegrinder.enabled then
        state:QueueAuraExpiration( "bladestorm_merciless_bonegrinder", ExpireBladestorm, buff.bladestorm.expires )
    end

    if prev_gcd[1].colossus_smash and time - action.colossus_smash.lastCast < 1 and last_cs_target == target.unit and debuff.colossus_smash.down then
        -- Apply Colossus Smash early because its application is delayed for some reason.
        applyDebuff( "target", "colossus_smash" )
    elseif prev_gcd[1].warbreaker and time - action.warbreaker.lastCast < 1 and last_cs_target == target.unit and debuff.colossus_smash.down then
        applyDebuff( "target", "colossus_smash" )
    end

    if debuff.colossus_smash.up and talent.test_of_might.enabled then state:QueueAuraExpiration( "test_of_might", TriggerTestOfMight, debuff.colossus_smash.expires ) end

    if buff.bladestorm.up and talent.hurricane.enabled then
        local next_hu = query_time + ( 1 * state.haste ) - ( ( query_time - buff.bladestorm.applied ) % ( 1 * state.haste ) )

        while ( next_hu <= buff.bladestorm.expires ) do
            state:QueueAuraEvent( "bladestorm_hurricane", TriggerHurricane, next_hu, "AURA_PERIODIC" )
            next_hu = next_hu + ( 1 * state.haste )
        end

    end

    if talent.collateral_damage.enabled and buff.sweeping_strikes.up then
        state:QueueAuraExpiration( "sweeping_strikes_collateral_dmg", TriggerCollateralDamage, buff.sweeping_strikes.expires )
    end
end )

spec:RegisterStateExpr( "cycle_for_execute", function ()
    if active_enemies == 1 or target.health_pct < ( talent.massacre.enabled and 35 or 20 ) or not settings.cycle or buff.execute_ineligible.down or buff.sudden_death.up then return false end
    return Hekili:GetNumTargetsBelowHealthPct( talent.massacre.enabled and 35 or 20, false, max( settings.cycle_min, offset + delay ) ) > 0
end )


spec:RegisterGear( "tier29", 200426, 200428, 200423, 200425, 200427 )
spec:RegisterSetBonuses( "tier29_2pc", 393705, "tier29_4pc", 393706 )
--(2) Set Bonus: Mortal Strike and Cleave damage and chance to critically strike increased by 10%.
--(4) Set Bonus: Mortal Strike, Cleave, & Execute critical strikes increase your damage and critical strike chance by 5% for 6 seconds.
spec:RegisterAura( "strike_vulnerabilities", {
    id = 394173,
    duration = 6,
    max_stack = 1
} )

spec:RegisterGear( "tier30", 202446, 202444, 202443, 202442, 202441 )
spec:RegisterSetBonuses( "tier30_2pc", 405577, "tier30_4pc", 405578 )
--(2) Set Bonus: Deep Wounds increases your chance to critically strike and critical strike damage dealt to afflicted targets by 5%.
--(4) Deep Wounds critical strikes have a chance to increase the damage of your next Mortal Strike by 10% and cause it to deal
--    [(19.32% of Attack power) * 2] Physical damage to enemies in front of you, stacking up to 3 times. Damage reduced above 5 targets. (2s cooldown)
spec:RegisterAura( "crushing_advance", {
    id = 410138,
    duration = 30,
    max_stack = 3
} )

spec:RegisterGear( "tier31", 207180, 207181, 207182, 207183, 207185 )
spec:RegisterSetBonuses( "tier31_2pc", 422923, "tier31_4pc", 422924 )
-- (4) Sudden Death also makes your next Execute powerfully slam the ground, causing a Thunder Clap that deals 100% increased damage. In addition, the Execute target bleeds for 50% of Execute's damage over 5 sec. If this bleed is reapplied, remaining damage is added to the new bleed.
spec:RegisterAura( "finishing_wound", {
    id = 426284,
    duration = 5,
    max_stack = 1
} )

-- Abilities
spec:RegisterAbilities( {
    avatar = {
        id = 107574,
        cast = 0,
        cooldown = 90,
        gcd = "off",

        spend = -15,
        spendType = "rage",

        talent = "avatar",
        startsCombat = false,
        texture = 613534,

        toggle = "cooldowns",

        handler = function ()
            applyBuff( "avatar" )
            if talent.blademasters_torment.enabled then applyBuff ( "bladestorm", 4 ) end
            if talent.warlords_torment.enabled then
                if buff.recklessness.up then buff.recklessness.expires = buff.recklessness.expires + 4
                else applyBuff( "recklessness", 4 ) end
            end
        end,
    },


    battle_shout = {
        id = 6673,
        cast = 0,
        cooldown = 15,
        gcd = "spell",

        startsCombat = false,
        texture = 132333,

        nobuff = "battle_shout",
        essential = true,

        handler = function ()
            applyBuff( "battle_shout" )
        end,
    },


    battle_stance = {
        id = 386164,
        cast = 0,
        cooldown = 3,
        gcd = "off",

        talent = "battle_stance",
        startsCombat = false,
        texture = 132349,
        essential = true,
        nobuff = "stance",

        handler = function ()
            applyBuff( "battle_stance" )
            removeBuff( "defensive_stance" )
        end,
    },


    berserker_rage = {
        id = 18499,
        cast = 0,
        cooldown = 60,
        gcd = "off",

        talent = "berserker_rage",
        startsCombat = false,
        texture = 136009,

        toggle = "cooldowns",

        handler = function ()
            applyBuff( "berserker_rage" )
        end,
    },


    berserker_shout = {
        id = 384100,
        cast = 0,
        cooldown = 60,
        gcd = "off",

        talent = "berserker_shout",
        startsCombat = false,
        texture = 136009,

        toggle = "cooldowns",

        handler = function ()
            applyBuff( "berserker_shout" )
        end,
    },


    bitter_immunity = {
        id = 383762,
        cast = 0,
        cooldown = 180,
        gcd = "off",

        talent = "bitter_immunity",
        startsCombat = false,
        texture = 136088,

        toggle = "cooldowns",

        handler = function ()
            gain( 0.2 * health.max, "health" )
        end,
    },


    -- ID: 227847
    -- 227847 w/ MB

    bladestorm = {
        id = function() return talent.hurricane.enabled and 389774 or 227847 end,
        cast = 0,
        cooldown = 90,
        gcd = "spell",

        talent = "bladestorm",
        startsCombat = true,
        texture = 236303,
        range = 8,

        spend = -20,
        spendType = "rage",

        toggle = "cooldowns",

        handler = function ()
            applyBuff( "bladestorm" )
            setCooldown( "global_cooldown", class.auras.bladestorm.duration )
            if talent.blademasters_torment.enabled then applyBuff( "avatar", 4 ) end
            if talent.merciless_bonegrinder.enabled then
                state:QueueAuraExpiration( "bladestorm_merciless_bonegrinder", ExpireBladestorm, buff.bladestorm.expires )
            end
        end,

        copy = { 227847, 389774 }
    },


    charge = {
        id = 100,
        cast = 0,
        cooldown = function () return talent.double_time.enabled and 17 or 20 end,
        charges  = function () if talent.double_time.enabled then return 2 end end,
        recharge = function () if talent.double_time.enabled then return 17 end end,
        gcd = "off",
        icd = 1,

        spend = -20,
        spendType = "rage",

        startsCombat = true,
        texture = 132337,

        usable = function () return target.minR > 8 and ( query_time - action.charge.lastCast > gcd.execute ), "target too close" end,
        handler = function ()
            setDistance( 5 )
            applyDebuff( "target", "charge" )
        end,
    },


    cleave = {
        id = 845,
        cast = 0,
        cooldown = function () return 6 - ( talent.reaping_swings.enabled and 3 or 0 ) end,
        gcd = "spell",

        spend = function() return 20 - ( buff.battlelord.up and 10 or 0 ) end,
        spendType = "rage",

        talent = "cleave",
        startsCombat = false,
        texture = 132338,

        handler = function ()
            applyDebuff( "target" , "deep_wounds" )
            active_dot.deep_wounds = max( active_dot.deep_wounds, active_enemies )
            removeBuff( "overpower" )
        end,
    },


    colossus_smash = {
        id = 167105,
        cast = 0,
        cooldown = 45,
        gcd = "spell",

        talent = "colossus_smash",
        notalent = "warbreaker",
        startsCombat = false,
        texture = 464973,

        handler = function ()
            applyDebuff( "target", "colossus_smash" )
            applyDebuff( "target", "deep_wounds" )
            if talent.in_for_the_kill.enabled and buff.in_for_the_kill.down then
                applyBuff( "in_for_the_kill" )
                stat.haste = stat.haste + ( target.health.pct < 35 and 0.2 or 0.1 )
            end
            if talent.test_of_might.enabled then
                state:QueueAuraExpiration( "test_of_might", TriggerTestOfMight, debuff.colossus_smash.expires )
            end
            if talent.warlords_torment.enabled then
                if buff.recklessness.up then buff.recklessness.expires = buff.recklessness.expires + 4
                else applyBuff( "recklessness", 4 ) end
            end
        end,
    },


    defensive_stance = {
        id = 386208,
        cast = 0,
        cooldown = 3,
        gcd = "off",

        talent = "defensive_stance",
        startsCombat = false,
        texture = 132341,
        nobuff = "stance",

        handler = function ()
            applyBuff( "defensive_stance" )
            removeBuff( "battle_stance" )
        end,
    },


    die_by_the_sword = {
        id = 118038,
        cast = 0,
        cooldown = function () return 120 - ( talent.valor_in_victory.enabled and 30 or 0 ) - ( conduit.stalwart_guardian.enabled and 20 or 0 ) end,
        gcd = "off",

        talent = "die_by_the_sword",
        startsCombat = false,
        texture = 132336,

        toggle = "defensives",

        handler = function ()
            applyBuff ( "die_by_the_sword" )
        end,
    },


    disarm = {
        id = 236077,
        cast = 0,
        cooldown = 45,
        gcd = "spell",

        pvptalent = "disarm",
        startsCombat = false,
        texture = 132343,

        handler = function ()
            applyDebuff( "target", "disarm" )
        end,
    },


    duel = {
        id = 236273,
        cast = 0,
        cooldown = 60,
        gcd = "spell",

        pvptalent = "duel",
        startsCombat = false,
        texture = 1455893,

        toggle = "cooldowns",

        handler = function ()
            applyDebuff ( "target", "duel" )
            applyBuff ( "duel" )
        end,
    },


    execute = {
        id = function () return talent.massacre.enabled and 281000 or 163201 end,
        known = 163201,
        copy = { 163201, 281000 },
        noOverride = 317485,
        cast = 0,
        cooldown = function () return ( talent.improved_execute.enabled and 0 or 6 ) end,
        gcd = "spell",
        hasteCD = true,

        spend = 0,
        spendType = "rage",

        startsCombat = true,
        texture = 135358,

        usable = function ()
            if buff.sudden_death.up or buff.stone_heart.up then return true end
            if cycle_for_execute then return true end
           return target.health_pct < ( talent.massacre.enabled and 35 or 20 ), "requires < " .. ( talent.massacre.enabled and 35 or 20 ) .. "% health"
        end,

        cycle = "execute_ineligible",

        indicator = function () if cycle_for_execute then return "cycle" end end,

        timeToReady = function()
            -- Instead of using regular resource requirements, we'll use timeToReady to support the spend system.
            if rage.current >= 20 then return 0 end
            return rage.time_to_20
        end,
        handler = function ()
            if not buff.sudden_death.up and not buff.stone_heart.up then
                local cost = min( rage.current, 40 )
                spend( cost, "rage", nil, true )
                if talent.improved_execute.enabled then
                    gain( cost * 0.1, "rage" )
                end
                if talent.critical_thinking.enabled then
                    gain( cost * ( talent.critical_thinking.rank * 0.05 ), "rage" ) -- Regain another 5/10% for critical thinking
                end
            end
            if buff.sudden_death.up then
                removeBuff( "sudden_death" )
                if set_bonus.tier31_4pc > 0 then
                    spec.abilities.thunder_clap.handler()
                    applyDebuff( "target", "finishing_wound" )
                end
            end
            if talent.executioners_precision.enabled then applyDebuff( "target", "executioners_precision", nil, min( 2, debuff.executioners_precision.stack + 1 ) ) end
            if legendary.exploiter.enabled then applyDebuff( "target", "exploiter", nil, min( 2, debuff.exploiter.stack + 1 ) ) end
            if talent.juggernaut.enabled then addStack( "juggernaut" ) end
        end,

        auras = {
            -- Legendary
            exploiter = {
                id = 335452,
                duration = 30,
                max_stack = 2,
            },
            -- Target Swapping
            execute_ineligible = {
                duration = 3600,
                max_stack = 1,
                generate = function( t, auraType )
                    if buff.sudden_death.down and buff.stone_heart.down and target.health_pct > ( talent.massacre.enabled and 35 or 20 ) then
                        t.count = 1
                        t.expires = query_time + 3600
                        t.applied = query_time
                        t.duration = 3600
                        t.caster = "player"
                        return
                    end
                    t.count = 0
                    t.expires = 0
                    t.applied = 0
                    t.caster = "nobody"
                end
            }
        }
    },

    hamstring = {
        id = 1715,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = 10,
        spendType = "rage",

        startsCombat = true,
        texture = 132316,

        handler = function ()
            applyDebuff ( "target", "hamstring" )
        end,
    },


    heroic_leap = {
        id = 6544,
        cast = 0,
        cooldown = function () return 45 + ( talent.bounding_stride.enabled and -15 or 0 ) end,
        charges = function () return legendary.leaper.enabled and 3 or nil end,
            recharge = function () return legendary.leaper.enabled and ( talent.bounding_stride.enabled and 30 or 45 ) or nil end,
        gcd = "off",
        icd = 0.8,

        talent = "heroic_leap",
        startsCombat = false,
        texture = 236171,

        handler = function ()
            if talent.bounding_stride.enabled then applyBuff( "bounding_stride" ) end
        end,
    },


    heroic_throw = {
        id = 57755,
        cast = 0,
        cooldown = 6,
        gcd = "spell",

        startsCombat = true,
        texture = 132453,

        handler = function ()
        end,
    },

    ignore_pain = {
        id = 190456,
        cast = 0,
        cooldown = 1,
        gcd = "off",

        spend = 35,
        spendType = "rage",

        talent = "ignore_pain",
        startsCombat = false,
        texture = 1377132,

        readyTime = function ()
            if buff.ignore_pain.up and buff.ignore_pain.v1 >= 0.3 * health.max then
                return buff.ignore_pain.remains - gcd.max
            end
        end,

        handler = function ()
            if buff.ignore_pain.up then
                buff.ignore_pain.expires = query_time + class.auras.ignore_pain.duration
                buff.ignore_pain.v1 = min( 0.3 * health.max, buff.ignore_pain.v1 + stat.attack_power * 3.5 * ( 1 + stat.versatility_atk_mod / 100 ) )
            else
                applyBuff( "ignore_pain" )
                buff.ignore_pain.v1 = min( 0.3 * health.max, stat.attack_power * 3.5 * ( 1 + stat.versatility_atk_mod / 100 ) )
            end
        end,
    },

    impending_victory = {
        id = 202168,
        cast = 0,
        cooldown = 25,
        gcd = "spell",

        spend = 10,
        spendType = "rage",

        talent = "impending_victory",
        startsCombat = false,
        texture = 589768,

        handler = function ()
            gain( health.max * 0.3, "health" )
            if conduit.indelible_victory.enabled then applyBuff( "indelible_victory" ) end
        end,
    },


    intervene = {
        id = 3411,
        cast = 0,
        cooldown = 30,
        gcd = "off",
        icd = 1.5,

        talent = "intervene",
        startsCombat = false,
        texture = 132365,

        handler = function ()
        end,
    },


    intimidating_shout = {
        id = function () return talent.menace.enabled and 316593 or 5246 end,
        copy = { 316593, 5246 },
        cast = 0,
        cooldown = 90,
        gcd = "spell",

        talent = "intimidating_shout",
        startsCombat = true,
        texture = 132154,

        toggle = "cooldowns",

        handler = function ()
            applyDebuff( "target", "intimidating_shout" )
            active_dot.intimidating_shout = max( active_dot.intimidating_shout, active_enemies )
        end,
    },


    mortal_strike = {
        id = 12294,
        cast = 0,
        cooldown = 6,
        gcd = "spell",
        hasteCD = true,

        spend = function() return 30 - ( buff.battlelord.up and 10 or 0 ) end,
        spendType = "rage",

        talent = "mortal_strike",
        startsCombat = true,
        texture = 132355,

        handler = function ()
            removeBuff( "overpower" )
            removeBuff( "executioners_precision" )
            removeBuff( "battlelord" )
            if set_bonus.tier30_4pc > 0 then removeBuff( "crushing_advance" ) end
            -- Patch 10.1 adds auto Rend to target using MS with talent under 35% HP
            if target.health.pct < 35 and talent.bloodletting.enabled then
                applyDebuff ( "target", "rend" )
            end
        end,
    },


    overpower = {
        id = 7384,
        cast = 0,
        charges = function () return 1 + ( talent.dreadnaught.enabled and 1 or 0 ) end,
        cooldown = function () return 12 - ( talent.honed_reflexes.enabled and 1 or 0 ) end,
        recharge = function () return 12 - ( talent.honed_reflexes.enabled and 1 or 0 ) end,
        gcd = "spell",

        spend = function() return talent.strength_of_arms.enabled and target.health_pct < 35 and -8 or 0 end,
        spendType = "rage",

        talent = "overpower",
        startsCombat = true,
        texture = 132223,

        handler = function ()
            if talent.martial_prowess.enabled then applyBuff( "overpower" ) end
        end,
    },


    piercing_howl = {
        id = 12323,
        cast = 0,
        cooldown = function () return 30 - ( conduit.disturb_the_peace.enabled and 5 or 0 ) end,
        gcd = "spell",

        talent = "piercing_howl",
        startsCombat = false,
        texture = 136147,

        handler = function ()
            applyDebuff( "target", "piercing_howl" )
            active_dot.piercing_howl = max( active_dot.piercing_howl, active_enemies )
        end,
    },


    pummel = {
        id = 6552,
        cast = 0,
        cooldown = function () return 15 - ( talent.concussive_blows.enabled and 1 or 0 ) - ( talent.honed_reflexes.enabled and 1 or 0 ) end,
        gcd = "off",

        startsCombat = true,
        texture = 132938,

        toggle = "interrupts",

        debuff = "casting",
        readyTime = state.timeToInterrupt,

        handler = function ()
            if talent.concussive_blows.enabled then
                applyDebuff( "target", "concussive_blows" )
            end
        end,
    },


    rallying_cry = {
        id = 97462,
        cast = 0,
        cooldown = 180,
        gcd = "spell",

        talent = "rallying_cry",
        startsCombat = false,
        texture = 132351,

        toggle = "cooldowns",
        shared = "player",

        handler = function ()
            applyBuff( "rallying_cry" )
            gain( 0.10 * health.max, "health" )
        end,
    },


    rend = {
        id = 772,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = 30,
        spendType = "rage",

        talent = "rend",
        startsCombat = true,
        texture = 132155,

        handler = function ()
            applyDebuff ( "target", "rend" )
        end,
    },


    sharpen_blade = {
        id = 198817,
        cast = 0,
        cooldown = 25,
        gcd = "off",

        pvptalent = "sharpen_blade",
        startsCombat = false,

        handler = function ()
            applyBuff ( "sharpened_blades" )
        end,
    },


    shattering_throw = {
        id = 64382,
        cast = 1.5,
        cooldown = function () return ( pvptalent.demolition.enabled and 90 or 180 ) end,
        gcd = "spell",

        talent = "shattering_throw",
        startsCombat = true,
        toggle = "cooldowns",

        handler = function ()
            removeDebuff( "target", "all_absorbs" )
        end,
    },


    shockwave = {
        id = 46968,
        cast = 0,
        cooldown = function () return ( ( talent.rumbling_earth.enabled and active_enemies >= 3 ) and 25 or 40 ) end,
        gcd = "spell",

        spend = -10,
        spendType = "rage",

        talent = "shockwave",
        startsCombat = true,

        toggle = "interrupts",
        debuff = function () return settings.shockwave_interrupt and "casting" or nil end,
        readyTime = function () return settings.shockwave_interrupt and timeToInterrupt() or nil end,

        usable = function () return not target.is_boss end,

        handler = function ()
            applyDebuff( "target", "shockwave" )
            active_dot.shockwave = max( active_dot.shockwave, active_enemies )
            if not target.is_boss then interrupt() end
        end,
    },


    -- Bash an enemy's skull, dealing $s1 Physical damage.; Skullsplitter causes your Deep Wounds $?s386357[and Rend ][]on the target to bleed out $427040s1% faster for $427040d.; Generates ${$s2/10} Rage.
    skullsplitter = {
        id = 260643,
        cast = 0,
        cooldown = 21,
        gcd = "spell",

        spend = -15,
        spendType = "rage",

        talent = "skullsplitter",
        startsCombat = true,

        handler = function ()
            applyDebuff( "target", "skullsplitter" )
        end,
    },


    slam = {
        id = 1464,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = function() return 20 + ( talent.barbaric_training.enabled and 5 or 0 ) end,
        spendType = "rage",

        startsCombat = true,

        handler = function ()
        end,
    },


    champions_spear = {
        id = function() return talent.champions_spear.enabled and 376079 or 307865 end,
        cast = 0,
        cooldown = 90,
        gcd = "spell",

        spend = function () return ( -25 * ( talent.piercing_challenge.enabled and 2 or 1 ) ) * ( 1 + conduit.piercing_verdict.mod * 0.01 ) end,
        spendType = "rage",

        startsCombat = true,
        toggle = "cooldowns",
        velocity = 30,

        handler = function ()
            applyDebuff( "target", "champions_spear" )
            if talent.champions_might.enabled or legendary.elysian_might.enabled then applyBuff( "elysian_might" ) end
        end,

        copy = { "spear_of_bastion", 307865, 376079 }
    },


    spell_reflection = {
        id = 23920,
        cast = 0,
        cooldown = 25,
        gcd = "off",

        talent = "spell_reflection",
        startsCombat = false,

        toggle = "interrupts",
        debuff = "casting",
        readyTime = state.timeToInterrupt,

        handler = function ()
            applyBuff( "spell_reflection" )
        end,
    },


    storm_bolt = {
        id = 107570,
        cast = 0,
        cooldown = 30,
        gcd = "spell",

        talent = "storm_bolt",
        startsCombat = true,
        texture = 613535,

        handler = function ()
            applyDebuff( "target", "storm_bolt" )
        end,
    },


    sweeping_strikes = {
        id = 260708,
        cast = 0,
        cooldown = 30,
        gcd = "off",
        icd = 0.75,

        startsCombat = false,
        texture = 132306,

        handler = function ()
            setCooldown( "global_cooldown", 0.75 )
            applyBuff( "sweeping_strikes" )

            if talent.collateral_damage.enabled then
                state:QueueAuraExpiration( "sweeping_strikes_collateral_dmg", TriggerCollateralDamage, buff.sweeping_strikes.expires )
            end
        end,
    },


    taunt = {
        id = 355,
        cast = 0,
        cooldown = 8,
        gcd = "off",

        startsCombat = true,
        texture = 136080,

        handler = function ()
            applyDebuff( "target", "taunt" )
        end,
    },


    thunder_clap = {
        id = 396719,
        cast = 0,
        cooldown = 6,
        hasteCD = true,
        gcd = "spell",

        spend = function() return 30 + ( talent.blood_and_thunder.enabled and 10 or 0 ) end,
        spendType = "rage",

        talent = "thunder_clap",
        startsCombat = true,

        handler = function ()
            applyDebuff( "target", "thunder_clap" )
            active_dot.thunder_clap = max( active_dot.thunder_clap, active_enemies )

            if talent.blood_and_thunder.enabled and talent.rend.enabled then -- Blood and Thunder now directly applies Rend to 5 nearby targets
                applyDebuff( "target", "rend" )
                active_dot.rend = min( active_enemies, 5 )
            end
        end,
    },


    thunderous_roar = {
        id = 384318,
        cast = 0,
        cooldown = function() return 90 - ( talent.uproar.enabled and 30 or 0 ) end,
        gcd = "spell",

        spend = -10,
        spendType = "rage",

        talent = "thunderous_roar",
        startsCombat = true,
        texture = 642418,

        toggle = "cooldowns",

        handler = function ()
            applyDebuff ( "target", "thunderous_roar" )
            active_dot.thunderous_roar = max( active_dot.thunderous_roar, active_enemies )
        end,
    },


    titanic_throw = {
        id = 384090,
        cast = 0,
        cooldown = 6,
        gcd = "spell",

        talent = "titanic_throw",
        startsCombat = true,
        texture = 132453,

        handler = function ()
        end,
    },


    victory_rush = {
        id = 34428,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        startsCombat = true,
        texture = 132342,

        buff = "victorious",
        handler = function ()
            removeBuff( "victorious" )
            gain( 0.2 * health.max, "health" )
            if conduit.indelible_victory.enabled then applyBuff( "indelible_victory" ) end
        end,
    },


    war_banner = {
        id = 236320,
        cast = 0,
        cooldown = 90,
        gcd = "off",
        icd = 1,

        pvptalent = "war_banner",
        startsCombat = false,
        texture = 603532,

        toggle = "cooldowns",

        handler = function ()
            applyBuff ( "war_banner" )
        end,
    },


    warbreaker = {
        id = 262161,
        cast = 0,
        cooldown = 45,
        gcd = "spell",

        talent = "warbreaker",
        startsCombat = false,
        texture = 2065633,
        range = 8,

        handler = function ()
            if talent.in_for_the_kill.enabled and buff.in_for_the_kill.down then
                applyBuff( "in_for_the_kill" )
                stat.haste = stat.haste + ( target.health.pct < 35 and 0.2 or 0.1 )
            end
            applyDebuff( "target", "colossus_smash" )
            active_dot.colossus_smash = max( active_dot.colossus_smash, active_enemies )

            if talent.test_of_might.enabled then
                state:QueueAuraExpiration( "test_of_might", TriggerTestOfMight, debuff.colossus_smash.expires )
            end
            if talent.warlords_torment.enabled then
                if buff.recklessness.up then buff.recklessness.expires = buff.recklessness.expires + 4
                else applyBuff( "recklessness", 4 ) end
            end
        end,
    },


    whirlwind = {
        id = 1680,
        cast = 0,
        cooldown = function () return ( talent.storm_of_steel.enabled and 14 or 0 ) end,
        gcd = "spell",

        spend = function() return 30 + ( talent.barbaric_training.enabled and 10 or 0 ) + ( talent.storm_of_swords.enabled and 20 or 0 ) end,
        spendType = "rage",

        startsCombat = false,
        texture = 132369,

        handler = function ()
            removeBuff ( "collateral_damage" )
            collateralDmgStacks = 0
        end,
    },


    wrecking_throw = {
        id = 384110,
        cast = 0,
        cooldown = function () return ( pvptalent.demolition.enabled and 45 * 0.5 or 45 ) end,
        gcd = "spell",

        talent = "wrecking_throw",
        startsCombat = false,
        texture = 460959,

        handler = function ()
        end,
    },
} )

spec:RegisterSetting( "shockwave_interrupt", true, {
    name = "Only |T236312:0|t Shockwave as Interrupt (when Talented)",
    desc = "If checked, |T236312:0|t Shockwave will only be recommended when your target is casting.",
    type = "toggle",
    width = "full"
} )

spec:RegisterSetting( "heroic_charge", false, {
    name = "Use Heroic Charge Combo",
    desc = "If checked, the default priority will check |cFFFFD100settings.heroic_charge|r to determine whether to use Heroic Leap + Charge together.\n\n" ..
        "This is generally a DPS increase but the erratic movement can be disruptive to smooth gameplay.",
    type = "toggle",
    width = "full",
} )


local LSR = LibStub( "SpellRange-1.0" )

spec:RegisterRanges( "hamstring", "mortal_strike", "execute", "storm_bolt", "charge", "heroic_throw", "taunt" )

spec:RegisterRangeFilter( strformat( "Can %s but cannot %s (8 yards)", Hekili:GetSpellLinkWithTexture( spec.abilities.taunt.id ), Hekili:GetSpellLinkWithTexture( spec.abilities.charge.id ) ), function()
    return LSR.IsSpellInRange( spec.abilities.taunt.name ) == 1 and LSR.IsSpellInRange( class.abilities.charge.name ) ~= 0
end )

spec:RegisterOptions( {
    enabled = true,

    aoe = 2,

    nameplates = true,
    rangeChecker = "hamstring",
    rangeFilter = true,

    damage = true,
    damageDots = false,
    damageExpiration = 8,

    potion = "spectral_strength",

    package = "Arms",
} )


spec:RegisterPack( "Arms", 20240203, [[Hekili:D3vBZTTrs6FlQsfAYezAciPiNusSQS5UQU46UCBTY39rbcrajI1GeCbaTS2If(TFDp4T5LUhaqrQC1(H4yZzWt3tp9BZmngCVZ9F((7c8ZdV)pCN5E5m3zxmD21Ux5C193L)Y2W7VBR)YV4)e8x24Vg(ZFnDDg(JVeN4hGpCwYU0LqdRYZ3M9lF4dpfLVA3dtxMS(dzrR3f7NhLSzzQ)J54)E5hU)Uh2ffN)7BU)bAkF5935VlFvs693Dxda)gcaqKOGGWYNmmB593Hp57N5((zx8lfl(VI2KKwSaEOFRyXUTi2tl(uXNGoDX7DCFVZ1qN(BHRt(AyXIu)OaVWVgUjFQFqqwXILRcx(f4)hTPyXJ(Ffrk5XIf5(PpfMdnNSd6AlCoV3fHRyXFj6PIf(FluTnxrB)pcMaajPKTu6ZSFs0NsgkOyXV)xbcNMSUyX)XVcda)nWVLHKw8priUXPMFub6kbq)v)8LRkw4mBQBBZZUg6HkVKgT5lH5Wi9rCmcD3z6vspWvV3Dg1d8HF7FltPBZ(yz3YG(8RPl93a))pNKMcIuG7H)BBAyE(lflItEg)hrjPr4)efWzrBEko896dgevvjxlp22PlEVBPO733SmExa0R72gghJIYhJdxIQltV)U4OS8mHcQGwEL0c(H)qOZhUX)H4WG7)l3F3sGVctJ8rnZhFe0CJbDUWu)yVa)1GQ)0DBlwmcvbsIdsEEZ0SNdd3cO6LbYMVeMnnnCTF0gqKEtXIla1xbpC)DpVkkn(5Onb3Ndk5Suf7(xd9c3eUokeazomIBbrNyiwxWI14IfIbXFF3tpfMUbmKQ5E9FwMNFAzW01(FRyXKIf73xSOgLSDO5MxqOF(k4bawsavqs(0aGR8EgmkcKg(JeASEpKSzx208OW0lC8C3USeuBiEwjOGUtGD0UerBsR0j8BHl3b(qaHYLScftOV5wPb9i0Qkg9e8qCssGhy55b(W2eeMoTcp1o5ha4KbGN5LNKUg)XA62Wyva4Tm2FlYDxXYDAEIMI2hOkWvgGLSlZlnXpfX7NgoELtdv2C5rRbBIeVGOqHkG7SwY5)v)8sQCnsL6FgmmsYYaEidg9RKPo0Zpou(X1vYqXp9bqz4lHcI(ZYeDDski3Ru(1OPZSt4uo)uPdVdKkqZq1cVKh9YEojfgYYArbH1EzKeMGrkJBdhE)gveB1U00i09RczQnHZdZYrozD0tRk9fGkbN1m(vBVpmQWlrTdLwIl7pXTwvtqIDBwb(VcdE74VwzPWyvmDieM8ooTWmDpJTCL)6TWFdABByPLJZLYAXzFzxCC224OCGC6AX8UgyCzs6(ZH3JqTwzYMOLG70K1M64zRsw(LN9)Ajux3juwuW7CIRjoQMeTrdAUKL6puS4AotdEFoWec4LdG6wHY4iznQh8ZZJdJb(ULRK0wnBUL8qIAPBtEU0nLZpFGsjUee49MvH3Y0DzOPKhKv0YqIjXyFHAUBhz4SomDzuCywggBn8ji)o0VhRlixxzvzfVHQAYUxOOZJCJwhumkKSn162vkHDIdr9sTU8tYD55ui3DuWKVkn5z1UMJRv4r)DXDK7hgqSmkXSPvHkXeZfr3dGCj93SmuOAELIDpOM1KDx9pVD361HXACSQSbty1lTjFvT(YNkdAx0yNG8QfxHY2tF0EWFPX02eX)NiLLMrTpW7L)dpml7YCT9kxFy9YlSNJsJlaLW7kCSdolmcxO2tLm5vYzOiwVbM9fUCJMmviPfTWbPUQ3iswPLKXOFSmV)(UGNwxrtE)phjA(G)tO7dOvyPPnPgX4IWCMfLIFCwBW6Y86AIRXOmu)iJB6XQq)yi2ZwmzDCfoxj7Nhgzz(ltd1DMs9KUZusEOF8JCMPpa5ChMIM6DL)xNXSlt87XDPV0roDDd1JrPHc46iHTUrcDYakdGkbAK1rkl4dPTUr1eVEmm9RjPOguzqn9eWyNbhroboVCQNz6DU80lbRblPfvZxIJP2bC6UnSUs8tcBZKIWpKXZU8LLnl0ptqgjkQSg5boYRu6Nyx3wH5LZmJZrQTbV6UwicJTfIYLSgMkBcK16NaNE9kdsPhPKQJRs2LtfFsIjta1sy53Tp7x9bPh0k(3I316QFAUZ0OSPP7E4fVNxfgVfGxSDmczLsFG0kGiFPyK6Onl9t34Nh6fTScD1iiEoEHFtS)oureha352dUZDWCNRm3PpbxXDrpQ4HUvuSYpZBxwOh6oOXyST5MWdb7sf7(zXIVxkOrLBZ2glZdys5MIMgTTuI8VJccyiaMF(YB7xnoNd5ne91OauT)HxGovcBXIFh4PO83bDviklwaSBXInjqSyraki7p8VMVlfOTdatymUhG1)cK(0u65ZSx2SKDgZdr5(7GNUzk0HkjcjzlfsMZtLuLyEW1(8G7HppyDaPNPYauL11CQ2RoRT)w3y5ATQhdtnSMReqMAh4JNrLw1aeq6tP6ciQ2FRBKra52HaYTvaPNf4anjQ3kEzJc6PmbffCmb7w1iow5BT0MQtZQpO0b8z9ABCIyxagxTKGF0IOTPNeme6gq0JjI0rg3dNUFqPd9MR0Ti45khjUs1RHtJUTlzMUdWMqe51pgsJawTQ32D)Z)jKbWdjFJ2kCT)MD(XKPepaA6oaA6ktt9KNRYeKcPMCMjAuKVun7LrTW)Uhm65WcE3DQvO7yp2pZShHFdppkZO0)VnmPKObYcCBS)MnvRZrxOmCEFEZ(Gn2k3HmpxBJmBsE96xP53c7GxzhkNoQMVjNnuejFUUJvZ(p(cSGi)8vE5Rc9csd9xJ7SpUpQQ73)A)0VGl2PU)Wkjf7kK(()z58BQ2W3Uatpfaz5WfQ9ODtUi61z9zZLzh(eAgwmxq)rjGhSNwgOScmYotStn6dvCNYUGAHd1axnFJRclojx(FRZkTuZAmi6yuLopK0T13AHrQU5HjEVY96BUiDT6JBWsxO3YIrCrAAIJRdDz4QAjQrAcnI6gzmzS12tsV0J0eJeY0IuHg)pI7ELxZgmrAVvS4ZRApV)IfphLVc(N4VTcECqlgs1pdemWIkcQwCW5y3WLt9a0lyEnajvk2tr9lS1pkf)TsO(1sHh1650uAC1uAChKsJBhknUdtPXTBLgIUmiLghELghBknohKsJRPsJrsxMknw2r4dXuVRmo7P1UvmyY7ururRGuHXeQ1yzmvpIufQFowWEX4Jf0j2gUuyRvV5AAwU4k1t2e)c(NH4FiSbLmH3MMGRWVClaqg886EGw1jWFMw(ynSqXI)B4NIaG3egv2E3O9qcAERGd1s3Fng5wNM6VDExRuPtllRQCeQleEg6N6cTlLbQUqSDd1tc4Z4Tc8sxpli9dwNgc)h7I2UnmykxIj9Y6St3yt61SwNHqNuM8z92X(V4L)1Wk7L4W8CaAZdswTOBicx3srwcDMvAjn5w1R2AaAyflaiZVSspOFaj1UgitQKq0NKMu9kHIyQ4HePnBW2(bVuTkd26xPCW05HH1wMw94GwzfFTtBTitupl8NV6GRVRpkFIewlQm(J7ui6gw5j2st5ZMH)ieBpMi(szP5WPVCMS3)Z6XJoMoeqxvDvdfVUmFGMyQMLiOLZ0SS(dQoPSPnoQQpdrEHiNctznAqTdoDQOCPYXjtxnBsY5wI27A7QsMwoTdpkUWF8W0IYG)X0SC)LFrQsH6Oykih)gomno0szXGKot9sew7NMhbiaPy9CywwntHw8TurT8J4D(mSXRn6FBZrk3QsZaR80vxqAtWzRWwjucuRSoeaLAwT2ux1VILkhBW1kNs1Q2odPsWYA7IqXvRBkNQBhv1eE84DNoZbvi4KUk5nSpL5nXBvx7HvQE0Olx7Eut3ICMK)D6ePA(121j)d4bEEHHF4MIfM3pqxBryBbBlyXO14YVcd8meJKz5WaQRJU5SuhBaQ7EmQOFBN6i7BwQ0gMFCi2HjSi4m3oYb)aQNFLPZU3fA2malBwy0rx(1xmSCeztGRKq2xFIAQDCl2uplpTSS4Qvmj51qlvN7nRgO3GupPEFvgAEN9p4PuwxD)kjSYpDlmhg4vAHzgV2WuroEH18dgzQKGEl)OTW8DenzyvIFvRDL3pvoYh13iGEYhSVUa88bJHUU3tJSNzZwM3)v(Hu86wsBRL74RhrjdDRfTO1vLO3iFqAjdh(11A1OOIzXD9kaYIsFXD9zbGgMmkoUvZ1VZ8v5KACtxD5EJzyp2(ixS7KQV6ftygsgVTd0UkoSv1yXkuBJQOcWvorqf(W4fRWyzg9imr9oeFkI6jLAa5ui5WTmOc541TxlUzqLOSLCLvF9qS9M)5Y7(Q10RRxxgdYR8oLq96ROS0Y2LbQ1Rp2)fXHvPcOhJ9S8TG3bCKI5uHL(beXqCGSqYSGOO6DH(Dkfg87WYU8FSR8qwZsWJkawsxs1j0cMIBatXPfF6)mcpFOl)LIf)wYgGIIMFh3kKauXx3C22RfLq)g78TjDJVzQUgKGpByDQ4m7epmeVW8eeqlIOg8mXlna3Lg8Mi3AWAerVVaQe4rduYGs9f46xNtnm1Flp7lCVE(86t50fd4VEU(JmAXnV(H6QVgVxIVfq(ZNqzRlJHSQFBnSPDQ3cDXNi8zw9caomVLmd96qYA8LEK6o4OM3LJHXtxOZtvh9j5BGrdh2EmR09szwXkjyFfjOPLTUBpYrfmKV7gg0IRx9Ne9FC1z3vi6vSct5seMq4P1Cpb1OgMjqMQpNu45aobKGIEKvENWWn8hn2g8F)3RVlE1TC7SjDiy7azBa3mO(jw1kRZWgnRmfWdA3tb095KcphW8ZWUCZdeWpSz4bHCVMHnYa4yydBh0YfWLNgU5P8vmiR3NJm8VcgVmp(xSX3TD54c(RGRH2YGj)4OCRCUA3o(e5vmcwHIgB8EDhoMa)k4xCn72y3Q2pIWYXSgjoFmCIBhu72G095id)RGX5Scj7YXf8xbxBZ6JTBhFI8kgb0wIeD4yc8RGFjTfnB)iclhZASAUgupSCEoXW3dG3MMSCQ)Mx8c2MzdCU(1t(VVKbf6Edh((6SYQVWxp8dvT5qxm0jg(EaC)Mp57xp5)(sMdsTP)PXEqQn9h(EQ2ySqOZ4km(rCL6((9CTmAS9f5WzJo5hg7m9QFKXqaAL5LOEYK5JTVWzUPxDk60jfDQOyT4)nuU9H3C52hobYTgnsZtnPrzN(v1MqJNTJk6(MhFsfcCVu4eUK7IsIDu9XK44KNfVtU(GKcSTEomnS(1qeTZeVLtLNexXc8Y1bpB086(TjrSDS72O07GaSZb(5(p4Nf(lfFQyX7lwGzCWSvU(jyItVMnXT6ydKooYgrIztC7ModQhTtfJbFSCi1GuUyk1rH5iczRxpnO7SU(6j9AlggdXHE5h(NlIhVJn9FX47tMgJX2FFsgvmhR4GpCjoxUvheNwr)PblxnbAapZCWHFM1mc5JYXk6yS92LpUEjsPHoxfu9wdpJMHu9wPHmrLy1xqpzNI9XsyWCgSVkHHlJXYbA75YOlF8pf7Q8JqZIbKTbZO9i7pJ)uJBElMFNzcLYT9NbCLPUxNiUbIgn3tqBYSVQMdjaMOlNqW7e2(VE9ETTaVEYyDBb4pkFETdxETJ3i4CSRSz0CpbTt9bYUCcbVty7)Ek2lLTxpzSQSXvoehML4jf8oH9aDFEKHJR8dom1Ttk4Dc7b6J4idh)PIEid6tk4Dc7HP63tE(WaNlHSQQ()DdkFmB7tt1LKX70ZdZ8(ZOtNGNsuBFN)0W08Q340Jix5G)6xBZjd4JEjGZSee6xvgn0T)68BqkMf81((YRbV5ls)7KwLZVlSNqGUwDJAr7f8gpp5XO4W63MISPnLn7pE7huU0Zl(KTUGx3509OENZphV5eVTYjq71X25Il5UBBD5ruOP73R0mBTHoegWLHbiR01wgWEXPw8PVRyXFM3k4drcuEcgNNS9wXnBCLCW582lj3BbiphgwbriMsZrYhosBbao0AhDimR7HYSCvR4qldYHWSvNyMHQTmNSF)y1guomuzn(MgRQAhY2(ABnXq2UO6tiBbp3LruN6xL9XGg5UKJCxUror1diBQXpYPRgiY21g5UDoYDpOrE91)OUkQRSkQJKc6j6GwTD(0mRxt7WpjMu65rUA7KQz2ycnAtyky7WxhYeu9nBjvahItcDiq7sdn3HSsdnAEeLhUUeAYhR5bHUx(saFE0J3Ilx5g073(9gFoTMFL8Zu(vZs(x0)kzP0BXNPkKcsFsSUD2iR3EtZ)iyQzCTACJRcFO)5TsrAMj3t1VcviV0OHr(HDAoOmncVfJU5QzY4O9PLcbI)di1i70qgxLpFuhpuB(gmjMFneNZD(4Src60C1Mrk1XUn24Dz(MlUAK2oV380s9YD2K(qdxf5C7N8jEHXUTYprZx2P((aQFaN67tP9HaQYilj8CCwyzo4zgac7q77s9CxCaB90uqPl5rymYqEo)IRiKYZrPSgzD6KVRwv85kVq5WqqES0Fod0hMqRa0jJO8Msl5FQAjpHWZ1CPiGmv98KX1yvRXb3vy1nxqHUEVjMfDOEoftqHoK2Tr1nOtVrelKNcn8brquE2ZiE4rJpZyv3TdDApQ3CzJAi1dzExBEZLtgr5ZWLI1lnUvCSsDFAUFpNrwxofKOL2LYIDI2kjj1QAg1c5UX1R0CxYrRkvO6rTPvTYQ51lXiUR9cc00UoCKTlv2hJYqwxodSdB0qu7WyDxXCZhtkX6A5vSijaexlliFWC)uo3LB8Xox0wglmZfx2eVPzFwQhW9Z2S7RLKBDTNwclZ3CJBuY7cMAu1AoiUpMUHuT6a5yEYCle65mR7EK1hM0tP8T4O0G1Irajm1xjhLzMOTbuwLW21DiTYvUzpKJVarUjmwvUjghP)t1QckAcLaDkcsvISCDfkjYK)zLOmY1jyDdy4LrMbOmUQe)HztnOpvaYMHH5ny4CNRAI2WwxxJSbGRtRQBBZu)2i5FrRiigPVtmY83aHQ)dhnA56OlnBJws4Mts0rXhmbk3VVCxk0V9XmvL6rmV975t(Peev3JgzqwgGYmtWMrwD6K0PrANADz(seRL62(ZGinX06NpXYNYWNDTZmTk2R0ncXv9KvpWA50FZTFKXXGCQbca1Vo8SL5vNzIujGmZ76urk1Cb40SBnHBA0Qh56Pg1QtKxp4mMLTXUEo(CE4UX7O81QKlbRAtflivgDJOt5ttfY0FaHisFGDyS4ytEC)(QBDUBDnSYvnLiCP0R0Hy1Xe5UP7zZuCWTOyEVl4grF4(6QCCti)m4vtVpejfrNVGM)CJrTISVlWQ1ZuRnsJugI9xB8B1P9zOeYMIMYEdCIYXsNgdB7a0FAP4rJhw(K462g4YfndT5UDzToLjkNPN)hzOXj8doDDHU3WdQurPsSPtAkhJJmVjEe6rcxw38bD84siXqzT7CT4FygBYJ7mspn0OdDYSyzPTm1av1i76HVR2FcZmkOdTXV5fmPm0UvS1xcEhlkArx5vN2KfhvYRgVxEKyCmyHewxPE92b)6uJif1DSNEZbT6F4AE6QKIstshTBNAZnQx7QTA(Px1OXIOeIik9CCHp7oI36W0LrXW6eqp3HpLkQPdRkkYojSZG9X01IYUi5zlJfJ48FxXIpRFID1hqlEGbQNNj3xYSZR98X91GD0zwxtT1hLBH9xyDhmUac22Pbn1af)lvFt3G8o5ogxHAnnJDZTxOkxFJ(CHoKHf(LSR(OAfjxZwgduf4q55KpA8zc5BZ2zpkVTccQRa35ZqF5u)U(5soIQ4eQQHdjmuFxtKRie9YrLOqlQlVJBDMixfnK10W8Bv(SEEOsxxsPRlR01TtPRlJ01DGsxhcPRdJ01SaLTjDDNipV0pP73vw5C))0VsNh6SVW2IVgHSACX(uuvjuZScLgL4XMOuRAsQkJ0u0yny3VNXJxZxut8GWpurLlTOQxwk8vuLnfywj8eLIBRFIk33crfcH4tpQqw15hyulkr2mTNyrIAZH7KQekA(u93o(QHdhGQvFvw7NW)QcVcFM2L6FRZOXmRA8m6Va)t6dzL(Q7ts25qYQJziW(90)(iMp7)ZVAI4lj4Y7)JRDexM93))9d]] )