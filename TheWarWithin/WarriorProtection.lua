-- WarriorProtection.lua
-- August 2024
-- 11.0.2

if UnitClassBase( "player" ) ~= "WARRIOR" then return end

local addon, ns = ...
local Hekili = _G[ addon ]
local class, state = Hekili.Class, Hekili.State

local FindPlayerAuraByID, RangeType = ns.FindPlayerAuraByID, ns.RangeType

local strformat = string.format

local spec = Hekili:NewSpecialization( 73 )

local base_rage_gen = 2

spec:RegisterResource( Enum.PowerType.Rage, {
    mainhand = {
        swing = "mainhand",

        last = function ()
            local swing = state.swings.mainhand
            local t = state.query_time

            return (  swing + floor( ( t - swing ) / state.swings.mainhand_speed )  * state.swings.mainhand_speed )
        end,

        interval = "mainhand_speed",

        stop = function () return state.time == 0 or state.swings.mainhand == 0 end,
        value = function ()
            if state.talent.devastator.enabled then -- 1 Rage for instigate with devastator, 2 rage for instigate with devastate
                return ( base_rage_gen * ( state.talent.war_machine.enabled and 1.5 or 1 ) ) + ( state.talent.instigate.enabled and 1 or 0 ) -- 1 Rage for instigate
            else
                return ( base_rage_gen * ( state.talent.war_machine.enabled and 1.5 or 1 ) ) + ( state.talent.instigate.enabled and 2 or 0 ) -- 2 Rage for instigate
            end
        end
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
    armored_to_the_teeth            = { 90259, 394855, 2 }, -- Gain Strength equal to 2% of your Armor.
    avatar                          = { 92639, 401150, 1 }, -- Transform into a colossus for 20 sec, causing you to deal 20% increased damage and removing all roots and snares. Generates 10 Rage.
    barbaric_training               = { 95954, 390675, 1 }, -- Revenge deals 25% increased damage but now costs 10 more rage.
    battle_stance                   = { 90261, 386164, 1 }, -- A balanced combat state that increases the critical strike chance of your abilities by 3% and reduces the duration of movement impairing effects by 10%. Lasts until canceled.
    berserker_shout                 = { 90348, 384100, 1 }, -- Go berserk, removing and granting immunity to Fear, Sap, and Incapacitate effects for 6 sec. Also remove fear effects from group members within 12 yds.
    bitter_immunity                 = { 90356, 383762, 1 }, -- Restores 20% health instantly and removes all diseases, poisons and curses affecting you. 
    bounding_stride                 = { 90355, 202163, 1 }, -- Reduces the cooldown of Heroic Leap by 15 sec, and Heroic Leap now also increases your movement speed by 70% for 3 sec.
    cacophonous_roar                = { 90383, 382954, 1 }, -- Intimidating Shout can withstand 200% more damage before breaking.
    champions_might                 = { 90323, 386284, 1 }, -- The duration of Champion's Spear is increased by 2 sec. You deal 25% increased critical strike damage to targets chained to your Spear.
    champions_spear                 = { 90380, 376079, 1 }, -- Throw a spear at the target location, dealing 109,239 Physical damage instantly and an additional 114,148 damage over 4 sec. Deals reduced damage beyond 5 targets. Enemies hit are chained to the spear's location for the duration. Generates 10 Rage.
    concussive_blows                = { 90354, 383115, 1 }, -- Cooldown of Pummel reduced by 1.0 sec. Successfully interrupting an enemy increases the damage you deal to them by 5% for 10 sec.
    crackling_thunder               = { 95959, 203201, 1 }, -- Thunder Clap's radius is increased by 50%, and it reduces movement speed by an additional 20%.
    cruel_strikes                   = { 90381, 392777, 2 }, -- Critical strike chance increased by 1% and critical strike damage of Execute increased by 5%. 
    crushing_force                  = { 90369, 390642, 2 }, -- Shield Slam deals an additional 5% damage and deals 5% increased critical strike damage. 
    defensive_stance                = { 90330, 386208, 1 }, -- A defensive combat state that reduces all damage you take by 16%. Lasts until canceled.
    double_time                     = { 90382, 103827, 1 }, -- Increases the maximum number of charges on Charge by 1, and reduces its cooldown by 3 sec.
    endurance_training              = { 90339, 382940, 2 }, -- Stamina increased by 5% and the duration of Fear, Sap and Incapacitate effects on you is reduced by 10.0%.
    fast_footwork                   = { 90344, 382260, 1 }, -- Movement speed increased by 5%.
    frothing_berserker              = { 90370, 392790, 1 }, -- Revenge has a 20% chance to immediately refund 25% of the Rage spent.
    heroic_leap                     = { 90346, 6544  , 1 }, -- Leap through the air toward a target location, slamming down with destructive force to deal 15,558 Physical damage to all enemies within 8 yards, and resetting the remaining cooldown on Taunt.
    honed_reflexes                  = { 95956, 391271, 1 }, -- Cooldown of Shield Wall, Pummel, Intervene, Spell Reflection, and Storm Bolt reduced by 5%.
    immovable_object                = { 90364, 394307, 1 }, -- Activating Avatar or Shield Wall grants 4 sec of the other.
    impending_victory               = { 90326, 202168, 1 }, -- Instantly attack the target, causing 39,061 damage and healing you for 30% of your maximum health. Killing an enemy that yields experience or honor resets the cooldown of Impending Victory and makes it cost no Rage.
    intervene                       = { 90329, 3411  , 1 }, -- Run at high speed toward an ally, intercepting all melee and ranged attacks against them for 6 sec while they remain within 10 yds.
    intimidating_shout              = { 90384, 5246  , 1 }, -- Causes the targeted enemy to cower in fear, and up to 5 additional enemies within 8 yards to flee. Targets are disoriented for 8 sec.
    leeching_strikes                = { 90371, 382258, 1 }, -- Leech increased by 3%.
    menace                          = { 90383, 275338, 1 }, -- Intimidating Shout will knock back all nearby enemies except your primary target, and cause them all to cower in fear for 15 sec instead of fleeing.
    onehanded_weapon_specialization = { 90324, 382895, 1 }, -- Damage with one-handed weapons and Leech increased by 5%.
    overwhelming_rage               = { 90378, 382767, 2 }, -- Maximum Rage increased by 15.
    pain_and_gain                   = { 90353, 382549, 1 }, -- When you take any damage, heal for 2% of your maximum health. This can only occur once every 10 sec.
    piercing_challenge              = { 90379, 382948, 1 }, -- Champion's Spear's damage increased by 50% and its Rage generation is increased by 100%.
    piercing_howl                   = { 90348, 12323 , 1 }, -- Snares all enemies within 12 yards, reducing their movement speed by 70% for 8 sec.
    rallying_cry                    = { 90331, 97462 , 1 }, -- Lets loose a rallying cry, granting all party or raid members within 40 yards 10% temporary and maximum health for 10 sec.
    reinforced_plates               = { 90368, 382939, 1 }, -- Armor increased by 10%.
    rumbling_earth                  = { 90374, 275339, 1 }, -- Shockwave's range increased by 6 yards and when Shockwave strikes at least 3 targets, its cooldown is reduced by 15 sec.
    second_wind                     = { 90332, 29838 , 1 }, -- Restores 6% health every 1 sec when you have not taken damage for 5 sec. While you are below 35% health, restores 1.0% health every 1 sec. The amount restored increases the closer you are to death.
    seismic_reverberation           = { 90354, 382956, 1 }, -- If Whirlwind or Revenge hits 3 or more enemies, it hits them 1 additional time for 30% damage.
    shattering_throw                = { 90351, 64382 , 1 }, -- Hurl your weapon at the enemy, causing 63,053 Physical damage, ignoring armor, and removing any magical immunities. Deals up to 500% increased damage to absorb shields.
    shockwave                       = { 90375, 46968 , 1 }, -- Sends a wave of force in a frontal cone, causing 19,862 damage and stunning all enemies within 16 yards for 2 sec.
    sidearm                         = { 95954, 384404, 1 }, -- Your auto-attacks have a 20% chance to hurl weapons at your target and 3 other enemies in front of you, dealing an additional 16,551 Physical damage.
    spell_reflection                = { 90385, 23920 , 1 }, -- Raise your shield, reflecting the first spell cast on you, and reduce magic damage you take by 25% for 5 sec.
    storm_bolt                      = { 90337, 107570, 1 }, -- Hurls your weapon at an enemy, causing 18,868 Physical damage and stunning for 4 sec.
    thunder_clap                    = { 90343, 6343  , 1 }, -- Blasts all enemies within 8 yards for 32,507 Physical damage and reduces their movement speed by 20% for 10 sec. Deals reduced damage beyond 5 targets. Generates 5 Rage. If you have Rend, Thunder Clap affects 5 nearby targets with Rend. 
    thunderous_roar                 = { 90359, 384318, 1 }, -- Roar explosively, dealing 114,403 Physical damage to enemies within 12 yds and cause them to bleed for 131,423 physical damage over 8 sec.
    thunderous_words                = { 90358, 384969, 1 }, -- Increases the duration of Thunderous Roar's Bleed effect by 2.0 sec and Thunderous Roar's Bleed effect causes enemies to take 30% increased damage from all your bleeds.
    unstoppable_force               = { 90364, 275336, 1 }, -- Avatar increases the damage of Thunder Clap and Shockwave by 50% and reduces the cooldown of Thunder Clap by 50%.
    uproar                          = { 90357, 391572, 1 }, -- Thunderous Roar's cooldown reduced by 45 sec.
    war_machine                     = { 90345, 316733, 1 }, -- Your auto attacks generate 50% more Rage. Killing an enemy instantly generates 5 Rage, and increases your movement speed by 30% for 8 sec.
    wild_strikes                    = { 90360, 382946, 2 }, -- Haste increased by 1% and your auto-attack critical strikes increase your auto-attack speed by 10% for 10 sec.
    wrecking_throw                  = { 90351, 384110, 1 }, -- Hurl your weapon at the enemy, causing 63,053 Physical damage, ignoring armor. Deals up to 500% increased damage to absorb shields.

    -- Protection
    anger_management                = { 90311, 152278, 1 }, -- Every 10 Rage you spend reduces the remaining cooldown on Avatar and Shield Wall by 1 sec.
    battering_ram                   = { 90262, 394312, 1 }, -- Shield Charge critical strike chance and critical strike damage increased by 20%, and Shield Charge increases your auto-attack damage and speed by 10% for 20 sec.
    battlescarred_veteran           = { 90435, 386394, 1 }, -- When your health is brought below 30%, you take 80% less damage for 8 sec and healing you receive is increased by 100%. Cannot occur more than once every 3 min.
    best_served_cold                = { 90304, 202560, 1 }, -- Revenge deals 10% more damage, or 20% more damage when your successful dodges or parries have made it cost no Rage.
    bloodborne                      = { 90448, 385704, 2 }, -- Deep Wounds, Rend and Thunderous Roar's Bleed effects deal 10% increased damage. 
    bloodsurge                      = { 90300, 384361, 1 }, -- Damage from your Bleed effects have a 10% chance to grant you 5 Rage.
    bolster                         = { 90264, 280001, 1 }, -- Last Stand's cooldown is reduced by 60 sec, and it grants you the Shield Block effect for its duration.
    booming_voice                   = { 90314, 202743, 1 }, -- Demoralizing Shout also generates 30 Rage, and increases damage you deal to affected targets by 20%.
    brace_for_impact                = { 90296, 386030, 1 }, -- Using Shield Slam increases the damage of Shield Slam by 5% for 16 sec, and it increases the block value of your shield by 3%. Stacking up to 5 times.
    brutal_vitality                 = { 90451, 384036, 1 }, -- 10% of damage you deal adds to your active Ignore Pain.
    challenging_shout               = { 90309, 1161  , 1 }, -- Taunts all enemies within 10 yds to attack you for 6 sec.
    champions_bulwark               = { 90316, 386328, 1 }, -- Shield Charge deals 20% increased damage, grants you Shield Block, makes your next Revenge cost no Rage, and generates an additional 20 Rage.
    dance_of_death                  = { 90260, 390713, 1 }, -- When an enemy dies while affected by your Ravager, its duration is extended by 2 sec. This effect can trigger a maximum of 3 times per use of Ravager.
    defenders_aegis                 = { 90310, 397103, 1 }, -- Shield Wall gains 1 additional charge, and its cooldown is reduced by 60 sec.
    demoralizing_shout              = { 90305, 1160  , 1 }, -- Demoralizes all enemies within 15 yards, reducing the damage they deal to you by 20% for 8 sec. Generates 30 Rage.
    devastator                      = { 90299, 236279, 1 }, -- Your auto attacks deal an additional 23,172 Physical damage and have a 20% chance to reset the remaining cooldown on Shield Slam.
    disrupting_shout                = { 90307, 386071, 1 }, -- Taunts all enemies within 14 yds to attack you for 6 sec, interrupts all spellcasting within 14 yds and prevents any spell in that school from being cast for 6 sec. 
    enduring_alacrity               = { 90433, 384063, 1 }, -- Increases Stamina and Armor by 8% and your Haste by 2%.
    enduring_defenses               = { 90313, 386027, 1 }, -- Shield Block lasts 2 sec longer.
    fight_through_the_flames        = { 90306, 452494, 1 }, -- Defensive Stance additionally reduces magic damage you take by 6%.
    focused_vigor                   = { 90318, 384067, 1 }, -- Increases Strength and Armor by 5% and your critical strike chance by 1%. 
    fueled_by_violence              = { 90451, 383103, 1 }, -- You are healed for 110% of the damage dealt by Deep Wounds.
    heavy_repercussions             = { 90319, 203177, 1 }, -- Shield Slam generates 2 more Rage and extends the duration of Shield Block by 1.0 sec.
    ignore_pain                     = { 90295, 190456, 1 }, -- Fight through the pain, ignoring 50% of damage taken, up to 1.8 million total damage prevented.
    impenetrable_wall               = { 90310, 384072, 1 }, -- Shield Slam generates an additional 4 Rage and reduces the remaining cooldown of Shield Wall by 6 sec.
    indomitable                     = { 90434, 202095, 1 }, -- Your maximum health is increased by 6%, and every 20 Rage you spend heals you for 1% of your maximum health.
    instigate                       = { 90301, 394311, 1 }, -- Devastate deals 20% increased damage and generates 2 Rage. Devastator deals 10% increased damage and generates 1 Rage.
    into_the_fray                   = { 90319, 202603, 1 }, -- You gain 2% Haste for each enemy or ally within 10 yards, up to 8% Haste.
    juggernaut                      = { 90449, 393967, 1 }, -- Execute increases Execute's damage dealt by 3% for 20 sec, stacking up to 15 times.
    last_stand                      = { 90297, 12975 , 1 }, -- Increases maximum health by 30% for 15 sec, and instantly heals you for that amount.
    massacre                        = { 90313, 281001, 1 }, -- Execute is now usable on targets below 35% health. 
    punish                          = { 90449, 275334, 1 }, -- Shield Slam deals 10% increased damage, and reduces enemies' damage against you by 2% for 9 sec. Multiple punishments may overlap.
    ravager                         = { 90432, 228920, 1 }, -- Throws a whirling weapon at the target location that chases nearby enemies, inflicting 327,423 Physical damage to all enemies over 10.4 sec. Deals reduced damage beyond 8 targets. Generates 10 Rage each time it deals damage.
    rend                            = { 90302, 394062, 1 }, -- Wounds the target, causing 25,927 Physical damage instantly and an additional 80,044 Bleed damage over 15 sec. Thunder Clap affects 5 nearby targets with Rend. 
    revenge                         = { 90298, 6572  , 1 }, -- Swing in a wide arc, dealing 37,983 Physical damage to all enemies in front of you. Deals reduced damage beyond 5 targets. Your successful dodges and parries have a chance to make your next Revenge cost no Rage.
    shield_charge                   = { 90317, 385952, 1 }, -- Charge to an enemy with your shield, dealing 222,120 Physical damage to it and 88,848 Physical damage to all enemies within 10 yards. Also stuns the primary target for 4 sec. Generates 20 Rage.
    shield_specialization           = { 90315, 386011, 2 }, -- Increases Block chance by 6% and your Block value by 12%.
    shield_wall                     = { 90312, 871   , 1 }, -- Reduces all damage you take by 40% for 8 sec.
    show_of_force                   = { 90320, 385843, 1 }, -- Revenge damage increased by 10% and Revenge increases the damage of your next Thunder Clap by 20%.
    spell_block                     = { 90450, 392966, 1 }, -- You are able to block spells for 30 sec.
    storm_of_steel                  = { 90260, 382953, 1 }, -- Ravager's damage is reduced by 30% but it now has 2 charges and generates 10 additional Rage each time it deals damage.
    strategist                      = { 90303, 384041, 1 }, -- Devastate, Thunder Clap, Revenge, and Execute have a 30% chance to reset the remaining cooldown on Shield Slam.
    sudden_death                    = { 90320, 29725 , 1 }, -- Your attacks have a chance to make your next Execute cost no Rage, be usable on any target regardless of their health, and deal damage as if you spent 40 Rage.
    thunderlord                     = { 90308, 385840, 1 }, -- Increases the radius of Demoralizing Shout by 5 yards. Each enemy hit by Thunder Clap reduces the remaining cooldown on Demoralizing Shout by 1.5 sec, up to 4.5 sec.
    tough_as_nails                  = { 90450, 385888, 1 }, -- Blocking an attack deals 18,915 Physical damage to the attacker, ignoring armor. Generates high threat.
    unnerving_focus                 = { 90452, 384042, 1 }, -- Last Stand increases your Rage generation by 50%.
    violent_outburst                = { 90265, 386477, 1 }, -- Consuming 30 rage grants a stack of Seeing Red, which transforms at 8 stacks into Violent Outburst, causing your next Shield Slam or Thunder Clap to deal 200% increased damage, generate 100% more Rage and grant Ignore Pain.

    -- Colossus
    arterial_bleed                  = { 94799, 440995, 1 }, -- Colossal Might increases the damage of your Rend and Deep Wounds by 2% per stack. 
    boneshaker                      = { 94789, 429639, 1 }, -- Shockwave's stun duration is increased by 1 sec and reduces the movement speed of affected enemies by 40% for 3 sec after the stun ends.
    colossal_might                  = { 94819, 429634, 1 }, -- Colossal Might increases damage dealt by your next Demolish by 10%, stacking up to 5 times. Shield Slam and Execute grant a stack of Colossal Might and Revenge grants a stack of Colossal Might when it strikes 3 or more targets.
    demolish                        = { 94818, 436358, 1, "colossus" }, -- Unleash a series of precise and powerful strikes against your target, dealing 515,611 damage to it, and 343,741 damage to enemies within 8 yds of it. Deals reduced damage beyond 8 targets. While channeling Demolish, you take 10% less damage and are immune to stuns, knockbacks, and forced movement effects. You can block, parry, dodge, and use certain defensive abilities while channeling Demolish.
    dominance_of_the_colossus       = { 94793, 429636, 1 }, -- Colossal Might now stacks up to 10 times. If you would gain a stack of Colossal Might and are at max stacks, the cooldown of Demolish is reduced by 2 sec. Enemies affected by Demolish take up to 10% more damage from you and deal up to 5% less damage to you for 10 sec based on the number of stacks of Colossal Might consumed by Demolish.
    earthquaker                     = { 94789, 440992, 1 }, -- Shockwave also knocks enemies into the air, and its cooldown is reduced by 5 sec.
    martial_expert                  = { 94812, 429638, 1 }, -- Critical strike damage of your abilities is increased by 10% and the amount of damage blocked by your critical blocks is increased by 20%.
    mountain_of_muscle_and_scars    = { 94806, 429642, 1 }, -- You deal 5% more damage and take 2.5% less damage. Size increased by 5%.
    no_stranger_to_pain             = { 94815, 429644, 1 }, -- Total damage prevented by Ignore Pain increased by 15%.
    one_against_many                = { 94799, 429637, 1 }, -- Shockwave, Revenge, and Whirlwind deal 5% more damage per target affected up to 5.
    practiced_strikes               = { 94796, 429647, 1 }, -- Shield Slam and Revenge damage increased by 20%.
    precise_might                   = { 94794, 431548, 1 }, -- Shield Slam critical strikes grant an additional stack of Colossal Might.
    tide_of_battle                  = { 94811, 429641, 1 }, -- Colossal Might increases the damage of your Revenge by 5% per stack.
    veteran_vitality                = { 94815, 440993, 1 }, -- When your health is brought below 35%, you gain a Second Wind, healing you for 12% of your max health over 2 sec. This effect cannot occur more than once every 60 sec.

    -- Mountain Thane
    avatar_of_the_storm             = { 94805, 437134, 1 }, -- Casting Avatar grants you 2 charges of Thunder Blast and resets the cooldown of Thunder Clap. While Avatar is not active, Lightning Strikes have a 10% chance to grant you Avatar for 4 secs. Thunder Blast Your next Thunder Clap becomes a Thunder Blast that deals Stormstrike damage.
    burst_of_power                  = { 94807, 437118, 1 }, -- Lightning Strikes have a 15% chance to make your next 2 Shield Slams have no cooldown.
    crashing_thunder                = { 94816, 436707, 1 }, -- Stormstrike or Nature damage your abilities deal is increased by 5%. Stormstrike damage ignores Armor. Thunder Clap damage increased by 40%. Seismic Reverberations now affects Thunder Clap in addition to Whirlwind.
    flashing_skies                  = { 94797, 437079, 1 }, -- Thunder Blast calls down a Lightning Strike on an enemy it hits.
    gathering_clouds                = { 94792, 436201, 1 }, -- Your attacks trigger Lightning Strikes 30% more often.
    ground_current                  = { 94800, 436148, 1 }, -- Lightning Strikes also deal 19,862 to enemies near their target. Damage reduced beyond 5 targets.
    keep_your_feet_on_the_ground    = { 94798, 438590, 1 }, -- Physical damage taken reduced by 2%. Thunder Blast reduces damage you take by 8% for 5 sec.
    lightning_strikes               = { 94803, 434969, 1, "mountain_thane" }, -- Damaging enemies with Thunder Clap, Revenge, or Execute has a 25% chance to also strike one with a lightning bolt, dealing 39,723 Nature damage. Lightning Strikes occur 30% more often during Avatar.
    snap_induction                  = { 94797, 456270, 1 }, -- Activating Demoralizing Shout grants a charge of Thunder Blast.
    steadfast_as_the_peaks          = { 94798, 434970, 1 }, -- Stamina increased by 5%. Victory Rush increases your maximum health by 10% for 5 sec. When this health increase expires, you heal for any amount of the original Victory Rush that healed you in excess of your full health.
    storm_bolts                     = { 94817, 436162, 1 }, -- Storm Bolt also hits 2 additional nearby targets, stunning them for 2 sec, but its cooldown is increased by 10 sec.
    storm_shield                    = { 94817, 438597, 1 }, -- Intervening a target grants them a shield for 5 sec that absorbs magic damage equal to 3 times your Armor.
    strength_of_the_mountain        = { 94808, 437068, 1 }, -- Shield Slam damage increased by 10%. Demoralizing Shout reduces damage enemies deal to you by an additional 5%
    thorims_might                   = { 94792, 436152, 1 }, -- Lightning Strikes generate 5 Rage. Revenge and Execute damage increased by 15%.
    thunder_blast                   = { 94785, 435607, 1 }, -- Shield Slam and Bloodthirst have a 35% chance to grant you Thunder Blast, stacking up to 2 charges. Thunder Blast Your next Thunder Clap becomes a Thunder Blast that deals 40% increased damage as Stormstrike and generates 10 Rage.
} )

-- PvP Talents
spec:RegisterPvpTalents( { 
    battlefield_commander = 5629, -- (424742) Your Shout abilities have additional effects.  Battle Shout: Increases Stamina by 3%.  Piercing Howl: Radius increased by 50%  Berserker Shout: Range increased by 8 yds.  Intimidating Shout: Cooldown reduced by 15 sec.  Rallying Cry: Removes movement impairing effects and grants 30% movement speed to allies.  Thunderous Roar: Targets receive 5% more damage from all sources while bleeding.
    bodyguard             = 168 , -- (213871) Protect an ally, causing 40% of all Physical damage they take to be transfered to you. When the target takes Physical damage, your Shield Slam cooldown has a 30% chance to be reset. Bodyguard is cancelled if the target is further than 20 yards from you. Lasts 1 min. Only one target can be Bodyguarded at a time.
    demolition            = 5374, -- (329033) Reduces the cooldown of your Shattering Throw or Wrecking Throw by 50% and increases its damage to absorb shields by an additional 250%.
    disarm                = 24  , -- (236077) Disarm the enemy's weapons and shield for 5 sec. Disarmed creatures deal significantly reduced damage.
    dragon_charge         = 831 , -- (206572) Run at high speed at a distance in front of you. All enemies in your path will take 46,344 Physical damage and be knocked back.
    morale_killer         = 171 , -- (199023) 
    oppressor             = 845 , -- (205800) 
    rebound               = 833 , -- (213915) Spell Reflection reflects the next 2 incoming spells cast on you and reflected spells deal 50% extra damage to the attacker. Spell Reflection's cooldown is increased by 10 sec.
    safeguard             = 5626, -- (424654) Intervene now has 2 charges and reduces the ally's damage taken by 20% for 5 sec. Intervene's cooldown is increased by 10 sec.
    shield_bash           = 173 , -- (198912) 
    storm_of_destruction  = 5627, -- (236308) Bladestorm and Ravager now snare all targets you hit by 60% for 6 sec and decrease their healing taken by 50 for 10 sec.
    thunderstruck         = 175 , -- (199045) 
    warbringer            = 5432, -- (356353) Charge roots enemies for 2 sec and emanates a shockwave past the target, rooting enemies and dealing 33,102 Physical damage in a 20 yd cone.
    warpath               = 178 , -- (199086) 
} )


-- Auras
spec:RegisterAuras( {
    avatar = {
        id = 401150,
        duration = 20,
        max_stack = 1,
        copy = 107574
    },
    battering_ram = {
        id = 394313,
        duration = 20,
        max_stack = 1,
    },
    battle_stance = {
        id = 386164,
        duration = 3600,
        max_stack = 1
    },
    battlescarred_veteran = {
        id = 386397,
        duration = 8,
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
    bodyguard = {
        id = 213871,
        duration = 60,
        tick_time = 1,
        max_stack = 1
    },
    bounding_stride = {
        id = 202164,
        duration = 3,
        max_stack = 1,
    },
    brace_for_impact = {
        id = 386029,
        duration = 16,
        max_stack = 5
    },
    burst_of_power = {
        id = 437121,
        duration = 12,
        max_stack = 2,
    },
    challenging_shout = {
        id = 1161,
        duration = 6,
        max_stack = 1
    },
    charge = {
        id = 105771,
        duration = 1,
        max_stack = 1,
    },
    colossal_might = {
        id = 440989,
        duration = 24,
        max_stack = function() return 5 + ( talent.dominance_of_the_colossus.enabled and 5 or 10 ) end
    },
    concussive_blows = {
        id = 383116,
        duration = 10,
        max_stack = 1
    },
    dance_of_death = {
        id = 393966,
        duration = 120,
        max_stack = 1,
    },
    deep_wounds = {
        id = 115767,
        duration = 15,
        tick_time = 3,
        max_stack = 1
    },
    defensive_stance = {
        id = 386208,
        duration = 3600,
        max_stack = 1
    },
    demoralizing_shout = {
        id = 1160,
        duration = 8,
        max_stack = 1
    },
    disarm = {
        id = 236077,
        duration = 6,
        max_stack = 1
    },
    disrupting_shout = {
        id = 386071,
        duration = 6,
        max_stack = 1
    },
    dragon_charge = {
        id = 206572,
        duration = 1.2,
        max_stack = 1
    },
    champions_spear = {
        id = 376080,
        duration = function() return 4 + ( talent.champions_might.enabled and 2 or 0 ) end,
        max_stack = 1
    },
    champions_might = {
        id = 386286,
        duration = 6,
        max_stack = 1
    },
    -- Target Swapping
    execute_ineligible = {
        duration = 3600,
        max_stack = 1,
        generate = function( t )
            if buff.sudden_death.down and target.health_pct > ( talent.massacre.enabled and 35 or 20 ) then
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
    },
    focused_assault = {
        id = 206891,
        duration = 6,
        max_stack = 5
    },
    hamstring = {
        id = 1715,
        duration = 15,
        max_stack = 1
    },
    ignore_pain = {
        id = 190456,
        duration = 12,
        max_stack = 1
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
    into_the_fray = {
        id = 202602,
        duration = 3600,
        max_stack = 5
    },
    juggernaut = {
        id = 393968,
        duration = 12,
        max_stack = 15,
        copy = 383290
    },
    keep_your_feet_on_the_ground = {
        id = 438591,
        duration = 5,
        max_stack = 1
    },
    last_stand = {
        id = 12975,
        duration = 15,
        max_stack = 1
    },
    piercing_howl = {
        id = 12323,
        duration = 8,
        max_stack = 1
    },
    punish = {
        id = 275335,
        duration = 9,
        max_stack = 5
    },
    rallying_cry = {
        id = 97463,
        duration = 10,
        max_stack = 1,
        shared = "player",
    },
    ravager = {
        id = 228920,
        duration = function () return ( buff.dance_of_death.up and 14 or 12 ) * haste end,
        tick_time = 2,
        max_stack = 1
    },
    rend = {
        id = 388539,
        duration = 15,
        tick_time = 3,
        max_stack = 1
    },
    revenge = {
        id = 5302,
        duration = 6,
        max_stack = 1
    },
    -- Damage taken reduced by $w1%.
    safeguard = {
        id = 424655,
        duration = 5.0,
        max_stack = 1,
    },
    seeing_red = {
        id = 386486,
        duration = 30,
        max_stack = 8
    },
    shield_bash = {
        id = 198912,
        duration = 8,
        max_stack = 1
    },
    shield_block = {
        id = 132404,
        duration = function () return ( talent.enduring_defenses.enabled and 8 or 6 ) + ( talent.heavy_repercussions.enabled and 1 or 0 )  end,
        max_stack = 1
    },
    shield_charge = {
        id = 385954,
        duration = 4,
        max_stack = 1,
    },
    shield_wall = {
        id = 871,
        duration = 8,
        max_stack = 1
    },
    shockwave = {
        id = 132168,
        duration = function() return 2 + ( talent.boneshaker.enabled and 1 or 0 ) end,
        max_stack = 1
    },
    show_of_force = {
        id = 385842,
        duration = 12,
        max_stack = 1
    },
    spell_block = {
        id = 392966,
        duration = 30,
        max_stack = 1
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
    sudden_death = {
        id = 52437,
        duration = 10,
        max_stack = 2
    },
    taunt = {
        id = 355,
        duration = 3,
        max_stack = 1
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
    unnerving_focus = {
        id = 384043,
        duration = 15,
        max_stack = 1
    },
    victorious = {
        id = 32216,
        duration = 20,
        max_stack = 1
    },
    violent_outburst = { -- Renamed from Outburst to violent Outburst in build 45779
        id = 386478,
        duration = 30,
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
    wrecked = {
        id = 447513,
        duration = 10,
        max_stack = 1
    }
} )


-- Dragonflight Season 1
spec:RegisterGear( "tier29", 200426, 200428, 200423, 200425, 200427 )
spec:RegisterSetBonuses( "tier29_2pc", 393710, "tier29_4pc", 393711 ) -- Dragonflight Season 1
-- 2-Set - Revenge grants you Vanguard's Determination, increasing your damage done and reducing damage you take by 4% for 5 sec seconds.
-- 4-Set - During Vanguard's Determination, gain Ignore Pain equal to 5% of damage you deal.
spec:RegisterAura( "vanguards_determination", {
    id = 394056,
    duration = 5,
    max_stack = 1,
} )

spec:RegisterGear( "tier30", 202446, 202444, 202443, 202442, 202441 )
spec:RegisterSetBonuses( "tier30_2pc", 405581, "tier30_4pc", 405582 )
--(2) Shield Slam deals 15% increased damage and reduces the cooldown of Last Stand by 1 sec. During Last Stand these effects are doubled.
--(4) For 10 sec after Last Stand ends, Shield Slam unleashes a wave of force dealing (45% of Attack power) Physical damage to enemies in front of you and reducing damage they deal to you by 5% for 5 sec.
spec:RegisterAura( "earthen_tenacity", {
    id = 410218,
    duration = 5,
    max_stack = 1
} )

spec:RegisterGear( "tier31", 207180, 207181, 207182, 207183, 207185, 217218, 217220, 217216, 217217, 217219 )
spec:RegisterSetBonuses( "tier31_2pc", 422927, "tier31_4pc", 422928 )
-- (2) Spending Rage has a chance to cause your next Shield Slam to consume your bleeds on a target, instantly dealing 40% of the remaining damage of your Deep Wounds and Rend and 100% of Thunderous Roar's, and reducing your damage taken by 10% for 5 sec.
-- (4) For each bleed effect consumed from a target, your damage taken is reduced by an additional 2%. When Shield Slam consumes a bleed, the cooldown of Thunder Clap is reset and the cooldown of Thunderous Roar is reduced by 3.0 sec.
spec:RegisterAuras( {
    fervid = {
        id = 425517,
        duration = 10,
        max_stack = 1
    },
    fervid_opposition = {
        id = 427413,
        duration = 5,
        max_stack = 1
    },
} )


local rageSpent_10 = 0
local rageSpent_20 = 0
local rageSpent_30 = 0

spec:RegisterStateExpr( "rageSpent_10", function () return rageSpent_10 end ) -- Glory (Shadowlands) and Anger Management talent
spec:RegisterStateExpr( "rageSpent_20", function () return rageSpent_20 end ) -- Indomitable talent
spec:RegisterStateExpr( "rageSpent_30", function () return rageSpent_30 end ) -- Outburst talent

local RAGE = Enum.PowerType.Rage
local lastRage = -1

spec:RegisterUnitEvent( "UNIT_POWER_FREQUENT", "player", nil, function( event, unit, powerType )
    if powerType == "RAGE" then
        local current = UnitPower( "player", RAGE )
        if current < lastRage - 3 then -- Spent Rage, -3 is used as a Hack to avoid Rage decaying
            if state.talent.anger_management.enabled or ( state.legendary.glory.enabled and FindPlayerAuraByID( 324143 ) ) then -- Glory and Anger Management
                rageSpent_10 = ( rageSpent_10 + lastRage - current ) % 10 
            end
            if state.talent.indomitable.enabled then -- Indomitable
                rageSpent_20 = ( rageSpent_20 + lastRage - current ) % 20
            end
            if state.talent.violent_outburst.enabled then -- Outburst T28 or Violent Outburst
                rageSpent_30 = ( rageSpent_30 + lastRage - current ) % 30
            end
        end
        lastRage = current
    end
end )

-- model rage expenditure and special effects
spec:RegisterHook( "spend", function( amt, resource )
    if resource == "rage" and amt < 0 then
        if talent.anger_management.enabled or ( legendary.glory.enabled and buff.conquerors_banner.up ) then
            rageSpent_10 = rageSpent_10 + amt
            local rage10activations = floor( rageSpent_10 / 10 )
            rageSpent_10 = rageSpent_10 % 10

            if rage10activations > 0 then
                if legendary.glory.enabled and buff.conquerors_banner.up then
                    buff.conquerors_banner.expires = buff.conquerors_banner.expires + ( rage10activations * 0.5 )
                end
                if talent.anger_management.enabled then
                    if talent.shield_wall.enabled then cooldown.shield_wall.expires = cooldown.shield_wall.expires - rage10activations end
                    if talent.avatar.enabled then cooldown.avatar.expires = cooldown.avatar.expires - rage10activations end
                end
            end
        end
        
        if talent.indomitable.enabled then
            rageSpent_20 = rageSpent_20 + amt
            local rage20activations = floor( rageSpent_20 / 20 )
            rageSpent_20 = rageSpent_20 % 20

            if rage20activations > 0 then
                gain( ( 0.01 * rage20activations ) * health.max, "health" ) -- Restores 1% max health
            end
        end

        if talent.violent_outburst.enabled then
            rageSpent_30 = rageSpent_30 + amt
            local rage30activations = floor( rageSpent_30 / 30 )
            rageSpent_30 = rageSpent_30 % 30

            if rage30activations > 0 then
                addStack( "seeing_red", nil, rage30activations )
                if buff.seeing_red.stack > 7 then
                    applyBuff( "violent_outburst" )
                    removeBuff( "seeing_red" )
                end
            end
        end
    end
end )

spec:RegisterCombatLogEvent( function(  _, subtype, _, sourceGUID, sourceName, sourceFlags, _, destGUID, destName, destFlags, _, spellID, spellName, school, amount, interrupt, a, b, c, d, critical )
    --TODO: Deepdive to see if beneficial or not.
    if sourceGUID == state.GUID then
        if state.talent.colossal_might.enabled and spellID == 440989 and ( subtype == "SPELL_AURA_APPLIED" or subtype == "SPELL_AURA_REMOVED" or subtype == "SPELL_AURA_REFRESH" or subtype == "SPELL_AURA_APPLIED_DOSE" or subtype == "SPELL_AURA_REMOVED_DOSE" ) then
            Hekili:ForceUpdate( "COLOSSALMIGHT_CHANGED", true )
        elseif state.talent.thunder_blast.enabled and spellID == 435615 and ( subtype == "SPELL_AURA_APPLIED" or subtype == "SPELL_AURA_REMOVED" or subtype == "SPELL_AURA_REFRESH" or subtype == "SPELL_AURA_APPLIED_DOSE" or subtype == "SPELL_AURA_REMOVED_DOSE" ) then
            Hekili:ForceUpdate( "THUNDERBLAST_CHANGED", true )
        elseif state.talent.burst_of_power.enabled and spellID == 437121 and ( subtype == "SPELL_AURA_APPLIED" or subtype == "SPELL_AURA_REMOVED" or subtype == "SPELL_AURA_REFRESH" or subtype == "SPELL_AURA_APPLIED_DOSE" or subtype == "SPELL_AURA_REMOVED_DOSE" ) then
            Hekili:ForceUpdate( "BURSTOFPOWER_CHANGED", true )
        end
    end
end )

spec:RegisterStateExpr( "cycle_for_execute", function ()
    if active_enemies == 1 or target.health_pct < ( talent.massacre.enabled and 35 or 20 ) or not settings.cycle or buff.execute_ineligible.down or buff.sudden_death.up then return false end
    return Hekili:GetNumTargetsBelowHealthPct( talent.massacre.enabled and 35 or 20, false, max( settings.cycle_min, offset + delay ) ) > 0
end )

local TriggerEarthenTenacity = setfenv( function()
    applyBuff( "earthen_tenacity" )
end, state )

spec:RegisterHook( "reset_precast", function ()
    if set_bonus.tier30_4pc > 0 and buff.last_stand.up then
        state:QueueAuraExpiration( "last_stand_earthen_tenacity", TriggerEarthenTenacity, buff.last_stand.expires )
    end
end )

spec:RegisterStateExpr( "last_stand_damage_taken", function ()
    return health.max * ( ( settings.last_stand_amount or 0 ) * 0.01 ) * ( solo and 0.5 or 1 )
end )
spec:RegisterStateExpr( "last_stand_health_pct", function ()
    return ( settings.last_stand_health or 100 )
end )
spec:RegisterStateExpr( "rallying_cry_damage_taken", function ()
    return health.max * ( ( settings.rallying_cry_amount or 0 ) * 0.01 ) * ( solo and 0.5 or 1 )
end )
spec:RegisterStateExpr( "rallying_cry_health_pct", function ()
    return ( settings.rallying_cry_health or 100 )
end )
spec:RegisterStateExpr( "shield_wall_damage_taken", function ()
    return health.max * ( ( settings.shield_wall_amount or 0 ) * 0.01 ) * ( solo and 0.5 or 1 )
end )
spec:RegisterStateExpr( "shield_wall_health_pct", function ()
    return ( settings.shield_wall_health or 100 )
end )

-- Abilities
spec:RegisterAbilities( {
    avatar = {
        id = 401150,
        cast = 0,
        cooldown = 90,
        gcd = "off",

        spend = function () return buff.unnerving_focus.up and -15 or -10 end,
        spendType = "rage",

        talent = "avatar",
        startsCombat = false,
        texture = 613534,

        toggle = "cooldowns",

        handler = function ()
            applyBuff( "avatar" )
            if talent.immovable_object.enabled then
                applyBuff( "shield_wall", 4 )
            end
            if talent.violent_outburst.enabled then
                applyBuff( "violent_outburst" )
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
        nobuff = function() return settings.stance_weaving and "battle_stance" or "stance" end,

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

        startsCombat = false,
        texture = 136009,

        --Not yet Implemented in LossOfControl via Classes.lua
        --toggle = "defensives",
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
            removeBuff( "dispellable_disease" )
            removeBuff( "dispellable_poison" )
            removeBuff( "dispellable_curse" )
            gain( 0.2 * health.max, "health" )
        end,
    },


    bodyguard = {
        id = 213871,
        cast = 0,
        cooldown = 15,
        gcd = "spell",

        pvptalent = "bodyguard",
        startsCombat = false,
        texture = 132359,

        handler = function ()
            applyBuff( "bodyguard" )
        end,
    },


    challenging_shout = {
        id = 1161,
        cast = 0,
        cooldown = 120,
        gcd = "off",

        talent = "challenging_shout",
        notalent = "disrupting_shout",
        startsCombat = true,
        texture = 132091,

        toggle = "cooldowns",

        handler = function ()
            applyDebuff( "target", "challenging_shout" )
            active_dot.challenging_shout = active_enemies
        end,
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
            if talent.champions_might.enabled or legendary.elysian_might.enabled then applyBuff( "champions_might" ) end
        end,

        copy = { "spear_of_bastion", 307865, 376079 }
    },

    charge = {
        id = 100,
        cast = 0,
        charges  = function () return talent.double_time.enabled and 2 or 1 end,
        cooldown = function () return talent.double_time.enabled and 17 or 20 end,
        recharge = function () return talent.double_time.enabled and 17 or 20 end,
        gcd = "off",
        icd = 1,

        spend = function () return -20 * ( buff.unnerving_focus.up and 1.5 or 1 ) end,
        spendType = "rage",

        startsCombat = true,
        texture = 132337,

        usable = function () return target.minR > 8 and ( query_time - action.charge.lastCast > gcd.execute ), "target too close" end,
        handler = function ()
            applyDebuff( "target", "charge" )
            if legendary.reprisal.enabled then
                applyBuff( "shield_block", 4 )
                applyBuff( "revenge" )
                gain( 20, "rage" )
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
        essential = true,
        nobuff = function() return settings.stance_weaving and "defensive_stance" or "stance" end,

        handler = function ()
            removeBuff( "battle_stance" )
            applyBuff( "defensive_stance" )
        end,
    },

    demolish = {
        id = 436358,
        cast = function () return 2 * haste end,
        channeled = true,
        breakable = false,
        cooldown = 45,
        gcd = "spell",

        startsCombat = true,

        handler = function()
            removeBuff( "colossal_might" )
            active_dot.wrecked = active_enemies
        end,
    },


    demoralizing_shout = {
        id = 1160,
        cast = 0,
        cooldown = 45,
        gcd = "spell",

        spend = function () return ( talent.booming_voice.enabled and -30 or 0 ) * ( buff.unnerving_focus.up and 1.5 or 1 ) end,
        spendType = "rage",

        talent = "demoralizing_shout",
        startsCombat = false,
        texture = 132366,

        handler = function ()
            applyDebuff( "target", "demoralizing_shout" )
            active_dot.demoralizing_shout = max( active_dot.demoralizing_shout, active_enemies )
        end,
    },


    devastate = {
        id = 20243,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = function() return ( talent.instigate.enabled and -2 or 0 ) * ( buff.unnerving_focus.up and 1.5 or 1) end,
        spendType = "rage",

        startsCombat = true,
        notalent = "devastator",

        handler = function ()
            applyDebuff( "target", "deep_wounds" )
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


    disrupting_shout = {
        id = 386071,
        cast = 0,
        cooldown = 90,
        gcd = "off",

        talent = "disrupting_shout",
        startsCombat = false,
        texture = 132091,

        toggle = "cooldowns",

        handler = function ()
            applyDebuff( "target", "disrupting_shout" )
            active_dot.disrupting_shout = active_enemies
        end,
    },


    dragon_charge = {
        id = 206572,
        cast = 0,
        cooldown = 20,
        gcd = "off",

        pvptalent = "dragon_charge",
        startsCombat = false,
        texture = 1380676,

        handler = function ()
        end,
    },


    execute = {
        id = function () return talent.massacre.enabled and 281000 or 163201 end,
        known = 163201,
        copy = { 163201, 281000 },
        noOverride = 317485, -- Condemn
        cast = 0,
        cooldown = 0,
        gcd = "spell",
        hasteCD = true,

        spend = 0,
        spendType = "rage",

        startsCombat = true,
        texture = 135358,

        usable = function ()
            if buff.sudden_death.up then return true end
            if cycle_for_execute then return true end
            return target.health_pct < ( talent.massacre.enabled and 35 or 20 ), "requires < " .. ( talent.massacre.enabled and 35 or 20 ) .. "% health"
        end,

        cycle = "execute_ineligible",

        indicator = function () if cycle_for_execute then return "cycle" end end,

        timeToReady = function()
            if buff.sudden_death.up then return 0 end
            local threshold = settings.reserve_rage + 40
            if rage.current >= threshold or ( buff.shield_block.remains > 3 and buff.ignore_pain.remains > 3 ) or not tanking then return 0 end
            return rage[ "time_to_" .. ( settings.reserve_rage + 40 ) ]
        end,

        handler = function()
            if not buff.sudden_death.up then
                local cost = min( rage.current, 40 )
                spend( cost, "rage", nil, true )
            else
                removeBuff( "sudden_death" )
            end
            if talent.juggernaut.enabled then addStack( "juggernaut" ) end

            if talent.dominance_of_the_colossus.enabled and buff.colossal_might.stack == 10 then reduceCooldown( "demolish", 2 ) end
            if talent.colossal_might.enabled then addStack( "colossal_might" ) end
        end,
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
            applyDebuff( "target", "hamstring" )
        end,
    },


    heroic_leap = {
        id = 6544,
        cast = 0,
        cooldown = function () return talent.bounding_stride.enabled and 30 or 45 end,
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
        cooldown = 1,
        gcd = "spell",

        startsCombat = true,

        usable = function () return target.minR > 7, "requires 8 yard range or more" end,
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

        toggle = "defensives",

        readyTime = function ()
            if settings.overlap_ignore_pain then return end
            if buff.ignore_pain.up and buff.ignore_pain.v1 >= 0.3 * health.max then
                return buff.ignore_pain.remains - gcd.max
            end
        end,

        handler = function ()
            if buff.ignore_pain.up then
                buff.ignore_pain.expires = query_time + class.auras.ignore_pain.duration
                buff.ignore_pain.v1 = min( 0.3 * health.max, buff.ignore_pain.v1 + stat.attack_power * 4.375 * ( 1 + stat.versatility_atk_mod / 100 ) )
            else
                applyBuff( "ignore_pain" )
                buff.ignore_pain.v1 = min( 0.3 * health.max, stat.attack_power * 4.375 * ( 1 + stat.versatility_atk_mod / 100 ) )
            end
        end,
    },


    impending_victory = {
        id = 202168,
        cast = 0,
        cooldown = 25,
        gcd = "spell",

        spend = function() return buff.victorious.up and 0 or 10 end,
        spendType = "rage",

        talent = "impending_victory",
        startsCombat = true,

        handler = function ()
            removeBuff( "victorious" )
            gain( health.max * 0.2, "health" )
            if conduit.indelible_victory.enabled then applyBuff( "indelible_victory" ) end
            if talent.steadfast_as_the_peaks.enabled then
                gain( health.max * 0.1, "health" )
                applyBuff( "steadfast_as_the_peaks" )
            end
        end,
    },


    intervene = {
        id = 3411,
        cast = 0,
        cooldown = function ()
            if pvptalent.safeguard.enabled then return 40 - ( talent.honed_reflexes.enabled and 40*0.05 or 0 ) end
            return 30 - ( talent.honed_reflexes.enabled and 30*0.05 or 0 )
        end,
        charges = function () if pvptalent.safeguard.enabled then return 2 end end,
        recharge = function () if pvptalent.safeguard.enabled then return 40 - ( talent.honed_reflexes.enabled and 40*0.05 or 0 ) end end,
        gcd = "off",
        icd = 1.5,

        talent = "intervene",
        startsCombat = false,

        handler = function ()
            if legendary.reprisal.enabled then
                applyBuff( "shield_block", 4 )
                applyBuff( "revenge" )
                gain( 20, "rage" )
            end

            if pvptalent.safeguard.enabled then
                applyBuff( "safeguard" )
            end
        end,
    },


    intimidating_shout = {
        id = function() return talent.menace.enabled and 316593 or 5246 end,
        cast = 0,
        cooldown = 90,
        gcd = "spell",

        talent = "intimidating_shout",
        startsCombat = true,
        texture = 132154,

        toggle = "interrupts",

        handler = function ()
            applyDebuff( "target", "intimidating_shout" )
            active_dot.intimidating_shout = max( active_dot.intimidating_shout, active_enemies )
        end,

        copy = { 316593, 5246 },
    },


    last_stand = {
        id = 12975,
        cast = 0,
        cooldown = function() return 180 - ( talent.bolster.enabled and 60 or 0 ) end,
        gcd = "off",

        talent = "last_stand",
        startsCombat = false,
        texture = 135871,

        toggle = function()
            if settings.last_stand_offensively and ( talent.unnerving_focus.enabled or conduit.unnerving_focus.enabled or set_bonus.tier30_2pc > 0 ) then
                return "cooldowns"
            end
            return "defensives"
        end,

        handler = function ()
            applyBuff( "last_stand" )

            if talent.bolster.enabled then
                applyBuff( "shield_block", buff.last_stand.duration )
            end

            if talent.unnerving_focus.enabled then
                applyBuff( "unnerving_focus" )
            end

            if set_bonus.tier30_4pc > 0 then
                state:QueueAuraExpiration( "last_stand_earthen_tenacity", TriggerEarthenTenacity, buff.last_stand.expires )
            end
        end,
    },


    oppressor = {
        id = 205800,
        cast = 0,
        cooldown = 20,
        gcd = "spell",

        pvptalent = "oppressor",
        startsCombat = false,
        texture = 136080,

        handler = function ()
            applyDebuff( "target", "focused_assault" )
        end
    },


    piercing_howl = {
        id = 12323,
        cast = 0,
        cooldown = 30,
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
        cooldown = function () return 15 - ( talent.concussive_blows.enabled and 1 or 0 ) - ( talent.honed_reflexes.enabled and 15*0.05 or 0 )  end,
        gcd = "off",

        startsCombat = true,
        texture = 132938,

        toggle = "interrupts",
        interrupt = true,

        debuff = "casting",
        readyTime = state.timeToInterrupt,

        handler = function ()
            interrupt()
            if talent.concussive_blows.enabled then applyDebuff( "target", "concussive_blows" ) end
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

        toggle = "defensives",

        handler = function ()
            applyBuff( "rallying_cry" )
            gain( 0.10 * health.max, "health" )
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
        toggle = "cooldowns",

        handler = function ()
            applyBuff( "ravager" )
        end,
    },


    rend = {
        id = 394062,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = 20,
        spendType = "rage",

        talent = "rend",
        startsCombat = true,
        texture = 132155,

        handler = function ()
            applyDebuff( "target", "rend" )
        end,
    },


    revenge = {
        id = 6572,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = function ()
            if buff.revenge.up then return 0 end
            return talent.barbaric_training.enabled and 30 or 20
        end,
        spendType = "rage",

        talent = "revenge",
        startsCombat = true,
        texture = 132353,

        readyTime = function()
            if buff.revenge.up then return 0 end
            local threshold = action.revenge.cost + ( settings.reserve_rage or 40 )
            if rage.current >= threshold or ( buff.shield_block.remains > 3 and buff.ignore_pain.remains > 3 ) or not tanking then return 0 end
            return rage[ "time_to_" .. threshold ]
        end,

        handler = function ()
            if set_bonus.tier29_2pc > 0 then applyBuff( "vanguards_determination" ) end
            if buff.revenge.up then removeBuff( "revenge" ) end
            if talent.show_of_force.enabled then applyBuff( "show_of_force" ) end
            applyDebuff( "target", "deep_wounds" )

            if talent.demolish.enabled and active_enemies > 2 then
                if talent.dominance_of_the_colossus.enabled and buff.colossal_might.stack == 10 then reduceCooldown( "demolish", 2 ) end
                if talent.colossal_might.enabled then addStack( "colossal_might" ) end
             end
        end,
    },


    shattering_throw = {
        id = 64382,
        cast = 1.5,
        cooldown = 180,
        gcd = "spell",

        talent = "shattering_throw",
        startsCombat = true,
        toggle = "cooldowns",

        handler = function ()
            removeDebuff( "target", "all_absorbs" )
        end,
    },


    shield_bash = {
        id = 198912,
        cast = 0,
        cooldown = 10,
        gcd = "spell",
        spend = -3,
        spendType = "rage",

        pvptalent = "shield_bash",
        startsCombat = false,
        texture = 132357,

        handler = function ()
            applyDebuff( "target", "shield_bash" )
        end,
    },


    shield_block = {
        id = 2565,
        cast = 0,
        charges = 2,
        cooldown = 16,
        recharge = 16,
        hasteCD = true,
        gcd = "off",

        toggle = "defensives",
        equipped = "shield",
        defensive = true,

        spend = 30,
        spendType = "rage",

        startsCombat = false,
        texture = 132110,

        nobuff = function()
            if not settings.stack_shield_block then return "shield_block" end
        end,

        handler = function ()
            applyBuff( "shield_block" )
        end,
    },


    shield_charge = {
        id = 385952,
        cast = 0,
        cooldown = 45,
        gcd = "spell",

        spend = -20,
        spendType = "rage",

        talent = "shield_charge",
        equipped = "shield",
        startsCombat = true,

        handler = function ()
            if talent.battering_ram.enabled then
                applyBuff( "battering_ram" )
            end
            if talent.champions_bulwark.enabled then
                applyBuff( "shield_block" )
                applyBuff( "revenge" )
                gain( 20, "rage" )
            end
        end,
    },


    shield_slam = {
        id = 23922,
        cast = 0,
        cooldown = function () return 9 - ( talent.honed_reflexes.enabled and 1 or 0 ) end,
        hasteCD = true,
        gcd = "spell",

        spend = function ()
            local reduction = 0
            -- The Wall Legendary overtakes the new Impenetrable Wall talent, they do not stack in 10.0
            if legendary.the_wall.enabled then reduction = reduction - 5
            elseif talent.impenetrable_wall.enabled then reduction = reduction - 4
            end

            return
            ( -15 + reduction + ( talent.heavy_repercussions.enabled and -2 or 0 ) )
            * ( buff.violent_outburst.up and 1.5 or 1 ) -- Build 45969
            * ( buff.unnerving_focus.up and 1.5 or 1 )
        end,
        spendType = "rage",

        equipped = "shield",
        startsCombat = true,
        texture = 134951,

        readyTime = function()
            if buff.burst_of_power.up then return 0 end
        end,

        handler = function ()
            if buff.violent_outburst.up then
                applyBuff( "ignore_pain" )
                removeBuff( "violent_outburst" )
            end

            if talent.brace_for_impact.enabled then applyBuff( "brace_for_impact" ) end

            if talent.heavy_repercussions.enabled and buff.shield_block.up then
                buff.shield_block.expires = buff.shield_block.expires + 1
            end

            if talent.punish.enabled then applyDebuff( "target", "punish" ) end

            if ( legendary.the_wall.enabled or talent.impenetrable_wall.enabled ) and cooldown.shield_wall.remains > 0 then
                reduceCooldown( "shield_wall", 6 )
            end

            if set_bonus.tier30_2pc > 0 then
                reduceCooldown( "last_stand", buff.last_stand.up and 4 or 2 )
            end

            if buff.fervid.up then
                removeDebuff( "target", "deep_wounds" )
                removeDebuff( "target", "rend" )
                removeDebuff( "target", "thunderous_roar" )
                if set_bonus.tier31_4pc > 0 then applyBuff( "fervid_opposition" ) end
            end

            if talent.dominance_of_the_colossus.enabled and buff.colossal_might.stack == 10 then reduceCooldown( "demolish", 2 ) end
            if talent.colossal_might then addStack( "colossal_might" ) end
        end,
    },


    shield_wall = {
        id = 871,
        cast = 0,
        charges = function () return 1 + ( talent.defenders_aegis.enabled and 1 or 0 ) + ( legendary.unbreakable_will.enabled and 1 or 0 ) end,
        cooldown = function() return 210 - ( talent.honed_reflexes.enabled and 210*0.05 or 0 ) - ( conduit.stalwart_guardian.enabled and 20 or 0 ) - ( talent.defenders_aegis.enabled and 60 or 0 ) end,
        recharge = function() return 210 - ( talent.honed_reflexes.enabled and 210*0.05 or 0 ) - ( conduit.stalwart_guardian.enabled and 20 or 0 ) - ( talent.defenders_aegis.enabled and 60 or 0 ) end,
        gcd = "off",

        talent = "shield_wall",
        startsCombat = false,
        texture = 132362,

        toggle = "defensives",

        handler = function ()
            applyBuff( "shield_wall" )
            if talent.immovable_object.enabled then applyBuff( "avatar", 4 ) end
        end,
    },


    shockwave = {
        id = 46968,
        cast = 0,
        cooldown = function () return
            ( ( ( talent.rumbling_earth.enabled and active_enemies >= 3 ) and 25 or 40 )
            - ( conduit.disturb_the_peace.enabled and 5 or 0 )
            - ( talent.earthquaker.enabled and 5 or 0 )
            ) end,
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

        spend = 20,
        spendType = "rage",

        startsCombat = true,
        texture = 132340,

        handler = function ()
        end,
    },


    spell_block = {
        id = 392966,
        cast = 0,
        cooldown = 90,
        gcd = "off",

        talent = "spell_block",
        startsCombat = false,

        toggle = "defensives",

        handler = function ()
            applyBuff( "spell_block" )
        end,
    },

    spell_reflection = {
        id = 23920,
        cast = 0,
        cooldown = function() return 25 - ( talent.honed_reflexes.enabled and 25 * 0.05 or 0 ) end,
        gcd = "off",

        talent = "spell_reflection",

        toggle = "defensives",
        debuff = "casting",

        handler = function()
            applyBuff( "spell_reflection" )
            applyBuff( "spell_reflection_defense" )
        end,
    },

    storm_bolt = {
        id = 107570,
        cast = 0,
        cooldown = function() return 30 - ( talent.honed_reflexes.enabled and 30 * 0.05 or 0 ) + ( talent.storm_bolts.enabled and 10 or 0 ) end,
        gcd = "spell",

        talent = "storm_bolt",
        startsCombat = true,

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
        cooldown = function () return haste * ( ( buff.avatar.up and talent.unstoppable_force.enabled ) and 3 or 6 ) end,
        gcd = "spell",
        hasteCD = true,

        spend = function () return -5
            * ( buff.violent_outburst.up and 2 or 1 )
            * ( buff.unnerving_focus.up and 1.5 or 1 ) end,
        spendType = "rage",

        talent = "thunder_clap",
        startsCombat = true,
        texture = 136105,
        bind = "thunder_blast",

        handler = function ()
            applyDebuff( "target", "thunder_clap" )
            active_dot.thunder_clap = max( active_dot.thunder_clap, active_enemies )
            removeBuff( "show_of_force" )

            if ( talent.thunderlord.enabled or legendary.thunderlord.enabled ) and cooldown.demoralizing_shout.remains > 0 then
                reduceCooldown( "demoralizing_shout", min( 3, active_enemies ) )
            end

            if talent.rend.enabled then
                applyDebuff( "target", "rend" )
                active_dot.rend = min( active_enemies, 5 )
            end

            if buff.violent_outburst.up then
                applyBuff( "ignore_pain" )
                removeBuff( "violent_outburst" )
            end
        end,
    },

    thunder_blast = {
        id = 435222,
        flash = 6343,
        cast = 0,
        cooldown = function () return haste * ( ( buff.avatar.up and talent.unstoppable_force.enabled ) and 3 or 6 ) end,
        gcd = "spell",
        hasteCD = true,

        spend = function () return -15
            * ( buff.violent_outburst.up and 2 or 1 )
            * ( buff.unnerving_focus.up and 1.5 or 1 ) end,
        spendType = "rage",

        talent = "thunder_clap",
        startsCombat = true,
        texture = 136105,
        bind = "thunder_clap",

        handler = function ()
            applyDebuff( "target", "thunder_clap" )
            active_dot.thunder_clap = max( active_dot.thunder_clap, active_enemies )
            removeBuff( "show_of_force" )

            if ( talent.thunderlord.enabled or legendary.thunderlord.enabled ) and cooldown.demoralizing_shout.remains > 0 then
                reduceCooldown( "demoralizing_shout", min( 3, active_enemies ) )
            end

            if talent.rend.enabled then
                applyDebuff( "target", "rend" )
                active_dot.rend = min( active_enemies, 5 )
            end

            if buff.violent_outburst.up then
                applyBuff( "ignore_pain" )
                removeBuff( "violent_outburst" )
            end
        end,
        copy = { 6343 }
    },


    thunderous_roar = {
        id = 384318,
        cast = 0,
        cooldown = function() return talent.uproar.enabled and 90 or 45 end,
        gcd = "spell",

        spend = -10,
        spendType = "rage",

        talent = "thunderous_roar",
        startsCombat = true,

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
        buff = "victorious",

        handler = function ()
            removeBuff( "victorious" )
            gain( health.max * 0.2, "health" )
            if conduit.indelible_victory.enabled then applyBuff( "indelible_victory" ) end
        end,
    },

    whirlwind = {
        id = 1680,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = 20,
        spendType = "rage",

        startsCombat = false,
        texture = 132369,

        handler = function ()
        end,
    },

    wrecking_throw = {
        id = 384110,
        cast = 0,
        cooldown = 45,
        gcd = "spell",

        talent = "wrecking_throw",
        startsCombat = true,

        handler = function ()
        end,
    },
} )

spec:RegisterSetting( "shockwave_interrupt", true, {
    name = "Only |T236312:0|t Shockwave as Interrupt",
    desc = "If checked, |T236312:0|t Shockwave will only be recommended when your target is casting (and talented).",
    type = "toggle",
    width = "full"
} )

spec:RegisterSetting( "overlap_ignore_pain", false, {
    name = "Overlap |T1377132:0|t Ignore Pain",
    desc = "If checked, |T1377132:0|t Ignore Pain can be recommended while it is already active even if its remaining absorb is greater than 30% of your maximum health.  This setting may cause you to spend more Rage on mitigation.",
    type = "toggle",
    width = "full"
} )

spec:RegisterSetting( "stack_shield_block", false, {
    name = "Overlap |T132110:0|t Shield Block",
    desc = function()
        return "If checked, the addon can recommend overlapping |T132110:0|t Shield Block usage. \n\n" ..
        "This setting avoids leaving Shield Block at 2 charges, which wastes cooldown recovery time."
    end,
    type = "toggle",
    width = "full"
} )

spec:RegisterSetting( "stance_weaving", false, {
    name = "Allow Stance Changes",
    desc = function()
        return "If checked, custom priorities can be written to recommend changing between stances.  For example, Battle Stance could be recommended when "
            .. "using offensive cooldowns, then Defensive Stance can be recommended when tanking resumes.\n\n"
            .. "If left unchecked, the addon will not recommend changing your stance as long as you are already in a stance.  This choice prevents the addon "
            .. "from endlessly recommending that you change your stance when you do not want to change it."
    end,
    type = "toggle",
    width = "full"
} )

spec:RegisterSetting( "reserve_rage", 35, { -- Ignore Pain cost is 35, Shield Block is 30.
    name = "|T135726:0|t Reserve Rage for Mitigation",
    desc = "If set above 0, the addon will not recommend |T132353:0|t Revenge or |T135358:0|t Execute unless you'll be still have this much Rage afterward.\n\n"
        .. "When set to |cFFFFD10035|r or higher, this feature ensures that you can always use |T1377132:0|t Ignore Pain and |T132110:0|t Shield Block when following recommendations for damage and threat.",
    type = "range",
    min = 0,
    max = 100,
    step = 1,
    width = "full",
} )

spec:RegisterSetting( "shield_wall_amount", 50, {
    name = "|T132362:0|t Shield Wall Damage Required",
    desc = "If set above 0, the priority can recommend |T132362:0|t Shield Wall if you have taken this much damage in the past 5 seconds, as a percentage of your maximum health.\n\n"
        .. "If set to |cFFFFD10050%|r and your maximum health is 50,000, then Shield Wall can be recommended when you've taken 25,000 damage in the past 5 seconds.\n\n"
        .. "This value is reduced by 50% when playing solo.",
    type = "range",
    min = 0,
    max = 200,
    step = 1,
    width = "full",
} )

spec:RegisterSetting( "shield_wall_health", 50, {
    name = "|T132362:0|t Shield Wall Health Percentage",
    desc = "If set below 100, the priority can recommend |T132362:0|t Shield Wall if your current health has fallen below this percentage.",
    type = "range",
    min = 0,
    max = 100,
    step = 1,
    width = "full",
} )

spec:RegisterSetting( "rallying_cry_amount", 50, {
    name = "|T132351:0|t Rallying Cry Damage Required",
    desc = "If set above 0, the priority can recommend |T132351:0|t Rallying Cry if you have taken this much damage in the past 5 seconds, as a percentage of your maximum health.\n\n"
        .. "If set to |cFFFFD10050%|r and your maximum health is 50,000, then Rallying Cry can be recommended when you've taken 25,000 damage in the past 5 seconds.\n\n"
        .. "This value is reduced by 50% when playing solo.",
    type = "range",
    min = 0,
    max = 200,
    step = 1,
    width = "full",
} )

spec:RegisterSetting( "rallying_cry_health", 50, {
    name = "|T132351:0|t Rallying Cry Health Percentage",
    desc = "If set below 100, the priority can recommend |T132351:0|t Rallying Cry if your current health has fallen below this percentage.",
    type = "range",
    min = 0,
    max = 100,
    step = 1,
    width = "full",
} )

spec:RegisterSetting( "last_stand_offensively", false, {
    name = "Use |T135871:0|t Last Stand Offensively",
    desc = function()
        return "If checked, the addon will recommend |T135871:0|t Last Stand as an offensive cooldown instead of a defensive cooldown.\n\n"
            .. "Requires " .. ( state.set_bonus.tier30_2pc > 0 and "|cFF00FF00" or "|cFFFF0000" ) .. "2-piece Tier 30|r or "
            .. "|W|T571316:0|t " .. ( ( state.talent.unnerving_focus.enabled or state.conduit.unnerving_focus.enabled ) and "|cFF00FF00" or "|cFFFF0000" ) .. " Unnerving Focus|r|w"
    end,
    type = "toggle",
    width = "full"
} )

spec:RegisterSetting( "last_stand_amount", 50, {
    name = "|T135871:0|t Last Stand Damage Required",
    desc = "If set above 0, the priority can recommend |T135871:0|t Last Stand if you have taken this much damage in the past 5 seconds, as a percentage of your maximum health.\n\n"
        .. "If set to |cFFFFD10050%|r and your maximum health is 50,000, then Last Stand can be recommended when you've taken 25,000 damage in the past 5 seconds.\n\n"
        .. "This value is reduced by 50% when playing solo.",
    type = "range",
    min = 0,
    max = 200,
    step = 1,
    width = "full",
    disabled = function() return state.settings.last_stand_offensively end,
} )

spec:RegisterSetting( "last_stand_health", 50, {
    name = "|T135871:0|t Last Stand Health Percentage",
    desc = "If set below 100, the priority can recommend |T135871:0|t Last Stand if your current health has fallen below this percentage.",
    type = "range",
    min = 0,
    max = 100,
    step = 1,
    width = "full",
    disabled = function() return state.settings.last_stand_offensively end,
} )


local LSR = LibStub( "SpellRange-1.0" )

spec:RegisterRanges( "hamstring", "devastate", "execute", "storm_bolt", "charge", "heroic_throw", "taunt" )

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
    damageExpiration = 8,

    potion = "potion_of_spectral_strength",

    package = "Protection Warrior",
} )


spec:RegisterPack( "Protection Warrior", 20240908, [[Hekili:nR1sVnoos4FlZfJySPDKFf7mioh2500hASaUb2BsMwI2wtKefOOs2SWq)23IuusKYK0ps6DxGgPtKkw1xvSErQYFS)p9xhHyy)FmXBYmVN8EAK3YztNoZFn7JCS)6Cu4RO9WVKHsHF(pOegoKftYQ28pruAmHYP5JeckIZRcsjneO7aJLx87p8W(y2HYTJcjPpueNwMG4lnKI2X4)D4d(R3wgNW(Zm)TMbYuGN54q)FSa(TdXrr4AsXfH(R5K(nVLFB887R249038E63R2Soo9pQ2KZHwm7JQnL5C(wu99QVxt)IVnzgq3ppGf6a8daKXzGEqj7Ita0JeAyXOCkgq(we7VT6b4NSeCqbdLfIVNr2VpbVcmdF3fXhiLmUGL0aVjVmnfNO(KWdi6E89X7wXItXR8oEmL8gofNXgffxlUxwQUGYcCqmdNwO(q0BigIY5Y2YD7gbw9SimnyBcQa4d59SJhn8cG9HV(8QjQCQ4qmojk4DusIauOeouItbuH2ckfz7FbEaJWz8)kAGGR1sxihvwTnHqIc2vs)q7PyAbM(AC2EnfGgIYWbmcLcYt9njX7pWkc(RYO9P9E1UykwienobwScgfLeec6GMKr7di7cy04Wx1SE5e(V1A9KQtzU0O1(3dy89k2Odyuc7WO8qgy88u5u8(mcfhKJIZQTE9O)fG(b3rHqQrr4DXHXahgpFqiHKWTEJKw)Ieu6ikgf9XXJ6epZ7eIR9GQjFGC)cEwAohtbBltEhrFTzdRp)M4MF9jFQc5r4ucyMJ)3WwzTVUog2siP8x9gjoeFjYxANnR3Z)KcU2tL72lcIJQ3of0xMLHPVXxXosyzHnOo1cu)8CEI3fSn35tulW3IjCzeaQ)2sken3jwWF7TpcO4CmfKAHi)uJzOnGohNHHWeEmnpy3g2M7Y70osUABYVcSpEHlSFEbEc)wEb8Zk6gE8OiY)Lvl8KzwkWyUHGIJQZfVAXGAkMoFOnrLc5wkaSuBILVdYcg(AZlFz1SbfywWwsgyFzXy60XbtYdVNx6GSBxW(WOvJ1YX2UrXZADNH0wp5DwFAJjhpZQgYxMmOnPGHPDSRNg4X1adpDwEOQMqHiZ9yQ6JonDHsHnJ5k6vFwMjfAebPXyTIPCEcuKKeuBhk0R1cj(hyRcSEbyoCtIlo0wokKKqkkG6zP8kH1lb8qmGeszraLOdsTK6gEHWZPvwMCNaFnTAC0YSG6)kaWj7EERHRqe89f8kRSvJTBkctq59GoVi9PSBpecbmtP5PrGemzZJi8S)qgMo0ABnCPFLlPvmwt0zurR1ZjdoP9bzSqbJKNlsqSJqn43zb43ciMDTGOTfckc8gGqdj76ImVby841II(Mck(nCwDFYn5qB4rboUinomGtcf6UuCiJwTrhts2O6dkfGss2gH88Qh9UfTfkFFoJOt)nxUbN1Umv2lXl8EiAsYHOW)ateuvkodGthm64NmKZKZ)D2ZCvVVkSj8ERZjVdkP8CfJV2n9HMqtVnM7SkqhzybSyFJCyTb7zfxQMCWNUD1Hl8)chwY08iBlWBV9nrchBIPzNBU7LpSP7Hs(5HdIWiOEBN5v7XouafoFrEbNM2CIL()0oiObwApr8TYXoxvhfEaFaN7k)MvpKlrz(VNKvI5L(Bl9o9OPVmPj5LKERhGDqT7V9UBfG8cygiYUMCnIPPZVa2ah1A(xhM4TslJmsrqFuHudfzojS2HD)t7hU6CUdxL3W14h(1k5i8BG2YV1U1qLx(jNKxF3YXZ9x)oIYl1u4V(ptZjugyU3mRAtnBQ2W71Ryu139xl(n(Thcv0G)7hIBLuUd5)39xhsJHdgeJ8x3pFr1MNxvTzCZn25VwBBWNbW5ZZlUHJZQPwzLnJw1MbvBS2Lq1MxaborqKEDsXJoxTshk9SFjiD2TIuvIS2p0MJhLm)wGx1MhVv0zFdFUvZip3uTrzHNQqC2jQbLOjHIGvt7qI85Cq84zab3P9rVpN5752D3ZSl1HqLChCuUqe(A0Fub8aHlnrOWGRt3txGTFQuT7EYmTDdRD9AYqdavMyZDkO7KMzdnzwTrpE2upQYSm3QZA1MH3uYU7CcjDyBuZKO2Tx2q19JNpj6OF3Uw9MSNPvpWJlS7mS)7QcNla13DA(LWUHkwLEnKRLAWqt5DgazthTjVnzy0dqSNCYCHnLnyJnx7WTYEkOVkr1KXDHlhy7T1ikai9op7E)V50d2Hzy5)hcUgdN90LAXhlBIh71JSaJtuRI01rTTvi2PR5xxa)4LxqeZviejSgAiw3PUmD(vjgo05l5xTUWLXq1Sc9pqIXwag7PMsOjvHE6GXJvPPzX9OXz9bNEWRUCx4RY)Tn4AS9C()VcBnXwJ1YiRCMhvJlJ)MDOYewB7dnRO(t(3BVW(wbFkaeLKLHJNmnacpPLD8V(M9BRB2842XeONKpZHd0R(lU2LoNCRTgmPtU1n04Uev7xkZ8qfCs3r6vnK7U8pTwB5PM31nYb9uBTou7gbbxTNQpscMAqTHYEJOq)4oT432zwWzeS(qmymqUvzuNQH(uEMdTQ09z7MC)osTK5xXbxm9eDHkkIRHeLXIq3p40SKDLvKP7B(8RYSYZDLvgf9rxtC6l0sVHQd7GAMzRdqHn(p5s4V5LoT3sTnFdQ4Z83T8cXM60ly1En)ldunrZAJdG66S8XHVu7LU68vlTjExPlLQVOZIoDqYXmiOsM1rlWgcNF(OLZHWB0w(Rx3gV4s0Tlbew4VZ()6XFhO3uZRlu71U)qGiQ(xRCkx2rBRJU7YP31luy475REDEMgtK6EhKZjcVzgEMD7fZVZC3UGiEY7ICv4gc3hW4CCyydtKzH0MKK63zAAsS8MzCtqBP9wpFHzqRzd5SM0VMR9tX6knPAlM9Z0kyRwVj9MkL(qW(5bDmIkNCH0wVJlhnYpXZDhhMgMLtU)ZMlMrWqT(IKYRzqx63vTwJrAvG7t5zAmYCCJi4Y7ejiOsWv7nxFUJWWh0zX4ZWd468W0h1M6Vvsq9SyZ)AjCz2pYS1fP3G1OT4M76uCYL2rxU9Sl1Z3S)AsMAFMktaTPJZ0NqHNBVtjbpavYoWhB81Tde(FWhiCXl9)p]] )