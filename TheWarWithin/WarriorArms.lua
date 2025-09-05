-- WarriorArms.lua
-- August 2025
-- Patch 11.2

if UnitClassBase( "player" ) ~= "WARRIOR" then return end

local addon, ns = ...
local Hekili = _G[ addon ]
local class, state = Hekili.Class, Hekili.State
local spec = Hekili:NewSpecialization( 71 )

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
    armored_to_the_teeth           = {  90366,  384124, 2 }, -- Gain Strength equal to $s1% of your Armor
    avatar                         = {  90365,  107574, 1 }, -- Transform into a colossus for $s1 sec, causing you to deal $s2% increased damage and removing all roots and snares. Generates $s3 Rage
    barbaric_training              = {  90340,  383082, 1 }, -- Slam, Cleave, and Whirlwind deal $s1% more damage and $s2% increased critical strike damage
    battle_stance                  = {  90327,  386164, 1 }, -- A balanced combat state that increases the critical strike chance of your abilities by $s1% and reduces the duration of movement impairing effects by $s2%. Lasts until canceled
    berserker_shout                = {  90348,  384100, 1 }, -- Go berserk, removing and granting immunity to Fear, Sap, and Incapacitate effects for $s1 sec. Also remove fear effects from group members within $s2 yds
    bitter_immunity                = {  90356,  383762, 1 }, -- Restores $s1% health instantly and removes all diseases, poisons, and curses affecting you
    blademasters_torment           = {  90363,  390138, 1 }, -- Activating Avatar grants $s1 sec of Sweeping Strikes and while Avatar is active the cooldown of Cleave is reduced by $s2 sec
    bounding_stride                = {  90355,  202163, 1 }, -- Reduces the cooldown of Heroic Leap by $s1 sec and Heroic Leap also increases your movement speed by $s2% for $s3 sec
    cacophonous_roar               = {  90383,  382954, 1 }, -- Intimidating Shout can withstand $s1% more damage before breaking
    champions_might                = {  90323,  386284, 1 }, -- The duration of Champion's Spear is increased by $s1 sec. You deal $s2% increased critical strike damage to targets chained to your Spear
    champions_spear                = {  90380,  376079, 1 }, -- Throw a spear at the target location, dealing $s$s2 Physical damage instantly and an additional $s3 damage over $s4 sec. Deals reduced damage beyond $s5 targets. Enemies hit are chained to the spear's location for the duration. Generates $s6 Rage
    concussive_blows               = {  90354,  383115, 1 }, -- Cooldown of Pummel reduced by $s1 sec. Successfully interrupting an enemy increases the damage you deal to them by $s2% for $s3 sec
    crackling_thunder              = {  95959,  203201, 1 }, -- Thunder Clap's radius is increased by $s1% and it reduces affected target's movement speed by an additional $s2%
    cruel_strikes                  = {  90381,  392777, 2 }, -- Critical strike chance increased by $s1% and critical strike damage of Execute increased by $s2%
    crushing_force                 = {  90347,  382764, 2 }, -- Mortal Strike deals an additional $s1% damage and deals $s2% increased critical strike damage
    defensive_stance               = {  92537,  386208, 1 }, -- A defensive combat state that reduces all damage you take by $s1% and all damage you deal by $s2%. Lasts until canceled
    double_time                    = {  90382,  103827, 1 }, -- Charge gains $s1 additional charge and its cooldown is reduced by $s2 sec
    fast_footwork                  = {  90344,  382260, 1 }, -- Movement speed increased by $s1%
    frothing_berserker             = {  90352,  392792, 1 }, -- Mortal Strike and Cleave have a $s1% chance to immediately refund $s2% of the Rage spent
    heroic_leap                    = {  90346,    6544, 1 }, -- Leap through the air toward a target location, slamming down with destructive force to deal $s$s2 Physical damage to all enemies within $s3 yards
    honed_reflexes                 = {  95956,  391271, 1 }, -- Cooldown of Die By the Sword, Pummel, Intervene, Spell Reflection, and Storm Bolt reduced by $s1%
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
    seismic_reverberation          = {  90354,  382956, 1 }, -- If Whirlwind or Cleave hits $s1 or more enemies it hits them $s2 additional time for $s3% damage
    shattering_throw               = {  90351,   64382, 1 }, -- Hurl your weapon at the enemy, removing any magical immunities and causing $s$s2 Physical damage, ignoring armor. Deals up to $s3% increased damage to absorb shields
    shockwave                      = {  90375,   46968, 1 }, -- Sends a wave of force in a frontal cone, causing $s1 damage and stunning all enemies within $s2 yards for $s3 sec
    sidearm                        = {  90340,  384404, 1 }, -- Your auto-attacks have a $s2% chance to hurl weapons at your target and $s3 other enemy in front of you, dealing $s$s4 Physical damage
    spell_reflection               = {  90385,   23920, 1 }, -- Raise your weapon, reflecting the first spell cast on you and reducing magic damage you take by $s1% for $s2 sec
    storm_bolt                     = {  90337,  107570, 1 }, -- Hurls your weapon at an enemy, causing $s$s2 Physical damage and stunning for $s3 sec
    thunder_clap                   = {  90343,    6343, 1 }, -- Blasts all enemies within $s2 yards for $s$s3 Physical damage and reduces their movement speed by $s4% for $s5 sec. Deals reduced damage beyond $s6 targets. If you have Rend, Thunder Clap affects $s7 nearby targets with Rend
    thunderous_roar                = {  90359,  384318, 1 }, -- Roar explosively, dealing $s$s3 Physical damage to enemies within $s4 yds and cause them to bleed for $s$s5 physical damage over $s6 sec. Deals reduced damage beyond $s7 targets
    thunderous_words               = {  90358,  384969, 1 }, -- Increases the duration of Thunderous Roar's Bleed effect by $s1 sec and Thunderous Roar's Bleed effect causes enemies to take $s2% increased damage from all your bleeds
    twohanded_weapon_specialization = {  90322,  382896, 2 }, -- While wielding two-handed weapons your damage is increased by $s1% and damage taken from area of effect attacks is reduced by $s2%
    uproar                         = {  90357,  391572, 1 }, -- Thunderous Roar's cooldown reduced by $s1 sec
    war_machine                    = {  90328,  262231, 1 }, -- Your auto-attacks generate $s1% more Rage. Killing an enemy instantly generates $s2 Rage and increases your movement speed by $s3% for $s4 sec
    warlords_torment               = {  90363,  390140, 1 }, -- Activating Avatar grants $s1 sec of Recklessness. The additional Rage generation of this Recklessness is reduced to $s2%
    wild_strikes                   = {  90360,  382946, 2 }, -- Haste increased by $s1% and your auto-attack critical strikes increase your auto-attack speed by $s2% for $s3 sec
    wrecking_throw                 = {  90351,  384110, 1 }, -- Hurl your weapon at the enemy, causing $s$s2 Physical damage, ignoring armor. Deals up to $s3% increased damage to absorb shields

    -- Arms
    anger_management               = {  90289,  152278, 1 }, -- Every $s1 Rage you spend on attacks reduces the remaining cooldown on Warbreaker, Bladestorm, and Ravager by $s2 sec
    battlelord                     = {  92615,  386630, 1 }, -- Overpower has a $s1% chance to reset the cooldown of Mortal Strike and generate $s2 Rage
    bladestorm                     = {  90441,  227847, 1 }, -- Become an unstoppable storm of destructive force, striking all nearby enemies for $s$s2 Physical damage over $s3 sec. Deals reduced damage beyond $s4 targets. You are immune to movement impairing and loss of control effects, but can use defensive abilities and can avoid attacks
    bloodborne                     = {  90283,  383287, 2 }, -- Your Bleed effects deal $s1% increased damage
    bloodletting                   = {  90438,  383154, 1 }, -- Deep Wounds, Rend and Thunderous Roar's Bleed effects last $s1 sec longer and have a $s2% increased critical strike chance. If you have Rend, Mortal Strike inflicts Rend on targets below $s3% health
    bloodsurge                     = {  90277,  384361, 1 }, -- Damage from Deep Wounds has a chance to generate $s1 Rage
    blunt_instruments              = {  90287,  383442, 1 }, -- Colossus Smash damage increased by $s1% and its effect duration is increased by $s2 sec
    cleave                         = {  90293,     845, 1 }, -- Strikes all enemies in front of you for $s$s2 Physical damage, inflicting Deep Wounds. Cleave will consume your Overpower effect to deal increased damage. Deals reduced damage beyond $s3 targets
    collateral_damage              = {  92536,  334779, 1 }, -- When Sweeping Strikes ends, your next Cleave or Whirlwind deals $s1% increased damage for each ability used during Sweeping Strikes that damaged a second target
    colossus_smash                 = {  90290,  167105, 1 }, -- Smashes the enemy's armor, dealing $s$s2 Physical damage and increasing damage you deal to them by $s3% for $s4 sec
    critical_thinking              = {  90444,  389306, 2 }, -- Critical Strike chance increased by $s1% and Execute immediately refunds $s2% of the Rage spent
    dance_of_death                 = {  92535,  390713, 1 }, -- When an enemy dies while affected by your Bladestorm, all damage you deal is increased by $s1% for the remainder of the Bladestorm and for $s2 sec afterwards. When an enemy dies while affected by your Ravager, its duration is extended by $s3 sec. These effects can trigger a maximum of $s4 times per use of Bladestorm or Ravager
    deft_experience                = {  90437,  389308, 2 }, -- Mastery increased by $s1% and Tactician's chance to trigger is increased by an additional $s2%
    die_by_the_sword               = {  90276,  118038, 1 }, -- Increases your parry chance by $s1% and reduces all damage you take by $s2% for $s3 sec
    dreadnaught                    = {  90285,  262150, 1 }, -- Overpower causes a seismic wave, dealing $s1 damage to all enemies in a $s2 yd line. Deals reduced damage beyond $s3 targets
    executioners_precision         = {  90445,  386634, 1 }, -- Execute causes the target to take $s1% more damage from your next Mortal Strike, stacking up to $s2 times
    exhilarating_blows             = {  90286,  383219, 1 }, -- Mortal Strike and Cleave have a $s1% chance to instantly reset their own cooldowns
    fatality                       = {  90439,  383703, 1 }, -- Mortal Strike and Cleave have a high chance to apply Fatal Mark to enemies above $s2% health. When an enemy with Fatal Mark is below $s3% health, your next Execute causes the Fatal Mark to deal $s$s4 Physical damage per stack
    fervor_of_battle               = {  90272,  202316, 1 }, -- If Cleave or Whirlwind hits $s1 or more targets you also Slam your primary target
    finishing_blows                = {  92614,  400205, 1 }, -- Overpower generates $s1 Rage when used on enemies below $s2% health
    fueled_by_violence             = {  90275,  383103, 1 }, -- You are healed for $s1% of the damage dealt by Deep Wounds
    ignore_pain                    = {  90269,  190456, 1 }, -- Fight through the pain, ignoring $s2% of damage taken until $s3 damage has been prevented. Repeated uses of Ignore Pain accumulate, up to $s$s4 total damage prevented
    impale                         = {  90292,  383430, 1 }, -- Critical strike damage of your abilities is increased by $s1%
    improved_execute               = {  90273,  316405, 1 }, -- Execute no longer has a cooldown and if your foe survives, $s1% of the Rage spent is refunded
    improved_overpower             = {  90279,  385571, 1 }, -- Overpower has $s1 charges and deals $s2% more damage
    improved_sweeping_strikes      = {  92536,  383155, 1 }, -- Sweeping Strikes lasts $s1 sec longer
    in_for_the_kill                = {  90288,  248621, 1 }, -- Warbreaker increases your Haste by $s1%, or by $s2% if any target is below $s3% health. Lasts for the duration of Warbreaker
    juggernaut                     = {  90446,  383292, 1 }, -- Execute increases Execute's damage dealt by $s1% for $s2 sec, stacking up to $s3 times
    martial_prowess                = {  90278,  316440, 1 }, -- Overpower increases the damage of your next Mortal Strike or Cleave by $s1%, stacking up to $s2 times
    massacre                       = {  90291,  281001, 1 }, -- Execute is usable on targets below $s1% health
    merciless_bonegrinder          = {  90266,  383317, 1 }, -- Whirlwind and Cleave deal $s1% increased damage during Ravager or for $s2 sec after Bladestorm ends
    mortal_strike                  = {  90270,   12294, 1 }, -- A vicious strike that deals $s$s2 Physical damage and reduces the effectiveness of healing on the target by $s3% for $s4 sec
    overpower                      = {  90271,    7384, 1 }, -- Overpower the enemy, dealing $s$s2 Physical damage. Cannot be blocked, dodged, or parried. Increases the damage of your next Mortal Strike by $s3%, stacking up to $s4 times
    ravager                        = {  90441,  228920, 1 }, -- Throws a whirling weapon at the target location that chases nearby enemies, inflicting $s$s2 Physical damage to all enemies over $s3 sec. Deals reduced damage beyond $s4 targets. Generates $s5 Rage each time it deals damage
    rend                           = {  90284,     772, 1 }, -- Wounds the target, causing $s$s3 Physical damage instantly and an additional $s$s4 Bleed damage over $s5 sec. Thunder Clap affects $s6 nearby targets with Rend
    sharpened_blades               = {  90447,  383341, 1 }, -- Your Mortal Strike, Cleave and Execute critical strike damage is increased by $s1% and your Execute has a $s2% increased critical hit chance
    skullsplitter                  = {  90281,  260643, 1 }, -- Bash an enemy's skull, dealing $s$s2 Physical damage. Skullsplitter causes your Rend and Deep Wounds on the target to bleed out $s3% faster for $s4 sec. Generates $s5 Rage
    spiteful_serenity              = {  90289,  400314, 1 }, -- Colossus Smash and Avatar's base durations are increased by $s1% but their damage bonuses are reduced by $s2%
    storm_of_swords                = {  90267,  385512, 1 }, -- Cleave and Whirlwind have a $s1% chance to make your next Cleave or Whirlwind cost $s2% less Rage
    storm_wall                     = {  90269,  388807, 1 }, -- Whenever you Parry, you heal for $s1% of your maximum health. This effect cannot occur more than once every $s2 sec
    strength_of_arms               = {  90285,  400803, 1 }, -- Overpower deals $s1% additional damage, has $s2% increased critical strike chance, and deals $s3% increased critical strike damage
    sudden_death                   = {  90274,   29725, 1 }, -- Your attacks have a chance to make your next Execute cost no Rage, be usable on any target regardless of their health, and deal damage as if you spent $s1 Rage
    tactician                      = {  90282,  184783, 1 }, -- You have a $s1% chance per Rage spent on attacks to reset the remaining cooldown on Overpower
    test_of_might                  = {  90288,  385008, 1 }, -- When Warbreaker expires, your Strength is increased by $s1% for every $s2 Rage you spent on attacks during Warbreaker. Lasts $s3 sec
    unhinged                       = {  90440,  386628, 1 }, -- Every other time Bladestorm or Ravager deal damage, you automatically cast a Mortal Strike at your target or random nearby enemy
    valor_in_victory               = {  90442,  383338, 1 }, -- Increases Versatility by $s1% and reduces the cooldown of Die by the Sword by $s2 sec
    warbreaker                     = {  90287,  262161, 1 }, -- Smash the ground and shatter the armor of all enemies within $s2 yds, dealing $s$s3 Physical damage and increasing damage you deal to them by $s4% for $s5 sec

    -- Colossus
    arterial_bleed                 = {  94799,  440995, 1 }, -- Colossal Might increases the damage of your Rend and Deep Wounds by $s1% per stack
    boneshaker                     = {  94789,  429639, 1 }, -- Shockwave's stun duration is increased by $s1 sec and reduces the movement speed of affected enemies by $s2% for $s3 sec after the stun ends
    colossal_might                 = {  94819,  429634, 1 }, -- Colossal Might increases damage dealt by your next Demolish by $s1%, stacking up to $s2 times. Mortal Strike grants a stack of Colossal Might and Cleave grants a stack of Colossal Might when it strikes $s3 or more targets
    demolish                       = {  94818,  436358, 1 }, -- Unleash a series of precise and powerful strikes against your target, dealing $s1 damage to it, and $s2 damage to enemies within $s3 yds of it. Deals reduced damage beyond $s4 targets. While channeling Demolish, you take $s5% less damage and are immune to stuns, knockbacks, and forced movement effects. You can block, parry, dodge, and use certain defensive abilities while channeling Demolish
    dominance_of_the_colossus      = {  94793,  429636, 1 }, -- Colossal Might now stacks up to $s1 times. If you would gain a stack of Colossal Might and are at max stacks, the cooldown of Demolish is reduced by $s2 sec. Enemies affected by Demolish take up to $s3% more damage from you and deal up to $s4% less damage to you for $s5 sec based on the number of stacks of Colossal Might consumed by Demolish
    earthquaker                    = {  94789,  440992, 1 }, -- Shockwave also knocks enemies into the air and its cooldown is reduced by $s1 sec
    martial_expert                 = {  94812,  429638, 1 }, -- Critical strike damage of your abilities is increased by $s1% and the amount of damage blocked by your critical blocks is increased by $s2%
    mountain_of_muscle_and_scars   = {  94806,  429642, 1 }, -- You deal $s1% more damage and take $s2% less damage. Size increased by $s3%
    no_stranger_to_pain            = {  94815,  429644, 1 }, -- Damage prevented by each use of Ignore Pain is increased by $s1%
    one_against_many               = {  94799,  429637, 1 }, -- Shockwave, Cleave, and Whirlwind deal $s1% more damage per target affected up to $s2
    practiced_strikes              = {  94796,  429647, 1 }, -- Mortal Strike and Cleave damage increased by $s1%
    precise_might                  = {  94794,  431548, 1 }, -- Mortal Strike critical strikes grant an additional stack of Colossal Might
    tide_of_battle                 = {  94811,  429641, 1 }, -- Colossal Might increases the damage of your Overpower by $s1% per stack
    veteran_vitality               = {  94815,  440993, 1 }, -- When your health is brought below $s1%, you gain a Second Wind, healing you for $s2% of your max health over $s3 sec. This effect cannot occur more than once every $s4 sec

    -- Slayer
    brutal_finish                  = {  94786,  446085, 1 }, -- Your next Mortal Strike after Bladestorm ends deals $s1% additional damage
    culling_cyclone                = {  94786,  444778, 1 }, -- Each strike of Bladestorm deals an additional $s1% damage evenly split across all targets
    death_drive                    = {  94813,  444770, 1 }, -- You heal for $s1% of damage dealt by Sudden Death
    fierce_followthrough           = {  94787,  444773, 1 }, -- Mortal Strike critical strikes increase the damage of your next Mortal Strike by $s1%
    imminent_demise                = {  94788,  444769, 1 }, -- Every $s1 Slayer's Strikes you gain Sudden Death. Using Sudden Death accelerates your next Bladestorm, striking $s2 additional time (max $s3). Bladestorm's total duration is unchanged
    opportunist                    = {  94787,  444774, 1 }, -- When Overpower has its cooldown reset by Tactician, your next Overpower deals $s1% additional damage and $s2% additional critical damage
    overwhelming_blades            = {  94810,  444772, 1 }, -- Each strike of Bladestorm applies Overwhelmed to all enemies affected, increasing damage you deal to them by $s1% for $s2 sec, max $s3 stacks
    reap_the_storm                 = {  94809,  444775, 1 }, -- Mortal Strike and Cleave when it hits $s2 or more targets have a $s3% chance to cause you to unleash a flurry of steel, striking all nearby enemies for $s$s4 Physical damage and applying Overwhelmed. Deals reduced damage beyond $s5 targets
    relentless_pursuit             = {  94795,  444776, 1 }, -- Charge increases your movement speed by $s1% for $s2 sec. Charge removes all movement impairing effects, this effect cannot occur more than once every $s3 sec
    show_no_mercy                  = {  94784,  444771, 1 }, -- Marked for Execution increases the critical strike chance and critical strike damage of your next Execute on the target by $s1%
    slayers_dominance              = {  94814,  444767, 1 }, -- Your attacks against your primary target have a high chance to overwhelm their defenses and trigger a Slayer's Strike, dealing $s$s2 Physical damage and applying Marked for Execution, increasing the damage they take from your next Execute by $s3%. Stacks $s4 times
    slayers_malice                 = {  94801,  444779, 1 }, -- Overpower damage increased by $s1%
    unrelenting_onslaught          = {  94820,  444780, 1 }, -- When you Execute a target that you've Marked for Execution, you both reduce the cooldown of Bladestorm by $s1 sec and apply $s2 stacks of Overwhelmed to the target per stack of Marked for Execution consumed. You can use Pummel and Storm Bolt while Bladestorming
    vicious_agility                = {  94795,  444777, 1 }, -- Heroic Leap reduces the cooldown of Charge by $s1 sec and Charge reduces the cooldown of Heroic Leap by $s2 sec
} )

-- PvP Talents
spec:RegisterPvpTalents( {
    battlefield_commander          = 5630, -- (424742) Your Shout abilities have additional effects.  Battle Shout: Increases Stamina by $s3%.  Piercing Howl: Radius increased by $s6%  Berserker Shout: Range increased by $s9 yds.  Intimidating Shout: Cooldown reduced by $s12 sec.  Rallying Cry: Removes movement impairing effects and grants $s15% movement speed to allies.  Thunderous Roar: Targets receive $s18% more damage from all sources while bleeding
    berserker_roar                 = 5701, -- (1227751) Go berserk, removing and granting immunity to Fear, Sap, and Incapacitate effects for $s1 sec. Also reduces the duration of the next crowd control effect within $s2 sec by $s3% on group members within $s4 yds
    demolition                     = 5372, -- (329033) Reduces the cooldown of your Shattering Throw or Wrecking Throw by $s1% and increases its damage to absorb shields by an additional $s2%
    disarm                         = 3534, -- (236077) Disarm the enemy's weapons and shield for $s1 sec. Disarmed creatures deal significantly reduced damage
    dragon_charge                  = 5679, -- (206572) Run at high speed at a distance in front of you. All enemies in your path will take $s$s2 Physical damage and be knocked back
    duel                           =   34, -- (236273) You challenge the target to a duel. While challenged, all damage you and the target deal to all targets other than each other is reduced by $s1%. Lasts $s2 sec
    master_and_commander           =   28, -- (235941) Cooldown of Rallying Cry reduced by $s1 sec
    rebound                        = 5547, -- (213915) Spell Reflection reflects the next $s1 incoming spells cast on you and reflected spells deal $s2% extra damage to the attacker. Spell Reflection's cooldown is increased by $s3 sec
    safeguard                      = 5625, -- (424654) Intervene now has $s1 charges and reduces the ally's damage taken by $s2% for $s3 sec. Intervene's cooldown is increased by $s4 sec
    sharpen_blade                  =   33, -- (1219165) Colossus Smash causes your next Mortal Strike to deal $s1% increased damage and reduce healing taken by $s2% for $s3 sec
    storm_of_destruction           =   31, -- (236308) Bladestorm, Ravager, and Demolish now snare all targets you hit by $s1% for $s2 sec and decrease their healing taken by $s3% for $s4 sec
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

spec:RegisterGear({
    -- The War Within
    tww3 = {
        items = { 237610, 237608, 237613, 237611, 237609 },
        auras = {
            -- Colossus
            critical_conclusion = {
                id = 1239144,
                duration = 12, -- 8 for arms?
                max_stack = 1
            },
            deeper_wounds = {
                id = 1239153,
                duration = 8,
                max_stack = 1
            },
        }
    },
    tww2 = {
        items = { 229235, 229233, 229238, 229236, 229234 },
        auras = {
            winning_streak = {
                id = 1216552,
                duration = 30,
                max_stack = 10,
                copy = "winning_streak_arms"
            },
            hedged_bets = {
                id = 1216556,
                duration = 12,
                max_stack = 1
            }
        }
    },
    -- Dragonflight
    tier31 = {
        items = { 207180, 207181, 207182, 207183, 207185 },
        setBonuses = {
            tier31_2pc = 422923,
            tier31_4pc = 422924
        },
        auras = {
            finishing_wound = {
                id = 426284,
                duration = 5,
                max_stack = 1
            }
        }
    },
    tier30 = {
        items = { 202446, 202444, 202443, 202442, 202441 },
        setBonuses = {
            tier30_2pc = 405577,
            tier30_4pc = 405578
        },
        auras = {
            crushing_advance = {
                id = 410138,
                duration = 30,
                max_stack = 3
            }
        }
    },
    tier29 = {
        items = { 200426, 200428, 200423, 200425, 200427, 217218, 217220, 217216, 217217, 217219 },
        setBonuses = {
            tier29_2pc = 393705,
            tier29_4pc = 393706
        },
        auras = {
            strike_vulnerabilities = {
                id = 394173,
                duration = 6,
                max_stack = 1
            }
        }
    },
    auras = {
        lethal_blows = {
            id = 455485,
            duration = 12,
            max_stack = 1
        }
    }
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
    if sourceGUID ~= state.GUID then return end

    if subtype == "SPELL_CAST_SUCCESS" then
        if ( spellName == class.abilities.colossus_smash.name or spellName == class.abilities.warbreaker.name ) then
            last_cs_target = destGUID
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

--[[spec:RegisterHook( "TimeToReady", function( wait, action )
    local id = class.abilities[ action ].id
    if buff.bladestorm.up and ( id < -99 or id > 0 ) then
        wait = max( wait, buff.bladestorm.remains )
    end
    return wait
end )--]]

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

    -- Will need to revisit this if `cancel_buff` is added to the APL.
    if buff.bladestorm.up then
        -- channelSpell( "bladestorm", buff.bladestorm.expires - class.auras.bladestorm.duration, class.auras.bladestorm.duration, class.abilities.bladestorm.id )
        setCooldown( "global_cooldown", buff.bladestorm.remains )
    end
end )

spec:RegisterStateExpr( "cycle_for_execute", function ()
    if active_enemies == 1 or target.health_pct < ( talent.massacre.enabled and 35 or 20 ) or not settings.cycle or buff.execute_ineligible.down or buff.sudden_death.up then return false end
    return Hekili:GetNumTargetsBelowHealthPct( talent.massacre.enabled and 35 or 20, false, max( settings.cycle_min, offset + delay ) ) > 0
end )

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
        nobuff = "bladestorm",
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
        copy = { 163201, 281000, 260798 },
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
            setCooldown( "global_cooldown", 0.75 )
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
            if talent.dominance_of_the_colossus.enabled and buff.colossal_might.stack == 10 then reduceCooldown( "demolish", 2 ) end
            if talent.colossal_might.enabled then addStack( "colossal_might" ) end
            if set_bonus.tww3_colossus >= 4 then removeStack( "critical_conclusion" ) end
            if talent.rend.enabled and target.health.pct < 35 and talent.bloodletting.enabled then
                applyDebuff ( "target", "rend" )
            end

            if set_bonus.tier30_4pc > 0 then removeBuff( "crushing_advance" ) end

        end,
    },


    overpower = {
        id = 7384,
        cast = 0,
        charges = function () if talent.improved_overpower.enabled then return 2 end end,
        cooldown = 12,
        recharge = function () if talent.improved_overpower.enabled then return 12 end end,
        gcd = "spell",

        spend = function() return talent.finishing_blows.enabled and target.health_pct < 35 and -8 or 0 end,
        spendType = "rage",

        talent = "overpower",
        startsCombat = true,
        texture = 132223,

        handler = function ()
            removeBuff( "opportunist" )
            if talent.martial_prowess.enabled then addStack( "overpower" ) end
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

            local zone = state.instance_id
            local npcid = target.npcid or -1
            local t = debuff.casting

            -- Only use on a reflectable spell targeted at the player.
            if not t.up then
                return false, "Target is not casting"
            end
            if not state.target.is_dummy and not class.reflectableFilters[ t.v1 ] then
                return false, "spell[" .. t.v1 .. "] in zone[" .. zone .. "] by npc[" .. npcid .. "] is not reflectable"
            end
            if not UnitIsUnit( "player", t.caster .. "target" ) then
                return false, "Player is not target of cast"
            end
            return true
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
        gcd = function() return buff.bladestorm.up and talent.unrelenting_onslaught.enabled and "off" or "spell" end,

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
    name = format( "%s Filter M+ |T132361:0|t Spell Reflection", NewFeature ),
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

    potion = "tempered_potion",

    package = "Arms",
} )

spec:RegisterPack( "Arms", 20250905, [[Hekili:L31)VnUTs()w2xr9g3M1XsjE3SfXgOxV7a6IIEfx23R)WHZ2kwYX6fzl)0xs28GH(B)gsQVqsXHKs2EBV7WcKnXIC4WHZ8z(IiPN7m)ZZV33lly(V6o2DY4poEYiNRD)443p)(Sx3hm)(9EREY7r4x25Tf(5pMSnL8HVgf75t6CACEYk4bBYY2N(dxD1JHzBYFy0Q4TxLgUnpYllmE3QeV1zK)E1vpef)WvzBcEXl5fOPH7U6hxrAYVLegNeM96VeMMLELFWAV8OSRGwr(8fEWWoI0)53)qEyu2pVB(dQyC3RDMFVxE2M4K53FF94)tKXh4XqF)awpdsbs9U3vS8ZBckw(7EjWpOStXY7d8sJH))6Ipri97g)X3nEYpuS8Fp8lfltZIt2wS8H4OSIL(5jH7Ee(RipGG0Nu2LBFNZhGU8J)2Va071DRUSy5AGvYca6MbD6PGS0ILE78lw(SxsO3drbPn9D87H((Z7cZc9Iye5tfFspZ6w17Rbca9(Z)(VZ)WL57jcRQg5(oxYqq4SILKLb43d3(tZVpIi9PlRrEVgKSind(JFLQLeSJWL(Z)xMF)kyHka4AqogNnkjyNp8JTEH7G50Dtlw(4k)rB9(cSsqxANFpPjZZGLkcHQ(qqpzNFqsCE6IKyVe(raA61OJ5Q44i)4x2b6yrXPPq3t36LUrKfMuS8Wbyfk4H81RLBz((gUW7zVmyWHr8g8zjcvyJb9zmYiq5vB82Uh(nO97dydXKJBs1wUcd7Jbus)EZKUKhRj5SILoJlwoOy5fnQHJkvpx4SGmXszZXwp1T6PdznaOWB0rKbQFEdz4KBcsaYC7d)FM5gGN9qsG3tS1SBnPXf8LGv5KEgKKUyFsWQWu4pgLMbGYflbnc3gsVnojZlcSytcFkGq9pIsDkT)75pcQo7aWsLkzfl)UIL3qNCazd2LX3HsQYP)NMtGwx4h4LTHN)WAc6qETGH7wVKNc8xSgCbull4i)1ntF2JPtCNX6N5X73dYQ8DawNGbB8Zbj7JFHT24Gd6b6dgnxN1wssMw19RrrqBFgQdgdVJnZPgxt0jLaaSOgJi8RZ18Tm9P8OO09rHGhmzGANB4BzJmuQv4qFQ9HCBBVhoVNFKEbmhEcC)UiBts8lYdhoKXB0OqRwD6wbrrK3w5bJAPLNgSiE96fWcbXJPg9VM1eb1p6NSGezXCY)4Wb)FRoHR1jzWWAbRLnqKBZDuWKHk99H75oXl0FrWZKvBpF)0rKqMiJ2evbayH3zLCUoxx90T8nyUm(a)INCegIlEg9UOiEMbLy1ShbGdBdFCJikPFW2yimXn1UyScozS1WjowbNiOexzSQdctpCHMy)0zCrrBNOaPAIEidERBV4a9M3aGfHj8dc2V4LyWCnTIx40eIc8EoO26whD4NmTWbwSkYBFTLVDGec4)PVaSjrmZudsLA7XBIjAoC8MxirB2btmzajXMiyIuI1OY2a3DHKTyt0pnb4Ar8bUs4R6AlHWwfTcPHdvdniAhxQFQYiw5eV0dD(oij3hd8fd4S8HBdswfc5nNc(m3f8ie1nOJ22tUueqxBnK1nwdz1PyBeamKn7edXbf97dkSoz0qQH3AbmPGgkN0sSzUJTgn1vyP)LnHjrValoTGalRXGTaGIYXM8sOFERLDzjRBhqP6l4NsZ7j2dNybAMvHBz021uXee0V4qC1G(jHJQbeunwGbqqLzRsZw0CcQhvUKowzDObkJL7RKcNyG)cyl1Gu4utmbwErGpSq5dsaIJIwMeI53ASCxhvXh0Gj2Uya8cdEzpU9GsC1B7oQGM8e7UefpG7sAToi5zq7lE9Ih8YYIcAtWgWYwiZ68vjcoJ52qexwT3axCfz7dE01(iVDVXcFf)QRy80A8f7k4avrY6U0v8ZxY6vIvTE0iu55Gfb7c2ggKkBm1Y7uMUW6nKGcR4KLkGpefh7hfKLbuVTYxv2l919NENBwe6Vvo3oZ1s49gDO)bRD7HdiyB2jIz7CSv0vNRs1iWDmTDDUtSVAd8z40m6cjxOXCWwNxmDKgBdKEuoiczEWqVJItu4HPTNqCN5jGshvB8JJ7UxAwNjzHDZy(Lw9Zd1lZtSX9HyUj4Hc9bRb)Ti9KM0e()HaR9hTShV(tnjXEQE9NNM8BucBFwYy5iGA)okctpbCvoUnL5XgSn7Qlu73lLMM6mH((Og2nGtLig6Dyuclsr2W8(O3jallPkCSkjZDvsgdjrX)KA4FMaT2CVoOqv(hk1lf6Cnw)TI1mteUh3xHYmECfmZTuV4nLcGkUK3OTT3ltoGURXbKbPEvsqHbjRcG0WJIIFH4vasTYuMv4yt8EbvBr1JkQHuOSBT3X255ncwURO07cmlCB5YY4rLUb2ct7T0KzbvAVDRcO2Z3kGvN8OHxFabARw3JqD6IQzeMBlDtapN2J1Ky8wiOfZvq09X0)x2z5(8TBdIm4JmgeDPbzn9QAlzq(TO8aLHh4uzAJ(QcRX7KBrWxi7wkQ1mmslyBqU0Sf7J82TdunyBZSKW9mU5VvTrVu5TT78(mEGEnChH5XE2G2pIFPBI0CJ0GYvovUZnphAqqb1KuVvjbcyKzeTWSrBc8IY2mA)Qmwn(Mu70rDdChZZKLgVl2VXlnOo0ao2SwPppjnWhW6aaZfH(XrwLG2D0ikzdvBkK1oPV649yBlihsaTXz8)TGwYNR3DG0n7xzRQ2LEzKpBdybbOfflHFeU1llGUlcbb8LKMffbgBqRa0hFI1wcPL0DA4EVWeYNXi1pYMy8t6oVfNCwS1BxoztkwRgkgoiBzL16rzoJw5b2hmeQzuiKQqj00KHnoxePRQD2LlKNWQOC)G2K2DeOrSOAHTuHQ5H1R41l1k3Cy7l3NQvGhdLiKZO9jXRg5T71f(7th5NNq3bQm7vbSp9HzIVDYqwlC72AHR51cfnPtRfo4Rfo6wlC61AHB71cx7xlKntDLmtDvgDEhTT)51flJ3f9k5NbKFqTs5mYb295qFc6UhtkFzvli29XWptyDRwavS8)a(OqGW7cczp3m1EiMaaiqhEvptB2Xl0BVoqPUN1g6wIZynhIzzRFlBYAZzCMQPaLGzZ(Gvuy9zeVBeVW6Zys7CPT8OFZdu4alrJSMdXS)1UQRyf7ept74kMDikA3Uob)J8W97d8hT(1eViVSnqYgbliVrQTKubjg7SjuDdFGesWoY4KALTIrC3HwTaA0vkN4G8jl24rEhpm5rZhOkd46Qh0mZSkoTY1HsDc1ES05rAG(GhgsNtSWa5zn9PmxZTc5zlwLfssBd4QxWeU8A9sw5bHAcPfcR)zgsnwDQz1Zo98sZygr8tMU4VN7)42QbvZlM90mOp49i51KcpD1tPnjORCiLsOKidVDSY4ueYdTmxcIroiqx4hYe3v9TwzxiFcZKvr6TJ51IHmgsi1nOPIcDqoYxCaAjNxSop51Mko0tsbjjeqjhTca4LG0mLifxawtHv2vEr00HC1uPIY3WE5l2rivWwz7st7IOUSkJwmLQrmjF3c2VVGC4LyhHPYubf2JLzkE52Oez1RRIa1cQkskD84gA7MbQvGuZFC1RYfVeGDrEXxTpmoPVst6RrHYR4iDi86rmOuKhxC4ocADheq9sHIBhRLvTxdoHQtgMcwOrj9UYYQ2VdNcj2zqLQ6ugwRqHdiIZS9EulRQkPs5XBFWRPUQnEHiVN3fPBIZZKQ9ifjjl(Xhjv3II8j1hADwL6KSPT5cMXfEsyke3vG3QnS3ziaYUlDB5RIVP6xnr4vM7D)kukxCpDBCD5hxKICgUwkV4)nYO6LvMPAjPsBIwaYB1pKKklOy(aK9CPV3ILKeQdZEBAz9VkwcAHqMWXq4tuhW0qKtcYYtGWpCaYeer8Hx9jJhnzKAHx6R7wvlmCqfuli0B(9aDeW(eJPK8Aai(n1LNttPj(22jz08qwz3hQP4RezRkMT96K8u0MjKR(jK7XmHKXP6GsQSCUDQ7KNdMKzv1ccnVvUAwnuTQbnLhvf6TdmSSCSDMRwZWUgyy3ggwoeXoQYuvTT6PJROsJSRmTvOrFUKMkvGrLURSPkGdPVM(lkZ567Bj)BwFQBPcglLEi6zVy8zT4oL24xvyr9IX5oz1DCUZHJ7uwaZoOZs9a5fbrWSbun2N)p)NGBUhI)IARew1Fuw2QomMUDymDBgZmPil61PlOQorA362ApLbwC2kRAQHdKqppEACHdvUdK66HrOQP4BesLCLzbx7JDL4BxhBh8yyF50X9zFFo0bT3LpeelloJbZQpC7mw9KDI5BMHTo4ckNBxyZ(9z6FEp)64ly2DY(75ra70D02BQIul9vIWfhEPBNiIPQpBQgpYdyhtbbyXM95JGzD95q9mDAiWGW722SttnUSc2xAZ)KjF2kuDUdOQUN8TeKurz(k7PRdAI87BwZJwF3XSw6pTRUbvopXXq98FLBQGSjvv6sTJBqvJUlf3a)AX66(g4VHWT3B(gbnfwzr2WDglVyxHqWrQTMGCiCDfm(iW91wepZMtTXR09QhS2tYh1J5rbOG1FYUqDo7AA7wyMq0wjBpoWOKUfNc3sCAxSecAQy5Bl3JJVLuLM)roBdlLgtErSaOEC5UDcmz39imhl(0Ves2jfKB8SFkEhmw0h)2Qei4E17abZI5EuM4ZUW5ld)AtoX3Pylk26Xwsu53(QccROjNrIBKSi5aRqgJ1obU)J4Cp6YNl(Y3xjY5OxBO1JTKOgxWu2KZiXnswK61OqgBL2GZ4tR18xn61pJTZl1nt3tTuOV0Z50A1(vJE9ZO68sDZ09ulf6l9CpPZ7Zl1nt3(zJAlx3pQ3q3RphoYqPApdwQ4tkIXS(n((2ofLj(eg)DKQy6RTXccJBqLfDyan0yHbCI2L0Q34aYsk3JTKO1kxAI4tvBoRKhJWX7dyTasiIC2GWM(dUqh5)2VT(JKEzOthp0GG1aL1r46j171AEHUc36Xclb4e18sG62CwjpgHXxHDXwhuq(UTc3jkB1k8hoh2W6jk)lQgHWsnXYSnpcDs9evlhRSjwLruF1ipZK3ccFst5cFyicww5Qaps7EmBdIWxUnNyYJP0yrMUDYxYzM8wqy7wxpYcR4yHGxDBoXK3Y11wa9VbBVQmaBNOC4a2tgCHEqCtgtd)UlCgn57r0yHNIShugoC2f6dqW0YT8i7yCKDkh5QLJVIYXR(dtoE1zuo2KheE9quVLyuyrG2qBZb3YrstdRZc7NPjGrOp5oJL9odkws)6gbEozt4gVoKSfG(MVPy5FDpXo3BlWyFL(ALP4tKXv6lmgIyzlKOe7lkfGz8MCZQpmPSX)RqsI)a50Du999czAYMyPJQZW87NEf)UiwFlO7z4lz7Q4PG8rzJRuEUKS9NM2ObvUnaVKUhQMkOUGK9xxOVlc91LDjiNkw(h5E7TltqMj4LX7Ns3sKLttNlB2HJtbsE5Q4D(H0yUBKWQJGVRj)1fM1TVmlw6gDnpMUWSLUaAPyYZjhoCH4d4J(EGk3kLQJDItCvYjUyCs78auWjU9ItQ2lTYlHU8lHoClGNjpR6cqXo)Qkc62sFR6crXopRkcmuN31USavTdwvbNQWvxxiTRAsJ5fLZTcqs2n1ZLHRNsQ)9DeZ8dhAD)(m7w((WUtDi9H7o8z64bA3vEZU9WbYHACGWbA8o3jmVF)x3)As46)7ILVRy5)zGF(oFVDzKOPbC)K89zS7KasH6PFdPbDh4raI)cYb9LUxYibEVkYJCSjjE(hkWX0R7N2J0N3eM2SnNlwMM)W7iXqu6C4HaY3VA)LYVP1c8)lSivOxEcLU(fJ9yeBi4eVErr8NBi2kx1aMs9O93A(RMokUuN2CjavUktAzZHPAQZGlAFFdnZbwlFJ67QNH4dg3TYJYbB2u3bxGq2dhu)5dqUwGMnrdJiCwWkzLlqUVFg06Q85URNm8WH2FS7y2Iu9fJdIwrPD0xnLImb(PP1(XlqIhArMx6t8IpIpNWSGTmc262eIyXk7dU2oKQk(1(YcsjZto47vsdhcpJ6QsLtmgwiOGsXIQpv1d48su92(Mngmpu(5dhi1BvoGk9tZrdXxAeO812RyP8wHZ0kx4tDg20te)wZMkESWnjgDvkgDrfJUgfJUiIr3okgDuigDqeJTFNN6eJUd5xaStm(nS0e(t6DQJXLzQ1cEKDxOuxFG0smUnHwZnZJQkRavQE0Unuic((WUhoGG1vF5QmZD8qJYux1YuxfZoRysxtYuxnY0wJQktc0LIHc5I0h29yLPK2sVAwOcvJxhndEJQlIgnkB6WkgQrGQdQw90H6HLJP04BfejGGxgjebTBaIZKHcSH492IWyR8IqzgKLZaYnaZDtgZthP7IfcHWVWvgOFm4PRW1TYPJQ1x2jeskaDpZ52XdKvIPPBK16Az5osBR1eecYunjKYyrqc2CRPGpnZ3Z3J6lhfB7G4DGI(Ejg6y4UNJFcIB)lzKZWsevxNP5s3c9lc3TopTmvomAko7Nn156jCED1l9efCtj561WCs3OcLXSYDdRCj7Ayyk1RM0D1WaPusCTNYLS8Lc3HgWGOB0upFTFmPBM(omFGmSEZrpMz6gqJ0P5QjrGmV5OxieVsr0Um0AW6PmH)W72LzZrSmuFNGOD84lXpVQpjjr65cH2jKVTgr7k)P9OMacNadd9S6erH2o5dhcAdBoir6Cq6CdUyqapQVer8ezH2UYJwf6ZzJi6JRwvjCjhyQ43djtDgp4c9vkBQlxCwyTXzmxJAF6zjnyObLl0h3Cwb5qoQ(UtKutfwjyu99Liknf8UJRyXFKQnPMwRGlRFF3e0UwF(XSI4OnQemWcjiUPHWzOcVzvh4mLyfL8HctsICrgntlbicqLctsvEhuHCX)ftIwYzgkPPTMTp5ytMnQasGABegJFboEbA2m35QY0PHhqXb4MscSK2MEeyKnePYDAf0t7RAaM4O15AwVsLbZXMwYJ9HgkPoqrTuxa8GBiQVteu8nubbfTsRvD7QrYA((xslxuJDq4aA2uFupBZTOqA(SP3mEGwoYUHxBR0I8WP0zc9P1Sqj(tAMjKdSozgFGr7)Wm3PdpRHSfqfVEfSUjYHD2SMsJJawGXdgbvPnR3gU5Q8osjPjx90gzcAH2iDQ80gG7hMjdnPLBw)97qxKjhqz1gfexXFVfXHxw3nfh1AnuvVF6EqqlSelBPfH9x1ul0(QMp2yH75)QgsG6pUMBeONMg2y0PPrg1VlBNnMwA6UwL)Y2Or)VAgvf)ixO8Y3kb6KC1PH29(Amm9P3IOVsuc0nNemRPMw9qVh3qsPjFLnGKvFtDsSYIVuks(meAGBKPAOAB1k0kzldHhIAJk0kRSpBqG0MvQuebcJJktpr2fXiwSrsz2k8qlcs(62riF4GXlJRPxJmIQIgtC1M3nynJPvrwO)cXKs7R4Dwv10H7RDAek1VySTusl91ZTLMpTSmV1c7hbjI1Z(UbtIl4mXu6Lx9uUGnNqI(r9e3gfuS2qXev)O67xQADbHBIQlZBUbRM6OayTVv4Ov3pM6B0IyMqFLRvGvONtQrA0eMqRbqcfxxWghoi(gA0jT6gQVgkPbx3C5sA1qlGWPrT7QRshTOQybpVWkKptvX9gZfX1zYWHMksHodczFh0Asm9MXA6Jc)fpl8fS5DUd04gH7thCrTjtLWRUGkLApSx58T8fIUfd12TJS9PBTzHHfewqGnFnKARyOsSnarEu5oqXx0O2PPwv8hByiZuuNTMEeFovNJfw2CIZQ7IjGtPQUye7PlyMQklYrbx2NkuHWvcDqGwYf8zSYDrhHt1Sf9jB9h8TOf(UWsn3AzPP(taNEIcQLVwtgD9CJQuiAhfCDrQB)ibYDD)Y)qS(zizhOUxsEdn5fJnPn82iPTziMXQyZSyPuDt0hRkwffTdr7wetb9iUYkoVXCujC1wu5toAK7tz1jvttC0DJfsuQHD0dJPIpk1oKQJOUQH1I7Uiq0e8BTSO3vaqQiGgbMCTajz21hfwfkp(Npmf5QSAneP(QaJrEt2mhDvsT2YzcUcVPI9wcjWFxDJR63NkQOqL2giZJPUWYMJkrEREyNaFNFpa)SA(V(bh6vx78)N]] )