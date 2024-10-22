-- WarriorArms.lua
-- August 2024
-- 11.0.2


if UnitClassBase( "player" ) ~= "WARRIOR" then return end

local addon, ns = ...
local Hekili = _G[ addon ]
local class, state = Hekili.Class, Hekili.State

local FindPlayerAuraByID = ns.FindPlayerAuraByID

local strformat = string.format

local spec = Hekili:NewSpecialization( 71 )

local base_rage_gen, arms_rage_mult = 1.59, 4.000

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

    ravager = {
        aura = "ravager",

        last = function ()
            local app = state.buff.ravager.applied
            local t = state.query_time

            return app + floor( ( t - app ) / state.haste ) * state.haste
        end,

        interval = function () return state.haste end,
        value = 10,
    },
} )

-- Talents
spec:RegisterTalents( {
    -- Warrior
    armored_to_the_teeth            = { 90366, 384124, 2 }, -- Gain Strength equal to 5% of your Armor.
    avatar                          = { 90365, 107574, 1 }, -- Transform into a colossus for 20 sec, causing you to deal 20% increased damage and removing all roots and snares. Generates 10 Rage.
    barbaric_training               = { 90340, 383082, 1 }, -- Slam, Cleave, and Whirlwind deal 10% more damage and 10% increased critical strike damage. 
    battle_stance                   = { 90327, 386164, 1 }, -- A balanced combat state that increases the critical strike chance of your abilities by 3% and reduces the duration of movement impairing effects by 10%. Lasts until canceled.
    berserker_shout                 = { 90348, 384100, 1 }, -- Go berserk, removing and granting immunity to Fear, Sap, and Incapacitate effects for 6 sec. Also remove fear effects from group members within 12 yds.
    bitter_immunity                 = { 90356, 383762, 1 }, -- Restores 20% health instantly and removes all diseases, poisons and curses affecting you. 
    blademasters_torment            = { 90363, 390138, 1 }, -- Activating Avatar grants 8 sec of Sweeping Strikes and while Avatar is active the cooldown of Cleave is reduced by 1.5 sec.
    bounding_stride                 = { 90355, 202163, 1 }, -- Reduces the cooldown of Heroic Leap by 15 sec, and Heroic Leap now also increases your movement speed by 70% for 3 sec.
    cacophonous_roar                = { 90383, 382954, 1 }, -- Intimidating Shout can withstand 200% more damage before breaking.
    champions_might                 = { 90323, 386284, 1 }, -- The duration of Champion's Spear is increased by 2 sec. You deal 25% increased critical strike damage to targets chained to your Spear.
    champions_spear                 = { 90380, 376079, 1 }, -- Throw a spear at the target location, dealing 131,541 Physical damage instantly and an additional 132,135 damage over 4 sec. Deals reduced damage beyond 5 targets. Enemies hit are chained to the spear's location for the duration. Generates 10 Rage.
    concussive_blows                = { 90354, 383115, 1 }, -- Cooldown of Pummel reduced by 1.0 sec. Successfully interrupting an enemy increases the damage you deal to them by 5% for 10 sec.
    crackling_thunder               = { 95959, 203201, 1 }, -- Thunder Clap's radius is increased by 50%, and it reduces movement speed by an additional 20%.
    cruel_strikes                   = { 90381, 392777, 2 }, -- Critical strike chance increased by 1% and critical strike damage of Execute increased by 5%. 
    crushing_force                  = { 90347, 382764, 2 }, -- Mortal Strike deals an additional 5% damage and deals 5% increased critical strike damage.
    defensive_stance                = { 92537, 386208, 1 }, -- A defensive combat state that reduces all damage you take by 15%, and all damage you deal by 10%. Lasts until canceled.
    double_time                     = { 90382, 103827, 1 }, -- Increases the maximum number of charges on Charge by 1, and reduces its cooldown by 3 sec.
    endurance_training              = { 90338, 382940, 2 }, -- Stamina increased by 5% and the duration of Fear, Sap and Incapacitate effects on you is reduced by 10.0%.
    fast_footwork                   = { 90344, 382260, 1 }, -- Movement speed increased by 5%.
    frothing_berserker              = { 90352, 392792, 1 }, -- Mortal Strike and Cleave have a 20% chance to immediately refund 10% of the Rage spent.
    heroic_leap                     = { 90346, 6544  , 1 }, -- Leap through the air toward a target location, slamming down with destructive force to deal 18,735 Physical damage to all enemies within 8 yards.
    honed_reflexes                  = { 95956, 391271, 1 }, -- Cooldown of Die By the Sword, Pummel, Intervene, Spell Reflection, and Storm Bolt reduced by 5%.
    impending_victory               = { 90326, 202168, 1 }, -- Instantly attack the target, causing 47,036 damage and healing you for 30% of your maximum health. Killing an enemy that yields experience or honor resets the cooldown of Impending Victory and makes it cost no Rage.
    intervene                       = { 90329, 3411  , 1 }, -- Run at high speed toward an ally, intercepting all melee and ranged attacks against them for 6 sec while they remain within 10 yds.
    intimidating_shout              = { 90384, 5246  , 1 }, -- Causes the targeted enemy to cower in fear, and up to 5 additional enemies within 8 yards to flee. Targets are disoriented for 8 sec.
    leeching_strikes                = { 90371, 382258, 1 }, -- Leech increased by 3%.
    menace                          = { 90383, 275338, 1 }, -- Intimidating Shout will knock back all nearby enemies except your primary target, and cause them all to cower in fear for 15 sec instead of fleeing.
    overwhelming_rage               = { 90378, 382767, 2 }, -- Maximum Rage increased by 15.
    pain_and_gain                   = { 90353, 382549, 1 }, -- When you take any damage, heal for 2% of your maximum health. This can only occur once every 10 sec.
    piercing_challenge              = { 90379, 382948, 1 }, -- Champion's Spear's damage increased by 50% and its Rage generation is increased by 100%.
    piercing_howl                   = { 90348, 12323 , 1 }, -- Snares all enemies within 12 yards, reducing their movement speed by 70% for 8 sec.
    rallying_cry                    = { 90331, 97462 , 1 }, -- Lets loose a rallying cry, granting all party or raid members within 40 yards 10% temporary and maximum health for 10 sec.
    reinforced_plates               = { 90368, 382939, 1 }, -- Armor increased by 10%.
    rumbling_earth                  = { 90374, 275339, 1 }, -- Shockwave's range increased by 6 yards and when Shockwave strikes at least 3 targets, its cooldown is reduced by 15 sec.
    second_wind                     = { 90332, 29838 , 1 }, -- Restores 6% health every 1 sec when you have not taken damage for 5 sec. While you are below 35% health, restores 1.0% health every 1 sec. The amount restored increases the closer you are to death.
    seismic_reverberation           = { 90354, 382956, 1 }, -- If Whirlwind or Cleave hits 3 or more enemies, it hits them 1 additional time for 30% damage.
    shattering_throw                = { 90351, 64382 , 1 }, -- Hurl your weapon at the enemy, causing 58,404 Physical damage, ignoring armor, and removing any magical immunities. Deals up to 500% increased damage to absorb shields.
    shockwave                       = { 90375, 46968 , 1 }, -- Sends a wave of force in a frontal cone, causing 15,944 damage and stunning all enemies within 10 yards for 2 sec.
    sidearm                         = { 90340, 384404, 1 }, -- Your auto-attacks have a 20% chance to hurl weapons at your target and 3 other enemies in front of you, dealing an additional 19,930 Physical damage.
    spell_reflection                = { 90385, 23920 , 1 }, -- Raise your weapon, reflecting the first spell cast on you, and reduce magic damage you take by 20% for 5 sec.
    storm_bolt                      = { 90337, 107570, 1 }, -- Hurls your weapon at an enemy, causing 22,720 Physical damage and stunning for 4 sec.
    thunder_clap                    = { 90343, 6343  , 1 }, -- Blasts all enemies within 8 yards for 56,758 Physical damage and reduces their movement speed by 20% for 10 sec. Deals reduced damage beyond 5 targets. If you have Rend, Thunder Clap affects 5 nearby targets with Rend. 
    thunderous_roar                 = { 90359, 384318, 1 }, -- Roar explosively, dealing 137,759 Physical damage to enemies within 12 yds and cause them to bleed for 304,441 physical damage over 16 sec.
    thunderous_words                = { 90358, 384969, 1 }, -- Increases the duration of Thunderous Roar's Bleed effect by 2.0 sec and Thunderous Roar's Bleed effect causes enemies to take 30% increased damage from all your bleeds.
    twohanded_weapon_specialization = { 90322, 382896, 1 }, -- Increases your damage while using two-handed weapons by 5%. 
    uproar                          = { 90357, 391572, 1 }, -- Thunderous Roar's cooldown reduced by 45 sec.
    war_machine                     = { 90328, 262231, 1 }, -- Your auto attacks generate 10% more Rage. Killing an enemy instantly generates 5 Rage, and increases your movement speed by 30% for 8 sec.
    warlords_torment                = { 90363, 390140, 1 }, -- Activating Avatar grants 6 sec of Recklessness. The additional Rage generation of this Recklessness is reduced to 25%.
    wild_strikes                    = { 90360, 382946, 2 }, -- Haste increased by 1% and your auto-attack critical strikes increase your auto-attack speed by 10% for 10 sec.
    wrecking_throw                  = { 90351, 384110, 1 }, -- Hurl your weapon at the enemy, causing 58,404 Physical damage, ignoring armor. Deals up to 500% increased damage to absorb shields.

    -- Arms
    anger_management                = { 90289, 152278, 1 }, -- Every 20 Rage you spend on attacks reduces the remaining cooldown on Colossus Smash, Bladestorm, and Ravager by 1 sec.
    battlelord                      = { 92615, 386630, 1 }, -- Overpower has a 35% chance to reset the cooldown of Mortal Strike and generate 10 Rage.
    bladestorm                      = { 90441, 227847, 1 }, -- Become an unstoppable storm of destructive force, striking all nearby enemies for 597,770 Physical damage over 5.4 sec. Deals reduced damage beyond 8 targets. You are immune to movement impairing and loss of control effects, but can use defensive abilities and can avoid attacks. 
    bloodborne                      = { 90283, 383287, 2 }, -- Deep Wounds, Rend and Thunderous Roar's Bleed effects deal 7.50% increased damage.
    bloodletting                    = { 90438, 383154, 1 }, -- Deep Wounds, Rend and Thunderous Roar's Bleed effects last 6.0 sec longer and have a 5% increased critical strike chance. If you have Rend, Mortal Strike inflicts Rend on targets below 35% health. 
    bloodsurge                      = { 90277, 384361, 1 }, -- Damage from your Bleed effects have a 10% chance to grant you 5 Rage.
    blunt_instruments               = { 90287, 383442, 1 }, -- Colossus Smash damage increased by 30% and its effect duration is increased by 3.0 sec.
    cleave                          = { 90293, 845   , 1 }, -- Strikes all enemies in front of you for 87,965 Physical damage, inflicting Deep Wounds. Cleave will consume your Overpower effect to deal increased damage. Deals reduced damage beyond 5 targets.
    collateral_damage               = { 92536, 334779, 1 }, -- When Sweeping Strikes ends, your next Cleave or Whirlwind deals 25% increased damage for each ability used during Sweeping Strikes that damaged a second target.
    colossus_smash                  = { 90290, 167105, 1 }, -- Smashes the enemy's armor, dealing 221,962 Physical damage, and increasing damage you deal to them by 30% for 13 sec.
    critical_thinking               = { 90444, 389306, 2 }, -- Critical Strike chance increased by 1% and Execute immediately refunds 10% of the Rage spent.
    dance_of_death                  = { 92535, 390713, 1 }, -- When an enemy dies while affected by your Bladestorm, all damage you deal is increased by 5% for the remainder of the Bladestorm and for 2 sec afterwards. When an enemy dies while affected by your Ravager, its duration is extended by 2 sec. These effects can trigger a maximum of 3 times per use of Bladestorm or Ravager.
    deft_experience                 = { 90437, 389308, 2 }, -- Mastery increased by 1% and Tactician's chance to trigger is increased by an additional 0.5%.
    die_by_the_sword                = { 90276, 118038, 1 }, -- Increases your parry chance by 100% and reduces all damage you take by 30% for 8 sec.
    dreadnaught                     = { 90285, 262150, 1 }, -- Overpower causes a seismic wave, dealing 22,959 damage to all enemies in a 10 yd line. Deals reduced damage beyond 5 targets.
    executioners_precision          = { 90445, 386634, 1 }, -- Execute causes the target to take 35% more damage from your next Mortal Strike, stacking up to 2 times.
    exhilarating_blows              = { 90286, 383219, 1 }, -- Mortal Strike and Cleave have a 20% chance to instantly reset their own cooldowns.
    fatality                        = { 90439, 383703, 1 }, -- Your Mortal Strikes and Cleaves against enemies above 30% health have a high chance to apply Fatal Mark. When an enemy falls below 30% health, Your next Execute inflicts an additional 161,196 Physical damage per stack.
    fervor_of_battle                = { 90272, 202316, 1 }, -- If Cleave or Whirlwind hit 2 or more targets you also Slam your primary target.
    finishing_blows                 = { 92614, 400205, 1 }, -- Overpower generates 8 Rage when used on enemies below 35% health. 
    fueled_by_violence              = { 90275, 383103, 1 }, -- You are healed for 85% of the damage dealt by Deep Wounds.
    ignore_pain                     = { 90269, 190456, 1 }, -- Fight through the pain, ignoring 50% of damage taken, up to 1.1 million total damage prevented.
    impale                          = { 90292, 383430, 1 }, -- Critical strike damage of your abilities is increased by 10%.
    improved_execute                = { 90273, 316405, 1 }, -- Execute no longer has a cooldown and if your foe survives, 10% of the Rage spent is refunded.
    improved_overpower              = { 90279, 385571, 1 }, -- Overpower has 2 charges and deals 15% more damage.
    improved_sweeping_strikes       = { 92536, 383155, 1 }, -- Sweeping Strikes lasts 6 sec longer.
    in_for_the_kill                 = { 90288, 248621, 1 }, -- Colossus Smash increases your Haste by 10%, or by 20% if the target is below 35% health. Lasts for the duration of Colossus Smash.
    juggernaut                      = { 90446, 383292, 1 }, -- Execute increases Execute's damage dealt by 3% for 12 sec, stacking up to 15 times.
    martial_prowess                 = { 90278, 316440, 1 }, -- Overpower increases the damage of your next Mortal Strike or Cleave by 30%, stacking up to 2 times.
    massacre                        = { 90291, 281001, 1 }, -- Execute is now usable on targets below 35% health. 
    merciless_bonegrinder           = { 90266, 383317, 1 }, -- Whirlwind and Cleave deal 50% increased damage during Ravager or for 9 sec after Bladestorm ends.
    mortal_strike                   = { 90270, 12294 , 1 }, -- A vicious strike that deals 219,914 Physical damage and reduces the effectiveness of healing on the target by 50% for 10 sec.
    overpower                       = { 90271, 7384  , 1 }, -- Overpower the enemy, dealing 154,225 Physical damage. Cannot be blocked, dodged, or parried. Increases the damage of your next Mortal Strike by 30%, stacking up to 2 times. 
    ravager                         = { 90441, 228920, 1 }, -- Throws a whirling weapon at the target location that chases nearby enemies, inflicting 394,267 Physical damage to all enemies over 10.9 sec. Deals reduced damage beyond 8 targets. Generates 10 Rage each time it deals damage.
    rend                            = { 90284, 772   , 1 }, -- Wounds the target, causing 69,453 Physical damage instantly and an additional 164,262 Bleed damage over 21 sec.
    sharpened_blades                = { 90447, 383341, 1 }, -- Your Mortal Strike, Cleave and Execute critical strike damage is increased by 10% and your Execute has a 5% increased critical hit chance.
    skullsplitter                   = { 90281, 260643, 1 }, -- Bash an enemy's skull, dealing 112,886 Physical damage. Skullsplitter causes your Rend and Deep Wounds on the target to bleed out 100% faster for 10 sec. Generates 15 Rage.
    spiteful_serenity               = { 90289, 400314, 1 }, -- Colossus Smash and Avatar's durations are increased by 100% but their damage bonuses are reduced by 40%.
    storm_of_swords                 = { 90267, 385512, 1 }, -- Cleave and Whirlwind have a 30% chance to make your next Cleave or Whirlwind cost 100% less Rage.
    storm_wall                      = { 90269, 388807, 1 }, -- Whenever you Parry, you heal for 5.00% of your maximum health. Can only occur once per second.
    strength_of_arms                = { 90285, 400803, 1 }, -- Overpower deals 15% additional damage, has 10% increased critical strike chance, and deals 10% increased critical strike damage. 
    sudden_death                    = { 90274, 29725 , 1 }, -- Your attacks have a chance to make your next Execute cost no Rage, be usable on any target regardless of their health, and deal damage as if you spent 40 Rage.
    tactician                       = { 90282, 184783, 1 }, -- You have a 2.00% chance per Rage spent on attacks to reset the remaining cooldown on Overpower.
    test_of_might                   = { 90288, 385008, 1 }, -- When Colossus Smash expires, your Strength is increased by 1% for every 10 Rage you spent on attacks during Colossus Smash. Lasts 12 sec.
    unhinged                        = { 90440, 386628, 1 }, -- Every other time Bladestorm or Ravager deal damage, you automatically cast a Mortal Strike at your target or random nearby enemy. 
    valor_in_victory                = { 90442, 383338, 1 }, -- Increases Versatility by 2% and reduces the cooldown of Die by the Sword by 30.0 sec.
    warbreaker                      = { 90287, 262161, 1 }, -- Smash the ground and shatter the armor of all enemies within 8 yds, dealing 221,962 Physical damage and increasing damage you deal to them by 30% for 13 sec.

    -- Colossus
    arterial_bleed                  = { 94799, 440995, 1 }, -- Colossal Might increases the damage of your Rend and Deep Wounds by 2% per stack. 
    boneshaker                      = { 94789, 429639, 1 }, -- Shockwave's stun duration is increased by 1 sec and reduces the movement speed of affected enemies by 40% for 3 sec after the stun ends.
    colossal_might                  = { 94819, 429634, 1 }, -- Colossal Might increases damage dealt by your next Demolish by 10%, stacking up to 5 times. Mortal Strike and Execute grant a stack of Colossal Might and Cleave grants a stack of Colossal Might when it strikes 3 or more targets.
    demolish                        = { 94818, 436358, 1, "colossus" }, -- Unleash a series of precise and powerful strikes against your target, dealing 620,874 damage to it, and 413,916 damage to enemies within 8 yds of it. Deals reduced damage beyond 8 targets. While channeling Demolish, you take 10% less damage and are immune to stuns, knockbacks, and forced movement effects. You can block, parry, dodge, and use certain defensive abilities while channeling Demolish.
    dominance_of_the_colossus       = { 94793, 429636, 1 }, -- Colossal Might now stacks up to 10 times. If you would gain a stack of Colossal Might and are at max stacks, the cooldown of Demolish is reduced by 2 sec. Enemies affected by Demolish take up to 10% more damage from you and deal up to 5% less damage to you for 10 sec based on the number of stacks of Colossal Might consumed by Demolish.
    earthquaker                     = { 94789, 440992, 1 }, -- Shockwave also knocks enemies into the air, and its cooldown is reduced by 5 sec.
    martial_expert                  = { 94812, 429638, 1 }, -- Critical strike damage of your abilities is increased by 10% and the amount of damage blocked by your critical blocks is increased by 20%.
    mountain_of_muscle_and_scars    = { 94806, 429642, 1 }, -- You deal 5% more damage and take 2.5% less damage. Size increased by 5%.
    no_stranger_to_pain             = { 94815, 429644, 1 }, -- Total damage prevented by Ignore Pain increased by 15%.
    one_against_many                = { 94799, 429637, 1 }, -- Shockwave, Cleave, and Whirlwind deal 5% more damage per target affected up to 5.
    practiced_strikes               = { 94796, 429647, 1 }, -- Mortal Strike and Cleave damage increased by 20%.
    precise_might                   = { 94794, 431548, 1 }, -- Mortal Strike critical strikes grant an additional stack of Colossal Might.
    tide_of_battle                  = { 94811, 429641, 1 }, -- Colossal Might increases the damage of your Overpower by 5% per stack.
    veteran_vitality                = { 94815, 440993, 1 }, -- When your health is brought below 35%, you gain a Second Wind, healing you for 12% of your max health over 2 sec. This effect cannot occur more than once every 60 sec.

    -- Slayer
    brutal_finish                   = { 94786, 446085, 1 }, -- Your next Mortal Strike after Bladestorm ends deals 50% additional damage.
    culling_cyclone                 = { 94786, 444778, 1 }, -- Each strike of Bladestorm deals an additional 20% damage evenly split across all targets.
    death_drive                     = { 94813, 444770, 1 }, -- You heal for 15% of damage dealt by Sudden Death.
    fierce_followthrough            = { 94787, 444773, 1 }, -- Mortal Strike critical strikes increase the damage of your next Mortal Strike by 15%. 
    imminent_demise                 = { 94788, 444769, 1 }, -- Every 3 Slayer's Strikes you gain Sudden Death. Using Sudden Death accelerates your next Bladestorm, striking 1 additional time (max 3). Bladestorm's total duration is unchanged.
    opportunist                     = { 94787, 444774, 1 }, -- When Overpower has its cooldown reset by Tactician, your next Overpower deals 15% additional damage and 15% additional critical damage.
    overwhelming_blades             = { 94810, 444772, 1 }, -- Each strike of Bladestorm applies Overwhelmed to all enemies affected, increasing damage you deal to them by 1% for 20 sec, max 10 stacks.
    reap_the_storm                  = { 94809, 444775, 1 }, -- Mortal Strike and Cleave have a 20% chance to cause you to unleash a flurry of steel, striking all nearby enemies for 125,562 damage and applying Overwhelmed. Deals reduced damage beyond 8 targets. 
    relentless_pursuit              = { 94795, 444776, 1 }, -- Charge grants you 70% movement speed for 3 sec. Charge removes all movement impairing effects, this effect cannot occur more than once every 30 sec. 
    show_no_mercy                   = { 94784, 444771, 1 }, -- Marked for Execution increases the critical strike chance and critical strike damage of your next Execute on the target by 10%.
    slayers_dominance               = { 94814, 444767, 1, "slayer" }, -- Your attacks against your primary target have a high chance to overwhelm your their defenses and trigger a Slayer's Strike, dealing 58,404 damage and applying Marked for Execution, increasing the damage they take from your next Execute by 10%. Stacks 3 times.
    slayers_malice                  = { 94801, 444779, 1 }, -- Overpower damage increased by 20%.
    unrelenting_onslaught           = { 94820, 444780, 1 }, -- When you Execute a target that you've Marked for Execution, you both reduce the cooldown of Bladestorm by 5 sec and apply 2 stacks of Overwhelmed to the target per stack of Marked for Execution consumed. You can now use Pummel and Storm Bolt while Bladestorming.
    vicious_agility                 = { 94795, 444777, 1 }, -- Heroic Leap reduces the cooldown of Charge by 5 sec and Charge reduces the cooldown of Heroic Leap by 2 sec.
} )


-- PvP Talents
spec:RegisterPvpTalents( { 
    battlefield_commander  = 5630, -- (424742) 
    demolition             = 5372, -- (329033) 
    disarm                 = 3534, -- (236077) Disarm the enemy's weapons and shield for 5 sec. Disarmed creatures deal significantly reduced damage.
    duel                   = 34  , -- (236273) You challenge the target to a duel. While challenged, all damage you and the target deal to all targets other than each other is reduced by 50%. Lasts 12 sec.
    master_and_commander   = 28  , -- (235941) 
    rebound                = 5547, -- (213915) 
    safeguard              = 5625, -- (424654) 
    shadow_of_the_colossus = 29  , -- (198807) 
    sharpen_blade          = 33  , -- (198817) When activated, your next Mortal Strike will deal 15% increased damage and reduce healing taken by 50% for 4 sec.
    storm_of_destruction   = 31  , -- (236308) 
    war_banner             = 32  , -- (236320) You throw down a war banner at your feet, rallying your allies. Increases movement speed by 30% and reduces the duration of all incoming crowd control effects by 50% to all allies within 30 yards of the war banner. Lasts 15 sec.
    warbringer             = 5376, -- (356353) 
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
    brutal_finish = {
        id = 446918,
        duration = 10,
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
    colossal_might = {
        id = 440989,
        duration = 24,
        max_stack = function() return 5 + ( talent.dominance_of_the_colossus.enabled and 5 or 10 ) end
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
    imminent_demise = {
        id = 445606,
        duration = 60,
        max_stack = 3
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
        duration = function () return ( 10 + ( talent.blunt_instruments.enabled and 3 or 0 ) ) * ( talent.spiteful_serenity.enabled and 2 or 1 ) end, -- 100% buff from spiteful_serenity
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
    juggernaut = {
        id = 383290,
        duration = 12,
        max_stack = 15
    },
    marked_for_execution = {
        id = 445584,
        duration = 30,
        max_stack = 3
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
    opportunist = {
        id = 456120,
        duration = 8,
        max_stack = 1
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
    ravager = {
        id = 228920,
        duration = 12,
        tick_time = 2,
        max_stack = 1
    },
    recklessness = {
        id = 1719,
        duration = 12,
        max_stack = 1,
        copy = "recklessness_warlords_torment"
    },
    rend = {
        id = 388539,
        duration = function() return 15 + ( talent.bloodletting.enabled and 6 or 0 ) end,
        tick_time = function() return debuff.skullsplitter.up and 1.5 or 3 end,
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
    storm_of_swords = {
        id = 439601,
        duration = 8,
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
        max_stack = 2
    },
    taunt = {
        id = 355,
        duration = 3,
        max_stack = 1
    },
    test_of_might = {
        id = 385013,
        duration = 12,
        max_stack = 1,
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

local marked_for_execution_stacks = {}
local marked_for_execution_virtual = {}

spec:RegisterCombatLogEvent( function( _, subtype, _,  sourceGUID, sourceName, _, _, destGUID, destName, destFlags, _, spellID, spellName, _, _, _, _, critical_swing, _, _, critical_spell )
    if sourceGUID == state.GUID then
        if subtype == "SPELL_CAST_SUCCESS" then
            if ( spellName == class.abilities.colossus_smash.name or spellName == class.abilities.warbreaker.name ) then
                last_cs_target = destGUID
            end
        elseif subtype == "SPELL_DAMAGE" and UnitGUID( "target" ) == destGUID then
            if spellID == 445579 then -- Slayer's Strike occurred
                marked_for_execution_stacks[ destGUID ] = min( ( marked_for_execution_stacks[ destGUID ] or 0 ) + 1, 3 )
            end
        end
    end
end )

local wipe = table.wipe

spec:RegisterEvent( "PLAYER_REGEN_ENABLED", function()
    wipe( marked_for_execution_stacks )
end )

spec:RegisterHook( "UNIT_ELIMINATED", function( id )
    marked_for_execution_stacks[ id ] = nil
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

    if talent.collateral_damage.enabled and buff.sweeping_strikes.up then
        state:QueueAuraExpiration( "sweeping_strikes_collateral_dmg", TriggerCollateralDamage, buff.sweeping_strikes.expires )
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


spec:RegisterGear( "tier29", 200426, 200428, 200423, 200425, 200427, 217218, 217220, 217216, 217217, 217219 )
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

spec:RegisterAuras( {
    lethal_blows = {
        id = 455485,
        duration = 12,
        max_stack = 1
    }
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
            if talent.blademasters_torment.enabled then applyBuff ( "sweeping_strikes", 8 ) end
            if talent.warlords_torment.enabled then
                if buff.recklessness.up then buff.recklessness.expires = buff.recklessness.expires + 6
                else applyBuff( "recklessness", 6 ) end
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
            gain( 0.2 * health.max, "health" )
        end,
    },


    -- ID: 227847
    -- 227847 w/ MB

    bladestorm = {
        id = function() return talent.unrelenting_onslaught.enabled and 446035 or 227847 end,
        cast = 0,
        cooldown = 90,
        gcd = "spell",

        talent = "bladestorm",
        startsCombat = true,
        texture = 236303,
        range = 8,

        toggle = "cooldowns",

        handler = function ()
            applyBuff( "bladestorm" )
            setCooldown( "global_cooldown", class.auras.bladestorm.duration )
            if talent.blademasters_torment.enabled then applyBuff( "avatar", 4 ) end
            if talent.merciless_bonegrinder.enabled then
                state:QueueAuraExpiration( "bladestorm_merciless_bonegrinder", ExpireBladestorm, buff.bladestorm.expires )
            end
            -- the final tick brutal finish gets applied before the final Bladestorm tick goes off.
            -- If using imminent demise, it will affect the final MS instead of the one that
            -- comes after the bladestorm, which means we dont need to track it.
            if talent.brutal_finish.enabled and not talent.imminent_demise.enabled then
                applyBuff( "brutal_finish" )
            end
            removeBuff( "imminent_demise" )
        end,

        copy = { 227847, 389774, 446035 }
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
        cooldown = function () return 4.5 - ( ( buff.avatar.up and talent.blademasters_torment.enabled ) and 1.5 or 0 ) end,
        gcd = "spell",

        spend = function() return buff.storm_of_swords.up and 0 or 20 end,
        spendType = "rage",

        talent = "cleave",
        startsCombat = false,
        texture = 132338,

        handler = function ()
            applyDebuff( "target" , "deep_wounds" )
            active_dot.deep_wounds = max( active_dot.deep_wounds, active_enemies )
            removeBuff( "overpower" )

            if talent.demolish.enabled and active_enemies > 2 then
                if talent.dominance_of_the_colossus.enabled and buff.colossal_might.stack == 10 then reduceCooldown( "demolish", 2 ) end
                if talent.colossal_might.enabled then addStack( "colossal_might" ) end
            end
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
        cooldown = function () return 120 - ( talent.valor_in_victory.enabled and 30 or 0 ) - ( conduit.stalwart_guardian.enabled and 20 or 0 ) - ( talent.honed_reflexes.enabled and 120*0.05 or 0 ) end,
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
            removeDebuff( "target", "marked_for_execution" )
            if not buff.sudden_death.up and not buff.stone_heart.up then
                local cost = min( rage.current, 40 )
                spend( cost, "rage", nil, true )
                if talent.improved_execute.enabled then
                    gain( cost * 0.1, "rage" )
                end
                if talent.critical_thinking.enabled then
                    gain( cost * ( talent.critical_thinking.rank * 0.1 ), "rage" ) -- Regain another 10/20% for critical thinking
                end
            end
            if buff.sudden_death.up then
                removeBuff( "sudden_death" )
                if talent.imminent_demise.enabled then
                    addStack( "imminent_demise" )
                end
                if set_bonus.tier31_4pc > 0 then
                    spec.abilities.thunder_clap.handler()
                    applyDebuff( "target", "finishing_wound" )
                end
            end
            if talent.executioners_precision.enabled then applyDebuff( "target", "executioners_precision", nil, min( 2, debuff.executioners_precision.stack + 1 ) ) end
            if legendary.exploiter.enabled then applyDebuff( "target", "exploiter", nil, min( 2, debuff.exploiter.stack + 1 ) ) end
            if talent.juggernaut.enabled then addStack( "juggernaut" ) end
            if talent.dominance_of_the_colossus.enabled and buff.colossal_might.stack == 10 then reduceCooldown( "demolish", 2 ) end
            if talent.colossal_might.enabled then addStack( "colossal_might" ) end
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

        spend = 20,
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
        cooldown = function() return 30 - ( talent.honed_reflexes.enabled and 30*0.05 or 0 ) end,
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
            if talent.dominance_of_the_colossus.enabled and buff.colossal_might.stack == 10 then reduceCooldown( "demolish", 2 ) end
            if talent.colossal_might.enabled then addStack( "colossal_might" ) end
        end,
    },


    overpower = {
        id = 7384,
        cast = 0,
        charges = function () return 1 + ( talent.improved_overpower.enabled and 1 or 0 ) end,
        cooldown = 12,
        recharge = 12,
        gcd = "spell",

        spend = function() return talent.finishing_blows.enabled and target.health_pct < 35 and -8 or 0 end,
        spendType = "rage",

        talent = "overpower",
        startsCombat = true,
        texture = 132223,

        handler = function ()
            removeBuff( "opportunist" )
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
        cooldown = function () return 15 - ( talent.concussive_blows.enabled and 1 or 0 ) - ( talent.honed_reflexes.enabled and 15*0.05 or 0 ) end,
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

    ravager = {
        id = 228920,
        cast = 0,
        cooldown = 90,
        recharge = 90,
        gcd = "spell",

        talent = "ravager",
        startsCombat = true,
        texture = 970854,

        toggle = "cooldowns",

        handler = function ()
            applyBuff( "ravager" )
            if talent.merciless_bonegrinder.enabled then applyBuff( "merciless_bonegrinder" ) end
        end,
    },


    rend = {
        id = 772,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = 20,
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

        spend = 20,
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


    spell_reflection = {
        id = 23920,
        cast = 0,
        cooldown = function() return 25 - ( talent.honed_reflexes.enabled and 25 * 0.05 or 0 ) end,
        gcd = "off",

        talent = "spell_reflection",
        startsCombat = false,

        toggle = "interrupts",
        debuff = "casting",
        readyTime = state.timeToInterrupt,

        usable = function()
            if not settings.spell_reflection_filter then return true end

            local filters = class.reflectableFilters
            local npcid = target.npcid
            local t = debuff.casting

            -- Only use on a reflectable spell targeted at the player.
            return not not ( t.up and npcid and filters and filters[ npcid ] and filters[ npcid ][ t.v1 ] and UnitIsUnit( "player", t.caster .. "target" ) )
        end,

        handler = function ()
            applyBuff( "spell_reflection" )
            applyBuff( "spell_reflection_defense" )
        end,
    },


    storm_bolt = {
        id = 107570,
        cast = 0,
        cooldown = function() return 30 - ( talent.honed_reflexes.enabled and 30*0.05 or 0 ) end,
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
        id = 6343,
        cast = 0,
        cooldown = 6,
        hasteCD = true,
        gcd = "spell",

        spend = 20,
        spendType = "rage",

        talent = "thunder_clap",
        startsCombat = true,

        handler = function ()
            applyDebuff( "target", "thunder_clap" )
            active_dot.thunder_clap = max( active_dot.thunder_clap, active_enemies )

            if talent.rend.enabled then
                applyDebuff( "target", "rend" )
                active_dot.rend = min( active_enemies, 5 )
            end
        end,
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
            applyDebuff ( "target", "thunderous_roar" )
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
        end,
    },


    whirlwind = {
        id = 1680,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = function() return buff.storm_of_swords.up and 0 or 20 end,
        spendType = "rage",

        notalent = "cleave",
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

local NewFeature = "|TInterface\\OptionsFrame\\UI-OptionsFrame-NewFeatureIcon:0|t"

spec:RegisterSetting( "spell_reflection_filter", true, {
    name = format( "%s Filter M+ |T132361:0|t Spell Reflection (TWW Season 1)", NewFeature ),
    desc = "If checked, then the addon will only suggest |T132361:0|t Spell Reflection on reflectable spells that target the player.",
    type = "toggle",
    width = "full",
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
    nameplateRange = 10,
    rangeFilter = true,

    damage = true,
    damageDots = false,
    damageExpiration = 8,

    potion = "spectral_strength",

    package = "Arms",
} )


spec:RegisterPack( "Arms", 20241021, [[Hekili:T3txVTnUY(BPOyDJ3n11sjUnDrsao3f3h2Il27dzp79nlRyZyRtKL8rsUPzrG)TFh(HKiP4qsj70ZcCoOaPjwdhoC48Tgsppy(Vp)UvXvK5)w40WldMggmjii8Zbxn)UQN3rMF3U4LpgVg(LS4TWp)BfBlPF4ZP5XROdUmFFXs4bBQQ2v(ZF4dRtQ2S)(jlZ3(HYKT7tJRsYZwwe)qf9Vx(H53D)(K0QFnB(9gM5GWzHZVlEF1M8I53Dxdc(fkcGjjz1kcFKKYLZVJoY3hm99Hb)8Hfa0)YHf73rr6HVC4lSho9ZVF6fNFyb9)Nj()Rqb(Q3hodE4FN9XLhwCFCjz1Hf5zhw8RlF(9)bjjRug6GzCu1ftF69Hxap733qoS4)lUa(bWxsYMFxAszvjJXLg)mPiQSc(JFJTpqYIVpLSA()187wwKurksIHfAE1Kcs2k4hBJPt)IRV5WI1lxnzB83aw1sk7z(DuqMxb8skIQ)qyNiBfPiFFzurECH8maGEHmOl3eVDh8BLrL7iDa9suYBzEE6Q8NYGn808YsyMk3gxUrLANDyXlVCyXkY97F4bDi3VRLkI)ACfm5WmotH4ugHgT9rziFkU4(cs8Je9vWNWzWCQABCXJKvrpKxer(gz5Ek(Muwbs)hwalHl4lbgO)J9RxtkYaPuJBkhw8JQWxUNk1gTIexTrcLHTKnFgjuc9QHZQVvJgUuIg8EmTe19PXGwwvEXwkD9zu6IH)8D7YlQ2Nbs3k7O5FLuSl)jcBtnyQ8E1wyaXPGcqrYJeTTRGazilFCFAA5U0KQQoBSbks8TtNguxmmfmgpzwx1SaCnIAPPQeyXTRaiMYYj09nj55us8xz72bkY5GjHT6e(hTprTBskSD2NeDFEA1C6)K0G(3aZnDPwWUYAsRDfJOMc8xjrKmY2eQTFarbMSm9rVTm9jVSmDLV6eFwgWvKT5GRe9PuvdZQEdUmaS5uSwWccXuLv25RTFzsPZPQj(U9WunDOsjRneNtSRouB7eIcHuaBmRI3cssGQ2HfJeww3skwMKck5G6wgzDrcvhqrzSvDpeDIEd4EuB12rXkAzA8UoQs216UuguHqSkekSRAnflUylFIq2LKTwiKwAsOhNxQpAvRwkYR66gOAq4UMaDjsg4qkdc9Anz1ebqC)IIhAE)RgDnZUQ3qv9m7wZu9Lz1IHQwLqUXBpzUzWnwnSR3HW2qzgZ8sp3HNmReUQDrk2og5mvlz4rC5gtsbUf8zdALCvwvgrO3rbfg42iBOIiJ0gJgyk2mEAtsr6tGKEhtJISsCAySx2Rc7H9JxpBB21s7rAeEPkFLtnzhru3dj4PoWKC(hYUUs2Unjd00HhTnPKuNBY1q6lMfXd8swla3nN7vwhFadWGhBfkYRRjzosrjeoozzszsBMDxJLgMRa8pQzvnUQU22Wds1wYQy2L(Ez3v41yfO4ScsoE9MQUoomy51dlMQMwXCWOAxfXAzG32Ed9WGPMzvBXBhQyTYqMEH476dktVAgGvZ4uSOL0tOft1v2cH1r06GYXBAc66(088vPKQka7DLsQdLFO(cSBPhNpF0zx(rNEKgOdKbe7R7QTPeniUpeVnPvVhZee4mLwwh8OZeUDG99nGAhid8uP64PHLdiOKurdgFF5KQNEki6YDlpSySnJs4c4favWRY1LtnBEm0xn4(KoRBFKZCBSk4JEASQnUT)Js)RJs)aQG9RsaL4UhCuuAJY(onE4PoVz2sBnMBkfD)qRZDgaXbZASAiKYqqEh5ntj0BXeceP4vZWmuy3gKbDKgRDN1xMIdlOwnt6iUC1A4ZMT21(uPkEPvCBJXsRgP3fEyT7sVmVIRi3FrGUCOtt12xrEiEFQJkTxLSLWvrNorieVfw1BzXqdBbXzljmr8RuSXvS2rLePk8ncAuS7Pk6vI3we8C2iEibIGpsrKvs(Fxo7)RTxBEfsjwyXiM64sMHFWm4YkjeTF7wsAJ1Cje1SOJttJ4)re9TNYFhQr83h9xJHPcgrPjJ8EHbyZp7rsvzJnB7EjuKzunfr3gL1zMjfXrCXY4mseiOawcQAS8BZ4R2EfD2vnlAKuANYu6gyz0)y)Q1BfZjUpKt0CEF86O8hIGNU8Xs7Uy0KVOmqzJmChPm7qkILcHkQ2dWnJwLW511JTwEqydGeTBtCjXnAniTlT7DpyiHu8ii(6WxH7aeybbf9W(IND51WjQEiPGWqNdJ7UXe1wdSLcBSuvLwl2iQ1888fzp0wuDGnQhA5TmFcuPLLuKkfT3(munsLxptLHAXGIKLpVmfelyIiLS5tAQ9BfywaYm9jNgbUFP(WVKtJcJsgk3KfyVdVCi06rmPm7owQAuRxBVyqdsGsQO20bPBf8yfNCSe8qIsl7n6eGB4SNCSxbrQ6wxQwGke3GioXo4zveKfnUU8T3h3gMvRtOQkyFRCt((kTWhzgjRYxVofqiZYN2yyHDPniDtH5GLZsIumm1Sv6VLUVnMIjvbtskNurd5zdplwWiBw5wr5fGXPgesuaidSmD)kIPaI6X8g2Z5nuEE1nLjM3Kh4TDxrYo(0)FtNvEJYfdBZI4OAdw4CiSZKVMSIkyE)ZaqCFVhw8RpCyrs17kPcKaDFybifEyrwoe7eZbmKXp9xR2xarFeaOHKs9Hx)jq8YtmZ8kFoBzdZiaLrfrX387a8Oy7RDtdONO9LKiQFZ6sxj94MOHwTVG1EIhw8dsXijwNTpKhf(ytrykXBnrSD3N0xI(SGcTVGcpMfKUL9EiKQZNf5dR9CqLSAsC2ZrR2v2Xowh9gwgWMenOtrPPyG7bbRZh1j4q)j4qheCylbR7jONIm7ksYbrINBwoHQcn6UYmWBzKIQVmn6KZlWFkxIZPq3huaGo2O2hoM1XpNjs06N6W3B3xAG0abr1FyqmMfmXzEOB)bfa8MQ0fVXPQajQYycg9qgL5XjoDnTcrfr72)N)j4w7(8VzwRyBC2(4uJzI0J5mShZzy7CwjN(UHAL4McmeRtG8KcXoSlnolJM4MQVR)qUUb6Po1)j(wTjoE1Qsr2KdlcIZA7pP4YY4LfeLG8ezbVHeNwTzYULv83A)mMmeV5MmbanN2wIuniq5xJapYo94QSxm(E3KhgJxSN9FAFFda1GA8DZ9Q0zNgxLS8X7xBq4Sw9UAG9wClNMHY7mh)TvzPmMOV1FPUp3VUdxrcYA3H7S4epqk(kWiYFiIhyF3A)k1d2kcrifN(yBXnZY1x1wyQosdQTmUElvzjJAZtLPoLfxa1B2yBJrunxRpnm1Jdo6ujpRVUWxIrNg1EBqs9rXjWVxJhj6q2)SKvCTaCKCSWm5oQB0YY1sus5dJYm4gQDimYKw(H08k5)24QrCQJeqDyXtjvBG)K(zBswVb4VqcvLvjBHu3wjsb7CkyPPGSia1E2HE6HKckKXzWVVloPG(zCu934lqzUM1GgnhujpmG6qdFt36ZosnUSyGNZFNj3YY(O(T(zbKXgR77iSqdBIixh184lR3GfoyneiBZwUXGHRdeNhMsRNA0qlPDTGwDPhXlzTDFOwdd3CYi9AZi09MHbq61Mra(MrGTnJGbTze2DZOt2hw2m0vud1uudNBOyo9u5MwYK8S0NP)KWprI7lL1Y3vKtl1cVwmuA)8AiOk(5Wpl4dRHbDyX)l8rjaIZij8N7gB3NtTaOGN(K)4z2vyhzu2ZBnDpn04nfIPABwhsGJXMkKXjDLsHcXBdO2SJSKzxNwP86I0y9LM7kRDBk1(TmqTg4PXiVPqm1FRB6g2WoXR0EUH5L9e8qnb6H8p3NSBhz1KhEUionUAteOFhrJrFln4pQQUhAdoTSo2R9iNElL7zf4tI2et7Zw(sU9d0ohJgZq1rANhtBS5oLT)61aBXREwI8(RzBQYh6KMuQMOC6dff7WJumpHhxI(1q8oo8G9llFxTOLJJDGVn7BFpsfQ5I2Lh44WsOzWeJyTNgfnaSlMHSGC078fKLpspIFz0J5hiKMMxaz2rZQKDo325RCKFhRcnjy)qTQi6N8OKewAMNtDXgSu8jFl2GLu)9UydshKwNfKYn2ukDH6X9W0PgMwTAsbTrc53yjt)myiHAXJweaWtdlP7KT0cDbzkKdUyFNCJS8o67VeClZYJUmNgFq8(QCrs4GitgiYm5Wx(FsOX3)5F(WIFjpdMq2JFxL6jYeqwvE3pUEncp(SGVn2f2mEYx1qT1thR(8eC5jISp8fdCZ2U4OF8YGpzMQK8NOryg804G20BjO(rHHMjq5(LxJcn1k9(X((lbbAvS0C37QHF7T4BhbZzFhMkJCDrRa3p2DWfisScxE6IRADwJVQLdfDimZHIUpEArhM2(ar3vNw0HiZpq0fo9eHoJYUnDyv)KE7i8kY9ZwVq1qOTPBAfyfUqhXBbsS1euDMqhaRmHDuaAwHYVXFdRjTh7js70scgWSjyEvrpgIZ3r4qaHcsFTjyl)rNzd9)WpG18r3mDSdgRdmBdXnlQo2KAePSUd35XkBb4i19wGzyEvrpgIX3HdX2hmG((Td3lm71oCh3eNcDy7ivUXWqqSgikiVJNOtHmPDKALIncI9a8osjYxz07bI3vKVSE1Ad5yW5j9770q3rJ6p6P7B86aao8YwxTbzVvhMtm6XKjXW8qDv9kJEpqSF7N4W5j9770miXMap2xndZjg9Ek20Xn1BWEthJWE3fV8c2tgDMDxqy6OJ)XZcMm7NqueGNAycP9g64X3EM9WAW2E1NXaNZyGygRz)Fh5BF47oF7dVc8T2S96KEwJWU5gM1GepkGQ5vgylhiFMjlaAlhr5gg9D9knXUK8rvwobsrQCIE1G1WmwXI7GEKQbC0O3iVvS3u2p(ANA11iZ18QPn5wt6zQLy47d6uBXkKagKESNiTrFx86jmGydG8kICNO1FV4EfSWXpnwdwaRwpHwKocXLo(oHUa7cBDESNi1P8GrqEfrUt06FMgEjSD8tJvHnS68nqtrFNq3WSt8QICNO9eZcgi6Wkz5aTg8DcDdtv9vf5or7jMfmq0HvaZHTOFvrUt0omftpP5HHCSWmv7PU31RGnXEDwhtm8yVuRJoiBb6rY74Or)HV8Rm(kfPbH8lIbAJstVcdOCS53vUJSC(V9Pa6Lxq(djPK6ooPCsZ7A7NU5dY3Fbh(Iniy3wbNZVpdUbMlJaxNO650JgZncjK2oS)C2ba5Mw9b83dwFWFic(T9E2o8L3EyX)kVvb6ZcKNU)557UHDySflZGZBpB13aO88L5zRsO4uIdB(Dz03xdwFi2WHsSyV4L((gD6dXkkVuhbtzk5Lxot9bYVhIrMkzLqCSxusOrkjeJs6(grmqjHdIsQpVk6BHHYBHbsBGVsvTZwXorcZxRsAgE)aEw)oBL9ejFwT52qrMTvjV(SbvFotmzo1qz16dQdnJASk2r9ejqoGsEZOEEYd3qd56AQA(lV05Ig82RKhd)Y9JogPltWBMoY6Li4Tx9Yl0Jd1iLtj11HZuWm72(Jrn4xoGkKV2v3hNZuZNkDdAJdejivVm(OutJGLX73UBbzOr0R1VRNnvgpA3WEueHFp6nY(CiJxLBrVthwBUe7OOuzx62GRMoInfnTQTyZSQZ1T31uyBuzuUdbmJcn5bfoy7THh(YC)o5r0CP357auVB7SpQ3(26W2OJmj7R5pcMw)wf9I1nLz3GluXAu7OKSh2xkuuWWP6Q)2BcUyMKDw7Cpvg3nQAsA3uwC6sUHJpNF9AbofyABkna2i6iBV)kUn0Fmli5ZvUB0GjX2SzE96)CYsmPhRNBcL87o05SY2e6epTnRScAEZrVrO2gVw3g6mzdKNi)oE6ZQ5i2gAUR3SoFsE6K08OosPN6aMAP2Xt4AQhnSbPDwTWat7CAHsc8ZBLI3fZEoTsuC7buSOXCdqPpLjbdQ2JQfgekouWaQJcH2ZvoHtya1C2xyml(PN5MqmOfssor2GKn(XzORK04Tgf4e0dfeTJvJHDntRQweyL0gvl(l3B9wrNBb6wyDlvlrMhTODlU4Y32jnxc0TGAvQUfSAPwVIHWecu0nKWcYzfGDn8qnhA4RgJrNXgz3R09BcF5L309RcJXwjSA)cajrdy92BUCQDrwh6NTqAtVQfQ2BWfFit)5XMn1t13mO3zbu7Ay8mdnCglXrOBDSAiDRH1qK(OFfV6zlOavTQHACPuvdODhfcGuSGZHQ7r6fua6wfyijH(Z07O(naCOi5pqCiBhbB4iznFkwFubJ(qDs5wGMVIEn8AYC5cJEgftLKzhgEDDGBh0UU5WegeQSedHQEn7mWA2GXviMlCSRGBbYgdMF0xLYer)9rytdU(GUoSHJg4dKCJcLvlr15llxoJc7lkxumRVf8Moh2yhJ0IrzoCOwj5pwyhg95E43ra4ryRHJbRwH5G066vAFU(m2(YlIpW4Ua(MRtFwc4C5nrwwb9X(yoDylF0rzlQgoeEAl2cLPy3Q3Jw30AFgRSgKFlqxKHhSFCz4A7qYwtAY03QPrLSiKhcQMUmqOsXYa1MOTZCAMH7)eHaqupKHXKgU8ZLKdCEJFEZfcVID)wbJNLB9Zv(QHvK1H5Pxv9Ybl6w2KCPysScJ5zRRkJ2xovghfIKSmii57yCUhGqQC5dueauDsQ)nOLAidk0lZ5RXN0CPy2GwLRptdkzdTsfDg(XuNIoiZLkSh1OOdKVskZ2l0qx61UAVXS2TP2AbdQQN(vnc7VoVlB4loqJlBbbahUwKWmQSjOQh5e71WDvx1mB1MrxkfYz4m)wBmymvAMXwiaxgV4VkX634MXVn9U2M2xhxX4uqFytdFpQ)wI0YYc39DDoiOrARbypdHOo7kxbiiGtpFbD04WnFD(yw80xVE7FcdAyOFHlGIgtH1PbII4oAbEC5)wGmhUW7F2WMzlUxmUezp6cd4TGRHqkguI96IygJSO(H9xLU35SRmoNk4osSxbke1uhP0QaLfDu7z8QcKw(UkpSNPfQm2ojfkhhFDbxs2UnjdKjGpEBsjr4zPRUoEcCQBrd2MK3jYoYdVYgCn2Ze19zwme(BNvHn7QOCbVPsFKA6AT1d1sxi2(c3NLfMovB()UfWWGXKvlXJ8WM1BpSO5AYxUBFQB9pAdjSkpcP)KJQIlFSD2LgdTzqtQiBR75mJdNswTnBO0xUasDeuz7xSaJXQfpvfwEH8D6((3(cNED9w3SDSM1aT)tn1zQ8gCC0zVHTT18Ekgv126N1NAKBNstNW0NpwRdQgzQRsfnFReoupBPV8sv3wDvW4n0HS19L7nbJBhjsZOERAt3nI9LpR3m1qJm1quMAOtMAictnSNm1adm1aeMA3ZsJnMA4y5TJEWuFl)4a8x0BmF)305T9eQQ0zg1dgPTHJRVyvv09SAsdXKGiByJvAz)HqUV8cIbXO6lr9BdLpPbUyUHMzUHgwMErTHUyUHwyUDMvtAkO7jJvofcdHCpzmx6Gy3y7mURZBIElcA2SAm2cp0Mj8XIOa(JoDq(KMMk)N0BeFjNYIEWNogZ9IhowKC4Bel36fweHHX7JsbEoR(D7P9vfxD3B3(Ta31xmJAsTZhhoLDdhp)))d]] )