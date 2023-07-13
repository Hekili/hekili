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
    berserker_shout                 = { 90348, 384100, 1 }, -- Go berserk, removing and granting immunity to Fear, Sap, and Incapacitate effects for 6 sec. Also remove fear effects from group members within 12 yards.
    bitter_immunity                 = { 90356, 383762, 1 }, -- Restores 20% health instantly and removes all diseases, poisons and curses affecting you.
    blood_and_thunder               = { 90342, 384277, 1 }, -- Thunderclap costs 10 more Rage and deals 10% increased damage. If you have Rend, Thunder Clap affects 5 nearby targets with Rend.
    bounding_stride                 = { 90355, 202163, 1 }, -- Reduces the cooldown of Heroic Leap by 15 sec, and Heroic Leap now also increases your movement speed by 70% for 3 sec.
    cacophonous_roar                = { 90383, 382954, 1 }, -- Intimidating Shout can withstand 200% more damage before breaking.
    crackling_thunder               = { 90342, 203201, 1 }, -- Thunder Clap's radius is increased by 50%, and it reduces movement speed by an additional 20%.
    cruel_strikes                   = { 90381, 392777, 2 }, -- Critical strike chance increased by 1% and critical strike damage of Execute increased by 5%.
    double_time                     = { 90382, 103827, 1 }, -- Increases the maximum number of charges on Charge by 1, and reduces its cooldown by 3 sec.
    elysian_might                   = { 90323, 386285, 1 }, -- Spear of Bastion's duration is increased by 2 sec. While you remain within Spear of Bastion's area your critical strike damage is increased by 25%.
    fast_footwork                   = { 90371, 382260, 1 }, -- Movement speed increased by 5%.
    furious_blows                   = { 90336, 390354, 1 }, -- Auto-attack speed increased by 5%.
    heroic_leap                     = { 90346, 6544  , 1 }, -- Leap through the air toward a target location, slamming down with destructive force to deal 423 Physical damage to all enemies within 8 yards.
    impending_victory               = { 90326, 202168, 1 }, -- Instantly attack the target, causing 900 damage and healing you for 30% of your maximum health. Killing an enemy that yields experience or honor resets the cooldown of Impending Victory and makes it cost no Rage.
    inspiring_presence              = { 90332, 382310, 1 }, -- Rallying Cry's duration is increased by 3 sec and it grants an additional 5% maximum health.
    intervene                       = { 90329, 3411  , 1 }, -- Run at high speed toward an ally, intercepting all melee and ranged attacks against them for 6 sec while they remain within 10 yds.
    intimidating_shout              = { 90384, 5246  , 1 }, -- Causes the targeted enemy to cower in fear, and up to 5 additional enemies within 8 yards to flee. Targets are disoriented for 8 sec.
    leeching_strikes                = { 90344, 382258, 1 }, -- Leech increased by 5%.
    menace                          = { 90383, 275338, 1 }, -- Intimidating Shout will knock back all nearby enemies except your primary target, and cause them all to cower in fear for 15 sec instead of fleeing.
    overwhelming_rage               = { 90378, 382767, 2 }, -- Maximum Rage increased by 15.
    pain_and_gain                   = { 90353, 382549, 1 }, -- When you take any damage, heal for 3.50% of your maximum health. This can only occur once every 10 sec.
    piercing_howl                   = { 90348, 12323 , 1 }, -- Snares all enemies within 12 yards, reducing their movement speed by 70% for 8 sec.
    piercing_verdict                = { 90379, 382948, 1 }, -- Spear of Bastion's instant damage increased by 50% and its Rage generation is increased by 100%.
    rallying_cry                    = { 90331, 97462 , 1 }, -- Lets loose a rallying cry, granting all party or raid members within 40 yards 15% temporary and maximum health for 10 sec.
    reinforced_plates               = { 90368, 382939, 1 }, -- Armor increased by 20%.
    rumbling_earth                  = { 90374, 275339, 1 }, -- Shockwave's range increased by 6 yards and when Shockwave strikes at least 3 targets, its cooldown is reduced by 15 sec.
    second_wind                     = { 90332, 29838 , 1 }, -- Restores 6% health every 1 sec when you have not taken damage for 5 sec.
    seismic_reverberation           = { 90340, 382956, 1 }, -- If Whirlwind hits 3 or more enemies, it hits them 1 additional time for 30% damage.
    shattering_throw                = { 90351, 64382 , 1 }, -- Hurl your weapon at the enemy, causing 1,621 Physical damage, ignoring armor, and removing any magical immunities. Deals up to 500% increased damage to absorb shields.
    shockwave                       = { 90375, 46968 , 1 }, -- Sends a wave of force in a frontal cone, causing 360 damage and stunning all enemies within 10 yards for 2 sec. Generates 10 Rage.
    sonic_boom                      = { 90321, 390725, 1 }, -- Shockwave deals 350% increased damage and will always critical strike.
    spear_of_bastion                = { 90380, 376079, 1 }, -- Throw a spear at the target location, dealing 2,970 Physical damage instantly and an additional 3,203 damage over 4 sec. Deals reduced damage beyond 5 targets. Enemies hit are chained to the spear's location for the duration. Generates 20 Rage.
    spell_reflection                = { 90385, 23920 , 1 }, -- Raise your weapon, reflecting the first spell cast on you, and reduce magic damage you take by 20% for 5 sec.
    storm_bolt                      = { 90337, 107570, 1 }, -- Hurls your weapon at an enemy, causing 513 Physical damage and stunning for 4 sec.
    thunderous_roar                 = { 90359, 384318, 1 }, -- Roar explosively, dealing 2,880 Physical damage to enemies within 12 yds and cause them to bleed for 3,688 physical damage over 8 sec. Generates 10 Rage.
    thunderous_words                = { 90358, 384969, 1 }, -- Increases the duration of Thunderous Roar's Bleed effect by 2.0 sec and increases the damage of your bleed effects by 15% at all times.
    titanic_throw                   = { 90341, 384090, 1 }, -- Throws your weapon at the enemy, causing 630 Physical damage to it and 5 nearby enemies. Generates high threat.
    uproar                          = { 90357, 391572, 1 }, -- Thunderous Roar's cooldown reduced by 30 sec.
    wild_strikes                    = { 90360, 382946, 2 }, -- Haste increased by 1% and your auto-attack critical strikes increase your auto-attack speed by 10% for 10 sec.
    wrecking_throw                  = { 90351, 384110, 1 }, -- Hurl your weapon at the enemy, causing 1,621 Physical damage, ignoring armor. Deals up to 500% increased damage to absorb shields.

    -- Arms
    anger_management                = { 90289, 152278, 1 }, -- Every 20 Rage you spend reduces the remaining cooldown on Warbreaker and Bladestorm by 1 sec.
    armored_to_the_teeth            = { 90366, 384124, 2 }, -- Gain Strength equal to 5% of your Armor.
    avatar                          = { 90365, 107574, 1 }, -- Transform into a colossus for 20 sec, causing you to deal 20% increased damage and removing all roots and snares. Generates 10 Rage.
    barbaric_training               = { 92221, 383082, 1 }, -- Slam and Whirlwind deal 30% more damage but now cost 10 more rage.
    battle_stance                   = { 90327, 386164, 1 }, -- A balanced combat state that increases the critical strike chance of your abilities by 3% and reduces the duration of movement impairing effects by 10%. Lasts until canceled.
    battlelord                      = { 92615, 386630, 1 }, -- Overpower deals 35% increased damage, has a 35% chance to reset the cooldown of Mortal Strike and Cleave and reduces their Rage costs by 10.
    blademasters_torment            = { 90363, 390138, 1 }, -- Activating Avatar or Bladestorm casts the other at reduced effectiveness.
    bladestorm                      = { 90441, 227847, 1 }, -- Become an unstoppable storm of destructive force, striking all nearby enemies for 6,873 Physical damage over 5.1 sec. Deals reduced damage beyond 8 targets. You are immune to movement impairing and loss of control effects, but can use defensive abilities and can avoid attacks. Generates 20 Rage.
    bloodborne                      = { 90283, 383287, 2 }, -- Deep Wounds, Rend and Thunderous Roar's Bleed effects deal 7.50% increased damage.
    bloodletting                    = { 90438, 383154, 1 }, -- Deep Wounds, Rend and Thunderous Roar's Bleed effects last 6.0 sec longer and have a 5% increased critical strike chance. If you have Rend, Mortal Strike inflicts Rend on targets below 35% health.
    bloodsurge                      = { 90277, 384361, 1 }, -- Your Bleed effects have a chance to grant you 5 Rage.
    blunt_instruments               = { 90287, 383442, 1 }, -- Colossus Smash damage increased by 30% and its effect duration is increased by 3.0 sec.
    cleave                          = { 90293, 845   , 1 }, -- Strikes all enemies in front of you for 1,323 Physical damage, inflicting Deep Wounds. Cleave will consume your Overpower effect to deal increased damage. Deals reduced damage beyond 5 targets.
    collateral_damage               = { 90267, 334779, 1 }, -- When Sweeping Strikes ends, your next Whirlwind deals 25% increased damage for each ability used during Sweeping Strikes that damaged a second target.
    colossus_smash                  = { 90290, 167105, 1 }, -- Smashes the enemy's armor, dealing 3,267 Physical damage, and increasing damage you deal to them by 30% for 10 sec.
    concussive_blows                = { 90333, 383115, 1 }, -- Cooldown of Pummel reduced by 1.0 sec. Successfully interrupting an enemy increases the damage you deal to them by 5% for 10 sec.
    critical_thinking               = { 90444, 389306, 2 }, -- Critical Strike chance increased by 1% and Execute immediately refunds 5% of the Rage spent.
    crushing_force                  = { 90347, 382764, 2 }, -- Slam deals an additional 30% damage and has a 7.50% increased critical strike chance.
    dance_of_death                  = { 92535, 390713, 1 }, -- If your Bladestorm helps kill an enemy your next Bladestorm lasts 3.0 sec longer.
    defensive_stance                = { 92537, 386208, 1 }, -- A defensive combat state that reduces all damage you take by 15%, and all damage you deal by 10%. Lasts until canceled.
    deft_experience                 = { 90437, 389308, 2 }, -- Mastery increased by 1% and Tactician's chance to trigger is increased by an additional 0.6%.
    die_by_the_sword                = { 90276, 118038, 1 }, -- Increases your parry chance by 100% and reduces all damage you take by 30% for 8 sec.
    dreadnaught                     = { 90285, 262150, 1 }, -- Overpower has 2 charges and causes a seismic wave, dealing 866 damage to all enemies in a 10 yd line. Deals reduced damage beyond 5 targets.
    endurance_training              = { 90338, 382940, 1 }, -- Stamina increased by 5% and the duration of Fear, Sap and Incapacitate effects on you is reduced by 10.0%.
    executioners_precision          = { 90445, 386634, 1 }, -- Execute causes the target to take 35% more damage from your next Mortal Strike, stacking up to 2 times.
    exhilarating_blows              = { 90286, 383219, 1 }, -- Mortal Strike and Cleave have a 20% chance to instantly reset their own cooldowns.
    fatality                        = { 90439, 383703, 1 }, -- Your Mortal Strikes and Cleaves against enemies above 30% health have a high chance to apply Fatal Mark. When an enemy falls below 30% health, Your next Execute inflicts an additional 4,476 Physical damage per stack.
    fervor_of_battle                = { 90272, 202316, 1 }, -- If Whirlwind hits 2 or more targets it also Slams your primary target.
    frothing_berserker              = { 90352, 392792, 1 }, -- Mortal Strike and Cleave have a 20% chance to immediately refund 20% of the Rage spent.
    fueled_by_violence              = { 90275, 383103, 1 }, -- You are healed for 85% of the damage dealt by Deep Wounds.
    honed_reflexes                  = { 90354, 382461, 1 }, -- Cooldown of Overpower and Pummel reduced by 1.0 sec.
    hurricane                       = { 90440, 390563, 1 }, -- While Bladestorming, every 0.8 sec you gain 5% movement speed and 5% Strength, stacking up to 6 times. Lasts 6 sec.
    ignore_pain                     = { 90269, 190456, 1 }, -- Fight through the pain, ignoring 50% of damage taken, up to 7,095 total damage prevented.
    impale                          = { 90292, 383430, 1 }, -- The damaging critical strikes of your abilities deal an additional 10.00% damage.
    improved_execute                = { 90273, 316405, 1 }, -- Execute no longer has a cooldown and if your foe survives, 10% of the Rage spent is refunded.
    improved_overpower              = { 90279, 385571, 1 }, -- Damage of Overpower increased by 15%.
    improved_slam                   = { 92614, 400205, 1 }, -- Slam has 15% increased critical strike chance and deals 30% increased critical strike damage.
    improved_sweeping_strikes       = { 92536, 383155, 1 }, -- Sweeping Strikes lasts 6 sec longer.
    in_for_the_kill                 = { 90288, 248621, 1 }, -- Warbreaker increases your Haste by 10%, or by 20% if any target is below 35% health. Lasts 10 sec.
    juggernaut                      = { 90446, 383292, 1 }, -- Execute increases Execute's damage dealt by 3% for 12 sec, stacking up to 15 times.
    martial_prowess                 = { 90278, 316440, 1 }, -- Overpower increases the damage of your next Mortal Strike or Cleave by 30%. Stacking up to 2 times.
    massacre                        = { 90291, 281001, 1 }, -- Execute is now usable on targets below 35% health.
    merciless_bonegrinder           = { 90266, 383317, 1 }, -- When Bladestorm ends, Whirlwind and Cleave deal 50% increased damage for 9 sec.
    mortal_strike                   = { 90270, 12294 , 1 }, -- A vicious strike that deals 3,478 Physical damage and reduces the effectiveness of healing on the target by 50% for 10 sec.
    overpower                       = { 90271, 7384  , 1 }, -- Overpower the enemy, dealing 2,515 Physical damage. Cannot be blocked, dodged, or parried. Increases the damage of your next Mortal Strike by 30%. Stacking up to 2 times.
    reaping_swings                  = { 90294, 383293, 1 }, -- Cooldown of Cleave reduced by 3 sec.
    rend                            = { 90284, 772   , 1 }, -- Wounds the target, causing 1,329 Physical damage instantly and an additional 2,602 Bleed damage over 15 sec.
    sharpened_blades                = { 90447, 383341, 1 }, -- Your Mortal Strike, Cleave and Execute critical strike damage is increased by 10% and your Execute has a 5% increased critical hit chance.
    sidearm                         = { 90333, 384404, 1 }, -- Your auto-attacks have a 20% chance to hurl weapons at your target and 3 other enemies in front of you, dealing an additional 450 Physical damage.
    skullsplitter                   = { 90281, 260643, 1 }, -- Bash an enemy's skull, dealing 2,160 Physical damage. Skullsplitter causes your Deep Wounds to expire instantly. Generates 15 Rage.
    spiteful_serenity               = { 90289, 400314, 1 }, -- Colossus Smash and Avatar's durations are increased by 100% but their damage bonuses are reduced by 40%.
    storm_of_swords                 = { 90267, 385512, 1 }, -- Whirlwind costs 20 more Rage and has a 14.0 sec cooldown. It now deals 175% more damage.
    storm_wall                      = { 90269, 388807, 1 }, -- Whenever you Parry, you heal for 8.00% of your maximum health. Can only occur once per second.
    strength_of_arms                = { 92536, 400803, 1 }, -- Overpower has 10% increased critical strike chance, deals 10% increased critical strike damage and on enemies below 35% health Overpower generates 8 Rage.
    sudden_death                    = { 90274, 29725 , 1 }, -- Your attacks have a chance to make your next Execute cost no Rage, be usable on any target regardless of their health, and deal damage as if you spent 40 Rage.
    tactician                       = { 90282, 184783, 1 }, -- You have a 2.50% chance per Rage spent on abilities to reset the remaining cooldown on Overpower.
    test_of_might                   = { 90288, 385008, 1 }, -- When Warbreaker expires, your Strength is increased by 1% for every 10 Rage you spent during Warbreaker. Lasts 12 sec.
    thunder_clap                    = { 92224, 396719, 1 }, -- Blasts all enemies within 8 yards for 1,189 Physical damage. and reduces their movement speed by 20% for 10 sec. Deals reduced damage beyond 5 targets.
    tide_of_blood                   = { 90280, 386357, 1 }, -- Skullsplitter deals 30% increased damage and also causes your Rend to expire instantly.
    twohanded_weapon_specialization = { 90322, 382896, 1 }, -- Increases your damage while using two-handed weapons by 5%.
    unhinged                        = { 90440, 386628, 1 }, -- While Bladestorm is active, you automatically cast a total of 2 Mortal Strikes at random nearby enemies.
    valor_in_victory                = { 90442, 383338, 1 }, -- Increases Versatility by 1% and reduces the cooldown of Die by the Sword by 30.0 sec.
    war_machine                     = { 90328, 262231, 1 }, -- Your auto attacks generate 10% more Rage. Killing an enemy instantly generates 5 Rage, and increases your movement speed by 30% for 8 sec.
    warbreaker                      = { 90287, 262161, 1 }, -- Smash the ground and shatter the armor of all enemies within 8 yds, dealing 3,267 Physical damage and increasing damage you deal to them by 30% for 10 sec.
    warlords_torment                = { 90363, 390140, 1 }, -- Activating Avatar or Colossus Smash casts Recklessness at reduced effectiveness.
} )


-- PvP Talents
spec:RegisterPvpTalents( {
    death_sentence         = 3522, -- (198500) Execute charges you to targets up to 15 yards away. This effect has a 6 sec cooldown.
    demolition             = 5372, -- (329033) Reduces the cooldown of your Shattering Throw or Wrecking Throw by 50% and increases its damage to absorb shields by an additional 250%.
    disarm                 = 3534, -- (236077) Disarm the enemy's weapons and shield for 5 sec. Disarmed creatures deal significantly reduced damage.
    duel                   = 34  , -- (236273) You challenge the target to a duel. While challenged, all damage you and the target deal to all targets other than each other is reduced by 50%. Lasts 8 sec.
    master_and_commander   = 28  , -- (235941) Cooldown of Rallying Cry reduced by 1 min, and grants 15% additional health.
    rebound                = 5547, -- (213915) Spell Reflection reflects the next 2 incoming spells cast on you and reflected spells deal 50% extra damage to the attacker. Spell Reflection's cooldown is increased by 10 sec.
    shadow_of_the_colossus = 29  , -- (198807) Charge resets the cooldown of your Overpower and Rage gained from Charge increased by 15.
    sharpen_blade          = 33  , -- (198817) When activated, your next Mortal Strike will deal 15% increased damage and reduce healing taken by 50% for 4 sec.
    storm_of_destruction   = 31  , -- (236308) Reduces the cooldown of Bladestorm by 33%, and Bladestorm now also applies Mortal Wound to all targets you hit.
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
        duration = 10,
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
        tick_time = 3,
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
    rallying_cry = {
        id = 97463,
        duration = function () return 10 + ( talent.inspiring_presence.enabled and 3 or 0 ) end,
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
        tick_time = 3,
        max_stack = 1,
        copy = 772
    },
    sharpen_blade = {
        id = 198817,
        duration = 3600,
        max_stack = 1
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
        if talent.anger_management.enabled then
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
        charges  = function () return talent.double_time.enabled and 2 or 1 end,
        cooldown = function () return talent.double_time.enabled and 17 or 20 end,
        recharge = function () return talent.double_time.enabled and 17 or 20 end,
        gcd = "off",

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
            removeBuff( "sudden_death" )
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
            gain( ( talent.inspiring_presence.enabled and 0.2 or 0.15 ) * health.max, "health" )
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
            removeDebuff( "target", "deep_wounds" )
            if talent.tide_of_blood.enabled then
                removeDebuff( "target", "rend" )
            end
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


spec:RegisterPack( "Arms", 20230711, [[Hekili:DZ1w3nUTr4Fl(fU2P7QLKYY2jhjDoPPVK90Z(qD6RIcMeYIXuKQ8I9U5OJ(T3b8kUnGu3Ct6dTzxrGbdMRFZaGDHZIFBXJbKC6IV6A7o2(EhNro35E347x8y(33sx84wI)lKNH)qmzd8))ZPBYy)43JsibSjNLuK6dFyDE(2SF6ZF(5W81fpnYpzZNZc3uerYdtI9tjRYz)D)pV4XNkcJY)14fpPFLNS4rsr(6K0fp(ylb(fgbGfjmiGwntAM)IhzZ8t23)jhNFA)Y9l)3BzeC)Y80W4xO5z7xUkjD)sh7roJMmA)x2)LQjm5tU26MWN)L)rMWWSFOAyzWy(5uFsm8F)TK0uAC((Le4)TnLMN)99lJsEJ9xctsdz)1W49lZcJFoI(PCs6Z0CrQ6kS4D8y3Gg)j37kh0Vg7hveaJ6XT0OO9l)x0vruFMiz0IhJcZYZkvcLRLx1Ab)Wxl1R0yYtr0Gf)9fp6d8fnnKadLrN6rMn6T1HPrVfghSF5CGjarFjTHH9gLUfOQxgiBEHMTih0tmI2mGnjP5KO6pZVwWahJU6P0nKWyqXmD2(Lp7hmAd5B7xUBhOcirGuDuEya1lzL3trjjbJQPX(Lw7x6NKefK8w8OSxkIIY2gfMdeDKEkcJ)AUP4NeLKLvK5LTHKTgzomUiG(uXQvYJVy7(L3us0GKCy2XbCKG7hdkslTw3V8h2V0E0dt6exSVZen3IkAQfaVrsJssdY8Yts3W(bEzqk4joARFE5YoEC)7tsW37BJX(A53YPz5mr)MWNxN3SNzF9QwTJrM7uzKB6KwKxjGfktEnbvED4k32zaBJNaw6feZhoVGTusAP5ijR8xao6oEVGokj5cCp)Oe5qPr(a6oerRW7Ti8rELbUywNzKOw(WPA3wfc(hhqttGpMMuPc)X(m5xxKMgYcUkBozqaCkCBRHDnfkIxdr6ObVFlFN86PicKkJ5oXevo29jRWJpQgAQAxy2ZVxVO5CorquTBlj7jkzoIfTwJXSCRSAT58s5tiukgXt)vY5zfmyeEbusEzSj)8oIr)g1VaqLWiJBFAJSK4qFVNss20S)44Q1j(V8g51ksHNsSMueWcm1Bdjg2HIHwpj)9o(j854KuQ3wqcxYr9MjQ0QKTAzVXI5lSC1d5jsEEeLLsajnfOiFWEGmylwKs2ZqG)1mWlGvceX2TK2x1hdH6gWSc7SSAJj6orogHkH7y8KxPPBtER227UJwUYTCROPVMuN5HTWc7g26(k1Jgt3esZKrUjkgVVpUbrI18vwygpsCGxDGD1DF9h88JiBlxs8eAM0bYPLMypavRgfhMAbplujpTHM6hgrZYaV5y6Zq9aSnlQ5PlEG6mAoJgfzqSAAQ7p65U1xAR4NwKXs54bq)9PQIu)iADCdx8izvHcNZcf2yJF1aSFowJmWzZriZvwePmNLRqzbC5ZeH54oMFyKYIPyWiz1sjp0BfapvjmKgYebuyPu)xyYZ81PjVjpuChsbq8Iy3hRaDpNz)UIue1tbw5HBOvWjThnPsEVbmflJPhafSrI9R0BpWThldPPuJ12InBOr6kUIdGkunxABrHsJfpgpl9A72NXRgcsZNw(H6cgGVxoJvSmrE8csExWTjnOMhao(kq)cvwXPfirqbRGyYBBXF8hqTUpL8Tw044U110K3p(1qOSvWMNehUbQ)oOckvlM9Img(QvEGaIPL7WfevQcdl24TfsSdo5K4xdLvopyIepbinsIbJEWof2a0VNagwIZVNOuA2oHPaIqqvTcIhWyWEGrEvn4Twk1eAQ)8Za2eaSdeAKUc8B9x3dsR3hlSNH4nHeGFGa3KGN5WT1mcM2a4jwBRee1gGK1Ask0KdbU0H5BBXbiDInA0nZOT6jPOzEPBnJyIPmVFViOZma3P7mTOprEM5kbF1)LSEq)0VM)oExL0mAklMEpOy63SLfVf4Fyx4tIIokek8KRcr0QI0V3dSI(jLkNzawrkjmWJ(AzPcbmuJFJ18VkFfnacDHCdm1sUqeO0IyVQ)ShR3HvDq0RQZURj(ArC0MJc4rXj7)D)2MoMvUoClzhNFDlGdqcKr8tPsinlBq6AkjcQgRTRe8iW1naquXZ9CLT5Ix22vmhwDYXdwAj2X1s0bBbuijBaOuT4d6CtyWR8QY9ldpr3axNuidksoAvfBOlRypPmZ7ewx0gf3dIl1U1k0MXM(ZXBP0BBdMw2QaoeU9riTncSPFdD2MmiDS02bHvi3GemYOdn0Z7tQPO9LkKpRtBttfWpJ2Isbi0gBrzpGSo(gb1Fmsn9t8WtgyOj3l4HsR0Rx8efT59V1uJOWZoyY7YTTFEbGVL3BjGiitWavPr1DvmAa7hhp31fVnK0CgI4TqLtq5VJGGu(VuzB1rEXsPXJzuRaQIVaZeYI7XclgMb)Lgsx12MsZE0TOUMXlEItk48AcQnyuEhCp8eCR6ejslOGBfw5W5v5BngaUuu(7fp)mnnMuK3Gvx(NnAxWNweDH0bFGVjq8D45GAse)GkBnTGVV6rPnd)S0gResOTHt4AyLnwBhd5pRQoDKic)jYXX4gy7g5gZzcXH9lZBv9xHvrHHuKAGcXuw2cj9gkkR5sOS658f()JZFfVKizGHSZWNZmG3gayQCwOnDNcQgNjhbCScGjqtHBOPv65txx0AbC0cgqtMumWasy51dh)OSbBq6RPyIM0VdcHcEI2l654v3caJgo6niWtWBe7JHS7)pCJAgeLb8c1S0FIoa2dklPZLNrnj4hBFQwysB(ditAlgUEp7nJhVIyMf82TzcW7WZX2X19DuCCQvCwVTOIUlWGKX1qpstbK5dkBm2P9xYpYirAe0i4HgqfO6TVVXqPpg6eO4jKn2272T(MG5JxWNXDBTmmGvNnGuMZPdRWg5Y90Zsx26De0)A4DbG3694KvZmQ7QpdRs)lLlCqryRC1j0hdAkpu7lcKboltnwa63Uhq)v1KCtt(ydNpR(GpDkVbx3PH(zIwebd89FoUMecrjeC3ChE6M29vVBbHREY989MP54QXtxOkXUEa5V5dxFGz47eRMeFDc(sHo)MsuEINFrNTOIDDBb1UcxXrtx0xx8qZOQq9LW13PV)vx8EX1xYCob8bDLhmCVACXl44yUMhJ79E)z(A6GF5XSASCeUOixK(i0TXKUQzJ7Taa9skCU)W1LZAldFixsgnxZLXNVld4yd3pEmK(yy2hl2RFdxeMYMocXlyqtQFZfty9E4nsAmmfOQGFBniPd3SfC4RFvcFq4yU(aR5u)NIWuMiklHDnxif5jL3IIY8nGvi79t8pdzVtIX)0(L)ssmSILF(d6G0cumpb5Bncrymx78TBAP7T6PR8vtxI0y3C93xQ)aImHpVHSmrxoL3l6(J6PBB9os0u5ICpq6DP4ZM(kirs52nmqQDYCPJ9fYLaLWNmhJ4elNVrI2yPJgk5pD(gXnwcIGePraqmuI3LIwIUQ5Uvi5K)sqY7UKsveIlNKwI6y5Wvi)9NFXbgjLpomzkJDCzklasy9tGNDrIuicatIS6rNPqANlQc8Ir(9FrdUN62F8HdcXJlk2H6ZC5dkOgKUDkkB6Zofr8Yo9iUiHY7aflhwqbTCpQK1e)ZI6GVAx5DQMd6EGQKZMtpc9zLblrs(tuxMkiAJUAhuyp5J2wMIij9AksuIEY1ooqQDYiHWs6P5uB1jbqoyx5vbjW)rklE3HBEYegju8rc3gJCNoFIfb4KjmM71XNy(YIyfXT4KD3WGaXDUfsKvZjAOqueypxeIEkQmeh3JmmagaNJkdAnjXswD8B6lbjp)EtUy5xovp)3DcFkcbet(ZsifmIFYWXRjpIV1zOoLXiPfpbjngjptTjbJ8hzGMXibAohY2lvrAVpKhj22rfbE)x(1YYxyeAs15rWoERY)j7b(m75IKSkmI208(SrTVFK)2SpxXO1VyK9FX0qyVve9JO5LV9r2BfzMMxdcJlRNim8QJ)8JHRMXUIItNzpAYUDkpD15pWpNQxOk)Vi)IufgD5ZbLTcCpoWz2wgFAyZFy3o2lGWs41pm1DcpL1S5yldYBlD6y(5Q)bHYMEjx19sj5MdYRb9JCp9Zzo8tq3B)eF0YpQtZmJ8dZKn6RehU1vOxWhocj)ykVeAQ2NJPG6t4btkO50ENWM7mAIf7KbNoXMNospcsgHWp5DREU3z8Ap(3545JQTpYrCs2SHVtqCj8WbXNSO2T7Llo0zCCRJ0ZMRk6ZAI)hREIDZCyes)ZWB3oXZTDURqakPxGyfLRBv3hfUVpWIWVAxJKA0s54SNoEYn72P(ZU29UffoRuHL)kKhVzx436RqgLfav6YmXiaYRfAUJocW6luPiU2)J5cBD9v1IGUweA1Z1ZF6Tmbb6KuF7CtV9gl1l5(ChxDCzvOjbxDDVpUD7Wm50hRXw3A1XQ6(QiL1ncPl(vB0y5Be5UDxPdZpsutoVgE1V0nO2Kxhic0EXm1rw(7NzLdie98wTIRQ7LIj7oxlKRY4uWwthjBVOsClTv11Rv37pBQwtgHaQCYftx)YzUGfecVodHzR)tAfJn3JJsysYOanUZ19XU2UYhlaIv2XfTgBcVeml5FsR8VIq8D1Mrn5qSwn2SCJR53uABDZhybzSKVkxtNP8uC(b7rJLziDr4KyQzUwxB4bAn3zsNVw3NVrELAcfks9zowIXgvc3p31Un2xtod1CfZRZvuj947xML5hlv9Y2x8x2OWJ)DJQ4xN0)HjYcLUiVQ32OsblVCvQJ4ws6jN2CLCr8fIcxTMDrGrwxxxLC)oYerueOKWVkpVAI7bOjzz9nVAiov8PeU(SKt4gleTIS0bleSI3MMekxuwvMb68p5cA2COawNjwX8IQi7otRQobWy7Jxx1L5voinx4U22rvNaf59P0tHiZ1KPOnbVEoOjFNyhcRLLySrngf(NiJIYcdCcsWv54E1CGMxbGC4Qs0ahgykfMvbfc6IxTonnoJe8kREQAyjJlHxP5HWiVCciNqxQA5e3bHyMT1e78maMQvFXXhwQMTIkLPZCXG(OHlRKakpcfzxUPmaeNqYGAJbDpTO(temOOIcijL91SmaTuJzHc8MRRFkdGuqtyJRX7EXUDnpGIPUCGB6MSQVBertiwGh0SWn0E(9kaee2pDC)1Adi3fxyaHPR2wQBKQT6uvwPp8Yg9SgmcuvWBgqmleywFy42TOC3UvGSHN0Pryl2SF5XZD7(5yho1C9ViF8gLQFi94jH3gZ8tlNZVIdr2mZPlnR8qvx5bwkOo8iAHnOO0fUm)8fik0PjKcQgqlJKjdIHS8W01FP)svgK8gQRGO6nH815VnW10XJnXV91VkT4l6m5uw2JDPUXGPIMQbgMcWuJ)e7KI8AQR9BYJbRAl5Xn8wXDaPiaauCA4dTkaCMvBLpTiHpxfH0UvVC1uPyfjdyxR3VkoDCFJESbzvR8d3ADq7RbrYgya8HFL3TYDItZBGgxszmlrZ5qGpF9jBLtTEGw7gCv7hOHga9T46Ea7ecnTMiq)oZaxpP98XaUcjYvlSsuCtk9CDGIodNjzRSzITg5QGSBGYjJ18BimF3rlO5FM0T6daQI3vn6VwCEyO3gQcCMJHOE8DRhflHWjz3NGWGWwc83qbJXxfr5)C84V4R37u(4px8Fd]] )