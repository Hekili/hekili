-- WarriorFury.lua
-- November 2022

if UnitClassBase( "player" ) ~= "WARRIOR" then return end

local addon, ns = ...
local Hekili = _G[ addon ]
local L = LibStub("AceLocale-3.0"):GetLocale( addon )
local class = Hekili.Class
local state = Hekili.State

local strformat = string.format

local FindPlayerAuraByID = ns.FindPlayerAuraByID
local IsActiveSpell = ns.IsActiveSpell
local W = ns.WordWrapper

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
    -- Warrior
    berserker_rage            = { 90372, 18499 , 1 }, -- Go berserk, removing and granting immunity to Fear, Sap, and Incapacitate effects for 6 sec.
    berserker_shout           = { 90348, 384100, 1 }, -- Go berserk, removing and granting immunity to Fear, Sap, and Incapacitate effects for 6 sec. Also remove fear effects from group members within 12 yards.
    bitter_immunity           = { 90356, 383762, 1 }, -- Restores 20% health instantly and removes all diseases, poisons and curses affecting you.
    blood_and_thunder         = { 90342, 384277, 1 }, -- Thunderclap costs 10 more Rage and deals 10% increased damage.
    bounding_stride           = { 90355, 202163, 1 }, -- Reduces the cooldown of Heroic Leap by 15 sec, and Heroic Leap now also increases your movement speed by 70% for 3 sec.
    cacophonous_roar          = { 90383, 382954, 1 }, -- Intimidating Shout can withstand 200% more damage before breaking.
    crackling_thunder         = { 90342, 203201, 1 }, -- Thunder Clap's radius is increased by 50%, and it reduces movement speed by an additional 20%.
    cruel_strikes             = { 90381, 392777, 2 }, -- Critical strike chance increased by 1% and critical strike damage of Execute increased by 5%.
    double_time               = { 90382, 103827, 1 }, -- Increases the maximum number of charges on Charge by 1, and reduces its cooldown by 3 sec.
    elysian_might             = { 90323, 386285, 1 }, -- Spear of Bastion's duration is increased by 2 sec. While you remain within Spear of Bastion's area your critical strike damage is increased by 25%.
    fast_footwork             = { 90371, 382260, 1 }, -- Movement speed increased by 5%.
    furious_blows             = { 90336, 390354, 1 }, -- Auto-attack speed increased by 5%.
    heroic_leap               = { 90346, 6544  , 1 }, -- Leap through the air toward a target location, slamming down with destructive force to deal 481 Physical damage to all enemies within 8 yards.
    impending_victory         = { 90326, 202168, 1 }, -- Instantly attack the target, causing 1,024 damage and healing you for 30% of your maximum health. Killing an enemy that yields experience or honor resets the cooldown of Impending Victory and makes it cost no Rage.
    inspiring_presence        = { 90332, 382310, 1 }, -- Rallying Cry's duration is increased by 3 sec and it grants an additional 5% maximum health.
    intervene                 = { 90329, 3411  , 1 }, -- Run at high speed toward an ally, intercepting all melee and ranged attacks against them for 6 sec while they remain within 10 yds.
    intimidating_shout        = { 90384, 5246  , 1 }, -- Causes the targeted enemy to cower in fear, and up to 5 additional enemies within 8 yards to flee. Targets are disoriented for 8 sec.
    leeching_strikes          = { 90344, 382258, 1 }, -- Leech increased by 5%.
    menace                    = { 90383, 275338, 1 }, -- Intimidating Shout will knock back all nearby enemies except your primary target, and cause them all to cower in fear for 15 sec instead of fleeing.
    overwhelming_rage         = { 90378, 382767, 2 }, -- Maximum Rage increased by 15.
    pain_and_gain             = { 90353, 382549, 1 }, -- When you take any damage, heal for 3.50% of your maximum health. This can only occur once every 10 sec.
    piercing_howl             = { 90348, 12323 , 1 }, -- Snares all enemies within 12 yards, reducing their movement speed by 70% for 8 sec.
    piercing_verdict          = { 90379, 382948, 1 }, -- Spear of Bastion's instant damage increased by 50% and its Rage generation is increased by 100%.
    rallying_cry              = { 90331, 97462 , 1 }, -- Lets loose a rallying cry, granting all party or raid members within 40 yards 15% temporary and maximum health for 10 sec.
    reinforced_plates         = { 90368, 382939, 1 }, -- Armor increased by 20%.
    rumbling_earth            = { 90374, 275339, 1 }, -- Shockwave's range increased by 6 yards and when Shockwave strikes at least 3 targets, its cooldown is reduced by 15 sec.
    second_wind               = { 90332, 29838 , 1 }, -- Restores 6% health every 1 sec when you have not taken damage for 5 sec.
    seismic_reverberation     = { 90340, 382956, 1 }, -- If Whirlwind hits 3 or more enemies, it hits them 1 additional time for 30% damage.
    shattering_throw          = { 90351, 64382 , 1 }, -- Hurl your weapon at the enemy, causing 2,048 Physical damage, ignoring armor, and removing any magical immunities. Deals up to 500% increased damage to absorb shields.
    shockwave                 = { 90375, 46968 , 1 }, -- Sends a wave of force in a frontal cone, causing 409 damage and stunning all enemies within 10 yards for 2 sec. Generates 10 Rage.
    sonic_boom                = { 90321, 390725, 1 }, -- Shockwave deals 350% increased damage and will always critical strike.
    spear_of_bastion          = { 90380, 376079, 1 }, -- Throw a spear at the target location, dealing 3,380 Physical damage instantly and an additional 3,789 damage over 4 sec. Deals reduced damage beyond 5 targets. Enemies hit are chained to the spear's location for the duration. Generates 20 Rage.
    spell_reflection          = { 90385, 23920 , 1 }, -- Raise your weapon, reflecting the first spell cast on you, and reduce magic damage you take by 20% for 5 sec.
    storm_bolt                = { 90337, 107570, 1 }, -- Hurls your weapon at an enemy, causing 584 Physical damage and stunning for 4 sec.
    thunderous_roar           = { 90359, 384318, 1 }, -- Roar explosively, dealing 3,278 Physical damage to enemies within 12 yds and cause them to bleed for 4,039 physical damage over 8 sec. Generates 10 Rage.
    thunderous_words          = { 90358, 384969, 1 }, -- Increases the duration of Thunderous Roar's Bleed effect by 2.0 sec and increases the damage of your bleed effects by 15% at all times.
    titanic_throw             = { 90341, 384090, 1 }, -- Throws your weapon at the enemy, causing 717 Physical damage to it and 5 nearby enemies. Generates high threat.
    uproar                    = { 90357, 391572, 1 }, -- Thunderous Roar's cooldown reduced by 30 sec.
    wild_strikes              = { 90360, 382946, 2 }, -- Haste increased by 1% and your auto-attack critical strikes increase your auto-attack speed by 10% for 10 sec.
    wrecking_throw            = { 90351, 384110, 1 }, -- Hurl your weapon at the enemy, causing 2,048 Physical damage, ignoring armor. Deals up to 500% increased damage to absorb shields.

    -- Fury
    anger_management          = { 90415, 152278, 1 }, -- Every 20 Rage you spend reduces the remaining cooldown on Recklessness and Ravager by 1 sec.
    annihilator               = { 90419, 383916, 1 }, -- Your auto-attacks deal an additional 271 Physical damage and generate 4 Rage.
    armored_to_the_teeth      = { 90258, 384124, 2 }, -- Gain Strength equal to 5% of your Armor.
    ashen_juggernaut          = { 90409, 392536, 1 }, -- Execute increases the critical strike chance of Execute by 10% for 15 sec, stacking up to 5 times.
    avatar                    = { 92640, 107574, 1 }, -- Transform into a colossus for 20 sec, causing you to deal 20% increased damage and removing all roots and snares. Generates 10 Rage.
    barbaric_training         = { 92222, 390674, 1 }, -- Slam and Whirlwind deal 20% increased damage and 10% increased critical strike damage.
    berserker_stance          = { 90325, 386196, 1 }, -- An aggressive combat state that increases the damage of your auto- attacks by 15% and reduces the duration of Fear, Sap and Incapacitate effects on you by 10%. Lasts until canceled.
    berserkers_torment        = { 90362, 390123, 1 }, -- Activating Avatar or Recklessness casts the other at reduced effectiveness.
    bloodborne                = { 90401, 385703, 1 }, -- Bleed damage of Odyn's Fury, Thunderous Roar and Gushing Wound increased by 20%.
    bloodcraze                = { 90405, 393950, 1 }, -- Bloodthirst increases the critical strike chance of your next Bloodthirst by 15%. Stacking up to 5 times.
    bloodthirst               = { 90392, 23881 , 1 }, -- Assault the target in a bloodthirsty craze, dealing 1,809 Physical damage and restoring 3% of your health. Generates 8 Rage.
    cold_steel_hot_blood      = { 90402, 383959, 1 }, -- Bloodthirst critical strikes generate 4 additional Rage, and inflict a Gushing Wound that leeches 1,659 health over 6 sec.
    concussive_blows          = { 90335, 383115, 1 }, -- Cooldown of Pummel reduced by 1.0 sec. Successfully interrupting an enemy increases the damage you deal to them by 5% for 10 sec.
    critical_thinking         = { 90425, 383297, 2 }, -- Critical Strike chance increased by 1.0% and Raging Blow and Annihilator's damaging critical strikes deal 5.0% increased damage.
    cruelty                   = { 90428, 392931, 1 }, -- While Enraged, Raging Blow deals 15% increased damage and Annihilator deals 10% increased damage.
    crushing_force            = { 90349, 382764, 2 }, -- Slam deals an additional 30% damage and has a 7.50% increased critical strike chance.
    dancing_blades            = { 90417, 391683, 1 }, -- Odyn's Fury increases your auto-attack damage and speed by 30% for 10 sec.
    defensive_stance          = { 92538, 386208, 1 }, -- A defensive combat state that reduces all damage you take by 15%, and all damage you deal by 10%. Lasts until canceled.
    deft_experience           = { 90421, 383295, 2 }, -- Mastery increased by 1% and Bloodthirst cooldown reduced by 0.75 sec.
    depths_of_insanity        = { 90413, 383922, 1 }, -- Recklessness lasts 4.0 sec longer.
    dual_wield_specialization = { 90373, 382900, 1 }, -- Increases your damage while dual wielding by 5%.
    endurance_training        = { 90376, 391997, 1 }, -- Increases Stamina by 5% and reduces the duration of movement impairing effects on you by 10.0%.
    enraged_regeneration      = { 90395, 184364, 1 }, -- Reduces damage taken by 30%, and Bloodthirst restores an additional 20% health. Usable while stunned or incapacitated. Lasts 8 sec.
    focus_in_chaos            = { 90403, 383486, 1 }, -- While Enraged, your auto-attacks can no longer miss.
    frenzied_flurry           = { 90422, 383605, 1 }, -- Increases auto-attack damage with one-handed weapons by 30% and your auto-attack critical strikes have a 50% chance to Enrage you.
    frenzy                    = { 90406, 335077, 1 }, -- Rampage increases your Haste by 2% for 12 sec, stacking up to 4 times. This effect is reset if you Rampage a different primary target.
    fresh_meat                = { 90399, 215568, 1 }, -- Bloodthirst always Enrages you the first time you strike a target, and it has a 15% increased chance to trigger Enrage.
    frothing_berserker        = { 90350, 215571, 1 }, -- Rampage has a 20% chance to immediately refund 20% of the Rage spent.
    hack_and_slash            = { 90407, 383877, 1 }, -- Each Rampage strike has a 25% chance to refund a charge of Raging Blow.
    honed_reflexes            = { 90367, 391270, 1 }, -- Cooldown of Raging Blow and Pummel reduced by 1.0 sec.
    hurricane                 = { 90389, 390563, 1 }, -- While Ravager is active, every 0.8 sec you gain 5% movement speed and 5% Strength, stacking up to 6 times. Lasts 6 sec.
    improved_bloodthirst      = { 90397, 383852, 1 }, -- Bloodthirst damage increased by 10%.
    improved_enrage           = { 90398, 383848, 1 }, -- Enrage increases your Haste by 15% and increases your movement speed by 10%.
    improved_execute          = { 90430, 316402, 1 }, -- Execute no longer costs Rage and now generates 20 Rage.
    improved_raging_blow      = { 90390, 383854, 1 }, -- Raging Blow has 2 charges and has a 20% chance to instantly reset its own cooldown.
    improved_whirlwind        = { 90427, 12950 , 1 }, -- Whirlwind causes your next 2 single-target attacks to strike up to 4 additional targets for 50% damage. Whirlwind generates 3 Rage, plus an additional 1 per target hit. Maximum 8 Rage.
    invigorating_fury         = { 90393, 383468, 1 }, -- Enraged Regeneration lasts 3 sec longer and instantly heals for 15% of your maximum health.
    massacre                  = { 90410, 206315, 1 }, -- Execute is now usable on targets below 35% health, and its cooldown is reduced by 1.5 sec.
    meat_cleaver              = { 90391, 280392, 1 }, -- Whirlwind deals 25% more damage and now affects your next 4 single-target melee attacks, instead of the next 2 attacks.
    odyns_fury                = { 90418, 385059, 1 }, -- Unleashes your power, dealing 4,578 Physical damage and an additional 1,720 Physical damage over 4 sec to all enemies within 12 yards. Generates 15 Rage.
    onslaught                 = { 90424, 315720, 1 }, -- Brutally attack an enemy for 4,348 Physical damage. Generates 30 Rage.
    raging_armaments          = { 90426, 388049, 1 }, -- Raging Blow gains an extra charge.
    raging_blow               = { 90396, 85288 , 1 }, -- A mighty blow with both weapons that deals a total of 2,526 Physical damage. Raging Blow has a 20% chance to instantly reset its own cooldown. Generates 14 Rage.
    rampage                   = { 90408, 184367, 1 }, -- Enrages you and unleashes a series of 4 brutal strikes for a total of 3,420 Physical damage.
    ravager                   = { 90388, 228920, 1 }, -- Throws a whirling weapon at the target location that chases nearby enemies, inflicting 10,424 Physical damage to all enemies over 9.7 sec. Deals reduced damage beyond 8 targets. Generates 10 Rage each time it deals damage.
    reckless_abandon          = { 90415, 396749, 1 }, -- Recklessness generates 50 Rage and Rampage greatly empowers your next 2 Bloodthirsts or Raging Blows.
    recklessness              = { 90412, 1719  , 1 }, -- Go berserk, increasing all Rage generation by 100% and granting your abilities 20% increased critical strike chance for 12 sec.
    sidearm                   = { 90335, 384404, 1 }, -- Your auto-attacks have a 20% chance to hurl weapons at your target and 3 other enemies in front of you, dealing an additional 512 Physical damage.
    singleminded_fury         = { 90400, 81099 , 1 }, -- While dual-wielding a pair of one-handed weapons, your damage done is increased by 5% and your movement speed is increased by 5%.
    slaughtering_strikes      = { 90411, 388004, 1 }, -- Raging Blow causes every strike of your next Rampage to deal an additional 20% damage, stacking up to 5 times. Annihilator causes every strike of your next Rampage to deal an additional 2% damage, stacking up to 5 times.
    storm_of_steel            = { 90389, 382953, 1 }, -- Ravager's damage is reduced by 30% but it now has 2 charges and generates 20 Rage each time it deals damage.
    storm_of_swords           = { 90420, 388903, 1 }, -- Whirlwind has a 7.0 sec cooldown, but deals 80% increased damage. Slam has a 12.0 sec cooldown and generates 10 Rage, but deals 100% increased damage.
    sudden_death              = { 90429, 280721, 1 }, -- Your attacks have a chance to reset the cooldown of Execute and make it usable on any target, regardless of their health.
    swift_strikes             = { 90416, 383459, 2 }, -- Increases haste by 1%, Raging Blow generates an additional 1 Rage and Annihilator generates an 1 additional Rage.
    tenderize                 = { 90423, 388933, 1 }, -- Onslaught Enrages you, and if you have Slaghtering Strikes grants you 3 stacks of Slaughtering Strikes. Enrage now lasts 2 sec longer.
    thunder_clap              = { 92223, 396719, 1 }, -- Blasts all enemies within 8 yards for 1,230 Physical damage. and reduces their movement speed by 20% for 10 sec. Deals reduced damage beyond 5 targets.
    titanic_rage              = { 90417, 394329, 1 }, -- Odyn's Fury's Enrages you, deals 10% increased damage and grants you 2 stacks of Whirlwind.
    titans_torment            = { 90362, 390135, 1 }, -- Activating Avatar casts Odyn's Fury, activating Odyn's Fury casts Avatar at reduced effectiveness.
    unbridled_ferocity        = { 90414, 389603, 1 }, -- Rampage and Onslaught have a 20% chance to grant Recklessness for 4 sec.
    vicious_contempt          = { 90404, 383885, 2 }, -- Bloodthirst deals 25% increased damage to enemies who are below 35% health.
    war_machine               = { 90386, 346002, 1 }, -- Your auto attacks generate 20% more Rage. Killing an enemy instantly generates 5 Rage, and increases your movement speed by 30% for 8 sec.
    warpaint                  = { 90394, 208154, 1 }, -- You take 10% reduced damage while Enrage is active.
    wrath_and_fury            = { 90387, 392936, 1 }, -- Raging Blow deals 15% increased damage and while Enraged, Raging Blow has a 30% chance to instantly reset its own cooldown.
} )


-- PvP Talents
spec:RegisterPvpTalents( {
    barbarian            = 166 , -- (280745) For 3 sec after casting Heroic Leap, you may cast the spell a second time without regard for its cooldown. Increases the damage done by your Heroic Leap by 200%.
    battle_trance        = 170 , -- (213857) You go into a trance causing you to regenerate 3% of your health and generate 3 Rage every 3 sec for 18 sec after using Raging Blow twice in a row on a target. Attacking a new target with Raging Blow will cancel this effect.
    bloodrage            = 172 , -- (329038) You gain 40 Rage over 4 sec, and all snares and roots are cleared from you, but at a cost of 5% of your health.
    death_sentence       = 25  , -- (198500) Execute charges you to targets up to 15 yards away. This effect has a 6 sec cooldown.
    death_wish           = 179 , -- (199261) Increases your damage taken and done by 5% for 15 sec at the cost of 5% of your health. Stacks up to 10 times.
    demolition           = 5373, -- (329033) Reduces the cooldown of your Shattering Throw or Wrecking Throw by 50% and increases its damage to absorb shields by an additional 250%.
    disarm               = 3533, -- (236077) Disarm the enemy's weapons and shield for 6 sec. Disarmed creatures deal significantly reduced damage.
    enduring_rage        = 177 , -- (198877) Increases the duration of your Enrage effect by 1 sec, and your Raging Blows extend the duration of your Enrage by 1.5 sec.
    master_and_commander = 3528, -- (235941) Cooldown of Rallying Cry reduced by 1 min, and grants 15% additional health.
    rebound              = 5548, -- (213915) Reflecting spells causes them to deal 50% extra damage back to the attacker.
    slaughterhouse       = 3735, -- (352998) Rampage damage reduces healing the target receives by 3% for 12 sec, stacking up to 12 times.
    warbringer           = 5431, -- (356353) Charge roots enemies for 2 sec and emanates a shockwave past the target, rooting enemies and dealing 4,701 Physical damage in a 15 yd cone.
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
        duration = function () return 10 + ( talent.inspiring_presence.enabled and 3 or 0 ) end,
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
        max_stack = 2,
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
            return stat.crit + ( 15 * buff.bloodcraze.stack ) + ( 10 * buff.merciless_assault.stack ) + ( 20 * buff.recklessness.stack )
        end,

        handler = function ()
            removeStack( "whirlwind" )
            removeStack( "reckless_abandon" )

            if talent.cold_steel_hot_blood.enabled and stat.crit >= 100 then
                applyDebuff( "target", "gushing_wound" )
                gain( 4, "rage" )
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
            return stat.crit + ( 15 * buff.bloodcraze.stack ) + ( 10 * buff.merciless_assault.stack ) + ( 20 * buff.recklessness.stack )
        end,

        handler = function ()
            removeStack( "whirlwind" )

            if talent.cold_steel_hot_blood.enabled and action.bloodthirst.crit_pct_current >= 100 then
                applyDebuff( "target", "gushing_wound" )
                gain( 4, "rage" )
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
        spentType = "rage",

        startsCombat = true,
        texture = 132337,

        usable = function () return target.distance > 10 and ( query_time - action.charge.lastCast > gcd.execute ) end,
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
            removeStack( "reckless_abandon" )
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
            if talent.dancing_blades.enabled then applyBuff( "dancing_blades" ) end
            if talent.titanic_rage.enabled then
                applyBuff( "enrage" )
                applyBuff( "whirlwind", nil, talent.meat_cleaver.enabled and 4 or 2 )
            end
            if talent.titans_torment.enabled then applyBuff( "avatar", 4 ) end
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

            gain( ( talent.inspiring_presence.enabled and 0.25 or 0.15 ) * health.max, "health" )
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
            if talent.frenzy.enabled then addStack( "frenzy" ) end
            if talent.reckless_abandon.enabled then addStack( "reckless_abandon", nil, 2 ) end
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
        cooldown = function () return talent.storm_of_swords.enabled and 12 or 0 end,
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
            if settings.check_ww_range and target.outside7 then return false, "target is outside of whirlwind range" end
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
    name = L["Check |T132369:0|t Whirlwind Range"],
    desc = L["If checked, when your target is outside of |T132369:0|t Whirlwind's range, it will not be recommended."],
    type = "toggle",
    width = "full"
} )

spec:RegisterSetting( "shockwave_interrupt", true, {
    name = L["Only |T236312:0|t Shockwave as Interrupt"],
    desc = L["If checked, |T236312:0|t Shockwave will only be recommended when your target is casting (and talented)."],
    type = "toggle",
    width = "full"
} )


spec:RegisterSetting( "t30_bloodthirst_crit", 95, {
    name = strformat( L["%s Critical Threshold (Tier 30)"],
        Hekili:GetSpellLinkWithTexture( spec.abilities.bloodthirst.id ) ),
    desc = strformat( L["By default, if you have four pieces of Tier 30 equipped, %s and %s will be recommended when their chance to crit is |cFFFFD10095%%|r or higher."],
        W( spec.abilities.bloodthirst.name ), W( spec.abilities.bloodbath.name ) ) .. "\n\n"
        .. strformat( L["Your tier set, %s, and %s can bring you over the 95%% threshold."],
        Hekili:GetSpellLinkWithTexture( spec.talents.recklessness[2] ), Hekili:GetSpellLinkWithTexture( spec.talents.bloodcraze[2] ) ) .. " "
        .. strformat( L["If %1$s is talented, these crits will proc a %2$s for additional damage."],
        W( Hekili:GetSpellLinkWithTexture( spec.talents.cold_steel_hot_blood[2] ) ), Hekili:GetSpellLinkWithTexture( spec.auras.gushing_wound.id ) ) .. " "
        .. L["Lowering this percentage slightly may be helpful if your base Critical Strike chance is very low."] .. " "
        .. L["However, if set too low, you may use these abilities but fail to crit."],
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
    name = L["Use Heroic Charge Combo"],
    desc = L["If checked, the default priority will check |cFFFFD100settings.heroic_charge|r to determine whether to use |T236171:0|t Heroic Leap + |T132337:0|t Charge together."] .. "\n\n"
        .. L["This is generally a DPS increase but the erratic movement can be disruptive to smooth gameplay."],
    type = "toggle",
    width = "full",
} )


spec:RegisterPack( "Fury", 20230514, [[Hekili:TZ1xVTnos8plbloNeCTosY2PP9AcWDlWHRbl6dN79QLPLOT1vzjVsujTfg6Z(nuYsIKIJOSJD29wSpSlIfhoZW5V)iPQMzp7lZM6ty0zF2XYzK1e7XdThp69JE3SPSVVLoB6wI3xjRG)iISb())ZSKVZF43dJj(8jNgNL4bdSMX2M(HBUzvaBD2IHEXBUjnytwiHfeh5LqwY4)27MztxKfeY(u0Sf6L8TZMsYyRJtMnDAWMFg4CGVpTKCAQ3SPCYFR1K3Ap(d5ZZN)399ZNNgg4ttYNVmg(FFjG)NJSYN7LeWYN)xGXPmwq0QH5pM)y18TkN))zlxlsZNNqbLLcmJf3Wd5z4imJ9cZ2AOTarJERZTfe9PiVWmFGQPBPHH5Z)30LHupUX4VXf1M4NGX(x0K4aV85)cLSDiywtIxgecgtsbHPd3Mqbd5cc7VE)nlOjP0KVstCtzKipA(JAPIWyHu301Xzm9uKLsDdy0nVH7qVNeUIYwtsC3M9JFatCr830pnYtegj5nblV)cgjKgXgYca9i1LfNSb(P(zb)5xdPPPrW)jo3QN7swqI8JJ4gW9ZhMLhOqROC6zbBOF8ERHt2TJBX4cAOFqPb4H7YF8N(P85nZBDH50neSM8jFvcjW3L(eFsTNTZKb6gpi6HXtUwuB2MTzdnu8jPCxQBsThvI6y1N4fh9RzGMLK6cl2iiUsyqn2FUQ7fhh6h)C0qrdi8JnKGO0poA3UR2BijrRGiInKiihLR)dQNzPdRzosRPGeiFjl1DzczfFACzUiB5sz5LTvCoGqaJ7QKa6sWN7TUEo7LexQI0VkK4hqyLRB)s)zNRRhSTgCLoTy3UfXPPdwgSAnZTAbzBR7XpCRSZRkApv8HjGgdMnJke3qBYQqs8iruEwqYE7iysPFCS1Glmn1qUIN6(FZ87WhOAv3xgakM1hF2IW4yF3LqrBjDgI)tzjKqxpsOuK9YGeAXCutTwqw5gV0LLe491uCnDqXJPrCBGQHQUaI26hkZum3K47NYZlTHQa6l(CaHnowsXhTkqPkx63GcgPdAY3IcwheYdRrt1GatKHEySvZsOCi9X2ohLsErBLeH9kvZG6pGZDbjL)SAVBJZaZ8kK9JAU3TJlQNOU0i6MakKLFTENRuntiU0T8NUHWARSzfaNGf4Y4nhyVjLhlYU3MRUksWXmRsHeiOCBjVe6(muugAm9iHLQlrtMDvXe7)DiAMNNQz5ypqmOhQbZDldUQS(YgkH56bT8EIMO3POX1DnQI886GKWNdI856rzFUYXshwpuJcfSbGS8e13TESbiAvB72hDouUGQ00Vr9Yy0MgsPRPrqD1vqr(iamjpew)avUMvE(OChWZgbGlJH2LjXLvWutpqnu6w4qadU93qGqFksIY7Ic7aUSIo3aIyaSruwkevrtgz5oER3GYjoSGqgSkszd5qOD36b(HSIoCpCVWOUfJYwNqbaNH4MqHP8QlBVKS01q2Ulm3NfA)8CcyjCb0NfwBSgxMc1mpdzp6lYbMq2SLSII14FFU(EUleAdWf5p6bBaG1(vpKVL88AA4gULHp41veDNvDFK2ezYU0VypfJaYEcQvdzpvFdYefcVvSiM5ME4AbP1r6zuAijdkQlUzgr(jV02TRQYnLxcj4h4giygIbPLBbsO2FpncTI2pwgH6WkTLhOVPLA1VqG(6RpqTbXwFVTPmp0XHOInc1weIimBG7JA2pdR5U6IiDKGa9)nT(v16tCVFv2FEB(RkTo7vC4cQExl(Wo(kdsi(00s7H8ZQTgc7XsMIouBH(syhlrx7GqxdRINaT(F4UUSxVIiA0k6xlinMc61GcPvOLyNR(3LsLnVq0uMJCAHc48e5yoK1O1VNHL9RtNrWogI)onODABLooqjgJAoAo9cHLyuX6N3Q3ULdvFWm4gdKXjOpqtqTY9st7P5TxgTEapPds4(jU4GsODjVu(XgcLRdzZMc4lsbIQUfkRXZM(mjjcMr6SPFznnFoGrjoHT)6EUuIxxYVkNFnliHFTrPXBaQbKfXBkVhjW7b1ushM)4Veebdz)H85)CCeiXIHVefd0LL3bfobqekzriLt4v2F76xrjmwVeKHkOWDfKgV6CEIEoRwWxH3QdJX93RN719svyB9Zr9Hw6zOCjefUkpikRrIpulVPWC1HrzVZz1qBJeHCQ0Ee2FkS7OrG11IBztQhbLP3E(033D(y9DNpwJKjEIIpCoF5LoJoPXh5pQPVL4jcC5b12cjRw8YiuRXjme2AgzjFcBvD(Lasa3jiIaRuARtKvH7Tg)3ob8NvR7t16ZctpESh)HQW)jG1yf9prrXoiaYofAoscYrgWPTNIpDjbARC5b1obnr40asejmt(9frnVqAWFlynse8r6SmW0I3nav(v(cdCGPbhP(PnyQ(1g8WcNqcZpbofK2aV4u)8h)uXcNZ0XvVJv5Z5VBk8L1SPf)vX7wR4znap4ZfVUU7z4S)XSP8ZlgkOtas1F3a5ZFaceYNpauYs9dhDtbvxKpx79VmF3oWT06wgYN)ri64LZ)Qx51ztRN2m2Sp7GUEXURNcH0599uOYR88hUH8TgXU)mD5cDu3cT5uT5I6kieTBtpMHJp6K85x3Odk31exxg)6QlvSzVVu)XR0yI1Ffsfg4jLc7cJ8sy93C7x8L(e0LUHwcvlcDN1DPwP5UdeJkQStL3JqH15ozp1(dDLRM3INsQ5kHk0TECTqGqVh0t0RgQrvQpQwUY8UFpOmL0WvN76z0R20W33Zjx6TQQSRIWvi6Q6cW4m32Yu0LEuwnX(AuEPt7Uqk41Rn0T41ng2gVoRHCn9SROcQQlvG)CAoOkB9XA1uQrVRdjLXgVoJ61lvAtBkpQbJJupUw(TRrZuSXlJS)oGA3j30Yu4gAkebEXHJweTJ47xkFJ18y9A9V6G5WNowpo41joqnVXx7GxvqYrG6jDCeZVQs8KZVCWrXGh92Wu(LgwWMXIIQXfOiSjYkuJ2Qq3TI0jBSvO8DTK7EdOcD3jsxd2rfQEVevs3sOcPJSejv8Icfjd(P45P2n08oaCXZa4YQ5D8vePg)viVi(v61iVOkpuXUXEluMPBqZ6fvtcIUZTTQtuNBmOeWD17CUWZ6QeOmCp841)yU1gd9)opBTPF96ozBNOrh0S1g8oEOHPAusuXJfN97ciYvTXW7w(kQmnDMWBQEkbfJ3sTh7kOdi1NIOJoqc)cHIFvjA8s5BBjwxb9ovk2rU6KVZsbUBxt)pXNF2XNFHr5Dk2V6za8U6(dWlgD0IODYF)WT)I3Fqh42p8W3owpDGL)a1CH9hGxdQXrCFNBqyup2GaEc(bTbHj9Adc32Zni8UEVbH(a8NX)KruCfvDJqN)vgaQyd2uRH7rL367fqzTxbLRWvuJ3U6XLFSauuwj3H6hpafAL2Wv5htafkKS4T(4cOqChNRqx)lFVO)1O2fu74exr(N8CfNeQTQ5BEq3iZ0vTUHDQFld6gyL4wv4QBdFu)(g0nIidMpELsRECkEDSfpd7ceKWTYGSv)Gl0G2QII6VgcQD774ij6Bys3oP9FYfmGXQeKdWZXwD1Pwius6RVqd4MEggjhaO89yOpWGqvSMptdnGyKQswc5uXnivMu(R0GkPsvkR)SnOsfEEG4w(BDvOh8UTuBw3bBp28bhl5IifPWgWuCrBvU8tLqLMya5wx102NEIsYdLrXY2f5Rz34A22rgdV6j905Pt2Xk3aMvJAvhQ0bT)mZ3WH6Hk1D8b(5PDDF3pO6xdddiY0inh(5gY)2uWHC00Ow5Zqr5187w(v1s6WezAo92EXf5xxGc4p1Vuf1aGukqv)5KsfFLeTcFuP0bTrqrl1eDD4n1(hVsRPYk6kkGVRXloa8(kr3fMuiaXdaR4u8Rz)V)]] )