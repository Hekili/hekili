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
    armored_to_the_teeth            = {  90259, 394855, 2 }, -- Gain Strength equal to 2% of your Armor.
    avatar                          = {  92639, 401150, 1 }, -- Transform into a colossus for 20 sec, causing you to deal 20% increased damage and removing all roots and snares. Generates 10 Rage.
    barbaric_training               = {  95954, 390675, 1 }, -- Revenge deals 25% increased damage but now costs 10 more rage.
    battle_stance                   = {  90261, 386164, 1 }, -- A balanced combat state that increases the critical strike chance of your abilities by 3% and reduces the duration of movement impairing effects by 10%. Lasts until canceled.
    berserker_shout                 = {  90348, 384100, 1 }, -- Go berserk, removing and granting immunity to Fear, Sap, and Incapacitate effects for 6 sec. Also remove fear effects from group members within 12 yds.
    bitter_immunity                 = {  90356, 383762, 1 }, -- Restores 20% health instantly and removes all diseases, poisons and curses affecting you.
    bounding_stride                 = {  90355, 202163, 1 }, -- Reduces the cooldown of Heroic Leap by 15 sec, and Heroic Leap now also increases your movement speed by 70% for 3 sec.
    cacophonous_roar                = {  90383, 382954, 1 }, -- Intimidating Shout can withstand 200% more damage before breaking.
    champions_might                 = {  90323, 386284, 1 }, -- The duration of Champion's Spear is increased by 2 sec. You deal 25% increased critical strike damage to targets chained to your Spear.
    champions_spear                 = {  90380, 376079, 1 }, -- Throw a spear at the target location, dealing 26,945 Physical damage instantly and an additional 28,091 damage over 4 sec. Deals reduced damage beyond 5 targets. Enemies hit are chained to the spear's location for the duration. Generates 10 Rage.
    concussive_blows                = {  90354, 383115, 1 }, -- Cooldown of Pummel reduced by 1.0 sec. Successfully interrupting an enemy increases the damage you deal to them by 5% for 10 sec.
    crackling_thunder               = {  95959, 203201, 1 }, -- Thunder Clap's radius is increased by 50%, and it reduces movement speed by an additional 20%.
    cruel_strikes                   = {  90381, 392777, 2 }, -- Critical strike chance increased by 1% and critical strike damage of Execute increased by 5%.
    crushing_force                  = {  90369, 390642, 2 }, -- Shield Slam deals an additional 5% damage and deals 5% increased critical strike damage.
    defensive_stance                = {  90330, 386208, 1 }, -- A defensive combat state that reduces all damage you take by 15%, and all damage you deal by 10%. Lasts until canceled.
    double_time                     = {  90382, 103827, 1 }, -- Increases the maximum number of charges on Charge by 1, and reduces its cooldown by 3 sec.
    endurance_training              = {  90339, 382940, 2 }, -- Stamina increased by 5% and the duration of Fear, Sap and Incapacitate effects on you is reduced by 10.0%.
    fast_footwork                   = {  90344, 382260, 1 }, -- Movement speed increased by 5%.
    frothing_berserker              = {  90370, 392790, 1 }, -- Revenge has a 20% chance to immediately refund 25% of the Rage spent.
    heroic_leap                     = {  90346,   6544, 1 }, -- Leap through the air toward a target location, slamming down with destructive force to deal 2,646 Physical damage to all enemies within 8 yards.
    honed_reflexes                  = {  95956, 391271, 1 }, -- Cooldown of Enraged Regeneration, Pummel, Intervene, Spell Reflection, and Storm Bolt reduced by 5%.
    immovable_object                = {  90364, 394307, 1 }, -- Activating Avatar or Shield Wall grants 4 sec of the other.
    impending_victory               = {  90326, 202168, 1 }, -- Instantly attack the target, causing 6,644 damage and healing you for 30% of your maximum health. Killing an enemy that yields experience or honor resets the cooldown of Impending Victory and makes it cost no Rage.
    intervene                       = {  90329,   3411, 1 }, -- Run at high speed toward an ally, intercepting all melee and ranged attacks against them for 6 sec while they remain within 10 yds.
    intimidating_shout              = {  90384,   5246, 1 }, -- Causes the targeted enemy to cower in fear, and up to 5 additional enemies within 8 yards to flee. Targets are disoriented for 8 sec.
    leeching_strikes                = {  90371, 382258, 1 }, -- Leech increased by 3%.
    menace                          = {  90383, 275338, 1 }, -- Intimidating Shout will knock back all nearby enemies except your primary target, and cause them all to cower in fear for 15 sec instead of fleeing.
    onehanded_weapon_specialization = {  90324, 382895, 1 }, -- Damage with one-handed weapons and Leech increased by 5%.
    overwhelming_rage               = {  90378, 382767, 2 }, -- Maximum Rage increased by 15.
    pain_and_gain                   = {  90353, 382549, 1 }, -- When you take any damage, heal for 2.00% of your maximum health. This can only occur once every 10 sec.
    piercing_challenge              = {  90379, 382948, 1 }, -- Champion's Spear's damage increased by 50% and its Rage generation is increased by 100%.
    piercing_howl                   = {  90348,  12323, 1 }, -- Snares all enemies within 12 yards, reducing their movement speed by 70% for 8 sec.
    rallying_cry                    = {  90331,  97462, 1 }, -- Lets loose a rallying cry, granting all party or raid members within 40 yards 10% temporary and maximum health for 10 sec.
    reinforced_plates               = {  90368, 382939, 1 }, -- Armor increased by 10%.
    rumbling_earth                  = {  90374, 275339, 1 }, -- Shockwave's range increased by 6 yards and when Shockwave strikes at least 3 targets, its cooldown is reduced by 15 sec.
    second_wind                     = {  90332,  29838, 1 }, -- Restores 6% health every 1 sec when you have not taken damage for 5 sec. While you are below 35% health, restores 1.0% health every 1 sec. The amount restored increases the closer you are to death.
    seismic_reverberation           = {  90354, 382956, 1 }, -- If Whirlwind hits 3 or more enemies, it hits them 1 additional time for 30% damage.
    shattering_throw                = {  90351,  64382, 1 }, -- Hurl your weapon at the enemy, causing 11,057 Physical damage, ignoring armor, and removing any magical immunities. Deals up to 500% increased damage to absorb shields.
    shockwave                       = {  90375,  46968, 1 }, -- Sends a wave of force in a frontal cone, causing 2,252 damage and stunning all enemies within 16 yards for 2 sec.
    sidearm                         = {  95954, 384404, 1 }, -- Your auto-attacks have a 20% chance to hurl weapons at your target and 3 other enemies in front of you, dealing an additional 2,815 Physical damage.
    spell_reflection                = {  90385,  23920, 1 }, -- Raise your weapon, reflecting the first spell cast on you, and reduce magic damage you take by 20% for 5 sec.
    storm_bolt                      = {  90337, 107570, 1 }, -- Hurls your weapon at an enemy, causing 3,210 Physical damage and stunning for 4 sec.
    thunder_clap                    = {  90343,   6343, 1 }, -- Blasts all enemies within 8 yards for 11,999 Physical damage and reduces their movement speed by 20% for 10 sec. Deals reduced damage beyond 5 targets.
    thunderous_roar                 = {  90359, 384318, 1 }, -- Roar explosively, dealing 28,219 Physical damage to enemies within 12 yds and cause them to bleed for 48,514 physical damage over 10 sec. Deals reduced damage beyond 5 targets.
    thunderous_words                = {  90358, 384969, 1 }, -- Increases the duration of Thunderous Roar's Bleed effect by 2.0 sec and Thunderous Roar's Bleed effect causes enemies to take 30% increased damage from all your bleeds.
    unstoppable_force               = {  90364, 275336, 1 }, -- Avatar increases the damage of Thunder Clap and Shockwave by 50% and reduces the cooldown of Thunder Clap by 50%.
    uproar                          = {  90357, 391572, 1 }, -- Thunderous Roar's cooldown reduced by 45 sec.
    war_machine                     = {  90345, 316733, 1 }, -- Your auto attacks generate 50% more Rage. Killing an enemy instantly generates 5 Rage, and increases your movement speed by 30% for 8 sec.
    wild_strikes                    = {  90360, 382946, 2 }, -- Haste increased by 1% and your auto-attack critical strikes increase your auto-attack speed by 10% for 10 sec.
    wrecking_throw                  = {  90351, 384110, 1 }, -- Hurl your weapon at the enemy, causing 11,057 Physical damage, ignoring armor. Deals up to 500% increased damage to absorb shields.

    -- Protection
    anger_management                = {  90311, 152278, 1 }, -- Every 20 Rage you spend reduces the remaining cooldown on Recklessness, Bladestorm, and Ravager by 1 sec.
    battering_ram                   = {  90262, 394312, 1 }, -- Shield Charge critical strike chance and critical strike damage increased by 20%, and Shield Charge increases your auto-attack damage and speed by 10% for 20 sec.
    battlescarred_veteran           = {  90435, 386394, 1 }, -- When your health is brought below 30%, you take 80% less damage for 8 sec and healing you receive is increased by 100%. Cannot occur more than once every 3 min.
    best_served_cold                = {  90304, 202560, 1 }, -- Revenge deals 10% more damage, or 20% more damage when your successful dodges or parries have made it cost no Rage.
    bloodborne                      = {  90448, 385704, 2 }, -- Deep Wounds, Rend and Thunderous Roar's Bleed effects deal 10% increased damage.
    bloodsurge                      = {  90300, 384361, 1 }, -- Damage from your Bleed effects have a 10% chance to grant you 5 Rage.
    bolster                         = {  90264, 280001, 1 }, -- Last Stand's cooldown is reduced by 60 sec, and it grants you the Shield Block effect for its duration.
    booming_voice                   = {  90314, 202743, 1 }, -- Demoralizing Shout also generates 30 Rage, and increases damage you deal to affected targets by 20%.
    brace_for_impact                = {  90296, 386030, 1 }, -- Using Shield Slam increases the damage of Shield Slam by 5% for 16 sec, and it increases the block value of your shield by 3%. Stacking up to 5 times.
    brutal_vitality                 = {  90451, 384036, 1 }, -- 10% of damage you deal adds to your active Ignore Pain.
    challenging_shout               = {  90309,   1161, 1 }, -- Taunts all enemies within 10 yds to attack you for 6 sec.
    champions_bulwark               = {  90316, 386328, 1 }, -- Shield Charge deals 20% increased damage, grants you Shield Block, makes your next Revenge cost no Rage, and generates an additional 20 Rage.
    dance_of_death                  = {  90260, 390713, 1 }, -- When an enemy dies while affected by your Ravager, its duration is extended by 2 sec. This effect can trigger a maximum of 3 times per use of Ravager.
    defenders_aegis                 = {  90310, 397103, 1 }, -- Shield Wall gains 1 additional charge, and its cooldown is reduced by 60 sec.
    demoralizing_shout              = {  90305,   1160, 1 }, -- Demoralizes all enemies within 10 yards, reducing the damage they deal to you by 20% for 8 sec.
    devastator                      = {  90299, 236279, 1 }, -- Your auto attacks deal an additional 4,933 Physical damage and have a 20% chance to reset the remaining cooldown on Shield Slam.
    disrupting_shout                = {  90307, 386071, 1 }, -- Taunts all enemies within 14 yds to attack you for 6 sec, interrupts all spellcasting within 14 yds and prevents any spell in that school from being cast for 6 sec.
    enduring_alacrity               = {  90433, 384063, 1 }, -- Increases Stamina and Armor by 8% and your Haste by 2%.
    enduring_defenses               = {  90313, 386027, 1 }, -- Shield Block lasts 2 sec longer.
    fight_through_the_flames        = {  90306, 452494, 1 }, -- Defensive Stance additionally reduces magic damage you take by 6%.
    focused_vigor                   = {  90318, 384067, 1 }, -- Increases Strength and Armor by 5% and your critical strike chance by 1%.
    fueled_by_violence              = {  90451, 383103, 1 }, -- You are healed for 85% of the damage dealt by Deep Wounds.
    heavy_repercussions             = {  90319, 203177, 1 }, -- Shield Slam generates 2 more Rage and extends the duration of Shield Block by 1.0 sec.
    ignore_pain                     = {  90295, 190456, 1 }, -- Fight through the pain, ignoring 50% of damage taken, up to 134,040 total damage prevented.
    impenetrable_wall               = {  90310, 384072, 1 }, -- Shield Slam generates an additional 4 Rage and reduces the remaining cooldown of Shield Wall by 6 sec.
    indomitable                     = {  90434, 202095, 1 }, -- Your maximum health is increased by 6%, and every 20 Rage you spend heals you for 1% of your maximum health.
    instigate                       = {  90301, 394311, 1 }, -- Devastate deals 20% increased damage and generates 2 Rage. Devastator deals 10% increased damage and generates 1 Rage.
    into_the_fray                   = {  90319, 202603, 1 }, -- You gain 2% Haste for each enemy or ally within 10 yards, up to 8% Haste.
    juggernaut                      = {  90449, 393967, 1 }, -- Execute increases Execute's damage dealt by 3% for 20 sec, stacking up to 15 times.
    last_stand                      = {  90297,  12975, 1 }, -- Increases maximum health by 30% for 15 sec, and instantly heals you for that amount.
    massacre                        = {  90313, 281001, 1 }, -- Execute is now usable on targets below 35% health.
    punish                          = {  90449, 275334, 1 }, -- Shield Slam deals 10% increased damage, and reduces enemies' damage against you by 2% for 9 sec. Multiple punishments may overlap.
    ravager                         = {  90432, 228920, 1 }, -- Throws a whirling weapon at the target location that chases nearby enemies, inflicting 80,762 Physical damage to all enemies over 10.5 sec. Deals reduced damage beyond 8 targets. Generates 10 Rage each time it deals damage.
    rend                            = {  90302, 394062, 1 }, -- Wounds the target, causing 4,410 Physical damage instantly and an additional 13,585 Bleed damage over 15 sec.
    revenge                         = {  90298,   6572, 1 }, -- Swing in a wide arc, dealing 7,343 Physical damage to all enemies in front of you. Deals reduced damage beyond 5 targets. Your successful dodges and parries have a chance to make your next Revenge cost no Rage.
    shield_charge                   = {  90317, 385952, 1 }, -- Charge to an enemy with your shield, dealing 47,302 Physical damage to it and 15,114 Physical damage to all enemies within 10 yards. Also stuns the primary target for 4 sec. Generates 20 Rage.
    shield_specialization           = {  90315, 386011, 2 }, -- Increases Block chance by 6% and your Block value by 12%.
    shield_wall                     = {  90312,    871, 1 }, -- Reduces all damage you take by 40% for 8 sec.
    show_of_force                   = {  90320, 385843, 1 }, -- Revenge damage increased by 10% and Revenge increases the damage of your next Thunder Clap by 20%.
    spell_block                     = {  90450, 392966, 1 }, -- You are able to block spells for 30 sec.
    storm_of_steel                  = {  90260, 382953, 1 }, -- Bladestorm and Ravager's damage are reduced by 30% but they now have 2 charges and generate 10 additional Rage each time they deal damage.
    strategist                      = {  90303, 384041, 1 }, -- Devastate, Thunder Clap, Revenge, and Execute have a 30% chance to reset the remaining cooldown on Shield Slam.
    sudden_death                    = {  90320,  29725, 1 }, -- Your attacks have a chance to make your next Execute cost no Rage, be usable on any target regardless of their health, and deal damage as if you spent 40 Rage.
    thunderlord                     = {  90308, 385840, 1 }, -- Increases the radius of Demoralizing Shout by 5 yards. Each enemy hit by Thunder Clap reduces the remaining cooldown on Demoralizing Shout by 1.5 sec, up to 4.5 sec.
    tough_as_nails                  = {  90450, 385888, 1 }, -- Blocking an attack deals 3,317 Physical damage to the attacker, ignoring armor. Generates high threat.
    unnerving_focus                 = {  90452, 384042, 1 }, -- Last Stand increases your Rage generation by 50%.
    violent_outburst                = {  90265, 386477, 1 }, -- Consuming 30 rage grants a stack of Seeing Red, which transforms at 8 stacks into Violent Outburst, causing your next Shield Slam or Thunder Clap to deal 200% increased damage, generate 100% more Rage and grant Ignore Pain.

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
    battlefield_commander = 5629, -- (424742) Your Shout abilities have additional effects.  Battle Shout: Increases Stamina by 3%.  Piercing Howl: Radius increased by 50%  Berserker Shout: Range increased by 8 yds.  Intimidating Shout: Cooldown reduced by 15 sec.  Rallying Cry: Removes movement impairing effects and grants 30% movement speed to allies.  Thunderous Roar: Targets receive 5% more damage from all sources while bleeding.
    bodyguard             =  168, -- (213871) Protect an ally, causing 40% of all Physical damage they take to be transfered to you. When the target takes Physical damage, your Shield Slam cooldown has a 30% chance to be reset. Bodyguard is cancelled if the target is further than 20 yards from you. Lasts 1 min. Only one target can be Bodyguarded at a time.
    demolition            = 5374, -- (329033) Reduces the cooldown of your Shattering Throw or Wrecking Throw by 50% and increases its damage to absorb shields by an additional 250%.
    disarm                =   24, -- (236077) Disarm the enemy's weapons and shield for 5 sec. Disarmed creatures deal significantly reduced damage.
    dragon_charge         =  831, -- (206572) Run at high speed at a distance in front of you. All enemies in your path will take 7,883 Physical damage and be knocked back.
    morale_killer         =  171, -- (199023) Reduces the cooldown of Demoralizing Shout by 15 sec, and Demoralizing Shout now reduces the damage enemies deal to all targets, not just you.
    oppressor             =  845, -- (205800) You focus the assault on this target, increasing their damage taken by 3% for 6 sec. Each unique player that attacks the target increases the damage taken by an additional 3%, stacking up to 5 times. Your melee attacks refresh the duration of Focused Assault.
    rebound               =  833, -- (213915) Spell Reflection reflects the next 2 incoming spells cast on you and reflected spells deal 50% extra damage to the attacker. Spell Reflection's cooldown is increased by 10 sec.
    safeguard             = 5626, -- (424654) Intervene now has 2 charges and reduces the ally's damage taken by 20% for 5 sec. Intervene's cooldown is increased by 10 sec.
    shield_bash           =  173, -- (198912) When Shield Slam is used on targets that are casting, it reduces their damage done by 15% for 8 sec and the cooldown is instantly reset.
    storm_of_destruction  = 5627, -- (236308) Bladestorm and Ravager now snare all targets you hit by 60% for 6 sec and decrease their healing taken by 50% for 10 sec.
    thunderstruck         =  175, -- (199045) Thunder Clap roots all targets it damages for 4 sec.
    warbringer            = 5432, -- (356353) Charge roots enemies for 2 sec and emanates a shockwave past the target, rooting enemies and dealing 5,631 Physical damage in a 20 yd cone.
    warpath               =  178, -- (199086) When landing with Heroic Leap, all targets are stunned for 3 sec.
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

spec:RegisterPack( "Fury", 20241022, [[Hekili:S31EVnoos(plnwmUJ3jTBlLX9JftcWEl2fygCy3)iZU3)zzflLyDTSKp9iDNbb(Z(vK6ffvvKuYYojthmysNiswSyXQQFfFOslTw(BlV2ZnZF5)0EU9pzn32EML9I5wlVo7HD(lVEN76V4Eh8lrUBHF(pYtEG9WhcJD9yTnnopznuWMSSDP)L3)(7cY2KFZS1XBFFAW28q3SG4O1jU3MX(71VF513KheM9lrlVbTJN)5Lx7MNTjoz51xhS9VbuoWZZVO6(PRxEnR6VZA(7ST)l7xzznB(Sf7xLVJrR9)6(FTUylOygfWkC(hGc)hbFB)QSKGOV4N9(7DtcCVj0pD)Q4ep)K6Ap)ZVB(fNVFf7Fxu8VwZl(xohG2fZ)07Sxaf(VlE8Q80GO72V6xw)W7(p(brPIv0Arbv6sKp(UlMtxM9fqz)2gG6)pUjWpabFqem3KeFBqimJ4UMj6tNTlXhMnUXn7hV89WpZc9Ds3eNNT)xrRHFsQFYx8tCsZCJw7FEw8D3f6FzCeE9RKBNZ0pUmlX3D9g)K48uNSe3O0TbzzaTQBHZA30SZV3nm3)sBCkMN67eK5VvjfXBk8RFbMctJG))8GBV8n()F5b7257n72hsCbDXnozB8D8aAUnXpYJIoU37M5MWPqMBOFu2SSaqAaCqCYw4pntuWvSCSC8)26WCp)YrD5ZNznliDwVgD403MG(2kP)FA)Q)oR(GofOX7wBha)X644qV4Vgb64Eb3h457TF1npavIluyMhW)79aOeV628KzGw9T7xfK9w4V5CW(vBCHFpkE)Qe)TUbCXm8Rz5jrGblqw)Wu)MNa2VZ6Za2Yj9HO1NhV7Yu)SGBlh2wf)RdJ2xcK881XrEbmAkiXbgZHPEDt(T3o5SMNxnKN5LNWDy9d)q9Jkg21LC58hF0SgYLroGi6bHgpTpJu7HosTjgP2dDKQUHh(i1IZOPDmrehgp(4zTlaCqLnZn6bhVDPtEtfHN1XWRxCInkNytXj2MWj2dIt2LeeNeK9G88VT48VLWSpMiGpyMGWr8cE8rQsMCMsLMMYa4M1vd96YN(NpZA2IFSTqIr3zPGhPO7Y2a1aPRzQ7tNE1zknnBkZK(2YS(2QSV7ZeKLZw3OC3qmh7UH35NTXfq(Y)9FhqCVj(B9H024K2MK01ehi5U8TB9dzOxG5mu3zE(8Xpd6fcdzgdtitSbR3WQhVbbB9)zMtLhFCB89(mSUzEbfrcC1cX2Wavcw7e67UJ1WU12Uv13fZ(TwDQByOtXF6ecnQqa0egM2QwkuAvZWG72KL68)M7DhJByCw9un047w75K4UoWnSvRUX9oN4BbaYG1Fj102ueNeipznGlFfJ(yw(Uw1omo2J7Hu8P3gK4Zlr8HmHhOP6g6Wg2asnav3uAq09XFbS9)gGIhb1H1XfIJDXFfc0ki6wiwZ4OAMQ0PEbsC6vwlMCltg5u9GlTUyHGBa)V5VopZ3zhy14prKc57E8Xwn9NVS9uCsEu3jP0q3ha2kXf8rEEktcNb(S4QM84Qkkp1XlEBqeBOpPSGkHPJ7nUrEXrtyK(EyKh5VnWp9slt7A3T9TRDJUdAhyacR7HPfn4Ugg1B7xxRzuFLXDnmQ7zxRzuBqxdoLI8PNQ52MrGbJdRWV4NA4G2a5Drptott2Zh(mD9ygxAp0XSXsBY55HoMz9CdsLOneY6Ro7nuevoOYkFgwtqxq1uiutCk94J6wcMep2S2TZqB4KZ4E18JsGEG7vtSAaKg75tNCwfO5g3T7y9JZwMeL3GkosQSPt7nZMTjNT8i2YZsIl462ChzlB670D(LJ32nfxstoZa4Ca)ltd8XZus2QzPamoYlotyXbvT2z7gb9bZMoi4As(OehJZeftKBDt(IpGbhN4uui0miKq31F5YlE8XcKU0n(rqWd3DhdCnpRMlTlRqAoBROC88DZ2u2w7jDlPQzFeRz10K2kdMzDlJhRqwCtORheuai(AeenpRMKxcZHtEdPIlzh2qQUkGtoRUhBfFtD8dF(XhjMCGYuOOebpihymHHzgFlzc(9YapUjjhkW52GOG0nQ4Fbb2Bm08bkN5BeI(6R1J54D7ItYYHEtJ0cIylBtqsAMqm2B8DdHz3DRZ(5lwuz6DFW6aMTnSgTm)T7YkhxmcSoX939l0HU6sJ0fkQXmboFwrG7WeV1e2agcMZAHP8noRaMcRHfD6aJdN15jWcMYU6YprtubUXKowN9Qo5WWuNiB1xbMk8RbrEcTARpBxkH11CV4(Wj1q4p3sxiZscwwwOOCU2yLPz1PP8GMqay7jmQX4p19N5wovn5fb(AfZ2F81Qw(mdFTITEQXxruCoUyuvDOsmkAais69smaHALGra7SrUcoNVb6xU7gex)LSyxqRlOTDsYt3qcly0OWm(TpyVMOktdI2uzA8UoSOUUunfiqmLuG1lEjRrVr)QAik6xDH9h9JViwj0pYk9Ia)PIz7p(tvlFMH)uXwp14pv8rlD3c33cAULUENpXeT6kskGiu2mz39tudcWH2mC69KHFw1Hdd)enW)T937nImwIfmae2eHPUOyBehkxtImzlqPlgWWiSzx1uUcUT6qm0kw0XB6NE0BbrwJb4jNVrO)4XDJcn0fCfR8CeVqNxIAXiPInHJBsk1FGOQw(mdiQITEQbIqMIoUoYR6WH5i)ZTu5QEmAi8Jn(Afjpj4Rh7PfWI2qo40mpPeg28Lc2xy0MbPWQXy1r4GKU8d0(u0TaX2exDnA2stZzGHfhIcbHY5btK48LEsSYt54ie6dSys0ZKMiqnHr07(GSg9j4cHJ3fj2cIil0hOqBYwIqcJlxHnihXeODZEogEbPKdy27e9qJkbmjgH2nejebjRQZuema1Oykv39Kb93MnoU4zYZChh4mQ(tj4vjhKhXCH77ronzMlr0bknFjD2BCQ25y2q3xWsFmDo7nq)JPdvACuj5OQ(f0CoIBX(QXyW4wdX15EBDOlIV1eIZFAmx32b6NoXDq(PtEgFSvAm(RNuWDBN0)Z4QDdprUTtEQp6Q2SHEJWd3TDYj7uYA3FhIBBeEMCvaY9ARJKXCxYMC0ssQS4lCqsrRpapidBEO4Tpfi56s6QVJmrzfKUngc7gsHGjhkLDZK53Tx96zAu51kVmGx15vUaEbVoMFEtTBxk)4Mqa2o6B14bcz52(uGmfYY9fXjDHpezZ)1JW(VLrOe1CKTMDhNAHouBPPz09jgcd54coAqyUNSdQQD)PccJCAPpo8DPobfz(qve3O68SAjU9tylvGEhuOPT2HTg9eQIr2KM2va3XBcXz80t3RM6HjXDqortEjE8p4J4rXNAs)piiPPBYvHmmFQjp1hKtB24u4tn5iF4eu9xF8PM0Vn0MCGPFTdnUzjItUqVste)Y9lVBLEt8E8rEi94r0p8rR6WI16gpr1(PtWEAeaAuUPkwaiGNza(n53SYQxtw2lJKxSdvwEiZn9lOTXOu6at0x)Ei665Lw(Igk82jcRgAxOBe71AQnJwKhmk7X9R(AaOqTkJ9SnGTbO7VFf8JGTUzSSza)LQ9Cw1cd3V6gE(5G98B5tLRCbbXQDUbjSNvqQ)AHpe1dU0W4SQ3kvRwJMmP3hBS3u7Ix43jNvy4u60ITS9MxfAa4ZH9g6E1CgYc2ZNYEVTrHC66o017H6ZHVP7i2uhGW0Vw7cCtXR6DvNHMabkDMH8UNx9gVFP1uXKSa6R59vx26LrDYnXP46ROtp2Otp2Ktp2ANESjMESFYMESqMESiMES610J9uXj2Em98NkswiXrHpW(Pp7hCJpbBxGCSKosrwjHn6pVQgmZ5y4NjfnRMJ3V6FbpkaiCKFqr56P2nXm7620Xy1hU1nD6w4muBZjsQo02WkDpOVxXS1WuP5nBAR0QXqyxY3)lq)BN)AWJ7v2IzdeDcxBCHRnYW0iU1wNW1wHWTtVIzPqoNmTvMcziS7OjCznYbq95B(M(8IKcfnvEnMQqgQcmyAzKh)NoP)Hz1zeIFuozzienqzEYG1gXxF7jNL4g454FppEEiKIzbrxzTaK2Yp3)BbPzPtnPBfcnbTBV6sBqkG3bSirXE(e5hxkxUAHrSuRS2qjtvb0S1nn1DDIpeloRbEO7epFVoLFS9Ct672PiJYoVBu4Sz7w5tc(dyXL)ZFAUWHTYwlGqLBf(VWZB9gZWF8BWx4eaJcZg1LvkPkkq0YTLiC6YRHLqZYJg1zNoRLx)v3eMUw6YR5rBgSL96IcrnYsiwVT56TKM9wwYTcSW4bqMgVfQmSsX4YOpH1TfDNFka38FhWGaz5PU)wCe0H8IFlkcpqYSyQcRMAHkDM13MEcO8fpjuUCT9y0TSOEsvPLqlry5fy3pApcYIfVaP8hokZFFeNQnw6s0uWfaLTXCcgTAv)YCz1ZjjiLEWGj4pHtq5JwvIUYftrEEYReH8IBIOePBT3JDi7(FfXTy9gkpsEfLpkojouU4x9mQZY6LPNrvEzomkt4P5aLYFIqBwAZKL1ML3RzcQ)5tM3XQlpIebREmj5OS3gSVrcvRrY3Ofb(4bpFP2h52Vt8r(sLVpE(ZE13EdLjc7zWXLO0d8bkHj88EW(ju7f(qCSte13a8eJ6llT(vi97La(EPY3ukchxkpCtncQokoZoEYccNzpRPSQnhy4ZFJ)s4jC(oaxzQ9nowbvo28Rnb8WGrkv5rNFxbE73ZE0hbkF88Z8Qp3trOPhVTn94r5xkBilH3Xb7mtDi0Jve6e(koa5WOVpYuWedNGeMUyVl6s0gRkgIdjCL1E7yadncMwhpkF8CH96onOne6d0LZR70GYOPhSBhlQTMV)ee1bJN)TU5H915cH2zruZcFMf66iSD59foq(diGe9LlMK8e2aJh)t0bJ1QaicCA84FIoySK)eHNnE8prhmwYFcJYoF(jKOFNY7BhmwYFcV1Jh)tD0FJK8Naxy84FIoyKK)ubNoA8pvhCWYFumK6VSxVTxOiNWJZU(QBs)1HSUJkRBMMkRo6N678zp6qnvwDGr1JqXpzFiJjPInKO13KWQB6ocLXQZrL8hnc)eX3X78lQrkyGfrpT1CTSXiVzFAl10s8VTLAuN0WxdMT0XvkINV2muPvrNI1SkHUxOBY5F86CCP)XJYpzCoTPb1h9vm6BOPXq(SVQrNsdFny2shx1iq7SRnJbGHgQk(bILGYsvrZAPhfZz1uvjpJwfnlC9anjo203ekJ(UUHqDQ6z6iW0(HnT6ma635BIlXeSCDgB6tQAsr6HgPXXM(MqzZMuPRNPJat7NHP8G8bvMWJ2WuEmN(MQ80bY8i9HYgfxIYyv6ZuTK9GHFESrdsKAgwUhT02JvFuSRK)Nq527p5YT3FeKBnQKD2f0ATD8VO3iQ8KvSTYFN9RSKcuF7Wr8mRRNWpFUI2ZIdOh78blSP)DuAo)tViRcfVWHa90KNjAKTkCLx9I0I5cxOSwcWJn5gTT25es5AviXShabKUqXgs0AtXYx6vecJuLJiX1swZXyncl)W7gLq5u(ESvOrBtRrFSj3OPgFcPC9eMsdKofBir1QdJwLJiX1swZxbJrgihE3O0aHcYCGU8prKBy(2oQexlzhzrWajxNJB5W8GDIi3WmvpQexlzhzrWajh9HGnKb9rL4Aj7WmmnKNhgXNP9DbQVxzVJ3Dd(17j9ts8rJgLpoVBkeN)(bErajU5kJ0v2J4ELCi3yVX7IcR(g8(6Rg4ZB((eUZcJI57lZBF8j8s)mks5V3ZHfh53oqkmZ(78TmUHX(2TV)x)LTv7sRLDZo1gYsGDq5lVM)Bl)TLxlMm0G)(FAXEyjbx(FT861jbS3bex43QcMuklDV6NHoz)QjadQsZF)QhFC)Q3OPwlVUGxxETykPBz2Y)PnjJ9MI0f6S6myTarks2YS2Fbz7ptlNdJTZK7KIXJcJY9RMw1s60aUKqHWthNut7ReSyEIn2)jYXoLGtk3ZZiYcvcqzzJETHjcPZvenQ7w7nBR73Qh249HoHb08MXKuEVNnM(a5ysB2TxqVF46gesGgEUHfyS7hjzxsxTT7MUjQEyyCPG0UqMsQVIAz9jd1UupNFfWgFUH(nCkRl(m98KUpg97xbe(IIzeEvP(SaWNqTfQyRexzdTS5JJU1qKmFKImT6RMrBzkTKnuTMRBsUdEsddj)bewqrQkV0Z7dfE5HFZz3AaCjpjb6TIjMpTqyaj)raROkxio3vMDq59f3XDTnOyscvKfy1K2fn1iNA8r7WRtUtLpvCXcrxwubcqncP9mY08lepwqTWmES(GO4jP5dmGSW5JI1RP)LQ1NAtTIUrQoFUdLk(Yiivp75I1RsdvQowI1PzoqQw0y3kcNPHU1F0d4e7cXUK9DVrU30G2j4du0aH)e(x54LS)7AH0HO64IQIEMyTG9f1284E0GDx85351qFAzqW)W4iPWqB(2JOJOJKabe8mdJ9XKbTUqCOJz4zzio0btuzNrSk1gqqfa8sH6qn)kahth5XtzixkcsGosC5LntfSLIOd6loSTbWrAr9PGJlhBkWZveUIDT1fYxuADnwowNs8Z6ipmaoN2PJg9C8Gg)Gzy6TJIahtVDmeIFwKAxXAmsEIEqng5Z29o4vmumULsQy8ok09tFhFPtZfNQvhZxl9UrfKwDWa0WLu9dcMlni2ZsmxTyCNymx9lb(Pb0L2)g1Gscyv76GmgyL2DKz7gABCkYLtUqSwkx7UM4FL(m)vOjxU6yflow7gEzSa7tgcq(zZa)KwDmnqFFwHS6aLAVWxI1J3AATzDZYa3I33JAKBu0tj6)DckigKhTjxpqGOXnF5Uj60qZplr704P6WdDP12vP1d2jgBv76RFsGwPJabrFv5riSGe8vBqfgJLyACaCU1WdOapqOd9qpTUWqypnXZJMmafxnnEVVWmmsDbpOjAXpQh7Sn8pfkCBWFc0ZsKFAU1W9xwmz9Uu5INpt0fn92mRblWOLz3B4rZxP9FScqWWLj3JW0nckg1m71t3NiWKxpD)raAEepD)ognnflTNQMD2)hJ410hMWjoGn97g)XwTO2JOjbCy6wTE0ux0FEcJW9NG2LRHIjA3TSA38fQTqu8bPy4QV5bT2qtL7ptpU(adMTeogKEfqVQqKjSkueewpJM3M2(s7(tP)InOklAJhACM8o9qUNrD3cp87XHHrHB)bJI(vZgK3VOFn46vC6J(vBFzsaIVgIC)IhUhHQ(6EO9KhQQIiRnB7okymDrl9C4(y(hGOYfVUrToig54TyYiDXKnT)XPpEXDrJ6ByCxA26UyEYTjh4czjFlaALhK3WVFPcYd87ScD8w0owlAXmHrathdyYs1WcphLH6O6IQQ9Av2HLRTZzvf7sftpEmmMLJ39Er1DNTxk5uHDQna2ESO12hYi2DIvZYYmmQTYV7cQdyR0cOYFMBAgm5nJLFOYAO8U8TB9dvhoel)auOJoFw59pFB89fXI5bwOSCPpxlBrlO1eDVVp4eXwGkSezfaucY(D1bCuZ5XLkrIYxz47A2Xnm0P4pCyVYvfV4vorUBbnRQKrwkgIQruO8v9pvnovDspdiba6a4)RdCdfW25zO9uac27oMCrn(IwQDJ7DoX36a826VKQgyGRHiD1aeiKFsQFYxaTNgF)Tm1lchrYcTLPWTbj(8QkxRwN3othawBgaaXK2Yvv7(jq(bEq0Npvw2NxhgJiU4AMByM1hiczCGGxP8isLHwVjFQDy3hgx5sUgtgVyTGzk3CK(W49sIF1bW4fhHtnA0bZ49sIFimEX1)OgEufJt(rCyWs8bPQiKxcAGSpy(Uxc8dGVB0W1ggHr8DVK3dsrr8c(AuqlgX39sEFa8DL(nuw9x7JLY32j4zzH(oPBIZ7SZzS6LfF3DH(SO36GmbdIIaiKANmIrmaQL6le9tfgk73cZH)XM)SAuD8CPz9yWzD5Lsw2dVY2309uvajqMwlWILgq2TZ3B2TpaGLWYNDY2474buBBcpSxHjhPn9I2ZOUDoraMUEBKKDxPxalKiNO)EL0EsG3ahlh)VTom3dDv39OFv9DsbRFTf7xz3fL9BWTTSaBgIIz92QDaalvwvLL92V6h6UW)Mcloon(ojzmrqYT)veAkBHePaJVRqO93zYk3mMXUBDxK2qRZ3VYl4(apMdIBEaQeN)2VILPA4DZ(vq)mB)QFbgSbzVf(BU0F)kqoSFvumld2W2edqdL9Rz5jaVybK1pm1V5jWQmMHRcWYrWKtYomQS8AO11Z6wnbSIpRHrQUAafDlYmST6zyKK0C)NH1se1ZWQfnYREShgsYA3L7jRu5IFUdQ2HnKK)CPnwjh3DIN1fPnlyyyCS8SLmh39d0ajhBRHJTf4ycuitv)2LeedAEpi5RMkVIZzzQmiEXyMU0c9xTQWVVvfyT1PPWP7x9N50WITzb)yh5BJ8VUMe5F8Qd54QoCfQxV33QcgZvY6X0CLLax12WYsiacSv81dLuQKwoUDbe7wUBi6I16rFsL(YX1SR7ZSgAMUezRO0ZbyX0xPfM4g454FppovpV0zSpdbSyqxuFQxY1W)BSKPtxCT)tntkmEGqu3f6gfvURg93TsN4JRpcKZuYDfVWf4LnPBrI31IfsEByvWPOcdlC3Md6CRBAQ76e51btTh61NqlwfGvNiWKLBYRZoWmd9AYPNn7U9umt)MDPVcgT6HfBIoWjFAU0w5ZURfsnU1T1qQSwhrvDrVH6qLC9EqqbOUoLsGQkuQ9w7EPLasAgwAV9kEzpldmdZKRLE)VvvXAjRMpqaygc6wRc2oskOxkH4iA1Pzvsik0n8cFGXwoAyCM4FJWmy4J44Nfo2eMbfvUQodBbiOQCNl32CEZHXROktfXyhWXHZvGKoa82mOULXvbQoHc5ToWg5Ht7Vvb0rPw7XcnwJQWzQC2pTZcAKqUz(vVLTBgo1eMzEgZENOqv33VINinlP4(vFniBd8NSNTbOdyTcl4ifMvkYCMCFmNZQwim3FduliwapwFMWQPBe877Cls7MfK6VwiWX8LjPHARuJ0wJgPD)0iT1RrIuLN9AKw0AKwQ0i7MPOnrJ0URgzNiCvPr2YHKn2o50hNy6IZ)m1EBMGQZySBkd9sAmhs5Jax3VKgtXwz5OosvCzlavVD(R5UjyNmjYEMW2QJ4OWhy)0N9dU7dbVp7sIzBzsXEQWyWZRQbZHum8ZKIMvZc7x9VGhfaeoYpOOC9u7MyMNPw0bB7(u5Fs50q3PYHnfq6bYqhGgZHuM)kvyru2g5rAFv266prEpxRMsz0WzJl7II2Vnl2itzTUwNA0KK2ygQhYndhHmCs73tA0TX(mraN)yFnv5AG0xvZV)YzkyhrXRjiLA68Acs52X(Dcs75W(KCPu1D7krguh3eKImp2wtgjhOGF5b73lRZf02OdlzFQilKmK3RzImhsRRxf5B)HMlAynIPb5t8xrm)(fXuPJojqu1WrJhSNbePsuPsH81K3Pc33NyCsT42pnWKprjVZ3y2RiHwm4bMpozQC8(3SCQz974AlKCLVJRAVWRgh9WZTm6TF0))iUelWIItQuGnJb0QWUG8lp1IqRfxyzN6I)gkrTpjWjCtUqDhWIVJHncgNtkBJctjuRBa6obw2CYaly2iW8Ida]] )