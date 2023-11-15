-- WarriorArms.lua
-- November 2022

if UnitClassBase( "player" ) ~= "WARRIOR" then return end

local addon, ns = ...
local Hekili = _G[ addon ]
local class, state = Hekili.Class, Hekili.State
local FindPlayerAuraByID = ns.FindPlayerAuraByID

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
    -- Warrior
    berserker_rage                  = { 90372, 18499 , 1 }, -- Go berserk, removing and granting immunity to Fear, Sap, and Incapacitate effects for 6 sec.
    berserker_shout                 = { 90348, 384100, 1 }, -- Go berserk, removing and granting immunity to Fear, Sap, and Incapacitate effects for 6 sec. Also remove fear effects from group members within 12 yds.
    bitter_immunity                 = { 90356, 383762, 1 }, -- Restores 20% health instantly and removes all diseases, poisons and curses affecting you.
    blood_and_thunder               = { 90342, 384277, 1 }, -- Thunder Clap costs 10 more Rage and deals 10% increased damage. If you have Rend, Thunder Clap affects 5 nearby targets with Rend.
    bounding_stride                 = { 90355, 202163, 1 }, -- Reduces the cooldown of Heroic Leap by 15 sec, and Heroic Leap now also increases your movement speed by 70% for 3 sec.
    cacophonous_roar                = { 90383, 382954, 1 }, -- Intimidating Shout can withstand 200% more damage before breaking.
    crackling_thunder               = { 90342, 203201, 1 }, -- Thunder Clap's radius is increased by 50%, and it reduces movement speed by an additional 20%.
    cruel_strikes                   = { 90381, 392777, 2 }, -- Critical strike chance increased by 1% and critical strike damage of Execute increased by 5%.
    double_time                     = { 90382, 103827, 1 }, -- Increases the maximum number of charges on Charge by 1, and reduces its cooldown by 3 sec.
    elysian_might                   = { 90323, 386285, 1 }, --
    fast_footwork                   = { 90371, 382260, 1 }, -- Movement speed increased by 5%.
    furious_blows                   = { 90336, 390354, 1 }, -- Auto-attack speed increased by 5%.
    heroic_leap                     = { 90346, 6544  , 1 }, -- Leap through the air toward a target location, slamming down with destructive force to deal 544 Physical damage to all enemies within 8 yards.
    impending_victory               = { 90326, 202168, 1 }, -- Instantly attack the target, causing 1,156 damage and healing you for 30% of your maximum health. Killing an enemy that yields experience or honor resets the cooldown of Impending Victory and makes it cost no Rage.
    intervene                       = { 90329, 3411  , 1 }, -- Run at high speed toward an ally, intercepting all melee and ranged attacks against them for 6 sec while they remain within 10 yds.
    intimidating_shout              = { 90384, 5246  , 1 }, -- Causes the targeted enemy to cower in fear, and up to 5 additional enemies within 8 yards to flee. Targets are disoriented for 8 sec.
    leeching_strikes                = { 90344, 382258, 1 }, -- Leech increased by 5%.
    menace                          = { 90383, 275338, 1 }, -- Intimidating Shout will knock back all nearby enemies except your primary target, and cause them all to cower in fear for 15 sec instead of fleeing.
    overwhelming_rage               = { 90378, 382767, 2 }, -- Maximum Rage increased by 15.
    pain_and_gain                   = { 90353, 382549, 1 }, -- When you take any damage, heal for 3.50% of your maximum health. This can only occur once every 10 sec.
    piercing_howl                   = { 90348, 12323 , 1 }, -- Snares all enemies within 12 yards, reducing their movement speed by 70% for 8 sec.
    piercing_verdict                = { 90379, 382948, 1 }, -- Spear of Bastion's instant damage increased by 50% and its Rage generation is increased by 100%.
    rallying_cry                    = { 90331, 97462 , 1 }, -- Lets loose a rallying cry, granting all party or raid members within 40 yards 10% temporary and maximum health for 10 sec.
    reinforced_plates               = { 90368, 382939, 1 }, -- Armor increased by 20%.
    rumbling_earth                  = { 90374, 275339, 1 }, -- Shockwave's range increased by 6 yards and when Shockwave strikes at least 3 targets, its cooldown is reduced by 15 sec.
    second_wind                     = { 90332, 29838 , 1 }, -- Restores 6% health every 1 sec when you have not taken damage for 5 sec.
    seismic_reverberation           = { 90340, 382956, 1 }, -- If Whirlwind hits 3 or more enemies, it hits them 1 additional time for 30% damage.
    shattering_throw                = { 90351, 64382 , 1 }, -- Hurl your weapon at the enemy, causing 1,960 Physical damage, ignoring armor, and removing any magical immunities. Deals up to 500% increased damage to absorb shields.
    shockwave                       = { 90375, 46968 , 1 }, -- Sends a wave of force in a frontal cone, causing 463 damage and stunning all enemies within 10 yards for 2 sec. Generates 10 Rage.
    sonic_boom                      = { 90321, 390725, 1 }, -- Shockwave deals 350% increased damage and will always critical strike.
    spear_of_bastion                = { 90380, 376079, 1 }, -- Throw a spear at the target location, dealing 3,817 Physical damage instantly and an additional 4,062 damage over 4 sec. Deals reduced damage beyond 5 targets. Enemies hit are chained to the spear's location for the duration. Generates 20 Rage.
    spell_reflection                = { 90385, 23920 , 1 }, -- Raise your weapon, reflecting the first spell cast on you, and reduce magic damage you take by 20% for 5 sec.
    storm_bolt                      = { 90337, 107570, 1 }, -- Hurls your weapon at an enemy, causing 659 Physical damage and stunning for 4 sec.
    thunderous_roar                 = { 90359, 384318, 1 }, -- Roar explosively, dealing 3,997 Physical damage to enemies within 12 yds and cause them to bleed for 5,051 physical damage over 8 sec. Generates 10 Rage.
    thunderous_words                = { 90358, 384969, 1 }, -- Increases the duration of Thunderous Roar's Bleed effect by 2.0 sec and increases the damage of your bleed effects by 15% at all times.
    titanic_throw                   = { 90341, 384090, 1 }, -- Throws your weapon at the enemy, causing 809 Physical damage to it and 5 nearby enemies. Generates high threat.
    uproar                          = { 90357, 391572, 1 }, -- Thunderous Roar's cooldown reduced by 30 sec.
    wild_strikes                    = { 90360, 382946, 2 }, -- Haste increased by 1% and your auto-attack critical strikes increase your auto-attack speed by 10% for 10 sec.
    wrecking_throw                  = { 90351, 384110, 1 }, -- Hurl your weapon at the enemy, causing 1,960 Physical damage, ignoring armor. Deals up to 500% increased damage to absorb shields.

    -- Arms
    anger_management                = { 90289, 152278, 1 }, -- Every 20 Rage you spend on attacks reduces the remaining cooldown on Warbreaker and Bladestorm by 1 sec.
    armored_to_the_teeth            = { 90366, 384124, 2 }, -- Gain Strength equal to 5% of your Armor.
    avatar                          = { 90365, 107574, 1 }, -- Transform into a colossus for 20 sec, causing you to deal 20% increased damage and removing all roots and snares. Generates 10 Rage.
    barbaric_training               = { 92221, 383082, 1 }, -- Slam and Whirlwind deal 30% more damage but now cost 10 more rage.
    battle_stance                   = { 90327, 386164, 1 }, -- A balanced combat state that increases the critical strike chance of your abilities by 3% and reduces the duration of movement impairing effects by 10%. Lasts until canceled.
    battlelord                      = { 92615, 386630, 1 }, -- Overpower deals 35% increased damage and has a 35% chance to reset the cooldown of Mortal Strike and Cleave and generate -10 Rage.
    blademasters_torment            = { 90363, 390138, 1 }, -- Activating Avatar or Bladestorm casts the other at reduced effectiveness.
    bladestorm                      = { 90441, 227847, 1 }, -- Become an unstoppable storm of destructive force, striking all nearby enemies for 8,927 Physical damage over 5.1 sec. Deals reduced damage beyond 8 targets. You are immune to movement impairing and loss of control effects, but can use defensive abilities and can avoid attacks. Generates 20 Rage.
    bloodborne                      = { 90283, 383287, 2 }, -- Deep Wounds, Rend and Thunderous Roar's Bleed effects deal 7.50% increased damage.
    bloodletting                    = { 90438, 383154, 1 }, -- Deep Wounds, Rend and Thunderous Roar's Bleed effects last 6.0 sec longer and have a 5% increased critical strike chance. If you have Rend, Mortal Strike inflicts Rend on targets below 35% health.
    bloodsurge                      = { 90277, 384361, 1 }, -- Your Bleed effects have a chance to grant you 5 Rage.
    blunt_instruments               = { 90287, 383442, 1 }, -- Colossus Smash damage increased by 30% and its effect duration is increased by 3.0 sec.
    cleave                          = { 90293, 845   , 1 }, -- Strikes all enemies in front of you for 1,700 Physical damage, inflicting Deep Wounds. Cleave will consume your Overpower effect to deal increased damage. Deals reduced damage beyond 5 targets.
    collateral_damage               = { 90267, 334779, 1 }, -- When Sweeping Strikes ends, your next Whirlwind deals 25% increased damage for each ability used during Sweeping Strikes that damaged a second target.
    colossus_smash                  = { 90290, 167105, 1 }, -- Smashes the enemy's armor, dealing 4,198 Physical damage, and increasing damage you deal to them by 30% for 10 sec.
    concussive_blows                = { 90333, 383115, 1 }, -- Cooldown of Pummel reduced by 1.0 sec. Successfully interrupting an enemy increases the damage you deal to them by 5% for 10 sec.
    critical_thinking               = { 90444, 389306, 2 }, -- Critical Strike chance increased by 1% and Execute immediately refunds 5% of the Rage spent.
    crushing_force                  = { 90347, 382764, 2 }, -- Slam deals an additional 30% damage and has a 7.50% increased critical strike chance.
    dance_of_death                  = { 92535, 390713, 1 }, -- If your Bladestorm helps kill an enemy your next Bladestorm lasts 3.0 sec longer.
    defensive_stance                = { 92537, 386208, 1 }, -- A defensive combat state that reduces all damage you take by 15%, and all damage you deal by 10%. Lasts until canceled.
    deft_experience                 = { 90437, 389308, 2 }, -- Mastery increased by 1% and Tactician's chance to trigger is increased by an additional 0.6%.
    die_by_the_sword                = { 90276, 118038, 1 }, -- Increases your parry chance by 100% and reduces all damage you take by 30% for 8 sec.
    dreadnaught                     = { 90285, 262150, 1 }, -- Overpower has 2 charges and causes a seismic wave, dealing 1,113 damage to all enemies in a 10 yd line. Deals reduced damage beyond 5 targets.
    endurance_training              = { 90338, 382940, 1 }, -- Stamina increased by 5% and the duration of Fear, Sap and Incapacitate effects on you is reduced by 10.0%.
    executioners_precision          = { 90445, 386634, 1 }, -- Execute causes the target to take 35% more damage from your next Mortal Strike, stacking up to 2 times.
    exhilarating_blows              = { 90286, 383219, 1 }, -- Mortal Strike and Cleave have a 20% chance to instantly reset their own cooldowns.
    fatality                        = { 90439, 383703, 1 }, -- Your Mortal Strikes and Cleaves against enemies above 30% health have a high chance to apply Fatal Mark. When an enemy falls below 30% health, Your next Execute inflicts an additional 5,410 Physical damage per stack.
    fervor_of_battle                = { 90272, 202316, 1 }, -- If Whirlwind hits 2 or more targets it also Slams your primary target.
    frothing_berserker              = { 90352, 392792, 1 }, -- Mortal Strike and Cleave have a 20% chance to immediately refund 20% of the Rage spent.
    fueled_by_violence              = { 90275, 383103, 1 }, -- You are healed for 85% of the damage dealt by Deep Wounds.
    honed_reflexes                  = { 90354, 382461, 1 }, -- Cooldown of Overpower and Pummel reduced by 1.0 sec.
    hurricane                       = { 90440, 390563, 1 }, -- While Bladestorming, every 0.9 sec you gain 5% movement speed and 5% Strength, stacking up to 6 times. Lasts 6 sec. Bladestorm cannot be canceled while using Hurricane.
    ignore_pain                     = { 90269, 190456, 1 }, -- Fight through the pain, ignoring 50% of damage taken, up to 14,706 total damage prevented.
    impale                          = { 90292, 383430, 1 }, -- The damaging critical strikes of your abilities deal an additional 10.00% damage.
    improved_execute                = { 90273, 316405, 1 }, -- Execute no longer has a cooldown and if your foe survives, 10% of the Rage spent is refunded.
    improved_overpower              = { 90279, 385571, 1 }, -- Damage of Overpower increased by 15%.
    improved_slam                   = { 92614, 400205, 1 }, -- Slam has 15% increased critical strike chance and deals 10% increased critical strike damage.
    improved_sweeping_strikes       = { 92536, 383155, 1 }, -- Sweeping Strikes lasts 6 sec longer.
    in_for_the_kill                 = { 90288, 248621, 1 }, -- Warbreaker increases your Haste by 10%, or by 20% if any target is below 35% health. Lasts 10 sec.
    juggernaut                      = { 90446, 383292, 1 }, -- Execute increases Execute's damage dealt by 3% for 12 sec, stacking up to 15 times.
    martial_prowess                 = { 90278, 316440, 1 }, -- Overpower increases the damage of your next Mortal Strike or Cleave by 30%. Stacking up to 2 times.
    massacre                        = { 90291, 281001, 1 }, -- Execute is now usable on targets below 35% health.
    merciless_bonegrinder           = { 90266, 383317, 1 }, -- When Bladestorm ends, Whirlwind and Cleave deal 50% increased damage for 9 sec.
    mortal_strike                   = { 90270, 12294 , 1 }, -- A vicious strike that deals 4,916 Physical damage and reduces the effectiveness of healing on the target by 50% for 10 sec.
    overpower                       = { 90271, 7384  , 1 }, -- Overpower the enemy, dealing 3,555 Physical damage. Cannot be blocked, dodged, or parried. Increases the damage of your next Mortal Strike by 30%. Stacking up to 2 times.
    reaping_swings                  = { 90294, 383293, 1 }, -- Cooldown of Cleave reduced by 3 sec.
    rend                            = { 90284, 772   , 1 }, -- Wounds the target, causing 1,708 Physical damage instantly and an additional 3,300 Bleed damage over 15 sec.
    sharpened_blades                = { 90447, 383341, 1 }, -- Your Mortal Strike, Cleave and Execute critical strike damage is increased by 10% and your Execute has a 5% increased critical hit chance.
    sidearm                         = { 90333, 384404, 1 }, -- Your auto-attacks have a 20% chance to hurl weapons at your target and 3 other enemies in front of you, dealing an additional 578 Physical damage.
    skullsplitter                   = { 90281, 260643, 1 }, -- Bash an enemy's skull, dealing 2,776 Physical damage. Skullsplitter causes your Deep Wounds on the target to bleed out 100% faster for 10 sec. Generates 15 Rage.
    spiteful_serenity               = { 90289, 400314, 1 }, -- Colossus Smash and Avatar's durations are increased by 100% but their damage bonuses are reduced by 40%.
    storm_of_swords                 = { 90267, 385512, 1 }, -- Whirlwind costs 20 more Rage and has a 14.0 sec cooldown. It now deals 175% more damage.
    storm_wall                      = { 90269, 388807, 1 }, -- Whenever you Parry, you heal for 8.00% of your maximum health. Can only occur once per second.
    strength_of_arms                = { 92536, 400803, 1 }, -- Overpower has 10% increased critical strike chance, deals 10% increased critical strike damage and on enemies below 35% health Overpower generates 8 Rage.
    sudden_death                    = { 90274, 29725 , 1 }, -- Your attacks have a chance to make your next Execute cost no Rage, be usable on any target regardless of their health, and deal damage as if you spent 40 Rage.
    tactician                       = { 90282, 184783, 1 }, -- You have a 2.50% chance per Rage spent on attacks to reset the remaining cooldown on Overpower.
    test_of_might                   = { 90288, 385008, 1 }, -- When Warbreaker expires, your Strength is increased by 1% for every 10 Rage you spent on attacks during Warbreaker. Lasts 12 sec.
    thunder_clap                    = { 92224, 396719, 1 }, -- Blasts all enemies within 8 yards for 1,528 Physical damage. and reduces their movement speed by 20% for 10 sec. Deals reduced damage beyond 5 targets.
    tide_of_blood                   = { 90280, 386357, 1 }, -- Skullsplitter deals 30% increased damage and also causes your Rend on the target to bleed out 100% faster for 10 sec.
    twohanded_weapon_specialization = { 90322, 382896, 1 }, -- Increases your damage while using two-handed weapons by 5%.
    unhinged                        = { 90440, 386628, 1 }, -- While Bladestorm is active, you automatically cast a total of 2 Mortal Strikes at random nearby enemies.
    valor_in_victory                = { 90442, 383338, 1 }, -- Increases Versatility by 1% and reduces the cooldown of Die by the Sword by 30.0 sec.
    war_machine                     = { 90328, 262231, 1 }, -- Your auto attacks generate 10% more Rage. Killing an enemy instantly generates 5 Rage, and increases your movement speed by 30% for 8 sec.
    warbreaker                      = { 90287, 262161, 1 }, -- Smash the ground and shatter the armor of all enemies within 8 yds, dealing 4,198 Physical damage and increasing damage you deal to them by 30% for 10 sec.
    warlords_torment                = { 90363, 390140, 1 }, -- Activating Avatar or Colossus Smash casts Recklessness at reduced effectiveness.
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
    elysian_might = {
        id = 386286,
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
    spear_of_bastion = {
        id = 376080,
        duration = function () return ( legendary.elysian_might.enabled and 8 or 4 ) + ( talent.elysian_might.enabled and 2 or 0 ) end,
        tick_time = 1,
        max_stack = 1,
        copy = 307871 -- Covenant version.
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
        id = 384318,
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
        spentType = "rage",

        startsCombat = true,
        texture = 132337,

        usable = function () return target.distance > 8 and ( query_time - action.charge.lastCast > gcd.execute ) end,
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


    spear_of_bastion = {
        id = function() return talent.spear_of_bastion.enabled and 376079 or 307865 end,
        cast = 0,
        cooldown = 90,
        gcd = "spell",

        spend = function () return ( -25 * ( talent.piercing_verdict.enabled and 2 or 1 ) ) * ( 1 + conduit.piercing_verdict.mod * 0.01 ) end,
        spendType = "rage",

        startsCombat = true,
        toggle = "cooldowns",
        velocity = 30,

        handler = function ()
            applyDebuff( "target", "spear_of_bastion" )
            if talent.elysian_might.enabled or legendary.elysian_might.enabled then applyBuff( "elysian_might" ) end
        end,

        copy = { 307865, 376079 }
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


spec:RegisterOptions( {
    enabled = true,

    aoe = 2,

    nameplates = true,
    nameplateRange = 8,

    damage = true,
    damageDots = false,
    damageExpiration = 8,

    potion = "spectral_strength",

    package = "Arms",
} )


spec:RegisterPack( "Arms", 20231115, [[Hekili:v3ZAZnooY9BzQRwns76rJi1OXE3iPQ2SjvLzQu7Dv8EFkvKenfTfptrQqszp(kx63EWlsIhDdcQhE28HBU1cGnA0OFJgal8w8hlUDDqz0IF3FK)yppVjdhDZyVrFAXTLVSlAXT7ccFm4bY)rAWwY)(R5BlO)4ljzbRPFCr2(8qsdBkl3v8lF8JpexUz)DddZ2(XI4T7tckJZsdZdUVK(3HFCXT3TpoP8lPlUdEKhV42G9LBYYxC7T1a43OaGmiXRxhX)YOIWf3s)Yp459HrF(xoS6WQ)ROTzpfT(WQV83oS6(8SThw9F8R)2HvbPKFRiQu8NLzhwn1J8)hK)qu5WdF9WxRb0egG(BbLHBoSYB0q)MMhDnPhSM)77Oioba5XPpgvwqgSSCw39gor6dM8b)rqFWh)T)TcLUn6gE3ki95xZddsj)))rwEEukbNdi)VD5rLLVCyvs2Z0)iolpM(NXPK5vC6djrFqFYqHQVYG3GJnDA8h85KUVKgMSFnPx3UlkjHskVpjkKs6hU42K4IYc2InBSwYhlYp87m(NO0G7sIwV4FDXTHe8kkpoGSgs(4NIwgLgTnoIqHMp7WkF(pNLsG0Zrr7iqBzbHM8yuXIscFakWUB)93pSypDXF56OGYndZJiqQbCrFlkCpHxIaLXuOu97BZYldsedImWjD8tOd37oSADwjzmsxt(NTbXPfnGKWENUokFzysWokyMGcgYitwah(CqEsw(6ILLz5BP)GOZhw17WQ(hwfMLLSo75uImtswrX(ILfBdkytX1K14xFLGnrmkGwh2VJ3kRTYOIYLz3VCB8dBkznnG367Om6xEezqdfk4PachcL28zuAd(yXi3ebuc)YdHRhUn4B8HU(litJ7iO0Jr5G9wIhBxuqoLMCxqb7xiy01YChnqsJ14g5EPIHA98NTXejO7QlnYeDkx2AIGWYNZimvfnZh(cI9L9wjHZpSASYctXJ7tsk2LexsWrk27nQnM3oJ72gnCTfiSWTZ7FIKOPmsuTqeNZL85gI7zKVnpJZv7HROsq1kOsy0PsXZubof6wRe2CI52H7clzlG3mItSrMMs8YBIZtEooDnddhJIH6k20K06jRWOmEDet(jjlBDfoIRj0dxJQaGB2NNhtnVPR6XY6VtYr4QL4araH9PBi2CIw)2n8nuR7scioTqzmy0QwnBuKLghU8USSTMu(InzHp(CWtmdEE4AzphSJTkdnxI95hpS6AmEYRXngSH6qbbuuFe04bVlOSmjIA3sFrdMQtrv(kxJCerk3FIoVGjGBqCIxK57YEwO26gueVFn0cZ3xq5Tws8YkmYrUdHWo35OppYH1dj8pE7UCQ3Ullsc220JbvKNgs49r5pLjmesNZGGdVteWP7mhbD9uTSqWbgTc3E4Xmoewlpe2jFCtxTVQOkyBzTRz5z8OV30wFCZN2LvQALQfFjjwOLcf3TRr3h3sNnPVEAcFtg5GqnGilIaPpU1TMHarNhg3eUPlsCJeTWP7liMdJY9)5L(7c1MoWmqsEqMej0v7pr2ZsjtcQEv6)zfhq5FUwxu9Knpk8rkguUjp7z9UIRaRT5aFTuYBP17ZzbKZu1pA44guG6ubz0kPSg3hSpPL4dlJ3gX99y0Wj8vFAW7S4swtI3minmI7bKeHGzNOouXQFE3(TBJs0M0kHbwqdQDzEDmTohji1Ww90NIRw0OlBq8gHtLK2zFX9u14lLjKYC37YQcpr3RG6zEab)5)XsA048yYxYZjtvAiCmIlLyIvWAp6krTwpMGRuuDS8sqJDKMwI6yPogLd2rLMHmHs1kw(p2V(HTIXeNv(mnM3f8avRbP1WhlShHNiLluozczz56yodRNWND1ikQmiy(jtB(K(19ytuqs5MADHJNiRjNmZkccZnm2a9L(12T6a(4lTUFxuEruov5slrm2EmkuzAcDNq9P8ZTesy7GJBq7(95V0suzTdkamt3it2oMTGMV5PacWjTs)Vs2hXBW0soFznpiE9YONOREbRjMJOzUJYRmP2ze9Ee9nAw3yEcqgjHOorMFxsqAA1QHUMRUJKZR95UVv0GBEgUTEMnjRwzI2KG2bHUWwcfcczhtPcePt6xkz9zFkQ(XnbHGXjHRCn8LW60CwWghPHeYrttjYE2eLhyxIvb7LsTPLqO0Put5PBTJuk187YmMVJ4zr2wIdB1MZB0usDIBj3uTUlhqDCt2(siR0stibdscz4j26xUB))8Fs(Y7YKYQhuJmmTIq190sZwTQKugkZE24brNYxTd5wHP8kjQSKau9iBvszBvUoL7tRXKtyJ(KsiiTbiWKQYaYazEzdBDsP0x4aOXAQlj91Hem3M)uYUQuNa6pP4Kmw6EvCk3A6EXDVczlk4(l2wQsLKXXfX73wYbud7QjMvkLRVBzY6SK05jvmnayJKeLE6HDjnl2N5Cw2Jzsd5BK1KkkpIxRoXaYymUpKhXo7SqoSgJn4WIdA8OGew1gwh)lBnZ3gJkBwAS9knr12UxCCgCYNrCMCj1KsCb5pibPhe(OuA)AjWkWD5rDl(S7iOctsLlXBdYlJjqyhjY5OIIkKAQY(vQMrqlPx395lJhdLG72ufpYvNreBGxrXyLskvnIoK9zNtKTsknAO4AdOYMZHLcLsUBFw9fGrG(h7F4HO80G9LvPKv)NTkeiP5gNTZWPJk(9kvtsPDRtzUtUtSn1r(3H3PN6Ffpto6zbeNBh3Bk5TtUznsnBdt0teRuhRNidS7dgUaGoUvhngQZzWrFpNhdTKVuU6S)CnN95R1q7PMQVykwgX3NoR7yp2UO3MrnaMgCEMBMy69hEWCTecSmpabPkPkSGkubaHjpNtMHlLMacE6luzdn(G(yc4mhMpMAU6GLhNJGhSkGtGyAlpp15WfD7tfoAzLXbMHWf3UH2BFRBR03RjAlU816gd9NO99Utwj9U8iQnc)4rNkhM2KVdwsRDrS1TcN7eBuEyCcX9v6Evf9qEmZnbHhnoK6FBE37Un2gSU06UWPSSIJ61Ha1u3iAmxQvyGnBpso(7K1ytdHsOSUNiveAe)HCiXgW83wRDlClyQBz54rl)0UqBU5JNZbRZwbnCnn9nepLLe6WIBspeFyu6yIIX9WPuw)bWDfhVHL40xMfjBfYcRrbrOh4GlPqcsh0uzxTViUmiXzcWbapDTuvgoyCdWESLIEaw5tZINZXDAPkhqdIG689FoQAjfTeUwNeOZRwNckvN41sUwxxMk4MlmPyUKHoz11D0cFdz1g5RHWlsNhg9SdBuLsIvmkRgLY7WwnQ77(o(mt2PeZq4ARUnSvLiTzmxIa3PsDYw5D5sHv7ED3mU1cDU9IaJ7pyLc3UpBNvhOQlLpgqbGnUv)8DwL3yB5ifXxymVAhRuQn2QePsPAvbiZCTV51IVEyP3WyI19939YYN3eLSBzXg2PwHXiQ0hctfjKPCkcfNggKNgugTmouaD1cOzP3YOVXogmlasNxhWoFhWo)oJD(Yyhs1jeFVcxrdPytqXY9frlPAjRzIBAUocHg9e)GuCdIDgPPrEPqnGFoSYJ3XPi)7ucbzkqy2doiD6OQGZve9qXprC5MWFF3lKoXb7HvFHGtXLVVGUlSes5Hve09WQ0SQK1ruEs)pl3NtgBpcyIsOhvQQFz0WjdHxplEjneDfBjfklUL811lHmNyqkQckTfcsMRt8rfyDW3(6G)XVoyDcPB3QdSY6CouEyvwhZ2FRBK72s9(3BinRv(jnTt)CWQMRdei9LuDceu7V1nIqG8BHa53qG0DdPJIevNyrnZ4alzSrKHXaOROr6CfVvUmvRIvFuPd0VDztJdyUj1xurK)KfsBDpbqiQAawpgWSG23bLUFuPdoJv6se4yLNewPQ1WRM32FrP5UX3brcMHxWA4bsiCBq6(awj3P7Yxhgs)omK(sdPr6ETuasuYBgzb5HW1kfufyNLc6rt5TsojgVak)T1XnWXyA5NLKvk)364sZWzvMcwMJtoKIhJfkLu1q0tLTnGeegV8TNZm)u5sRLUaxbQ9WKCQ1lPdAU4xfj1qTxnTUMidQRO5auZ9jFGHbgnjpAE8uk5inhF(d(xsgV)ytZX8(WQNJl3q(t6VTH85eFMjUUuqimeNKwlC25kA3OUhEhPxK1110HkN2t2XwFxqCo934G6x5eVfqzsxJRXxJRXVtCn(TW143nUg)25Aa6sN4A8W5A8SX14DuCn(MCngwrm5AG2dGtryVnBOokVBfgiwsvOvWCicymaYRrJ16EG8qUPAH2le1SeMIDrHmPnXg5Rh0cn2JS0KxO)Be9FysHscX0JzhjMfEqnue8QQEqLRZi)Bo)ZQrHdR(RKFkMa40OyE7TdT7YOc4kWzb0UVCkI5wxNCxsVnNVAv2Ykpha)cGUb34xGvQ0r(fJTw6oB042ePAv5ZaNO0TA5BqfJb9VxUjqC6Si)Wtr50TpP6Ixz0NzLTa9mfqSRXmGfVDxwEP4kd59kvf(7PHD))UNBuQiJsxd2xMjSOfsgNhIOxUj)NXuPj61PYVLLsgrwZVxKNk9BIccqPxklynxLmls3679TbVrq)NHHUsoO1any(P1HR3OlfG9HbSwEB1answDDf4NowpgbWYBnRoGH22wda)jyaxVzYAa14YjWvaE6Kaeaxv2gAWuVAoCfCNoE(5ljdgcWpDS(Aya3SxqAq1CtIEla5nWGuDFj0al8Mw4kOpDklcGvUAc0am41wGRawF7s0Gn2UP8wdEelhNjW7Jy)4mWP8Da0xyIY5c8ENDbEuqQxS36qgRyWngael2NcoJyR(SyaWhXS15G57sOC9Wxb8vwC3h8(o5LmI(IQc2rdV0RJNwWirHg1nmcJ1r6qlcXwQDEgnwgq9xxuZ0V3WtDTdT4LhIiw2pzBLxk4EPSTFPGlQpK1LUGU2dJAAOfg(nbHNfMD5Q2rFMcCGDCK188PEhg(0Y5rdKYNmiDOGOqVPcpmqp9JOJoer0I3zLzwH2jhCisQdGo9jquaKdOIJc9hjT4))LqcexCo24Ara3PJNV1524eCbdl4(ZIlyEiIfNS4gwaZs1FTgybQmBdGIyJ6Ia0tzj7C5FNqXpIyWrzbvaYlqOcxaqE(LMWI54KL8FZb8Pqeqy5plQuWa(5kWCezRtkYoHRrxUKHGb6Zer5sd(ZPciqx4fBSfLLRd(XBGwIThdSyHRrXMTIdUxQQYTneOvZl8yzR7Q84idkyzgBmwy9Y9HW95vRDxLpcLykxnBaepTMDeOgLBhaKH6Zff8yaoJqbz9OG)kpGn9713g4)HFaR0HNnAqle2wGSnaxpPmSvvZwzDf2OzLLaCG2(saCFUOGhdW4RW(yRdaGVBRWDcYoTcBeWW5qg2oqz18rrzEu6dLBqGSEFoZG)eqCEMdEXgE30LZlWpbSM0wbzXpjU0kMR2TZ)GCcZGnusJnCVQdNtaFc4lTGISHUI2pJGfdznsy75qjUDGAxgeUpNzWFcioMuiyxoVa)eWABsFOD78piNWmawseOdNtaFc4lOSOz7NrWIHSgzNRgQhNppxyW7aG3LNfomi9LLR3vyd4y9Zr831HHs0x2DW7QYkR6cpDW3v2MJnyOlm4DaWUTEI3phXFxhMJITXD3ypk2g3bVJSngbc9oSINUhw5q)6RyT0RV9GCWKrh8J99go5NqeeiTICE)gmyEF7boJT8QpIEToIEIrSI8)gs3(4BoD7Jxa6wnhProQR51HpwHam8ODuH13iB1caGD(fbui72azUxP1tP6tebKstP2((apodt1YpIbjPMDfQ6hqcBoA00Llj0BhUUBOWj7rNHXXQbjZTrVH(GYJ4BHh5TcEE255mA2vO2kxbyxUKqVD46UpTUXZD6JJDEoSeYFCYKxwO3oCpwTPNB4HLe8JJR7Yc92H7XQV4Cdp88ZDmZ7ll0BhUhNmGRy9XbDv4(3tl2VJUVYuit9imUmAl)I5IEoB)Vj)y6JPKV))5F5WQO0Y8xOxqrfSDOEOyJPVpljj7540hOB9Co9Aj65O8OQtQpnEf2XaUcM0hth6XsTSQFPzSD1EFQsVxVM251bLb3fue9lh(6HvF4WkAMBO7i(x2wH0FwfY096MDhahU43V2J(48KDFm9(WG3PIH1Vwp)0SpY3eFX7ZZHVARl0xMh4Eur1UIEXymdWXtk(k(qs353WFxfF)mQaW0zJgo51xnEx)MFJ83WF((K)f9NRpLEZER8OJG0BZ3Sr9S(0rm)MxFL(2X0t544p1FIcUR9mqXNYcUTc5EQ(u4rXLAgrWBy35Kau6rVf5MozKmC0EF7Oac)EmSN9XqgUkVHDNpOw)qWXwFnUS1N7DZOESXP(az)6RMDBkTB9nU3rNoEspTcGR(RL6L)ObUmg(k0z1x3nCcY(DkZ36Nxox)IJBCQIpLZVv08cVDf7(bzgTNn3JGZ86138k6BUhro7DWVpBdWhmPN6kWbB(m)E9ra7RVc)79qEk4Mprbr0EgY44ZMGWR4pzzZ8OKpDSzC7YRIJ7Yvk3oTeOjd2(LWvAzpiUYbWSHToxuo18wMvtN5lPdvCvhhr1cQDP7crq8BsTJ0Aje0OhcakeQ09rvF27Dv1iO0H3HSGl(1MdltJwcy9Rt)eLiH(rMpUyt)0GEqAq8HqDUOUIAwOhqSxFftAdw5)iOXQbvHAvfYq9OI9JGS8uKACDo3d7sQgIfq(s)wMZvPur7vDN8oD24re216fq1E1hN80YYlr0vDmGWvTlVz7y70pzdr1vWJH4CSA61WiK(tLGn9Xeoe6VRwbUsQPL5byxQSuGH8EAn3hBjEkrMdcKkMELqtBx75erFRU8WeWHgS6R0yM2a(Ab3Kk4dH1uqrYJdJjRKiegmK94ghlcMGmkv3mUC)A0kzvR0qOgBoIuY61jM2aupO86t1t)NazB4as(eObyyWVYxk5(1twBV8rmRQbQnIE6xF0tNz88)8JJgowhHCZAv)AnnMpkuCFyQXXQMhOpsvwYuHoXViftBMEyo3FuTvQkl)Mw8NlS4ZPEYNTLg7zGpqtIHTnlL0EztJMb5hI6FZeDIsJnseNdLPRANETEARtET5sTymBSvImU(ejEDyRdevsGHBBCRiMUF5Wkj13n7JgIqLIjmq7cn8PQwUSzOcCvrN60UZbcPnaBBxuuvhbAKpLuAwDa(6DMqf7dQbT7mnQqeGXJo(1Qghg0vslPUR(q6imfJ8M40s46ZbSuu7xcmguzVt908iOLyOHWDj5NLhJfldFxf(AGOCvxVNadaE5r0vxX8ROB(1zGSg(zGo48XP6u(eS(jAq)chpgZ8kmY8X3rF4u8bdDOe0jPdTOD0gq3PtUlz3TS61lj8ONjBR6IYuzNWuD9balrIusxKBk1bItWyGGza65mQDdboPvuXtsDzTEwCTeGTWW9M(INpfcvaqTbs0DuDf0m1icEZxY5MMp2u2njaqflbhag4kyp)AdheuMpnypCyFn6fCqnnFAzor4t1PMOsB(lBvYYzpqnDEZIhZkkMHvdxpf1pAEgUSHB0PIyREYeXwXb7mBnMydSxF3qNzEnw207QjVMJrFb5caOLAd6SYlsICmzkPOZ1yyW)82Z9d(3IWVP3nD243z8y)G(PnriiiY63dM2IDPT0RbAKTHj4SnudSS4b4sSBbJzlpLQjMqFmHYwOEFWc5Wa)19xcXTvyt1Ns29gBJQQJvDbPALpw2alIZ74tRJEcpDSGJT5IdgFfUDL09ajj1MfVbBVjTnS6Y5MjLro99kEsJduWy2Q9H)Cf(uTnRlx0GgmPwnHuT7oxGf52KSils)414JlI)rNzV7Sq3eg97dB1hBLG7oWSppcKOuJbk30NdA86t3JaxDYzMNfwaOLWo40u3OmnSUq(jr3GKl8Svx9Gjdt1VONQxhzgTuWa1CBtgbWPQWn64Y17Gf5SysTzlyuc22)Nx6VlSxBE8IRxSTH0YesZjtS(vf6agdeyCdnGRQAu(j9DYx0qZRGHy)8BkcmGBbccVOCZOxCdDy89rgFWBHIMX3(fhXHV(xoS675Jlxhia8dxWvz7MXEFSeKbVRAEQLOff1vKz16ykiLwHKp3cnNn)UETo0bC1)yXvS7rGUEbf0bCvCuwmyRLrKxFTVAd8WWeNsjzU96g5BfYlGT9uZHvfSD2XcfSfAH81d644ieo6Ye3hCI7JnXbovFYIz4tC4tPly7AtC)wN4(hZeV692rN)0xM)0tI78cD(NSDSXqQIDTZKeWAIJNekBhGmKtTH2ydiiy7mr1H1NQhsiilnGfkQZq2hgYyN9jqixx4Q0)dXl1cHBbRmwvYwG6tcZuAzNrma9w)iF1LPf9LEPIoXsPoQOaKqcNAt8zvnQ4EsCHv10(8ruNFH(D96YShedUqnGemupqxYkv0lUBaH1kveeNLL1ddkxmFMs9FDSuxFqQRpk11VvQRpc11VJuxpaQRhc11SG)TrD9hiVU4g19VWD86pPVSwh7Qpt2c3oJvHl0VcYst9Qcehf7ZgO4TJeRspngnubwPeLH8iyn3hXhnhiv(WKkNKuWTkBJbgLcpqX)i3iv(VfKkkiypnxSCnGI)2KBhyHCztB6a2Bb2I)V]] )