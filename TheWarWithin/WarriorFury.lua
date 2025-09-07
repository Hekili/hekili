-- WarriorFury.lua
-- August 2025
-- Patch 11.2

if UnitClassBase( "player" ) ~= "WARRIOR" then return end

local addon, ns = ...
local Hekili = _G[ addon ]
local class, state = Hekili.Class, Hekili.State
local spec = Hekili:NewSpecialization( 72 )

---- Local function declarations for increased performance
-- Strings
local strformat = string.format
-- Tables
local insert, remove, sort, wipe = table.insert, table.remove, table.sort, table.wipe
-- Math
local abs, ceil, floor, max, sqrt = math.abs, math.ceil, math.floor, math.max, math.sqrt

-- Common WoW APIs, comment out unneeded per-spec
-- local GetSpellCastCount = C_Spell.GetSpellCastCount
-- local GetSpellInfo = C_Spell.GetSpellInfo
-- local GetSpellInfo = ns.GetUnpackedSpellInfo
-- local GetPlayerAuraBySpellID = C_UnitAuras.GetPlayerAuraBySpellID
-- local FindUnitBuffByID, FindUnitDebuffByID = ns.FindUnitBuffByID, ns.FindUnitDebuffByID
-- local IsSpellOverlayed = C_SpellActivationOverlay.IsSpellOverlayed
-- local IsSpellKnownOrOverridesKnown = C_SpellBook.IsSpellInSpellBook
-- local IsActiveSpell = ns.IsActiveSpell

-- Specialization-specific local functions (if any)
local FindPlayerAuraByID = ns.FindPlayerAuraByID
local LSR = LibStub("SpellRange-1.0")
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
            local baseAmt = base_rage_gen * fury_rage_mult * ( state.talent.war_machine.enabled and 1.2 or 1 ) -- "static" amount
            return ( baseAmt * ( state.buff.recklessness.up and 2 or 1 ) * state.swings.mainhand_speed ) -- Dynamic factors
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
            local baseAmt = base_rage_gen * fury_rage_mult * ( state.talent.war_machine.enabled and 1.2 or 1 ) -- "static" amount
            return ( baseAmt * ( state.buff.recklessness.up and 2 or 1 ) * state.swings.offhand_speed * offhand_mod ) -- Dynamic factors
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
    armored_to_the_teeth           = {  90366,  384124, 2 }, -- Gain Strength equal to $s1% of your Armor
    avatar                         = {  90365,  107574, 1 }, -- Transform into a colossus for $s1 sec, causing you to deal $s2% increased damage and removing all roots and snares. Generates $s3 Rage
    barbaric_training              = {  90340,  383082, 1 }, -- Slam and Whirlwind deal $s1% more damage and $s2% increased critical strike damage
    berserker_shout                = {  90348,  384100, 1 }, -- Go berserk, removing and granting immunity to Fear, Sap, and Incapacitate effects for $s1 sec. Also remove fear effects from group members within $s2 yds
    berserker_stance               = {  90325,  386196, 1 }, -- An aggressive combat state that increases the damage of your auto-attacks by $s1% and reduces the duration of Fear, Sap and Incapacitate effects on you by $s2%. Lasts until canceled
    berserkers_torment             = {  90362,  390123, 1 }, -- Activating Avatar or Recklessness grants $s1 sec of the other
    bitter_immunity                = {  90356,  383762, 1 }, -- Restores $s1% health instantly and removes all diseases, poisons, and curses affecting you
    bounding_stride                = {  90355,  202163, 1 }, -- Reduces the cooldown of Heroic Leap by $s1 sec and Heroic Leap also increases your movement speed by $s2% for $s3 sec
    cacophonous_roar               = {  90383,  382954, 1 }, -- Intimidating Shout can withstand $s1% more damage before breaking
    champions_might                = {  90323,  386284, 1 }, -- The duration of Champion's Spear is increased by $s1 sec. You deal $s2% increased critical strike damage to targets chained to your Spear
    champions_spear                = {  90380,  376079, 1 }, -- Throw a spear at the target location, dealing $s$s2 Physical damage instantly and an additional $s3 damage over $s4 sec. Deals reduced damage beyond $s5 targets. Enemies hit are chained to the spear's location for the duration. Generates $s6 Rage
    concussive_blows               = {  90354,  383115, 1 }, -- Cooldown of Pummel reduced by $s1 sec. Successfully interrupting an enemy increases the damage you deal to them by $s2% for $s3 sec
    crackling_thunder              = {  95959,  203201, 1 }, -- Thunder Clap's radius is increased by $s1% and it reduces affected target's movement speed by an additional $s2%
    cruel_strikes                  = {  90381,  392777, 2 }, -- Critical strike chance increased by $s1% and critical strike damage of Execute increased by $s2%
    crushing_force                 = {  90347,  382764, 2 }, -- Bloodthirst deals an additional $s1% damage and deals $s2% increased critical strike damage
    defensive_stance               = {  92538,  386208, 1 }, -- A defensive combat state that reduces all damage you take by $s1% and all damage you deal by $s2%. Lasts until canceled
    double_time                    = {  90382,  103827, 1 }, -- Charge gains $s1 additional charge and its cooldown is reduced by $s2 sec
    dual_wield_specialization      = {  90373,  382900, 2 }, -- While dual wielding your damage is increased by $s1% and movement speed is increased by $s2%
    fast_footwork                  = {  90344,  382260, 1 }, -- Movement speed increased by $s1%
    frothing_berserker             = {  90352,  392792, 1 }, -- Rampage has a $s1% chance to immediately refund $s2% of the Rage spent
    heroic_leap                    = {  90346,    6544, 1 }, -- Leap through the air toward a target location, slamming down with destructive force to deal $s$s2 Physical damage to all enemies within $s3 yards
    honed_reflexes                 = {  95956,  391271, 1 }, -- Cooldown of Enraged Regeneration, Pummel, Intervene, Spell Reflection, and Storm Bolt reduced by $s1%
    impending_victory              = {  90326,  202168, 1 }, -- Instantly attack the target, causing $s1 damage and healing you for $s2% of your maximum health. Killing an enemy that yields experience or honor resets the cooldown of Impending Victory and makes it cost no Rage
    intervene                      = {  90329,    3411, 1 }, -- Run at high speed toward an ally, intercepting all melee and ranged attacks against them for $s1 sec while they remain within $s2 yds
    intimidating_shout             = {  90384,    5246, 1 }, -- Causes the targeted enemy to cower in fear and up to $s1 additional enemies within $s2 yards to flee. Targets are disoriented for $s3 sec
    leeching_strikes               = {  90371,  382258, 1 }, -- Leech increased by $s1%
    menace                         = {  90383,  275338, 1 }, -- Intimidating Shout will knock back all nearby enemies except your primary target and cause them all to cower in fear for $s1 sec instead of fleeing
    overwhelming_rage              = {  90378,  382767, 1 }, -- Maximum Rage increased by $s1
    pain_and_gain                  = {  90353,  382549, 1 }, -- When you take any damage, heal for $s1% of your maximum health. This can only occur once every $s2 sec
    piercing_challenge             = {  90379,  382948, 1 }, -- Champion's Spear's damage increased by $s1% and its Rage generation is increased by $s2%
    piercing_howl                  = {  90348,   12323, 1 }, -- Snares all enemies within $s1 yards, reducing their movement speed by $s2% for $s3 sec
    rallying_cry                   = {  90331,   97462, 1 }, -- Lets loose a rallying cry, granting all party or raid members within $s1 yards $s2% temporary and maximum health for $s3 sec
    reinforced_plates              = {  90368,  382939, 2 }, -- Stamina increased by $s1% and Armor increased by $s2%
    rumbling_earth                 = {  90374,  275339, 1 }, -- Shockwave's range increased by $s1 yards and when it strikes at least $s2 targets its cooldown is reduced by $s3 sec
    second_wind                    = {  90332,   29838, 1 }, -- Restores $s1% health every $s2 sec when you have not taken damage for $s3 sec. Restores $s4% health every $s5 sec while you are below $s6% health. The amount restored increases the closer you are to death
    seismic_reverberation          = {  90354,  382956, 1 }, -- If Whirlwind hits $s1 or more enemies it hits them $s2 additional time for $s3% damage
    shattering_throw               = {  90351,   64382, 1 }, -- Hurl your weapon at the enemy, removing any magical immunities and causing $s$s2 Physical damage, ignoring armor. Deals up to $s3% increased damage to absorb shields
    shockwave                      = {  90375,   46968, 1 }, -- Sends a wave of force in a frontal cone, causing $s1 damage and stunning all enemies within $s2 yards for $s3 sec
    sidearm                        = {  90340,  384404, 1 }, -- Your auto-attacks have a $s2% chance to hurl weapons at your target and $s3 other enemy in front of you, dealing $s$s4 Physical damage
    spell_reflection               = {  90385,   23920, 1 }, -- Raise your weapon, reflecting the first spell cast on you and reducing magic damage you take by $s1% for $s2 sec
    storm_bolt                     = {  90337,  107570, 1 }, -- Hurls your weapon at an enemy, causing $s$s2 Physical damage and stunning for $s3 sec
    thunder_clap                   = {  90343,    6343, 1 }, -- Blasts all enemies within $s2 yards for $s$s3 Physical damage and reduces their movement speed by $s4% for $s5 sec. Deals reduced damage beyond $s6 targets
    thunderous_roar                = {  90359,  384318, 1 }, -- Roar explosively, dealing $s$s3 Physical damage to enemies within $s4 yds and cause them to bleed for $s$s5 physical damage over $s6 sec. Deals reduced damage beyond $s7 targets
    thunderous_words               = {  90358,  384969, 1 }, -- Increases the duration of Thunderous Roar's Bleed effect by $s1 sec and Thunderous Roar's Bleed effect causes enemies to take $s2% increased damage from all your bleeds
    titans_torment                 = {  90362,  390135, 1 }, -- While Avatar is active Rampage's Rage cost is reduced by $s1 and Bloodthirst's cooldown is reduced by $s2 sec
    uproar                         = {  90357,  391572, 1 }, -- Thunderous Roar's cooldown reduced by $s1 sec
    war_machine                    = {  90328,  262231, 1 }, -- Your auto-attacks generate $s1% more Rage. Killing an enemy instantly generates $s2 Rage and increases your movement speed by $s3% for $s4 sec
    wild_strikes                   = {  90360,  382946, 2 }, -- Haste increased by $s1% and your auto-attack critical strikes increase your auto-attack speed by $s2% for $s3 sec
    wrecking_throw                 = {  90351,  384110, 1 }, -- Hurl your weapon at the enemy, causing $s$s2 Physical damage, ignoring armor. Deals up to $s3% increased damage to absorb shields

    -- Fury
    anger_management               = {  90415,  152278, 1 }, -- Every $s1 Rage you spend reduces the remaining cooldown on Recklessness, Bladestorm, and Ravager by $s2 sec
    ashen_juggernaut               = {  90409,  392536, 1 }, -- Execute increases the critical strike chance of Execute by $s1% for $s2 sec, stacking up to $s3 times
    bladestorm                     = {  90388,  227847, 1 }, -- Become an unstoppable storm of destructive force, striking all nearby enemies for $s$s2 Physical damage over $s3 sec. Deals reduced damage beyond $s4 targets. You are immune to movement impairing and loss of control effects, but can use defensive abilities and can avoid attacks. Generates $s5 Rage each time you deal damage
    bloodborne                     = {  90401,  385703, 1 }, -- Your Bleed effects deal $s1% additional damage
    bloodcraze                     = {  90405,  393950, 1 }, -- Raging Blow increases the critical strike chance of your next Bloodthirst by $s1% until it critically strikes, stacking up to $s2 times
    bloodthirst                    = {  90392,   23881, 1 }, -- Assault the target in a bloodthirsty craze, dealing $s$s2 Physical damage and restoring $s3% of your health. Generates $s4 Rage
    cold_steel_hot_blood           = {  90402,  383959, 1 }, -- Bloodthirst critical strikes generate $s1 additional Rage and inflict a Gushing Wound that leeches $s2 health over $s3 sec
    critical_thinking              = {  90425,  383297, 2 }, -- Critical Strike chance increased by $s1% and Raging Blow's critical strikes deal $s2% increased damage
    cruelty                        = {  90428,  392931, 1 }, -- While Enraged, Raging Blow deals $s1% increased damage
    dancing_blades                 = {  90417,  391683, 1 }, -- Odyn's Fury increases your auto-attack damage and speed by $s1% for $s2 sec
    deft_experience                = {  90421,  383295, 2 }, -- Mastery increased by $s1% and if you are Enraged, Bloodthirst extends your Enrage by $s2 sec
    depths_of_insanity             = {  90413,  383922, 1 }, -- Recklessness lasts $s1 sec longer
    enraged_regeneration           = {  90395,  184364, 1 }, -- Reduces damage taken by $s1% and Bloodthirst restores an additional $s2% health for $s3 sec. Usable while stunned or incapacitated
    focus_in_chaos                 = {  90403,  383486, 1 }, -- While Enraged, your auto-attacks can no longer miss
    frenzied_enrage                = {  90398,  383848, 1 }, -- Enrage increases your Haste by $s1% and increases your movement speed by $s2%
    frenzy                         = {  90406,  335077, 1 }, -- Rampage increases your Haste by $s1% for $s2 sec, stacking up to $s3 times. This effect is reset if you Rampage a different primary target
    fresh_meat                     = {  90399,  215568, 1 }, -- Bloodthirst always Enrages you the first time you strike a target and it has a $s1% increased chance to trigger Enrage
    hack_and_slash                 = {  90407,  383877, 1 }, -- Each Rampage strike has a $s1% chance to refund a charge of Raging Blow
    improved_bloodthirst           = {  90397,  383852, 1 }, -- Bloodthirst damage increased by $s1%
    improved_execute               = {  90430,  316402, 1 }, -- Execute no longer costs Rage and now generates $s1 Rage
    improved_raging_blow           = {  90390,  383854, 1 }, -- Raging Blow has $s1 charges and has a $s2% chance to instantly reset its own cooldown
    improved_whirlwind             = {  90427,   12950, 1 }, -- Whirlwind causes your next $s1 single-target attacks to strike up to $s2 additional targets for $s3% damage. Whirlwind generates $s4 Rage, plus an additional $s5 per target hit. Maximum $s6 Rage
    invigorating_fury              = {  90393,  383468, 1 }, -- Enraged Regeneration lasts $s1 sec longer and instantly heals for $s2% of your maximum health
    massacre                       = {  90410,  206315, 1 }, -- Execute is now usable on targets below $s1% health and its cooldown is reduced by $s2 sec
    meat_cleaver                   = {  90391,  280392, 1 }, -- Whirlwind deals $s1% more damage and affects your next $s2 single-target attacks
    odyns_fury                     = {  90418,  385059, 1 }, -- Unleashes your power, dealing $s$s3 Physical damage and an additional $s$s4 Physical damage over $s5 sec to all enemies within $s6 yards. Deals reduced damage beyond $s7 targets. Generates $s8 Rage
    onslaught                      = {  90424,  315720, 1 }, -- Brutally attack an enemy for $s$s2 Physical damage. Generates $s3 Rage
    powerful_enrage                = {  90398,  440277, 1 }, -- Enrage increases the damage your abilities deal by an additional $s1% and Enrage's duration is increased by $s2 sec
    raging_blow                    = {  90396,   85288, 1 }, -- A mighty blow with both weapons that deals a total of $s$s2 Physical damage. Raging Blow has a $s3% chance to instantly reset its own cooldown. Generates $s4 Rage
    rampage                        = {  90408,  184367, 1 }, -- Enrages you and unleashes a series of $s2 brutal strikes for a total of $s$s3 Physical damage and empowering your next Bloodthirst and Raging Blow
    ravager                        = {  90388,  228920, 1 }, -- Throws a whirling weapon at the target location that chases nearby enemies, inflicting $s$s2 Physical damage to all enemies over $s3 sec. Deals reduced damage beyond $s4 targets. Generates $s5 Rage each time it deals damage
    reckless_abandon               = {  90415,  396749, 1 }, -- Activating Recklessness generates $s3 Rage and while Recklessness is active, Raging Blow and Bloodthirst are replaced by Crushing Blow and Bloodbath.  Crushing Blow Strike a mighty blow with both weapons that deals a total of $s$s6 Physical damage. Crushing Blow has a $s7% chance to instantly reset its own cooldown and its critical strikes deal $s8% additional damage. Generates $s9 Rage.  Bloodbath Assault the target in a bloodthirsty craze, dealing $s$s12 Physical damage and restoring $s13% of your health. Bloodbath causes the target to bleed for $s14 damage over $s15 sec. Using Bloodbath on a target that is affected by Bloodbath extends the bleed by $s16 sec. Generates $s17 Rage
    recklessness                   = {  90412,    1719, 1 }, -- Go berserk, increasing all Rage generation by $s1% and granting your abilities $s2% increased critical strike chance for $s3 sec. Generates $s4 Rage
    singleminded_fury              = {  90400,   81099, 1 }, -- While dual-wielding a pair of one-handed weapons, your damage done is increased by $s1%, your auto-attack damage with one-handed weapons is increased by $s2%, your movement speed is increased by $s3%, and your auto-attack critical strikes have a $s4% chance to Enrage you
    slaughtering_strikes           = {  90411,  388004, 1 }, -- Raging Blow causes every strike of your next Rampage to deal an additional $s1% damage, stacking up to $s2 times
    storm_of_steel                 = {  90389,  382953, 1 }, -- Bladestorm and Ravager's damage are reduced by $s1% but they now have $s2 charges and generate $s3 additional Rage each time they deal damage
    sudden_death                   = {  90429,  280721, 1 }, -- Your attacks have a chance to reset the cooldown of Execute and make it usable on any target, regardless of their health
    swift_strikes                  = {  90416,  383459, 2 }, -- Haste increased by $s1% and Raging Blow and Bloodthirst generate an additional $s2 Rage
    tenderize                      = {  90423,  388933, 1 }, -- Onslaught Enrages you. If you have Slaughtering Strikes, it also grants you $s1 stacks of Slaughtering Strikes
    titanic_rage                   = {  90417,  394329, 1 }, -- Odyn's Fury's Enrages you, deals $s1% increased damage and grants you $s2 stacks of Whirlwind
    unbridled_ferocity             = {  90414,  389603, 1 }, -- Rampage has a $s1% chance to grant Recklessness for $s2 sec
    unhinged                       = {  90389,  386628, 1 }, -- Every other time Bladestorm or Ravager deal damage, you automatically cast a Bloodthirst at your target or random nearby enemy
    vicious_contempt               = {  90404,  383885, 2 }, -- Bloodthirst deals $s1% increased damage to enemies who are below $s2% health
    warpaint                       = {  90394,  208154, 1 }, -- You take $s1% reduced damage while Enrage is active
    wrath_and_fury                 = {  90387,  392936, 1 }, -- Raging Blow deals $s1% increased damage and while Enraged, Raging Blow has a $s2% increased chance to instantly reset its own cooldown

    -- Mountain Thane
    avatar_of_the_storm            = {  94805,  437134, 1 }, -- Casting Avatar grants you $s1 charges of Thunder Blast and resets the cooldown of Thunder Clap. While Avatar is not active, Lightning Strikes have a $s2% chance to grant you Avatar for $s3 secs. Thunder Blast Your next Thunder Clap becomes a Thunder Blast that deals Stormstrike damage
    burst_of_power                 = {  94807,  437118, 1 }, -- Lightning Strikes have a $s1% chance to make your next $s2 Bloodthirsts have no cooldown, deal $s3% increased damage, and generate $s4 additional Rage
    crashing_thunder               = {  94816,  436707, 1 }, -- Stormstrike or Nature damage your abilities deal is increased by $s2%$s$s3 Stormstrike damage ignores Armor. Thunder Clap damage increased by $s4%, and it generates $s5 Rage. Seismic Reverberations, Improved Whirlwind, Meat Cleaver, and Barbaric Training now affect Thunder Clap in addition to Whirlwind
    flashing_skies                 = {  94797,  437079, 1 }, -- Thunder Blast calls down a Lightning Strike on an enemy it hits
    gathering_clouds               = {  94792,  436201, 1 }, -- Your attacks trigger Lightning Strikes $s1% more often
    ground_current                 = {  94800,  436148, 1 }, -- Lightning Strikes also deal $s$s2 Nature damage to enemies near their target. Damage reduced beyond $s3 targets
    keep_your_feet_on_the_ground   = {  94798,  438590, 1 }, -- Physical damage taken reduced by $s1%. Thunder Blast reduces damage you take by $s2% for $s3 sec
    lightning_strikes              = {  94803,  434969, 1 }, -- Damaging enemies with Thunder Clap, Raging Blow, or Execute has a $s2% chance to also strike one with a lightning bolt, dealing $s$s3 Nature damage. Lightning Strikes occur $s4% more often during Avatar
    snap_induction                 = {  94797,  456270, 1 }, -- Activating Recklessness grants a charge of Thunder Blast
    steadfast_as_the_peaks         = {  94798,  434970, 1 }, -- Stamina increased by $s1%. Impending Victory increases your maximum health by $s2% for $s3 sec. When this health increase expires, you heal for any amount of the original Impending Victory that healed you in excess of your full health
    storm_bolts                    = {  94817,  436162, 1 }, -- Storm Bolt also hits $s1 additional nearby targets, stunning them for $s2 sec, but its cooldown is increased by $s3 sec
    storm_shield                   = {  94817,  438597, 1 }, -- Intervening a target grants them a shield for $s1 sec that absorbs magic damage equal to $s2 times your Armor
    strength_of_the_mountain       = {  94808,  437068, 1 }, -- Shield Slam damage increased by $s1%. Bloodthirst and Rampage damage increased by $s2%
    thorims_might                  = {  94792,  436152, 1 }, -- Lightning Strikes generate $s1 Rage. Raging Blow and Execute damage increased by $s2%
    thunder_blast                  = {  94785,  435607, 1 }, -- Shield Slam and Bloodthirst have a $s1% chance to grant you Thunder Blast, stacking up to $s2 charges. Thunder Blast Your next Thunder Clap becomes a Thunder Blast that deals Stormstrike damage and generates $s5 Rage

    -- Slayer
    brutal_finish                  = {  94786,  446085, 1 }, -- Your next Rampage after Bladestorm ends deals $s1% additional damage
    culling_cyclone                = {  94786,  444778, 1 }, -- Each strike of Bladestorm deals an additional $s1% damage evenly split across all targets
    death_drive                    = {  94813,  444770, 1 }, -- You heal for $s1% of damage dealt by Sudden Death
    fierce_followthrough           = {  94787,  444773, 1 }, -- Bloodthirst critical strikes increase the damage of your next Bloodthirst by $s1%
    imminent_demise                = {  94788,  444769, 1 }, -- Every $s1 Slayer's Strikes you gain Sudden Death. Using Sudden Death accelerates your next Bladestorm, striking $s2 additional time (max $s3). Bladestorm's total duration is unchanged
    opportunist                    = {  94787,  444774, 1 }, -- When Raging Blow resets its own cooldown, your next Raging Blow deals $s1% additional damage and $s2% additional critical damage
    overwhelming_blades            = {  94810,  444772, 1 }, -- Each strike of Bladestorm applies Overwhelmed to all enemies affected, increasing damage you deal to them by $s1% for $s2 sec, max $s3 stacks
    reap_the_storm                 = {  94809,  444775, 1 }, -- Bloodthirst has a $s2% chance to cause you to unleash a flurry of steel, striking all nearby enemies for $s$s3 Physical damage and applying Overwhelmed. Deals reduced damage beyond $s4 targets
    relentless_pursuit             = {  94795,  444776, 1 }, -- Charge increases your movement speed by $s1% for $s2 sec. Charge removes all movement impairing effects, this effect cannot occur more than once every $s3 sec
    show_no_mercy                  = {  94784,  444771, 1 }, -- Marked for Execution increases the critical strike chance and critical strike damage of your next Execute on the target by $s1%
    slayers_dominance              = {  94814,  444767, 1 }, -- Your attacks against your primary target have a high chance to overwhelm their defenses and trigger a Slayer's Strike, dealing $s$s2 Physical damage and applying Marked for Execution, increasing the damage they take from your next Execute by $s3%. Stacks $s4 times
    slayers_malice                 = {  94801,  444779, 1 }, -- Raging Blow damage increased by $s1%
    unrelenting_onslaught          = {  94820,  444780, 1 }, -- When you Execute a target that you've Marked for Execution, you both reduce the cooldown of Bladestorm by $s1 sec and apply $s2 stacks of Overwhelmed to the target per stack of Marked for Execution consumed. You can use Pummel and Storm Bolt while Bladestorming
    vicious_agility                = {  94795,  444777, 1 }, -- Heroic Leap reduces the cooldown of Charge by $s1 sec and Charge reduces the cooldown of Heroic Leap by $s2 sec
} )

-- PvP Talents
spec:RegisterPvpTalents( {
    battlefield_commander          = 5628, -- (424742) Your Shout abilities have additional effects.  Battle Shout: Increases Stamina by $s3%.  Piercing Howl: Radius increased by $s6%  Berserker Shout: Range increased by $s9 yds.  Intimidating Shout: Cooldown reduced by $s12 sec.  Rallying Cry: Removes movement impairing effects and grants $s15% movement speed to allies.  Thunderous Roar: Targets receive $s18% more damage from all sources while bleeding
    berserker_roar                 = 5702, -- (1227751) Go berserk, removing and granting immunity to Fear, Sap, and Incapacitate effects for $s1 sec. Also reduces the duration of the next crowd control effect within $s2 sec by $s3% on group members within $s4 yds
    death_wish                     =  179, -- (199261) Increases your damage taken and done by $s1% for $s2 sec at the cost of $s3% of your health. Stacks up to $s4 times
    demolition                     = 5373, -- (329033) Reduces the cooldown of your Shattering Throw or Wrecking Throw by $s1% and increases its damage to absorb shields by an additional $s2%
    disarm                         = 3533, -- (236077) Disarm the enemy's weapons and shield for $s1 sec. Disarmed creatures deal significantly reduced damage
    dragon_charge                  = 5678, -- (206572) Run at high speed at a distance in front of you. All enemies in your path will take $s$s2 Physical damage and be knocked back
    enduring_rage                  =  177, -- (411764) You have a chance to become Enraged while you are suffering movement impairing effects. Suffering loss of control effects have a chance to grant you Recklessness for $s1 sec
    master_and_commander           = 3528, -- (235941) Cooldown of Rallying Cry reduced by $s1 sec
    rebound                        = 5548, -- (213915) Spell Reflection reflects the next $s1 incoming spells cast on you and reflected spells deal $s2% extra damage to the attacker. Spell Reflection's cooldown is increased by $s3 sec
    safeguard                      = 5624, -- (424654) Intervene now has $s1 charges and reduces the ally's damage taken by $s2% for $s3 sec. Intervene's cooldown is increased by $s4 sec
    slaughterhouse                 = 3735, -- (352998) Rampage, Onslaught, and Odyn's Fury damage reduce healing the target receives by $s1% for $s2 sec, stacking up to $s3 times
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
        duration = function () return 4 * haste end,
        max_stack = 1,
        onCancel = function()
            setCooldown( "global_cooldown", 0 )
        end,
        copy = { 227847, 389774, 446035 }
    },
    bloodbath_dot = {
        id = 113344,
        duration = 6,
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
    overwhelmed = {
        id = 445836,
        duration = 20,
        max_stack = 10
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
        max_stack = function () return talent.meat_cleaver.enabled and 4 or 2 end,
        copy = "whirlwind"
    },
} )

spec:RegisterGear({
    -- The War Within
    tww3 = {
        items = { 237610, 237608, 237613, 237611, 237609 },
        auras = {
            -- Mountain Thane
            severe_thunder = {
                id = 1252096,
                duration = 12,
                max_stack = 1
            },
        },
    },
    tww2 = {
        items = { 229235, 229233, 229238, 229236, 229234 },
        auras = {
            winning_streak = {
                id = 1216561,
                duration = 30,
                max_stack = 10,
                copy = "winning_streak_fury"
            },
            double_down_bt = {
                id = 1216565,
                duration = 12,
                max_stack = 1
            },
            double_down_rb = {
                id = 1216569,
                duration = 12,
                max_stack = 1
            }
        }
    },
    -- Dragonflight
    tier31 = {
        items = { 207180, 207181, 207182, 207183, 207185 },
        setBonuses = {
            tier31_2pc = 422925,
            tier31_4pc = 422926
        },
        auras = {
            furious_bloodthirst = {
                id = 423211,
                duration = 20,
                max_stack = 3
            }
        }
    },
    tier30 = {
        items = { 202446, 202444, 202443, 202442, 202441, 217218, 217220, 217216, 217217, 217219 },
        setBonuses = {
            tier30_2pc = 405579,
            tier30_4pc = 405580
        },
        auras = {
            merciless_assault = {
                id = 409983,
                duration = 14,
                max_stack = 10
            }
        }
    },
    tier29 = {
        items = { 200426, 200428, 200423, 200425, 200427 },
        setBonuses = {
            tier29_2pc = 393708,
            tier29_4pc = 393709
        }
    },
    -- Legacy
    tier21 = {
        items = { 152178, 152179, 152180, 152181, 152182, 152183 },
        auras = {
            slaughter = {
                id = 253384,
                duration = 4
            },
            outrage = {
                id = 253385,
                duration = 8
            }
        }
    },
    tier20 = {
        items = { 147187, 147188, 147189, 147190, 147191, 147192 },
        auras = {
            raging_thirst = {
                id = 242300,
                duration = 8
            },
            bloody_rage = {
                id = 242952,
                duration = 10,
                max_stack = 10
            }
        }
    },
    ceannar_charger = { items = { 137088 } },
    timeless_stratagem = { items = { 143728 } },
    kazzalax_fujiedas_fury = {
        items = { 137053 },
        auras = {
            fujiedas_fury = {
                id = 207776,
                duration = 10,
                max_stack = 4
            }
        }
    },
    mannoroths_bloodletting_manacles = { items = { 137107 } },
    najentuss_vertebrae = { items = { 137087 } },
    valarjar_berserkers = { items = { 151824 } },
    ayalas_stone_heart = {
        items = { 137052 },
        auras = {
            stone_heart = {
                id = 225947,
                duration = 10
            }
        }
    },
    the_great_storms_eye = {
        items = { 151823 },
        auras = {
            tornados_eye = {
                id = 248142,
                duration = 6,
                max_stack = 6
            }
        }
    },
    archavons_heavy_hand = { items = { 137060 } },
    weight_of_the_earth = { items = { 137077 } },
    soul_of_the_battlelord = { items = { 151650 } }
} )

local whirlwindConsumers = {
    [335097] = true,    -- Crushing Blow
    [335096] = true,    -- Bloodbath
    [23881]  = true,    -- Bloodthirst
    [5308]   = true,    -- Execute
    [280735] = true,    -- Execute (Massacre)
    [202168] = true,    -- Impending Victory
    [85288]  = true,    -- Raging Blow
    [184367] = true,    -- Rampage
    [315720] = true,    -- Onslaught
    [34428]  = true,    -- Victory Rush
    [1464]   = true,    -- Slam
    [1715]   = true,    -- Hamstring
}

local trueWWStacks = 0
local BSUP = false

local rageSpent = 0
local gloryRage = 0

local fresh_meat_actual = {}

local last_rampage_target = nil

local RemoveFrenzy = setfenv( function()
    removeBuff( "frenzy" )
end, state )

spec:RegisterCombatLogEvent( function(  _, subtype, _, sourceGUID, sourceName, sourceFlags, _, destGUID, destName, destFlags, _, spellID, spellName, school, amount, interrupt, a, b, c, d, critical )
    if sourceGUID ~= state.GUID then return end

    if subtype == "SPELL_CAST_SUCCESS" then
        if whirlwindConsumers[ spellID ] and not BSUP then
            trueWWStacks = trueWWStacks - 1
        elseif spellID == 190411 and state.talent.improved_whirlwind.enabled then
            trueWWStacks = state.talent.meat_cleaver.enabled and 4 or 2
        end
        local ability = class.abilities[ spellID ]

        if not ability then return end
        if ability.key == "rampage" and last_rampage_target ~= destGUID and state.talent.frenzy.enabled then
            RemoveFrenzy()
            last_rampage_target = destGUID
        end

    elseif subtype == "SPELL_DAMAGE" then
        local ability = class.abilities[ spellID ]
        if not ability then return end

        if ( ability.key == "bloodthirst" or ability.key == "bloodbath" ) and state.talent.fresh_meat.enabled and not fresh_meat_actual[ destGUID ] then
            fresh_meat_actual[ destGUID ] = true
        end
    elseif ( subtype == "SPELL_AURA_APPLIED" or subtype == "SPELL_AURA_REMOVED" or subtype == "SPELL_AURA_REFRESH" or subtype == "SPELL_AURA_APPLIED_DOSE" or subtype == "SPELL_AURA_REMOVED_DOSE" ) then
        if spellID == 446035 then
            BSUP = ( subtype ~= "SPELL_AURA_REMOVED" ) and true or false
        end
        if state.talent.thunder_blast.enabled and spellID == 435615 then Hekili:ForceUpdate( "THUNDERBLAST_CHANGED", true ) end
        if state.talent.burst_of_power.enabled and spellID == 437121 then Hekili:ForceUpdate( "BURSTOFPOWER_CHANGED", true ) end
    end
end )

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

spec:RegisterHook( "prespend", function( amt, resource, overcap, clean )
    if buff.recklessness.up and resource == "rage" and amt < 0 then
        return amt * 2, resource, overcap, true
    end
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

    if buff.whirlwind.up then
        if trueWWStacks > 0 then
            applyBuff( "whirlwind", buff.whirlwind.remains, trueWWStacks )
        else
            removeBuff( "whirlwind" )
        end
    else
        if trueWWStacks > 0 then
            applyBuff( "whirlwind", nil, trueWWStacks )
        elseif action.whirlwind.time_since < gcd.max then
            local stacks = spec.auras.whirlwind.max_stack
            applyBuff( "whirlwind", nil, stacks )
        end
    end

    if legendary.will_of_the_berserker.enabled and buff.recklessness.up then
        state:QueueAuraExpiration( "recklessness", WillOfTheBerserker, buff.recklessness.expires )
    end

    active_dot.hit_by_fresh_meat = 0

    for k, v in pairs( fresh_meat_actual ) do
        if k == target.unit then
            applyDebuff( "target", "hit_by_fresh_meat" )
        else
            active_dot.hit_by_fresh_meat = active_dot.hit_by_fresh_meat + 1
        end
    end

    if buff.bladestorm.up then
        -- channelSpell( "bladestorm", buff.bladestorm.expires - class.auras.bladestorm.duration, class.auras.bladestorm.duration, class.abilities.bladestorm.id )
        setCooldown( "global_cooldown", buff.bladestorm.remains )
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
        -- Will need to revisit this if `cancel_buff` is added to the APL.
        nobuff = "bladestorm",

        spend = -20,
        spendType = "rage",

        toggle = "cooldowns",

        handler = function ()
            applyBuff( "bladestorm" )
            setCooldown( "global_cooldown", class.auras.bladestorm.duration )
            if talent.blademasters_torment.enabled then applyBuff( "avatar", 4 ) end
            if talent.overwhelming_blades.enabled then applyDebuff( "target", "overwhelmed", nil, 10 ) end

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

        spend = function() return spec.abilities.bloodthirst.spend end,
        spendType = "rage",

        cycle = function () return talent.fresh_meat.enabled and "hit_by_fresh_meat" or nil end,

        startsCombat = true,
        texture = 236304,
        talent = "reckless_abandon",
        buff = "recklessness",
        bind = "bloodthirst",

        critical = function()
            return stat.crit
            + ( 15 * buff.bloodcraze.stack )
            + ( 12 * buff.merciless_assault.stack )
            + ( 20 * buff.recklessness.stack )
        end,

        handler = function()
            spec.abilities.bloodthirst.handler()
            -- Always extends by 6 seconds or applies a 6 second one
            applyDebuff( "target", "bloodbath_dot", debuff.bloodbath_dot.remains + 6 )
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
        cooldown = function () return buff.burst_of_power.up and 0 or ( 4.5 - ( talent.titans_torment.enabled and buff.avatar.up and 1.5 or 0 ) ) * haste end,
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
        nobuff = function() if talent.reckless_abandon.enabled then return "recklessness" end end,
        startsCombat = true,
        bind = "bloodbath",

        critical = function()
            return stat.crit
            + ( 15 * buff.bloodcraze.stack )
            + ( 12 * buff.merciless_assault.stack )
            + ( 20 * buff.recklessness.stack )
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

            if talent.bloodcraze.enabled and action.bloodthirst.crit_pct_current >= 100 then removeBuff( "bloodcraze" ) end

            gain( health.max * ( buff.enraged_regeneration.up and 0.23 or 0.03 ) , "health" )

            if talent.fresh_meat.enabled and debuff.hit_by_fresh_meat.down then
                applyBuff( "enrage" )
                applyDebuff( "target", "hit_by_fresh_meat" )
            end

            -- Legacy
            removeBuff( "double_down_bt" )
            removeBuff( "merciless_assault" )
            if set_bonus.tier31_4pc > 0 and action.bloodthirst.crit_pct_current >= 100 then
                reduceCooldown( "odyns_fury", 2.5 )
            end
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

        usable = function () return target.minR >= ( settings.charge_min_range or 8 ) and ( query_time - action.charge.lastCast > gcd.execute ), "target too close" end,
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
        buff = "recklessness",
        bind = "raging_blow",

        handler = function ()
            removeStack( "whirlwind" )
            removeBuff( "opportunist" )
            spendCharges( "raging_blow", 1 )
            if buff.will_of_the_berserker.up then buff.will_of_the_berserker.expires = query_time + 12 end

            removeBuff( "double_down_rb" )
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
            setCooldown( "global_cooldown", 0.75 )
            removeStack( "whirlwind" )
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

        spend = 15,
        spendType = "rage",

        handler = function ()
            applyDebuff( "target", "odyns_fury" )
            active_dot.odyns_fury = max( active_dot.odyns_fury, active_enemies )
            if talent.dancing_blades.enabled then applyBuff( "dancing_blades" ) end
            if talent.titanic_rage.enabled then
                applyBuff( "enrage" )
                applyBuff( "whirlwind", nil, talent.meat_cleaver.enabled and 4 or 2 )
            end
            if talent.titans_torment.enabled then applyBuff( "avatar", 4 ) end

            if state.spec.fury and set_bonus.tier31_2pc > 0 then
                applyBuff( "furious_bloodthirst", nil, 3 )
            end

            -- PvP
            if pvptalent.slaughterhouse.enabled then applyDebuff( "target", "slaughterhouse", nil, debuff.slaughterhouse.stack + 1 ) end
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
        charges = function () if talent.improved_raging_blow.enabled then return 2 end end,
        cooldown = 8,
        hasteCD = true,
        recharge = function () if talent.improved_raging_blow.enabled then return 8 * haste end end,
        gcd = "spell",

        spend = function () return -12 - talent.swift_strikes.rank - ( buff.double_down_rb.up and 2 or 0 )end,
        spendType = "rage",

        talent = "raging_blow",
        texture = 589119,
        startsCombat = true,
        nobuff = function() if talent.reckless_abandon.enabled then return "recklessness" end end,
        bind = "crushing_blow",

        handler = function ()
            removeStack( "whirlwind" )
            spendCharges( "crushing_blow", 1 )
            removeBuff( "opportunist" )
            if buff.will_of_the_berserker.up then buff.will_of_the_berserker.expires = query_time + 12 end
            if talent.slaughtering_strikes.enabled then addStack( "slaughtering_strikes_raging_blow" ) end
            removeBuff( "double_down_rb" )
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

        spend = function() return 80 - ( talent.titans_torment.enabled and buff.avatar.up and 20 or 0 ) end,
        spendType = "rage",

        startsCombat = true,
        texture = 132352,
        talent = "rampage",

        handler = function ()
            applyBuff( "enrage" )
            removeStack( "whirlwind" )
            removeBuff( "slaughtering_strikes" )
            if talent.frenzy.enabled then addStack( "frenzy" ) end -- TODO: resets on target swap
            removeBuff( "brutal_finish" )

            -- PvP
            if pvptalent.slaughterhouse.enabled then applyDebuff( "target", "slaughterhouse", nil, debuff.slaughterhouse.stack + 1 ) end

            -- Legacy
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
        spend = function() return talent.reckless_abandon.enabled and -50 or 0 end,
        spendType = "rage",

        talent = "recklessness",
        startsCombat = false,
        texture = 458972,

        handler = function ()
            applyBuff( "recklessness" )
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
        cooldown = function() return ( 30 + ( talent.storm_bolts.enabled and 10 or 0 ) ) * ( 1 - ( 0.05 * talent.honed_reflexes.rank ) ) end,
        gcd = function() return buff.bladestorm.up and talent.unrelenting_onslaught.enabled and "off" or "spell" end,

        startsCombat = true,
        texture = 613535,

        talent = "storm_bolt",

        -- Add usable check for Unrelenting Onslaught talent
        usable = function()
            if buff.bladestorm.up and not talent.unrelenting_onslaught.enabled then
                return false, "can't use during bladestorm without unrelenting onslaught"
            end
            return true
        end,

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
        known = 6343,
        flash = 6343,
        cast = 0,
        cooldown = 6,
        gcd = "spell",
        hasteCD = true,

        spend = 10,
        spendType = "rage",

        talent = "thunder_blast",
        buff = "thunder_blast",
        startsCombat = true,
        texture = 460957,

        handler = function ()
            class.abilities.thunder_clap.handler()
            removeStack( "thunder_blast" )
            if set_bonus.tww3 >= 4 then removeBuff( "severe_thunder" ) end
        end,

        bind = "thunder_clap"
    },

    thunder_clap = {
        id = 6343,
        cast = 0,
        cooldown = 6,
        gcd = "spell",
        hasteCD = true,

        spend = 8,
        spendType = "rage",

        talent = "thunder_clap",
        nobuff = "thunder_blast",
        startsCombat = true,
        texture = 136105,

        handler = function ()
            if talent.crashing_thunder.enabled and talent.improved_whirlwind.enabled then
                applyBuff ( "whirlwind", nil, talent.meat_cleaver.enabled and 4 or 2 )
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
            if settings.check_ww_range and target.distance > 8 then return false, "target is outside of whirlwind range" end
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
    name = format( "%s Filter M+ |T132361:0|t Spell Reflection", NewFeature ),
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
    name = "Only |T236312:0|t Shockwave as Interrupt",
    desc = "If checked, |T236312:0|t Shockwave will only be recommended when your target is casting.",
    type = "toggle",
    width = "full"
} )

spec:RegisterSetting( "charge_min_range", 10, {
    name = strformat( "%s Minimum Distance", Hekili:GetSpellLinkWithTexture( spec.abilities.charge.id ) ),
    desc = strformat( "If your target is closer than this distance, |W%s|w will not be recommended.", Hekili:GetSpellLinkWithTexture( spec.abilities.charge.id ) ),
    type = "range",
    min = 8,
    max = 25,
    step = 1,
    width = "full",
} )


spec:RegisterSetting( "t30_bloodthirst_crit", 95, {
    name = strformat( "%s Critical Threshold (Tier 30)", Hekili:GetSpellLinkWithTexture( spec.abilities.bloodthirst.id ) ),
    desc = strformat( "By default, if you have four pieces of Tier 30 equipped, |W%s|w and |W%s|w will be recommended when their chance to crit is |cFFFFD10095%%|r or higher.\n\n"
            .. "Your (old) tier set and %s can bring you over the 95%% threshold. If |W%s|w is talented, these crits will proc a %s for additional damage. "
            .. "Lowering this percentage slightly may be helpful if your base Critical Strike chance is very low. However, if set too low, you may use these abilities but "
            .. "fail to crit.",
            spec.abilities.bloodthirst.name, spec.abilities.bloodbath.name, Hekili:GetSpellLinkWithTexture( spec.auras.recklessness.id ),
            Hekili:GetSpellLinkWithTexture( spec.auras.bloodcraze.id ), Hekili:GetSpellLinkWithTexture( spec.auras.gushing_wound.id ) ),
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

    potion = "tempered_potion",

    package = "Fury",
} )

spec:RegisterPack( "Fury", 20250905, [[Hekili:nZt)VnUTs(3sqr9g)AQJLs8UzlwBG(6DpGUOO3dW9UF5WzzzlAB9ISKF6JKnfb(V9Bgs9bj1qkzNKDlA3DtehoC489qjolCw8hlMh4NZw87UJDNm(JJNmYX15dUVFX88NoWwm)G)6793c)qS)E4V)hfPpHp8POe)aCYzjfPRHb2LNFi7NU(6TH57kwnADY(RZc3xe5NhMeVo1Fto(7RVEvuYQRZ3XE0p9ra0W4R)51ii)Z0WK0W8N(TWS8SRdyB8lIYVgGcFU3gyzhHZFX8vfHr5)A8IvKe(4jlM7xKVljDX85H7)fGWcdcycWzzW8rW)XX39JJN8thx(pc)YXLz5jP7pUCvsu(XLbfPHXBpU8Vh5dWZh5ZIP8XFC8nWu(5)5VDC58NIxx9CavVhE(VghMh6hXba4qPjBcJa(Y39Dhx(FFilpL5VhG6ReB64NX1DEnM)feZhx(lj73hMliFGyU7JUV)9b3ka()ayMWZQ3Rto(5JF2NVOzJoKYasDLF(pm9A4VZJyEz7skYnablnJLEpl1ll3pEn7Q8KTBJyttIPH)b)0q)vrSRqDSP5Ga4EwUNJh7lRJkcyx9GFur9Zh5mkmBeYpxVJLMuK5LN6hNb7RCw6PGFxd431k(bo1)jcpWTYoU0)4YYPb)Y6KKOGKhJVc0IcFimGfakvpba9GFUF6XLj4FcEkgaLlOaDMnhxgM)o4bCsaup8HFoo54Yu2E)W4ayfHFmVin(4shaVSOmwZtgpAYOtzh74Lbc(RsomnJLhUPCF7i(xpe3tbuE16K4GqeNsSCGW8kYyERk2SzWLnpVAppcSB4AAF)3x)iX(UEKPJF(5(nrotsOm3m5HNYo19C3PUg2PUN7o1(eF57uhoHM1YgrEB88ZxQoaywMpYp(jVGdzdUOcXJAz5DsuIljL4AIsC7dL4EwuYHsNK6YFxz5VJK0NIfW3mdiOi(ap)SPrgCPvLMMXGqeRR261Jp8VDPZOj)GktcX7imes828DaeelnQUpC4SlTAA2mwFwBN(T2oLR9PiGC827hx4hr5z3pAllFNFQ3HI)8pH4mRs(YPGAxAu7(IqnzSaV6z4T2plVshJgJObqyoBVvmspv4hVpILLfd)5QWntVG9VlcpCGfmAZtP(q89DEqIcEbyggGykWeEeoPuXW6cisDayfMed0xqseg0hdX9f26ICmag7bwkedlpCpe4bwhiC26CmswygpYwyexBOEjHfAnWI3YWfcN1NqpTp)8(Khy7zX5JccfjfmBI8CqMr4AViM)bCITH2vb8dj4pHqUjC7UCpr4YSz3mgC9Q8OpbpAqosq5J2X8JY3n6W68pDZKbCnBzM7OIdp)8QKSSbQyqDPpnjjsRf73ZI4S1)qOnMjY4QbKGeptkz5(z3BE5Bj)qwIEyP69Hz8ue)uilkaY81lgmryPGl0S92q207MOULw(hOYrP92XLywRLkm7aUjKknOlLbke(C1kUXYviyrqkZRaOaccE(MWues)y4Np4hMIptGQFwS(K7HSOK8ktDhKQn6pNYtVWHXGlVGRruUplomqYvkyF7HkZZa1RliF(WbAZMYlDzWmjCiCWxXKjtBOKJteXPko3uNHYPwr6CFMQLsNSrxs2ORr2OBNSrxdSr3tKn6qWgDmWgDoj2O7qzbq)yJFNil(K4ONW)MH)fxzwYwaWewoGOEbC)DvfeO5rcAVjMwnXEC5)f6IfqCmlumE3yBvcANOINUeZCRfZP)CjPU(anrSzBcRMBDVQuwbuQE8Pnujn3ZHCF(zdE7anUdS1GJRzUszNB10XizQS76fr62fp11cpT1QszsyuumujH9ZHCFP8uewVDq8G(L6ZGgqwHHBIrKKzrzZMVIHwyO2CvtVD4bALikEcsIetqELxEIxqiBMJ74bxAGNndhZMG0cnzuqWrQrpPgIuneDv2I4)0uK6jZ2Y0IF3ese5iYU4)PK7ReVsn7Cqv7qKFCmK7szk4iKpav5fZ2hYYM6m4Yu)WapitwiHs)GGSrHXZCG19c9NZ(cESAdnVyiuL((jxSztDbEjnAF(z6Npq)XvSMjwieMibDVdGqP6aSUm3pcrYE)Sm)1PSrSyCcbKcKg5N0JDhBEftI92UoWl1FDOFuvv(TZHgLXkXW5pi1Fl7t3nwmqwbEISEbmW(vm8f1AhRQp2vaT(bpbCZ6Xk3ZIbKDAPWmuyAryW6mV)vrWwSCcLCAu3qYZAL)wVKnqA4HRVpRVZrCMNOwimbQAluGokjjGFUpYpfs(LXhr(Hy1pq93(rqvMrr6voeg)qY9G63xGAfIby45dWLxhsEekFimEtrwzPsYsLkDmNjQf7mBQZntKYrsH1oq3NVADstvlukTi2t8BErGEEP1AK)tS0RYqEB(ur2hLQTCzfAg7HJEVQnpjYGA5Jzk4YmQAQjwqcAfwtmC5X22EGsEsdlnBhOo)Vk2UfLbf5yAR0duZPaLOEGyfdL6Q4gyqXNaH57kWGIynLPjIA)18x5iOuwmAHkRK2GeOC(9hWh5LDGvEac02RCcu2IvvzdmzLIkjzBupUU(fLz0WUP4MtvLChxQKKhM7hhU2dXJaN7z4z5eX8FGLokl3F99thtG(M9CTKQMAgu5eUIQ98xbjVKeBma4u3BrxX8j5hdAkyYCaYq)vdSYVaB1jdUuNNzCDUt(m6Q3mpUlmn6Xqr(vTdMvfsrIZCs8k4xI8laRrjRZCEMAH)zjxFvAbmG3MW4WSD0c0uqd0FltNDxzsCgwtck2TBDjjSeWe7C)07zGZ7KupXGWee4RpwtDOBEbHYjLnzAr2o0)geU4XkebKbaE1thjogUSPUL2r68zWqTCh1yHVhDCYvJmo0adJuPNbcdk9mECTvaRVwEWFY6u))KvY9M6GvBi2)fhqhwdcsYhvptp83QK53oUs3umEsAmBy5oTXAS)AlsCUgkuNJj0Jek0GgCt8fXo4tt(6YtLmlWD4mhNj21Gnew3MITgte(vvD2PoMe257WZYtQkh1cckLEpeUoeJpTojgks6qoTpbDAyDAiK2)AWdurku4xo4DBslcd0MUidQyBvsCr2O8hF8gVBpSwdSz3sXzvSVSPn3tnPKdhssZlGDtoTBHxchRnZ4duUI1OlBEmovh52xnZAUD6FuvSxhNSdVJw983f7V70OOIIIXNX9B(UuYnCDywrc8)VZFknCZ)3XL)i)S7GQn2GfwGVvL43Ld)tm)R34xUcpHVCXlBjMX4FsbBW3(I4nXeeGN2xEc(HdeheX0(wwGffFwt(k4x2sBAJpKhofjFZ1P1vC4kjken3Bqbpb8FWuM0vJQNiD9SGb2Yig4LK2AfoiYAvZhsPUKMpxJudKSJ4Dtzm9hYKL0iCzBl9fay6z5Mjuz0sXmjtrsCioxwhQSsSoWsg88Ytgyoq2W2RUKfxvQSA1(CsvevHwRzAxLPqm6OMro7woPj4w8iNtHqNdmL5oFD1QcPRubMn9gcDs6Okvd3txSkBp5qg0rhOcL0hgY4XwxscY3EMTx2dF5eAwKXr0O6EysDrVmIm6ONEp2JDuVCmDrFDfvAM1EatXFO8Hrm7QGtlMdSf84Ik)QkVZ5dlM)OFkEukzlMZFdVH7Xuzkdd9UYVaX3HFuA)7cX7Rnlb)wbaR7KYx2lSVal0Srh)8VfIVHS7(j8trmgwl(WVJ4TX8oryT6HYvh7sNVm8Rn6upa8wyS1W9eP6hupbIja5ne5DIwdVHzcESj4uO(pAM6nk(Cnl((kHoh7AdTgUNiTtbgjiVHiVt0A4fLtWJ7L2GZ4xxR5VA478m2EBXE3491MlCU4Z511Q9Rg(opJQ3wS3nEFT5cNl(CFv33VTyVB8EE2O9LQppS3G3BEv5g6u9Rl27gVNh3OVu95H9UX7lkPblu7zLy6XptKpF9hm87oPm6nVHnFxAi2(wbwHzCRrEXjSGDaSYcoXQiT6(nyqKknCprATYLLSRPG5nf9Vzi(BeDNCGjGitCIRMeBnFZvuOVF3dOoMj9fbQd1PoORZMS6IQQ5NV3QhjJgfTgwr6BgPDl9PH5nf9Vzi(BeDB2OW0DJJc990OW(m7PrXjrxNnz1fvvZp)WBrKc7iv(w0zaXAG0ZZp6fygBhPwPysq61zCCUgdVXOVhi(v9qumVm70VsFgy(6W8kJEtkn94SRoPi)VXOVhiUFY1x4rLsCvnn4g4SKR9h99uU2kgZB0fWL0rExgtAxdwnn2EE9BjZRQlXT(k705kxD5BRehFf5Jx)nJpE9BiFSPABZNWj9njMWIWiG99u165kzbW6A9)vEz(i(VT67h)4s8tPglIFX8SdS1l(9p4Uyo)zyNDP(OaGF535nkgX0wmxUdGSyE5TmyXFFr(IF3fHt0UpwmhHTEoA9eeT5DdoVMNmp5aqtS8M5xjYWFkQa(hv(SHQ45ZZt06AAK1L3FqCDV98xxBNEa166kVUtOx3WnlMJFoxmyrv2IYkWhxoaeShxAZg54YVx6AaQLR7XLtpUC8XLp)8PGeI8ERq0qrZ1jn8GGP9xQoKcToaAVBukZ7qelMdZUwS7GsT3BwQrHP2AaIvLqc7Axct4)90LWDIe7syRCMpC(2r6k3inRQDRxnaN9CbQs0YnEPjwjb3wSZJSHe8DNpbRlR0j42LVyKGD7GGDBi4p(Y09QUKZYAF0Sq(kYPytzgi2YMhvO82P(71kaqgjhylhx(344cIOFC5p0In3igQH0qEfCiG)FwlQJ0131kaCYuNUwTzQZrI6uTYCQ19CrnaNXNVoRPKrOTsexNy(A6C(RPP0sOv0Lwt3tEnDvXzF6xl8vspTdRiOz9nbaIs9mkum368(l3SgYFWHCeRNYanIB1rqAWOigXcCNpV872Qo1oj8wbU4RbxpY(P2yyuI2XH9tt5XLforA1Ox42NtQtLKC)spj3jn0Uu7KHk7YguP2nhq0CZ4Y4MAd9PYHaNBT(KkfJoHpiVmz9R(jhHyRLHdsBmlt7IEBdvYPVCTZjYPXlAmnAjIRNIJI0VQzVurkekBnSw9Ctu2VsQzTWbr6evat3NA63QcQD3nPIYnGiIedA4Q89o4tgV9(Y)EZIBnAkD0wHBVQyMxuQ)uFF(e6BsbQQ(wk46QLAQxyhKHn6LQ4LowzDgj6Ow9fjBo5YAwozwcvjIWZS0HtDA1Hyiw7SPAwoguo)A1jIOskttzX1QYHBhkhUNMYHB3kheGCskhoMvoCSPC0(t8OpkhUTvomMMiHYHIzkDcuNITDxjlFPDJWbKYVEB92tNh9McnzUsRhwIJHufN9QUtrOm4bVUFXic2tCQd)fUpmrMkTnNfwLdTLLNNmWO7GE6nQ3uOj7FRASeABVY70tvBJWJIEsQvYuej82w0Pwaq1oIQng1ld9oD8oSxsWodUxZpA2Quvu1C(V1BdLscA16F4mCh3XvuPXe6kLl9uvZ(EXQUG2s1vupBPmnSjKgXghtrTANBTgdBe6DtSSaa(RtbwwIqv4A3vDJd0ChVQsOtWLA3YLec2j1mj6UHuB3619ak5A8ZA66tKfhF6e)mrgh1YytKhs9MgBq7HKfnt0oLpPUjfFty44LTSjqnF6M(uhkrQAHAa4owMkv6vaC680pS32fflSh0s9S(H8Rohsk3nUbOw9nQkFL1Md6DpkjXznmkDrQ2HHuBPoQYl1U)eNvOxTir6(AZQMjP1BQ4OtVEItaDknTk(5NONTBdYOoJczx1vTYkoAuF1F1nUkTZnW1vgS6ozLou3idLARTshuRhKMPg9uL6p6HaBlu4XB1CKAQnrkX76SYHc)2WZxyZh02R(QYVbMItKRKa0FxRkhdOghsHxkoCpvimFUxcRU2nUkjtsdxvBrykqfeC58LM1V0UH6yR0wvQUALWTtRCpvD9qTwMLvT8VxfCIte13AxP0WvV8VuhgMIkiTxNYTtB)o6HQlD8iLms7o8KakQKBPpLXHw3GA38yQZzRhSpIl5Ssmh(Q3U9iiErInetZ7AK6q30uzA6ZdvP7rFv9vieZjjHr6VTkaizJ3Igr0IieDotQOmkHLvk5UQ38tJl2k1jQtyYIeQobgI76(5iIAUw4uNDslVI1TQG2RLE78rsnOQNhqwHmTAGSpJw(HkBjaKfNzZrudhW1QrKKVNw160G)oBvy9WFK8kz2LQr70lSAQAYq0YBzsmbQggufBR2XuRw6wJ)qJDveX0Tm8aJJkNJDPcHIfLsF3GmtBnnd9wtwPrEZbsi3KYuu3n2WY4AR3ow2(SPXL1GIHsCrvVE92cOE5jZvxFNsjPewhg7Tj8LDY3yzQKAyhjIlQLaTlCMq7NOhzDRvwqdDBOPPryzZFKU5kQwrAYBj7DRhnGH2at3(KnrX46k3DXkJAnX42P2kb0mA3(1iN2m(xL4qnDyrJMPDniQMZ2kdPXuGQmeZwfQTRnJkDwkr5flJOz7FySzE057528g0SFstb9neA39dkf1iTmAsM7uHtyKQbJz7vD9xPu8oLOG30rPZAnuosd4BAx3CPWsRgnfnw9Iq0GvP8z1M(JoO3QaAth(rfkDLMQj00t4icok1B4wmxQ5WHLUYRLvuw7RFPSn6f8ohNgiNrssMY9IOwqZMxeonPBOtTv7ikjRJutmL2EVs8VfFq16xUlrHKsh5oqULPw72RaVVCHlr)k8R5W1Vuk7PA1qf)M2Qkx6KlQYr2sYjdjZwWSZhdD(U2HEp)JwXsvyMfjvDiV2Id1snDA7XIi2PLQQkZ0AkpvlzkWAD6CcV1rz0N0qXv6g6u6UPVjmyP0QtmeNLsN6taFtzmymGVLIyKeeJhtZG(q)IozjVAJovVSDEKDehwXwtRG0p2Zehg3JehmF(cxCUoWCpHW3DL2z)zyM4w96qZpNOsUkF5GvEK02EVV3zNOMoOsChnaVRhPXu9Fl())]] )
