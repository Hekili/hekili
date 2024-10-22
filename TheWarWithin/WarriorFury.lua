-- WarriorFury.lua
-- August 2024
-- 11.0.2


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
            return ( ( ( state.talent.war_machine.enabled and 1.2 or 1 ) * base_rage_gen * fury_rage_mult * state.swings.mainhand_speed )
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
            return ( ( state.talent.war_machine.enabled and 1.1 or 1 ) * base_rage_gen * fury_rage_mult * state.swings.offhand_speed * offhand_mod )
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
    -- Warrior
    armored_to_the_teeth         = { 90258, 384124, 2 }, -- Gain Strength equal to 5% of your Armor.
    avatar                       = { 92640, 107574, 1 }, -- Transform into a colossus for 20 sec, causing you to deal 20% increased damage and removing all roots and snares. Generates 10 Rage.
    barbaric_training            = { 95955, 390674, 1 }, -- Slam and Whirlwind deal 20% increased damage and 10% increased critical strike damage.
    berserker_shout              = { 90348, 384100, 1 }, -- Go berserk, removing and granting immunity to Fear, Sap, and Incapacitate effects for 6 sec. Also remove fear effects from group members within 12 yds.
    berserker_stance             = { 90325, 386196, 1 }, -- An aggressive combat state that increases the damage of your auto-attacks by 15% and reduces the duration of Fear, Sap and Incapacitate effects on you by 10%. Lasts until canceled.
    berserkers_torment           = { 90362, 390123, 1 }, -- Activating Avatar or Recklessness grants 8 sec of the other.
    bitter_immunity              = { 90356, 383762, 1 }, -- Restores 20% health instantly and removes all diseases, poisons and curses affecting you. 
    bounding_stride              = { 90355, 202163, 1 }, -- Reduces the cooldown of Heroic Leap by 15 sec, and Heroic Leap now also increases your movement speed by 70% for 3 sec.
    cacophonous_roar             = { 90383, 382954, 1 }, -- Intimidating Shout can withstand 200% more damage before breaking.
    champions_might              = { 90323, 386284, 1 }, -- The duration of Champion's Spear is increased by 2 sec. You deal 25% increased critical strike damage to targets chained to your Spear.
    champions_spear              = { 90380, 376079, 1 }, -- Throw a spear at the target location, dealing 129,398 Physical damage instantly and an additional 127,448 damage over 4 sec. Deals reduced damage beyond 5 targets. Enemies hit are chained to the spear's location for the duration. Generates 10 Rage.
    concussive_blows             = { 90354, 383115, 1 }, -- Cooldown of Pummel reduced by 1.0 sec. Successfully interrupting an enemy increases the damage you deal to them by 5% for 10 sec.
    crackling_thunder            = { 95959, 203201, 1 }, -- Thunder Clap's radius is increased by 50%, and it reduces movement speed by an additional 20%.
    cruel_strikes                = { 90381, 392777, 2 }, -- Critical strike chance increased by 1% and critical strike damage of Execute increased by 5%. 
    crushing_force               = { 90349, 382764, 2 }, -- Bloodthirst deals an additional 5% damage and has a 5% increased critical strike chance.
    defensive_stance             = { 92538, 386208, 1 }, -- A defensive combat state that reduces all damage you take by 15%, and all damage you deal by 10%. Lasts until canceled.
    double_time                  = { 90382, 103827, 1 }, -- Increases the maximum number of charges on Charge by 1, and reduces its cooldown by 3 sec.
    dual_wield_specialization    = { 90373, 382900, 1 }, -- Increases your damage while dual wielding by 5%.
    endurance_training           = { 90376, 391997, 2 }, -- Increases Stamina by 5% and reduces the duration of movement impairing effects on you by 10.0%.
    fast_footwork                = { 90344, 382260, 1 }, -- Movement speed increased by 5%.
    frothing_berserker           = { 90350, 215571, 1 }, -- Rampage has a 20% chance to immediately refund 10% of the Rage spent.
    heroic_leap                  = { 90346, 6544  , 1 }, -- Leap through the air toward a target location, slamming down with destructive force to deal 18,429 Physical damage to all enemies within 8 yards.
    honed_reflexes               = { 95956, 391271, 1 }, -- Cooldown of Enraged Regeneration, Pummel, Intervene, Spell Reflection, and Storm Bolt reduced by 5%.
    impending_victory            = { 90326, 202168, 1 }, -- Instantly attack the target, causing 46,270 damage and healing you for 30% of your maximum health. Killing an enemy that yields experience or honor resets the cooldown of Impending Victory and makes it cost no Rage.
    intervene                    = { 90329, 3411  , 1 }, -- Run at high speed toward an ally, intercepting all melee and ranged attacks against them for 6 sec while they remain within 10 yds.
    intimidating_shout           = { 90384, 5246  , 1 }, -- Causes the targeted enemy to cower in fear, and up to 5 additional enemies within 8 yards to flee. Targets are disoriented for 8 sec.
    leeching_strikes             = { 90371, 382258, 1 }, -- Leech increased by 3%.
    menace                       = { 90383, 275338, 1 }, -- Intimidating Shout will knock back all nearby enemies except your primary target, and cause them all to cower in fear for 15 sec instead of fleeing.
    overwhelming_rage            = { 90378, 382767, 2 }, -- Maximum Rage increased by 15.
    pain_and_gain                = { 90353, 382549, 1 }, -- When you take any damage, heal for 2% of your maximum health. This can only occur once every 10 sec.
    piercing_challenge           = { 90379, 382948, 1 }, -- Champion's Spear's damage increased by 50% and its Rage generation is increased by 100%.
    piercing_howl                = { 90348, 12323 , 1 }, -- Snares all enemies within 12 yards, reducing their movement speed by 70% for 8 sec.
    rallying_cry                 = { 90331, 97462 , 1 }, -- Lets loose a rallying cry, granting all party or raid members within 40 yards 10% temporary and maximum health for 10 sec.
    reinforced_plates            = { 90368, 382939, 1 }, -- Armor increased by 10%.
    rumbling_earth               = { 90374, 275339, 1 }, -- Shockwave's range increased by 6 yards and when Shockwave strikes at least 3 targets, its cooldown is reduced by 15 sec.
    second_wind                  = { 90332, 29838 , 1 }, -- Restores 6% health every 1 sec when you have not taken damage for 5 sec. While you are below 35% health, restores 1.0% health every 1 sec. The amount restored increases the closer you are to death.
    seismic_reverberation        = { 90354, 382956, 1 }, -- If Whirlwind hits 3 or more enemies, it hits them 1 additional time for 30% damage.
    shattering_throw             = { 90351, 64382 , 1 }, -- Hurl your weapon at the enemy, causing 52,282 Physical damage, ignoring armor, and removing any magical immunities. Deals up to 500% increased damage to absorb shields.
    shockwave                    = { 90375, 46968 , 1 }, -- Sends a wave of force in a frontal cone, causing 15,684 damage and stunning all enemies within 10 yards for 2 sec.
    sidearm                      = { 95955, 384404, 1 }, -- Your auto-attacks have a 20% chance to hurl weapons at your target and 3 other enemies in front of you, dealing an additional 19,606 Physical damage.
    spell_reflection             = { 90385, 23920 , 1 }, -- Raise your weapon, reflecting the first spell cast on you, and reduce magic damage you take by 20% for 5 sec.
    storm_bolt                   = { 90337, 107570, 1 }, -- Hurls your weapon at an enemy, causing 22,350 Physical damage and stunning for 4 sec.
    thunder_clap                 = { 90343, 6343  , 1 }, -- Blasts all enemies within 8 yards for 55,833 Physical damage and reduces their movement speed by 20% for 10 sec. Deals reduced damage beyond 5 targets.
    thunderous_roar              = { 90359, 384318, 1 }, -- Roar explosively, dealing 135,515 Physical damage to enemies within 12 yds and cause them to bleed for 146,820 physical damage over 8 sec.
    thunderous_words             = { 90358, 384969, 1 }, -- Increases the duration of Thunderous Roar's Bleed effect by 2.0 sec and Thunderous Roar's Bleed effect causes enemies to take 30% increased damage from all your bleeds.
    titans_torment               = { 90362, 390135, 1 }, -- Activating Avatar casts Odyn's Fury and activating Odyn's Fury grants 4 sec of Avatar.
    uproar                       = { 90357, 391572, 1 }, -- Thunderous Roar's cooldown reduced by 45 sec.
    war_machine                  = { 90386, 346002, 1 }, -- Your auto attacks generate 20% more Rage. Killing an enemy instantly generates 5 Rage, and increases your movement speed by 30% for 8 sec.
    wild_strikes                 = { 90360, 382946, 2 }, -- Haste increased by 1% and your auto-attack critical strikes increase your auto-attack speed by 10% for 10 sec.
    wrecking_throw               = { 90351, 384110, 1 }, -- Hurl your weapon at the enemy, causing 52,282 Physical damage, ignoring armor. Deals up to 500% increased damage to absorb shields.

    -- Fury
    anger_management             = { 90415, 152278, 1 }, -- Every 20 Rage you spend reduces the remaining cooldown on Recklessness, Bladestorm, and Ravager by 1 sec.
    ashen_juggernaut             = { 90409, 392536, 1 }, -- Execute increases the critical strike chance of Execute by 10% for 15 sec, stacking up to 5 times.
    bladestorm                   = { 90388, 227847, 1 }, -- Become an unstoppable storm of destructive force, striking all nearby enemies for 506,503 Physical damage over 3.7 sec. Deals reduced damage beyond 8 targets. You are immune to movement impairing and loss of control effects, but can use defensive abilities and can avoid attacks. Generates 10 Rage each time you deal damage.
    bloodborne                   = { 90401, 385703, 1 }, -- Bleed damage of Odyn's Fury, Thunderous Roar and Gushing Wound increased by 20%.
    bloodcraze                   = { 90405, 393950, 1 }, -- Raging Blow increases the critical strike chance of your next Bloodthirst by 15% until it critically strikes, stacking up to 5 times.
    bloodthirst                  = { 90392, 23881 , 1 }, -- Assault the target in a bloodthirsty craze, dealing 90,187 Physical damage and restoring 3% of your health. Generates 8 Rage.
    cold_steel_hot_blood         = { 90402, 383959, 1 }, -- Bloodthirst critical strikes generate 4 additional Rage, and inflict a Gushing Wound that leeches 63,523 health over 6 sec.
    critical_thinking            = { 90425, 383297, 2 }, -- Critical Strike chance increased by 1% and Raging Blow's critical strikes deal 5% increased damage.
    cruelty                      = { 90428, 392931, 1 }, -- While Enraged, Raging Blow deals 15% increased damage.
    dancing_blades               = { 90417, 391683, 1 }, -- Odyn's Fury increases your auto-attack damage and speed by 30% for 10 sec.
    deft_experience              = { 90421, 383295, 2 }, -- Mastery increased by 1% and if you are Enraged, Bloodthirst extends your Enrage by 0.5 sec.
    depths_of_insanity           = { 90413, 383922, 1 }, -- Recklessness lasts 4.0 sec longer.
    enraged_regeneration         = { 90395, 184364, 1 }, -- Reduces damage taken by 30%, and Bloodthirst restores an additional 20% health. Usable while stunned or incapacitated. Lasts 8 sec.
    focus_in_chaos               = { 90403, 383486, 1 }, -- While Enraged, your auto-attacks can no longer miss.
    frenzied_enrage              = { 90398, 383848, 1 }, -- Enrage increases your Haste by 15% and increases your movement speed by 10%.
    frenzy                       = { 90406, 335077, 1 }, -- Rampage increases your Haste by 2% for 12 sec, stacking up to 4 times. This effect is reset if you Rampage a different primary target.
    fresh_meat                   = { 90399, 215568, 1 }, -- Bloodthirst always Enrages you the first time you strike a target, and it has a 15% increased chance to trigger Enrage.
    hack_and_slash               = { 90407, 383877, 1 }, -- Each Rampage strike has a 25% chance to refund a charge of Raging Blow.
    improved_bloodthirst         = { 90397, 383852, 1 }, -- Bloodthirst damage increased by 10%.
    improved_execute             = { 90430, 316402, 1 }, -- Execute no longer costs Rage and now generates 20 Rage.
    improved_raging_blow         = { 90390, 383854, 1 }, -- Raging Blow has 2 charges and has a 20% chance to instantly reset its own cooldown.
    improved_whirlwind           = { 90427, 12950 , 1 }, -- Whirlwind causes your next 4 single-target attacks to strike up to 4 additional targets for 55% damage. Whirlwind generates 3 Rage, plus an additional 1 per target hit. Maximum 8 Rage.
    invigorating_fury            = { 90393, 383468, 1 }, -- Enraged Regeneration lasts 3 sec longer and instantly heals for 10% of your maximum health.
    massacre                     = { 90410, 206315, 1 }, -- Execute is now usable on targets below 35% health, and its cooldown is reduced by 1.5 sec.
    meat_cleaver                 = { 90391, 280392, 1 }, -- Whirlwind deals 25% more damage and now affects your next 4 single-target melee attacks, instead of the next 2 attacks.
    odyns_fury                   = { 90418, 385059, 1 }, -- Unleashes your power, dealing 356,472 Physical damage and an additional 147,436 Physical damage over 4 sec to all enemies within 12 yards. Generates 15 Rage. 
    onslaught                    = { 90424, 315720, 1 }, -- Brutally attack an enemy for 166,446 Physical damage. Generates 30 Rage.
    powerful_enrage              = { 90398, 440277, 1 }, -- Enrage increases the damage your abilities deal by an additional 15% and Enrage's duration is increased by 1 sec.
    raging_blow                  = { 90396, 85288 , 1 }, -- A mighty blow with both weapons that deals a total of 80,372 Physical damage. Raging Blow has a 20% chance to instantly reset its own cooldown. Generates 12 Rage.
    rampage                      = { 90408, 184367, 1 }, -- Enrages you and unleashes a series of 4 brutal strikes for a total of 135,040 Physical damage.
    ravager                      = { 90388, 228920, 1 }, -- Throws a whirling weapon at the target location that chases nearby enemies, inflicting 387,846 Physical damage to all enemies over 11.1 sec. Deals reduced damage beyond 8 targets. Generates 10 Rage each time it deals damage.
    reckless_abandon             = { 90415, 396749, 1 }, -- Recklessness generates 50 Rage and Rampage greatly empowers your next Bloodthirst and Raging Blow.
    recklessness                 = { 90412, 1719  , 1 }, -- Go berserk, increasing all Rage generation by 100% and granting your abilities 20% increased critical strike chance for 12 sec.
    singleminded_fury            = { 90400, 81099 , 1 }, -- While dual-wielding a pair of one-handed weapons, your damage done is increased by 5%, your auto-attack damage with one-handed weapons is increased by 30%, your movement speed is increased by 5%, and your auto-attack critical strikes have a 50% chance to Enrage you.
    slaughtering_strikes         = { 90411, 388004, 1 }, -- Raging Blow causes every strike of your next Rampage to deal an additional 20% damage, stacking up to 5 times.
    storm_of_steel               = { 90389, 382953, 1 }, -- Bladestorm and Ravager's damage are reduced by 30% but they now have 2 charges and generate 10 additional Rage each time they deal damage.
    sudden_death                 = { 90429, 280721, 1 }, -- Your attacks have a chance to reset the cooldown of Execute and make it usable on any target, regardless of their health.
    swift_strikes                = { 90416, 383459, 2 }, -- Haste increased by 1% and Raging Blow and Bloodthirst generate an additional 1 Rage.
    tenderize                    = { 90423, 388933, 1 }, -- Onslaught Enrages you, and if you have Slaughtering Strikes grants you 3 stacks of Slaughtering Strikes.
    titanic_rage                 = { 90417, 394329, 1 }, -- Odyn's Fury's Enrages you, deals 10% increased damage and grants you 4 stacks of Whirlwind. 
    unbridled_ferocity           = { 90414, 389603, 1 }, -- Rampage has a 6% chance to grant Recklessness for 4 sec.
    unhinged                     = { 90389, 386628, 1 }, -- Every other time Bladestorm or Ravager deal damage, you automatically cast a Bloodthirst at your target or random nearby enemy. 
    vicious_contempt             = { 90404, 383885, 2 }, -- Bloodthirst deals 25% increased damage to enemies who are below 35% health.
    warpaint                     = { 90394, 208154, 1 }, -- You take 10% reduced damage while Enrage is active.
    wrath_and_fury               = { 90387, 392936, 1 }, -- Raging Blow deals 15% increased damage and while Enraged, Raging Blow has a 10% increased chance to instantly reset its own cooldown. 

    -- Mountain Thane
    avatar_of_the_storm          = { 94805, 437134, 1 }, -- Casting Avatar grants you 2 charges of Thunder Blast and resets the cooldown of Thunder Clap. While Avatar is not active, Lightning Strikes have a 10% chance to grant you Avatar for 4 secs. Thunder Blast Your next Thunder Clap becomes a Thunder Blast that deals Stormstrike damage.
    burst_of_power               = { 94807, 437118, 1 }, -- Lightning Strikes have a 15% chance to make your next 2 Bloodthirsts have no cooldown, deal 35% increased damage, and generate 2 additional Rage.
    crashing_thunder             = { 94816, 436707, 1 }, -- Stormstrike or Nature damage your abilities deal is increased by 5%. Stormstrike damage ignores Armor. Thunder Clap damage increased by 40%, and it generates 5 Rage. Seismic Reverberations, Improved Whirlwind, Meat Cleaver, and Barbaric Training now affect Thunder Clap in addition to Whirlwind.
    flashing_skies               = { 94797, 437079, 1 }, -- Thunder Blast calls down a Lightning Strike on an enemy it hits.
    gathering_clouds             = { 94792, 436201, 1 }, -- Your attacks trigger Lightning Strikes 30% more often.
    ground_current               = { 94800, 436148, 1 }, -- Lightning Strikes also deal 23,527 to enemies near their target. Damage reduced beyond 5 targets.
    keep_your_feet_on_the_ground = { 94798, 438590, 1 }, -- Physical damage taken reduced by 2%. Thunder Blast reduces damage you take by 8% for 5 sec.
    lightning_strikes            = { 94803, 434969, 1, "mountain_thane" }, -- Damaging enemies with Thunder Clap, Raging Blow, or Execute has a 25% chance to also strike one with a lightning bolt, dealing 47,054 Nature damage. Lightning Strikes occur 30% more often during Avatar.
    snap_induction               = { 94797, 456270, 1 }, -- Activating Recklessness grants a charge of Thunder Blast.
    steadfast_as_the_peaks       = { 94798, 434970, 1 }, -- Stamina increased by 5%. Impending Victory increases your maximum health by 10% for 5 sec. When this health increase expires, you heal for any amount of the original Impending Victory that healed you in excess of your full health.
    storm_bolts                  = { 94817, 436162, 1 }, -- Storm Bolt also hits 2 additional nearby targets, stunning them for 2 sec, but its cooldown is increased by 10 sec.
    storm_shield                 = { 94817, 438597, 1 }, -- Intervening a target grants them a shield for 5 sec that absorbs magic damage equal to 3 times your Armor.
    strength_of_the_mountain     = { 94808, 437068, 1 }, -- Shield Slam damage increased by 10%. Bloodthirst and Rampage damage increased by 15%.
    thorims_might                = { 94792, 436152, 1 }, -- Lightning Strikes generate 5 Rage. Raging Blow and Execute damage increased by 15%.
    thunder_blast                = { 94785, 435607, 1 }, -- Shield Slam and Bloodthirst have a 35% chance to grant you Thunder Blast, stacking up to 2 charges. Thunder Blast Your next Thunder Clap becomes a Thunder Blast that deals Stormstrike damage and generates 5 Rage.

    -- Slayer
    brutal_finish                = { 94786, 446085, 1 }, -- Your next Rampage after Bladestorm ends deals 50% additional damage.
    culling_cyclone              = { 94786, 444778, 1 }, -- Each strike of Bladestorm deals an additional 20% damage evenly split across all targets.
    death_drive                  = { 94813, 444770, 1 }, -- You heal for 15% of damage dealt by Sudden Death.
    fierce_followthrough         = { 94787, 444773, 1 }, -- Bloodthirst critical strikes increase the damage of your next Bloodthirst by 15%. 
    imminent_demise              = { 94788, 444769, 1 }, -- Every 3 Slayer's Strikes you gain Sudden Death. Using Sudden Death accelerates your next Bladestorm, striking 1 additional time (max 3). Bladestorm's total duration is unchanged.
    opportunist                  = { 94787, 444774, 1 }, -- When Raging Blow resets its own cooldown, your next Raging Blow deals 10% additional damage and 10% additional critical damage.
    overwhelming_blades          = { 94810, 444772, 1 }, -- Each strike of Bladestorm applies Overwhelmed to all enemies affected, increasing damage you deal to them by 1% for 20 sec, max 10 stacks.
    reap_the_storm               = { 94809, 444775, 1 }, -- Bloodthirst has a 20% chance to cause you to unleash a flurry of steel, striking all nearby enemies for 123,517 damage and applying Overwhelmed. Deals reduced damage beyond 8 targets. 
    relentless_pursuit           = { 94795, 444776, 1 }, -- Charge grants you 70% movement speed for 3 sec. Charge removes all movement impairing effects, this effect cannot occur more than once every 30 sec. 
    show_no_mercy                = { 94784, 444771, 1 }, -- Marked for Execution increases the critical strike chance and critical strike damage of your next Execute on the target by 10%.
    slayers_dominance            = { 94814, 444767, 1, "slayer" }, -- Your attacks against your primary target have a high chance to overwhelm your their defenses and trigger a Slayer's Strike, dealing 52,282 damage and applying Marked for Execution, increasing the damage they take from your next Execute by 10%. Stacks 3 times.
    slayers_malice               = { 94801, 444779, 1 }, -- Raging Blow damage increased by 20%.
    unrelenting_onslaught        = { 94820, 444780, 1 }, -- When you Execute a target that you've Marked for Execution, you both reduce the cooldown of Bladestorm by 5 sec and apply 2 stacks of Overwhelmed to the target per stack of Marked for Execution consumed. You can now use Pummel and Storm Bolt while Bladestorming.
    vicious_agility              = { 94795, 444777, 1 }, -- Heroic Leap reduces the cooldown of Charge by 5 sec and Charge reduces the cooldown of Heroic Leap by 2 sec.
} )


-- PvP Talents
spec:RegisterPvpTalents( { 
    barbarian             = 166 , -- (280745) 
    battle_trance         = 170 , -- (213857) 
    battlefield_commander = 5628, -- (424742) Your Shout abilities have additional effects.  Battle Shout: Increases Stamina by 3%.  Piercing Howl: Radius increased by 50%  Berserker Shout: Range increased by 8 yds.  Intimidating Shout: Cooldown reduced by 15 sec.  Rallying Cry: Removes movement impairing effects and grants 30% movement speed to allies.  Thunderous Roar: Targets receive 5% more damage from all sources while bleeding.
    death_wish            = 179 , -- (199261) Increases your damage taken and done by 10% for 15 sec at the cost of 10% of your health. Stacks up to 5 times.
    demolition            = 5373, -- (329033) Reduces the cooldown of your Shattering Throw or Wrecking Throw by 50% and increases its damage to absorb shields by an additional 250%.
    disarm                = 3533, -- (236077) Disarm the enemy's weapons and shield for 5 sec. Disarmed creatures deal significantly reduced damage.
    enduring_rage         = 177 , -- (411764) 
    master_and_commander  = 3528, -- (235941) Cooldown of Rallying Cry reduced by $s1//1000${$s1//1000} sec, and grants 15% additional health.
    rebound               = 5548, -- (213915) Spell Reflection reflects the next 2 incoming spells cast on you and reflected spells deal 50% extra damage to the attacker. Spell Reflection's cooldown is increased by 10 sec.
    safeguard             = 5624, -- (424654) Intervene now has 2 charges and reduces the ally's damage taken by 20% for 5 sec. Intervene's cooldown is increased by 10 sec.
    slaughterhouse        = 3735, -- (352998) 
    warbringer            = 5431, -- (356353) Charge roots enemies for 2 sec and emanates a shockwave past the target, rooting enemies and dealing 39,211 Physical damage in a 20 yd cone.
} )

-- Auras
spec:RegisterAuras( {
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
    bladestorm = {
        id = 46924,
        duration = function () return ( buff.dance_of_death.up and 9 or 6 ) * haste end,
        max_stack = 1,
        onCancel = function()
            setCooldown( "global_cooldown", 0 )
        end,
        copy = { 227847, 389774, 446035 }
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
    brutal_finish = {
        id = 446918,
        duration = 10,
        max_stack = 1
    },
    burst_of_power = {
        id = 437121,
        duration = 15,
        max_stack = 2
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
        duration = function() return talent.powerful_enrage.enabled and 5 or 4 end,
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
    imminent_demise = {
        id = 445606,
        duration = 60,
        max_stack = 3,
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
    marked_for_execution = {
        id = 445584,
        duration = 30,
        max_stack = 3,
    },
    odyns_fury = {
        id = 385060,
        duration = 4,
        tick_time = 1,
        max_stack = 1,
        copy = { "odyns_fury_torment", "odyns_fury_torment_mh" }
    },
    opportunist = {
        id = 456120,
        duration = 8,
        max_stack = 1,
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
    reckless_abandon_bloodbath = {
        id = 461288,
        duration = 12,
        max_stack = 1,
        copy = "bloodbath"
    },
    reckless_abandon_crushing_blow = {
        id = 396752,
        duration = 12,
        max_stack = 1,
        copy = "crushing_blow"
    },
    recklessness = {
        id = 1719,
        duration = function() return state.talent.depths_of_insanity.enabled and 16 or 12 end,
        max_stack = 1,
        copy = "recklessness_warlords_torment"
    },
    slaughterhouse = {
        id = 354788,
        duration = 20,
        max_stack = 12
    },
    slaughtering_strikes_raging_blow = {
        id = 393931,
        duration = 12,
        max_stack = 5,
        copy = "slaughtering_strikes"
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
        max_stack = 2
    },
    steadfast_as_the_peaks = {
        id = 437152,
        duration = 5,
        max_stack = 1
    },
    taunt = {
        id = 355,
        duration = 3,
        max_stack = 1,
    },
    thunder_blast = {
        id = 435615,
        duration = 15,
        max_stack = 2
    },
    thunder_clap = {
        id = 6343,
        duration = 10,
        max_stack = 1
    },
    thunderous_roar = {
        id = 397364,
        duration = function () return talent.thunderous_words.enabled and 10 or 8 end,
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
    meat_cleaver = {
        id = 85739,
        duration = 20,
        max_stack = function ()
            if talent.meat_cleaver.enabled then return 4
            elseif talent.improved_whirlwind.enabled or talent.titanic_rage.enabled then return 2
            else return 0 end
        end,
        copy = "whirlwind"
    },
} )


spec:RegisterGear( "tier29", 200426, 200428, 200423, 200425, 200427 )
spec:RegisterSetBonuses( "tier29_2pc", 393708, "tier29_4pc", 393709 )
-- 2-Set - Execute’s chance to critically strike increased by 10%.
-- 4-Set - Sudden Death’s chance to reset the cooldown of Execute and make it usable on any target, regardless of health, is greatly increased.

spec:RegisterGear( "tier30", 202446, 202444, 202443, 202442, 202441, 217218, 217220, 217216, 217217, 217219 )
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

local rageSpent = 0
local gloryRage = 0

local fresh_meat_actual = {}
local fresh_meat_virtual = {}

local last_rampage_target = nil

local marked_for_execution_stacks = {}
local marked_for_execution_virtual = {}

local TriggerColdSteelHotBlood = setfenv( function()
    applyDebuff( "target", "gushing_wound" )
    gain( 4, "rage" )
end, state )

local RemoveFrenzy = setfenv( function()
    removeBuff( "frenzy" )
end, state )

local ExpireBladestorm = setfenv( function()
    applyBuff( "merciless_bonegrinder" )
end, state )

spec:RegisterCombatLogEvent( function(  _, subtype, _, sourceGUID, sourceName, sourceFlags, _, destGUID, destName, destFlags, _, spellID, spellName, school, amount, interrupt, a, b, c, d, critical )

    if sourceGUID == state.GUID then
        if subtype == "SPELL_CAST_SUCCESS" then
            local ability = class.abilities[ spellID ]

            if not ability then return end
            if ability.key == "rampage" and last_rampage_target ~= destGUID and state.talent.frenzy.enabled then
                RemoveFrenzy()
                last_rampage_target = destGUID
            end

        elseif subtype == "SPELL_DAMAGE" and UnitGUID( "target" ) == destGUID then
            if spellID == 445579 then -- Slayer's Strike occurred
                marked_for_execution_stacks[ destGUID ] = min( ( marked_for_execution_stacks[ destGUID ] or 0 ) + 1, 3 )
                return
            end

            local ability = class.abilities[ spellID ]
            if not ability then return end

            if ( ability.key == "bloodthirst" or ability.key == "bloodbath" ) and state.talent.fresh_meat.enabled and not fresh_meat_actual[ destGUID ] then
                fresh_meat_actual[ destGUID ] = true
            end
        elseif state.talent.thunder_blast.enabled and spellID == 435615 and ( subtype == "SPELL_AURA_APPLIED" or subtype == "SPELL_AURA_REMOVED" or subtype == "SPELL_AURA_REFRESH" or subtype == "SPELL_AURA_APPLIED_DOSE" or subtype == "SPELL_AURA_REMOVED_DOSE" ) then
            Hekili:ForceUpdate( "THUNDERBLAST_CHANGED", true )
            --Will pickup thunder_blast stacks
        elseif state.talent.burst_of_power.enabled and spellID == 437121 and ( subtype == "SPELL_AURA_APPLIED" or subtype == "SPELL_AURA_REMOVED" or subtype == "SPELL_AURA_REFRESH" or subtype == "SPELL_AURA_APPLIED_DOSE" or subtype == "SPELL_AURA_REMOVED_DOSE" ) then
            Hekili:ForceUpdate( "BURSTOFPOWER_CHANGED", true )
        end
    end
end )


local wipe = table.wipe

spec:RegisterEvent( "PLAYER_REGEN_ENABLED", function()
    wipe( fresh_meat_actual )
    wipe( marked_for_execution_stacks )
end )

spec:RegisterHook( "UNIT_ELIMINATED", function( id )
    fresh_meat_actual[ id ] = nil
    marked_for_execution_stacks[ id ] = nil
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
                cooldown.bladestorm.expires = cooldown.bladestorm.expires - reduction
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

spec:RegisterHook( "reset_precast", function ()
    rage_spent = nil
    glory_rage = nil

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

    for k, v in pairs( marked_for_execution_stacks ) do
        marked_for_execution_virtual[ k ] = v

        if k == target.unit then
            applyDebuff( "target", "marked_for_execution", nil, v )
        else
            active_dot.marked_for_execution = active_dot.marked_for_execution + 1
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
            if talent.avatar_of_the_storm.enabled then
                addStack( "thunder_blast" , nil,  2 )
                reduceCooldown( "thunder_clap", 6) -- resets cooldown of TC entirely
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

        startsCombat = false,
        texture = 136009,

        --toggle = "defensives",
        --Not yet Implemented in LossOfControl via Classes.lua
        --usable = function () return ( debuff.sap.up or debuff.incapacitate.up or debuff.fear.up ) , "requires fear/incapacitate/sap debuff" end,

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

        --Not yet Implemented in LossOfControl via Classes.lua
        --toggle = "defensives",
        --usable = function () return ( debuff.sap.up or debuff.incapacitate.up or debuff.fear.up ) , "requires fear/incapacitate/sap debuff" end,

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

    bladestorm = {
        id = function() return talent.unrelenting_onslaught.enabled and 446035 or 227847 end,
        cast = 0,
        cooldown = 90,
        gcd = "spell",

        talent = "bladestorm",
        startsCombat = true,
        texture = 236303,
        range = 8,
        charges = function () if talent.storm_of_steel.enabled then return 2 end end,

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

            if talent.brutal_finish.enabled then applyBuff( "brutal_finish" ) end
            removeBuff( "imminent_demise" )
        end,

        copy = { 227847, 389774, 446035 }
    },


    bloodbath = {
        id = 335096,
        known = 23881,
        flash = 23881,
        cast = 0,
        cooldown = function () return buff.burst_of_power.up and 0 or ( 4.5 ) * haste end,
        gcd = "spell",

        spend = function()
            return -8
            + ( -2 * buff.merciless_assault.stack )
            + ( talent.cold_steel_hot_blood.enabled and action.bloodthirst.crit_pct_current >= 100 and -4 or 0 )
            + ( buff.burst_of_power.up and -2 or 0 )
            + ( -1 * talent.swift_strikes.rank )
        end,
        spendType = "rage",

        cycle = function () return talent.fresh_meat.enabled and "hit_by_fresh_meat" or nil end,

        startsCombat = true,
        texture = 236304,
        buff = "reckless_abandon_bloodbath",
        bind = "bloodthirst",

        critical = function()
            return stat.crit
            + ( 15 * buff.bloodcraze.stack )
            + ( 12 * buff.merciless_assault.stack )
            + ( 20 * buff.recklessness.stack )
            + ( talent.crushing_force.enabled and talent.crushing_force.rank * 2 or 0 )
        end,
        handler = function()
            removeStack( "whirlwind" )
            if buff.enrage.up and talent.deft_experience.enabled then
                buff.enrage.remains = buff.enrage.remains + ( 0.5 * talent.deft_experience.rank )
            end
        
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
        
            if legendary.cadence_of_fujieda.enabled then
                if buff.cadence_of_fujieda.stack < 5 then stat.haste = stat.haste + 0.01 end
                addStack( "cadence_of_fujieda" )
            end
        
            if buff.reckless_abandon_bloodbath.up then removeBuff( "reckless_abandon_bloodbath" ) end
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
        cooldown = function () return buff.burst_of_power.up and 0 or ( 4.5 ) * haste end,
        gcd = "spell",

        spend = function()
            return -8
            + ( -2 * buff.merciless_assault.stack )
            + ( talent.cold_steel_hot_blood.enabled and action.bloodthirst.crit_pct_current >= 100 and -4 or 0 )
            + ( buff.burst_of_power.up and -2 or 0 )
            + ( -1 * talent.swift_strikes.rank )
        end,
        spendType = "rage",

        cycle = function () return talent.fresh_meat.enabled and "hit_by_fresh_meat" or nil end,

        talent = "bloodthirst",
        texture = 136012,
        nobuff = "reckless_abandon_bloodbath",
        startsCombat = true,
        bind = "bloodbath",

        critical = function()
            return stat.crit
            + ( 15 * buff.bloodcraze.stack )
            + ( 12 * buff.merciless_assault.stack )
            + ( 20 * buff.recklessness.stack )
            + ( talent.crushing_force.enabled and talent.crushing_force.rank * 2 or 0 )
        end,
        handler = function()
            removeStack( "whirlwind" )
            if buff.enrage.up and talent.deft_experience.enabled then
                buff.enrage.remains = buff.enrage.remains + ( 0.5 * talent.deft_experience.rank )
            end
        
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

            if legendary.cadence_of_fujieda.enabled then
                if buff.cadence_of_fujieda.stack < 5 then stat.haste = stat.haste + 0.01 end
                addStack( "cadence_of_fujieda" )
            end
        
            if buff.reckless_abandon_bloodbath.up then removeBuff( "reckless_abandon_bloodbath" ) end
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

    
    champions_spear = {
        id = function() return talent.champions_spear.enabled and 376079 or 307865 end,
        cast = 0,
        cooldown = 90,
        gcd = "spell",

        spend = function () return ( -10 * ( talent.piercing_challenge.enabled and 2 or 1 ) ) * ( 1 + conduit.piercing_verdict.mod * 0.01 ) end,
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
        end,
        cooldown = function() return 7 * haste end,
        recharge = function() return 7 * haste end,
        gcd = "spell",

        spend = function () return -12 - talent.swift_strikes.rank end,
        spendType = "rage",

        startsCombat = true,
        texture = 132215,

        talent = "reckless_abandon",
        buff = "reckless_abandon_crushing_blow",
        bind = "raging_blow",

        handler = function ()
            removeStack( "whirlwind" )
            removeBuff( "opportunist" )
            removeBuff( "reckless_abandon" )
            spendCharges( "raging_blow", 1 )
            if buff.will_of_the_berserker.up then buff.will_of_the_berserker.expires = query_time + 12 end

            if buff.reckless_abandon_crushing_blow.up then removeBuff( "reckless_abandon_crushing_blow" ) end
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
        cooldown = function () return 120 - ( conduit.stalwart_guardian.enabled and 20 or 0 ) - ( talent.honed_reflexes.enabled and 15*0.05 or 0 ) end,
        gcd = "off",

	    toggle = "defensives",

        talent = "enraged_regeneration",
        startsCombat = false,
        texture = 132345,

        handler = function ()
            applyBuff( "enraged_regeneration" )
            if ( talent.invigorating_fury.enabled ) then gain( health.max * 0.10 , "health" ) end
        end,
    },


    execute = {
        id = function () return talent.massacre.enabled and 280735 or 5308 end,
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

        handler = function ()
            removeDebuff( "target", "marked_for_execution" )
            if not buff.sudden_death.up and not buff.stone_heart.up and not talent.improved_execute.enabled then -- Execute costs rage
                local cost = min( rage.current, 40 )
                spend( cost, "rage", nil, true )
            else
                removeBuff( "sudden_death" )
                if talent.imminent_demise.enabled then
                    addStack( "imminent_demise" )
                end
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
            if talent.steadfast_as_the_peaks.enabled then applyBuff( "steadfast_as_the_peaks" ) end
        end,
    },


    intervene = {
        id = 3411,
        cast = 0,
        cooldown = function() return 30 - ( talent.honed_reflexes.enabled and 30*0.05 or 0 ) end,
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
                addStack( "slaughtering_strikes", nil, 3 )
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
        cooldown = function () return 15 - ( talent.concussive_blows.enabled and 1 or 0 ) - - ( talent.honed_reflexes.enabled and 15*0.05 or 0 ) end,
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
        startsCombat = true,
        nobuff = "reckless_abandon_crushing_blow",
        bind = "crushing_blow",

        handler = function ()
            removeStack( "whirlwind" )
            spendCharges( "crushing_blow", 1 )
            removeBuff( "opportunist" )
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
            if talent.reckless_abandon.enabled then 
                applyBuff( "reckless_abandon_bloodbath" )
                applyBuff( "reckless_abandon_crushing_blow" )
            end
            if set_bonus.tier30_4pc > 0 then addStack( "merciless_assault" ) end
            removeBuff( "brutal_finish" )
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

            if talent.snap_induction.enabled then addStack( "thunder_blast " ) end
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
        cooldown = 0,
        gcd = "spell",

        startsCombat = true,
        texture = 132340,

        handler = function ()
            removeStack( "whirlwind" )
        end,
    },


    storm_bolt = {
        id = 107570,
        cast = 0,
        cooldown = function() return 30 + ( talent.storm_bolts.enabled and 10 or 0 ) - ( talent.honed_reflexes.enabled and 30*0.05 or 0 ) end,
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

    thunder_blast = {
        id = 435222,
        flash = 6343,
        cast = 0,
        cooldown = 6,
        gcd = "spell",
        hasteCD = true,

        spend = 15,
        spendType = "rage",

        talent = "thunder_blast",
        buff = "thunder_blast",
        startsCombat = true,
        texture = 460957,

        handler = function ()
            if ( talent.crashing_thunder.enabled ) then
                if ( talent.improved_whirlwind.enabled ) then
                    applyBuff ( "whirlwind", nil, talent.meat_cleaver.enabled and 4 or 2 )
                end
            end
            applyDebuff( "target", "thunder_clap" )
            active_dot.thunder_clap = max( active_dot.thunder_clap, active_enemies )
            removeStack( "thunder_blast" )
        end,

        bind = "thunder_clap"
    },

    thunder_clap = {
        id = 6343,
        cast = 0,
        cooldown = 6,
        gcd = "spell",
        hasteCD = true,

        spend = 20,
        spendType = "rage",

        talent = "thunder_clap",
        nobuff = "thunder_blast",
        startsCombat = true,
        texture = 136105,

        handler = function ()
            if ( talent.crashing_thunder.enabled ) then
                if ( talent.improved_whirlwind.enabled ) then
                    applyBuff ( "whirlwind", nil, talent.meat_cleaver.enabled and 4 or 2 )
                end
            end
            applyDebuff( "target", "thunder_clap" )
            active_dot.thunder_clap = max( active_dot.thunder_clap, active_enemies )
        end,

        bind = "thunder_blast",
    },


    thunderous_roar = {
        id = 384318,
        cast = 0,
        cooldown = function() return 90 - ( talent.uproar.enabled and 45 or 0 ) end,
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
            if talent.steadfast_as_the_peaks.enabled then applyBuff( "steadfast_as_the_peaks" ) end
        end,
    },


    whirlwind = {
        id = 190411,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        startsCombat = true,

        spend = function() return talent.improved_whirlwind.enabled and ( -3 - min( 5, active_enemies ) ) or 0 end,
        spendType = "rage",

        texture = 132369,

        usable = function ()
            if action.taunt.known and action.heroic_throw.known and settings.check_ww_range and not ( action.taunt.in_range and not action.heroic_throw.in_range ) then return false, "target is outside of whirlwind range" end
            return true
        end,

        handler = function ()
            if talent.improved_whirlwind.enabled then
                applyBuff( "meat_cleaver", nil, talent.meat_cleaver.enabled and 4 or 2 )
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

local NewFeature = "|TInterface\\OptionsFrame\\UI-OptionsFrame-NewFeatureIcon:0|t"

spec:RegisterSetting( "spell_reflection_filter", true, {
    name = format( "%s Filter M+ |T132361:0|t Spell Reflection (TWW Season 1)", NewFeature ),
    desc = "If checked, then the addon will only suggest |T132361:0|t Spell Reflection on reflectable spells that target the player.",
    type = "toggle",
    width = "full",
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
    nameplateRange = 10,
    rangeFilter = true,

    damage = true,
    damageDots = false,
    damageExpiration = 8,

    potion = "spectral_strength",

    package = "Fury",
} )

spec:RegisterPack( "Fury", 20241021, [[Hekili:T31EVnoos(plnwmUJ3jTJLYKz6Er7aC3IDbMghM7pYC79Fwwws2wB0dF6r6odc8N9RkQxKuSeLuSDspiyWKorK8hlwSEXIuulnw(7lVZ1oZB5Vzo38NmMBAmZWWW0y5DzpU3B5D7TDU3El8lr2HWp)N5jpIp8XGyBxSTPX5joqb7YY2N(3U6QT(z7YxpZjo8Qu)W8a7m)4iNe7nz4F7C1Y7wN7hK9RrlxRSJN)PL3zNNTloz5D35h(3bK9DD9kQUxQZY7WQ)bJ5FW04VDyfwLdRY3JiD4lh(svHZ)zOW)P)3oSklXp6EVSREWoX3EDGx6HvXjUEj11E(N(W8RV8Wk8FVP4FnMx8VMMuDX8p(bZBGc)FkE8Q8u)OThw9Rop(H)LNFukFfnUPaL2G8lF4650LzEnu2VVdq))1ob(bWz9JaMFs8g)aGLB7G820z7t8a29A7SFCXvWpZc8Ss3fNND4lkRHxsQxY9EjwPz2roExMfVDBG3I4i11VIVDjkaSilXZ2zNxsCEQvwIDuAOFwgGvDlSCStZU8b7GCVfMQrmp1ZYpZlStev3u4xVhMctJG))s)nlEN3)xU)(9EUZ28yIniSTZkBNNLlGzyIxKlfo2pyNzNWqiZoWlkBwMpWnakioje(Z(XkycwwgwEFZji31RCux(8zgZ8tNnOrNA8njW3St8)lhw9pW6dYuGeVDTEa8hoXXbUXFncKXD9FW31Z9WQ1pcvIXuq1d4)DFeeIxTjpzgivV5Wk)S3d)nJcoSANn87rXhwL4fA7ZyZWVMLNeDyLbaRxqQxZtMp7MzdzaByL(yKZLX7xK6L5VPCyBu8Vwi2laiV0joY1hXKJJdeMfkEToFZMjx088QH8m38eMfPF4hQFuXWUUKfZF6P(1qgpYcyrpY14PdzKAo2rQjXi1CSJ0UB4ZFKAWi00wQi8dJNE6cXcaduzZSJE0YDF6K3vb8SwkEdIsmvsjMuuIzFOeZrrj7t8Jt8ZEuE(3KF(3GB2xflGnyMOGIyf80tuLm5IofAAkdC34un0RlF6F9cJz38JImje3zPGfPOTz7GAOORrX9PtV9IovnBkRp9Tr)6BJY(EitqgwH2r52bQmSBhS1lBNn45l)p(dWJ764VneOnvdTjj01GdqUppm0la9EbQZqDN56Xg)ORximKzOpHm(g4SdRhRb(HEFgnQ80tHXp4H(6M56xejWT3W3g0PIVJvGN9ESHTRTPq13hJ)MqNAheyv8NwbqJkyanHHPTQLmfHAg4VDxwQ1)o3DlsniLvpvdnERJRvITJVDGqRwBV1kEd4G035(0(2MI4Ka(j2ag)Lp6Jz57fQDqCSlZcj)t34N4XkH)HiZdKuTdSWHn4PgCv3uQF0dX3d6(Fd8Ihb1b74c2X(4VcbA5hTbI1moQMOknQx4jo9wJBMSb5rwvpyHX13WzgW7BEo5zEw7bTgVj8iKV)PNeA6NxiofNKh1EsknW(rwSKxMIS3mWGftUKfuvrHPwUXH(r44Ec2(hGHxKxOVx6cJ(IF4OW)w94dkArEYK)76j(9G(lWpCC4J0FJvLAwTIaHVOcs7OTi7Yocw0gQHmr27F1KRXeLr(ofIjqnsp9KUyL5jWMiSVqzRMCbt2ZlkbGNj7XxnWWd(8PtUOY02o7W9yNyfIIOSgurosLnD6WOuy9QyeSye0jXfKSiPPUzn9A6EVYrQy7uZGjNqa7qaLlJH6rYu10utCAi54gNXf5wvtTc3Xjd0VzbcswnruAHHrbftEH2W6nbRJXjwffcTbCwB7C)IRXqTkL3s35fbw23UfT8LNvACs6P10(cGFnrK6j4kjWeLDP7VIUADGTlydgyindTMNj2fVJucuDV1GtBjjkg5Tl(eXeAe8x5q3Xr8zS116)hLwVxNKdfyTXpYpDhjv1MhiREtiLNKNUd8bAbUX(6iOrkEe4tecpAh2eK38zJ54IrkIMzNNDq2Uz7DY(813uPe9GVJpQIcrdN5fUNGCbSQiwEON8ogRkE)(4KSCGrrp91MrvzQ1YETDKlFAsiK6LMZ7sjGwicyqz78tsZ49xitkt6JHkoEIMjWohzAju1v4RqzbF1pYLJJg6H5jcIS8b(mHW3k43djkb1SGqIdYQz1CAUipOv7cFT7Wm87ghMHJZHz4RqhMHVgCyg2sfPWwbNcsPJY5t6JYtOKPOJMRvcLQZLN1WJPN1qTET6PNvcEGwpRH69SQNgP4rCEwh3uOw)DYczpp)DIKnfrk4wVKqlzoa3akdxE19EeAy0E4c7YdxOopCYeNg9B1fpepAvRw91Qdno6R0lbWxStZ6sAKRnVU9bYZ8bkDlV932d8(4EKRvk8okPxDrh(bPi(Pk7RxmVEC0WP1jLWu1P2hfxN1PlQYUppcn7752tQL2BcV0JANj8Z59ZxIWyPLn5ojuA)gcntHXY2If0euZIIKvpkwJ36COymzVS0LkOYltGekhT9vOMg60QNtGTAjK(VEiUgvSCi5IE9UUgo6BGUb(oyPqkgC4S9Zi492i2FNhHD4oIAzx9aXxyxeNH1XiW(opUi0UkMEsD6Cj0E9f9SRgKtcQa37K015KGoKBc1UUhhDjxrqXK(NKJLNDgB(969OKBB8Q20zCtHCJTOoZuz2P3FjEKdI3Sb3fsUDtIhHEDCPqwC9E8z76MwUjEC78h4wCFGDueEq1ei9IZywzpEy1x9HzZvz4Z2bcYGS6HvWp8dTZWtkeBdRVeRwqWHvRzN9n85BytxRGz1dR2B7NGpRaQ)Jcv9UhCPbXzv74RHWOr(SoO6uquSz6vXauVHMt4oMbG7hlC3VVDoAIx1ZNINjcL(BAB1Y29X6Cp10DebHdatFKr4OMIJrrvNP8W5uA5rX56O60KSWyk)bys5rO42fcB07K1XPP9F6Xu50Jj50JP2PhtIPhZxSPhdftpgetpgdA6XCk)e7aME(lfheV4OGhXF6H)GP8XP7cWHhOVIt8ho6VSQgO6Cm8ZKIMvtXhw9FdpYhaoYZVOC9OTog1RfXP3Ipf7aoP69fk1nNij6qRd3P5b99QkDnvI0SMnv4iRngY9PNiIicK)275awCV1K)K2PJ5AQM5AQyy2lQ1uhZ1SdMBREvLMc5CYuHtH3yi3JgZfBKfeeaBrB6pZXDiO1LvJPDWd7YzW0Yyr(xToAvZQpTv)O8brJlAGYZGg2gLhTLoqHlsdLOCBVqr4mjvItLP(q70uBNepiYvSbUtuTjXtvT3XMZ7tFlEaWk7CM8LWP9c53cNwk2dWyP)8hNxUDbvHcZvzHGW5EEAo(ony56vx93PEDgGJmqQOUSsovrb86ocSWPlVdwFjEkXQE5kM)ZlV7R2j4SD6Y7yX75hIBgoe3gECVFFA1wS(E8CBdc4S43sJdHAclPkUm4pynoWApsbR9)x(Ohi8vW4Vhhb9gR43tSafa0Sy6IRMBHQDHX3MQdDr33sylw4ar(vpDB(IGC5Q3vHBzrdevPLklbS8cPhg2hbEXp9DiY3CsM)(zc9ePmUiRNiNqgc0)f1O3yaucxolJei(jcUqvomKzbvpNutE(P1qbLm8OP3RvdO8PNscx5IjHNqktoRosWlxmj8ecehj4nj428jLvcAHC52c2dFH2tA4BEsFvt3NoVhV5j9C4V70H8z1t6OT90Ph0JK)5pE09pt5pD8o8oX2Fi8NoE69e7bLykt1rLsQluvLE6YZ1BJDEWqD4rWAl8FY9oX0MoflNKxqyI441beZLhVoGWOXrOduopw)AloSzscQ8iykUL5T6CNr)QVx3rL1nttL72IxDs3gqhQPYcDyRfSupc5FFKvmMKkUNGwNiPQTAqbYQQZjf(tgWVq0D8EVIAKckyr0tBn5fxf89792xtlv)I7RrCsdDnAYshv1ruc1QHDQv0QynXE0oJ6KZ)QRZPf)thYVyuoTQb1nAHk87PQXyUtl0itPHUgnzPJQ6iE3JHddnOYF7xqGSuverV16lpkQZDJAN0SYQOjW)NPkXPg)(GSYdBGc0PQxFhb9TFWPvRrGFRl8dIjy56CSXNu0Kc6XgPXPg)(GC)MuPRxFhb9TFgNWJIBlgclAJt4P)43xHNwUmpr3cqk9lrPSkDh8iPp0Z7(hLbjsndl3JgA7XQB8Nk()zKVD1zNVD1jGV1is2ktk1s7QVUIuiYtwrnPuPebQlgjfwM11tkt9r1lBX7huMpoXjFun6hH8Q89kDtLn2tlYJpP)eOEu20MthV4mMpVJcxMiN3hPnbH4ifCc2eKQxmqjaRE8BBbYZAlqosWFEoebLUZWLLoa3ruRiM7ih)EflhGRmXH6jgUJMzLZiY1HJW)Qa0Il0Q4EcADyDLNSxfaROkNqW1cB)xVwVwx4ZVB6CzHDK0fsjAtAj6tnChnX4ZiY1tyDQG0Q4EcQwzyLv5ecUwy7F2W6LcYZVB6ubHEHEJYK)zcUXzB7KcUwypYSGrch9YThLfSZeCJtv9KcUwypYSGrcxRL29Sg0NuW1c74um7jnpoWN1z2LE7ib)6MUpJrjX14XN3JVpZUeXPYB0RFUavIf9)m5We5(5iLzjQ8a9CsTeXsHpw6EuN66rNliICn(StwZHV8RmlWiOFS6I54Wk8EzhnWU8o2VX(awv9Mpc)XVX(Cyvc2Y)ZL35K4JNiw7L3DXHvVdiIU5xhwnH7vIx6kUz1NHXlRgDQVCy10dRE6PE0xyLENg0Q(krT8o(xN1Lzl)nZUgQAOqymCrXncWSMlugEIwLYfBGv0s6BmhPbfH1kguthkhOy(ah7xto2fhtnTv6Ezcb5N6IbkZB0pRRrYzRJ7Sq7VvpSv3h6ygqZBgts3mu4y6gYXK2Rako57XlBqWbAO5gsaj3FMMC1DZZFy1cWlxnVuJPBgXXqK6YMcg(l4MLM0MfWX5lFBTXHWVqoein6lYPAFTu1MuExhQCCwikUTMqQ6J9ubPBX2BbY4tn43qPyx8jDd8wopA4QY3mVCYhv38tyxymxxFqzCvjtXG5DOw7H)v7NVxWAsBCLAWrneOnvHtbfkDZNxPGjDhiWk(6B4n)q9QEYpnvEpgW6FARCI9FHugB2r8A2NNvwF3AXGM2yJg38QNDOngOqMT7lPyLAQg0QQnMDPizfweK44f33zSo6J8Yz8CnjPSpXxVgXgXAzoNVwvJhP6iizZtos1tRCTQy1BqU(2tJb218DkEfxk3B0YEfwb4VLK5qcFc7(uEj(F3v)c5(waEVfG3Bb49NKa8kmF36QwLfw3C(PJbyrsBSyNUWdv6XHokSxYydPdC7OfBO(a3ocbhs7kyubhA27GdPnon0Gd14GKkuJ6G7(UmcS2dfj(Rw1MUEvNPdx9fkAl9XbkgivJfTts0uvBLXBbt1VakkU4Z7oMK)8hpMgzVNVFC(Re6UJZzaba(ZI6FS7yDjTk6qgO6hfbLrBW6vzqzAZCZzomj9rl8IeNuhbyq7DwikiTR2EyrOm8ffjggt3rCm0yxUPx(YPdPyurO0oacLEEfZaJGTfPkEIckOdN9M9Wzpqa13Lh1oQRh22zzbEwP7IZBrOy9YI3UnWdhnCTP4JHnBFYWlueP2jlzfd8PuVSM2x9sgH)wqo8pMSNzHxbRqpsCb5xpgSCk9Hkl(1z75MbjQqNokafET30V0bmql4og)NYUz0ZG5oAn03gjItcSg0CZNRYZ0a63UUfuu1VM89RSlMY(1FJGfGMHi)70wLZqvhUOQZ94Hv)qB3Enfwe7bZ7zVbrXBUFfqtX9Jkfi89fmT)bYRSZkVy1l7I0gSUeC14J386GBQ1pcvIrFhwHNLiw3Cyf0pZkUp49ZEFA5xLHdRa(WHvrX4XmcDJ5IxN7jEz5jaTyaW6fGxF7vpz(SBMPweaFdajNKTquwEh066zDdL(H5M1ubvBjGIUvXmSz3ZWkEfmh(mSwq6EgUBwJCSadqrsw6UAhlflN)YmOkEffVANL6yLuC7jESlsvg8XaOy5zlzkU91VajfBQHIn5OycVq9v8R6l0GKTAQ3Aygjt9(bxmMPlTq(vRi8vcvaBRvtHqS7)vgggZU5WQFSf)TH)xxtI3U4Qv3DBlQsPvVReQqVPkz5yAQYGJQevSm4cGqv4OdqiL6vswTEri7JCqtGRJRpPE5Kvlzx3N1PD5TdPK2LS8wAxKt7sZAkuLaJJxIs6biv8LETpy9zqRB7UOtpZRYmROnZ1N5mROntpVmjwHoFpke3kPu53IA(0aiK0L)SSTqndpIuRCk28h95VqmfmQZfsh7GJA7jvN8OwF8xLTIqF8CMkXX4oooJihpDSPoc5IPJulDwpRnz1XDKQkcdHvVw9DduB2xAi46i84(EbjfIm33Jio2dDEBK5onnHrDg4OmoJ)VvqoQcPxDi)fXIjlVv)jOQWsdxuZvVawSGQN3ig2rvMYVSaTXL02ZIT7JTo8iIeyp8MYrgDTwm5HJ4l8o9cRRDcOC5rvRaJTQAJMymjxSbEice(u5v4ylgcEuTm756BDPQapLKqn7uI0uJeP5WKin1lrQOkV6LinOLin6sIS9RByFKinBlr2Ar5DjrkyqYSo(8rAetxQjUOBRntukZ0BZu90kzVPqkBeQL9lXyQQKHDuhPyTiIHV(BiiR6MksZ7R4VwNQw5xx2N6CAO9u54MciTa1tdG9McPu)7uGvHW2rEKouHT22tKxhE1ukIb77x5q3FREPkR1060EnjPnMH6HCZWHf5AfKkdDvF25WcA(Ivwe7HKMC9xwt(e1XhXQIashEhFlRJB6aUGLvfpH(oOXTT8xrZYvgt96IuNCpvvawPdhrk8HNuLpn9KjtBP1xBZchNCks1pex8hJs(48Mkj(13S55T)cC2uwRVcNv6VQZFblCMAb566i8n5STHebg0bXDXq8JpAH0C5htfvYY8RaKnZuL3eWycmerkWHJrVppm0lqLSjhqmtqykzMJ5Rhj(W4hkYRHRFXM9ZKmVripBjfl6NoLfQbXKdfCzD(owWYx3VuovL7Jltpa)cIP8x5yheyv8hw4B1BX72BjhUX2qhMh7eHstsmaOtNy90T0uADFeGbfMA9VZD3I8LLDMTpTOT2ElMMdG2CUNrzAou2cAxcN4OId2rPnmJ2jXOi3Ks5NrihgWIH8yvvUwcP(cLbsH1WhyHCB5QQn3xKFsByAKQnHJNSxhe9gQijpICIU5fbpRph0PHrr3(mOOqUdmLskQzvudJOgfBQENOYw21XZAS00Oyu1hk5Qx5liyjqB1K9xl))d]] )