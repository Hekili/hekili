-- WarriorFury.lua
-- November 2022

if UnitClassBase( "player" ) ~= "WARRIOR" then return end

local addon, ns = ...
local Hekili = _G[ addon ]
local class = Hekili.Class
local state = Hekili.State

local strformat = string.format

local FindPlayerAuraByID = ns.FindPlayerAuraByID
local IsActiveSpell = ns.IsActiveSpell

local spec = Hekili:NewSpecialization( 72 )

local base_rage_gen, fury_rage_mult = 1.75, 1.00
local offhand_mod = 0.50

spec:RegisterResource( Enum.PowerType.Rage, {
    mainhand_fury = {
        swing = "mainhand",

        last = function ()
            local swing = state.swings.mainhand
            local t = state.query_time

            return swing + floor( ( t - swing ) / state.swings.mainhand_speed ) * state.swings.mainhand_speed
        end,

        interval = "mainhand_speed",

        stop = function () return state.time == 0 or state.swings.mainhand == 0 end,
        value = function ()
             -- annihilator: auto-attacks deal an additional (10% of Attack power) Physical damage and generate 2 Rage.
             -- swift strikes: annihilator generates 2 additional rage
            return ( ( ( state.talent.war_machine.enabled and 1.2 or 1 ) * base_rage_gen * fury_rage_mult * state.swings.mainhand_speed )
            + ( state.talent.annihilator.enabled and ( state.talent.swift_strikes.rank > 0 and 2 + ( state.talent.swift_strikes.rank * 1 ) or 2 ) or 0 )
            )
        end
    },

    offhand_fury = {
        swing = "offhand",

        last = function ()
            local swing = state.swings.offhand
            local t = state.query_time

            return swing + floor( ( t - swing ) / state.swings.offhand_speed ) * state.swings.offhand_speed
        end,

        interval = "offhand_speed",

        stop = function () return state.time == 0 or state.swings.offhand == 0 end,
        value = function ()
            -- annihilator: auto-attacks deal an additional (10% of Attack power) Physical damage and generate 2 Rage.
            -- swift strikes: annihilator generates 2 additional rage
            return ( ( state.talent.war_machine.enabled and 1.1 or 1 ) * base_rage_gen * fury_rage_mult * state.swings.offhand_speed * offhand_mod )
            + ( state.talent.annihilator.enabled and ( state.talent.swift_strikes.rank > 0 and 2 + ( state.talent.swift_strikes.rank * 1 ) or 2 ) or 0 )
        end,
    },

    battle_trance = {
        aura = "battle_trance",

        last = function ()
            local app = state.buff.battle_trance.applied
            local t = state.query_time

            return app + floor( ( t - app ) / 3 ) * 3
        end,

        interval = 3,

        value = 5,
    },

    conquerors_banner = {
        aura = "conquerors_banner",

        last = function ()
            local app = state.buff.conquerors_banner.applied
            local t = state.query_time

            return app + floor( t - app )
        end,

        interval = 1,

        value = 6, -- Fury 6, Arms 4, Prot 4
    },

    ravager = {
        aura = "ravager",

        last = function ()
            local app = state.buff.ravager.applied
            local t = state.query_time

            return app + floor( ( t - app ) / state.haste ) * state.haste
        end,

        interval = function () return state.haste end,

        value = function () return state.talent.storm_of_steel.enabled and 20 or 10 end,
    },
} )


-- Talents
spec:RegisterTalents( {
    -- Warrior Talents
    armored_to_the_teeth            = { 90366, 384124, 2 }, -- Gain Strength equal to $s2% of your Armor.
    avatar                          = { 92640, 107574, 1 }, -- Transform into a colossus for $d, causing you to deal $s1% increased damage$?s394314[, take $394314s2% reduced damage][] and removing all roots and snares.; Generates ${$s2/10} Rage.
    barbaric_training               = { 90377, 390675, 1 }, -- Revenge deals $s1% increased damage but now costs ${$s2/10} more rage.
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
    concussive_blows                = { 90335, 383115, 1 }, -- Cooldown of Pummel reduced by ${$s1/-1000}.1 sec. ; Successfully interrupting an enemy increases the damage you deal to them by $383116s2% for $383116d.
    crackling_thunder               = { 90342, 203201, 1 }, -- Thunder Clap's radius is increased by $s1%, and it reduces movement speed by an additional $s2%.
    cruel_strikes                   = { 90381, 392777, 2 }, -- Critical strike chance increased by $s1% and critical strike damage of Execute increased by $s2%.
    crushing_force                  = { 90347, 382764, 2 }, -- Slam deals an additional $s1% damage and has a ${$s3/10}.2% increased critical strike chance.
    defensive_stance                = { 92538, 386208, 1 }, -- A defensive combat state that reduces all damage you take by $s1%, and all damage you deal by $s2%. ; Lasts until canceled.
    double_time                     = { 90382, 103827, 1 }, -- Increases the maximum number of charges on Charge by 1, and reduces its cooldown by ${$s2/-1000} sec.
    dual_wield_specialization       = { 90373, 382900, 1 }, -- Increases your damage while dual wielding by $s1%.
    endurance_training              = { 90339, 382940, 1 }, -- Stamina increased by $s1% and the duration of Fear, Sap and Incapacitate effects on you is reduced by ${$s6/10}.1%.
    fast_footwork                   = { 90371, 382260, 1 }, -- Movement speed increased by $s1%.
    frothing_berserker              = { 90350, 215571, 1 }, -- Rampage has a $h% chance to immediately refund $s1% of the Rage spent.
    furious_blows                   = { 90336, 390354, 1 }, -- Auto-attack speed increased by $s1%.
    heroic_leap                     = { 90346, 6544  , 1 }, -- Leap through the air toward a target location, slamming down with destructive force to deal $52174s1 Physical damage to all enemies within $52174a1 yards$?c3[, and resetting the remaining cooldown on Taunt][].
    honed_reflexes                  = { 90367, 391270, 1 }, -- Cooldown of Raging Blow and Pummel reduced by ${$s2/-1000}.1 sec.
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
    sidearm                         = { 90334, 384404, 1 }, -- Your auto-attacks have a $s2% chance to hurl weapons at your target and 3 other enemies in front of you, dealing an additional $384391s1 Physical damage.
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
    war_machine                     = { 90386, 346002, 1 }, -- Your auto attacks generate $s2% more Rage.; Killing an enemy instantly generates ${$262232s1/10} Rage, and increases your movement speed by $262232s2% for $262232d.
    warlords_torment                = { 90363, 390140, 1 }, -- Activating Avatar or Colossus Smash casts Recklessness at reduced effectiveness.
    wild_strikes                    = { 90360, 382946, 2 }, -- Haste increased by $s1% and your auto-attack critical strikes increase your auto-attack speed by $s2% for $392778d.
    wrecking_throw                  = { 90351, 384110, 1 }, -- Hurl your weapon at the enemy, causing $<damage> Physical damage, ignoring armor. Deals up to $?s329033[${($329033s3/100+1)*500}][500]% increased damage to absorb shields.

    -- Fury Talents
    anger_management                = { 90415, 152278, 1 }, -- Every $?c1[$s1]?c2[$s3][$s2] Rage you spend$?c1[ on attacks][] reduces the remaining cooldown on $?c1&s262161[Warbreaker and Bladestorm]?c1[Colossus Smash and Bladestorm]?c2[Recklessness and Ravager][Avatar and Shield Wall] by 1 sec.
    annihilator                     = { 90419, 383916, 1 }, -- Your auto-attacks deal an additional $383915s1 Physical damage and generate ${$383915s2/10} Rage.
    ashen_juggernaut                = { 90409, 392536, 1 }, -- $?a317320[Condemn][Execute] increases the critical strike chance of $?a317320[Condemn][Execute] by $392537s1% for $392537d, stacking up to $392537u times.
    berserker_stance                = { 90325, 386196, 1 }, -- An aggressive combat state that increases the damage of your auto-attacks by $s1% and reduces the duration of Fear, Sap and Incapacitate effects on you by $s2%.; Lasts until canceled.
    bloodborne                      = { 90401, 385703, 1 }, -- Bleed damage of Odyn's Fury, Thunderous Roar and Gushing Wound increased by $s1%.
    bloodcraze                      = { 90405, 393950, 1 }, -- Bloodthirst increases the critical strike chance of your next Bloodthirst by $393950s1%. Stacking up to $s2 times.
    bloodthirst                     = { 90392, 23881 , 1 }, -- Assault the target in a bloodthirsty craze, dealing $s1 Physical damage and restoring $117313s1% of your health.$?s385735[; Increases the critical chance of your next Bloodthirst by $s3%. Stacking up to $u times.][]; Generates ${$s2/10} Rage.
    cold_steel_hot_blood            = { 90402, 383959, 1 }, -- Bloodthirst critical strikes generate ${$383978s1/10} additional Rage, and inflict a Gushing Wound that leeches $385042o health over $385042d.
    critical_thinking               = { 90425, 383297, 2 }, -- Critical Strike chance increased by ${$s1}.1% and Raging Blow and Annihilator's damaging critical strikes deal ${$s2}.1% increased damage.
    cruelty                         = { 90428, 392931, 1 }, -- While Enraged, Raging Blow deals $s1% increased damage and Annihilator deals $s2% increased damage.
    dancing_blades                  = { 90417, 391683, 1 }, -- Odyn's Fury increases your auto-attack damage and speed by $391688s1% for $391688d.
    deft_experience                 = { 90421, 383295, 2 }, -- Mastery increased by $s1% and Bloodthirst cooldown reduced by ${$s2/-1000}.2 sec.
    depths_of_insanity              = { 90413, 383922, 1 }, -- Recklessness lasts ${$s1/1000}.1 sec longer.
    enraged_regeneration            = { 90395, 184364, 1 }, -- Reduces damage taken by $s1%, and Bloodthirst restores an additional $s2% health. Usable while stunned or incapacitated. Lasts $d.
    focus_in_chaos                  = { 90403, 383486, 1 }, -- While Enraged, your auto-attacks can no longer miss.
    frenzied_flurry                 = { 90422, 383605, 1 }, -- Increases auto-attack damage with one-handed weapons by $s1% and your auto-attack critical strikes have a $s2% chance to Enrage you.;
    frenzy                          = { 90406, 335077, 1 }, -- Rampage increases your Haste by $335082s1% for $335082d, stacking up to $335082u times. This effect is reset if you Rampage a different primary target.
    fresh_meat                      = { 90399, 215568, 1 }, -- Bloodthirst always Enrages you the first time you strike a target, and it has a $s1% increased chance to trigger Enrage.
    hack_and_slash                  = { 90407, 383877, 1 }, -- Each Rampage strike has a $h% chance to refund a charge of Raging Blow.
    hurricane                       = { 90389, 390563, 1 }, -- While $?s137050[Ravager is active][Bladestorming], every $?c2[$390719t1][$390577t1] sec you gain $s2% movement speed and $s1% Strength, stacking up to $s3 times. Lasts $390581d. ; Bladestorm cannot be canceled while using Hurricane.
    improved_bloodthirst            = { 90397, 383852, 1 }, -- Bloodthirst damage increased by $s1%.
    improved_enrage                 = { 90398, 383848, 1 }, -- Enrage increases your Haste by $184362s1% and increases your movement speed by $184362s2%.
    improved_execute                = { 90430, 316402, 1 }, -- Execute no longer costs Rage and now generates ${$s3/10} Rage.
    improved_raging_blow            = { 90390, 383854, 1 }, -- Raging Blow has ${$s1+1} charges and has a $85288s1% chance to instantly reset its own cooldown.
    improved_whirlwind              = { 90427, 12950 , 1 }, -- Whirlwind causes your next $85739u single-target $lattack:attacks; to strike up to $85739s1 additional targets for $85739s3% damage.; Whirlwind generates $190411s1 Rage, plus an additional $190411s2 per target hit. Maximum $<maxRage> Rage.
    invigorating_fury               = { 90393, 383468, 1 }, -- Enraged Regeneration lasts ${$s1/1000} sec longer and instantly heals for $s2% of your maximum health.
    massacre                        = { 90410, 206315, 1 }, -- $?a317320[Condemn][Execute] is now usable on targets below $s2% health, and its cooldown is reduced by ${$s3/1000}.1 sec.
    meat_cleaver                    = { 90391, 280392, 1 }, -- Whirlwind deals $s1% more damage and now affects your next ${$s2+$s3} single-target melee attacks, instead of the next $s3 attacks.
    odyns_fury                      = { 90418, 385059, 1 }, -- Unleashes your power, dealing ${$385060sw1+$385062sw1+$385061sw1+$385061sw1} Physical damage and an additional $385060o2 Physical damage over $385060d to all enemies within $385060A2 yards.; Generates ${$s5/10} Rage.;
    onslaught                       = { 90424, 315720, 1 }, -- Brutally attack an enemy for $396718s1 Physical damage$?s388933[ and become Enraged for $184362d.][.]; Generates ${$m1/10} Rage.
    raging_armaments                = { 90426, 388049, 1 }, -- Raging Blow gains an extra charge.
    raging_blow                     = { 90396, 85288 , 1 }, -- A mighty blow with both weapons that deals a total of $<damage> Physical damage.$?s383854[; Raging Blow has a $s1% chance to instantly reset its own cooldown.][]; Generates ${$m2/10} Rage.
    rampage                         = { 90408, 184367, 1 }, -- Enrages you and unleashes a series of $s1 brutal strikes for a total of $<damage> Physical damage$?a396749[ and greatly empowering your next $396749s3 Bloodthirsts or Raging Blows][].
    ravager                         = { 90388, 228920, 1 }, -- Throws a whirling weapon at the target location that chases nearby enemies, inflicting $<damage> Physical damage to all enemies over $d. Deals reduced damage beyond $156287s2 targets.; Generates ${$334934s1/10} Rage each time it deals damage.
    reckless_abandon                = { 90415, 396749, 1 }, -- Recklessness generates ${$s1/10} Rage and Rampage greatly empowers your next Bloodthirst or Raging Blow.
    recklessness                    = { 90412, 1719  , 1 }, -- Go berserk, increasing all Rage generation by $s4% and granting your abilities $s1% increased critical strike chance for $d.$?a396749[; Generates ${$s3/10} Rage.][]
    singleminded_fury               = { 90400, 81099 , 1 }, -- While dual-wielding a pair of one-handed weapons, your damage done is increased by $s1% and your movement speed is increased by $s3%.
    slaughtering_strikes            = { 90411, 388004, 1 }, -- Raging Blow causes every strike of your next Rampage to deal an additional $393931s1% damage, stacking up to $s2 times.; Annihilator causes every strike of your next Rampage to deal an additional $393943s1% damage, stacking up to $s2 times.;
    storm_of_steel                  = { 90389, 382953, 1 }, -- Ravager's damage is reduced by $s1% but it now has $s4 charges and generates $s6 Rage each time it deals damage.
    storm_of_swords                 = { 90420, 388903, 1 }, -- Whirlwind has a ${$s1/1000}.1 sec cooldown, but deals $s3% increased damage. ; Slam has a ${$s2/1000}.1 sec cooldown and generates ${$s6/10} Rage, but deals $s4% increased damage.
    sudden_death                    = { 90429, 280721, 1 }, -- Your attacks have a chance to reset the cooldown of $?a317320[Condemn][Execute] and make it usable on any target, regardless of their health.
    swift_strikes                   = { 90416, 383459, 2 }, -- Increases haste by $s1%, Raging Blow generates an additional ${$s2/10} Rage and Annihilator generates an ${$s3/10} additional Rage.
    tenderize                       = { 90423, 388933, 1 }, -- Onslaught Enrages you, and if you have Slaghtering Strikes grants you $s2 stacks of Slaughtering Strikes.; Enrage now lasts ${$s1/1000} sec longer.;
    titanic_rage                    = { 90417, 394329, 1 }, -- Odyn's Fury's Enrages you, deals $s2% increased damage and grants you $85739u stacks of Whirlwind.;
    unbridled_ferocity              = { 90414, 389603, 1 }, -- Rampage and Onslaught have a $s1% chance to grant Recklessness for ${$s2/1000} sec.
    vicious_contempt                = { 90404, 383885, 2 }, -- Bloodthirst deals $s1% increased damage to enemies who are below $<threshold>% health.
    warpaint                        = { 90394, 208154, 1 }, -- You take $s1% reduced damage while Enrage is active.
    wrath_and_fury                  = { 90387, 392936, 1 }, -- Raging Blow deals $386045s1% increased damage and while Enraged, Raging Blow has a $h% chance to instantly reset its own cooldown.;
} )


-- PvP Talents
spec:RegisterPvpTalents( {
    barbarian            = 166 , -- (280745) For 3 sec after casting Heroic Leap, you may cast the spell a second time without regard for its cooldown. Increases the damage done by your Heroic Leap by 200%.
    battle_trance        = 170 , -- (213857) You go into a trance causing you to regenerate 3% of your health and generate 3 Rage every 3 sec for 18 sec after using Raging Blow twice in a row on a target. Attacking a new target with Raging Blow will cancel this effect.
    bloodrage            = 172 , -- (329038) You gain 40 Rage over 4 sec, and all snares and roots are cleared from you, but at a cost of 5% of your health.
    death_sentence       = 25  , -- (198500) Execute charges you to targets up to 15 yards away. This effect has a 6 sec cooldown.
    death_wish           = 179 , -- (199261) Increases your damage taken and done by 10% for 15 sec at the cost of 10% of your health. Stacks up to 5 times.
    demolition           = 5373, -- (329033) Reduces the cooldown of your Shattering Throw or Wrecking Throw by 50% and increases its damage to absorb shields by an additional 250%.
    disarm               = 3533, -- (236077) Disarm the enemy's weapons and shield for 5 sec. Disarmed creatures deal significantly reduced damage.
    enduring_rage        = 177 , -- (411764) You have a chance to become Enraged while you are suffering movement impairing effects. While Enraged, suffering loss of control effects have a chance to grant you Recklessness for 4 sec.
    master_and_commander = 3528, -- (235941) Cooldown of Rallying Cry reduced by 1 min, and grants 15% additional health.
    rebound              = 5548, -- (213915) Spell Reflection reflects the next 2 incoming spells cast on you and reflected spells deal 50% extra damage to the attacker. Spell Reflection's cooldown is increased by 10 sec.
    slaughterhouse       = 3735, -- (352998) Rampage damage reduces healing the target receives by 3% for 20 sec, stacking up to 12 times.
    warbringer           = 5431, -- (356353) Charge roots enemies for 2 sec and emanates a shockwave past the target, rooting enemies and dealing 1,221 Physical damage in a 20 yd cone.
} )


-- Auras
spec:RegisterAuras( {
    annihilator = {
        id = 383915
    },
    ashen_juggernaut = {
        id = 392537,
        duration = 15,
        max_stack = 5
    },
    avatar = {
        id = 107574,
        duration = 20,
        max_stack = 1
    },
    battle_trance = { --PvP Talent
        id = 213858,
        duration = 18,
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
    berserker_stance = {
        id = 386196,
        duration = 3600,
        max_stack = 1
    },
    bloodcraze = {
        id = 393951,
        duration = 20,
        max_stack = 5
    },
    bloodrage = {
        id = 329038,
        duration = 4,
        tick_time = 1,
        max_stack = 1
    },
    bloodthirst = {
        id = 23881,
        duration = 20,
        max_stack = 1
    },
    charge = {
        id = 105771,
        duration = 1,
        max_stack = 1,
    },
    concussive_blows = {
        id = 383116,
        duration = 10,
        max_stack = 1
    },
    dancing_blades = {
        id = 391688,
        duration = 10,
        max_stack = 1
    },
    death_wish = {
        id = 199261,
        duration = 15,
        max_stack = 10
    },
    defensive_stance = {
        id = 386208,
        duration = 3600,
        max_stack = 1
    },
    disarm = {
        id = 236077,
        duration = 6,
        max_stack = 1
    },
    elysian_might = {
        id = 386286,
        duration = 8,
        max_stack = 1,
        copy = 311193 -- Covenant version.
    },
    enrage = {
        id = 184362,
        duration = function() return talent.tenderize.enabled and 6 or 4 end,
        max_stack = 1,
    },
    enraged_regeneration = {
        id = 184364,
        duration = function () return state.talent.invigorating_fury.enabled and 11 or 8 end,
        max_stack = 1,
    },
    frenzy = {
        id = 335082,
        duration = 12,
        max_stack = 4,
    },
    gushing_wound = {
        id = 385042,
        duration = 6,
        tick_time = 2,
        max_stack = 1,
    },
    hamstring = {
        id = 1715,
        duration = 15,
        max_stack = 1,
    },
    hurricane = {
        id = 390581,
        duration = 6,
        max_stack = 6
    },
    indelible_victory = {
        id = 336642,
        duration = 8,
        max_stack = 1
    },
    intimidating_shout = {
        id = function () return talent.menace.enabled and 316593 or 5246 end,
        duration = function () return talent.menace.enabled and 15 or 8 end,
        max_stack = 1,
    },
    odyns_fury = {
        id = 385060,
        duration = 4,
        tick_time = 1,
        max_stack = 1
    },
    piercing_howl = {
        id = 12323,
        duration = 8,
        max_stack = 1,
    },
    quick_thinking = {
        id = 392778,
        duration = 10,
        max_stack = 1
    },
    raging_blow = {
        id = 85288,
        duration = 12,
        max_stack = 1
    },
    rallying_cry = {
        id = 97463,
        duration = 10,
        max_stack = 1,
    },
    ravager = {
        id = 228920,
        duration = 12,
        tick_time = 2,
        max_stack = 1
    },
    reckless_abandon = {
        id = 396752,
        duration = 12,
        max_stack = 1,
    },
    recklessness = {
        id = 1719,
        duration = function() return state.talent.depths_of_insanity.enabled and 16 or 12 end,
        max_stack = 1,
    },
    rend = {
        id = 388539,
        duration = 15,
        tick_time = 3,
        max_stack = 1
    },
    slaughtering_strikes_annihilator = {
        id = 393943,
        duration = 12,
        max_stack = 5
    },
    slaughtering_strikes_raging_blow = {
        id = 393931,
        duration = 12,
        max_stack = 5
    },
    spell_reflection = {
        id = 23920,
        duration = function () return legendary.misshapen_mirror.enabled and 8 or 5 end,
        max_stack = 1,
    },
    stance = {
        alias = { "battle_stance", "berserker_stance", "defensive_stance" },
        aliasMode = "first",
        aliasType = "buff",
        duration = 3600,
    },
    sudden_death = {
        id = 280776,
        duration = 10,
        max_stack = 1
    },
    taunt = {
        id = 355,
        duration = 3,
        max_stack = 1,
    },
    thunder_clap = {
        id = 6343,
        duration = 10,
        max_stack = 1
    },
    thunderous_roar = {
        id = 384318,
        duration = 8,
        tick_time = 2,
        max_stack = 1
    },
    victorious = {
            id = 32216,
            duration = 20,
            max_stack = 1,
        },
    war_machine = {
        id = 262232,
        duration = 8,
        max_stack = 1
    },
    whirlwind = {
        id = 85739,
        duration = 20,
        max_stack = function ()
            if talent.meat_cleaver.enabled then return 4
            elseif talent.improved_whirlwind.enabled or talent.titanic_rage.enabled then return 2
            else return 0
            end
        end,
        copy = "meat_cleaver"
    },
} )


spec:RegisterGear( "tier29", 200426, 200428, 200423, 200425, 200427 )
spec:RegisterSetBonuses( "tier29_2pc", 393708, "tier29_4pc", 393709 )
-- 2-Set - Execute’s chance to critically strike increased by 10%.
-- 4-Set - Sudden Death’s chance to reset the cooldown of Execute and make it usable on any target, regardless of health, is greatly increased.

spec:RegisterGear( "tier30", 202446, 202444, 202443, 202442, 202441 )
spec:RegisterSetBonuses( "tier30_2pc", 405579, "tier30_4pc", 405580 )
--(2) Rampage damage and critical strike chance increased by 10%.
--(4) Rampage causes your next Bloodthirst to have a 10% increased critical strike chance, deal 25% increased damage and generate 2 additional Rage. Stacking up to 10 times.
spec:RegisterAura( "merciless_assault", {
    id = 409983,
    duration = 14,
    max_stack = 10
} )

spec:RegisterGear( "tier31", 207180, 207181, 207182, 207183, 207185 )
spec:RegisterSetBonuses( "tier31_2pc", 422925, "tier31_4pc", 422926 )
-- (2) Odyn's Fury deals 50% increased damage and causes your next 3 Bloodthirsts to deal 150% additional damage and have 100% increased critical strike chance against its primary target.
-- (4) Bloodthirst critical strikes reduce the cooldown of Odyn's Fury by 2.5 sec.
spec:RegisterAura( "furious_bloodthirst", {
    id = 423211,
    duration = 20,
    max_stack = 3
} )
-- (4) Bloodthirst critical strikes reduce the cooldown of Odyn's Fury by 2.5 sec.


spec:RegisterGear( 'tier20', 147187, 147188, 147189, 147190, 147191, 147192 )
    spec:RegisterAura( "raging_thirst", {
        id = 242300,
        duration = 8
        } ) -- fury 2pc.
    spec:RegisterAura( "bloody_rage", {
        id = 242952,
        duration = 10,
        max_stack = 10
        } ) -- fury 4pc.

spec:RegisterGear( 'tier21', 152178, 152179, 152180, 152181, 152182, 152183 )
    spec:RegisterAura( "slaughter", {
        id = 253384,
        duration = 4
    } ) -- fury 2pc dot.
    spec:RegisterAura( "outrage", {
        id = 253385,
        duration = 8
    } ) -- fury 4pc.

spec:RegisterGear( "ceannar_charger", 137088 )
spec:RegisterGear( "timeless_stratagem", 143728 )
spec:RegisterGear( "kazzalax_fujiedas_fury", 137053 )
    spec:RegisterAura( "fujiedas_fury", {
        id = 207776,
        duration = 10,
        max_stack = 4
    } )
spec:RegisterGear( "mannoroths_bloodletting_manacles", 137107 ) -- NYI.
spec:RegisterGear( "najentuss_vertebrae", 137087 )
spec:RegisterGear( "valarjar_berserkers", 151824 )
spec:RegisterGear( "ayalas_stone_heart", 137052 )
    spec:RegisterAura( "stone_heart", { id = 225947,
        duration = 10
    } )
spec:RegisterGear( "the_great_storms_eye", 151823 )
    spec:RegisterAura( "tornados_eye", {
        id = 248142,
        duration = 6,
        max_stack = 6
    } )
spec:RegisterGear( "archavons_heavy_hand", 137060 )
spec:RegisterGear( "weight_of_the_earth", 137077 ) -- NYI.

spec:RegisterGear( "soul_of_the_battlelord", 151650 )

state.IsActiveSpell = IsActiveSpell

local whirlwind_consumers = {
    crushing_blow = 1,
    bloodbath = 1,
    bloodthirst = 1,
    execute = 1,
    impending_victory = 1,
    raging_blow = 1,
    rampage = 1,
    onslaught = 1,
    victory_rush = 1
}

local whirlwind_stacks = 0

local rageSpent = 0
local gloryRage = 0

local fresh_meat_actual = {}
local fresh_meat_virtual = {}

local last_rampage_target = nil

local TriggerColdSteelHotBlood = setfenv( function()
    applyDebuff( "target", "gushing_wound" )
    gain( 4, "rage" )
end, state )

local TriggerSlaughteringStrikesAnnihilator = setfenv( function()
    addStack( "slaughtering_strikes_annihilator" )
end, state )

local RemoveFrenzy = setfenv( function()
    removeBuff( "frenzy" )
end, state )

spec:RegisterCombatLogEvent( function(  _, subtype, _, sourceGUID, sourceName, sourceFlags, _, destGUID, destName, destFlags, _, spellID, spellName, school, amount, interrupt, a, b, c, d, critical )

    if sourceGUID == state.GUID then
        if subtype == "SPELL_CAST_SUCCESS" then
            local ability = class.abilities[ spellID ]

            if not ability then return end
            if state.talent.improved_whirlwind.enabled and ability.key == "whirlwind" then
                whirlwind_stacks = state.talent.meat_cleaver.enabled and 4 or 2
            elseif state.talent.titanic_rage.enabled and ( ability.key == "odyns_fury" or ( ability.key == "avatar" and state.talent.titans_torment.enabled ) ) then
                if state.talent.meat_cleaver.enabled then
                    whirlwind_stacks = 4
                else
                    whirlwind_stacks = 2 -- Titanic Rage gives 2 stacks of WW even if Imp. WW / Meatcleaver are untalented.
                end
            elseif whirlwind_consumers[ ability.key ] and whirlwind_stacks > 0 then
                whirlwind_stacks = whirlwind_stacks - 1
            elseif ability.key == "rampage" and last_rampage_target ~= destGUID and state.talent.frenzy.enabled then
                RemoveFrenzy()
                last_rampage_target = destGUID
            end

        elseif subtype == "SPELL_DAMAGE" and UnitGUID( "target" ) == destGUID then
            local ability = class.abilities[ spellID ]
            if not ability then return end
            if ability.key == "bloodthirst" or ability.key == "bloodbath" then
                if critical and state.talent.cold_steel_hot_blood.enabled then -- Critical boolean is the 21st parameter in SPELL_DAMAGE within CLEU (Ref: https://wowpedia.fandom.com/wiki/COMBAT_LOG_EVENT#Payload)
                    TriggerColdSteelHotBlood() -- Bloodthirst/bath critical strike occured.
                elseif state.talent.fresh_meat.enabled and not fresh_meat_actual[ destGUID ] then
                    fresh_meat_actual[ destGUID ] = true
                end
            end
        elseif subtype == "SWING_DAMAGE" and UnitGUID( "target" ) == destGUID then
            -- amt is the 12th parameter in SWING_DAMAGE within CLEU (Ref: https://wowpedia.fandom.com/wiki/COMBAT_LOG_EVENT#Payload)
            local amt = spellID
            if amt > 0 and state.talent.annihilator.enabled and state.talent.slaughtering_strikes.enabled then
                TriggerSlaughteringStrikesAnnihilator()
            end
        end
    end
end )


local wipe = table.wipe

spec:RegisterEvent( "PLAYER_REGEN_ENABLED", function()
    wipe( fresh_meat_actual )
end )

spec:RegisterHook( "UNIT_ELIMINATED", function( id )
    fresh_meat_actual[ id ] = nil
end )


local RAGE = Enum.PowerType.Rage
local lastRage = -1

spec:RegisterUnitEvent( "UNIT_POWER_FREQUENT", "player", nil, function( event, unit, powerType )
    if powerType == "RAGE" then
        local current = UnitPower( "player", RAGE )
        if current < lastRage - 3 then -- Spent Rage, -3 is used as a Hack to avoid Rage decay triggering
            if state.talent.anger_management.enabled then
                rageSpent = ( rageSpent + ( lastRage - current ) ) % 20
            end
            if state.legendary.glory.enabled and FindPlayerAuraByID( 324143 ) then
                gloryRage = ( gloryRage + lastRage - current ) % 25
            end
        end
        lastRage = current
    end
end )

spec:RegisterStateExpr( "rage_spent", function ()
    return rageSpent
end )

spec:RegisterStateExpr( "glory_rage", function ()
    return gloryRage
end )


spec:RegisterHook( "spend", function( amt, resource )
    if resource == "rage" then
        if talent.anger_management.enabled then
            rage_spent = rage_spent + amt
            local reduction = floor( rage_spent / 20 )
            rage_spent = rage_spent % 20
            if reduction > 0 then
                cooldown.recklessness.expires = cooldown.recklessness.expires - reduction
                cooldown.ravager.expires = cooldown.ravager.expires - reduction
            end
        end

        if legendary.glory.enabled and buff.conquerors_banner.up then
            glory_rage = glory_rage + amt
            local addition = floor( glory_rage / 10 ) * 0.5
            glory_rage = glory_rage % 10
		  if addition > 0 then buff.conquerors_banner.expires = buff.conquerors_banner.expires + addition end
        end
    end
end )


local WillOfTheBerserker = setfenv( function()
    applyBuff( "will_of_the_berserker" )
end, state )

local TriggerHurricane = setfenv( function()
    addStack( "hurricane" )
end, state )

spec:RegisterHook( "reset_precast", function ()
    rage_spent = nil
    glory_rage = nil

    if buff.whirlwind.up then
        if whirlwind_stacks == 0 then removeBuff( "whirlwind" )
        elseif whirlwind_stacks < buff.whirlwind.stack then
            applyBuff( "whirlwind", buff.whirlwind.remains, whirlwind_stacks )
        end
    end

    if legendary.will_of_the_berserker.enabled and buff.recklessness.up then
        state:QueueAuraExpiration( "recklessness", WillOfTheBerserker, buff.recklessness.expires )
    end

    wipe( fresh_meat_virtual )
    active_dot.hit_by_fresh_meat = 0

    for k, v in pairs( fresh_meat_actual ) do
        fresh_meat_virtual[ k ] = v

        if k == target.unit then
            applyDebuff( "target", "hit_by_fresh_meat" )
        else
            active_dot.hit_by_fresh_meat = active_dot.hit_by_fresh_meat + 1
        end
    end

    if buff.ravager.up and talent.hurricane.enabled then
        local next_hu = query_time + haste - ( ( query_time - buff.ravager.applied ) % haste )

        while ( next_hu <= buff.ravager.expires ) do
            state:QueueAuraEvent( "ravager_hurricane", TriggerHurricane, next_hu, "AURA_PERIODIC" )
            next_hu = next_hu + haste
        end
    end
end )




spec:RegisterStateExpr( "cycle_for_execute", function ()
    if active_enemies == 1 or target.health_pct < ( talent.massacre.enabled and 35 or 20 ) or not settings.cycle or buff.execute_ineligible.down or buff.sudden_death.up then return false end
    return Hekili:GetNumTargetsBelowHealthPct( talent.massacre.enabled and 35 or 20, false, max( settings.cycle_min, offset + delay ) ) > 0
end )


spec:RegisterStateExpr( "cycle_for_condemn", function ()
    if active_enemies == 1 or target.health_pct < ( talent.massacre.enabled and 35 or 20 ) or target.health_pct > 80 or not settings.cycle or not action.condemn.known or buff.condemn_ineligible.down or buff.sudden_death.up then return false end
    return Hekili:GetNumTargetsBelowHealthPct( talent.massacre.enabled and 35 or 20, false, max( settings.cycle_min, offset + delay ) ) > 0 or Hekili:GetNumTargetsAboveHealthPct( 80, false, max( settings.cycle_min, offset + delay ) ) > 0
end )


-- Abilities
spec:RegisterAbilities( {
    avatar = {
        id = 107574,
        cast = 0,
        cooldown = 90,
        gcd = "off",

        spend = -10,
        spendType = "rage",

        talent = "avatar",
        startsCombat = false,
        texture = 613534,

        toggle = "cooldowns",

        handler = function ()
            applyBuff( "avatar" )
            if talent.berserkers_torment.enabled then applyBuff( "recklessness", 8 ) end
            if talent.titans_torment.enabled then
                applyBuff( "odyns_fury" )
                active_dot.odyns_fury = max( active_dot.odyns_fury, active_enemies )
                if talent.titanic_rage.enabled then
                    applyBuff ( "enrage" )
                    applyBuff ( "whirlwind", nil, talent.meat_cleaver.enabled and 4 or 2 )
                end
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

        essential = true,
        nobuff = "battle_shout",

        handler = function ()
            applyBuff( "battle_shout" )
        end,
    },


    berserker_rage = {
        id = 18499,
        cast = 0,
        cooldown = 60,
        gcd = "off",

        toggle = "cooldowns",
        talent = "berserker_rage",
        startsCombat = false,
        texture = 136009,

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


    berserker_stance = {
        id = 386196,
        cast = 0,
        cooldown = 3,
        gcd = "off",

        talent = "berserker_stance",
        startsCombat = false,
        essential = true,

        nobuff = "stance",

        handler = function ()
            applyBuff( "berserker_stance" )
            removeBuff( "defensive_stance" )
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


    bloodbath = {
        id = 335096,
        known = 23881,
        flash = 23881,
        cast = 0,
        cooldown = function () return ( 3 - talent.deft_experience.rank * 0.75 ) * haste end,
        gcd = "spell",

        spend = function() return -8 - ( 2 * buff.merciless_assault.stack ) + ( talent.seethe.enabled and action.bloodbath.crit_pct_current >= 100 and -2 or 0 ) end,
        spendType = "rage",

        cycle = function () return talent.fresh_meat.enabled and "hit_by_fresh_meat" or nil end,

        startsCombat = true,
        texture = 236304,
        buff = "reckless_abandon",
        bind = "bloodthirst",

        critical = function()
            return stat.crit + ( 15 * buff.bloodcraze.stack ) + ( 10 * buff.merciless_assault.stack ) + ( 20 * buff.recklessness.stack ) + ( buff.furious_bloodthirst.up and 100 or 0 )
        end,

        handler = function ()
            removeStack( "whirlwind" )
            removeBuff( "reckless_abandon" )

            if talent.cold_steel_hot_blood.enabled and action.bloodthirst.crit_pct_current >= 100 then
                applyDebuff( "target", "gushing_wound" )
                gain( 4, "rage" )
            end

            if set_bonus.tier31_4pc > 0 and action.bloodthirst.crit_pct_current >= 100 then
                reduceCooldown( "odyns_fury", 2.5 )
            end

            removeBuff( "merciless_assault" )
            if talent.bloodcraze.enabled then
                if action.bloodthirst.crit_pct_current >= 100 then removeBuff( "bloodcraze" )
                else addStack( "bloodcraze" ) end
            end

            gain( health.max * ( buff.enraged_regeneration.up and 0.23 or 0.03 ) , "health" )

            if talent.fresh_meat.enabled and debuff.hit_by_fresh_meat.down then
                applyBuff( "enrage" )
                applyDebuff( "target", "hit_by_fresh_meat" )
            end
            if talent.invigorating_fury.enabled then gain ( health.max * 0.15 , "health" ) end

            if legendary.cadence_of_fujieda.enabled then
                if buff.cadence_of_fujieda.stack < 5 then stat.haste = stat.haste + 0.01 end
                addStack( "cadence_of_fujieda" )
            end
        end,
    },


    bloodrage = {
        id = 329038,
        cast = 0,
        cooldown = 20,
        gcd = "off",

        spend = function() return 0.05 * health.max end,
        spendType = "health",

        pvptalent = "bloodrage",
        startsCombat = false,
        texture = 132277,

        handler = function ()
            applyBuff ( "bloodrage" )
        end,
    },


    bloodthirst = {
        id = 23881,
        cast = 0,
        cooldown = function () return ( 4.5 - talent.deft_experience.rank * 0.75 ) * haste end,
        gcd = "spell",

        spend = function() return -8 - ( 2 * buff.merciless_assault.stack ) + ( talent.seethe.enabled and action.bloodthirst.crit_pct_current >= 100 and -2 or 0 ) end,
        spendType = "rage",

        cycle = function () return talent.fresh_meat.enabled and "hit_by_fresh_meat" or nil end,

        talent = "bloodthirst",
        texture = 136012,
        nobuff = "reckless_abandon",
        startsCombat = true,
        bind = "bloodbath",

        critical = function()
            return stat.crit + ( 15 * buff.bloodcraze.stack ) + ( 10 * buff.merciless_assault.stack ) + ( 20 * buff.recklessness.stack ) + ( buff.furious_bloodthirst.up and 100 or 0 )
        end,

        handler = function ()
            removeStack( "whirlwind" )

            if talent.cold_steel_hot_blood.enabled and action.bloodthirst.crit_pct_current >= 100 then
                applyDebuff( "target", "gushing_wound" )
                gain( 4, "rage" )
            end

            if set_bonus.tier31_4pc > 0 and action.bloodthirst.crit_pct_current >= 100 then
                reduceCooldown( "odyns_fury", 2.5 )
            end

            removeBuff( "merciless_assault" )
            if talent.bloodcraze.enabled then
                if action.bloodthirst.crit_pct_current >= 100 then removeBuff( "bloodcraze" )
                else addStack( "bloodcraze" ) end
            end

            gain( health.max * ( buff.enraged_regeneration.up and 0.23 or 0.03 ) , "health" )

            if talent.fresh_meat.enabled and debuff.hit_by_fresh_meat.down then
                applyBuff( "enrage" )
                applyDebuff( "target", "hit_by_fresh_meat" )
            end

            if talent.invigorating_fury.enabled then gain ( health.max * 0.2 , "health" ) end

            if legendary.cadence_of_fujieda.enabled then
                if buff.cadence_of_fujieda.stack < 5 then stat.haste = stat.haste + 0.01 end
                addStack( "cadence_of_fujieda" )
            end
        end,

        auras = {
            cadence_of_fujieda = {
                id = 335558,
                duration = 12,
                max_stack = 5,
            },
            hit_by_fresh_meat = {
                duration = 3600,
                max_stack = 1,
            }
        },
    },


    charge = {
        id = 100,
        cast = 0,
        charges = function () return talent.double_time.enabled and 2 or nil end,
        cooldown = function () return talent.double_time.enabled and 17 or 20 end,
        recharge = function () return talent.double_time.enabled and 17 or 20 end,
        gcd = "off",

        spend = -20,
        spendType = "rage",

        startsCombat = true,
        texture = 132337,

        usable = function () return target.minR > 8 and ( query_time - action.charge.lastCast > gcd.execute ), "target too close" end,
        handler = function ()
            applyDebuff( "target", "charge" )
            setDistance( 5 )
        end,
    },


    crushing_blow = {
        id = 335097,
        known = 85288,
        flash = 85288,
        cast = 0,
        charges = function () return
              ( talent.raging_blow.enabled and 1 or 0 )
            + ( talent.improved_raging_blow.enabled and 1 or 0 )
            + ( talent.raging_armaments.enabled and 1 or 0 )
        end,
        cooldown = function() return 7 * haste end,
        recharge = function() return 7 * haste end,
        gcd = "spell",

        spend = function () return -12 - talent.swift_strikes.rank end,
        spendType = "rage",

        startsCombat = true,
        texture = 132215,

        talent = "reckless_abandon",
        buff = "reckless_abandon",
        notalent = "annihilator",
        bind = "raging_blow",

        handler = function ()
            removeStack( "whirlwind" )
            removeBuff( "reckless_abandon" )
            spendCharges( "raging_blow", 1 )
            if buff.will_of_the_berserker.up then buff.will_of_the_berserker.expires = query_time + 12 end
        end,
    },


    death_wish = {
        id = 199261,
        cast = 0,
        cooldown = 5,
        gcd = "spell",

        spend = 6777,
        spendType = "health",

        pvptalent = "death_wish",
        startsCombat = false,
        texture = 136146,

        handler = function ()
            addStack( "death_wish" )
        end,
    },


    defensive_stance = {
        id = 386208,
        cast = 0,
        cooldown = 3,
        gcd = "off",

        talent = "defensive_stance",
        startsCombat = false,
        nobuff = "stance",

        handler = function ()
            applyBuff( "defensive_stance" )
            removeBuff( "berserker_stance" )
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


    enraged_regeneration = {
        id = 184364,
        cast = 0,
        cooldown = function () return 120 - ( conduit.stalwart_guardian.enabled and 20 or 0 ) end,
        gcd = "off",

	    toggle = "defensives",

        talent = "enraged_regeneration",
        startsCombat = false,
        texture = 132345,

        handler = function ()
            applyBuff( "enraged_regeneration" )
        end,
    },


    execute = {
        id = function () return IsActiveSpell( 280735 ) and 280735 or 5308 end,
	    known = 5308,
        noOverride = 317485,
        cast = 0,
        cooldown = function () return ( talent.massacre.enabled and 4.5 or 6 ) end,
	    hasteCD = true,
        gcd = "spell",

        spend = function () return ( talent.improved_execute.enabled and -20 or 0 ) end,
        spendType = "rage",

        startsCombat = true,
        texture = 135358,

        usable = function ()
            if buff.sudden_death.up then return true end
            if cycle_for_execute then return true end
            return target.health_pct < ( talent.massacre.enabled and 35 or 20 ), "requires target in execute range"
        end,

        cycle = "execute_ineligible",

        indicator = function () if cycle_for_execute then return "cycle" end end,

        timeToReady = function()
            -- Instead of using regular resource requirements, we'll use timeToReady to support the spend system.
            if talent.improved_execute.enabled then
                return 0 -- We gain rage when using excute with this talent
            elseif rage.current >= 20 then
                return 0
            else
                return rage.time_to_20
            end
        end,

        handler = function ()
            if not buff.sudden_death.up and not buff.stone_heart.up and not talent.improved_execute.enabled then -- Execute costs rage
                local cost = min( rage.current, 40 )
                spend( cost, "rage", nil, true )
            else
                removeBuff( "sudden_death" )
            end

            removeStack( "whirlwind" )
            if talent.ashen_juggernaut.enabled then applyBuff( "ashen_juggernaut" ) end
        end,

        copy = { 280735, 5308 },

        auras = {
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
        cooldown = function () return talent.bounding_stride.enabled and 30 or 45 end,
        charges = function () return legendary.leaper.enabled and 3 or nil end,
        recharge = function () return legendary.leaper.enabled and ( talent.bounding_stride.enabled and 30 or 45 ) or nil end,
        gcd = "off",

        talent = "heroic_leap",
        startsCombat = false,
        texture = 236171,

        usable = function () return ( query_time - action.heroic_leap.lastCast > gcd.execute ) end,
        handler = function ()
            setDistance( 15 ) -- probably heroic_leap + charge combo.
            if talent.bounding_stride.enabled then applyBuff( "bounding_stride" ) end
        end,

        copy = 52174
    },


    heroic_throw = {
        id = 57755,
        cast = 0,
        cooldown = 1,
        gcd = "spell",

        startsCombat = true,
        texture = 132453,

        handler = function ()
        end,
    },


    impending_victory = {
        id = 202168,
        cast = 0,
        cooldown = 25,
        gcd = "spell",

        spend = 10,
        spendType = "rage",

        startsCombat = true,
        texture = 589768,

        talent = "impending_victory",

        handler = function ()
            gain( health.max * 0.3, "health" )
            removeStack( "whirlwind" )
            if conduit.indelible_victory.enabled then applyBuff( "indelible_victory" ) end
        end,
    },


    intervene = {
        id = 3411,
        cast = 0,
        cooldown = 30,
        gcd = "off",

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


    odyns_fury = {
        id = 385059,
        cast = 0,
        cooldown = 45,
        gcd = "spell",

        talent = "odyns_fury",
        startsCombat = false,
        texture = 1278409,

        handler = function ()
            applyDebuff( "target", "odyns_fury" )
            active_dot.odyns_fury = max( active_dot.odyns_fury, active_enemies )
            if pvptalent.slaughterhouse.enabled then applyDebuff( "target", "slaughterhouse", nil, debuff.slaughterhouse.stack + 1 ) end
            if talent.dancing_blades.enabled then applyBuff( "dancing_blades" ) end
            if talent.titanic_rage.enabled then
                applyBuff( "enrage" )
                applyBuff( "whirlwind", nil, talent.meat_cleaver.enabled and 4 or 2 )
            end
            if talent.titans_torment.enabled then applyBuff( "avatar", 4 ) end

            if state.spec.fury and set_bonus.tier31_2pc > 0 then
                applyBuff( "furious_bloodthirst", nil, 3 )
            end
        end,
    },


    onslaught = {
        id = 315720,
        cast = 0,
        cooldown = 18,
        hasteCD = true,
        gcd = "spell",

        spend = -30,
        spendType = "rage",

        talent = "onslaught",
        startsCombat = true,
        texture = 132364,

        handler = function ()
            removeStack( "whirlwind" )
            if pvptalent.slaughterhouse.enabled then applyDebuff( "target", "slaughterhouse", nil, debuff.slaughterhouse.stack + 1 ) end
            if talent.tenderize.enabled then
                applyBuff( "enrage" )
            end
        end,
    },


    piercing_howl = {
        id = 12323,
        cast = 0,
        cooldown = function () return 30 - ( conduit.disturb_the_peace.enabled and 5 or 0 ) end,
        gcd = "spell",

        talent = "piercing_howl",
        startsCombat = true,
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
            interrupt()
            if talent.concussive_blows.enabled then
                applyDebuff( "target", "concussive_blows" )
            end
        end,
    },


    raging_blow = {
        id = 85288,
        cast = 0,
        charges = function () return
            ( talent.raging_blow.enabled and 1 or 0 )
          + ( talent.improved_raging_blow.enabled and 1 or 0 )
          + ( talent.raging_armaments.enabled and 1 or 0 )
        end,
        cooldown = function() return 8 * state.haste end,
        recharge = function() return 8 * state.haste end,
        gcd = "spell",

        spend = function () return -12 - talent.swift_strikes.rank end,
        spendType = "rage",

        talent = "raging_blow",
        texture = 589119,
        notalent = "annihilator",
        startsCombat = true,
        nobuff = "reckless_abandon",
        bind = "crushing_blow",

        handler = function ()
            removeStack( "whirlwind" )
            spendCharges( "crushing_blow", 1 )
            if buff.will_of_the_berserker.up then buff.will_of_the_berserker.expires = query_time + 12 end
            if talent.slaughtering_strikes.enabled then addStack( "slaughtering_strikes_raging_blow" ) end
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


    rampage = {
        id = 184367,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = 80,
        spendType = "rage",

        startsCombat = true,
        texture = 132352,
        talent = "rampage",

        handler = function ()
            applyBuff( "enrage" )
            removeStack( "whirlwind" )
            if pvptalent.slaughterhouse.enabled then applyDebuff( "target", "slaughterhouse", nil, debuff.slaughterhouse.stack + 1 ) end
            if talent.frenzy.enabled then addStack( "frenzy" ) end
            if talent.reckless_abandon.enabled then applyBuff( "reckless_abandon" ) end
            if set_bonus.tier30_4pc > 0 then addStack( "merciless_assault" ) end
        end,
    },


    ravager = {
        id = 228920,
        cast = 0,
        charges = function () return ( talent.storm_of_steel.enabled and 2 or 1 ) end,
        cooldown = 90,
        recharge = 90,
        gcd = "spell",

        talent = "ravager",
        startsCombat = true,
        texture = 970854,

        toggle = "cooldowns",

        handler = function ()
            applyBuff( "ravager" )
        end,
    },


    recklessness = {
        id = 1719,
        cast = 0,
        cooldown = 90,
        gcd = "off",

        toggle = "cooldowns",

        talent = "recklessness",
        startsCombat = false,
        texture = 458972,

        handler = function ()
            applyBuff( "recklessness" )
            if talent.reckless_abandon.enabled then
                gain( 50, "rage" )
            end
            if talent.berserkers_torment.enabled then applyBuff( "avatar", 8 ) end
            if legendary.will_of_the_berserker.enabled then
                state:QueueAuraExpiration( "recklessness", WillOfTheBerserker, buff.recklessness.expires )
            end
        end,

        auras = {
            will_of_the_berserker = { -- Shadowlands Legendary
                id = 335597,
                duration = 12,
                max_stack = 1
            }
        }
    },

    shattering_throw = {
        id = 64382,
        cast = 1.5,
        cooldown = 180,
        gcd = "spell",

        talent = "shattering_throw",
        startsCombat = true,
        texture = 311430,

        range = 30,
        toggle = "cooldowns",
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
        texture = 236312,

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


    slam = {
        id = 1464,
        cast = 0,
        cooldown = function () return talent.storm_of_swords.enabled and 9 or 0 end,
        gcd = "spell",

        spend = 20,
        spendType = "rage",

        startsCombat = true,
        texture = 132340,

        handler = function ()
            removeStack( "whirlwind" )
        end,
    },


    storm_bolt = {
        id = 107570,
        cast = 0,
        cooldown = 30,
        gcd = "spell",

        startsCombat = true,
        texture = 613535,

        talent = "storm_bolt",

        handler = function ()
            applyDebuff( "target", "storm_bolt" )
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
        id = 6343,
        cast = 0,
        cooldown = 6,
        gcd = "spell",
        hasteCD = true,

        spend = function() return 30 + ( talent.blood_and_thunder.enabled and 10 or 0 ) end,
        spendType = "rage",

        talent = "thunder_clap",
        startsCombat = true,
        texture = 136105,

        handler = function ()
            applyDebuff( "target", "thunder_clap" )
            active_dot.thunder_clap = max( active_dot.thunder_clap, active_enemies )
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
            applyDebuff( "target", "thunderous_roar" )
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

        notalent = "impending_victory",
        buff = "victorious",

        handler = function ()
            removeBuff( "victorious" )
            removeStack( "whirlwind" )
            gain( 0.2 * health.max, "health" )
            if conduit.indelible_victory.enabled then applyBuff( "indelible_victory" ) end
        end,
    },


    whirlwind = {
        id = 190411,
        cast = 0,
        cooldown = function () return ( talent.storm_of_swords.enabled and 7 * haste or 0 ) end,
        gcd = "spell",

        startsCombat = true,

        -- TODO: Find a way to calculate the extra 1 rage per extra target hit?
        spend = function() return talent.improved_whirlwind.enabled and ( -3 - min( 5, active_enemies ) ) or 0 end,
        spendType = "rage",

        texture = 132369,

        usable = function ()
            if action.taunt.known and action.heroic_throw.known and settings.check_ww_range and not ( action.taunt.in_range and not action.heroic_throw.in_range ) then return false, "target is outside of whirlwind range" end
            return true
        end,

        handler = function ()
            if talent.improved_whirlwind.enabled then
                applyBuff ( "whirlwind", nil, talent.meat_cleaver.enabled and 4 or 2 )
            end
        end,
    },


    wrecking_throw = {
        id = 384110,
        cast = 0,
        cooldown = function () return pvptalent.demolition.enabled and 22.5 or 45 end,
        gcd = "spell",

        talent = "wrecking_throw",
        startsCombat = true,
        texture = 460959,

        handler = function ()
        end,
    },
} )


spec:RegisterSetting( "check_ww_range", false, {
    name = "Check |T132369:0|t Whirlwind Range",
    desc = "If checked, when your target is outside of |T132369:0|t Whirlwind's range, it will not be recommended.",
    type = "toggle",
    width = "full"
} )

spec:RegisterSetting( "shockwave_interrupt", true, {
    name = "Only |T236312:0|t Shockwave as Interrupt (when Talented)",
    desc = "If checked, |T236312:0|t Shockwave will only be recommended when your target is casting.",
    type = "toggle",
    width = "full"
} )


spec:RegisterSetting( "t30_bloodthirst_crit", 95, {
    name = strformat( "%s Critical Threshold (Tier 30)", Hekili:GetSpellLinkWithTexture( spec.abilities.bloodthirst.id ) ),
    desc = strformat( "By default, if you have four pieces of Tier 30 equipped, |W%s|w and |W%s|w will be recommended when their chance to crit is |cFFFFD10095%%|r or higher.\n\n"
            .. "Your tier set, %s, and %s can bring you over the 95%% threshold. If |W%s|w is talented, these crits will proc a %s for additional damage. "
            .. "Lowering this percentage slightly may be helpful if your base Critical Strike chance is very low. However, if set too low, you may use these abilities but "
            .. "fail to crit.",
            spec.abilities.bloodthirst.name, spec.abilities.bloodbath.name, Hekili:GetSpellLinkWithTexture( spec.talents.recklessness[2] ),
            Hekili:GetSpellLinkWithTexture( spec.talents.bloodcraze[2] ), Hekili:GetSpellLinkWithTexture( spec.talents.cold_steel_hot_blood[2] ),
            Hekili:GetSpellLinkWithTexture( spec.auras.gushing_wound.id ) ),
    type = "range",
    min = 0,
    max = 100,
    step = 1,
    width = "full",
} )

spec:RegisterStateExpr( "bloodthirst_crit_threshold", function()
    return settings.t30_bloodthirst_crit or 95
end )

spec:RegisterSetting( "heroic_charge", false, {
    name = "Use Heroic Charge Combo",
    desc = "If checked, the default priority will check |cFFFFD100settings.heroic_charge|r to determine whether to use Heroic Leap + Charge together.\n\n" ..
        "This is generally a DPS increase but the erratic movement can be disruptive to smooth gameplay.",
    type = "toggle",
    width = "full",
} )



local LSR = LibStub( "SpellRange-1.0" )

spec:RegisterRanges( "hamstring", "bloodthirst", "execute", "storm_bolt", "charge", "heroic_throw", "taunt" )

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

spec:RegisterPack( "Fury", 20240116, [[Hekili:D3ZFZnUTY9zXtM4t6L7KfPTV7s6zptEPTtZnVMxN6R9pffTeLf7rrQsszFoJh9zVla4paa3faKsYjV(hXrhXIDxS)clawcoZB2xMD3YWYOz)M)u)RM659(jEF46pCL3S7kFEB0S72gU4RHpa)inCd83)1D5pZE4ZjzHlzDUiBx(cOH1LLBl(PlU4H4Y17UFYISnxueVzxsyzCw6I8WvLS)9IlMD397Itk)10z3Jt5z3fURCDw(S7UlEZVaioE5Yib0rflMDhd63n17DEx9t7NVF()sAXU8O9Z)5hdldZ3ppUy)8DB3p)(OvzSN)L17sxgLNTdE()zwy(K9FE)NbCC5788EN)haC8xJFy)8WVfP2Iph7)xBzS4(5Lz7NZyhfy8UMdZpNKK9uld8eiaaYgxgM(gGMFjlFtuAjWq7kfnMX(XFF5Z8MzYtfKo9JCK(VhNMbidezSHdJjkubtq7)JWYfa18MoXVT5PFaGqL9ZJt)AujqVvmScG7n5APoC978NY7WxeaEXV8pxtwfOQK5)8YLaRLedY1km(Ly2pVC6(5lYJHH33dThvwgN(Gs)NELeBbCtEeyFeTuiFRXHApu1dTSFlqx(o)3Zb6xtxKSBja1DBJssa1D0QKOfm7V)jgP2K9i02)gyleVy)8)wu42jGLCE2Q4eW(nKdyXKT5rGT79HL)WnxCFuEru(xJYdkaT5IO9FgfQWYYKOGcUIffIDfrbXLrBElZh6MWKhIkxhMhSD3V)7qhVp7B4DlKBr924v3CwzycyenPKzvveuwztH2l4NFnjQOif(p5(w)8GW7dtxMLI37hdZJdVpjsWQv2nbEbrFJlBF7JHj7AEoOgIlMKV7(NdEADuYwqgac(xErP5NwhxSncEYdbXPlcZtbfzq8I(Xa(emGVzgW3cd8Dq8dgcfwJHYoklYYswM9u6B3pFz8JGPoyLE)ZaqvU5mdXmWjM5tTdIQm)xxbbFkz(0CwC)81HWVtZ4MEHXPCNL8OYD5PGjmG2OKIO2NmL7q6UeXlO450fVnB7nGJw8Qk5IN4)hWW9nakFlmmxgZWPKodySaMj597wT68rTpVEipz5UCEy7V)7BEKyy30YntL1YM6ixgfSIfMRTZJ7Zi1FOJuFIrQ)qhPM74Hps94mArhNm5HXlVmsTb2dNuuMhL(q5AzTstJBclkJYFgTThHqCaRMexI3(AwFrBHfO)8ZQhit6eQOxJCF0rUp1i330i33Wi33Yi3NCK7BDK7pOr(284maFpRBF7lBF7jzDJjY5cVZr4iEdV8cvlNpYOtrBBW0KlMeM(CWYTfnTp(VmcsJ4hmOuaiqinZDE84Bhzm0tBBUqBexbmA7vr7(OG8c2eMUlmbBQpNNkNYQhf1(KOUb5akxan(qeBg(Y4nrFIfd8Lxy54WsnyYYyrkl3EnmlhmnxB)wZtakibY)H15r5HXldIEK1PU92)6ZXApo92RUESm3SD3MnrjYpPGLewqEtoykqNP)KfHaWI)zqcqDfbvHmK5qa6hI4Pf1y1iNZZeX0TfF6YxEHBqO0iS0ajCLe)W6YIG)NDlFGnUy4SBxyuqUtvzfc5tGdVkjUpjlBjFwb5NUkopI3I8dzsCW6nmjGjnuAPjtq0ebpNZerP5GGbiVSklC5YcM6Y76ZpJdv10BauJQZmSDIRxEbB2Skb6yiyOOdn5ftYb60cLJE5f88Ap)mA6mctEZymWxGHNnraOblJJ(K)ufd0oPfRZsrFdm7GiIv0omnnEDmS8KS8ZBekGp3MTmegaw3WiR2uZtsWvnORA62RM2omfnHYTE(dIBpRl3sGETqhYdJgZ4w93iHCgu)XWkNd4MQLRJZlkzTIQ1gtPoj0oV8cJHEeMHlnAtCuXTGq8mygqisx6Uca4O8l9c83UymU1JI4AxA3GhB2LughiO9Bb)Q4fLWePWyvJU34BfvfGZoed2kUUXtkg9ezgarNs4t0vQywFQtMwhxKXQNIUdMgGPWHibISLIcldwatmaPgX9QuDIXdNoMKrG1DLN8eSWhgFiMnq0gFjzIMAzO4nW88pgTmOPTZj4QUYTp53xSqY0rFlAXUYOgxIqyfLPWeepat5KgUJB(J3qDSGhwSKe7LnBgvqEgUJNUmxn2X54UyJpFePagtGbgA06nlgqUmxdjU5bsGuIwZTjuD2NgC12fNl64e5ioS8Td2Ua0F7YHC7kV9MF0cfeDKNEZHqeiK2iQTp5CtbivLr0I6f57kwZ2ycO)pjn9(tqsURda6WvdAOZzBx79qvvFqA2CykLWhIOsjQk4rf2L8varm7r365nT2jgCGZzBNZgMKH144AG(40ghGUaztU4MrPMqGs7FgQMYvRszIWsAGT02UPDCw)I3cpkjChKqR8U(jJp1Hwt2CLrSysX)oTac6HSrQyLhstM4OqOJ1(qrePctil7PUPdB5MjGR66EYneYAwMfM98iBhSk2ifBrYIWUa2f20nbR90eKtDsjHR)HjxcDU(iNmHo6vJEpsptIENrqZAFwcRevO3cxgviyr1N1WGslItfc5nzrNXLMROXOeg5SDdbESP15rojc)jW033(XRnq4tq6hOK4px5Fa53VmRCYdvEJpLbjHwl9QePTRiCdBlryZZmqXiFjB0D9pNza3XZsEQu3N2uhndk9UQGm4Aw3J14g(ic)04QvSJD47blHiERBC4Ub84yXkyuEY6OWeOnMR3Lxxh6Ctyrr4I8OM1UkbL8(Y4qKHo29NMidoK7SDEvpkMvY5OlMBjKynNuJdan10N6QmboGTf2gMqsp23HKM74b6hm0CvT67AbtdKDpWuzTY1UA6mCM3wMUde3u6rRMZ0a4sIWK6hN40EOygMurcohsw2aimlag7uUo3eBxWMEfMEpPKLD(31uGqTNit9zRX27u16Cz1Z5HjmlHY1rblZJc3KZNYKn6z5JSjm)RbzRcQHdMrNZtMrn7hzRwfaX2VXJSGA4Mm2oDOrujFsSx(F6YXQYG5FzDBXvvx5xLSNTgYIkc0rZH)eVruJt8d57TmWyfN09auWybE(kU2Co4VSF(2W4C2ZeOsuszt6JaPijRS(yZ4Bqn5PfJDoYIJJSE)GBp(gPdQnSOmGTt03YpxdSNpwpfo4b0hwUewehGCTWhTSlAYATdcRph9B8glxUcOhE8T3SILLBqf2gQ81hv(6tkF9TkF9jKV(9w(6HiF9iKVE9s(6pwwZ4M897eLhvwAYZS)gX(d38xY7HTy74Lv1HfBa(2AiyouzWFZfDRHz3p)VZk4taXPrXI2TJT7ZyEwQ4zG6FU)fD5yy0bJSxyfKrJwbZMI3TXkLfKKXI(jXs60sEcMGH02Ofqem1m37NOYhxu5KVcDXRyYaMucpwPoICtu5)AiQyOiyDOypUOTqm53o2G4Yu80XvZU)Fx1xPqI1OJX9QvXciq2MWsIk9HQcyH1h5dd98ruN7p(Xzp2fYYGVkYckzV9gFqkGtGU7eq15OR)46tV)6XZUJvOyap1uN6xn7UNcZzd7Iz3XZaiEZ2S8YQQt(nk5q9gwfE()UtmREr2gaAyb2zvPeaz1c5EWQS7)wmlQiRQT)LSuGI8MFd5or(grjttdq9I1aah59TXVIu4sCkOU7GAyxBZfF1X8v4ywpXqnCR3mf2Fpo21xeMg21BMc7FKG35rM05yr4Q(Hj1nAtdJQnsH5FKaZ1BHMosRFoPv8uCeQUYtnSQ2ijQj8qQ3fenKQV5iDqN)jv57DATC9oTMUuO)yOgPClAx0FhzstlKiLWo(iWV(NolAFcl6JbQpTw3(er8pgCoHP3aTp2)zKebwgTkCxsFtbGqKEeIctH62ZrudTs1aAprz3k3ud1DbOVK4ekqoMCpHj8aTZSG0(pNp9eihc)D9PtLDkqnQ3Bt573p)xc55bXFcmtmYpsXA7epSzrMiVHDn0OcOskOCNeKVLE40Ye4ke9deef9nhSdTOGYDs4(4Yk4MtwVryk)otHi80A2rK25f0bbZyWCsr)jdX)bX3zGMNdrbemkLwT1UZxyO3T3Lrl9e)Lz0I5Kf(AWSLnUQrE2j)8gprJofDAwr7tJu7AFCyoPO)KH4)G4BANcQ3Vxm07OtXqEdFTyozHVgmBzJRAtzQZslpgtvybR8TsV(vXKa16WCSX)HW6vV5WM48wqoYy)q47hBFRMnX7QGDcOYHmg4V51M4(AaoQy(q4ywXBAIHRA)yIxs2TZU90ex(aMd0cwn7nIdZXg)hcRt5pIcYrg7hcFBYpKeStavoKXaUpjcahvmFiCmQxz32pM4LKD7SdwnODyzHDQXVlygTMsqWofCUocCLombFWaWVRrUmhz8WXFVnEg66Ap143fm7MsLgoxhbUsNHz84EsUdZ4XD87QXtNLPDIUNAqxleLZQ2TeJM)GJ3onOBjbLgwNIEwPy9DstT8)vuUDXRUC7ItGCR1KSZXI0yTJFH6GyYtcOQXFND5VcduxDpirMTrj(rsSkJD5sYkk65HGKc8TEkIDRwUJx5Wm)mE1rkQAQ9Zz3yf130KC4sZ4NNXUufOxYE9vNVmSm8(WIOFA)N3p)Dv3CJ4NfsfBZkUMECuieNU2rQ2eOv2n1Qh2KksT9hb6eEs1(fetyl1SJiTXrRQW1qqmciNqKBfTUpdQtZuF4KX4e10(70wh(0whVsOZZSXwNMDePwThqb5eICRO19C9DYy7WjJrJToh07b5jEsrUv0oWWNhz0rFYZwh02TLpUi3kAhymIJm6OoZ7HnOpPi3kAhMPVJ88Wq(eIeXKV7mEZXizm57bS3OMiMCtoNeMORN(Yj)isbI6Qzaft1PO2KeyMOAwps1(ZPRSwjl5Wh1U9M0WEN2)JJaef01rs0tH(JHSNYW(GkTVJBDZAgPd)9dOt04JNuLWv8yG6tNFiv5LFKSIpLLy(XTav3)5FLpHkdvVxDJtyZvo7o(V4FytKFnUGh8B8VvkviC2FD2DS9lbScdbqXV5z2p)wqPUF(5a)jyn6jL4qDM4vvTZfm18xEbMRVZRs3(5FcKpho(R)4xm7UMUnRC2V5toE5ib5sJHte8gRsSHZYpSy5KnHFRLSv3gkmIEjjrhvH62BMfg1GNAr6tj7yTE9(5JRrtLie)fgRDKHFpyXhxxli2zwXfqZXTJ(263HjaUIua0yEJV)y1JdoxQDBQiymzXhI(OwujUUC4cOpETcNwDdBWyZRPDgqUWR48MalgV0RaIEdKoY1TKS5(3Gr03BY44yqxUQHjfgjRgPIc2AuqCnE00EhBwa5KxjxskRUxlx6gpsuKjH(GRQf(10fHy(JMD87myeE81V206obQPmxhhQEMC0SFL8kpqN72rO2fpgBC(JopozKHk3djh56BnmgY9MAZrgF(pkJMZmAQ1Yekx0mCgHEEREtgdb4vcYGDTHbHAUrkwtDqxT7DkUQ7YRLNuRZ9pvL6aRN(tvu6stS4rpDMlU5VAbw9ONbuvDHpkh80h4mdpmVoDKWpdg6OYi2xUiRBdpG7Iqe2YJo4hIXYNSzMHlqOJnQLFcB7CAMlHoZufNUogxJRJe6Q3V20bE0H4QUqT6MJQnzU01Dfplr64C9Ke9AG2jmNVBH5Avld0kZ3sAXdYCFGdz6qf2gC9IWAgv(0Xyu040MmkrvQ9UuJQ4thvH2zQfPSR6noA(GmPAvKAe7JQmul3QbhT7KRYYokXlN2HdRe1Q0(spz4AxOMgu(kqPClVPd6LYG2ErVPcwj7ZUj)1yEMXLaZoJaXm8tNuToOoFnH4Mfs52lSwMvVuZ6hl(ucPZTkmR2NwinyVsbBziqOV6Lgos7RqKy7aceF6tR2V(IzgxjI0w539wNtmTJusdAr8Lnc5FLJMzmN(UOGr5wKO95nAM9C7j5N2p6rZQZCwXMvS(vTmdumTB(KhPdLIHT63ajDqTMdh16jWZP2WkhKcpkTYMZ1wzy3xqEHUTXiO7xrPMLywHc6xLCBReqLVmmwuNTZGi6mx5kJzdxLSL0NRgXgvPMAUG7NzoJ3Z6oUexytTRFWyIvn6bIpCtCgZttNPENEXLIxn12QAnmW98vZ1xsMnZCk7Mh(NzE4BKJmWo07Sd(Q)hzFfJ2xSVBMOwSUynZgwT3fyYBtWzD2IiXvvEvg2K(pkZxjBenZ8IF6WjWCJ(SjAzF8OytL2Qcu)KtPmPJ8b(Yji9Sb6e8gEoy9KEQ76nF()MlcHMma0MuO57JSE6skWk9vsgBUDPHKGtqkosPOhinwAAZtTzCHfyI2tW(Eds7GPBXKTLV5CTDOUsxz)kzxBIhvLNQ(TrqLBHcmK3IaCSRMpt7vfkwYg9G7qVRe04oZ3XbyCNVm3PN9sf3fVsjvGwrHCne3mLbsPIuxjw8pC56te02il72oIBlib5TZTgrJfFs7ZJ3keT)z6trnUHcRIRjnf4FQANDh07gBdVMKfXvAyyQRbGGQikyFZkyKkEV)kyRiXSc2OKPZEe3dVnDJ76DAYu7V2nkssbPY9RCPRKqDTZyDVODXbdtcPBDOlHWA)1UrcjKVfjKVKesFnr909Q(EDwB6nQxcfolt96MigS0T2KWOzVRluaG13G2gHS1(lCC4X2NHFWGSTbsIxwL6Tx92oCfAq9luaWzUs3NGMR8K4k1ahEng3(OlyQhofuVHl4(HI7Gz0vP0dAs9UUGBz3qZYwCwmdzZNSZbyzexBfAF9Yul9sFA7Mlnz5XJ0LJCtQWheVZx(G0oqqXDmM3WIgjUOJfBnNw0gPBAzH6OsjHQnuej1FHeQZLN6tbHCqhtFsiALtKycriByDem)XQRFBLLgHc8a2Cp5TMWq5AqUNdcmngB1r1SALYGTeVKSs5)T(GRL)ngvhpQVWDuYWdzVNKdCwxW4ClkPTnXaiJv2tjju30GPji1jG6RqfD2CkvBrhcupTyDqJXDs1rBgaM)PYx9acxIxRpAiylhwZ0XxZ0XVxMo(wmD87NPJVDtheqgGPJhTPJNjtNUVzbUy64310PtknDnDmCefdXT3w(Co65Behez1PiQWntQWXyS1W0rHFoQHKBbzyqreXT5l3GCvKO4)(N4VFjy7Q0H4QBun5U3UT1by1ZYOjhI5cs8b3mxWdS0tZfKnpRwjW6d)l7rTwq6b0QbBoDwJon2jLH15hhls(tzNOnEwWwsTUtMTnBr)aoUc6teeNmANgH2R3K(CvOfInM1e)zDlFNw(wTiFPpXR))zPKtVV8cH5jPuY77bzrfLa)a)o3LdS6vPmw7XrqvBdHiaC48VuTHDUuJhuLy3svhln5r)dtfGtx920LxK9I5sLkTKOB9atxWEu4qUatDRm7gQrLHk8apeBtWxBLF7irf4kOV3u5qDKVlGYgdnD(Jt1C(n1DPjU0lXxDHR0OgB)2mkNDXmTLH7v9o6y9aCCk3vspddNZ(zwPNUatKQHiWTRvZpD0UEwLRYwekvfPHslEWKORZVBVZdhEvY6AqgxmFnmEmu1V9KZLQVv6yqTkIBmwGRko4ef4QdvQVlf4QsT0swGRVxLHilWvLYLvvARbPsjZsuoQ81naP(SaYwWN)VM9)9]] )